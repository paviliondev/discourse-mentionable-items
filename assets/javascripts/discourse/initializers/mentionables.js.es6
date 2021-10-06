import { withPluginApi } from "discourse/lib/plugin-api";
import { findRawTemplate } from "discourse-common/lib/raw-templates";
import { searchMentionableItem } from "../lib/mentionable-item-search";
import { linkSeenMentionableItems } from "../lib/mentionable-items-preview-styling";
import { SEPARATOR } from "../lib/discourse-markdown/mentionable-items";
import EmberObject, { set } from "@ember/object";
import { caretPosition, inCodeBlock } from "discourse/lib/utilities";
import Site from "discourse/models/site";
import { schedule } from "@ember/runloop";

export default {
  name: "mentionable-items",
  initialize(container) {
    const siteSettings = container.lookup("site-settings:main");

    if (!siteSettings.mentionables_enabled) {
      return;
    }

    const length = Site.current().mentionable_items.length;
    const obj = EmberObject.create(Site.current().mentionable_items);

    set(obj, "length", length);
    Site.current().set("mentionable_items", obj);

    withPluginApi("0.8.13", (api) => {
      api.modifyClass("component:d-editor", {
        didInsertElement() {
          this._super(...arguments);
          const $editorInput = $(this.element.querySelector(".d-editor-input"));
          this._applyMentionableItemsAutocomplete($editorInput);
        },

        _applyMentionableItemsAutocomplete($editorInput) {
          $editorInput.autocomplete({
            template: findRawTemplate("mentionable-item-autocomplete"),
            key: SEPARATOR,
            afterComplete: (value) => {
              this.set("value", value);
              return this._focusTextArea();
            },
            transformComplete: (item) => item.model.slug,
            dataSource: (term) =>
              term.match(/\s/)
                ? null
                : searchMentionableItem(term, siteSettings),
            triggerRule: (textarea) =>
              !inCodeBlock(textarea.value, caretPosition(textarea)),
          });
        },

        _updatePreview() {
          this._super(...arguments);

          schedule("afterRender", () => {
            const $preview = $(this.element.querySelector(".d-editor-preview"));
            if (this._state !== "inDOM" || $preview.length === 0) {
              return;
            }
            linkSeenMentionableItems($preview, siteSettings);
          });
        },
      });

      api.onToolbarCreate((toolbar) => {
        toolbar.addButton({
          id: "insert-mentionable",
          group: "extras",
          icon: siteSettings.mentionables_composer_button_icon,
          title: "mentionables.composer.insert.title",
          perform: (e) => {
            e.addText(SEPARATOR);
            $(document.querySelector("#reply-control .d-editor-input")).trigger(
              "keyup.autocomplete"
            );
          },
        });
      });
    });
  },
};

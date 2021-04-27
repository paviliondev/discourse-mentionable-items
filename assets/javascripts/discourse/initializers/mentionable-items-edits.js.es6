import { withPluginApi } from "discourse/lib/plugin-api";
import { findRawTemplate } from "discourse-common/lib/raw-templates";
import { searchMentionableItem } from "../lib/mentionable-item-search";
import { mentionableItemTriggerRule } from "../lib/mentionable-item-trigger";
import { linkSeenMentionableItems } from "../lib/mentionable-items-preview-styling"
import { linkSeenMentions } from "discourse/lib/link-mentions";
import { set } from "@ember/object";
import { inCodeBlock } from "discourse/lib/utilities";
import EmberObject from "@ember/object";
import Site from "discourse/models/site";
import { schedule } from "@ember/runloop";

export default {
  name: "mentionable-items-edits",
  initialize(container) {
    const currentUser = container.lookup("current-user:main");
    const siteSettings = container.lookup("site-settings:main");

    if (!siteSettings.mentionable_items_enabled) return;

    const length = Site.current().mentionable_items.length;
    const obj = EmberObject.create(Discourse.Site.current().mentionable_items);

    set(obj, "length", length);

    Site.current().set("mentionable_items", obj);

    withPluginApi("0.8.13", (api) => {
      api.modifyClass("component:d-editor", {
        didInsertElement() {
          this._super(...arguments);

          const $editorInput = $(this.element.querySelector(".d-editor-input"));
          this._applyMentionablItemsAutocomplete($editorInput);
        },

        _applyMentionablItemsAutocomplete($editorInput) {
          const siteSettings = this.siteSettings;

          $editorInput.autocomplete({
            template: findRawTemplate("mentionable-item-autocomplete"),
            key: "+",
            afterComplete: (value) => {
              this.set("value", value);

              return this._focusTextArea();
            },
            onKeyUp: (text, cp) => {
              if (inCodeBlock(text, cp)) {
                return false;
              }

              const matches = /(?:^|[\s.\?,@\/#!%&*;:\[\]{}=\-_()])(\+(?!:).?[\w-]*:?(?!:)(?:t\d?)?:?) ?$/gi.exec(
                text.substring(0, cp)
              );

              if (matches && matches[1]) {
                return [matches[1]];
              }
            },
            transformComplete: (obj) => {
              return obj.model.name_slug;
            },
            dataSource: (term) => {
              if (term.match(/\s/)) {
                return null;
              }

              const return_var = searchMentionableItem(term, siteSettings);

              return return_var;
            },

            triggerRule: (textarea, opts) => {
              return mentionableItemTriggerRule(textarea, opts);
            },
          });
        },

        _updatePreview() {
          this._super(...arguments);

          schedule("afterRender", () => {
            if (this._state !== "inDOM") {
              return;
            }

            const $preview = $(this.element.querySelector(".d-editor-preview"));
            if ($preview.length === 0) {
              return;
            }

            linkSeenMentionableItems($preview);
          });
        }
      });
    });
  },
};

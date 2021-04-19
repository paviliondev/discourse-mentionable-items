import { withPluginApi } from "discourse/lib/plugin-api";
import { findRawTemplate } from "discourse-common/lib/raw-templates";
import { searchMentionableItem } from "../lib/mentionable-item-search";
import {
  mentionableItemTriggerRule
} from "../lib/mentionable-item-trigger";
import { linkSeenMentionableItems } from "../lib/mentionable-items-preview-styling"
import { linkSeenHashtags } from "discourse/lib/link-hashtags";
import { linkSeenMentions } from "discourse/lib/link-mentions";
//Changes for Stable
//import { loadOneboxes } from "discourse/lib/load-oneboxes";
import { ajax } from "discourse/lib/ajax";
import loadScript from "discourse/lib/load-script";
//Changes for Stable
//import { resolveCachedShortUrls } from "pretty-text/upload-short-url";
import { set } from "@ember/object";
import { later, next, schedule, scheduleOnce } from "@ember/runloop";
import { isTesting } from "discourse-common/config/environment";
import {
  caretPosition,
  clipboardHelpers,
  determinePostReplaceSelection,
  inCodeBlock,
  safariHacksDisabled,
} from "discourse/lib/utilities";

export default {
  name: "mentionable-items-edits",
  initialize(container) {
    const currentUser = container.lookup("current-user:main");
    const siteSettings = container.lookup("site-settings:main");

    if (!siteSettings.mentionable_items_enabled) return;

    const length = Discourse.Site.current().mentionable_items.length;
    const obj = Ember.Object.create(Discourse.Site.current().mentionable_items);

    set(obj, "length", length);

    Discourse.Site.current().set("mentionable_items", obj);

    withPluginApi("0.8.13", (api) => {
      api.modifyClass("component:d-editor", {
        didInsertElement() {
          this._super(...arguments);

          const $editorInput = $(this.element.querySelector(".d-editor-input"));

          this._applyEmojiAutocomplete($editorInput);
          this._applyCategoryHashtagAutocomplete($editorInput);

          this._applyMentionablItemsAutocomplete($editorInput);

          scheduleOnce("afterRender", this, this._readyNow);

          const mouseTrap = Mousetrap(
            this.element.querySelector(".d-editor-input")
          );
          const shortcuts = this.get("toolbar.shortcuts");

          Object.keys(shortcuts).forEach((sc) => {
            const button = shortcuts[sc];
            mouseTrap.bind(sc, () => {
              button.action(button);
              return false;
            });
          });

          // disable clicking on links in the preview
          $(this.element.querySelector(".d-editor-preview")).on(
            "click.preview",
            (e) => {
              if (wantsNewWindow(e)) {
                return;
              }
              const $target = $(e.target);
              if ($target.is("a.mention")) {
                this.appEvents.trigger(
                  "click.discourse-preview-user-card-mention",
                  $target
                );
              }
              if ($target.is("a.mention-group")) {
                this.appEvents.trigger(
                  "click.discourse-preview-group-card-mention-group",
                  $target
                );
              }
              if ($target.is("a")) {
                e.preventDefault();
                return false;
              }
            }
          );

          if (this.composerEvents) {
            this.appEvents.on("composer:insert-block", this, "_insertBlock");
            this.appEvents.on("composer:insert-text", this, "_insertText");
            this.appEvents.on("composer:replace-text", this, "_replaceText");
          }
          this._mouseTrap = mouseTrap;

          if (isTesting()) {
            this.element.addEventListener("paste", this.paste.bind(this));
          }
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
          if (this._state !== "inDOM") {
            return;
          }

          const value = this.value;

          this.cachedCookAsync(value).then((cooked) => {
            if (this.isDestroyed) {
              return;
            }
            if (this.preview === cooked) {
              return;
            }

            this.set("preview", cooked);

            const cookedElement = document.createElement("div");
            cookedElement.innerHTML = cooked;
            //Changes for Stable
            // linkSeenHashtags($(cookedElement));
            linkSeenMentionableItems($(cookedElement));
            //Changes for Stable
            // linkSeenMentions($(cookedElement), this.siteSettings);
            // resolveCachedShortUrls(this.siteSettings, cookedElement);
            // loadOneboxes(
            //   cookedElement,
            //   ajax,
            //   null,
            //   null,
            //   this.siteSettings.max_oneboxes_per_post,
            //   false,
            //   true
            // );

            loadScript("/javascripts/diffhtml.min.js").then(() => {
              window.diff.innerHTML(
                this.element.querySelector(".d-editor-preview"),
                cookedElement.innerHTML,
                {
                  parser: {
                    rawElements: ["script", "noscript", "style", "template"],
                  },
                }
              );
            });

            schedule("afterRender", () => {
              if (this._state !== "inDOM") {
                return;
              }
              const $preview = $(
                this.element.querySelector(".d-editor-preview")
              );
              if ($preview.length === 0) {
                return;
              }

              if (this.previewUpdated) {
                this.previewUpdated($preview);
              }
            });
          });
        },
      });
    });
  },
};

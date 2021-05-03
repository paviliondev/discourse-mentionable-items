import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";
import { bind } from "@ember/runloop";

export default Component.extend({
  classNames: ['mentionables-log-message'],
  showDetails: false,

  didInsertElement() {
    $(document).on("click", bind(this, this.documentClick));
  },

  willDestroyElement() {
    $(document).off("click", bind(this, this.documentClick));
  },

  documentClick(e) {
    if (this._state === "destroying") {
      return;
    }

    if (!$(e.target).closest(this.element).length) {
      this.set("showDetails", false);
    }
  },

  @discourseComputed('log.type')
  messageTitle(type) {
    return I18n.t(`mentionable_items.${type}.title`);
  },

  @discourseComputed('log.message')
  reportDetails(message) {
    return Object.keys(message).map(key => {
      let opts = {};

      if (/\_items/.test(key)) {
        opts.items = message[key].join(', ');
      } else {
        opts.count = message[key];
      }

      return I18n.t(`mentionable_items.report.${key}`, opts);
    });
  },

  actions: {
    toggleDetails() {
      this.toggleProperty('showDetails');
    }
  }
});
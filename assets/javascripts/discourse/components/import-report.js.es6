import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";
import { bind } from "@ember/runloop";

export default Component.extend({
  classNames: ['import-report'],
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

    if (!$(e.target).closest(".import-report").length) {
      this.set("showDetails", false);
    }
  },

  @discourseComputed('report')
  reportDetails(report) {
    return Object.keys(report).map(key => {
      let opts = {};

      if (/\_items/.test(key)) {
        opts.items = report[key].join(', ');
      } else {
        opts.count = report[key];
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
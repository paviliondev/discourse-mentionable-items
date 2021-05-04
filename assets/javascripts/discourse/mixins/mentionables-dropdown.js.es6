import Mixin from "@ember/object/mixin";
import { bind } from "@ember/runloop";

export default Mixin.create({
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

  actions: {
    toggleDetails() {
      this.toggleProperty('showDetails');
    }
  }
});
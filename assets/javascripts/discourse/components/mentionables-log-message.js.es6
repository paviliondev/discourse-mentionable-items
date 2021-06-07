import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";
import Dropdown from "../mixins/mentionables-dropdown";
import I18n from "I18n";

const typesWithDescriptions = ["destroy_all"];

export default Component.extend(Dropdown, {
  classNames: ["mentionables-log-message", "mentionables-dropdown"],
  showDetails: false,

  @discourseComputed("log.type")
  messageTitle(type) {
    return I18n.t(`mentionables.log.${type}.title`);
  },

  @discourseComputed("log.type", "log.message")
  messageDetails(type, message) {
    if (type === "report") {
      return this.reportDetails(message);
    }
    if (typesWithDescriptions.includes(type)) {
      return I18n.t(`mentionables.log.${type}.description`);
    }
    return message;
  },

  reportDetails(message) {
    return Object.keys(message).map((key) => {
      let opts = {};

      if (/\_items/.test(key)) {
        opts.items = message[key].join(", ");
      } else {
        opts.count = message[key];
      }

      return I18n.t(`mentionables.log.report.${key}`, opts);
    });
  },
});

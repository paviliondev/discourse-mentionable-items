import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import EmberObject from "@ember/object";
import { equal } from "@ember/object/computed";

const MentionablesLog = EmberObject.extend({
  isReport: equal("type", "report"),
});

MentionablesLog.reopenClass({
  list(params = {}) {
    return ajax("/admin/plugins/mentionables", {
      data: params,
    }).catch(popupAjaxError);
  },
});

export default MentionablesLog;

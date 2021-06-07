import MentionablesLog from "../models/mentionables-log";
import DiscourseRoute from "discourse/routes/discourse";
import { A } from "@ember/array";

export default DiscourseRoute.extend({
  model() {
    return MentionablesLog.list();
  },

  setupController(controller, model) {
    const logs = A(model.logs.map((log) => MentionablesLog.create(log)));
    const info = model.info;

    controller.setProperties({
      logs,
      info,
    });
  },
});

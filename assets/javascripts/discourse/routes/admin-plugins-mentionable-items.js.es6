import MentionableItemLog from "../models/mentionable-item-log";
import DiscourseRoute from "discourse/routes/discourse";
import { A } from "@ember/array";

export default DiscourseRoute.extend({
  model() {
    return MentionableItemLog.list();
  },

  setupController(controller, model) {
    const logs = A(model.logs.map(log => MentionableItemLog.create(log)));
    const info = model.info;

    controller.setProperties({
      logs,
      info
    });
  }
})
import MentionableItemLog from "../models/mentionable-item-log";
import DiscourseRoute from "discourse/routes/discourse";
import { A } from "@ember/array";

export default DiscourseRoute.extend({
  model() {
    return MentionableItemLog.list();
  },

  setupController(controller, model) {
    controller.set('logs', A(model.map(log => MentionableItemLog.create(log))));
  }
})
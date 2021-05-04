import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";
import Dropdown from "../mixins/mentionables-dropdown";

export default Component.extend(Dropdown, {
  classNames: ['mentionables-info', 'mentionables-dropdown']
});
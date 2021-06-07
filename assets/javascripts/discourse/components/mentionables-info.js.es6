import Component from "@ember/component";
import Dropdown from "../mixins/mentionables-dropdown";

export default Component.extend(Dropdown, {
  classNames: ['mentionables-info', 'mentionables-dropdown']
});

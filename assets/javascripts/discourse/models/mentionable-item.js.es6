import discourseComputed, { on } from "discourse-common/utils/decorators";
import RestModel from "discourse/models/rest";
import Site from "discourse/models/site";
import { get } from "@ember/object";
import { getOwner } from "discourse-common/lib/get-owner";
import getURL from "discourse-common/lib/get-url";

const MentionableItem = RestModel.extend({
  // @on("init")

  @discourseComputed("id")
  searchContext(id) {
    return { type: "mentionable_item", id, mentionable_item: this };
  },
});

MentionableItem.reopenClass({
  nameFor(mentionable_item, separator = "/", depth = 3) {
    if (!mentionable_item) {
      return "";
    }

    let result = "";

    
    const id = get(mentionable_item, "id"),
      name = get(mentionable_item, "name");

    return !name || name.trim().length === 0
      ? `${result}${id}-mentionable_item`
      : result + name;
  },

  list() {
    return Site.currentProp("mentionable_items");
  },

  _idMap() {
    return Site.currentProp("mentionable_items");
  },

  findById(id) {
    if (!id) {
      return;
    }
    return MentionableItem._idMap()[id];
  },

  findByIds(ids = []) {
    const mentionable_items = [];
    ids.forEach((id) => {
      const found = MentionableItem.findById(id);
      if (found) {
        mentionable_items.push(found);
      }
    });
    return mentionable_items;
  },

  search(term, opts) {
    
    let limit = 5;

    if (opts) {
      if (opts.limit === 0) {
        return [];
      } else if (opts.limit) {
        limit = opts.limit;
      }
    }

    const emptyTerm = term === "";
    let nameTerm = term;

    if (!emptyTerm) {
      term = term.toLowerCase();
      term = term.replace(/-/g, " ");
    }

    const mentionable_items = MentionableItem.list();
    const length = mentionable_items.length;
    let i;
    let data = [];

    const done = () => {
      return data.length === limit;
    };

    for (i = 0; i < length && !done(); i++) {
      const mentionable_item = mentionable_items[i];

      if (
        !emptyTerm &&
        mentionable_item.name.toLowerCase().indexOf(term) === 0
      ) {
        data.push(mentionable_item);
      }
    }
    return data.sortBy("url");
  },
});

export default MentionableItem;

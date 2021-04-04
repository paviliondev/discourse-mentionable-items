import { cancel, later } from "@ember/runloop";
import { CANCELLED_STATUS } from "discourse/lib/autocomplete";
import MentionableItem from "../models/mentionable-item";
import { Promise } from "rsvp";
import { SEPARATOR } from "../lib/mentionable-item-trigger";
import { TAG_HASHTAG_POSTFIX } from "discourse/lib/tag-hashtags";
import discourseDebounce from "discourse-common/lib/debounce";
import getURL from "discourse-common/lib/get-url";
import { isTesting } from "discourse-common/config/environment";

let cache = {};
let cacheTime;
let oldSearch;

function updateCache(term, results) {
  cache[term] = results;
  cacheTime = new Date();
  return results;
}

export function searchMentionableItem(term, siteSettings) {
  if (oldSearch) {
    oldSearch.abort();
    oldSearch = null;
  }

  if (new Date() - cacheTime > 30000) {
    cache = {};
  }
  const cached = cache[term];
  if (cached) {
    return cached;
  }

  const limit = 5;
  let mentionable_items = MentionableItem.search(term, { limit });
  let numOfMentionableItems = mentionable_items.length;
  
  mentionable_items = mentionable_items.map((mentionable_item) => {
    return {
      model: mentionable_item,
      text: MentionableItem.nameFor(mentionable_item, SEPARATOR, 2),
    };
  });

  return updateCache(term, mentionable_items);
}

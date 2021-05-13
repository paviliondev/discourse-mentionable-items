import MentionableItem from "../models/mentionable-item";
import { SEPARATOR } from "../lib/discourse-markdown/mentionable-items";

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

  const limit = siteSettings.mentionable_items_autocomplete_limit;
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

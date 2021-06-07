import MentionableItem from "../models/mentionable-item";

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

  const limit = siteSettings.mentionables_autocomplete_limit;
  let mentionable_items = MentionableItem.search(term, { limit });

  mentionable_items = mentionable_items.map((item) => {
    return {
      model: item,
      text: MentionableItem.nameFor(item),
    };
  });

  return updateCache(term, mentionable_items);
}

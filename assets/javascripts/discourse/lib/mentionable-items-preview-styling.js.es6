import { searchMentionableItem } from "../lib/mentionable-item-search";

function replaceSpan($elem, item_data) {
  $elem.replaceWith(
    `<a href="${item_data.model.url}" class="mentionable-item" target="_blank"><span>${item_data.model.name}</span></a>`
  );
}

export function linkSeenMentionableItems(elem, siteSettings) {
  const mentionableItems = elem.querySelectorAll("span.mentionable-item");

  if (!mentionableItems || !mentionableItems.length === 0) {
    return [];
  }

  const items = [...mentionableItems].map((mentionableitem) => {
    return mentionableitem.innerText.substr(1)});

  mentionableItems.forEach((_, index, mentionableitem) => {
    let item = items[index];
    let item_data = searchMentionableItem(item, siteSettings)[0];

    if (!item_data || !item_data.model) {
      return;
    }

    if (item_data.model.slug === item) {
      replaceSpan($(mentionableitem), item_data);
    }
  });
}

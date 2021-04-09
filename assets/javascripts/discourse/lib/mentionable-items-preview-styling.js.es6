import { searchMentionableItem } from "../lib/mentionable-item-search";

function replaceSpan($elem, item_data) {
  $elem.replaceWith(
    `<a href="${item_data.model.url}" class="mentionable-item"><span>${item_data.model.name}</span></a>`
  );
}

export function linkSeenMentionableItems($elem) {

  const $mentionableitems = $elem.find("span.mentionable-item");
  if ($mentionableitems.length === 0) {
    return [];
  }

  const items = [
    ...$mentionableitems.map((_, mentionableitem) =>
      mentionableitem.innerText.substr(1)
    ),
  ];

  $mentionableitems.each((index, mentionableitem) => {
    let item = items[index];

    const lowerItem = item.toLowerCase();

    let item_data = searchMentionableItem(item)[0];

    replaceSpan($(mentionableitem), item_data);
  });
}

import { registerOption } from "pretty-text/pretty-text";

export const SEPARATOR = "+";

registerOption((siteSettings, opts) => {
  opts.features["mentionable-items"] = !!siteSettings.mentionable_items_enabled;
});

function setupMarkdownIt(helper) {
  helper.registerOptions((opts, siteSettings) => {
    opts.features[
      "mentionable-items"
    ] = !!siteSettings.mentionable_items_enabled;
  });

  helper.registerPlugin((md) => {
    const rule = {
      matcher: mentionableItemRegex(),
      onMatch: addMentionableItem,
    };

    md.core.textPostProcess.ruler.push("mentionable-items", rule);
  });
}

export function setup(helper) {
  helper.allowList(["span.mentionable-item", "div.mentionable-item"]);

  if (helper.markdownIt) {
    setupMarkdownIt(helper);
  } else {
    helper.addPreProcessor(replaceMentionableItems);
  }
}

function addMentionableItem(buffer, matches, state) {
  let item = matches[2];
  let tag = "span";
  let className = "mentionable-item";

  let token = new state.Token("mention_open", tag, 1);
  token.attrs = [["class", className]];

  buffer.push(token);

  token = new state.Token("text", "", 0);
  token.content = SEPARATOR + item;

  buffer.push(token);

  token = new state.Token("mention_close", tag, -1);
  buffer.push(token);
}

function mentionableItemRegex() {
  return /(\+)([a-zA-Z][\w.-]{0,200}[^\W_])|(\+)([a-zA-Z]\w)/;
}

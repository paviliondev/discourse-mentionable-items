import {
  caretPosition,
  caretRowCol,
  inCodeBlock,
} from "discourse/lib/utilities";

export function mentionableItemTriggerRule(textarea, opts) {
  const result = caretRowCol(textarea);
  const row = result.rowNum;
  let col = result.colNum;
  let line = textarea.value.split("\n")[row - 1];

  if (inCodeBlock(textarea.value, caretPosition(textarea))) {
    return false;
  }

  return true;
}

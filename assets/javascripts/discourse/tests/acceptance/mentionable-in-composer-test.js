import { click, fillIn, visit } from "@ember/test-helpers";
import { toggleCheckDraftPopup } from "discourse/controllers/composer";
import { cloneJSON } from "discourse-common/lib/object";
import {
  acceptance,
  exists,
  query,
} from "discourse/tests/helpers/qunit-helpers";
import { test } from "qunit";
import mentionableFixtures from "../fixtures/mentionable-fixtures";

acceptance("Composer", function (needs) {
  needs.user({
    id: 5,
    username: "kris",
    whisperer: true,
  });
  needs.settings({
    general_category_id: 1,
    default_composer_category: 1,
  });
  needs.site({
    categories: [
      {
        id: 1,
        name: "General",
        slug: "general",
        permission: 1,
        topic_template: null,
      },
    ],
  });
  needs.site(cloneJSON(mentionableFixtures["mentionable_items.json"]));
  needs.hooks.afterEach(() => toggleCheckDraftPopup(false));

  test("composer controls", async function (assert) {
    await visit("/");
    assert.ok(exists("#create-topic"), "the create button is visible");
    await click("#create-topic");
    assert.ok(exists(".d-editor-input"), "the composer input is visible");
    assert.ok(exists(".d-editor-preview:visible"), "shows the preview");
    await fillIn("#reply-title", "this is my new topic title");
    assert.ok(
      exists(".title-input .popup-tip.good.hide"),
      "the title is now good"
    );
    await fillIn(
      ".d-editor-input",
      "this is the *content* of a post with a mentionable item +the-stuff-of-dreams"
    );
    assert.strictEqual(
      query(".d-editor-preview").innerHTML.trim(),
      '<p>this is the <em>content</em> of a post with a mentionable item <a href="https://amazing.com/stuff-of-dreams-book" class="mentionable-item" target="_blank" tabindex="-1"><span>The Stuff of Dreams</span></a></p>',
      "it previews content"
    );
  });
});

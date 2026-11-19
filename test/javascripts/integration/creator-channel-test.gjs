import { click, render } from "@ember/test-helpers";
import { module, test } from "qunit";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import CreatorChannel from "discourse/plugins/discourse-creator-channels/discourse/connectors/group-edit/creator-channel";

module("Integration | Component | CreatorChannel", function (hooks) {
  setupRenderingTest(hooks);

  test("staff can mark and unmark a channel in the group save payload", async function (assert) {
    this.currentUser.set("admin", true);
    const group = this.owner.lookup("service:store").createRecord("group", {
      id: 42,
      name: "creators",
      is_channel: true,
    });
    await render(
      <template><CreatorChannel @outletArgs={{hash group=group}} /></template>
    );
    assert
      .dom(".creator-channel-field__checkbox")
      .isChecked("loads the existing marker");
    await click(".creator-channel-field__checkbox");
    assert.false(
      group.asJSON().custom_fields.is_channel,
      "saves an explicit false to clear the marker"
    );
    await click(".creator-channel-field__checkbox");
    assert.true(
      group.asJSON().custom_fields.is_channel,
      "saves the enabled marker"
    );
  });

  test("non-staff owners cannot see the checkbox", async function (assert) {
    this.currentUser.setProperties({ admin: false, moderator: false });
    const group = { automatic: false, is_group_owner: true };
    await render(
      <template><CreatorChannel @outletArgs={{hash group=group}} /></template>
    );
    assert
      .dom(".creator-channel-field")
      .doesNotExist("hidden from non-staff owners");
  });

  test("automatic groups cannot be marked as channels", async function (assert) {
    this.currentUser.set("admin", true);
    const group = { automatic: true };
    await render(
      <template><CreatorChannel @outletArgs={{hash group=group}} /></template>
    );
    assert
      .dom(".creator-channel-field")
      .doesNotExist("hidden for automatic groups");
  });
});

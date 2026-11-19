import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "creator-channel-group",
  initialize() {
    withPluginApi((api) => {
      api.addModelField("group", "is_channel", { defaultValue: false });
      api.addModelSaveProperty("group", "custom_fields", function () {
        return { ...this.custom_fields, is_channel: this.is_channel };
      });
    });
  },
};

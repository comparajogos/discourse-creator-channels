# frozen_string_literal: true

RSpec.describe GroupsController do
  fab!(:owner, :user)
  fab!(:admin)
  fab!(:group) { Fabricate(:group, name: "creator_team") }

  describe "#show" do
    it "exposes true for channels and false for ordinary groups" do
      get "/groups/#{group.name}.json"
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.dig("group", "is_channel")).to eq(false)

      group.custom_fields["is_channel"] = true
      group.save_custom_fields

      get "/groups/#{group.name}.json"
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.dig("group", "is_channel")).to eq(true)
    end
  end

  describe "#index" do
    it "includes channel status on the group directory" do
      group.custom_fields["is_channel"] = true
      group.save_custom_fields

      get "/groups.json"

      expect(response).to have_http_status(:ok)
      data = response.parsed_body.fetch("groups").find { |entry| entry["id"] == group.id }
      expect(data.fetch("is_channel")).to eq(true)
    end
  end

  describe "#update" do
    it "lets an administrator set and clear the marker" do
      sign_in(admin)

      [true, false].each do |value|
        put "/groups/#{group.id}.json", params: { group: { custom_fields: { is_channel: value } } }
        expect(response).to have_http_status(:ok)
        expect(group.reload.custom_fields["is_channel"]).to eq(value)
      end
    end

    it "keeps the channel marker unchanged when a non-staff owner submits it" do
      group.add_owner(owner)
      group.custom_fields["is_channel"] = true
      group.save_custom_fields
      sign_in(owner)

      put "/groups/#{group.id}.json", params: { group: { custom_fields: { is_channel: false } } }

      expect(response).to have_http_status(:ok)
      expect(group.reload.custom_fields["is_channel"]).to eq(true)
    end
  end
end

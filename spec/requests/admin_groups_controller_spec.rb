# frozen_string_literal: true

RSpec.describe Admin::GroupsController do
  fab!(:admin)
  fab!(:owner, :user)

  describe "#create" do
    it "persists the channel marker through the group API" do
      api_key = Fabricate(:api_key, user: admin)

      post "/admin/groups.json",
           headers: {
             "Api-Key" => api_key.key,
             "Api-Username" => admin.username,
           },
           params: {
             group: {
               name: "creator_team",
               owner_usernames: owner.username,
               custom_fields: {
                 is_channel: true,
               },
             },
           }

      expect(response).to have_http_status(:ok)
      data = response.parsed_body.fetch("basic_group")
      expect(data["is_channel"]).to eq(true)
      group = Group.find(data.fetch("id"))
      expect(group.custom_fields["is_channel"]).to eq(true)
      expect(group.group_users.find_by!(user: owner).owner).to eq(true)
    end
  end
end

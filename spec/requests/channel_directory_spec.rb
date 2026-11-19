# frozen_string_literal: true

RSpec.describe "Channel directory" do
  fab!(:ordinary_group, :group)
  fab!(:channel) { Fabricate(:group, name: "table_stories", full_name: "Table Stories") }
  fab!(:hidden_channel) { Fabricate(:group, visibility_level: Group.visibility_levels[:staff]) }

  before do
    SiteSetting.enable_group_directory = true
    [channel, hidden_channel].each do |group|
      group.custom_fields["is_channel"] = true
      group.save_custom_fields
    end
  end

  it "filters visible channels and keeps the existing search" do
    get "/groups.json", params: { is_channel: true }
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["groups"].pluck("id")).to eq([channel.id])
    expect(response.parsed_body["total_rows_groups"]).to eq(1)

    get "/groups.json", params: { is_channel: true, filter: "table" }
    expect(response.parsed_body["groups"].pluck("id")).to eq([channel.id])

    get "/groups.json", params: { is_channel: true, filter: ordinary_group.name }
    expect(response.parsed_body["groups"]).to eq([])

    get "/groups.json", params: { is_channel: false }
    expect(response.parsed_body["groups"].pluck("id")).to include(ordinary_group.id, channel.id)
  end

  it "filters before pagination and preserves the filter on the next page" do
    15.times do |index|
      group = Fabricate(:group, name: "channel_#{index}")
      group.custom_fields["is_channel"] = true
      group.save_custom_fields
    end
    headers = {
      "User-Agent" =>
        "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 Mobile/15E148",
    }
    get "/groups.json", params: { is_channel: true, order: "name", asc: true }, headers: headers
    expect(response).to have_http_status(:ok)
    first_page = response.parsed_body
    expect(first_page["total_rows_groups"]).to eq(16)
    expect(first_page["groups"].length).to eq(15)
    expect(first_page["groups"].all? { |group| group["is_channel"] }).to eq(true)

    get first_page["load_more_groups"], headers: headers, xhr: true
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["groups"].length).to eq(1)
    expect(response.parsed_body["groups"].first["is_channel"]).to eq(true)
    expect(response.parsed_body["total_rows_groups"]).to eq(16)
  end
end

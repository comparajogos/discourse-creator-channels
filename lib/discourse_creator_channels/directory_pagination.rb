# frozen_string_literal: true

module DiscourseCreatorChannels
  module DirectoryPagination
    extend ActiveSupport::Concern

    included { after_action :preserve_channel_directory_filter, only: :index }

    private

    def preserve_channel_directory_filter
      return unless params[:is_channel].to_s == "true" && response.successful?
      return unless response.media_type == "application/json"

      data = JSON.parse(response.body)
      if (url = data["load_more_groups"])
        separator = url.include?("?") ? "&" : "?"
        data["load_more_groups"] = "#{url}#{separator}is_channel=true"
        response.body = data.to_json
      end
    end
  end
end

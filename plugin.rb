# frozen_string_literal: true

# name: discourse-creator-channels
# about: Mark existing Discourse groups as creator channels.
# version: 0.2.0
# authors: Compara Jogos
# url: https://github.com/comparajogos/discourse-creator-channels

module ::DiscourseCreatorChannels
  GROUP_FIELD = "is_channel"
end

after_initialize do
  require_relative "lib/discourse_creator_channels/directory_pagination"

  register_modifier(:groups_index_query) do |groups, context|
    if context.respond_to?(:params) && context.params[:is_channel].to_s == "true"
      groups.where(
        id:
          GroupCustomField.where(name: DiscourseCreatorChannels::GROUP_FIELD, value: "t").select(
            :group_id,
          ),
      )
    else
      groups
    end
  end

  reloadable_patch { GroupsController.include(DiscourseCreatorChannels::DirectoryPagination) }

  register_group_custom_field_type(DiscourseCreatorChannels::GROUP_FIELD, :boolean)
  register_editable_group_custom_field(DiscourseCreatorChannels::GROUP_FIELD.to_sym)
  add_preloaded_group_custom_field(DiscourseCreatorChannels::GROUP_FIELD)

  add_to_serializer(:basic_group, :is_channel) do
    object.custom_fields[DiscourseCreatorChannels::GROUP_FIELD] == true
  end
end

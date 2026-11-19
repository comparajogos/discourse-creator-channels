# frozen_string_literal: true

# name: discourse-creator-channels
# about: Mark existing Discourse groups as creator channels.
# version: 0.1.0
# authors: Compara Jogos
# url: https://github.com/comparajogos/discourse-creator-channels

module ::DiscourseCreatorChannels
  GROUP_FIELD = "is_channel"
end

after_initialize do
  register_group_custom_field_type(DiscourseCreatorChannels::GROUP_FIELD, :boolean)
  register_editable_group_custom_field(DiscourseCreatorChannels::GROUP_FIELD.to_sym)
  add_preloaded_group_custom_field(DiscourseCreatorChannels::GROUP_FIELD)

  add_to_serializer(:basic_group, :is_channel) do
    object.custom_fields[DiscourseCreatorChannels::GROUP_FIELD] == true
  end
end

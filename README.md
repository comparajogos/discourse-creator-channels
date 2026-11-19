# Discourse Creator Channels

A minimal plugin that marks existing Discourse groups as content-creator channels.
The group represents the creator's team; its existing group page is the channel page.

## What it does

- Registers `is_channel` as a boolean group custom field.
- Allows the field through Discourse's normal group creation and update APIs.
- Adds an `is_channel` boolean to basic group JSON, including group pages and the
  group directory. Groups without the marker return `false`.
- Preloads the field when Discourse preloads group custom fields.

There are no migrations, new routes, settings, or frontend controls. The plugin
uses existing group permissions. On the tested Discourse version, registered
custom fields can be updated by staff with group-edit permission; a non-staff
group owner cannot change the marker. The plugin does not override core access
controls.

## Installation

Add the plugin to your Discourse container's plugin clone list and rebuild:

```yaml
- git clone https://github.com/comparajogos/discourse-creator-channels.git
```

For a development checkout, clone into `plugins/discourse-creator-channels` and
restart the Rails server.

## API and Workflows

Include the marker in `POST /admin/groups.json` or `PUT /groups/:id.json`:

```json
{
  "group": {
    "name": "example-team",
    "full_name": "Example Team",
    "owner_usernames": "example_creator",
    "custom_fields": { "is_channel": true }
  }
}
```

The creating API user must have permission to create groups. In Workflows, an HTTP
Request node can supply this payload using a Header Auth credential named
`Api-Key` and the matching `Api-Username` header. Derive `owner_usernames` from the
logged-in submitter, rather than an editable form field.

After creation, the response includes `basic_group.is_channel`. The group show
response includes `group.is_channel`; use it in a theme to identify channel groups.
Send `false` to clear the marker.

## Scope

This skeleton supplies the marker and API integration only. Channel presentation,
content attribution, profile links, and a management toggle can build on it later.
Followers, audience membership, payments, and category provisioning are outside
this plugin's current scope. No Workflows core changes are required.

## Tests

From a Discourse checkout with this plugin installed:

```sh
LOAD_PLUGINS=1 bin/rspec plugins/discourse-creator-channels/spec
bin/lint --fix plugins/discourse-creator-channels/plugin.rb plugins/discourse-creator-channels/spec
```

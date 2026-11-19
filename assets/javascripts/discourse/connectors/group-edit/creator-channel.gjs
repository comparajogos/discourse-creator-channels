import Component from "@glimmer/component";
import { Input } from "@ember/component";
import { service } from "@ember/service";
import { i18n } from "discourse-i18n";

export default class CreatorChannel extends Component {
  @service currentUser;

  get canEdit() {
    return this.currentUser?.staff && !this.args.outletArgs.group.automatic;
  }

  <template>
    {{#if this.canEdit}}
      <div class="control-group creator-channel-field">
        <label>
          <Input
            class="creator-channel-field__checkbox"
            @checked={{@outletArgs.group.is_channel}}
            @type="checkbox"
          />
          {{i18n "creator_channels.group.label"}}
        </label>
        <p class="description">{{i18n "creator_channels.group.description"}}</p>
      </div>
    {{/if}}
  </template>
}

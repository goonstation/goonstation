import { useBackend } from "../../backend";
import {
  Button,
  LabeledList,
} from '../../components';


export const POWER_CHANNEL_EQUIPMENT = 1;
export const POWER_CHANNEL_LIGHTING = 2;
export const POWER_CHANNEL_ENVIRONMENTAL = 3;

export const POWER_CHANNEL_STATUS_OFF = 0;
export const POWER_CHANNEL_STATUS_AUTO_OFF = 1;
export const POWER_CHANNEL_STATUS_ON = 2;
export const POWER_CHANNEL_STATUS_AUTO_ON = 3;


export const PowerChannelSection = (props, context) => {
  const {
    powerChannel,
  } = props;
  const { act, data } = useBackend(context);
  const {
    locked,
    is_ai,
    is_silicon,
    can_access_remotely,
    aidisabled,
    equipment,
    lighting,
    environ,
    lastused_equip,
    lastused_light,
    lastused_environ,
  } = data;


  const powerChannelToLabel = () => {
    switch (powerChannel) {
      case POWER_CHANNEL_EQUIPMENT:
        return "Equipment";
      case POWER_CHANNEL_LIGHTING:
        return "Lighting";
      case POWER_CHANNEL_ENVIRONMENTAL:
        return "Environmental";
      default:
        return "Unknown";
    }
  };

  const getPowerChannelStatus = () => {
    switch (powerChannel) {
      case POWER_CHANNEL_EQUIPMENT:
        return equipment;
      case POWER_CHANNEL_LIGHTING:
        return lighting;
      case POWER_CHANNEL_ENVIRONMENTAL:
        return environ;
    }
  };

  const powerChannelWatts = () => {
    switch (powerChannel) {
      case POWER_CHANNEL_EQUIPMENT:
        return lastused_equip;
      case POWER_CHANNEL_LIGHTING:
        return lastused_light;
      case POWER_CHANNEL_ENVIRONMENTAL:
        return lastused_environ;
      default:
        return 0;
    }
  };

  const powerChannelLabel = powerChannelToLabel(powerChannel);

  // ------------ Events ------------
  const onPowerChannelStatusChange = (status) => {
    switch (powerChannel) {
      case POWER_CHANNEL_EQUIPMENT:
        act("onPowerChannelEquipmentStatusChange", { status });
        break;
      case POWER_CHANNEL_LIGHTING:
        act("onPowerChannelLightingStatusChange", { status });
        break;
      case POWER_CHANNEL_ENVIRONMENTAL:
        act("onPowerChannelEnvironStatusChange", { status });
        break;
      default:
        return;
    }
  };
  // ------------ End Events ------------

  const hasPermission = () => {
    if (is_ai || is_silicon || can_access_remotely) {
      return !aidisabled;
    }
    return !locked;
  };

  const isCurrentStatus = (status) => {
    return status === getPowerChannelStatus();
  };

  return (
    <LabeledList.Item label={powerChannelLabel} direction="row">
      <LabeledList>
        <LabeledList.Item label={powerChannelWatts() + " W"} direction="row" disabled={!hasPermission()}>
          <Button content="Off"
            disabled={!hasPermission() && !isCurrentStatus(POWER_CHANNEL_STATUS_OFF)}
            onClick={() => { onPowerChannelStatusChange(POWER_CHANNEL_STATUS_OFF); }}
            selected={isCurrentStatus(POWER_CHANNEL_STATUS_OFF)}
            align="center"
          />
          <Button content="On"
            disabled={!hasPermission() && !isCurrentStatus(POWER_CHANNEL_STATUS_ON)}
            onClick={() => { onPowerChannelStatusChange(POWER_CHANNEL_STATUS_ON); }}
            selected={isCurrentStatus(POWER_CHANNEL_STATUS_ON)}
          />
          <Button content="Auto"
            disabled={!hasPermission() && !(
              isCurrentStatus(POWER_CHANNEL_STATUS_AUTO_OFF) || isCurrentStatus(POWER_CHANNEL_STATUS_AUTO_ON)
            )}
            onClick={() => { onPowerChannelStatusChange(POWER_CHANNEL_STATUS_AUTO_ON); }}
            selected={isCurrentStatus(POWER_CHANNEL_STATUS_AUTO_OFF) || isCurrentStatus(POWER_CHANNEL_STATUS_AUTO_ON)}
          />
        </LabeledList.Item>
      </LabeledList>
    </LabeledList.Item>
  );
};

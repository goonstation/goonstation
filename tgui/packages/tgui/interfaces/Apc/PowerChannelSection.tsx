/**
 * @file
 * @copyright 2022-2023
 * @author Original 56Kyle (https://github.com/56Kyle)
 * @author Changes Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import { Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import type { ApcData } from './types';
import { formatWatts, getHasPermission } from './util';

enum PowerChannel {
  Equipment = 1,
  Lighting = 2,
  Environmental = 3,
}

enum PowerChannelStatus {
  Off = 0,
  AutoOff = 1,
  On = 2,
  AutoOn = 3,
}

interface PowerChannelConfig {
  id: PowerChannel;
  label: string;
  getPower: (data: ApcData) => number;
  getStatus: (data: ApcData) => PowerChannelStatus;
  statusChangeAction: string;
}

const autoPowerChannelStatuses = [
  PowerChannelStatus.AutoOff,
  PowerChannelStatus.AutoOn,
];
const getPowerChannelStatusIsAuto = (powerChannelStatus: PowerChannelStatus) =>
  autoPowerChannelStatuses.includes(powerChannelStatus);

const powerChannelConfig: PowerChannelConfig[] = [
  {
    id: PowerChannel.Equipment,
    label: 'Equipment',
    getPower: ({ lastused_equip }) => lastused_equip,
    getStatus: ({ equipment }) => equipment,
    statusChangeAction: 'onPowerChannelEquipmentStatusChange',
  },
  {
    id: PowerChannel.Lighting,
    label: 'Lighting',
    getPower: ({ lastused_light }) => lastused_light,
    getStatus: ({ lighting }) => lighting,
    statusChangeAction: 'onPowerChannelLightingStatusChange',
  },
  {
    id: PowerChannel.Environmental,
    label: 'Environmental',
    getPower: ({ lastused_environ }) => lastused_environ,
    getStatus: ({ environ }) => environ,
    statusChangeAction: 'onPowerChannelEnvironStatusChange',
  },
];

const powerChannelConfigLookup = powerChannelConfig.reduce(
  (acc, cur) => ({ ...acc, [cur.id]: cur }),
  {} as Record<PowerChannel, PowerChannelConfig>,
);

interface PowerChannelItemProps {
  powerChannel: PowerChannel;
}

const PowerChannelItem = (props: PowerChannelItemProps) => {
  const { powerChannel } = props;
  const { act, data } = useBackend<ApcData>();

  const hasPermission = getHasPermission(data);
  const currPowerChannelConfig = powerChannelConfigLookup[powerChannel];
  const label = currPowerChannelConfig.label ?? 'Unknown';
  const currentStatus = currPowerChannelConfig.getStatus(data);
  const currentStatusIsAuto = getPowerChannelStatusIsAuto(currentStatus);
  const power = currPowerChannelConfig.getPower(data);
  const statusChangeAction = currPowerChannelConfig.statusChangeAction;

  // #region event handlers
  const handlePowerChannelStatusChange = (status: PowerChannelStatus) => {
    if (statusChangeAction) {
      act(statusChangeAction, { status });
    }
  };
  // #endregion

  return (
    <LabeledList.Item
      label={label}
      textAlign="right"
      buttons={
        <>
          <Button
            disabled={
              !hasPermission && currentStatus !== PowerChannelStatus.Off
            }
            onClick={() =>
              handlePowerChannelStatusChange(PowerChannelStatus.Off)
            }
            selected={currentStatus === PowerChannelStatus.Off}
          >
            Off
          </Button>
          <Button
            disabled={!hasPermission && currentStatus !== PowerChannelStatus.On}
            onClick={() =>
              handlePowerChannelStatusChange(PowerChannelStatus.On)
            }
            selected={currentStatus === PowerChannelStatus.On}
          >
            On
          </Button>
          <Button
            disabled={!hasPermission && !currentStatusIsAuto}
            onClick={() =>
              handlePowerChannelStatusChange(PowerChannelStatus.AutoOn)
            }
            selected={currentStatusIsAuto}
          >
            Auto
          </Button>
        </>
      }
    >
      {formatWatts(power)}
    </LabeledList.Item>
  );
};

export const PowerChannelSection = (_props, context) => {
  const { data } = useBackend<ApcData>();
  const { lastused_total } = data;
  return (
    <Section title="Power Channel">
      <LabeledList>
        <PowerChannelItem powerChannel={PowerChannel.Equipment} />
        <PowerChannelItem powerChannel={PowerChannel.Lighting} />
        <PowerChannelItem powerChannel={PowerChannel.Environmental} />
        <LabeledList.Item label="Total Load" textAlign="right" buttons>
          {formatWatts(lastused_total)}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

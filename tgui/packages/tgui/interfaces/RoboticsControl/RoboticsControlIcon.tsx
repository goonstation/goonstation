/**
 * @file
 * @copyright 2025
 * @author FlameArrow57 (https://github.com/FlameArrow57)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Box, Icon, Tooltip } from 'tgui-core/components';

import { Status } from './type';

interface TooltipIconProps {
  color?: string;
  icon: string;
  tooltip: string;
}

export const TooltipIcon = ({ color, icon, tooltip }: TooltipIconProps) => (
  <Tooltip position="bottom" content={tooltip}>
    <Box color={color} position="relative">
      <Icon name={icon} />
    </Box>
  </Tooltip>
);

interface CellIconProps {
  charge: [number, number] | null;
}

export const CellIcon = (props: CellIconProps) => {
  const { charge } = props;
  if (!charge) {
    return (
      <TooltipIcon
        color="bad"
        icon="triangle-exclamation"
        tooltip="No cell inserted"
      />
    );
  }
  const chargeRatio = charge[0] / charge[1];
  const tooltip = `${charge[0]} / ${charge[1]}`;
  if (chargeRatio === 0) {
    return <TooltipIcon color="bad" icon="battery-empty" tooltip={tooltip} />;
  }
  if (chargeRatio < 0.25) {
    return (
      <TooltipIcon color="average" icon="battery-quarter" tooltip={tooltip} />
    );
  }
  if (chargeRatio < 0.5) {
    return (
      <TooltipIcon color="average" icon="battery-half" tooltip={tooltip} />
    );
  }
  if (chargeRatio < 0.75) {
    return (
      <TooltipIcon
        color="good"
        icon="battery-three-quarters"
        tooltip={tooltip}
      />
    );
  }
  return <TooltipIcon color="good" icon="battery-full" tooltip={tooltip} />;
};

interface StatusIconProps {
  status: Status;
}

export const StatusIcon = ({ status }: StatusIconProps) => {
  switch (status) {
    case Status.Alive: {
      return (
        <TooltipIcon color="good" icon="wifi" tooltip="Operating normally" />
      );
    }
    case Status.Unconscious:
    case Status.Dead:
    default: {
      return (
        <TooltipIcon
          color="bad"
          icon="triangle-exclamation"
          tooltip="ERROR: Not Responding!"
        />
      );
    }
  }
};

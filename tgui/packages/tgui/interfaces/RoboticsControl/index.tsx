/**
 * @file
 * @copyright 2025
 * @author FlameArrow57 (https://github.com/FlameArrow57)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import type { BooleanLike } from 'common/react';
import {
  Box,
  Button,
  Icon,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import type {
  AIData,
  CyborgData,
  GhostdroneData,
  RoboticsControlData,
} from './type';
import { Status } from './type';

interface TooltipIconProps {
  color?: string;
  icon: string;
  tooltip: string;
}

const TooltipIcon = ({ color, icon, tooltip }: TooltipIconProps) => (
  <Tooltip position="bottom" content={tooltip}>
    <Box color={color} position="relative">
      <Icon name={icon} />
    </Box>
  </Tooltip>
);

interface CellIconProps {
  charge: [number, number] | null;
}

const CellIcon = (props: CellIconProps) => {
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

const StatusIcon = ({ status }: StatusIconProps) => {
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

export const RoboticsControl = () => {
  const { data } = useBackend<RoboticsControlData>();
  const { user_is_ai, user_is_cyborg, ais, cyborgs, ghostdrones } = data;

  return (
    <Window title="Robotics Control" width={870} height={590}>
      <Window.Content>
        <Section fill scrollable>
          <Section title="Located AI Units">
            {ais?.length ? (
              <AIStatuses
                ais={ais}
                user_is_robot={!!(user_is_ai || user_is_cyborg)}
              />
            ) : (
              'No AI units located'
            )}
          </Section>
          <Section title="Located Silicons">
            {cyborgs?.length ? (
              <SiliconStatuses
                cyborgs={cyborgs}
                user_is_ai={user_is_ai}
                user_is_cyborg={user_is_cyborg}
              />
            ) : (
              'No cyborgs located'
            )}
          </Section>
          <Section title="Ghostdrones">
            {ghostdrones?.length ? (
              <GhostdroneStatuses ghostdrones={ghostdrones} />
            ) : (
              'No ghostdrones located'
            )}
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};

interface AIStatusesProps {
  ais: AIData[];
  user_is_robot: boolean;
}

const AIStatuses = (props: AIStatusesProps) => {
  const { act } = useBackend();
  const { ais, user_is_robot } = props;

  return (
    <Table>
      <Table.Row>
        <Table.Cell header>Name</Table.Cell>
        <Table.Cell header textAlign="center">
          Status
        </Table.Cell>
        <Table.Cell header>Kill Switch</Table.Cell>
      </Table.Row>
      {ais.map((item) => (
        <Table.Row key={item.mob_ref}>
          <Table.Cell>{item.name}</Table.Cell>
          <Table.Cell textAlign="center">
            <StatusIcon status={item.status} />
          </Table.Cell>
          <Table.Cell collapsing>
            {!item.killswitch_time ? (
              <NoticeBox warning inline>
                <Button
                  disabled={user_is_robot}
                  onClick={() =>
                    act('start_ai_killswitch', { mob_ref: item.mob_ref })
                  }
                >
                  *Swipe ID*
                </Button>
              </NoticeBox>
            ) : (
              <NoticeBox danger inline>
                <Button
                  disabled={user_is_robot}
                  onClick={() =>
                    act('stop_ai_killswitch', { mob_ref: item.mob_ref })
                  }
                >
                  Cancel - {item.killswitch_time} remaining
                </Button>
              </NoticeBox>
            )}
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};

interface SiliconStatusesProps {
  cyborgs: CyborgData[];
  user_is_ai: BooleanLike;
  user_is_cyborg: BooleanLike;
}

const SiliconStatuses = (props: SiliconStatusesProps) => {
  const { act } = useBackend();
  const { cyborgs, user_is_ai, user_is_cyborg } = props;

  return (
    <Table>
      <Table.Row>
        <Table.Cell header>Name</Table.Cell>
        <Table.Cell header textAlign="center">
          Status
        </Table.Cell>
        <Table.Cell header>Module</Table.Cell>
        <Table.Cell header>Lock Switch</Table.Cell>
        <Table.Cell header>Kill Switch</Table.Cell>
      </Table.Row>
      {cyborgs.map((item) => (
        <Table.Row key={item.mob_ref}>
          <Table.Cell>{item.name}</Table.Cell>
          <Table.Cell textAlign="center">
            <Stack>
              <Stack.Item grow={1}>
                <CellIcon
                  charge={
                    item.cell_charge !== null && item.cell_maxcharge !== null
                      ? [item.cell_charge, item.cell_maxcharge]
                      : null
                  }
                />
              </Stack.Item>
              <Stack.Item grow={1}>
                {item.missing_brain ? (
                  <TooltipIcon
                    color="bad"
                    icon="triangle-exclamation"
                    tooltip="Intelligence cortex missing"
                  />
                ) : (
                  <TooltipIcon
                    color="good"
                    icon="brain"
                    tooltip="Intelligence cortex present"
                  />
                )}
              </Stack.Item>
              <Stack.Item grow={1}>
                <StatusIcon status={item.status} />
              </Stack.Item>
            </Stack>
          </Table.Cell>
          <Table.Cell>{item.module || 'None'}</Table.Cell>
          <Table.Cell>
            {!item.lock_time ? (
              <NoticeBox warning inline>
                <Button
                  disabled={!user_is_ai}
                  onClick={() =>
                    act('start_silicon_lock', { mob_ref: item.mob_ref })
                  }
                >
                  Lock
                </Button>
              </NoticeBox>
            ) : (
              <NoticeBox danger inline>
                <Button
                  onClick={() =>
                    act('stop_silicon_lock', { mob_ref: item.mob_ref })
                  }
                >
                  Cancel - {item.lock_time} remaining
                </Button>
              </NoticeBox>
            )}
          </Table.Cell>
          <Table.Cell collapsing>
            {!item.killswitch_time ? (
              <NoticeBox warning inline>
                <Button
                  disabled={user_is_cyborg || user_is_ai}
                  onClick={() =>
                    act('start_silicon_killswitch', { mob_ref: item.mob_ref })
                  }
                >
                  *Swipe ID*
                </Button>
              </NoticeBox>
            ) : (
              <NoticeBox danger inline>
                <Button
                  disabled={user_is_cyborg || user_is_ai}
                  onClick={() =>
                    act('stop_silicon_killswitch', { mob_ref: item.mob_ref })
                  }
                >
                  Cancel - {item.killswitch_time} remaining
                </Button>
              </NoticeBox>
            )}
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};

interface GhostdroneStatusesProps {
  ghostdrones: GhostdroneData[];
}

const GhostdroneStatuses = (props: GhostdroneStatusesProps) => {
  const { act } = useBackend();
  const { ghostdrones } = props;

  return (
    <Table>
      <Table.Row>
        <Table.Cell bold>Name</Table.Cell>
        <Table.Cell bold>Switch</Table.Cell>
      </Table.Row>
      {ghostdrones.map((item) => (
        <Table.Row key={item.mob_ref}>
          <Table.Cell collapsing>{item.name}</Table.Cell>
          <Table.Cell collapsing>
            <NoticeBox danger inline>
              <Button
                onClick={() =>
                  act('killswitch_ghostdrone', { mob_ref: item.mob_ref })
                }
              >
                Terminate
              </Button>
            </NoticeBox>
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};

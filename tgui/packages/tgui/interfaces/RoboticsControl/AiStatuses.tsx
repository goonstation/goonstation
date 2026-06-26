/**
 * @file
 * @copyright 2025
 * @author FlameArrow57 (https://github.com/FlameArrow57)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Button, NoticeBox, Stack, Table } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { CellIcon, StatusIcon, TooltipIcon } from './RoboticsControlIcon';
import type { AIData } from './type';

interface AIStatusesProps {
  ais: AIData[];
  user_is_robot: boolean;
  can_lockdown: boolean;
  can_killswitch: boolean;
}

export const AIStatuses = (props: AIStatusesProps) => {
  const { act } = useBackend();
  const { ais, user_is_robot, can_killswitch, can_lockdown } = props;

  return (
    <Table>
      <Table.Row>
        <Table.Cell header>Name</Table.Cell>
        <Table.Cell header textAlign="center">
          Status
        </Table.Cell>
        <Table.Cell header>Module</Table.Cell>
        {can_lockdown && <Table.Cell header>Lockdown</Table.Cell>}
        {can_killswitch && <Table.Cell header>Kill Switch</Table.Cell>}
      </Table.Row>
      {ais.map((item) => (
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
                {item.brain_status === 'missing' && (
                  <TooltipIcon
                    color="bad"
                    icon="triangle-exclamation"
                    tooltip="Intelligence cortex missing"
                  />
                )}
                {item.brain_status === 'disconnected' && (
                  <TooltipIcon
                    color="average"
                    icon="satellite-dish"
                    tooltip="Intelligence cortex disconnected"
                  />
                )}
                {item.brain_status === 'present' && (
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
          <Table.Cell>N/A</Table.Cell>
          {can_lockdown && <Table.Cell>N/A</Table.Cell>}
          {can_killswitch && (
            <Table.Cell collapsing>
              {!item.killswitch_time ? (
                <NoticeBox inline>
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
                    Cancel - {item.killswitch_time}s
                  </Button>
                </NoticeBox>
              )}
            </Table.Cell>
          )}
        </Table.Row>
      ))}
    </Table>
  );
};

/**
 * @file
 * @copyright 2025
 * @author FlameArrow57 (https://github.com/FlameArrow57)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import type { BooleanLike } from 'common/react';
import { Button, NoticeBox, Stack, Table } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { CellIcon, StatusIcon, TooltipIcon } from './RoboticsControlIcon';
import type { CyborgData } from './type';

interface SiliconStatusesProps {
  cyborgs: CyborgData[];
  user_is_ai: BooleanLike;
  user_is_cyborg: BooleanLike;
}

export const CyborgStatuses = (props: SiliconStatusesProps) => {
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

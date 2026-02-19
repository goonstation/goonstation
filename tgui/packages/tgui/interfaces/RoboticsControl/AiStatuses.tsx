/**
 * @file
 * @copyright 2025
 * @author FlameArrow57 (https://github.com/FlameArrow57)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Button, NoticeBox, Table } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { StatusIcon } from './RoboticsControlIcon';
import type { AIData } from './type';

interface AIStatusesProps {
  ais: AIData[];
  user_is_robot: boolean;
}

export const AIStatuses = (props: AIStatusesProps) => {
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

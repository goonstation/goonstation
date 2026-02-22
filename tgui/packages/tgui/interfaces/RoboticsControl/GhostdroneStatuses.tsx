/**
 * @file
 * @copyright 2025
 * @author FlameArrow57 (https://github.com/FlameArrow57)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Button, NoticeBox, Table } from 'tgui-core/components';

import { useBackend } from '../../backend';
import type { GhostdroneData } from './type';

interface GhostdroneStatusesProps {
  ghostdrones: GhostdroneData[];
}

export const GhostdroneStatuses = (props: GhostdroneStatusesProps) => {
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

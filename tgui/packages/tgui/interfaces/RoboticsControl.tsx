/**
 * @file
 * @copyright 2025
 * @author FlameArrow57 (https://github.com/FlameArrow57)
 * @license ISC
 */

import { BooleanLike } from 'common/react';
import { Button, NoticeBox, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface RoboticsControlData {
  user_is_ai: BooleanLike;
  user_is_cyborg: BooleanLike;
  ais: AIData[];
  cyborgs: CyborgData[];
  ghostdrones: GhostdroneData[];
}

interface AIData {
  name: string;
  mob_ref: string;
  status: string;
  killswitch_time: number | null;
}

interface CyborgData {
  name: string;
  mob_ref: string;
  status: string;
  cell_charge: number | null;
  cell_maxcharge: number | null;
  module: string | null;
  lock_time: number | null;
  killswitch_time: number | null;
}

interface GhostdroneData {
  name: string;
  mob_ref: string;
}

export const RoboticsControl = () => {
  const { act, data } = useBackend<RoboticsControlData>();
  const { user_is_ai, user_is_cyborg, ais, cyborgs, ghostdrones } = data;

  return (
    <Window title="Robotics Control" width={870} height={590}>
      <Window.Content>
        <Section fill scrollable>
          <Section title="Located AI Units">
            {ais.length ? (
              <AIStatuses
                ais={ais}
                user_is_robot={user_is_ai || user_is_cyborg}
              />
            ) : (
              'No AI units located'
            )}
          </Section>
          <Section title="Located Silicons">
            {cyborgs.length ? (
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
            {ghostdrones.length ? (
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
  ais;
  user_is_robot;
}

const AIStatuses = (props: AIStatusesProps) => {
  const { act } = useBackend();
  const { ais, user_is_robot } = props;

  return (
    <Table>
      <Table.Row>
        <Table.Cell bold>Name</Table.Cell>
        <Table.Cell bold>Status</Table.Cell>
        <Table.Cell bold>Kill Switch</Table.Cell>
      </Table.Row>
      {ais.map((item) => (
        <Table.Row key={item.mob_ref}>
          <Table.Cell>{item.name}</Table.Cell>
          <Table.Cell>{item.status}</Table.Cell>
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
  cyborgs;
  user_is_ai;
  user_is_cyborg;
}

const SiliconStatuses = (props: SiliconStatusesProps) => {
  const { act } = useBackend();
  const { cyborgs, user_is_ai, user_is_cyborg } = props;

  return (
    <Table>
      <Table.Row>
        <Table.Cell bold>Name</Table.Cell>
        <Table.Cell bold>Status</Table.Cell>
        <Table.Cell bold>Cell Charge</Table.Cell>
        <Table.Cell bold>Module</Table.Cell>
        <Table.Cell bold>Lock Switch</Table.Cell>
        <Table.Cell bold>Kill Switch</Table.Cell>
      </Table.Row>
      {cyborgs.map((item) => (
        <Table.Row key={item.mob_ref}>
          <Table.Cell>{item.name}</Table.Cell>
          <Table.Cell>{item.status}</Table.Cell>
          <Table.Cell>
            {item.cell_maxcharge
              ? `${item.cell_charge}/${item.cell_maxcharge}`
              : 'No Cell Installed'}
          </Table.Cell>
          <Table.Cell>
            {item.module ? `${item.module}` : 'No Module Installed'}
          </Table.Cell>
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
  ghostdrones;
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

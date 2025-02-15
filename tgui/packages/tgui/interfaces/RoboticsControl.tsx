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
  ais: AIData[];
  cyborgs: CyborgData[];
  ghostdrones: GhostdroneData[];
  user_is_ai: BooleanLike;
  user_is_cyborg: BooleanLike;
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
    <Window title="Robotics Control" width={1000} height={600}>
      <Window.Content>
        <Section
          title="Located AI Units"
          fill
          scrollable
          minHeight="200px"
          maxHeight="200px"
        >
          <AIStatuses ais={ais} user_is_robot={user_is_ai || user_is_cyborg} />
        </Section>
        <Section
          title="Located Silicons"
          fill
          scrollable
          minHeight="200px"
          maxHeight="200px"
        >
          {/*
          <SiliconStatuses
            cyborg_names={cyborg_names}
            cyborg_statuses={cyborg_statuses}
            cyborg_cell_charges={cyborg_cell_charges}
            cyborg_modules={cyborg_modules}
            cyborg_lock_times={cyborg_lock_times}
            cyborg_killswitch_times={cyborg_killswitch_times}
            user_is_ai={user_is_ai}
            user_is_cyborg={user_is_cyborg}
          />*/}
        </Section>
        <Section
          title="Ghostdrones"
          fill
          scrollable
          minHeight="140px"
          maxHeight="140px"
        >
          {/* <GhostdroneStatuses ghostdrone_names={ghostdrone_names} />*/}
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
        <Table.Cell bold>Switch</Table.Cell>
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
                  Kill switch *Swipe ID*
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
                  Cancel kill switch - {item.killswitch_time} remaining
                </Button>
              </NoticeBox>
            )}
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};
/*
const SiliconStatuses = (props) => {
  const { act } = useBackend();
  const {
    cyborg_names,
    cyborg_statuses,
    cyborg_cell_charges,
    cyborg_modules,
    cyborg_lock_times,
    cyborg_killswitch_times,
    user_is_ai,
    user_is_cyborg,
  } = props;

  return (
    <Table>
      <Table.Row>
        <Table.Cell bold>Name</Table.Cell>
        <Table.Cell bold>Status</Table.Cell>
        <Table.Cell bold>Charge</Table.Cell>
        <Table.Cell bold>Module</Table.Cell>
        <Table.Cell bold>Lock Switch</Table.Cell>
        <Table.Cell bold>Kill Switch</Table.Cell>
      </Table.Row>
      {cyborg_names.map((item, index) => (
        <Table.Row key={index}>
          <Table.Cell>{item}</Table.Cell>
          <Table.Cell>{cyborg_statuses[index]}</Table.Cell>
          <Table.Cell>{cyborg_cell_charges[index]}</Table.Cell>
          <Table.Cell>{cyborg_modules[index]}</Table.Cell>
          <Table.Cell>
            {!cyborg_lock_times[index] ? (
              <NoticeBox warning inline>
                <Button
                  disabled={!user_is_ai}
                  onClick={() =>
                    act('start_silicon_lock', { index: index + 1 })
                  }
                >
                  Lock
                </Button>
              </NoticeBox>
            ) : (
              <NoticeBox danger inline>
                <Button
                  onClick={() => act('stop_silicon_lock', { index: index + 1 })}
                >
                  Cancel unlock - {cyborg_lock_times[index]} remaining
                </Button>
              </NoticeBox>
            )}
          </Table.Cell>
          <Table.Cell collapsing>
            {!cyborg_killswitch_times[index] ? (
              <NoticeBox warning inline>
                <Button
                  disabled={user_is_cyborg || user_is_ai}
                  onClick={() =>
                    act('start_silicon_killswitch', { index: index + 1 })
                  }
                >
                  Kill switch *Swipe ID*
                </Button>
              </NoticeBox>
            ) : (
              <NoticeBox danger inline>
                <Button
                  disabled={user_is_cyborg || user_is_ai}
                  onClick={() =>
                    act('stop_silicon_killswitch', { index: index + 1 })
                  }
                >
                  Cancel kill switch - {cyborg_killswitch_times[index]}{' '}
                  remaining
                </Button>
              </NoticeBox>
            )}
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};

const GhostdroneStatuses = (props) => {
  const { act } = useBackend();
  const { ghostdrone_names } = props;

  return (
    <Table>
      <Table.Row>
        <Table.Cell bold>Name</Table.Cell>
        <Table.Cell bold>Switch</Table.Cell>
      </Table.Row>
      {ghostdrone_names.map((item, index) => (
        <Table.Row key={index}>
          <Table.Cell collapsing>{item}</Table.Cell>
          <Table.Cell collapsing>
            <NoticeBox danger inline>
              <Button
                onClick={() =>
                  act('killswitch_ghostdrone', { index: index + 1 })
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
*/

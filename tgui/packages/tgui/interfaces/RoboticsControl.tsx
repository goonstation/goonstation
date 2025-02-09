/**
 * @file
 * @copyright 2025
 * @author FlameArrow57 (https://github.com/FlameArrow57)
 * @license ISC
 */

import { Button, NoticeBox, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface RoboticsControlData {
  user_is_ai: boolean;
  user_is_cyborg: boolean;
  ai_names: string[];
  ai_statuses: string[];
  ai_killswitch_times: string[];
  cyborg_names: string[];
  cyborg_statuses: string[];
  cyborg_cell_charges: string[];
  cyborg_modules: string[];
  cyborg_lock_times: string[];
  cyborg_killswitch_times: string[];
  ghostdrone_names: string[];
}

export const RoboticsControl = () => {
  const { act, data } = useBackend<RoboticsControlData>();
  const {
    user_is_ai,
    user_is_cyborg,
    ai_names,
    ai_statuses,
    ai_killswitch_times,
    cyborg_names,
    cyborg_statuses,
    cyborg_cell_charges,
    cyborg_modules,
    cyborg_lock_times,
    cyborg_killswitch_times,
    ghostdrone_names,
  } = data;

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
          <AiStatuses
            ai_names={ai_names}
            ai_statuses={ai_statuses}
            ai_killswitch_times={ai_killswitch_times}
            user_is_robot={user_is_ai || user_is_cyborg}
          />
        </Section>
        <Section
          title="Located Silicons"
          fill
          scrollable
          minHeight="200px"
          maxHeight="200px"
        >
          <SiliconStatuses
            cyborg_names={cyborg_names}
            cyborg_statuses={cyborg_statuses}
            cyborg_cell_charges={cyborg_cell_charges}
            cyborg_modules={cyborg_modules}
            cyborg_lock_times={cyborg_lock_times}
            cyborg_killswitch_times={cyborg_killswitch_times}
            user_is_ai={user_is_ai}
            user_is_cyborg={user_is_cyborg}
          />
        </Section>
        <Section
          title="Ghostdrones"
          fill
          scrollable
          minHeight="140px"
          maxHeight="140px"
        >
          <GhostdroneStatuses ghostdrone_names={ghostdrone_names} />
        </Section>
      </Window.Content>
    </Window>
  );
};

const AiStatuses = (props) => {
  const { act } = useBackend();
  const { ai_names, ai_statuses, ai_killswitch_times, user_is_robot } = props;

  return (
    <Table>
      <Table.Row>
        <Table.Cell bold>Name</Table.Cell>
        <Table.Cell bold>Status</Table.Cell>
        <Table.Cell bold>Switch</Table.Cell>
      </Table.Row>
      {ai_names.map((item, index) => (
        <Table.Row key={index}>
          <Table.Cell>{item}</Table.Cell>
          <Table.Cell>{ai_statuses[index]}</Table.Cell>
          <Table.Cell collapsing>
            {!ai_killswitch_times[index] ? (
              <NoticeBox warning inline>
                <Button
                  disabled={user_is_robot}
                  onClick={() =>
                    act('start_ai_killswitch', { index: index + 1 })
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
                    act('stop_ai_killswitch', { index: index + 1 })
                  }
                >
                  Cancel kill switch - {ai_killswitch_times[index]} remaining
                </Button>
              </NoticeBox>
            )}
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};

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

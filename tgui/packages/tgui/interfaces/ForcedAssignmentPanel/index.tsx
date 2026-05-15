/**
 * @file
 * @copyright 2026
 * @author DisturbHerb (https://github.com/DisturbHerb)
 * @license ISC
 */

import { capitalize } from 'common/string';
import { Button, NoticeBox, Section, Stack, Table } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import {
  ForcedAntagonist,
  ForcedAssignment,
  ForcedAssignmentPanelData,
  GameStates,
} from './types';

export const ForcedAssignmentPanel = () => {
  const { act, data } = useBackend<ForcedAssignmentPanelData>();
  const { currentState } = data;

  return (
    <Window width={800} height={450} title="Forced Assignment Panel">
      <Window.Content>
        <Stack fill vertical>
          {!!(currentState >= GameStates.GameStateSettingUp) && (
            <Stack.Item>
              <NoticeBox>
                Changes to forced assignments will not take effect in an active
                round!
              </NoticeBox>
            </Stack.Item>
          )}
          <Stack.Item grow>
            <Section
              fill
              title="Forced Assignments"
              buttons={
                <Stack justify="center">
                  <Stack.Item>
                    <Button
                      onClick={() => act('add_forced_assignment')}
                      color="good"
                      icon="plus"
                    >
                      Add Forced Assignment
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      onClick={() => act('clear_forced_assignments')}
                      color="bad"
                      icon="trash"
                    >
                      Clear All
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      onClick={() => act('import_forced_assignments')}
                      icon="file-import"
                    >
                      Import
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      onClick={() => act('export_forced_assignments')}
                      icon="file-export"
                    >
                      Export
                    </Button>
                  </Stack.Item>
                </Stack>
              }
            >
              <ForcedAssignmentTable />
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ForcedAssignmentTable = () => {
  const { data } = useBackend<ForcedAssignmentPanelData>();
  const { forcedAssignments } = data;

  return (
    <Table textAlign="center">
      <Table.Row header>
        <Table.Cell textAlign="center" verticalAlign="middle">
          CKey
        </Table.Cell>
        <Table.Cell textAlign="center" verticalAlign="middle">
          Player Name
        </Table.Cell>
        <Table.Cell textAlign="center" verticalAlign="middle">
          Job
        </Table.Cell>
        <Table.Cell textAlign="center" verticalAlign="middle">
          Antagonist Roles
        </Table.Cell>
        <Table.Cell collapsing textAlign="center" verticalAlign="middle">
          Actions
        </Table.Cell>
      </Table.Row>
      {Object.values(forcedAssignments).map((forcedAssignment) => (
        <ForcedAssignmentRow
          key={forcedAssignment.ckey}
          {...forcedAssignment}
        />
      ))}
    </Table>
  );
};

const ForcedAssignmentRow = (props: ForcedAssignment) => {
  const { act } = useBackend<ForcedAssignmentPanelData>();
  const { ckey, playerName, forcedJob, forcedAntags } = props;
  return (
    <Table.Row className="candystripe">
      <Table.Cell textAlign="center" verticalAlign="middle">
        <Button
          onClick={() => act('edit_ckey', { ckey: ckey })}
          tooltip="Change CKey"
        >
          {ckey}
        </Button>
      </Table.Cell>
      <Table.Cell textAlign="center" verticalAlign="middle">
        {playerName ? <PlayerItem ckey={ckey} /> : 'OFFLINE'}
      </Table.Cell>
      <Table.Cell textAlign="center" verticalAlign="middle">
        {forcedJob ? (
          <JobItem ckey={ckey} forcedJob={forcedJob} />
        ) : (
          <Button
            icon="plus"
            onClick={() => act('edit_job', { ckey: ckey })}
            tooltip="Add job"
          />
        )}
      </Table.Cell>
      <Table.Cell textAlign="center" verticalAlign="middle">
        <Stack fill vertical>
          {!!forcedAntags &&
            Object.values(forcedAntags).map((forcedAntag) => (
              <ForcedAntagonistItem
                key={forcedAntag.displayName}
                ckey={ckey}
                {...forcedAntag}
              />
            ))}
          <Stack.Item>
            <Button
              icon="plus"
              onClick={() => act('add_antagonist_roles', { ckey: ckey })}
              tooltip="Add antagonist role"
            />
          </Stack.Item>
        </Stack>
      </Table.Cell>
      <Table.Cell textAlign="center" verticalAlign="middle">
        <Button
          onClick={() => act('remove_forced_assignment', { ckey: ckey })}
          color="bad"
          icon="x"
          tooltip={'Remove ' + ckey}
        />
      </Table.Cell>
    </Table.Row>
  );
};

interface PlayerItemProps {
  ckey: string;
}

const PlayerItem = (props: PlayerItemProps) => {
  const { act } = useBackend<ForcedAssignmentPanelData>();
  const { ckey } = props;

  return (
    <Stack justify="center">
      <Stack.Item>
        <Button
          onClick={() =>
            act('open_player_options', {
              ckey: ckey,
            })
          }
          tooltip={'View player options for ' + ckey}
        >
          {ckey}
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="envelope"
          color="bad"
          onClick={() =>
            act('private_message_player', {
              ckey: ckey,
            })
          }
          tooltip={'Private message ' + ckey}
        />
      </Stack.Item>
    </Stack>
  );
};

interface JobItemProps {
  ckey: string;
  forcedJob: string;
}

const JobItem = (props: JobItemProps) => {
  const { act } = useBackend<ForcedAssignmentPanelData>();
  const { ckey, forcedJob } = props;

  return (
    <Stack fill justify="center">
      <Stack.Item>
        <Button
          onClick={() => act('edit_job', { ckey: ckey })}
          tooltip="Edit job"
        >
          {forcedJob}
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="x"
          color="bad"
          onClick={() =>
            act('remove_job', {
              ckey: ckey,
            })
          }
          tooltip="Remove Job"
        />
      </Stack.Item>
    </Stack>
  );
};

interface ForcedAntagonistItemProps extends ForcedAntagonist {
  ckey: string;
}

const ForcedAntagonistItem = (props: ForcedAntagonistItemProps) => {
  const { act } = useBackend<ForcedAssignmentPanelData>();
  const { ckey, displayName, doEquipment, doObjectives, customObjective } =
    props;
  return (
    <Stack.Item>
      <Stack fill justify="center">
        <Stack.Item>
          {' '}
          <Button
            onClick={() =>
              act('edit_antagonist', {
                ckey: ckey,
                displayName: displayName,
              })
            }
            tooltip={
              <Stack fill vertical>
                <Stack.Item>
                  Give Equipment: {doEquipment ? 'Yes' : 'No'}
                </Stack.Item>
                <Stack.Item>
                  Random Objectives: {doObjectives ? 'Yes' : 'No'}
                </Stack.Item>
                {!!customObjective && (
                  <Stack.Item>Custom Objective: {customObjective}</Stack.Item>
                )}
              </Stack>
            }
          >
            <Stack fill vertical>
              <Stack.Item>{capitalize(displayName)}</Stack.Item>
            </Stack>
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="x"
            color="bad"
            onClick={() =>
              act('remove_antagonist', {
                ckey: ckey,
                displayName: displayName,
              })
            }
            tooltip={'Remove ' + displayName}
          />
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

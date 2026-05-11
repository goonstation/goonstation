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

const ForcedAssignmentItem = (props: ForcedAssignment) => {
  const { act } = useBackend<ForcedAssignmentPanelData>();
  const {
    ckey,
    playerName,
    forcedJobInput,
    forcedJob,
    forcedAntagInput,
    forcedAntags,
  } = props;
  return (
    <Table.Row className="candystripe">
      <Table.Cell textAlign="center">{ckey}</Table.Cell>
      <Table.Cell textAlign="center">
        {playerName ? (
          <Stack>
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
        ) : (
          'N/A'
        )}
      </Table.Cell>
      <Table.Cell textAlign="center">
        {forcedJob ? (
          <Button
            onClick={() => act('edit_job', { ckey: ckey })}
            tooltip="Edit Job"
          >
            {forcedJob}
          </Button>
        ) : forcedJobInput ? (
          <Stack fill vertical>
            <Stack.Item>
              <NoticeBox danger>Invalid Job!</NoticeBox>
            </Stack.Item>
            <Stack.Item>{forcedJobInput}</Stack.Item>
          </Stack>
        ) : (
          'N/A'
        )}
      </Table.Cell>
      <Table.Cell textAlign="center">
        <Stack fill vertical>
          {forcedAntags ? (
            Object.values(forcedAntags).map((forcedAntag) => (
              <ForcedAntagonistItem
                key={forcedAntag.displayName}
                ckey={ckey}
                {...forcedAntag}
              />
            ))
          ) : forcedAntagInput.length ? (
            <Stack.Item>
              <NoticeBox danger>Invalid Antagonists!</NoticeBox>
            </Stack.Item>
          ) : (
            'N/A'
          )}
        </Stack>
      </Table.Cell>
      <Table.Cell textAlign="center">
        <Button
          onClick={() => act('remove_forced_assignment', { ckey: ckey })}
          color="red"
          icon="x"
          tooltip={'Remove ' + ckey}
        />
      </Table.Cell>
    </Table.Row>
  );
};

interface ForcedAntagonistProps extends ForcedAntagonist {
  ckey: string;
}

const ForcedAntagonistItem = (props: ForcedAntagonistProps) => {
  const { act } = useBackend<ForcedAssignmentPanelData>();
  const {
    antagonistPath,
    ckey,
    displayName,
    doEquipment,
    doObjectives,
    customObjective,
  } = props;
  return (
    <Stack.Item>
      <Button
        onClick={() =>
          act('edit_antagonist_role', {
            ckey: ckey,
            forcedAntagonist: displayName,
          })
        }
        tooltip={
          <Stack fill vertical textAlign="center">
            <Stack.Item>Give Equipment: {doEquipment}</Stack.Item>
            <Stack.Item>Do Objectives: {doObjectives}</Stack.Item>
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
  );
};

export const ForcedAssignmentPanel = () => {
  const { act, data } = useBackend<ForcedAssignmentPanelData>();
  const { currentState, forcedAssignments } = data;

  return (
    <Window width={640} height={480} title="Forced Assignment Panel">
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
              title="Forced Assignment Controls"
              fill
              buttons={
                <Stack>
                  <Stack.Item>
                    <Button onClick={() => act('add_forced_assignment')}>
                      Add Forced Assignment
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Button onClick={() => act('clear_forced_assignments')}>
                      Clear All
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Button onClick={() => act('import_forced_assignments')}>
                      Import
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Button onClick={() => act('export_forced_assignments')}>
                      Export
                    </Button>
                  </Stack.Item>
                </Stack>
              }
            >
              <Table>
                <Table.Row header>
                  <Table.Cell collapsing textAlign="center">
                    CKey
                  </Table.Cell>
                  <Table.Cell collapsing textAlign="center">
                    Player Name
                  </Table.Cell>
                  <Table.Cell textAlign="center">Job</Table.Cell>
                  <Table.Cell textAlign="center">Antagonist Roles</Table.Cell>
                  <Table.Cell collapsing textAlign="center">
                    Actions
                  </Table.Cell>
                </Table.Row>
                {Object.values(forcedAssignments).map((forcedAssignment) => (
                  <ForcedAssignmentItem
                    key={forcedAssignment.ckey}
                    {...forcedAssignment}
                  />
                ))}
              </Table>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

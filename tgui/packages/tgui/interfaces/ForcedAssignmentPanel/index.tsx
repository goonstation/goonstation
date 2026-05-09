/**
 * @file
 * @copyright 2026
 * @author DisturbHerb (https://github.com/DisturbHerb)
 * @license ISC
 */

import { Box, Button, Divider, Section, Stack } from 'tgui-core/components';
import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { ForcedAssignmentPanelData, ForcedAssignment } from './types';

const ForcedAssignmentItem = (props: ForcedAssignment) => {
  const { act } = useBackend<ForcedAssignmentPanelData>();
  const { ckey, playerName, forcedJob } = props;
  return (
    <Stack.Item>
      <Stack align="baseline" justify="space-between" textAlign="center">
        <Stack.Item grow>{ckey}</Stack.Item>
        <Stack.Item grow>
          {playerName ? playerName : <Box bold>Offline</Box>}
        </Stack.Item>
        <Stack.Item grow>
          <Stack justify="space-between">
            <Stack.Item grow>
              <Stack fill vertical>
                {!forcedJob && <Stack.Item bold>N/A</Stack.Item>}
                {!!forcedJob && <Stack.Item>{forcedJob}</Stack.Item>}
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Button
                onClick={() => act('remove_forced_assignment', { ckey: ckey })}
                color="red"
                icon="x"
                tooltip="Remove"
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
      <Divider />
    </Stack.Item>
  );
};

export const ForcedAssignmentPanel = () => {
  const { act, data } = useBackend<ForcedAssignmentPanelData>();
  const { forcedAssignments } = data;

  return (
    <Window width={1100} height={640} title="Forced Assignment Panel">
      <Window.Content>
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
          <Stack fill vertical>
            <Stack.Item>
              <Stack fill bold textAlign="center">
                <Stack.Item grow>CKEY</Stack.Item>
                <Stack.Item grow>Mob Name</Stack.Item>
                <Stack.Item grow>Assignment</Stack.Item>
              </Stack>
            </Stack.Item>
            {Object.values(forcedAssignments).map((forcedAssignment) => (
              <ForcedAssignmentItem
                key={forcedAssignment.ckey}
                {...forcedAssignment}
              />
            ))}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

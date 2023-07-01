import { useBackend } from '../backend';
import { Button, ProgressBar, Section, Stack } from '../components';
import { Window } from '../layouts';

const PollControls = ({ isAdmin, act, pollId, pollStatus, multipleChoice }) => {
  if (!isAdmin) return null;
  return (
    <Stack>
      <Stack.Item>
        <Button tooltip="Add Option" tooltipPosition="top" icon="plus" onClick={() => act('addOption', { pollId })} />
        <Button
          tooltip="Edit Poll"
          tooltipPosition="top"
          icon="pen"
          onClick={() => act('editPoll', { pollId })}
        />
        <Button
          tooltip="Toggle Multiple Choice"
          tooltipPosition="top"
          color={multipleChoice ? 'good' : 'bad'}
          icon="list-check"
          onClick={() => act('toggleMultipleChoice', { pollId })}
        />
        <Button
          tooltip="Poll Status"
          tooltipPosition="top"
          color={pollStatus ? 'good' : 'bad'}
          icon={pollStatus ? 'lock-open' : 'lock'}
          onClick={() => act('togglePollStatus', { pollId })}
        />
        <Button.Confirm tooltip="Delete Poll" tooltipPosition="top" icon="trash" color="bad" onClick={() => act('deletePoll', { pollId })} />
      </Stack.Item>
    </Stack>
  );
};

const OptionControls = ({ isAdmin, act, pollId, optionId }) => {
  if (!isAdmin) return null;
  return (
    <Stack>
      <Stack.Item>
        <Button icon="pen" onClick={() => act('editOption', { optionId })} />
        <Button.Confirm icon="trash" color="bad" onClick={() => act('deleteOption', { optionId })} />
      </Stack.Item>
    </Stack>
  );
};

const Ballot = ({ options, total_answers, act, pollId, isAdmin, pollStatus }) => {
  if (!options || options.length === 0) return null;
  return (
    <Stack vertical>
      {options.map((option, index) => (
        <Stack.Item key={index}>
          <Stack vertical>
            <Stack>
              <Stack.Item grow>
                <Button.Checkbox
                  checked={option.voted}
                  disabled={!pollStatus}
                  onClick={() => act('vote', { pollId, optionId: option.id })}
                >
                  {option.option}
                </Button.Checkbox>
              </Stack.Item>
              <Stack.Item>
                <OptionControls
                  isAdmin={isAdmin}
                  act={act}
                  pollId={pollId}
                  optionId={option.id}
                  pollStatus={pollStatus}
                />
              </Stack.Item>
            </Stack>
            <Stack.Item>
              <ProgressBar value={option.answers_count / total_answers} />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      ))}
    </Stack>
  );
};

export const PollBallot = (props, context) => {
  const { act, data } = useBackend(context);
  const { isAdmin, polls } = data;

  return (
    <Window title="Poll Ballot" width="750" height="800">
      <Window.Content>
        <Stack vertical>
          {polls && polls.map((poll, index) => (
            <Stack.Item key={index}>
              <Section
                title={poll.question}
                buttons={
                  <PollControls
                    isAdmin={isAdmin}
                    act={act}
                    pollId={poll.id}
                    pollStatus={poll.status}
                    multipleChoice={poll.multiple_choice === "yes"}
                  />
                }>
                <Stack vertical>
                  <Ballot
                    options={poll.options}
                    total_answers={poll.total_answers}
                    act={act}
                    pollId={poll.id}
                    isAdmin={isAdmin}
                    pollStatus={poll.status}
                  />
                </Stack>
              </Section>
            </Stack.Item>
          ))}
          {isAdmin && (
            <Stack.Item>
              <Button onClick={() => act('addPoll')}>Add Poll</Button>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

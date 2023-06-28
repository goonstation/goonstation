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


const OptionControls = ({ isAdmin, act, pollId, optionIndex }) => {
  if (!isAdmin) return null;
  return (
    <Stack>
      <Stack.Item>
        <Button icon="pen" onClick={() => act('editOption', { pollId, optionIndex })} />
        <Button.Confirm icon="trash" color="bad" onClick={() => act('deleteOption', { pollId, optionIndex })} />
      </Stack.Item>
    </Stack>
  );
};

const Ballot = ({ pollOptions, totalVotes, act, pollId, isAdmin, pollStatus }) => {
  if (!pollOptions || pollOptions.length === 0) return null;
  return (
    <Stack vertical>
      {pollOptions.map((option, index) => (
        <Stack.Item key={index}>
          <Stack vertical>
            <Stack>
              <Stack.Item grow>
                <Button.Checkbox
                  checked={option.voted}
                  disabled={!pollStatus}
                  onClick={() => act('vote', { pollId, option: index })}
                >
                  {option.name}
                </Button.Checkbox>
              </Stack.Item>
              <Stack.Item>
                <OptionControls
                  isAdmin={isAdmin}
                  act={act}
                  pollId={pollId}
                  optionIndex={index}
                  pollStatus={pollStatus}
                />
              </Stack.Item>
            </Stack>
            <Stack.Item>
              <ProgressBar value={option.voteCount / totalVotes} />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      ))}
    </Stack>
  );
};

export const VotingBallot = (props, context) => {
  const { act, data } = useBackend(context);
  const { polls, isAdmin } = data;

  return (
    <Window title="Voting Ballot" width="750" height="800">
      <Window.Content>
        <Stack vertical>
          {polls.map((poll, index) => (
            <Stack.Item key={index}>
              <Section
                title={`Poll #${index + 1}`}
                buttons={
                  <PollControls
                    isAdmin={isAdmin}
                    act={act}
                    pollId={poll.id}
                    pollStatus={poll.status}
                    multipleChoice={poll.multipleChoice}
                  />
                }>
                <Stack vertical>
                  <Ballot
                    pollOptions={poll.options}
                    totalVotes={poll.totalVotes}
                    act={act}
                    pollId={poll.id}
                    isAdmin={isAdmin}
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

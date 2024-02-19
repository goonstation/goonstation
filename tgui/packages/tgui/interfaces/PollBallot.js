import { useBackend } from '../backend';
import { Button, ProgressBar, Section, Stack } from '../components';
import { Window } from '../layouts';

const PollControls = ({ isAdmin, act, pollId, isExpired, multipleChoice, expiryDate, servers }) => {
  return (
    <Stack>
      <Stack.Item>
        {servers.includes("global") ? (
          <Button
            tooltip="Global Poll"
            tooltipPosition="top"
            icon="globe"
          />
        ) : servers.includes("rp_only") ? (
          <Button
            tooltip="RP Only Poll"
            tooltipPosition="top"
            icon="masks-theater"
          />
        ) : null}
        {multipleChoice ? (
          <Button
            tooltip="Multiple Choice"
            tooltipPosition="top"
            icon="list-check"
          />
        ) : null}
        <Button
          tooltip={expiryDate ? expiryDate : "No Expiration Date"}
          tooltipPosition="top"
          color={isExpired ? 'bad' : 'good'}
          icon={isExpired ? 'lock' : 'lock-open'}
        />
        {isAdmin ? (
          <>
            <Button tooltip="Add Option" tooltipPosition="top" icon="plus" onClick={() => act('addOption', { pollId })} />
            <Button
              tooltip="Edit Poll"
              tooltipPosition="top"
              icon="pen"
              onClick={() => act('editPoll', { pollId })}
            />
            <Button.Confirm tooltip="Delete Poll" tooltipPosition="top" icon="trash" color="bad" onClick={() => act('deletePoll', { pollId })} />
          </>
        ) : null}
      </Stack.Item>
    </Stack>
  );
};

const OptionControls = ({ isAdmin, act, pollId, optionId }) => {
  if (!isAdmin) return null;
  return (
    <Stack>
      <Stack.Item>
        <Button icon="pen" onClick={() => act('editOption', { pollId, optionId })} />
        <Button.Confirm icon="trash" color="bad" onClick={() => act('deleteOption', { pollId, optionId })} />
      </Stack.Item>
    </Stack>
  );
};

const Poll = ({ options, total_answers, act, pollId, isAdmin, isExpired, playerId }) => {
  if (!options || options.length === 0) return null;
  return (
    <Stack vertical>
      {options.map((option, index) => (
        <Stack.Item key={index}>
          <Stack vertical>
            <Stack>
              <Stack.Item grow>
                <Button.Checkbox
                  disabled={isExpired}
                  checked={option.answers_player_ids.includes(playerId)}
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
                />
              </Stack.Item>
            </Stack>
            <Stack.Item>
              <ProgressBar value={total_answers ? option.answers_count / total_answers : 0} />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      ))}
    </Stack>
  );
};

export const PollBallot = (props, context) => {
  const { act, data } = useBackend(context);
  const { isAdmin, filterInactive, polls, playerId } = data;

  return (
    <Window title="Poll Ballot" width="750" height="800">
      <Window.Content>
        <Stack vertical>
          <Stack.Item>
            <Stack>
              <Stack.Item>
                <Button.Checkbox
                  checked={filterInactive}
                  onClick={() => act('toggle-filterInactive')}>Filter Closed Polls
                </Button.Checkbox>
              </Stack.Item>
              {isAdmin ? (
                <Stack.Item>
                  <Button onClick={() => act('addPoll')}>Add Poll</Button>
                </Stack.Item>
              ) : null}
            </Stack>
          </Stack.Item>
          {
            polls && polls.filter(poll => {
              // Check if the poll is expired by comparing the current date to expires_at.
              const isExpired = poll.expires_at ? new Date() >= new Date(poll.expires_at) : false;
              // If filterInactive is true, exclude expired polls. Otherwise, include all.
              return !filterInactive || !isExpired;
            }).map((poll, index) => (
              <Stack.Item key={index}>
                <Section
                  title={poll.question}
                  buttons={
                    <PollControls
                      isAdmin={isAdmin}
                      act={act}
                      pollId={poll.id}
                      isExpired={poll.expires_at && (new Date() > new Date(poll.expires_at))}
                      multipleChoice={poll.multiple_choice}
                      expiryDate={poll.expires_at}
                      servers={poll.servers}
                    />
                  }>
                  <Stack vertical>
                    <Poll
                      options={poll.options}
                      total_answers={poll.total_answers}
                      act={act}
                      pollId={poll.id}
                      isAdmin={isAdmin}
                      isExpired={poll.expires_at && (new Date() > new Date(poll.expires_at))}
                      playerId={playerId}
                    />
                  </Stack>
                </Section>
              </Stack.Item>
            ))
          }
        </Stack>
      </Window.Content>
    </Window>
  );
};

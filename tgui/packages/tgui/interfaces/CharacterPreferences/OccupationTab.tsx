/**
 * @file
 * @copyright 2025
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import {
  Box,
  Button,
  LabeledList,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { CharacterPreferencesData } from './type';

export const OccupationTab = () => {
  const { act, data } = useBackend<CharacterPreferencesData>();

  return (
    <>
      <Section title="Job Preferences">
        <Stack height="2em" mb="2em" align="center" justify="space-between">
          <Stack.Item width="50%" pt="2.5px">
            <LabeledList>
              <LabeledList.Item
                label={
                  <Tooltip content="This is for the one job that you like the most - the game will always try to get you into this job first if it can. You might not always get your favorite job, especially if it's a single-slot role like a Head, but don't be discouraged if you don't get it - it's just luck of the draw. You might get it next time.">
                    Favourite Job:
                  </Tooltip>
                }
                verticalAlign="middle"
              >
                {data.jobFavourite ? (
                  <Occupation
                    job_title={data.jobFavourite}
                    priority_level={1}
                  />
                ) : (
                  'None'
                )}
              </LabeledList.Item>
            </LabeledList>
          </Stack.Item>
          <Stack.Item>
            <Button
              onClick={() => act('reset-all-jobs-priorities')}
              color="red"
            >
              Reset All Job Preferences
            </Button>
          </Stack.Item>
        </Stack>
        <Stack>
          <PrioritySection
            title="Medium Priority"
            priority_level={2}
            tooltip="Medium Priority Jobs are any jobs that you would like to play that aren't your favorite. People with jobs in this category get priority over those who have the same job in their Low Priority bracket. It's best to put jobs here that you actively enjoy playing and wouldn't mind ending up with if you don't get your favorite."
            occupations={data.jobsMedPriority}
          />
          <Stack.Divider />
          <PrioritySection
            title="Low Priority"
            priority_level={3}
            tooltip="Low Priority Jobs are jobs that you don't mind doing. When the game is finding candidates for a job, it will try to fill it with Medium Priority players first, then Low Priority players if there are still free slots."
            occupations={data.jobsLowPriority}
          />
          <Stack.Divider />
          <PrioritySection
            title="Unwanted Jobs"
            priority_level={4}
            tooltip="Unwanted Jobs are jobs that you absolutely don't want to have. The game will never give you a job you list here. The 'Staff Assistant' role can't be put here, however, as it's the fallback job if there are no other openings."
            occupations={data.jobsUnwanted}
          />
        </Stack>
      </Section>
      <Section
        title={
          <Tooltip content="Antagonist roles are randomly chosen when the game starts, before jobs have been allocated. Leaving an antagonist role unchecked means that you will never be chosen for it automatically.">
            Antagonist Preferences
          </Tooltip>
        }
      >
        <Stack
          g="2px"
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(2, 1fr)',
          }}
        >
          {Object.entries(data.antagonistPreferences).map(
            ([key, value], index) => (
              <Stack.Item key={index}>
                <Button.Checkbox
                  onClick={() =>
                    act('toggle-antagonist-preference', {
                      variable: data.antagonistStaticData[key].variable,
                    })
                  }
                  tooltip={
                    <OccupationTooltip
                      title={data.antagonistStaticData[key].name}
                      disabled_tooltip={
                        data.antagonistStaticData[key].disabled_tooltip
                      }
                    />
                  }
                  disabled={data.antagonistStaticData[key].disabled}
                  checked={value}
                  width="100%"
                >
                  {data.antagonistStaticData[key].name}
                </Button.Checkbox>
              </Stack.Item>
            ),
          )}
        </Stack>
      </Section>
    </>
  );
};

const PrioritySection = (props) => {
  const { title, priority_level, tooltip, occupations } = props;

  return (
    <Stack.Item grow overflow="hidden">
      <Section title={<Tooltip content={tooltip}>{title}</Tooltip>}>
        <Stack vertical g="2px">
          {occupations?.map((occupation, index) => (
            <Occupation
              key={index}
              job_title={occupation}
              priority_level={priority_level}
            />
          ))}
        </Stack>
      </Section>
    </Stack.Item>
  );
};

const Occupation = (props) => {
  const { job_title, priority_level } = props;
  const { act, data } = useBackend<CharacterPreferencesData>();

  return (
    <Stack.Item>
      <Stack g="3px">
        <Stack.Item>
          <Button
            onClick={() =>
              act('increase-job-priority', {
                job: job_title,
                priority: priority_level,
              })
            }
            disabled={
              data.jobStaticData[job_title].disabled || priority_level === 1
            }
            color={data.jobStaticData[job_title].colour}
            icon="chevron-left"
            align="left"
          />
        </Stack.Item>
        <Stack.Item grow minWidth="0px">
          <Button
            onClick={() =>
              act('set-job-priority', {
                job: job_title,
                priority: priority_level,
              })
            }
            tooltip={
              <OccupationTooltip
                title={job_title}
                disabled_tooltip={
                  data.jobStaticData[job_title].disabled_tooltip
                }
              />
            }
            disabled={data.jobStaticData[job_title].disabled}
            color={data.jobStaticData[job_title].colour}
            width="100%"
          >
            <Box
              overflow="hidden"
              textAlign="center"
              fontFamily={job_title === 'Clown' && 'Comic Sans MS'}
              fontSize={job_title === 'Clown' && '13px'}
            >
              {job_title}
            </Box>
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            onClick={() =>
              act('decrease-job-priority', {
                job: job_title,
                priority: priority_level,
              })
            }
            disabled={
              data.jobStaticData[job_title].disabled || priority_level === 4
            }
            color={data.jobStaticData[job_title].colour}
            icon="chevron-right"
            align="right"
          />
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const OccupationTooltip = (props) => {
  const { title, disabled_tooltip } = props;

  return (
    <>
      <Box bold textAlign="center">
        {title}
      </Box>
      {!!disabled_tooltip && (
        <Box
          mt="0.5em"
          dangerouslySetInnerHTML={{
            __html: `<b>Disabled:</b> ${disabled_tooltip}`,
          }}
        />
      )}
    </>
  );
};

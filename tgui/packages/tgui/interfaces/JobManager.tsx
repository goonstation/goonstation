/**
 * @file
 * @copyright 2024
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import {
  Box,
  Button,
  Collapsible,
  Divider,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const JobItem = ({
  name,
  count,
  limit,
  type,
  onEdit,
  onAlterCap,
  onRemove,
}) => (
  <LabeledList.Item
    label={name}
    buttons={
      <>
        <Button tooltip="Alter Cap" onClick={onAlterCap}>
          {`${count}/${limit}`}
        </Button>
        <Button icon="edit" tooltip="Edit Job" onClick={onEdit} />
        {type === 'created' && (
          <Button.Confirm
            icon="trash"
            color="bad"
            tooltip="Remove Job"
            onClick={onRemove}
          />
        )}
      </>
    }
  />
);

const JobList = ({ jobs, act }) => (
  <LabeledList>
    {jobs.map((job) => (
      <JobItem
        key={job.name}
        name={job.name}
        count={job.count}
        limit={job.limit}
        type={job.type}
        onEdit={() => act('edit', { job: job.name })}
        onAlterCap={() => act('alter_cap', { job: job.name })}
        onRemove={() => act('remove_job', { job: job.name })}
      />
    ))}
  </LabeledList>
);

const JobCategory = ({ title, jobs, color, act }) => (
  <Collapsible
    title={title}
    color={color}
    childStyles={{ paddingLeft: '10px' }}
  >
    <JobList jobs={jobs} act={act} />
  </Collapsible>
);

const ForcedAssignmentItem = (props: ForcedAssignment) => {
  const { act } = useBackend<JobManagerData>();
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

interface JobManagerData {
  allowSpecialJobs: boolean;
  hiddenJobs;
  specialJobs;
  categorisedSpecialJobs;
  stapleJobs;
  forcedAssignments: Record<string, ForcedAssignment>;
}

interface ForcedAssignment {
  ckey: string;
  playerName: string;
  forcedJob: string;
}

export const JobManager = () => {
  const { act, data } = useBackend<JobManagerData>();

  const {
    stapleJobs = [],
    specialJobs = [],
    categorisedSpecialJobs = [],
    hiddenJobs = [],
    allowSpecialJobs,
    forcedAssignments,
  } = data;

  const jobCategories = [
    {
      name: 'Command Jobs',
      color: 'green',
      jobs: stapleJobs.filter((job) => job.type === 'command'),
    },
    {
      name: 'Security Jobs',
      color: 'red',
      jobs: stapleJobs.filter((job) => job.type === 'security'),
    },
    {
      name: 'Research Jobs',
      color: 'violet',
      jobs: stapleJobs.filter((job) => job.type === 'research'),
    },
    {
      name: 'Medical Jobs',
      color: 'pink',
      jobs: stapleJobs.filter((job) => job.type === 'medical'),
    },
    {
      name: 'Engineering Jobs',
      color: 'orange',
      jobs: stapleJobs.filter((job) => job.type === 'engineering'),
    },
    {
      name: 'Civilian Jobs',
      color: 'blue',
      jobs: stapleJobs.filter((job) => job.type === 'civilian'),
    },
  ];

  const specialJobCategories = [
    {
      name: 'Nanotrasen Jobs',
      color: 'navy',
      jobs: categorisedSpecialJobs.filter((job) => job.type === 'nanotrasen'),
    },
    {
      name: 'Syndicate Jobs',
      color: 'crimson',
      jobs: categorisedSpecialJobs.filter((job) => job.type === 'syndicate'),
    },
    {
      name: 'Halloween Jobs',
      color: 'orange',
      jobs: categorisedSpecialJobs.filter((job) => job.type === 'halloween'),
    },
    {
      name: 'Clown Jobs',
      color: 'pink',
      jobs: categorisedSpecialJobs.filter((job) => job.type === 'clown'),
    },
    {
      name: 'Random Jobs',
      color: 'teal',
      jobs: categorisedSpecialJobs.filter((job) => job.type === 'random'),
    },
    {
      name: 'Daily Jobs',
      color: 'blue',
      jobs: categorisedSpecialJobs.filter((job) => job.type === 'daily'),
    },
  ];

  return (
    <Window title="Job Manager" width={500} height={600}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <Section title="Job Controls" fill>
              {stapleJobs.length || specialJobs.length || hiddenJobs.length ? (
                <>
                  {jobCategories.map((category) => (
                    <JobCategory
                      key={category.name}
                      title={category.name}
                      jobs={category.jobs}
                      color={category.color}
                      act={act}
                    />
                  ))}
                  <Collapsible
                    title="Special Jobs"
                    childStyles={{ paddingLeft: '10px' }}
                  >
                    {specialJobCategories.map((category) => (
                      <JobCategory
                        key={category.name}
                        title={category.name}
                        jobs={category.jobs}
                        color={category.color}
                        act={act}
                      />
                    ))}
                    <JobList jobs={specialJobs} act={act} />
                  </Collapsible>
                  <JobCategory
                    title="Hidden Jobs"
                    jobs={hiddenJobs}
                    color={'grey'}
                    act={act}
                  />
                  <Button.Checkbox
                    checked={allowSpecialJobs}
                    onClick={() => act('toggle_special_jobs')}
                  >
                    Special Jobs
                  </Button.Checkbox>
                  <Button onClick={() => act('job_creator')}>
                    Create New Job
                  </Button>
                </>
              ) : (
                <NoticeBox>No jobs found.</NoticeBox>
              )}
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              title="Forced Assignment Controls"
              fill
              buttons={
                <Stack>
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
                <Stack.Item align="center">
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
                  </Stack>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

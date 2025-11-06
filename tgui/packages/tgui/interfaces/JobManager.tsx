/**
 * @file
 * @copyright 2024
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import {
  Button,
  Collapsible,
  LabeledList,
  NoticeBox,
  Section,
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

interface JobManagerData {
  allowSpecialJobs;
  hiddenJobs;
  specialJobs;
  categorisedSpecialJobs;
  stapleJobs;
}

export const JobManager = () => {
  const { act, data } = useBackend<JobManagerData>();

  const {
    stapleJobs = [],
    specialJobs = [],
    categorisedSpecialJobs = [],
    hiddenJobs = [],
    allowSpecialJobs,
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
  ];

  if (!stapleJobs.length && !specialJobs.length && !hiddenJobs.length) {
    return (
      <Window title="Job Manager" width={400} height={600}>
        <Window.Content scrollable>
          <NoticeBox>No jobs found.</NoticeBox>
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window title="Job Manager" width={500} height={600}>
      <Window.Content scrollable>
        <Section title="Job Controls">
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
          <Button onClick={() => act('job_creator')}>Create New Job</Button>
        </Section>
      </Window.Content>
    </Window>
  );
};

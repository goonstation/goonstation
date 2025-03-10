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

const JobCategory = ({ title, jobs, act }) => (
  <Collapsible title={title}>
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
  </Collapsible>
);

interface JobManagerData {
  allowSpecialJobs;
  hiddenJobs;
  specialJobs;
  stapleJobs;
}

export const JobManager = () => {
  const { act, data } = useBackend<JobManagerData>();

  const {
    stapleJobs = [],
    specialJobs = [],
    hiddenJobs = [],
    allowSpecialJobs,
  } = data;

  const jobCategories = [
    {
      name: 'Command Jobs',
      jobs: stapleJobs.filter((job) => job.type === 'command'),
    },
    {
      name: 'Security Jobs',
      jobs: stapleJobs.filter((job) => job.type === 'security'),
    },
    {
      name: 'Research Jobs',
      jobs: stapleJobs.filter((job) => job.type === 'research'),
    },
    {
      name: 'Medical Jobs',
      jobs: stapleJobs.filter((job) => job.type === 'medical'),
    },
    {
      name: 'Engineering Jobs',
      jobs: stapleJobs.filter((job) => job.type === 'engineering'),
    },
    {
      name: 'Civilian Jobs',
      jobs: stapleJobs.filter((job) => job.type === 'civilian'),
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
              act={act}
            />
          ))}
          <JobCategory title="Special Jobs" jobs={specialJobs} act={act} />
          <JobCategory title="Hidden Jobs" jobs={hiddenJobs} act={act} />
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

import { useBackend } from '../backend';
import { Button, Collapsible, LabeledList, NoticeBox, Section } from '../components';
import { Window } from '../layouts';

export const JobManager = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    stapleJobs = [],
    specialJobs = [],
    hiddenJobs = [],
    allowSpecialJobs,
  } = data;

  const jobCategories = [
    {
      name: 'Command Jobs',
      jobs: stapleJobs.filter(job => job.type === 'command'),
    },
    {
      name: 'Security Jobs',
      jobs: stapleJobs.filter(job => job.type === 'security'),
    },
    {
      name: 'Research Jobs',
      jobs: stapleJobs.filter(job => job.type === 'research'),
    },
    {
      name: 'Engineering Jobs',
      jobs: stapleJobs.filter(job => job.type === 'engineering'),
    },
    {
      name: 'Civilian Jobs',
      jobs: stapleJobs.filter(job => job.type === 'civilian'),
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
          {jobCategories.map(category => (
            <Collapsible key={category.name} title={category.name}>
              <LabeledList>
                {category.jobs.map(job => (
                  <LabeledList.Item 
                    key={job.name} 
                    label={job.name}    
                    buttons={
                      <>
                        <Button
                          content={`${job.count}/${job.limit}`}
                          onClick={() => act('alter_cap', { job: job.name })}
                        />
                        <Button
                          icon="edit"
                          onClick={() => act('edit', { job: job.name })}
                        />
                      </>
                    }
                  />
                ))}
              </LabeledList>
            </Collapsible>
          ))}
          <Collapsible title="Special Jobs">
            <LabeledList>
              {specialJobs.map(job => (
                <LabeledList.Item 
                  key={job.name} 
                  label={job.name}    
                  buttons={
                    <>
                      <Button
                        content={`${job.count}/${job.limit}`}
                        onClick={() => act('alter_cap', { job: job.name })}
                      />
                      <Button
                        icon="edit"
                        onClick={() => act('edit', { job: job.name })}
                      />
                      {job.type === 'created' && (
                        <Button.Confirm
                          icon="trash"
                          color="bad"
                          onClick={() => act('remove_job', { job: job.name })}
                        />
                      )}
                    </>
                  }
                />
              ))}
            </LabeledList>
          </Collapsible>
          <Collapsible title="Hidden Jobs">
            <LabeledList>
              {hiddenJobs.map(job => (
                <LabeledList.Item 
                  key={job.name} 
                  label={job.name}    
                  buttons={
                    <>
                      <Button
                        content={`${job.count}/${job.limit}`}
                        onClick={() => act('alter_cap', { job: job.name })}
                      />
                      <Button
                        icon="edit"
                        onClick={() => act('edit', { job: job.name })}
                      />
                      {job.type === 'created' && (
                        <Button.Confirm
                          icon="trash"
                          color="bad"
                          onClick={() => act('remove_job', { job: job.name })}
                        />
                      )}
                    </>
                  }
                />
              ))}
            </LabeledList>
          </Collapsible>
          <Button.Checkbox
            content="Special Jobs"
            checked={allowSpecialJobs}
            onClick={() => act('toggle_special_jobs')}
          />
          <Button content="Create New Job" onClick={() => act('job_creator')} />
        </Section>
      </Window.Content>
    </Window>
  );
};

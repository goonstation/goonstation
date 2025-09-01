type Act = (action: string, payload?: object) => void;

export const openJobWikiPage = (act: Act, job: string) =>
  act('open-job-wiki', { job });

export const setJobPriorityLevel = (
  act: Act,
  job: string,
  fromPriority: number,
  toPriority: number,
) => act('set-job-priority-level', { job, fromPriority, toPriority });

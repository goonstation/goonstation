/**
 * @file
 * @copyright 2025
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

type Act = (action: string, payload?: object) => void;

export const openJobWikiPage = (act: Act, job: string) =>
  act('open-job-wiki', { job });

export const setJobPriorityLevel = (
  act: Act,
  job: string,
  fromPriority: number,
  toPriority: number,
) => act('set-job-priority-level', { job, fromPriority, toPriority });

export const resetJobPriorityLevels = (act: Act, toPriority: number) =>
  act('reset-all-jobs-priorities', { toPriority });

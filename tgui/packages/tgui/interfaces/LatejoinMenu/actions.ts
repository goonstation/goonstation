/**
 * @file
 * @copyright 2025
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

type Act = (action: string, payload?: object) => void;

export const openJobWikiPage = (act: Act, job_ref: string) =>
  act('open-job-wiki', { job_ref });

export const joinAsJob = (
  act: Act,
  job_ref: string,
  silicon_latejoin?: string,
) => act('join-as-job', { job_ref, silicon_latejoin });

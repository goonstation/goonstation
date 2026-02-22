/**
 * @file
 * @copyright 2025
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import type { BooleanLike } from 'tgui-core/react';

export interface LatejoinMenuData {
  departments: DepartmentData[];
}

export interface DepartmentData {
  name: string;
  colour: string;
  jobs: JobData[];
}

export interface JobData {
  job_name: string;
  priority_role: BooleanLike;
  player_requested: BooleanLike;
  has_wiki_link: boolean;
  job_ref: string;
  silicon_latejoin?: string;
  colour: string;
  slot_count: number;
  slot_limit: number;
  disabled: BooleanLike;
}

export interface JobModalOptions {
  job_name: string;
  has_wiki_link: boolean;
  job_ref: string;
  silicon_latejoin: string | undefined;
}

export interface ModalContextValue {
  setJobModalOptions: (options: JobModalOptions | undefined) => void;
}

export interface ModalContextState {
  jobModal: JobModalOptions | undefined;
}

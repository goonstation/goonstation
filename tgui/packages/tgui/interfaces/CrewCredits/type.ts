/**
 * @file
 * @copyright 2023
 * @author Original glowbold (https://github.com/pgmzeta)
 * @author Changes Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import { BooleanLike } from 'common/react';

export interface CrewTabData {
  groups: GroupBlockProps[];
}

export interface GroupBlockProps {
  title: string;
  crew: CrewMemberProps[];
}

export interface CrewMemberProps {
  real_name: string;
  dead: BooleanLike;
  player: string;
  role: string;
  head?: BooleanLike;
}


export interface AntagonistTabData {
  game_mode: string;
  verbose_antagonist_data: VerboseAntagonistProps[]
  succinct_antagonist_data: SuccinctAntagonistProps[]
}

export interface VerboseAntagonistProps {
  antagonist_roles: string;
  real_name: string;
  player: string;
  job_role: string;
  status: string;

  objectives: ObjectiveProps[]
  antagonist_statistics: AntagonistStatisticsProps[]

  subordinate_antagonists: SuccinctAntagonistProps[]
}

export interface ObjectiveProps {
  explanation_text: string;
  completed: BooleanLike;
}

export interface AntagonistStatisticsProps {
  name: string;
  type: string;
  value: string;
}

export interface SuccinctAntagonistProps {
  antagonist_role: string;
  real_name: string;
  player: string;
  dead: BooleanLike;
}


export interface ScoreTabData {
  victory_headline: string;
  victory_body: string;
  total_score: string;
  grade: string;
  score_groups: ScoreCategoryProps[];
}
export interface ScoreCategoryProps {
  title: string;
  entries: ScoreItemProps[];
}

export interface ScoreItemProps {
  name: string;
  type: string;
  value: string;
}

export enum CrewCreditsTabKeys {
  General,
  Antagonists,
  Score,
}

/**
 * @file
 * @copyright 2023
 * @author Original glowbold (https://github.com/pgmzeta)
 * @author Changes Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import { BooleanLike } from 'tgui-core/react';

export enum CrewCreditsTabKeys {
  Crew,
  Antagonists,
  Score,
  Citations,
}

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
  head?: boolean;
}

export interface AntagonistTabData {
  game_mode: string;
  verbose_antagonist_data: VerboseAntagonistProps[];
  succinct_antagonist_data: SuccinctAntagonistProps[];
}

export interface VerboseAntagonistProps {
  antagonist_roles: string;
  real_name: string;
  player: string;
  job_role: string;
  status: string;

  objectives: ObjectiveProps[];
  antagonist_statistics: AntagonistStatisticsProps[];

  subordinate_antagonists: SuccinctAntagonistProps[];
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

export interface CitationTabData {
  tickets: CitationsByTargetData[];
  fines: CitationsByTargetData[];
}

export interface CitationByTargetListProps {
  title: string;
  citation_targets: CitationsByTargetData[];
}

export interface CitationsByTargetData {
  name: string;
  citations: CitationData[];
}

export interface TicketData {
  reason: string;
  issuer: string;
  issuer_job: string;
}

export interface FineData extends TicketData {
  amount: number;
  approver: string;
  approver_job: string;
  paid_amount: number;
  paid: BooleanLike;
}

export type CitationData = TicketData | FineData;

export const isFineData = (value: CitationData): value is FineData =>
  'amount' in value;

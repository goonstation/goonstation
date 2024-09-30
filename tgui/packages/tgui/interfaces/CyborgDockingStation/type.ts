/**
 * @file
 * @copyright 2022
 * @author glowbold (https://github.com/pgmzeta)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { BooleanLike } from 'tgui-core/react';

type FalsyBooleanLike = false | 0 | null | undefined;
type TruthyBooleanLike = true | 1;

export interface CyborgDockingStationData {
  occupant?: OccupantData;

  disabled: BooleanLike;
  viewer_is_occupant: BooleanLike;
  viewer_is_robot: BooleanLike;
  allow_self_service: BooleanLike;
  conversion_chamber: BooleanLike;

  cabling: number;
  fuel: number;

  cells: PowerCellData[];
  modules: ModuleData[];
  upgrades: UpgradeData[];
  clothes: ClothingData[];
}

interface OccupantDataBase {
  name: string;
  kind: 'eyebot' | 'human' | 'robot';
}

export interface OccupantDataRobot extends OccupantDataBase {
  kind: 'robot';
  parts: PartListData;
  cell?: PowerCellData;
  moduleName?: string;
  upgrades: UpgradeData[];
  upgrades_max: number;
  clothing: ClothingData[];
  cosmetics: RobotCosmeticsData;
  user: 'brain' | 'ai' | 'unknown';
}

export interface OccupantDataHuman extends OccupantDataBase {
  kind: 'human';
  health: number;
  max_health: number;
}

export interface OccupantDataEyebot extends OccupantDataBase {
  kind: 'eyebot';
  cell: PowerCellData;
}

export type OccupantData =
  | OccupantDataEyebot
  | OccupantDataHuman
  | OccupantDataRobot;

export interface PartListData {
  head: PartData;
  chest: PartData;
  arm_l: PartData;
  arm_r: PartData;
  leg_l: PartData;
  leg_r: PartData;
}

interface BasePartData {
  exists: BooleanLike;
}

interface MissingPartData extends BasePartData {
  exists: FalsyBooleanLike;
}

interface PresentPartData extends BasePartData {
  exists: TruthyBooleanLike;
  max_health: number;
  dmg_blunt: number;
  dmg_burns: number;
}

export type PartData = MissingPartData | PresentPartData;

export const isPresentPartsData = (
  partData: PartData,
): partData is PresentPartData => !!partData.exists;

export interface ItemData {
  name: string;
  ref: string;
}

export interface PowerCellData extends ItemData {
  current: number;
  max: number;
}

export interface ModuleData extends ItemData {}
export interface UpgradeData extends ItemData {}
export interface ClothingData extends ItemData {}

export interface RobotCosmeticsData {
  chest?: string;
  head?: string;
  arms?: string;
  legs?: string;
  paint?: string; // hex colour rep
  fx: [number, number, number]; // R,G,B rep
}

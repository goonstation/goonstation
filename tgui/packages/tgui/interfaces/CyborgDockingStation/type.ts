/**
 * @file
 * @copyright 2022
 * @author glowbold (https://github.com/pgmzeta)
 * @license ISC
 */

export interface CyborgDockingStationData {
  occupant?: OccupantData,

  disabled: boolean;
  viewer_is_occupant: boolean;
  viewer_is_robot: boolean;
  allow_self_service: boolean,
  conversion_chamber: boolean,

  cabling: number,
  fuel: number,

  cells?: Array<PowerCellData>,
  modules?: Array<ModuleData>,
  upgrades?: Array<UpgradeData>,
  clothes?: Array<ClothingData>,
}

interface OccupantData {
  name: string,
  kind: string,
}

interface OccupantDataRobot extends OccupantData {
  parts?: PartListData,
  cell?: PowerCellData,
  module?: string,
  upgrades?: Array<string>,
  upgrades_max?: number,
  clothing?: Array<string>,
  cosmetics?: CyborgCosmeticsData,
}

interface OccupantDataHuman extends OccupantData {
  health: number,
  max_health: number,
}

interface OccupantDataEyebot extends OccupantData {
  health: number,
  max_health: number,
  cell?: PowerCellData,
}

interface PartListData {
  head: PartData,
  chest: PartData,
  arm_l: PartData,
  arm_r: PartData,
  leg_l: PartData,
  leg_r: PartData,
}

interface PartData {
  exists: boolean,
  max_health: number
  dmg_blunt: number,
  dmg_burn: number,
}

interface PowerCellData {
  name: string,
  ref: string,
  current: number,
  max: number,
}

interface ModuleData {
  name: string,
  ref: string,
}

interface UpgradeData {
  name: string,
  ref: string,
}

interface ClothingData {
  name: string,
  ref: string,
}

interface CyborgCosmeticsData {
  chest: string,
  head: string,
  arms: string,
  legs: string,
  paint: string, // hex colour rep
  fx: Array<number>, // R,G,B rep
}

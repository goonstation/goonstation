/**
 * @file
 * @copyright 2023
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { BooleanLike } from 'common/react';
import type { ApcData, ApcInterfaceData, ApcAccessPanelData } from './types';
import { InterfaceType } from './types';

export const formatWatts = (watts: number | undefined) => `${isNaN(watts) ? 0 : Math.floor(watts)} W`;

export const getHasPermission = ({ is_ai, is_silicon, can_access_remotely, aidisabled, locked }: ApcData) => (
  (is_ai || is_silicon || can_access_remotely) ? !aidisabled : !locked
);

export const getIsAccessPanelVisible = ({ is_ai, wiresexposed }: ApcAccessPanelData) => !!wiresexposed && !is_ai;

const localInterfaceTypes = [InterfaceType.LocalOnly, InterfaceType.LocalAndNetwork];
export const getIsLocalAccess = ({ can_access_remotely, setup_networkapc }: ApcInterfaceData) => (
  localInterfaceTypes.includes(setup_networkapc) && !can_access_remotely
);

const sectionVerticalMargin = 6;
const titleHeight = 32;

const calculateMainSectionHeight = (area_requires_power: BooleanLike, isLocalAccess: boolean) => (
  (
    area_requires_power
      ? (isLocalAccess ? 181 : 132)
      : 62
  ) + sectionVerticalMargin
);

export const calculateWindowHeight = (
  area_requires_power: BooleanLike,
  showCoverLock: boolean,
  showPowerChannel: boolean,
  showOverload: boolean,
  showAccessPanel: boolean,
  isLocalAccess: boolean,
) => {
  const mainSectionHeight = calculateMainSectionHeight(area_requires_power, isLocalAccess);
  const powerChannelHeight = 130 + sectionVerticalMargin;
  const coverLockHeight = 36 + sectionVerticalMargin;
  const overloadHeight = 36 + sectionVerticalMargin;
  const accessPanelHeight = 248 + sectionVerticalMargin;
  return (
    titleHeight
    + mainSectionHeight
    + (showPowerChannel ? powerChannelHeight : 0)
    + (showCoverLock ? coverLockHeight : 0)
    + (showOverload ? overloadHeight : 0)
    + (showAccessPanel ? accessPanelHeight : 0)
    + (2 * sectionVerticalMargin)
  );
};

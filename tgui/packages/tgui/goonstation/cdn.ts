/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license ISC
 */

import { useBackend } from '../backend';

interface CDNData {
  cdn: string;
  VCS_REVISION: string;
}

export const resource = (file: string): string => {
  const { data } = useBackend<CDNData>();
  const { cdn, VCS_REVISION } = data;
  if (cdn) {
    return `${cdn}/${file}?v=${VCS_REVISION}`;
  } else {
    const parts = file.split('/');
    return parts[parts.length - 1];
  }
};

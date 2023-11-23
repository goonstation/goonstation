/**
 * @file
 * @copyright 2023
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { useBackend } from '../../backend';
import { BanPanelAction, BanPanelTab } from './type';
import type { BanPanelData } from './type';

export const useBanPanelBackend = (context) => {
  const { act, data } = useBackend<BanPanelData>(context);
  const action = {
    searchBans: (filters?: object) => act(BanPanelAction.SearchBans, { filters }),
    setTab: (value: BanPanelTab) => act(BanPanelAction.SetTab, { value }),
  };
  return {
    action,
    data,
  };
};

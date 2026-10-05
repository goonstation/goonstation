/**
 * @file
 * @copyright 2026
 * @author JORJ949 (https://github.com/JORJ949)
 * @license MIT
 */

import { SupplyConsoleMenu } from './MenuLayout';
import { SupplyConsoleTabKeys } from './type';

const shown_tabs = [
  SupplyConsoleTabKeys.Requests,
  SupplyConsoleTabKeys.Supplies,
  SupplyConsoleTabKeys.History,
  SupplyConsoleTabKeys.Market,
  SupplyConsoleTabKeys.Traders,
  SupplyConsoleTabKeys.Requisitions,
];

export const SupplyConsole = () => {
  return (
    <SupplyConsoleMenu
      see_rockbox
      see_account={false}
      can_accept_orders
      shown_tabs={shown_tabs}
    />
  );
};

export { SupplyConsoleMenu, SupplyConsoleTabKeys };

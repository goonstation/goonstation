/**
 * @file
 * @copyright 2026
 * @author JORJ949 (https://github.com/JORJ949)
 * @license MIT
 */
import { SupplyConsoleMenu, SupplyConsoleTabKeys } from './SupplyConsole';

const shown_tabs = [
  SupplyConsoleTabKeys.Requests,
  SupplyConsoleTabKeys.Supplies,
];

export const SupplyRequestConsole = () => {
  return (
    <SupplyConsoleMenu
      see_rockbox={false}
      see_account
      can_accept_orders={false}
      shown_tabs={shown_tabs}
    />
  );
};

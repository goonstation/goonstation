/**
 * @file
 * @copyright 2026
 * @author JORJ949 (https://github.com/JORJ949)
 * @license MIT
 */
import { ConsoleMenu } from './SupplyConsole/index';
import { SupplyConsoleTabKeys } from './SupplyConsole/type';

export const SupplyRequestConsole = () => {
  return (
    <ConsoleMenu
      see_rockbox={false}
      see_account
      shown_tabs={[
        SupplyConsoleTabKeys.Requests,
        SupplyConsoleTabKeys.Supplies,
      ]}
    />
  );
};

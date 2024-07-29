/**
 * @file
 * @copyright 2022
 * @author glowbold (https://github.com/pgmzeta)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { ProgressBar, Tooltip } from 'tgui-core/components';

import type { PowerCellData } from './type';

interface CellChargeBarProps {
  cell: PowerCellData;
}

export const CellChargeBar = (props: CellChargeBarProps) => {
  const { cell } = props;
  const charge = cell.current / cell.max;
  return (
    <Tooltip
      position="bottom"
      content={Math.floor(cell.current) + '/' + cell.max}
    >
      <ProgressBar
        position="relative"
        value={charge}
        ranges={{
          good: [0.5, Infinity],
          average: [0.25, 0.5],
          bad: [-Infinity, 0.25],
        }}
      >
        {Math.floor(charge * 100)}%
      </ProgressBar>
    </Tooltip>
  );
};

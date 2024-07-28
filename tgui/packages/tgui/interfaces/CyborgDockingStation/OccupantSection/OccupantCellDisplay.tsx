/**
 * @file
 * @copyright 2022
 * @author glowbold (https://github.com/pgmzeta)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Box, LabeledList } from 'tgui-core/components';

import { CellChargeBar } from '../CellChargeBar';
import { DockingAllowedButton } from '../DockingAllowedButton';
import type { PowerCellData } from '../type';

interface OccupantCellDisplayProps {
  cell: PowerCellData | undefined;
  onRemoveCell: () => void;
}

export const OccupantCellDisplay = (props: OccupantCellDisplayProps) => {
  const { cell, onRemoveCell } = props;
  return (
    <LabeledList.Item
      label="Power Cell"
      color={cell ? 'white' : 'red'}
      buttons={
        <DockingAllowedButton
          onClick={onRemoveCell}
          icon="minus"
          tooltip="Remove the occupant's power cell"
          disabled={!cell}
        />
      }
    >
      {cell ? (
        <CellChargeBar cell={cell} />
      ) : (
        <Box bold>No Power Cell Installed</Box>
      )}
    </LabeledList.Item>
  );
};

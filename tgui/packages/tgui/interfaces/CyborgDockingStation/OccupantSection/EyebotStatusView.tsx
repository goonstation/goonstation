/**
 * @file
 * @copyright 2022
 * @author glowbold (https://github.com/pgmzeta)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { LabeledList } from 'tgui-core/components';

import { CellChargeBar } from '../CellChargeBar';
import { OccupantDataEyebot } from '../type';

interface EyebotStatusViewProps {
  occupant: OccupantDataEyebot;
}

export const EyebotStatusView = (props: EyebotStatusViewProps) => {
  const { occupant } = props;
  return (
    <LabeledList>
      <LabeledList.Item label={occupant.cell.name}>
        <CellChargeBar cell={occupant.cell} />
      </LabeledList.Item>
    </LabeledList>
  );
};

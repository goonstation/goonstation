/**
 * @file
 * @copyright 2022
 * @author glowbold (https://github.com/pgmzeta)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { LabeledList, ProgressBar } from 'tgui-core/components';

import { OccupantDataHuman } from '../type';

interface HumanStatusViewProps {
  occupant: OccupantDataHuman;
}

export const HumanStatusView = (props: HumanStatusViewProps) => {
  const { occupant } = props;
  const { health, max_health } = occupant;
  return (
    <LabeledList>
      <LabeledList.Item label="Converting">
        <ProgressBar
          value={(max_health - health) / max_health}
          ranges={{
            good: [0.5, Infinity],
            average: [0.25, 0.5],
            bad: [-Infinity, 0.25],
          }}
        >
          {Math.floor(((max_health - health) / max_health) * 100)}%
        </ProgressBar>
      </LabeledList.Item>
    </LabeledList>
  );
};

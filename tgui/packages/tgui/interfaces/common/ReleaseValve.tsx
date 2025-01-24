/**
 * @file
 * @copyright 2020
 * @author PrimeNumb (https://github.com/primenumb)
 * @license MIT
 */

import { Button, LabeledList, NumberInput } from 'tgui-core/components';

export const ReleaseValve = (props) => {
  const {
    valveIsOpen,
    releasePressure = 0,
    minRelease = 0,
    maxRelease = 0,
    onToggleValve,
    onSetPressure,
  } = props;

  return (
    <LabeledList>
      <LabeledList.Item label="Release valve">
        <Button
          color={valveIsOpen ? 'average' : 'default'}
          onClick={onToggleValve}
        >
          {valveIsOpen ? 'Open' : 'Closed'}
        </Button>
      </LabeledList.Item>
      <LabeledList.Item label="Release pressure">
        <Button onClick={() => onSetPressure(minRelease)}>Min</Button>
        <NumberInput
          animated
          width="7em"
          value={releasePressure}
          minValue={minRelease}
          maxValue={maxRelease}
          step={1}
          onChange={(targetPressure) => onSetPressure(targetPressure)}
        />
        <Button onClick={() => onSetPressure(maxRelease)}>Max</Button>
      </LabeledList.Item>
    </LabeledList>
  );
};

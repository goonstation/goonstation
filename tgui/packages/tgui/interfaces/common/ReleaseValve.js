/**
* @file
* @copyright 2020
* @author PrimeNumb (https://github.com/primenumb)
* @license MIT
*/

import { NumberInput, LabeledList, Button } from '../../components';

export const ReleaseValve = props => {

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
          content={valveIsOpen ? 'Open' : 'Closed'}
          color={valveIsOpen ? 'average' : 'default'}
          onClick={onToggleValve} />
      </LabeledList.Item>
      <LabeledList.Item label="Release pressure">
        <Button
          onClick={() => onSetPressure(minRelease)}
          content="Min" />
        <NumberInput
          animated
          width="7em"
          value={releasePressure}
          minValue={minRelease}
          maxValue={maxRelease}
          onChange={(e, targetPressure) => onSetPressure(targetPressure)} />
        <Button
          onClick={() => onSetPressure(maxRelease)}
          content="Max" />
      </LabeledList.Item>
    </LabeledList>
  );

};

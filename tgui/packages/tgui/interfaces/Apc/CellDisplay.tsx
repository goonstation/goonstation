/**
 * @file
 * @copyright 2022-2023
 * @author Original 56Kyle (https://github.com/56Kyle)
 * @author Changes Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import { useBackend } from '../../backend';
import { Button, LabeledList, ProgressBar } from '../../components';
import type { ApcData } from './types';
import { getHasPermission } from './util';

const CHARGE_MODE_OFF = 0;
const CHARGE_MODE_AUTO = 1;

const getChargingStatusText = (charging, chargecount) => {
  switch (charging) {
    case 0:
      return chargecount ? 'Performing self-test' : 'Not charging';
    case 1:
      return 'Fully Charged';
    default:
      return 'Charging';
  }
};

export const CellDisplay = (_props, context) => {
  const { act, data } = useBackend<ApcData>(context);
  const {
    cell_percent,
    cell_present,
    chargecount,
    chargemode,
    charging,
  } = data;
  const hasPermission = getHasPermission(data);
  const chargingStatusText = getChargingStatusText(charging, chargecount);
  const buildChargeModeChangeHandler = (chargemode) => () => act('onChargeModeChange', { chargemode });
  return (
    <>
      <LabeledList.Item
        label="Charging"
        textAlign="right"
        buttons={
          <>
            <Button
              onClick={buildChargeModeChangeHandler(CHARGE_MODE_OFF)}
              disabled={!hasPermission && (chargemode !== CHARGE_MODE_OFF)}
              selected={chargemode === CHARGE_MODE_OFF}
            >
              Off
            </Button>
            <Button
              onClick={buildChargeModeChangeHandler(CHARGE_MODE_AUTO)}
              disabled={!hasPermission && (chargemode !== CHARGE_MODE_AUTO)}
              selected={chargemode === CHARGE_MODE_AUTO}
            >
              Auto
            </Button>
          </>
        }
      >
        ({cell_present ? chargingStatusText : 'Not Connected'})
      </LabeledList.Item>
      <LabeledList.Item label="Cell Power" verticalAlign="middle">
        <ProgressBar
          value={cell_percent}
          minValue={0}
          maxValue={100}
          color={cell_percent < 20 ? 'red' : cell_percent < 50 ? 'yellow' : 'green'}
        />
      </LabeledList.Item>
    </>
  );
};

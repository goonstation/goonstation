/**
 * @file
 * @copyright 2022
 * @author cringe (https://github.com/Laboredih123)
 * @license MIT
 */

import {
  Button,
  Divider,
  LabeledList,
  NumberInput,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { PortableBasicInfo, PortableHoldingTank } from './common/PortableAtmos';

interface PortablePumpData {
  connected;
  direction_out;
  holding;
  maxPressure;
  maxRelease;
  minRelease;
  on;
  pressure;
  targetPressure;
}

export const PortablePump = () => {
  const { act, data } = useBackend<PortablePumpData>();

  const {
    connected,
    on,
    direction_out,
    holding,
    pressure,
    targetPressure,
    maxPressure,
    minRelease,
    maxRelease,
  } = data;

  return (
    <Window width={305} height={365}>
      <Window.Content>
        <PortableBasicInfo
          connected={connected}
          pressure={pressure}
          maxPressure={maxPressure}
        >
          <Divider />
          <LabeledList>
            <LabeledList.Item label="Pump Power">
              <Button
                color={on ? 'average' : 'default'}
                onClick={() => act('toggle-power')}
              >
                {on ? 'On' : 'Off'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Target Pressure">
              <Button
                onClick={() =>
                  act('set-pressure', { targetPressure: minRelease })
                }
              >
                Min
              </Button>
              <NumberInput
                animated
                width="7em"
                value={targetPressure}
                minValue={minRelease}
                maxValue={maxRelease}
                step={1}
                onChange={(newTargetPressure) =>
                  act('set-pressure', { targetPressure: newTargetPressure })
                }
              />
              <Button
                onClick={() =>
                  act('set-pressure', { targetPressure: maxRelease })
                }
              >
                Max
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Pump Direction">
              <Button
                color={direction_out ? 'yellow' : 'blue'}
                onClick={() => act('toggle-pump')}
              >
                {direction_out ? 'Out' : 'In'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </PortableBasicInfo>
        <PortableHoldingTank
          holding={holding}
          onEjectTank={() => act('eject-tank')}
        />
      </Window.Content>
    </Window>
  );
};

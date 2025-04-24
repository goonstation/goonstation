/**
 * @file
 * @copyright 2020
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import {
  Box,
  Button,
  Knob,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { formatMoney, formatPower, formatSiUnit } from '../format';
import { Window } from '../layouts';

interface PowerTransmissionLaserData {
  capacity;
  charge;
  excessPower;
  gridLoad;
  inputLevel;
  inputMultiplier;
  inputNumber;
  isCharging;
  isChargingEnabled;
  isEmagged;
  isFiring;
  isLaserEnabled;
  lifetimeEarnings;
  name;
  outputLevel;
  outputMultiplier;
  outputNumber;
  storedBalance;
  totalGridPower;
}

export const PowerTransmissionLaser = () => {
  const { data } = useBackend<PowerTransmissionLaserData>();
  const { storedBalance, name = 'Power Transmission Laser' } = data;
  return (
    <Window title={name} width={310} height={485}>
      <Window.Content>
        <Status />
        <InputControls />
        <OutputControls />
        <NoticeBox success>
          Stored Credits : {formatMoney(storedBalance)}⪽
        </NoticeBox>
      </Window.Content>
    </Window>
  );
};

const Status = () => {
  const { data } = useBackend<PowerTransmissionLaserData>();
  const { capacity, charge, gridLoad, totalGridPower } = data;

  return (
    <Section title="Status">
      <LabeledList>
        <LabeledList.Item label="Reserve Power">
          {formatSiUnit(charge, 0, 'J')}
        </LabeledList.Item>
      </LabeledList>
      <ProgressBar
        mt="0.5em"
        mb="0.5em"
        ranges={{
          good: [0.8, Infinity],
          average: [0.5, 0.8],
          bad: [-Infinity, 0.5],
        }}
        value={charge / capacity}
      />
      <LabeledList>
        <LabeledList.Item label="Grid Saturation" />
      </LabeledList>
      <ProgressBar
        mt="0.5em"
        ranges={{
          good: [0.8, Infinity],
          average: [0.5, 0.8],
          bad: [-Infinity, 0.5],
        }}
        value={totalGridPower ? gridLoad / totalGridPower : 0}
      />
    </Section>
  );
};

const InputControls = (props, context) => {
  const { act, data } = useBackend<PowerTransmissionLaserData>();
  const {
    isChargingEnabled,
    excessPower,
    isCharging,
    inputLevel,
    inputNumber,
    inputMultiplier,
  } = data;

  return (
    <Section title="Input Controls">
      <LabeledList>
        <LabeledList.Item
          label="Input Circuit"
          buttons={
            <Button
              icon="power-off"
              color={isChargingEnabled ? 'green' : 'red'}
              onClick={() => act('toggleInput')}
            >
              {isChargingEnabled ? 'Enabled' : 'Disabled'}
            </Button>
          }
        >
          <Box
            color={
              (isCharging && 'good') ||
              (isChargingEnabled && 'average') ||
              'bad'
            }
          >
            {(isCharging && 'Online') ||
              (isChargingEnabled && 'Idle') ||
              'Offline'}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Input Level">
          {formatPower(inputLevel)}
        </LabeledList.Item>
        <LabeledList.Item label="Optimal">
          {formatPower(excessPower)}
        </LabeledList.Item>
      </LabeledList>
      <Box mt="0.5em">
        <Knob
          mr="0.5em"
          animated
          size={1.25}
          inline
          step={5}
          stepPixelSize={2}
          minValue={0}
          maxValue={999}
          value={inputNumber}
          onDrag={(e, setInput) => act('setInput', { setInput })}
        />
        <Button selected={inputMultiplier === 1} onClick={() => act('inputW')}>
          W
        </Button>
        <Button
          selected={inputMultiplier === 10 ** 3}
          onClick={() => act('inputkW')}
        >
          kW
        </Button>
        <Button
          selected={inputMultiplier === 10 ** 6}
          onClick={() => act('inputMW')}
        >
          MW
        </Button>
        <Button
          selected={inputMultiplier === 10 ** 9}
          onClick={() => act('inputGW')}
        >
          GW
        </Button>
        <Button
          selected={inputMultiplier === 10 ** 12}
          onClick={() => act('inputTW')}
        >
          TW
        </Button>
      </Box>
    </Section>
  );
};

const OutputControls = () => {
  const { act, data } = useBackend<PowerTransmissionLaserData>();
  const {
    isEmagged,
    isFiring,
    isLaserEnabled,
    outputLevel,
    outputNumber,
    outputMultiplier,
  } = data;

  return (
    <Section title="Output Controls">
      <LabeledList>
        <LabeledList.Item
          label="Laser Circuit"
          buttons={
            <Button
              icon="power-off"
              color={isLaserEnabled ? 'green' : 'red'}
              onClick={() => act('toggleOutput')}
            >
              {isLaserEnabled ? 'Enabled' : 'Disabled'}
            </Button>
          }
        >
          <Box
            color={
              (isFiring && 'good') || (isLaserEnabled && 'average') || 'bad'
            }
          >
            {(isFiring && 'Online') || (isLaserEnabled && 'Idle') || 'Offline'}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Output Level">
          {outputNumber < 0
            ? '-' + formatPower(Math.abs(outputLevel))
            : formatPower(outputLevel)}
        </LabeledList.Item>
      </LabeledList>
      <Box mt="0.5em">
        <Knob
          mr="0.5em"
          size={1.25}
          animated
          inline
          step={5}
          stepPixelSize={2}
          minValue={isEmagged ? -999 : 0}
          maxValue={isEmagged ? 0 : 999}
          ranges={{ bad: [-Infinity, -1] }}
          value={outputNumber}
          onDrag={(e, setOutput) => act('setOutput', { setOutput })}
        />
        <Button
          selected={outputMultiplier === 10 ** 6}
          onClick={() => act('outputMW')}
        >
          MW
        </Button>
        <Button
          selected={outputMultiplier === 10 ** 9}
          onClick={() => act('outputGW')}
        >
          GW
        </Button>
        <Button
          selected={outputMultiplier === 10 ** 12}
          onClick={() => act('outputTW')}
        >
          TW
        </Button>
      </Box>
    </Section>
  );
};

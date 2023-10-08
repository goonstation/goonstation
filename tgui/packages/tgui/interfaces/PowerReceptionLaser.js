/**
 * @file
 * @copyright 2023
 * @author Azrun (https://github.com/Azrun)
 * @license ISC
 */

import { useBackend } from '../backend';
import { Box, Button, Knob, LabeledList, NoticeBox, ProgressBar, Section } from '../components';
import { formatMoney, formatPower, formatSiUnit } from '../format';
import { Window } from '../layouts';

export const PowerReceptionLaser = (props, context) => {
  const { data } = useBackend(context);
  const {
    lifetimeSpending,
    name = 'Power Reception Laser',
  } = data;
  return (
    <Window
      title={name}
      width="310"
      height="530">
      <Window.Content>
        <Status />
        <InputControls />
        <OutputControls />
        <NoticeBox success>
          Credits Spent : {formatMoney(lifetimeSpending)}
        </NoticeBox>
      </Window.Content>
    </Window>
  );
};

const Status = (props, context) => {
  const { data } = useBackend(context);
  const {
    capacity,
    charge,
    stationBudget,
    powerCost,
    procsPerSecond,
  } = data;

  return (
    <Section title="Status">
      <LabeledList>
        <LabeledList.Item
          label="Reserve Power" >
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
        value={charge / capacity} />
      <LabeledList>
        <LabeledList.Item label="Available Funds">
          {stationBudget + "⪽"}

        </LabeledList.Item>
        <LabeledList.Item label="Power Cost">
          {(powerCost) + "⪽"}

        </LabeledList.Item>
        <LabeledList.Item label="Forecasted Cost">
          {(powerCost*60) + "⪽"}

        </LabeledList.Item>
      </LabeledList>
      <ProgressBar
        mt="0.5em"
        ranges={{
          good: [-Infinity, 0.1],
          average: [0.1, 0.3],
          bad: [0.3, Infinity],
        }}
        value={(powerCost*60)/stationBudget} />
    </Section>
  );
};

const OutputControls = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    isChargingEnabled,
    isCharging,
    isEmagged,
    gridLoad,
    outputLevel,
    outputNumber,
    outputMultiplier,
  } = data;

  return (
    <Section title="Output Controls">
      <LabeledList>
        <LabeledList.Item
          label="Output Circuit"
          buttons={
            <Button
              icon="power-off"
              content={isChargingEnabled ? 'Enabled' : 'Disabled'}
              color={isChargingEnabled ? 'green' : 'red'}
              onClick={() => act('toggleOutput')} />
          } >
          <Box
            color={(isCharging && 'good')
              || (isChargingEnabled && 'average')
              || 'bad'}>
            {(isCharging && 'Online')
              || (isChargingEnabled && 'Idle')
              || 'Offline'}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item
          label="Output Level" >
          {formatPower(outputLevel)}
        </LabeledList.Item>
        <LabeledList.Item
          label="Grid Load" >
          {formatPower(gridLoad)}
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
          value={outputNumber}
          onDrag={(e, setOutput) => act('setOutput', { setOutput })} />
        <Button
          content={'W'}
          selected={outputMultiplier===1}
          onClick={() => act('outputW')} />
        <Button
          content={'kW'}
          selected={outputMultiplier===10**3}
          onClick={() => act('outputkW')} />
        <Button
          content={'MW'}
          selected={outputMultiplier===10**6}
          onClick={() => act('outputMW')} />
        {!!isEmagged && (
          <>
            <Button
              content={'GW'}
              selected={outputMultiplier===10**9}
              onClick={() => act('outputGW')} />
            <Button
              content={'TW'}
              selected={outputMultiplier===10**12}
              onClick={() => act('outputTW')} />
          </>
        )}
      </Box>
    </Section>
  );
};

const InputControls = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    isEmagged,
    isFiring,
    isLaserEnabled,
    inputLevel,
    inputNumber,
    inputMultiplier,
  } = data;

  return (
    <Section title="Input Controls">
      <LabeledList>
        <LabeledList.Item label="Laser Circuit"
          buttons={
            <Button
              icon="power-off"
              content={isLaserEnabled ? 'Enabled' : 'Disabled'}
              color={isLaserEnabled ? 'green' : 'red'}
              onClick={() => act('toggleInput')} />
          } >
          <Box
            color={(isFiring && 'good')
              || (isLaserEnabled && 'average')
              || 'bad'}>
            {(isFiring && 'Online')
              || (isLaserEnabled && 'Idle')
              || 'Offline'}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Input Level">
          {inputNumber < 0 ? '-' + formatPower(Math.abs(inputLevel))
            : formatPower(inputLevel)}
        </LabeledList.Item>
      </LabeledList>
      <Box mt="0.5em">
        <Knob
          mr="0.5em"
          size={1.25}
          animated
          bipolar={isEmagged}
          inline
          step={5}
          stepPixelSize={2}
          minValue={isEmagged ? -999 : 0}
          maxValue={999}
          ranges={{ bad: [-Infinity, -1] }}
          value={inputNumber}
          onDrag={(e, setInput) => act('setInput', { setInput })} />
        <Button
          content={'W'}
          selected={inputMultiplier===1}
          onClick={() => act('inputW')} />
        <Button
          content={'kW'}
          selected={inputMultiplier===10**3}
          onClick={() => act('inputkW')} />
        <Button
          content={'MW'}
          selected={inputMultiplier===10**6}
          onClick={() => act('inputMW')} />
        {!!isEmagged && (
          <>
            <Button
              content={'GW'}
              selected={inputMultiplier===10**9}
              onClick={() => act('inputGW')} />
            <Button
              content={'TW'}
              selected={inputMultiplier===10**12}
              onClick={() => act('inputTW')} />
          </>
        )}
      </Box>
    </Section>
  );
};

/**
 * @file
 * @copyright 2020
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { useBackend } from '../backend';
import { Box, Button, ColorBox, Divider, Knob, LabeledList, NoticeBox, ProgressBar, Section } from '../components';
import { formatMoney, formatPower, formatSiUnit } from '../format';
import { Window } from '../layouts';

export const PowerTransmissionLaser = (props, context) => {
  const { data } = useBackend(context);
  const {
    lifetimeEarnings,
    name = 'Power Transmission Laser',
  } = data;
  return (
    <Window
      title={name}
      width="310"
      height="485">
      <Window.Content>
        <Status />
        <InputControls />
        <OutputControls />
        <NoticeBox success>
          Earned Credits : {formatMoney(lifetimeEarnings)}
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
    gridLoad,
    totalGridPower,
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
        <LabeledList.Item label="Grid Saturation" />
      </LabeledList>
      <ProgressBar
        mt="0.5em"
        ranges={{
          good: [0.8, Infinity],
          average: [0.5, 0.8],
          bad: [-Infinity, 0.5],
        }}
        value={gridLoad / totalGridPower} />
    </Section>
  );
};

const InputControls = (props, context) => {
  const { act, data } = useBackend(context);
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
              content={isChargingEnabled ? 'Enabled' : 'Disabled'}
              color={isChargingEnabled ? 'green' : 'red'}
              onClick={() => act('toggleInput')} />
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
          label="Input Level" >
          {formatPower(inputLevel)}
        </LabeledList.Item>
        <LabeledList.Item
          label="Optimal" >
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
        <Button
          content={'GW'}
          selected={inputMultiplier===10**9}
          onClick={() => act('inputGW')} />
        <Button
          content={'TW'}
          selected={inputMultiplier===10**12}
          onClick={() => act('inputTW')} />
      </Box>
    </Section>
  );
};

const OutputControls = (props, context) => {
  const { act, data } = useBackend(context);
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
        <LabeledList.Item label="Laser Circuit"
          buttons={
            <Button
              icon="power-off"
              content={isLaserEnabled ? 'Enabled' : 'Disabled'}
              color={isLaserEnabled ? 'green' : 'red'}
              onClick={() => act('toggleOutput')} />
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
        <LabeledList.Item label="Output Level">
          {outputNumber < 0 ? '-' + formatPower(Math.abs(outputLevel))
            : formatPower(outputLevel)}
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
          value={outputNumber}
          onDrag={(e, setOutput) => act('setOutput', { setOutput })} />
        <Button
          content={'MW'}
          selected={outputMultiplier===10**6}
          onClick={() => act('outputMW')} />
        <Button
          content={'GW'}
          selected={outputMultiplier===10**9}
          onClick={() => act('outputGW')} />
        <Button
          content={'TW'}
          selected={outputMultiplier===10**12}
          onClick={() => act('outputTW')} />
      </Box>
    </Section>
  );
};

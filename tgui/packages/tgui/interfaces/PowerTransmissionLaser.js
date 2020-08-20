import { useBackend } from '../backend';
import { Box, Button, ColorBox, Divider, Knob, LabeledList, NoticeBox, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

export const PowerTransmissionLaser = (props, context) => {
  const { data } = useBackend(context);
  // Extract `health` and `color` variables from the `data` object.
  const {
    lifetimeEarnings,
    name,
  } = data;
  return (
    <Window
      title={name}
      width="310"
      height="565">
      <Window.Content>
        <Status />
        <InputControls />
        <OutputControls />
        <NoticeBox success>
          Earned Credits : {Math.floor(lifetimeEarnings)} Credits
        </NoticeBox>
      </Window.Content>
    </Window>
  );
};

const Status = (props, context) => {
  const { data } = useBackend(context);
  const {
    charge,
    excessPower,
    gridLoad,
    inputLevel,
    isCharging,
    isFiring,
    outputLevel,
    totalGridPower,
  } = data;

  return (
    <Section title="Status">
      <LabeledList>
        <LabeledList.Item
          label="Stored Capacity"
          labelColor="white"
          textAlign="right">
          {charge}J
        </LabeledList.Item>
        <LabeledList.Item
          label="Current Input Setting"
          labelColor="white"
          textAlign="right">
          {inputLevel}W
        </LabeledList.Item>
        <LabeledList.Item
          label="Optimal Input Setting"
          labelColor="white"
          textAlign="right">
          {excessPower}W
        </LabeledList.Item>
        <LabeledList.Item
          label="Charging Status"
          labelColor="white"
          textAlign="right">
          {isCharging ? "Online " : "Offline "}
          <ColorBox
            color={isCharging ? "green" : "red"} />
        </LabeledList.Item>
      </LabeledList>
      <Divider />
      <Box mb="0.5em"
        bold>
        Power Grid Saturation
      </Box>
      <ProgressBar
        ranges={{
          good: [0.8, Infinity],
          average: [0.5, 0.8],
          bad: [-Infinity, 0.5],
        }}
        value={gridLoad / totalGridPower} />
      <Divider />
      <LabeledList>
        <LabeledList.Item
          label="Current Output Setting"
          labelColor="white"
          textAlign="right">
          {outputLevel}W
        </LabeledList.Item>
        <LabeledList.Item
          label="Laser Status"
          labelColor="white"
          textAlign="right">
          {isFiring ? "Online " : "Offline "}
          <ColorBox
            color={isFiring ? "green" : "red"} />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const InputControls = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    chargingEnabled,
    inputLevel,
    inputNumber,
    inputMultiplier,
  } = data;

  return (
    <Section title="Input Controls">
      <Box mb="0.5em">
        <strong>Charging Circuit </strong>
        <Button
          icon="power-off"
          content={chargingEnabled ? "Enabled" : "Disabled"}
          color={chargingEnabled ? "green" : "red"}
          onClick={() => act('toggleInput')} />
      </Box>
      <Box mb="0.5em">
        <strong>Input Level : {inputLevel}W</strong>
      </Box>
      <Box mb="0.5em">
        <Knob
          mr="0.5em"
          animated
          inline
          minValue={1}
          maxValue={999}
          value={inputNumber}
          onDrag={(e, setInput) => act('setInput', { setInput })} />
        <Button
          content={"W"}
          selected={inputMultiplier===1}
          onClick={() => act('inputW')} />
        <Button
          content={"kW"}
          selected={inputMultiplier===10**3}
          onClick={() => act('inputkW')} />
        <Button
          content={"MW"}
          selected={inputMultiplier===10**6}
          onClick={() => act('inputMW')} />
        <Button
          content={"GW"}
          selected={inputMultiplier===10**9}
          onClick={() => act('inputGW')} />
        <Button
          content={"TW"}
          selected={inputMultiplier===10**12}
          onClick={() => act('inputTW')} />
      </Box>
    </Section>
  );
};

const OutputControls = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    laserEnabled,
    outputLevel,
    outputNumber,
    outputMultiplier,
  } = data;

  return (
    <Section title="Output Controls">
      <Box mb="0.5em">
        <strong>Laser Circuit </strong>
        <Button
          icon="power-off"
          content={laserEnabled ? "Enabled" : "Disabled"}
          color={laserEnabled ? "green" : "red"}
          onClick={() => act('toggleOutput')} />
      </Box>
      <Box mb="0.5em">
        <strong>Output Level : {outputLevel}W</strong>
      </Box>
      <Box mb="0.5em">
        <Knob
          mr="0.5em"
          animated
          inline
          minValue={1}
          maxValue={999}
          value={outputNumber}
          onDrag={(e, setOutput) => act('setOutput', { setOutput })} />
        <Button
          content={"MW"}
          selected={outputMultiplier===10**6}
          onClick={() => act('outputMW')} />
        <Button
          content={"GW"}
          selected={outputMultiplier===10**9}
          onClick={() => act('outputGW')} />
        <Button
          content={"TW"}
          selected={outputMultiplier===10**12}
          onClick={() => act('outputTW')} />
      </Box>
    </Section>
  );
};

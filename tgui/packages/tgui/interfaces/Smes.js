/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @author Original spookydonut (https://github.com/spookydonut)
 * @author Changes Aleksej Komarov (https://github.com/stylemistake)
 * @author Changes Sovexe (https://github.com/Sovexe)
 * @license MIT
 */

import { useBackend } from '../backend';
import { Box, Button, Flex, LabeledList, ProgressBar, Section, Slider } from '../components';
import { formatPower, formatSiUnit } from '../format';
import { Window } from '../layouts';

// Common power multiplier
const POWER_MUL = 1e3;

export const Smes = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    charge,
    capacity,
    inputAttempt,
    inputting,
    inputLevel,
    inputLevelMax,
    inputAvailable,
    outputAttempt,
    outputting,
    outputLevel,
    outputLevelMax,
  } = data;
  const inputState = (
    ((charge / capacity) >= 1 && 'good')
    || ((inputting && inputLevel) && 'average')
    || 'bad'
  );
  const outputState = (
    ((outputAttempt && outputting) && 'good')
    || (charge > 0 && 'average')
    || 'bad'
  );
  return (
    <Window
      width={340}
      height={360}>
      <Window.Content>
        <Section title="Stored Energy">
          <LabeledList>
            <LabeledList.Item
              label="Stored Energy" >
              {formatSiUnit(charge, 0, 'J')}
            </LabeledList.Item>
          </LabeledList>
          <ProgressBar
            mt="0.5em"
            value={charge / capacity}
            ranges={{
              good: [0.5, Infinity],
              average: [0.15, 0.5],
              bad: [-Infinity, 0.15],
            }} />
        </Section>
        <Section title="Input">
          <LabeledList>
            <LabeledList.Item
              label="Charge Mode"
              buttons={
                <Button
                  icon="power-off"
                  color={inputAttempt ? "green" : "red"}
                  onClick={() => act('toggle-input')}>
                  {inputAttempt ? 'On' : 'Off'}
                </Button>
              }>
              <Box color={inputState}>
                {((charge / capacity) >= 1 && 'Fully Charged')
                  || ((inputAttempt && inputLevel && !inputting) && 'Initializing')
                  || ((inputAttempt && inputLevel && inputting) && 'Charging')
                  || ((inputAttempt && inputting) && 'Idle')
                  || 'Not Charging'}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Target Input">
              <Flex inline width="100%">
                <Flex.Item>
                  <Button
                    icon="fast-backward"
                    disabled={inputLevel === 0}
                    onClick={() => act('set-input', {
                      target: 'min',
                    })} />
                  <Button
                    icon="backward"
                    disabled={inputLevel === 0}
                    onClick={() => act('set-input', {
                      adjust: -10000,
                    })} />
                </Flex.Item>
                <Flex.Item grow={1} mx={1}>
                  <Slider
                    value={inputLevel / POWER_MUL}
                    fillValue={inputAvailable / POWER_MUL}
                    minValue={0}
                    maxValue={inputLevelMax / POWER_MUL}
                    step={5}
                    stepPixelSize={4}
                    format={value => formatPower(value * POWER_MUL, 1)}
                    onDrag={(e, value) => act('set-input', {
                      target: value * POWER_MUL,
                    })} />
                </Flex.Item>
                <Flex.Item>
                  <Button
                    icon="forward"
                    disabled={inputLevel === inputLevelMax}
                    onClick={() => act('set-input', {
                      adjust: 10000,
                    })} />
                  <Button
                    icon="fast-forward"
                    disabled={inputLevel === inputLevelMax}
                    onClick={() => act('set-input', {
                      target: 'max',
                    })} />
                </Flex.Item>
              </Flex>
            </LabeledList.Item>
            <LabeledList.Item label="Available">
              {formatPower(inputAvailable)}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Output">
          <LabeledList>
            <LabeledList.Item
              label="Output Mode"
              buttons={
                <Button
                  icon="power-off"
                  color={outputAttempt ? "green" : "red"}
                  onClick={() => act('toggle-output')}>
                  {outputAttempt ? 'On' : 'Off'}
                </Button>
              }>
              <Box color={outputState}>
                {((outputting && outputAttempt) && 'Enabled')
                  || (outputAttempt && 'Idle')
                  || (charge && 'Disabled')
                  || 'No Charge'}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Target Output">
              <Flex inline width="100%">
                <Flex.Item>
                  <Button
                    icon="fast-backward"
                    disabled={outputLevel === 0}
                    onClick={() => act('set-output', {
                      target: 'min',
                    })} />
                  <Button
                    icon="backward"
                    disabled={outputLevel === 0}
                    onClick={() => act('set-output', {
                      adjust: -10000,
                    })} />
                </Flex.Item>
                <Flex.Item grow={1} mx={1}>
                  <Slider
                    value={outputLevel / POWER_MUL}
                    minValue={0}
                    maxValue={outputLevelMax / POWER_MUL}
                    step={5}
                    stepPixelSize={4}
                    format={value => formatPower(value * POWER_MUL, 1)}
                    onDrag={(e, value) => act('set-output', {
                      target: value * POWER_MUL,
                    })} />
                </Flex.Item>
                <Flex.Item>
                  <Button
                    icon="forward"
                    disabled={outputLevel === outputLevelMax}
                    onClick={() => act('set-output', {
                      adjust: 10000,
                    })} />
                  <Button
                    icon="fast-forward"
                    disabled={outputLevel === outputLevelMax}
                    onClick={() => act('set-output', {
                      target: 'max',
                    })} />
                </Flex.Item>
              </Flex>
            </LabeledList.Item>
            <LabeledList.Item label="Outputting">
              {formatPower(outputting)}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

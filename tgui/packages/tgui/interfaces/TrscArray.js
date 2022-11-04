import { Window } from '../layouts';
import { useBackend } from "../backend";

import {
  Box,
  Button,
  Divider,
  Flex,
  Knob,
  Section,
  Image,
  ProgressBar,
} from '../components';
import { formatPower } from '../format';

export const TrscArray = (props, context) => {
  const { act, data } = useBackend(context);
  const { apcCellStat, apcCellDiff, arrayCellStat, arrayCellDiff, sendsSafe, sendsMax, failsafeThreshold,
    failsafeStat, arrayImage, arrayHealth, drawRateTarget, surplusThreshold } = data;

  const setDrawRate = (e, value) => act('set_draw_rate', { drawRateTarget: value });
  const setSurplus = (e, value) => act('set_surplus', { surplusThreshold: value });

  return (
    <Window width={400} height={550} title="Transception Systems">
      <Window.Content>
        <Section title="Array Status" textAlign="center">
          <Box>
            <Flex justify="space-around">
              <Flex.Item>
                <Flex height={21} direction="column" justify="space-around">
                  <Flex.Item>
                    <strong>Area Cell Power:</strong><br />
                    <h3>{apcCellStat}</h3>
                    <ProgressBar value={apcCellDiff} color="#f9ae00" />
                  </Flex.Item>
                  <Flex.Item>
                    <strong>Internal Capacitor:</strong><br />
                    <h3>{arrayCellStat}</h3>
                    <ProgressBar value={arrayCellDiff} color="#76B9D3" />
                  </Flex.Item>
                  <Flex.Item>
                    <strong>Transceptions Remaining<br />(Standard / Maximum)<br /></strong>
                    <h2>{sendsSafe} | {sendsMax}</h2>
                  </Flex.Item>
                </Flex>
              </Flex.Item>
              <Flex.Item backgroundColor="#A37933">
                <Box mb={1} mx={0.5} height={19} backgroundColor="#101020">
                  <Flex mx={2} my={2} height={18} direction="column" justify="space-around">
                    <Flex.Item>
                      <Image
                        pixelated
                        width="96px"
                        height="96px"
                        src={`data:image/png;base64,${arrayImage}`}
                        backgroundColor="transparent"
                      /><br />
                    </Flex.Item>
                    <Flex.Item>
                      <strong>Array Condition:</strong><br />
                      <h2>{arrayHealth}</h2>
                    </Flex.Item>
                  </Flex>
                </Box>
              </Flex.Item>
            </Flex>
          </Box>
        </Section>
        <Divider />
        <Section title="Transception Systems" textAlign="center">
          <Flex justify="space-around">
            <Flex.Item>
              <strong>Transception Capability:<br />{failsafeStat}</strong>
            </Flex.Item>
            <Flex.Item>
              <strong>Power Loss Failsafe:<br />{failsafeThreshold} | </strong>
              <Button
                content="Toggle"
                onClick={() => act('toggle_failsafe')}
              />
            </Flex.Item>
          </Flex>
        </Section>
        <Section title="Internal Capacitor Control" textAlign="center">
          <Flex justify="space-around">
            <Flex.Item>
              <strong>Target Charge Rate:<br />{formatPower(drawRateTarget)} </strong>
              <Knob
                minValue={0}
                maxValue={50000}
                step={100}
                value={drawRateTarget}
                onDrag={setDrawRate}
              />
            </Flex.Item>
            <Flex.Item>
              <strong>Required Surplus:<br />{formatPower(surplusThreshold)} </strong>
              <Knob
                minValue={10000}
                maxValue={200000}
                step={100}
                value={surplusThreshold}
                onDrag={setSurplus}
              />
            </Flex.Item>
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};


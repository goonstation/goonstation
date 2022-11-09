import { Window } from '../layouts';
import { useBackend } from "../backend";

import {
  Box,
  Button,
  Divider,
  Flex,
  Section,
  Image,
  ProgressBar,
} from '../components';

export const TrscArray = (props, context) => {
  const { act, data } = useBackend(context);
  const { cellStat, cellDiff, sendsSafe, sendsMax, failsafeThreshold, failsafeStat, arrayImage, arrayHealth } = data;
  return (
    <Window width={400} height={440} title="Transception Systems">
      <Window.Content>
        <Section title="Array Status" textAlign="center">
          <Box>
            <Flex justify="space-around">
              <Flex.Item>
                <Flex height={21} direction="column" justify="space-around">
                  <Flex.Item>
                    <strong>Area Cell Power:</strong><br />
                    <h3>{cellStat}</h3>
                    <ProgressBar value={cellDiff} color="#f9ae00" />
                  </Flex.Item>
                  <Flex.Item>
                    <strong>Transceptions Remaining<br />Within Standard Limit<br /></strong><h2>{sendsSafe}</h2>
                  </Flex.Item>
                  <Flex.Item>
                    <strong>Maximum Remaining<br />Transceptions<br /></strong><h2>{sendsMax}</h2>
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
      </Window.Content>
    </Window>
  );
};


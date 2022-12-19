/**
 * @file
 * @copyright 2022
 * @author CodeJester (https://github.com/codeJester27)
 * @license ISC
 */

import { useBackend, useLocalState } from '../backend';
import { Blink, Box, Button, Collapsible, Flex, Icon, Modal, NumberInput, ProgressBar, Section, Stack } from '../components';
import { Window } from '../layouts';
import { pluralize } from './common/stringUtils';
import { WirePanelControls } from './common/WirePanel/type';
import { WirePanelCollapsible } from './WirePanelWindow';

const DefaultSort = {
  Fruit: 1,
  Vegetable: 2,
  Herb: 3,
  Flower: 4,
  Miscellaneous: 5,
  Other: 6,
};

const categorySorter = (a, b) => (
  (DefaultSort[a.name] || DefaultSort.Other) - (DefaultSort[b.name] || DefaultSort.Other)
);

export const SeedFabricator = (_props, context) => {
  const { data } = useBackend(context);
  const { canVend, maxSeed, name, seedCount } = data;
  const categories = data.seedCategories || [];
  const isWorking = (data.wirePanel.active_wire_controls & WirePanelControls.WIRE_CONTROL_POWER_A) === 0;

  categories.sort(categorySorter);

  const [dispenseAmount, setDispenseAmount] = useLocalState(context, 'dispenseAmount', 1);

  return (
    <Window
      title={name}
      width={500}
      height={600}
    >
      <Window.Content>
        <Stack vertical width="100%">
          <Stack.Item>
            <WirePanelCollapsible
              style={data.wirePanelTheme}
              cover_status={data.wirePanel.cover_status} />
          </Stack.Item>
          <Stack.Item position="relative">
            <Section>
              <Flex>
                <Flex.Item bold pr={1}>
                  Dispense:
                </Flex.Item>
                <Flex.Item basis={6} grow>
                  <NumberInput
                    value={dispenseAmount}
                    format={value => value + pluralize(' seed', value)}
                    minValue={1}
                    maxValue={10}
                    onDrag={(_e, value) => setDispenseAmount(value)}
                  />
                </Flex.Item>
                <Flex.Item grow={2}>
                  <ProgressBar
                    value={Math.max(0, maxSeed - seedCount)}
                    maxValue={maxSeed}
                    ranges={{
                      yellow: [5, Infinity],
                      bad: [-Infinity, 5],
                    }}
                  >
                    <Icon name="bolt" />
                  </ProgressBar>
                </Flex.Item>
              </Flex>
            </Section>
            <Section>
              {!canVend && (
                <Modal textAlign="center"
                  width={25}
                  height={5}
                  fontSize={2}
                  fontFamily="Courier"
                  color="yellow">
                  <Blink interval={500} time={500}>
                    <Icon name="bolt" pr={1.5} />
                  </Blink>
                  UNIT RECHARGING
                </Modal>
              )}
              {categories.map(category => (
                <SeedCategory
                  key={category.name}
                  category={category}
                  dispenseAmount={dispenseAmount} />
              ))}
            </Section>
            { !!isWorking && (
              <Section fillPositionedParent backgroundColor="rgba(0,0,0,0.7)">
                <Box
                  verticalAlign="top"
                  textAlign="center"
                  fontSize={3}
                  pt={10}
                  pb={10}
                  pr={10}
                  pl={10}
                  fontFamily="Courier"
                  color="red"
                  position="relative"
                >
                  <Blink time={500}>
                    <Icon name="exclamation-triangle" pr={1.5} />
                    MALFUNCTION
                    <Icon name="exclamation-triangle" pl={1.5} />
                  </Blink>
                  CHECK WIRES
                </Box>
              </Section>
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const seedsSorter = (a, b) => a.name.localeCompare(b.name);

const SeedCategory = (props, context) => {
  const { act } = useBackend(context);
  const { category, dispenseAmount } = props;
  const { name, seeds } = category;

  if (!seeds) return null;

  const sortedSeeds = seeds.sort(seedsSorter);

  return (
    <Collapsible
      title={name}>
      {sortedSeeds.map(seed => (
        <Box key={seed.name} as="span">
          <Button
            width="155px"
            height="32px"
            px={0}
            m={0.25}
            onClick={() => act('disp', { path: seed.path, amount: dispenseAmount })}
          >
            <Flex direction="row" align="center">
              <Flex.Item>
                {seed.img ? (
                  <img
                    style={{
                      'vertical-align': 'middle',
                      'horizontal-align': 'middle',
                    }}
                    height="32px"
                    width="32px"
                    src={`data:image/png;base64,${seed.img}`} />
                ) : (
                  <Icon
                    style={{
                      'vertical-align': 'middle',
                      'horizontal-align': 'middle',
                    }}
                    height="32px"
                    width="32px"
                    name="question-circle-o"
                    pl="8px"
                    pt="4px"
                    fontSize="24px" />
                )}
              </Flex.Item>
              <Flex.Item
                overflow="hidden"
                style={{ 'text-overflow': 'ellipsis' }}
                title={seed.name}
              >
                {seed.name}
              </Flex.Item>
            </Flex>
          </Button>
        </Box>
      ))}
    </Collapsible>
  );
};

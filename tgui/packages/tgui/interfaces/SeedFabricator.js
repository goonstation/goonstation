import { useBackend, useLocalState } from "../backend";
import { Blink, Box, Button, Collapsible, Flex, Icon, Modal, NumberInput, ProgressBar, Section, Stack } from '../components';
import { Window } from '../layouts';
import { pluralize } from "./common/stringUtils";

const DefaultSort = {
  Fruit: 1,
  Vegetable: 2,
  Herb: 3,
  Flower: 4,
  Miscellaneous: 5,
};

const SeedsPerRow = 3;

export const SeedFabricator = (props, context) => {
  const { data } = useBackend(context);
  const { canVend, isWorking, maxSeed, name, seedCount } = data;
  const categories = data.seedCategories || [];

  categories.sort((a, b) => (
    (DefaultSort[a.name] || a.name).toString().localeCompare((DefaultSort[b.name] || b.name).toString())
  ));

  const [dispenseAmount, setDispenseAmount] = useLocalState(context, 'dispenseAmount', 1);

  return (
    <Window
      title={name}
      width={500}
      height={600}>
      <Window.Content>
        {!isWorking && (
          <Modal textAlign="center"
            width={35}
            height={10}
            fontSize={3}
            fontFamily="Courier"
            color="red">
            <Blink time={500}>
              <Icon name="exclamation-triangle" pr={1.5} />
              MALFUNCTION
              <Icon name="exclamation-triangle" pl={1.5} />
            </Blink>
            CHECK WIRES
          </Modal>
        )}
        <Section>
          <Flex>
            <Flex.Item bold pr={1}>
              Dispense:
            </Flex.Item>
            <Flex.Item basis={6} grow>
              <NumberInput
                value={dispenseAmount}
                format={value => value + pluralize(" seed", value)}
                minValue={1}
                maxValue={10}
                onDrag={(e, value) => setDispenseAmount(value)}
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
          {categories.map((category, index) => (
            <SeedCategory
              key={category.name}
              category={category}
              dispenseAmount={dispenseAmount} />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};

const SeedCategory = (props, context) => {
  const { act } = useBackend(context);
  const { category, dispenseAmount } = props;
  const { name } = category;
  const seeds = category.seeds;
  if (!seeds) return false;
  seeds.sort((a, b) => a.name.localeCompare(b.name));

  return (
    <Collapsible
      title={name}>
      <Stack vertical>
        <Box>
          {seeds.map((seed, index) => (
            <Box key={seed.name} as="span">
              <Button width="155px" height="32px" px={0} m={0.25}
                onClick={() => act('disp', { path: seed.path, amount: dispenseAmount })}>
                <Flex direction="row" align="center">
                  <Flex.Item>
                    <img
                      src={`data:image/png;base64,${seed.img}`}
                      style={{
                        'vertical-align': 'middle',
                        'horizontal-align': 'middle',
                      }}
                      height="32px"
                      width="32px" />
                  </Flex.Item>
                  <Flex.Item
                    overflow="hidden"
                    style={{ 'text-overflow': 'ellipsis' }}>
                    {seed.name}
                  </Flex.Item>
                </Flex>
              </Button>
            </Box>
          ))}
        </Box>
      </Stack>
    </Collapsible>
  );

};

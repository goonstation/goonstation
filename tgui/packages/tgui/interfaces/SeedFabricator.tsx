/**
 * @file
 * @copyright 2022
 * @author CodeJester (https://github.com/codeJester27)
 * @license ISC
 */

import { useState } from 'react';
import {
  Blink,
  Box,
  Button,
  Collapsible,
  Flex,
  Icon,
  Modal,
  NumberInput,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import { pluralize } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const DefaultSort = {
  Fruit: 1,
  Vegetable: 2,
  Herb: 3,
  Flower: 4,
  Miscellaneous: 5,
  Other: 6,
};

const categorySorter = (a, b) =>
  (DefaultSort[a.name] || DefaultSort.Other) -
  (DefaultSort[b.name] || DefaultSort.Other);

interface SeedFabricatorData {
  canVend;
  isWorking;
  maxSeed;
  name;
  seedCategories;
  seedCount;
}

export const SeedFabricator = () => {
  const { data } = useBackend<SeedFabricatorData>();
  const { canVend, isWorking, maxSeed, name, seedCount } = data;
  const categories = data.seedCategories || [];

  categories.sort(categorySorter);

  const [dispenseAmount, setDispenseAmount] = useState(1);

  return (
    <Window title={name} width={500} height={600}>
      <Window.Content>
        {!isWorking && (
          <Modal
            textAlign="center"
            width={35}
            height={10}
            fontSize={3}
            fontFamily="Courier"
            color="red"
          >
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
                format={(value) => value + pluralize(' seed', value)}
                minValue={1}
                maxValue={10}
                step={1}
                onDrag={(value) => setDispenseAmount(value)}
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
            <Modal
              textAlign="center"
              width={25}
              height={5}
              fontSize={2}
              fontFamily="Courier"
              color="yellow"
            >
              <Blink interval={500} time={500}>
                <Icon name="bolt" pr={1.5} />
              </Blink>
              UNIT RECHARGING
            </Modal>
          )}
          {categories.map((category) => (
            <SeedCategory
              key={category.name}
              category={category}
              dispenseAmount={dispenseAmount}
            />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};

const seedsSorter = (a, b) => a.name.localeCompare(b.name);

const SeedCategory = (props) => {
  const { act } = useBackend<SeedFabricatorData>();
  const { category, dispenseAmount } = props;
  const { name, seeds } = category;

  if (!seeds) return null;

  const sortedSeeds = seeds.sort(seedsSorter);

  return (
    <Collapsible title={name}>
      {sortedSeeds.map((seed) => (
        <Box key={seed.name} as="span">
          <Button
            width="155px"
            height="32px"
            px={0}
            m={0.25}
            onClick={() =>
              act('disp', { path: seed.path, amount: dispenseAmount })
            }
          >
            <Flex direction="row" align="center">
              <Flex.Item>
                {seed.img ? (
                  <img
                    style={{
                      verticalAlign: 'middle',
                    }}
                    height="32px"
                    width="32px"
                    src={`data:image/png;base64,${seed.img}`}
                  />
                ) : (
                  <Icon
                    style={{
                      verticalAlign: 'middle',
                    }}
                    height="32px"
                    width="32px"
                    name="question-circle-o"
                    pl="8px"
                    pt="4px"
                    fontSize="24px"
                  />
                )}
              </Flex.Item>
              <Flex.Item
                overflow="hidden"
                style={{ textOverflow: 'ellipsis' }}
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

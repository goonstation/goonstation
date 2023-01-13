import { useBackend } from '../../backend';
import { Box, Button, Divider, Dropdown, Flex, Section, Stack, Tabs } from '../../components';
import { Window } from '../../layouts';
import { ClothingBoothData } from './types';

import { capitalize } from '.././common/stringUtils';

export const ClothingBooth = (props, context) => {
  const { data } = useBackend<ClothingBoothData>(context);
  const { clothingbooth_list, name } = data;

  return (
    <Window title={name} width={350} height={500}>
      <Window.Content>
        <Flex fill direction="column">
          <Flex.Item mb="0.5em">
            <Section bold>
              {`Balance: 420⪽`}
            </Section>
          </Flex.Item>
          <Flex.Item>
            <Stack direction="row">
              <Stack.Item grow={1}>
                <SlotTabs />
              </Stack.Item>
              <Stack.Item grow={3}>
                <Flex fill direction="column">
                  <Flex.Item>
                    <Section>
                      <Dropdown selected="Accessories" />
                    </Section>
                  </Flex.Item>
                  <Flex.Item>
                    <Section scrollable> {/* this section has all the clothing items */}
                      {clothingbooth_list
                        .map(booth_item => {
                          const {
                            cost,
                            name,
                          } = booth_item;
                          return (
                            <ClothingBoothItem
                              key={name}
                              booth_item={booth_item}
                            />
                          );
                        })}
                    </Section>
                  </Flex.Item>
                </Flex>
              </Stack.Item>
            </Stack>
          </Flex.Item>
          <Flex.Item mt="0.5em">
            <Section fill>
              {`there's gonna be stuff here`}
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const ClothingBoothItem = (props) => {
  const {
    booth_item: {
      category,
      cost,
      img,
      name,
    },
  } = props;

  return (
    <>
      <Stack align="center">
        <Stack.Item>
          <img
            src={`data:image/png;base64,${img}`}
            style={{
              'vertical-align': 'middle',
              'horizontal-align': 'middle',
            }}
          />
        </Stack.Item>
        <Stack.Item grow={1}>
          <Box bold>
            {capitalize(name)}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Button bold color="green" style={{ "width": "50px", "text-align": "center", "padding": "0px" }}>
            {`${cost}⪽`}
          </Button>
        </Stack.Item>
      </Stack>
      <Divider />
    </>
  );
};

const SlotTabs = (props, context) => {
  return (
    <Tabs fill vertical>
      <Tabs.Tab>Head</Tabs.Tab>
      <Tabs.Tab>Eyewear</Tabs.Tab>
      <Tabs.Tab>Mask</Tabs.Tab>
      <Tabs.Tab>Gloves</Tabs.Tab>
      <Tabs.Tab>Innerwear</Tabs.Tab>
      <Tabs.Tab>Outerwear</Tabs.Tab>
    </Tabs>
  );
};

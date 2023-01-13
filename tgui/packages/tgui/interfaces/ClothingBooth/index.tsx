import { useBackend } from '../../backend';
import { Box, Button, Divider, Dropdown, Section, Stack, Tabs } from '../../components';
import { Window } from '../../layouts';
import { ClothingBoothData } from './types';

import { capitalize } from '.././common/stringUtils';

export const ClothingBooth = (props, context) => {
  const { data } = useBackend<ClothingBoothData>(context);
  const { clothingbooth_list, name } = data;

  return (
    <Window title={name} width={350} height={500}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section fill bold>
              {`Balance: 420⪽`}
            </Section>
          </Stack.Item>
          <Stack.Item grow={3}>
            <Stack fill>
              <Stack.Item>
                <SlotTabs />
              </Stack.Item>
              <Stack.Item grow={1}>
                <Stack fill vertical>
                  <Stack.Item>
                    <Section fill>
                      <Dropdown selected="Accessories" />
                    </Section>
                  </Stack.Item>
                  <Stack.Item grow={1}>
                    <Section fill scrollable> {/* this section has all the clothing items */}
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
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow={2}>
            <Section fill>
              {`there's gonna be stuff here`}
            </Section>
          </Stack.Item>
        </Stack>
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

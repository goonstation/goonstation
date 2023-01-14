import { useBackend } from '../../backend';
import { Box, Button, Divider, Dropdown, Section, Stack, Tabs } from '../../components';
import { Window } from '../../layouts';
import { ClothingBoothData, ClothingBoothListData } from './type';

import { capitalize } from '.././common/stringUtils';

export const ClothingBooth = (props, context) => {
  const { data } = useBackend<ClothingBoothData>(context);

  return (
    <Window title={data.name} width={350} height={500}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section fill bold>
              {`Balance: ${data.money}⪽`}
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
                    <Section fill scrollable>
                      {data.clothingBoothList
                        .map((booth_item) => {
                          <ClothingBoothItem key={booth_item.name} booth_item={booth_item} />;
                        })}
                    </Section>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow={2}>
            <Section fill>{`there's gonna be stuff here`}</Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type boothItemProps = {
  booth_item: ClothingBoothListData;
};

const ClothingBoothItem = ({ booth_item }: boothItemProps, context) => {
  const { data } = useBackend<ClothingBoothData>(context);

  return (
    <>
      <Stack align="center">
        <Stack.Item>
          <img
            src={`data:image/png;base64,${booth_item.img}`}
            style={{
              'vertical-align': 'middle',
              'horizontal-align': 'middle',
            }}
          />
        </Stack.Item>
        <Stack.Item grow={1}>
          <Box bold>{capitalize(booth_item.name)}</Box>
        </Stack.Item>
        <Stack.Item>
          {/* please get around to destroying this Button and replacing it with something nicer */}
          <Button bold color="green" style={{ 'width': '50px', 'text-align': 'center', 'padding': '0px' }}>
            {`${booth_item.cost}⪽`}
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

import { useBackend } from '../../backend';
import { Box, Button, Divider, Dropdown, Flex, Section, Stack, Tabs } from '../../components';
import { Fragment } from 'inferno';
import { Window } from '../../layouts';
import { ClothingBoothData } from './types';

import { capitalize } from '.././common/stringUtils';

export const ClothingBooth = (props, context) => {
  const { data } = useBackend<ClothingBoothData>(context);
  const { name } = data;

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
                    <Section fill scrollable> {/* this section has all the clothing items */}
                      <ClothingBoothItem />
                      <ClothingBoothItem />
                      <ClothingBoothItem />
                      <ClothingBoothItem />
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

const ClothingBoothItem = (props, context) => {
  return (
    <Fragment>
      <Stack align="center">
        <Stack.Item>
          <img
            src={`data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAA
            AgCAYAAABzenr0AAAAaXpUWHREZXNjcmlwdGlvbgAAeJwl x70KgCAUBtD
            Z+xQfukd/q0so4aDvIGjpUIFKvX6D2zkCm96Ng7KG3lhqfm5IrMNI7MuhJ
            UgsM7EU 85laT22+RUhwTizkUiExETuKv2K3gHYKyhr6AZq3GAuWckZCAA
            ABHElEQVRYhe2WMc8BMRzGn3uD vWkihuJtJMIikZjYbvYJfAOjL+UTWCw
            mzmg8kchR3sQidhIMlHMS0b6ooc90fZre88u//+vVqTdb MKkfo+kWwAJY
            AAvwDQAx3YXzBPfC4+w2qH4EQAYXM/Fl2PfFyVcFUQKYJ7gng32xY+G5q8
            89FQit LfDFjh3Gm1sPhEWr8oy0mrBRSy2dArmMnQJBo5ZSDgcAR/U+IHs
            gGtgerBjw5h6Qor+5fPcP+YiH 9Ww6UX2XFkByL3rlNMVosb545TRFewb2
            YNnrAKRoqeJmNkEPwA3M2wFoqeKK87Mg3AUASjgghspb oPwVZLdBtd+5D
            +p3hhOd01CrAicImDmK/xsYlfG/oQWwABbAOMARSXBakSQiLfsAAAAASUV
            ORK5C YII=`}
            style={{
              'vertical-align': 'middle',
              'horizontal-align': 'middle',
            }}
          />
        </Stack.Item>
        <Stack.Item grow={1}>
          <Box bold>
            {capitalize("Beaker")}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Button bold color="green" style={{ "width": "50px", "text-align": "center", "padding": "0px" }}>
            {`150⪽`}
          </Button>
        </Stack.Item>
      </Stack>
      <Divider />
    </Fragment>
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

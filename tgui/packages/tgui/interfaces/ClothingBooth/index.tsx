import { useBackend } from '../../backend';
import { Divider, Dropdown, Flex, Section, Stack, Tabs } from '../../components';
import { Fragment } from 'inferno';
import { Window } from '../../layouts';
import { ClothingBoothData } from './types';

export const ClothingBooth = (props, context) => {
  const { data } = useBackend<ClothingBoothData>(context);
  const { name } = data;

  return (
    <Window title={name} width={350} height={500}>
      <Window.Content>
        <Flex direction="column">
          <Flex.Item grow={3}>
            <Stack direction="row">
              <Stack.Item grow={1}>
                <SlotTabs />
              </Stack.Item>
              <Stack.Item grow={3}>
                <Stack direction="column">
                  <Stack.Item grow={1}>
                    <Section>
                      <Dropdown selected="Accessories" />
                    </Section>
                  </Stack.Item>
                  <Stack.Item grow={3}>
                    <Section>
                      <ClothingBoothItem />
                    </Section>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const ClothingBoothItem = (props, context) => {
  return (
    <Fragment>
      <Flex>
        <Flex.Item>
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
        </Flex.Item>
      </Flex>
      <Divider />
    </Fragment>
  );
};

const SlotTabs = (props, context) => {
  return (
    <Tabs vertical>
      <Tabs.Tab>Head</Tabs.Tab>
      <Tabs.Tab>Eyewear</Tabs.Tab>
      <Tabs.Tab>Mask</Tabs.Tab>
      <Tabs.Tab>Gloves</Tabs.Tab>
      <Tabs.Tab>Innerwear</Tabs.Tab>
      <Tabs.Tab>Outerwear</Tabs.Tab>
    </Tabs>
  );
};

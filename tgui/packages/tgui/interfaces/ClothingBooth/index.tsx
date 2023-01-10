import { Dropdown, Flex, Tabs } from '../../components';
import { Window } from '../../layouts';

export const ClothingBooth = (props, context) => {
  return (
    <Window title="Clothing Booth" width={350} height={500}>
      <Window.Content>
        <Flex direction="column">
          <Flex.Item grow={3}>
            <Flex direction="row">
              <Flex.Item grow={1}>
                <SlotTabs />
              </Flex.Item>
              <Flex.Item grow={3}>
                <Flex direction="column">
                  <Flex.Item grow={1}>
                    <Dropdown selected="Accessories" />
                  </Flex.Item>
                </Flex>
              </Flex.Item>
            </Flex>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const SlotTabs = (props, context) => {
  return (
    <Tabs vertical>
      <Tabs.Tab>
        Head
      </Tabs.Tab>
      <Tabs.Tab>
        Eyewear
      </Tabs.Tab>
      <Tabs.Tab>
        Mask
      </Tabs.Tab>
      <Tabs.Tab>
        Gloves
      </Tabs.Tab>
      <Tabs.Tab>
        Innerwear
      </Tabs.Tab>
      <Tabs.Tab>
        Outerwear
      </Tabs.Tab>
    </Tabs>
  );
};

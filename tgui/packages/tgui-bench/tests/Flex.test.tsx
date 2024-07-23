import { createRenderer } from 'tgui/renderer';
import { Flex } from 'tgui-core/components';

const render = createRenderer();

export const Default = () => {
  const node = (
    <Flex align="baseline">
      <Flex.Item mr={1}>Text {Math.random()}</Flex.Item>
      <Flex.Item grow={1} basis={0}>
        Text {Math.random()}
      </Flex.Item>
    </Flex>
  );
  render(node);
};

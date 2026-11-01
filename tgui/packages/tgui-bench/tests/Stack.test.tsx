import { createRenderer } from 'tgui/renderer';
import { Stack } from 'tgui-core/components';

const render = createRenderer();

export const Default = () => {
  const node = (
    <Stack align="baseline">
      <Stack.Item>Text {Math.random()}</Stack.Item>
      <Stack.Item grow={1} basis={0}>
        Text {Math.random()}
      </Stack.Item>
    </Stack>
  );
  render(node);
};

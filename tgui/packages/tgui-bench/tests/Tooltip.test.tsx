import { createRenderer } from 'tgui/renderer';
import { Box, Tooltip } from 'tgui-core/components';

const render = createRenderer();

export const ListOfTooltips = () => {
  const nodes: JSX.Element[] = [];

  for (let i = 0; i < 100; i++) {
    nodes.push(
      <Tooltip key={i} content={`This is from tooltip ${i}`} position="bottom">
        <Box as="span" backgroundColor="blue" fontSize="48px" m={1}>
          Tooltip #{i}
        </Box>
      </Tooltip>,
    );
  }

  render(<div>{nodes}</div>);
};

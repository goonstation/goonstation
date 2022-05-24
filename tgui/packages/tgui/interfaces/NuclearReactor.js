import { useBackend } from '../backend';
import { BlockQuote, Button, Collapsible, Box, Section, Table } from '../components';
import { Window } from '../layouts';
import { useLocalState } from '../backend';
import { Divider, Flex, Stack } from '../components';
import { capitalize, pluralize } from './common/stringUtils';

const ReactorComponentEntry = (props) => {
  const {
    product: {
      name,
      cost,
      img,
    },
    disabled,
    onClick,
  } = props;

  return (
    <>
      <Flex direction="row" align="center">
        <Flex.Item>
          <img
            src={`data:image/png;base64,${img}`}
            style={{
              'vertical-align': 'middle',
              'horizontal-align': 'middle',
            }}
          />
        </Flex.Item>
        <Flex.Item grow={1}>
          <Box bold>
            {capitalize(name)}
          </Box>
          <Box>
            {`Cost: ${cost} ${pluralize('Unit', cost)}`}
          </Box>
        </Flex.Item>
        <Flex.Item>
          <Button onClick={onClick} disabled={disabled}>
            Create
          </Button>
        </Flex.Item>
      </Flex>
      <Divider />
    </>
  );
};

const ReactorGrid = (shape) => {
  const {
    gridW,
    gridH,
    comps,
  } = shape;

  let rows = [];
  for (let i = 0; i < gridW; i++) {
    let cols = [];
    for (let j = 0; j < gridH; j++) {
      cols.push(
        <Table.Cell>
          <Button>EMPTY</Button>
        </Table.Cell>);
    }
    rows.push(<Table.Row>{cols}</Table.Row>);
  }
  return <Table>{rows}</Table>;
};

export const NuclearReactor = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    components,
    gridW,
    gridH,
  } = data;
  return (
    <Window
      resizable
      title="Nuclear Reactor"
      width={600}
      height={600}>
      <Window.Content>
        <Section>
          <Box >
            <ReactorGrid
              gridW={gridW}
              gridH={gridH} />
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};

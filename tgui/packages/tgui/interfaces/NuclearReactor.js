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

const ReactorRow = (shape) => {
  const {
    onClick,
    components,
    rowID,
  } = shape;
  return (
    <Table.Row>
      {components.map((c, index) => {
        if (c === null)
        {
          return (
            <Table.Cell>
              <Button
                key={name}
                fluid
                onClick={() => onClick('slot', { "x": rowID+1, "y": index+1 })}
                height={5}
                weidth={5}>
                EMPTY
              </Button>
            </Table.Cell>
          );
        }
        else
        {
          const { x, y, name, img } = c;
          return (
            <Table.Cell>
              <Button
                key={name}
                fluid
                onClick={() => onClick('slot', { "x": x, "y": y })}
                height={5}
                weidth={5}>
                <img
                  src={`data:image/png;base64,${img}`}
                  style={{
                    'vertical-align': 'middle',
                    'horizontal-align': 'middle',
                  }}
                />
              </Button>
            </Table.Cell>);
        }
      })}
    </Table.Row>
  );
};

const ReactorGrid = (shape) => {
  const {
    onClick,
    components,
  } = shape;
  return (
    <Table>
      {components.map((r, index) => { const { comp } = r;
        return (
          <Table.Row key>
            <ReactorRow rowID={index} components={r} onClick={onClick} />
          </Table.Row>
        );
      })}
    </Table>
  );
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
              gridH={gridH}
              onClick={act}
              components={components}
            />
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};

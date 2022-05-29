import { useBackend } from '../backend';
import { BlockQuote, Button, Collapsible, Box, Section, Table } from '../components';
import { Window } from '../layouts';
import { useLocalState } from '../backend';
import { Divider, Flex, Stack } from '../components';
import { capitalize, pluralize } from './common/stringUtils';

const ReactorRow = (shape) => {
  const {
    onClick,
    components,
    rowID,
    emptySlotIcon,
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
                color="transparent"
                m={1}
                onClick={() => onClick('slot', { "x": rowID+1, "y": index+1 })} >
                <img
                  src={`data:image/png;base64,${emptySlotIcon}`}
                  style={{
                    'vertical-align': 'middle',
                    'horizontal-align': 'middle',
                  }}
                />
              </Button>
            </Table.Cell>
          );
        }
        else
        {
          const { x, y, name, img, temp } = c;
          return (
            <Table.Cell>
              <Button
                key={name}
                fluid
                tooltip={temp}
                color="transparent"
                m={1}
                onClick={() => onClick('slot', { "x": x, "y": y })} >
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
    emptySlotIcon,
  } = shape;
  return (
    <Table>
      {components.map((r, index) => { const { comp } = r;
        return (
          <Table.Row key>
            <ReactorRow rowID={index} components={r} onClick={onClick} emptySlotIcon={emptySlotIcon} />
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
    emptySlotIcon,
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
              emptySlotIcon={emptySlotIcon}
            />
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};

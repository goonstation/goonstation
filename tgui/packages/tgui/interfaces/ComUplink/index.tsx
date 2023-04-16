/**
 * @file
 * @copyright 2021
 * @author Zonespace (https://github.com/Zonespace27)
 * @license MIT
 */

import { useBackend } from '../../backend';
import { Box, Button, Collapsible, LabeledList, Section, Stack, Table } from '../../components';
import { Window } from '../../layouts';
import { ComUplinkData, ComUplinkStockData } from './type';

import { pluralize } from '../common/stringUtils';

export const ComUplink = (props, context) => {
  const { data } = useBackend<ComUplinkData>(context);
  return (
    <Window
      theme="syndicate"
      title="Syndicate Commander Uplink"
      width={500}
      height={500}>
      <Window.Content scrollable>
        <Stack className="ComUplink" />
        <Stack.Item>
          <Section fill>
            <LabeledList>
              <LabeledList.Item label="Points">
                <Box key={data.points} inline bold color="green" mr="5px" className={`ComUplink__Points--commander`}>
                  {data.points}
                </Box>
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Stack.Item>
        <Stack.Item grow={1}>
          <Section
            fill
            scrollable
            title="Uplink Items"
          />
          <Collapsible className={`ComUplink__Category--Main`} title="Equipment" open color="Main">
            <Table>
              {data.stock
                .filter((stock) => stock.category === "Main")
                .map((stock) => (
                  <Stock key={stock.name} stock={stock} />
                ))}
            </Table>
          </Collapsible>
        </Stack.Item>
      </Window.Content>
    </Window>
  );
};

type StockProps = {
  stock: ComUplinkStockData;
};

const Stock = ({ stock }: StockProps, context) => {
  const { data, act } = useBackend<ComUplinkData>(context);

  return (
    <Table.Row className="ComUplink__Row" opacity={stock.cost > data.points[stock.category] ? 0.5:1}>
      <Table.Cell className="ComUplink__Cell" py="5px">
        <Box mb="5px" bold>
          {stock.name}
        </Box>
        <Box>{stock.description}</Box>
      </Table.Cell>
      <Table.Cell className="ComUplink__Cell" py="5px" textAlign="right">
        <Button
          disabled={stock.cost > data.points}
          onClick={() => act('redeem', { ref: stock.ref })}>
          Purchase {stock.cost} {pluralize('point', stock.cost)}
        </Button>
      </Table.Cell>
    </Table.Row>
  );
};

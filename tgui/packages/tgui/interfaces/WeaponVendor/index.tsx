import { classes } from 'common/react';
import { pluralize } from 'common/string';
import { useBackend, useLocalState } from '../../backend';
import { Box, Button, Collapsible, LabeledList, Section, Stack, Table } from '../../components';
import { Window } from '../../layouts';
import { WeaponVendorData, WeaponVendorStockData } from './type';

const LoadoutConfig = {
  Sidearm: {
    color: 'teal',
  },
  Loadout: {
    color: 'yellow',
  },
  Utility: {
    color: 'blue',
  },
  Assistant: {
    color: 'grey',
  },
};

export const WeaponVendor = (_props, context) => {
  const { data } = useBackend<WeaponVendorData>(context);
  const [filterAvailable, setFilterAvailable] = useLocalState(context, 'filter-available', false);

  return (
    <Window width={550} height={700}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section fill>
              <LabeledList>
                <LabeledList.Item label="Balance">
                  {Object.entries(data.credits).map(([name, value], index) => (
                    <Box key={name} inline mr="5px" color={LoadoutConfig[name]?.color}>
                      {value} {name} {pluralize('credit', value)}
                      {index + 1 !== Object.keys(data.credits).length ? ', ' : ''}
                    </Box>
                  ))}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item grow={1}>
            <Section
              fill
              scrollable
              title="Materiel"
              buttons={
                <Button.Checkbox checked={filterAvailable} onClick={() => setFilterAvailable(!filterAvailable)}>
                  Filter Available
                </Button.Checkbox>
              }>
              {Object.keys(data.credits).map((category) => (
                <StockCategory key={category} category={category} />
              ))}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type StockCategoryProps = {
  category: string;
};

const StockCategory = ({ category }: StockCategoryProps, context) => {
  const { data } = useBackend<WeaponVendorData>(context);
  const [filterAvailable] = useLocalState(context, 'filter-available', false);

  let stock = data.stock.filter((stock) => stock.category === category);
  if (filterAvailable) {
    stock = stock.filter((stock) => stock.cost <= data.credits[stock.category]);
  }

  const color = LoadoutConfig[category]?.color;

  if (stock.length === 0) {
    return null;
  }

  return (
    <Collapsible title={category} open color={color}>
      <Table key={category}>
        {data.stock
          .filter((stock) => stock.category === category)
          .map((stock) => (
            <Stock key={stock.name} stock={stock} />
          ))}
      </Table>
    </Collapsible>
  );
};

type StockProps = {
  stock: WeaponVendorStockData;
};

const Stock = ({ stock }: StockProps, context) => {
  const { data, act } = useBackend<WeaponVendorData>(context);

  const color = LoadoutConfig[stock.category]?.color;
  return (
    <Table.Row className={'WeaponVendor__Row'} opacity={stock.cost > data.credits[stock.category] && 0.5}>
      <Table.Cell className="WeaponVendor__Cell">
        <Box pb="5px">
          <Box inline bold>
            {stock.name}
          </Box>
        </Box>
        <Box>{stock.description}</Box>
      </Table.Cell>
      <Table.Cell className="WeaponVendor__Cell" textAlign="right">
        <Button
          disabled={stock.cost > data.credits[stock.category]}
          color={color}
          onClick={() => act('redeem', { ref: stock.ref })}>
          Redeem {stock.cost} {pluralize('credit', stock.cost)}
        </Button>
      </Table.Cell>
    </Table.Row>
  );
};

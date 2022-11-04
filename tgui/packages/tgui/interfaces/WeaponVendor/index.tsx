/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */

import { toTitleCase } from 'common/string';
import { useBackend, useLocalState } from '../../backend';
import { Box, Button, Collapsible, LabeledList, Section, Stack, Table } from '../../components';
import { Window } from '../../layouts';
import { WeaponVendorData, WeaponVendorStockData } from './type';

import { pluralize } from '../common/stringUtils';

export const WeaponVendor = (_props, context) => {
  const { data } = useBackend<WeaponVendorData>(context);
  const [filterAvailable, setFilterAvailable] = useLocalState(context, 'filter-available', false);

  return (
    <Window width={550} height={700}>
      <Window.Content>
        <Stack className="WeaponVendor" vertical fill>
          <Stack.Item>
            <Section fill>
              <LabeledList>
                <LabeledList.Item label="Balance">
                  {Object.entries(data.credits).map(([name, value], index) => (
                    <Box key={name} inline mr="5px" className={`WeaponVendor__Credits--${name}`}>
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
                <StockCategory key={category} category={category} filterAvailable={filterAvailable} />
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
  filterAvailable: boolean;
};

const StockCategory = (props: StockCategoryProps, context) => {
  const { category, filterAvailable } = props;
  const { data } = useBackend<WeaponVendorData>(context);

  let stock = data.stock.filter((stock) => stock.category === category);
  if (filterAvailable) {
    stock = stock.filter((stock) => stock.cost <= data.credits[stock.category]);
  }

  if (stock.length === 0) {
    return null;
  }

  return (
    <Collapsible className={`WeaponVendor__Category--${category}`} title={toTitleCase(category)} open color={category}>
      <Table>
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

  return (
    <Table.Row className="WeaponVendor__Row" opacity={stock.cost > data.credits[stock.category] ? 0.5 : 1}>
      <Table.Cell className="WeaponVendor__Cell" py="5px">
        <Box mb="5px" bold>
          {stock.name}
        </Box>
        <Box>{stock.description}</Box>
      </Table.Cell>
      <Table.Cell className="WeaponVendor__Cell" py="5px" textAlign="right">
        <Button
          disabled={stock.cost > data.credits[stock.category]}
          color={stock.category}
          onClick={() => act('redeem', { ref: stock.ref })}>
          Redeem {stock.cost} {pluralize('credit', stock.cost)}
        </Button>
      </Table.Cell>
    </Table.Row>
  );
};

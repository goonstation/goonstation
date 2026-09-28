/**
 * @file
 * @copyright 2026
 * @author JORJ949 (https://github.com/JORJ949)
 * @license MIT
 */

import { Section, Table } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { SupplyConsoleData } from './type';

export const SupplyConsoleHistoryTab = () => {
  const { data } = useBackend<SupplyConsoleData>();
  return (
    <Section title="Order History" scrollable fill>
      <Table>
        <Table.Cell py="2px">
          <b>Ordered Items:</b>
        </Table.Cell>
        <Table.Cell width={'100px'}>
          <b>Ordered By:</b>
        </Table.Cell>
        <Table.Cell>
          <b>Cost:</b>
        </Table.Cell>
        <Table.Cell>
          <b>Comment:</b>
        </Table.Cell>
        {data.order_history.map((order, index) => (
          <Table.Row className="candystripe" key={index}>
            <Table.Cell py="2px">{order.supply_name}</Table.Cell>
            <Table.Cell>{order.orderer}</Table.Cell>
            <Table.Cell>{order.cost}⪽</Table.Cell>
            <Table.Cell>{order.comment}</Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

/**
 * @file
 * @copyright 2026
 * @author JORJ949 (https://github.com/JORJ949)
 * @license MIT
 */

import { Button, Section, Table } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { SupplyConsoleData } from './type';

export const SupplyConsoleRequestsTab = () => {
  const { data } = useBackend<SupplyConsoleData>();
  return (
    <Section title="Cargo Requests">
      <Table>
        <Table.Cell>
          <b>Requested Items:</b>
        </Table.Cell>
        <Table.Cell width={'100px'}>
          <b>Requester:</b>
        </Table.Cell>
        <Table.Cell>
          <b>Cost:</b>
        </Table.Cell>
        <Table.Cell>
          <b>Location:</b>
        </Table.Cell>
        {data.requests.map((order, index) => (
          <Table.Row className="candystripe" key={index}>
            <Table.Cell>{order.supply_name}</Table.Cell>
            <Table.Cell>{order.requester}</Table.Cell>
            <Table.Cell>{order.cost}⪽</Table.Cell>
            <Table.Cell>{order.console_location}</Table.Cell>
            <Table.Cell py="2px">
              <Button
                color="good"
                icon="check"
                iconColor="white"
                tooltip="Approve"
              />
            </Table.Cell>
            <Table.Cell py="2px">
              <Button
                color="bad"
                icon="trash"
                iconColor="white"
                tooltip="Deny"
              />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

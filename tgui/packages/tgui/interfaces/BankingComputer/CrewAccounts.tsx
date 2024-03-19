/**
 * @file
 * @copyright 2024
 * @author mloccy (https://github.com/mloccy)
 * @license MIT
 */

import { useBackend } from "../../backend";
import { Button, Section, Table } from "../../components";
import { TransferButton } from "./TransferButton";
import { CREDIT_SIGN, CrewAccount } from "./type";

interface CrewAccountLineProps {
  account: CrewAccount
}

const CrewAccountLine = (props: CrewAccountLineProps, context) => {
  const { data, act } = useBackend(context);
  return (
    <>
      <Table.Cell bold>{props.account.name}</Table.Cell>
      <Table.Cell>{props.account.job}</Table.Cell>
      <Table.Cell>{props.account.wage.toLocaleString()}{CREDIT_SIGN}</Table.Cell>
      <Table.Cell><Button onClick={() => act("edit_wage", { "id": props.account.id })} icon="pen" /></Table.Cell>
      <Table.Cell>{props.account.balance.toLocaleString()}{CREDIT_SIGN}</Table.Cell>
      <Table.Cell><TransferButton frozen={props.account.frozen} id={props.account.id} type={"crew"} /></Table.Cell>
    </>
  );
};

interface CrewAccountsProps {
  accounts: CrewAccount[]
}
export const CrewAccounts = (props: CrewAccountsProps) => {
  return (
    <Section title="Crew Acccounts">
      <Table>
        <Table.Row className="tableHeader">
          <Table.Cell bold>
            Name
          </Table.Cell>
          <Table.Cell bold>
            Job
          </Table.Cell>
          <Table.Cell bold>
            Salery
          </Table.Cell>
          <Table.Cell />
          <Table.Cell bold>
            Account Balance
          </Table.Cell>
        </Table.Row>
        {props.accounts.map(account => {
          return <Table.Row className="crewAccountRow" key={account.name}> <CrewAccountLine account={account} /></Table.Row>;
        })}
      </Table>
    </Section>
  );
};

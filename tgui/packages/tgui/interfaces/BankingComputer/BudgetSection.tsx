/**
 * @file
 * @copyright 2024
 * @author mloccy (https://github.com/mloccy)
 * @license MIT
 */

import { Table } from "../../components";
import { TransferButton } from "./TransferButton";
import { Budget, CREDIT_SIGN } from "./type";

interface BudgetProps {
  rowClassName?: string,
  allowTransfer: boolean,
  currentBudget: Budget
}
const BudgetLine = (props: BudgetProps) => {

  return (
    <Table.Row className={props.rowClassName}>
      <Table.Cell bold>
        {props.currentBudget.name}
      </Table.Cell>
      <Table.Cell>
        {props.currentBudget.amount.toLocaleString()}{CREDIT_SIGN}
      </Table.Cell>
      <Table.Cell className="buttonCell">
        {props.allowTransfer
          ? <TransferButton frozen={false} id={props.currentBudget.name} type={"budget"} />
          : ""}
      </Table.Cell>
    </Table.Row>

  );
};

interface BudgetSectionProps {
  budgets: Budget[]
}

const BudgetSummery = (props: BudgetSectionProps) => {
  const sum = props.budgets.reduce((acc, budget) => {
    return acc + budget.amount;
  }, 0);
  const newBudget = { "name": "Total Funds", "amount": sum };
  return (
    <BudgetLine rowClassName="budgetSummery" allowTransfer={false} currentBudget={newBudget} />
  );
};
export const BudgetSection = (props: BudgetSectionProps) => {
  return (
    <Table className="budgetTable">
      <Table.Row className="headerRow">
        <Table.Cell bold>Budget Name</Table.Cell>
        <Table.Cell bold>Balance</Table.Cell>
        <Table.Cell />
      </Table.Row>
      {
        props.budgets.map(budget => {
          return (
            <BudgetLine rowClassName="budgetRow" key={budget.name} allowTransfer currentBudget={budget} />
          );
        })
      }

      <BudgetSummery budgets={props.budgets} />

    </Table>

  );
};

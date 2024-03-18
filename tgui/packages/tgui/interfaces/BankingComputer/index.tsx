/**
 * @file
 * @copyright 2024
 * @author mloccy (https://github.com/mloccy)
 * @license MIT
 */
const CREDIT_SIGN = "⪽";

import { useBackend, useLocalState } from '../../backend';
// import { Box, Flex, Section } from '../../components';
import { Button, Divider, Section, Stack, Table } from '../../components';
import { Window } from '../../layouts';
import { BankComputerStatus, Budget, CrewAccount, PayrollData, Transfer } from './type';

interface TransferButtonProps {
  id: string,
  type: string,
  frozen: boolean,
}

const transferButtonTooltip = (isAuthenticated: boolean, isFrozen: boolean) => {
  if (!isAuthenticated) {
    return "Please login to transfer funds.";
  } else if (isAuthenticated && isFrozen) {
    return "Cannot withdraw from account as it is frozen.";
  }

  return "";
};

const TransferButton = (props : TransferButtonProps, context) => {
  const { act, data } = useBackend<BankComputerStatus>(context);
  const [transferring, setTransferring] = useLocalState<boolean>(context, "transferring", false);
  const [transferInfo, setTransferInfo] = useLocalState<Transfer>(context, "transferInfo", null);
  return (
    <Button
      title={transferButtonTooltip(data.authenticated, props.frozen)}
      disabled={(!data.authenticated) || props.frozen}
      onClick={() => {

        setTransferring(!transferring);

        if (!transferring) {
          let transferObj = {
            "fromId": props.id,
            "fromType": props.type,

            "toId": "",
            "toType": null,
          };

          setTransferInfo(transferObj);
        } else {
          if (transferInfo.fromId === props.id && transferInfo.fromType === props.type) {
            return;
          } else {
            let fullTransferObj = {
              "fromId": transferInfo.fromId,
              "fromType": transferInfo.fromType,

              "toId": props.id,
              "toType": props.type,
            };

            act("transfer", fullTransferObj);
          }
        }

      }}
      color={transferring? "red": "blue"}>
      {transferring? "Transfer to": "Transfer"}
    </Button>
  );
};

interface BudgetProps {
  currentBudget: Budget
}
const BudgetLine = (props : BudgetProps) => {

  return (
    <>
      <Table.Cell bold>
        {props.currentBudget.name}
      </Table.Cell>
      <Table.Cell>
        {props.currentBudget.amount.toLocaleString()}{CREDIT_SIGN}
      </Table.Cell>
      <Table.Cell className="buttonCell">

        <TransferButton frozen={false} id={props.currentBudget.name} type={"budget"} />

      </Table.Cell>
    </>
  );
};

const AuthenticationControl = (props, context) => {
  const { data, act } = useBackend<BankComputerStatus>(context);
  return (
    <Section>
      <Stack>
        <Stack.Item>
          <Button
            icon="eject"
            onClick={() => act("card_insertion")}>
            {data.cardInserted? data.cardName: "Insert Card"}
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button icon="key"
            onClick={() => act("login")}
            title={(!data.authenticated && !data.cardInserted)? "Please insert a valid ID card to login" : ""}
            disabled={!data.cardInserted && !data.authenticated}>
            {data.authenticated? "Log out": "Login"}
          </Button>
        </Stack.Item>
        <Stack.Item textColor={data.failedLogin? "red" : ""}>
          {data.authenticated? "Currently logged in as " + data.loggedInName : ""}
          {data.failedLogin? "Login failed" : ""}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

interface PayrollDetailsProps{
  data: PayrollData,
  payrollActive: boolean
}

const PayrollDetails = (props : PayrollDetailsProps, context) => {
  const { act, data } = useBackend(context);
  return (
    <Stack vertical>
      <Stack.Item>
        <Stack align="flex-end" justify="space-between">
          <Stack.Item bold>Payroll Stipend</Stack.Item>
          <Stack.Item>{props.data.stipend}{CREDIT_SIGN}</Stack.Item>
        </Stack>
      </Stack.Item>
      <Divider />
      <Stack.Item>
        <Stack align="flex-end" justify="space-between">
          <Stack.Item bold>Payroll Cost</Stack.Item>
          <Stack.Item>{props.data.cost.toLocaleString()}{CREDIT_SIGN}</Stack.Item>
        </Stack>
      </Stack.Item>
      <Divider />
      <Stack.Item>
        <Stack align="flex-end" justify="space-between">
          <Stack.Item bold>Surplus</Stack.Item>
          <Stack.Item color={props.data.surplus< 0?"red" : ""}>{props.data.surplus.toLocaleString()}{CREDIT_SIGN}</Stack.Item>
        </Stack>
      </Stack.Item>
      <Divider />
      <Stack.Item>
        <Stack align="flex-end" justify="space-between">
          <Stack.Item bold>Total Stipend</Stack.Item>
          <Stack.Item>{props.data.total.toLocaleString()}{CREDIT_SIGN}</Stack.Item>
        </Stack>
      </Stack.Item>
      <Divider />
      <Stack.Item>
        <Stack>
          <Stack.Item bold>
            Payroll Status:
          </Stack.Item>
          <Stack.Item color={props.payrollActive ? "green" : "red"}>
            {props.payrollActive? "Active": "Suspended"}
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Button
          icon={props.payrollActive? "xmark" : "check"}
          color={props.payrollActive? "red" : "green"}
          onClick={() => act("togglePayroll")}>
          {props.payrollActive? "Suspend Payroll": "Resume Payroll"}
        </Button>
      </Stack.Item>
    </Stack>
  );
};

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
const CrewAccounts = (props : CrewAccountsProps) => {
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

export const BankingComputer = (_props, context) => {
  const { act, data } = useBackend<BankComputerStatus>(context);

  return (
    <Window
      width={580}
      height={580}
      title={"Banking Records"}>
      <Window.Content scrollable>
        <Section>
          <AuthenticationControl />
        </Section>
        <Section title="Budget Status">
          <Table className="budgetTable">
            <Table.Row className="headerRow">
              <Table.Cell bold>Budget Name</Table.Cell>
              <Table.Cell bold>Balance</Table.Cell>
              <Table.Cell />
            </Table.Row>

            {
              data.budgets.map(budget => {
                return (
                  <Table.Row key={budget.name}>
                    <BudgetLine currentBudget={budget} />
                  </Table.Row>
                );
              })
            }
          </Table>
        </Section>
        <Section title="Payroll Details">
          {data.authenticated? <PayrollDetails data={data.payroll} payrollActive={data.payrollActive} /> : "Please authenticate to view and modify the payroll and crew accounts." }
        </Section>
        <Divider />
        { data.authenticated? <CrewAccounts accounts={data.accounts} /> : "" }
      </Window.Content>
    </Window>
  );
};

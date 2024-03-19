/**
 * @file
 * @copyright 2024
 * @author mloccy (https://github.com/mloccy)
 * @license MIT
 */

import { useBackend } from '../../backend';
import { Divider, Section } from '../../components';
import { Window } from '../../layouts';
import { AuthenticationControl } from './AuthenticationControl';
import { BudgetSection } from './BudgetSection';
import { CrewAccounts } from './CrewAccounts';
import { PayrollDetails } from './PayrollDetails';
import { BankComputerStatus } from './type';

export const BankingComputer = (_props, context) => {
  const { act, data } = useBackend<BankComputerStatus>(context);

  return (
    <Window
      width={580}
      height={680}
      title={"Banking Records"}>
      <Window.Content scrollable>
        <Section>
          <AuthenticationControl />
        </Section>
        <Section title="Budgets Status">
          <BudgetSection budgets={data.budgets} />
        </Section>
        <Section title="Payroll Details">
          {data.authenticated ? <PayrollDetails data={data.payroll} payrollActive={data.payrollActive} /> : "Please authenticate to view and modify the payroll and crew accounts."}
        </Section>
        <Divider />
        {data.authenticated ? <CrewAccounts accounts={data.accounts} /> : ""}
      </Window.Content>
    </Window>
  );
};

/**
 * @file
 * @copyright 2024
 * @author mloccy (https://github.com/mloccy)
 * @license MIT
 */

import { useBackend, useLocalState } from '../../backend';
import { Section, Tabs } from '../../components';
import { Window } from '../../layouts';
import { AuthenticationControl } from './AuthenticationControl';
import { BudgetSection } from './BudgetSection';
import { CrewAccounts } from './CrewAccounts';
import { PayrollDetails } from './PayrollDetails';
import { BankComputerStatus, TabState } from './type';

export const BankingComputer = (_props, context) => {
  const { act, data } = useBackend<BankComputerStatus>(context);
  const [selectedTab, setSelectedTab] = useLocalState(context, "selectedTab", TabState.BudgetStatus);

  return (
    <Window
      width={580}
      height={380}
      title={"Banking Records"}>
      <Window.Content scrollable>
        {!data.isSiliconUser && <AuthenticationControl />}
        <Tabs>
          <Tabs.Tab onClick={() => setSelectedTab(TabState.BudgetStatus)} selected={selectedTab === TabState.BudgetStatus} title="Budget Status">
            Budgets
          </Tabs.Tab>
          <Tabs.Tab
            onClick={() => setSelectedTab(TabState.PayrollDetails)} selected={selectedTab === TabState.PayrollDetails}>
            Payroll
          </Tabs.Tab>
          <Tabs.Tab
            onClick={() => setSelectedTab(TabState.CrewAccounts)} selected={selectedTab === TabState.CrewAccounts}>
            Accounts
          </Tabs.Tab>
        </Tabs>
        {selectedTab === TabState.BudgetStatus
          ? <Section title="Budget Status"><BudgetSection budgets={data.budgets} /></Section>
          : ""}
        {selectedTab === TabState.PayrollDetails
          ? data.authenticated
            ? <PayrollDetails data={data.payroll} payrollActive={data.payrollActive} />
            : <Section>Please authenticate to view payroll details.</Section>
          : ""}
        {selectedTab === TabState.CrewAccounts
          ? data.authenticated
            ? <CrewAccounts accounts={data.accounts} isSiliconUser={data.isSiliconUser} />
            : <Section>Please authenticate to modify crew accounts.</Section>
          : ""}
      </Window.Content>
    </Window>
  );
};

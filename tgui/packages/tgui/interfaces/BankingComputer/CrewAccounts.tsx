/**
 * @file
 * @copyright 2024
 * @author mloccy (https://github.com/mloccy)
 * @license MIT
 */

import { useBackend, useLocalState } from "../../backend";
import { Button, Divider, Dropdown, Input, Section, Stack, Table } from "../../components";
import { CREDIT_SIGN } from "../common/strings";
import { SortDirection } from "../PlayerPanel/constant";
import { Header } from "../PlayerPanel/Header";
import { TransferButton } from "./TransferButton";
import { ColumnSortField, CrewAccount, CrewColumnSortConfig, SearchFilter } from "./type";

interface CrewAccountLineProps {
  account: CrewAccount
}

const CrewAccountLine = (props: CrewAccountLineProps, context) => {
  const { data, act } = useBackend(context);
  return (
    <>
      <Table.Cell className="crewAccountCell" bold>{props.account.name}</Table.Cell>
      <Table.Cell className="crewAccountCell">{props.account.job}</Table.Cell>
      <Table.Cell className="crewAccountCell">
        <Button title={"Edit Salary"} onClick={() => act("edit_wage", { "id": props.account.id })} icon="pen">
          {props.account.wage.toLocaleString()}{CREDIT_SIGN}
        </Button>
      </Table.Cell>
      <Table.Cell className="crewAccountCell">{props.account.balance.toLocaleString()}{CREDIT_SIGN}</Table.Cell>
      <Table.Cell className="crewAccountCell"><TransferButton frozen={props.account.frozen} id={props.account.id} type={"crew"} /></Table.Cell>
    </>
  );
};


interface CrewAccountsTableHeaderProps {
  onSortClick: (config: CrewColumnSortConfig) => any,
  currentColumnConfig: CrewColumnSortConfig
}
const CrewAccountsTableHeader = (props: CrewAccountsTableHeaderProps, context) => {
  const setColumnConfig = (field: ColumnSortField) => {
    if (props.currentColumnConfig === null) {
      props.onSortClick({ "field": field, dir: SortDirection.Asc });
    } else {
      let dir = props.currentColumnConfig.dir;
      if (dir === SortDirection.Asc) {
        dir = SortDirection.Desc;
      } else {
        dir = SortDirection.Asc;
      }

      props.onSortClick({ dir: dir, field: field });
    }

  };
  return (
    <Table.Row header>
      <Table.Cell bold>
        <Header
          sortDirection={
            props.currentColumnConfig?.field === ColumnSortField.Name
              ? props.currentColumnConfig?.dir
              : null
          }
          onSortClick={() => setColumnConfig(ColumnSortField.Name)}>
          Name
        </Header>
      </Table.Cell>
      <Table.Cell bold>
        <Header
          sortDirection={
            props.currentColumnConfig?.field === ColumnSortField.Job
              ? props.currentColumnConfig?.dir
              : null
          }
          onSortClick={() => setColumnConfig(ColumnSortField.Job)}>
          Job
        </Header>
      </Table.Cell>
      <Table.Cell bold>
        <Header
          sortDirection={
            props.currentColumnConfig?.field === ColumnSortField.Salary
              ? props.currentColumnConfig?.dir
              : null
          }
          onSortClick={() => setColumnConfig(ColumnSortField.Salary)}>
          Salary
        </Header>
      </Table.Cell>
      <Table.Cell bold>
        <Header
          sortDirection={
            props.currentColumnConfig?.field === ColumnSortField.Balance
              ? props.currentColumnConfig?.dir
              : null
          }
          onSortClick={() => setColumnConfig(ColumnSortField.Balance)}>
          Account Balance
        </Header>
      </Table.Cell>
    </Table.Row>
  );
};

interface CrewAccountsTableProps {
  accounts: CrewAccount[],
  onSortClick: (config: CrewColumnSortConfig) => any,
  currentColumnConfig: CrewColumnSortConfig
}
const CrewAccountsTable = (props: CrewAccountsTableProps) => {
  if (props.accounts.length > 0) {
    return (
      <Table>
        <CrewAccountsTableHeader currentColumnConfig={props.currentColumnConfig} onSortClick={props.onSortClick} />
        {
          props.accounts.map(account => (
            <Table.Row className="crewAccountRow" key={account.name}>
              <CrewAccountLine account={account} />
            </Table.Row>))
        }
      </Table>
    );
  } else {
    return (<Section>Search returned no results.</Section>);
  }
};

interface CrewAccountsProps {
  accounts: CrewAccount[],
}

export const CrewAccounts = (props: CrewAccountsProps, context) => {
  const [searchText, setSearchText] = useLocalState(context, "crewAccountSearchText", "");
  const [searchFilter, setSearchFilter] = useLocalState(context, "crewAccountSearchFilter", SearchFilter.Name);
  const [sort, setSort] = useLocalState<CrewColumnSortConfig>(context, 'crewColumnSort', null);

  const filterOptions = Object.keys(SearchFilter);
  const onSortClick = (config: CrewColumnSortConfig) => {
    setSort(config);
  };

  const numericCompare = (a: number, b: number) => {
    if (a === b) {
      return 0;
    } else if (a > b) {
      return 1;
    } else {
      return -1;
    }
  };

  const compareByField = (a: CrewAccount, b: CrewAccount, sortConfig: CrewColumnSortConfig) => {

    switch (sortConfig.field) {
      case ColumnSortField.Name:
        return a.name.localeCompare(b.name);

      case ColumnSortField.Job:
        return a.job.localeCompare(b.job);

      case ColumnSortField.Balance:
        return numericCompare(a.balance, b.balance);

      case ColumnSortField.Salary:
        return numericCompare(a.wage, b.wage);
    }

  };

  const searchAndSortCrewAccounts = (filter: string, text: string, sortConfig: CrewColumnSortConfig) => {

    let accounts = props.accounts;
    if (sortConfig) {
      accounts.sort((a, b) => compareByField(a, b, sortConfig));

      if (sortConfig.dir === SortDirection.Asc) {
        accounts.reverse();
      }
    }

    if (!filter) {
      return accounts;
    }

    switch (filter) {
      case SearchFilter.Name:
      case "Name":
        return accounts.filter(account => account.name.toLocaleLowerCase().includes(text.toLocaleLowerCase()));

      case SearchFilter.Job:
      case "Job":
        return accounts.filter(account => account.job.toLocaleLowerCase().includes(text.toLocaleLowerCase()));
    }

  };
  const handleSearchTextChange = (_e, value: string) => setSearchText(value);
  return (
    <Section title="Crew Acccounts">
      <Stack>
        <Stack.Item bold fontSize="larger">
          Search:
        </Stack.Item>
        <Stack.Item>
          <Input autoFocus value={searchText} onInput={handleSearchTextChange} />
        </Stack.Item>
        <Stack.Item>
          <Dropdown
            icon="filter"
            nochevron
            selected={searchFilter}
            onSelected={(value: SearchFilter) => setSearchFilter(value)}
            options={filterOptions} />
        </Stack.Item>
      </Stack>
      <Divider />
      <CrewAccountsTable
        currentColumnConfig={sort}
        onSortClick={onSortClick}
        accounts={searchAndSortCrewAccounts(searchFilter, searchText, sort)} />
    </Section>
  );
};

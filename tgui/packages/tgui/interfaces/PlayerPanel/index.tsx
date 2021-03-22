/**
 * @file
 * @copyright 2021
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { InfernoNode } from 'inferno';
import { useBackend, useLocalState } from '../../backend';
import { Box, Button, Icon, Input, Table } from '../../components';
import { Window } from '../../layouts';
import { Action, SortDirection } from './constants';

interface Column<Row, Value> {
  field?: string,
  name: string,
  sorter?: (a: Value, b: Value) => number,
  template?: (config: CellTemplateConfig<Row, Value>) => InfernoNode,
  valueSelector?: (config: CellValueSelectorConfig<Row, Value>) => Value,
}

interface CellTemplateConfig<Row, Value> {
  act: (action: string, payload?: object) => void,
  column: Column<Row, Value>,
  row: Row,
  value: Value,
}

interface CellValueSelectorConfig<Row, Value> {
  column: Column<Row, Value>,
  row: Row,
}

interface SortConfig {
  field: string,
  dir: SortDirection,
}

const defaultValueSelector = (config: CellValueSelectorConfig<PlayerData, string>) => config.row[config.column.field];

const defaultTemplate = (config: CellTemplateConfig<PlayerData, string>) => config.value;
const ckeyTemplate = (config: CellTemplateConfig<PlayerData, string>) => {
  const {
    act,
    value,
  } = config;
  return (
    <Button
      onClick={() => act(Action.OpenPlayerOptions, {
        ckey: value,
      })}
    >
      {value}
    </Button>
  );
};

const alphabeticalSort = (a: string, b: string) => a.localeCompare(b);
const ipSort = (a: string, b: string) => 0; // TODO
const dateStringSort = (a: string, b: string) => 0; // TODO

const columns: Column<PlayerData, any>[] = [
  { name: 'CKey', field: 'ckey', sorter: alphabeticalSort, template: ckeyTemplate },
  { name: 'Name', field: 'name', sorter: alphabeticalSort },
  { name: 'Real Name', field: 'realName', sorter: alphabeticalSort },
  { name: 'Assigned Role', field: 'assignedRole', sorter: alphabeticalSort },
  { name: 'Special Role', field: 'specialRole', sorter: alphabeticalSort },
  { name: 'Player Type', field: 'playerType', sorter: alphabeticalSort },
  { name: 'CID', field: 'computerID', sorter: alphabeticalSort },
  { name: 'IP', field: 'ip', sorter: ipSort },
  { name: 'Join Date', field: 'joined', sorter: dateStringSort },
  { name: 'Player location', field: 'playerLocation', sorter: alphabeticalSort },
];

interface PlayerData {
  assignedRole: string,
  computerId: string,
  ckey: string,
  ip: string,
  joined: string,
  name: string,
  playerLocation: string,
  playerType: string,
  realName: string,
  specialRole: string,
}

interface PlayerPanelData {
  players: {
    [ckey: string]: PlayerData,
  },
}

interface SortableHeaderProps {
  children: InfernoNode,
  onClick: () => any,
  sortDirection?: SortDirection | null,
}

const SortableHeader = (props: SortableHeaderProps) => {
  const {
    children,
    onClick,
    sortDirection,
    ...rest
  } = props;
  const iconName = sortDirection
    ? (sortDirection === SortDirection.Asc ? 'sort-alpha-down' : 'sort-alpha-up')
    : 'sort';
  return (
    <Box onClick={onClick} {...rest}>
      {children}
      <Icon name={iconName} />
    </Box>
  );
};

export const PlayerPanel = (props, context) => {
  const { act, data } = useBackend<PlayerPanelData>(context);
  const { players } = data;
  const [search, setSearch] = useLocalState(context, 'search', '');
  const [sort, setSort] = useLocalState<Array<SortConfig>>(context, 'sort', []);
  let resolvedPlayers = Object.keys(players).map(ckey => players[ckey]);
  if (search) {
    const lowerSearch = search.toLowerCase();
    // filter player data strings by search string, case-insensitive
    resolvedPlayers = resolvedPlayers.filter(player => (
      Object.values(player)
        .some(value => typeof value === 'string' && value.toLowerCase().includes(lowerSearch))
    ));
  }
  return (
    <Window width={670} height={640}>
      <Window.Content scrollable>
        <Input
          autoFocus
          mb={1}
          placeholder="Search..."
          onInput={(_e, value: string) => setSearch(value)}
          value={search}
        />
        <Table>
          <Table.Row header>
            {columns.map(column => (
              <Table.Cell key={column.field}>
                <SortableHeader
                  onClick={() => {}}
                  sortDirection={(sort.find(s => s.field === column.field) || {}).dir}
                >
                  {column.name}
                </SortableHeader>
              </Table.Cell>
            ))}
          </Table.Row>
          {resolvedPlayers.map(player => {
            const { ckey } = player;
            return (
              <Table.Row key={ckey}>
                {columns.map((column, i) => {
                  const {
                    field,
                    name,
                    template = defaultTemplate,
                    valueSelector = defaultValueSelector,
                  } = column;
                  const value = valueSelector({
                    column,
                    row: player,
                  });
                  return (
                    <Table.Cell key={`${name}${field ? `__${field}` : `__${i}`}`}>
                      {template({
                        act,
                        column,
                        row: player,
                        value,
                      })}
                    </Table.Cell>
                  );
                })}
              </Table.Row>
            );
          })}
        </Table>
      </Window.Content>
    </Window>
  );
};

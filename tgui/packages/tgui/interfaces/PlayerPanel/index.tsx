/**
 * @file
 * @copyright 2021
 * @author Sovexe (https://github.com/Sovexe)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { useBackend, useLocalState } from '../../backend';
import { Button, Input, Table } from '../../components';
import { Window } from '../../layouts';
import { Header } from './Header';
import { Action, SortDirection } from './constant';
import { CellTemplateConfig, CellValueSelectorConfig, Column, PlayerData, PlayerPanelData, SortConfig } from './type';

const defaultTemplate = <Row extends object, Value>(config: CellTemplateConfig<Row, Value>) => `${config.value}`;
const ckeyTemplate = (config: CellTemplateConfig<PlayerData, string>) => {
  const {
    act,
    row,
    value,
  } = config;
  return (
    <>
      <Button
        onClick={() => act(Action.OpenPlayerOptions, {
          ckey: value,
          mobRef: row.mobRef,
        })}
      >
        {value}
      </Button>
      <Button
        icon="envelope"
        color="bad"
        onClick={() => act(Action.PrivateMessagePlayer, {
          ckey: value,
          mobRef: row.mobRef,
        })}
      />
    </>
  );
};

const playerLocationTemplate = (config: CellTemplateConfig<PlayerData, string>) => {
  const {
    act,
    row,
    value,
  } = config;
  return (
    <Button
      onClick={() => act(Action.JumpToPlayerLocation, {
        ckey: row.ckey,
        mobRef: row.mobRef,
      })}
    >
      {value}
    </Button>
  );
};

const alphabeticalSorter = (a: string, b: string) => a.localeCompare(b);

// https://stackoverflow.com/a/68147012
const makeIpNumber = (ip: string) => Number(
  ip.split('.')
    .map((subString) => (`00${subString}`).slice(-3))
    .join('')
);
const ipSorter = (a: string, b: string) => makeIpNumber(a) - makeIpNumber(b);

const numberSorter = (a: number, b: number) => a - b;

const dateStringSorter = (a: string, b: string) => {
  let aArray = a.split("-").map(parseFloat);
  let bArray = b.split("-").map(parseFloat);
  return aArray > bArray ? 1 : aArray < bArray ? -1 : 0;
};

const createDefaultValueSelector = <Row extends object, Value>(field: string) => (
  (config: CellValueSelectorConfig<Row, Value>): Value => config.row[field]
);

const createDefaultColumnConfig = <Row extends object, Value>(field: string) => ({
  id: field,
  sorter: alphabeticalSorter,
  template: defaultTemplate,
  valueSelector: createDefaultValueSelector<Row, Value>(field),
});

const columns: Column<PlayerData, unknown>[] = [
  { ...createDefaultColumnConfig('ckey'), name: 'CKey', template: ckeyTemplate },
  { ...createDefaultColumnConfig('name'), name: 'Name' },
  { ...createDefaultColumnConfig('realName'), name: 'Real Name' },
  { ...createDefaultColumnConfig('assignedRole'), name: 'Assigned Role' },
  { ...createDefaultColumnConfig('specialRole'), name: 'Special Role' },
  { ...createDefaultColumnConfig('playerType'), name: 'Player Type' },
  { ...createDefaultColumnConfig('computerId'), name: 'CID' },
  { ...createDefaultColumnConfig('ip'), name: 'IP', sorter: ipSorter },
  { ...createDefaultColumnConfig('joined'), name: 'Join Date', sorter: dateStringSorter },
  { ...createDefaultColumnConfig('playerLocation'), name: 'Player Location', template: playerLocationTemplate },
  { ...createDefaultColumnConfig('ping'), name: 'Ping', sorter: numberSorter },
];

export const PlayerPanel = (props, context) => {
  const { act, data } = useBackend<PlayerPanelData>(context);
  const { players } = data;
  const [search, setSearch] = useLocalState(context, 'search', '');
  const [sort, setSort] = useLocalState<SortConfig>(context, 'sort', null);
  let resolvedPlayers = Object.keys(players).map(ckey => players[ckey]);

  // generate all values up front (to avoid having to generate multiple times)
  const playerValues: { [ckey: string]: {
    [id: string]: unknown,
  } } = resolvedPlayers.reduce((prevPlayerValues, currPlayer) => {
    prevPlayerValues[currPlayer.ckey] = columns.reduce((prevValues, currColumn) => {
      const {
        id,
        valueSelector,
      } = currColumn;
      prevValues[id] = valueSelector({
        column: currColumn,
        row: currPlayer,
      });
      return prevValues;
    }, {});
    return prevPlayerValues;
  }, {});
  if (search) {
    const lowerSearch = search.toLowerCase();
    resolvedPlayers = resolvedPlayers.filter(player => {
      const values = Object.values(playerValues[player.ckey]);
      return values.some(value => typeof value === 'string' && value.toLowerCase().includes(lowerSearch));
    });
  }
  if (sort) {
    const sortColumn = columns.find(column => column.id === sort.id);
    if (sortColumn) {
      resolvedPlayers.sort((a, b) => {
        let comparison = sortColumn.sorter(
          playerValues[a.ckey][sortColumn.id],
          playerValues[b.ckey][sortColumn.id],
        );
        if (sort.dir === SortDirection.Desc) {
          comparison *= -1;
        }
        return comparison;
      });
    }
  }
  return (
    <Window width={1100} height={640} title="Player Panel">
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
            {columns.map(column => {
              const columnSort = sort?.id === column.id ? sort : null;
              return (
                <Table.Cell key={column.field}>
                  <Header
                    onSortClick={column.sorter ? () => setSort({
                      dir: columnSort?.dir
                        ? (columnSort.dir === SortDirection.Asc ? SortDirection.Desc : SortDirection.Asc)
                        : SortDirection.Asc,
                      id: column.id,
                    }) : null}
                    sortDirection={columnSort?.dir}
                  >
                    {column.name}
                  </Header>
                </Table.Cell>
              );
            })}
          </Table.Row>
          {resolvedPlayers.map(player => {
            const { ckey } = player;
            return (
              <Table.Row key={ckey}>
                {columns.map(column => {
                  const {
                    id,
                    template,
                  } = column;
                  return (
                    <Table.Cell key={id}>
                      {template({
                        act,
                        column,
                        row: player,
                        value: playerValues[ckey][id],
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

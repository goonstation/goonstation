/**
 * @file
 * @copyright 2053
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { InfernoNode } from 'inferno';
import { useBackend } from '../backend';
import { Button, Table } from '../components';
import { Window } from '../layouts';

interface Column {
  name: string,
  field: string,
  template?: (config: CellTemplateConfig) => InfernoNode,
}

interface CellTemplateConfig {
  act: (action: string, payload?: object) => void,
  column: Column,
  row: PlayerData,
}

const defaultTemplate = (config: CellTemplateConfig) => config.row[config.column.field];
const nameTemplate = (config: CellTemplateConfig) => (
  <Button
    onClick={() => config.act('open-player-options', {
      ckey: config.row.ckey,
    })}
  >
    {config.row[config.column.field]}
  </Button>
);

const columns: Column[] = [
  { name: 'CKey', field: 'ckey' },
  { name: 'Name', field: 'name', template: nameTemplate },
  { name: 'Real Name', field: 'realName' },
  { name: 'Assigned Role', field: 'assignedRole' },
  { name: 'Special Role', field: 'specialRole' },
  { name: 'Player Type', field: 'playerType' },
  { name: 'CID', field: 'computerID' },
  { name: 'IP', field: 'ip' },
  { name: 'Join Date', field: 'joined' },
  { name: 'Player location', field: 'playerLocation' },
];

interface PlayerData {
  ckey: string,
  name: string,
  realName: string,
  assignedRole: string,
  specialRole: string,
  playerType: string,
  computerId: string,
  ip: string,
  joined: string,
  playerLocation: string,
}

interface PlayerPanelData {
  players: Array<PlayerData>,
}

export const PlayerPanel = (props, context) => {
  const { act, data } = useBackend<PlayerPanelData>(context);
  const {
    players,
  } = data;
  return (
    <Window width={670} height={640}>
      <Window.Content scrollable>
        This is the panel of doom:
        <Table>
          <Table.Row>
            {columns.map(column => (
              <Table.Cell key={column.field}>
                {column.name}
              </Table.Cell>
            ))}
          </Table.Row>
          {Object.keys(players).map(ckey => {
            const player = players[ckey];
            return (
              <Table.Row key={ckey}>
                {columns.map(column => {
                  const {
                    field,
                    template = defaultTemplate,
                  } = column;
                  return (
                    <Table.Cell key={field}>
                      {template({
                        act,
                        column,
                        row: player,
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

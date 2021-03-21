/**
 * @file
 * @copyright 2053
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { InfernoNode } from 'inferno';
import { useBackend } from '../backend';
import { Button, Box, Table } from '../components';
import { Window } from '../layouts';

const defaultTemplate = ({ column, row }) => row[column.field];

interface Column {
  name: string,
  field: string,
  template?: ({ row, column: Column }) => InfernoNode,
}

const columns: Column[] = [
  { name: 'CKey', field: 'ckey' },
  { name: 'Name', field: 'name' },
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
          {players.map(player => (
            <Table.Row>
              {columns.map(column => {
                const {
                  field,
                  template = defaultTemplate,
                } = column;
                <Table.Cell key={field}>
                  {template({
                    column,
                    row: player,
                   })}
                </Table.Cell>
              })}
            </Table.Row>
          ))}
        </Table>
      </Window.Content>
    </Window>
  );
};

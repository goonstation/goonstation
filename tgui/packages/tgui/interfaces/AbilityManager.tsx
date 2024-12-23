/**
 * @file
 * @copyright 2023
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { Box, Button, NumberInput, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface NumberInputCellProps {
  number: number;
  unit?: string;
  onChange: (abilityRef: string, value: number) => void;
  abilityRef: string;
}

const NumberInputCell = ({
  number,
  unit,
  onChange,
  abilityRef,
}: NumberInputCellProps) => (
  <Table.Cell py="0.5em" collapsing>
    <Box align="center">
      <NumberInput
        minValue={0}
        maxValue={Infinity}
        unit={unit}
        width="5em"
        value={number}
        step={1}
        onChange={(value) => onChange(abilityRef, value)}
      />
    </Box>
  </Table.Cell>
);

const HeaderCell = ({ children }) => (
  <Table.Cell py="0.5em" textAlign="center">
    {children}
  </Table.Cell>
);

const HeaderRow = () => (
  <Table.Row bold>
    <HeaderCell>Name</HeaderCell>
    <HeaderCell>Subtype</HeaderCell>
    <HeaderCell>Cost</HeaderCell>
    <HeaderCell>Cooldown</HeaderCell>
    <HeaderCell>Actions</HeaderCell>
  </Table.Row>
);

interface AbilityManagerData {
  abilities;
  target_name;
}

export const AbilityManager = () => {
  const { act, data } = useBackend<AbilityManagerData>();
  const { abilities, target_name } = data;

  // Defining the actions that can be performed from the UI.
  const addAbility = () => act('addAbility');
  const updatePointCost = (abilityRef, value) =>
    act('updatePointCost', { abilityRef, value });
  const updateCooldown = (abilityRef, value) =>
    act('updateCooldown', { abilityRef, value });
  const manageAbility = (abilityRef) => act('manageAbility', { abilityRef });
  const renameAbility = (abilityRef) => act('renameAbility', { abilityRef });
  const deleteAbility = (abilityRef) => act('deleteAbility', { abilityRef });

  return (
    <Window title="Ability Manager" width={750} height={300}>
      <Window.Content>
        <Section
          title={`Abilities of ${target_name}`}
          scrollable
          fill
          buttons={
            /* Button for adding a new Ability */
            <Button icon="plus" onClick={addAbility}>
              Add Ability
            </Button>
          }
        >
          {/* Table for displaying existing Abilities */}
          <Table>
            {/* Display our tables header, even if we don't have any abilities. */}
            <HeaderRow />
            {/* Map through the list of abilities and render a table row for each. */}
            {abilities?.length > 0
              ? abilities.map((ability) => (
                  <Table.Row key={ability.abilityRef}>
                    <Table.Cell py="0.5em">{ability.name}</Table.Cell>
                    <Table.Cell py="0.5em">{ability.subtype}</Table.Cell>
                    <NumberInputCell
                      number={ability.pointCost}
                      onChange={updatePointCost}
                      abilityRef={ability.abilityRef}
                    />
                    <NumberInputCell
                      number={ability.cooldown}
                      unit="ds"
                      onChange={updateCooldown}
                      abilityRef={ability.abilityRef}
                    />
                    {/* Buttons for managing and deleting the ability */}
                    <Table.Cell py="0.5em" collapsing>
                      <Box align="center" nowrap>
                        <Button
                          tooltip="View Variables"
                          tooltipPosition="top"
                          align="left"
                          icon="gear"
                          onClick={() => manageAbility(ability.abilityRef)}
                        />
                        <Button
                          tooltip="Rename"
                          tooltipPosition="top"
                          align="left"
                          icon="pen"
                          onClick={() => renameAbility(ability.abilityRef)}
                        />
                        <Button.Confirm
                          tooltip="Remove"
                          tooltipPosition="top"
                          align="left"
                          icon="trash"
                          color="bad"
                          onClick={() => deleteAbility(ability.abilityRef)}
                        />
                      </Box>
                    </Table.Cell>
                  </Table.Row>
                ))
              : null}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};

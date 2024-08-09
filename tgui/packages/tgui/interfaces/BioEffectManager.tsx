/**
 * @file
 * @copyright 2023
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { Box, Button, NumberInput, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// Pass the id to the callbacks
const CheckboxCell = ({ checked, onClick, id }) => (
  <Table.Cell py="0.5em" collapsing>
    <Box align="center">
      <Button.Checkbox
        checked={checked}
        width="5em"
        onClick={() => onClick(id)}
      />
    </Box>
  </Table.Cell>
);

const NumberInputCell = ({ number, unit, onChange, id }) => (
  <Table.Cell py="0.5em" collapsing>
    <Box align="center">
      <NumberInput
        minValue={0}
        maxValue={Infinity}
        unit={unit}
        width="5em"
        value={number}
        step={1}
        onChange={(value) => onChange(id, value)}
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
    <HeaderCell>ID</HeaderCell>
    <HeaderCell>Stable</HeaderCell>
    <HeaderCell>Reinforced</HeaderCell>
    <HeaderCell>Boosted</HeaderCell>
    <HeaderCell>Synced</HeaderCell>
    <HeaderCell>Cooldown</HeaderCell>
    <HeaderCell>Actions</HeaderCell>
  </Table.Row>
);

interface BioEffectManagerData {
  bioEffects;
  stability;
  target_name;
}

export const BioEffectManager = () => {
  const { act, data } = useBackend<BioEffectManagerData>();
  const { bioEffects, stability, target_name } = data;

  // Defining the actions that can be performed from the UI.
  const addBioEffect = () => act('addBioEffect');
  const updateCooldown = (id, value) => act('updateCooldown', { id, value });
  const updateStability = (value) => act('updateStability', { value });
  const toggleBoosted = (id) => act('toggleBoosted', { id });
  const toggleReinforced = (id) => act('toggleReinforced', { id });
  const toggleStabilized = (id) => act('toggleStabilized', { id });
  const toggleSynced = (id) => act('toggleSynced', { id });
  const manageBioEffect = (id) => act('manageBioEffect', { id });
  const deleteBioEffect = (id) => act('deleteBioEffect', { id });

  return (
    <Window title="Bioeffect Manager" width={750} height={300}>
      <Window.Content>
        <Section
          title={`Bioeffects of ${target_name}`}
          scrollable
          fill
          buttons={
            <>
              {/* Input and button for managing Stability */}
              Stability:
              <NumberInput
                minValue={0}
                maxValue={Infinity}
                width="5em"
                step={1}
                value={stability}
                onChange={(value) => updateStability(value)}
              />
              {/* Button for adding a new Bioeffect */}
              <Button icon="plus" onClick={addBioEffect}>
                Add Bioeffect
              </Button>
            </>
          }
        >
          {/* Table for displaying existing Bioeffects */}
          <Table>
            {/* Display our tables header, even if we don't have any effects. */}
            <HeaderRow />
            {/* Map through the list of bioEffects and render a table row for each. */}
            {bioEffects?.length > 0
              ? bioEffects.map((effect) => (
                  <Table.Row key={effect.id}>
                    <Table.Cell py="0.5em">{effect.name}</Table.Cell>
                    <Table.Cell py="0.5em" collapsing>
                      {effect.id}
                    </Table.Cell>
                    <CheckboxCell
                      checked={effect.stabilized}
                      onClick={toggleStabilized}
                      id={effect.id}
                    />
                    <CheckboxCell
                      checked={effect.reinforced}
                      onClick={toggleReinforced}
                      id={effect.id}
                    />
                    <CheckboxCell
                      checked={effect.boosted}
                      onClick={toggleBoosted}
                      id={effect.id}
                    />
                    <CheckboxCell
                      checked={effect.synced}
                      onClick={toggleSynced}
                      id={effect.id}
                    />
                    <NumberInputCell
                      number={effect.cooldown}
                      unit="ds"
                      onChange={updateCooldown}
                      id={effect.id}
                    />
                    {/* Buttons for managing and deleting the bioeffect */}
                    <Table.Cell py="0.5em" collapsing>
                      <Box align="center" nowrap>
                        <Button
                          tooltip="View Variables"
                          tooltipPosition="top"
                          align="left"
                          icon="gear"
                          onClick={() => manageBioEffect(effect.id)}
                        />
                        <Button.Confirm
                          tooltip="Remove"
                          tooltipPosition="top"
                          align="left"
                          icon="trash"
                          color="bad"
                          onClick={() => deleteBioEffect(effect.id)}
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

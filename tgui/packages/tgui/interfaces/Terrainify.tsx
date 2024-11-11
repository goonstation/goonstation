/**
 * Copyright (c) 2022 @Azrun
 * SPDX-License-Identifier: MIT
 */

import { Box, Button, Flex, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const TerrainChoice = (props) => {
  const { typeData, terrain, onTerrainValue } = props;

  return (
    <Flex.Item mb={1}>
      <Flex direction="column">
        <Section title="Types">
          {Object.keys(typeData).map((terrainType, buttonIndex) => (
            <Flex.Item mb={1} key={buttonIndex}>
              <Button
                fluid
                selected={terrain === terrainType}
                onClick={() => onTerrainValue(terrainType)}
              >
                {typeData[terrainType].name}
              </Button>
            </Flex.Item>
          ))}
        </Section>
      </Flex>
    </Flex.Item>
  );
};

export const TerrainVehicleChoice = (props) => {
  const {
    fabricator,
    cars,
    allowVehicles,
    onToggleFabricators,
    onToggleCars,
    onToggleAllowVehicles,
  } = props;

  return (
    <Flex.Item>
      <Section title="Vehicle Options">
        <Button.Checkbox
          checked={fabricator}
          onClick={() => onToggleFabricators()}
        >
          Add Subs to Fabricators
        </Button.Checkbox>
        <br />
        <Button.Checkbox checked={cars} onClick={() => onToggleCars()}>
          Convert some Cars
        </Button.Checkbox>
        <Button.Checkbox
          checked={allowVehicles}
          onClick={() => onToggleAllowVehicles()}
        >
          Allow Pods
        </Button.Checkbox>
      </Section>
    </Flex.Item>
  );
};

export const TerrainToggles = (props) => {
  const { terrain, typeData, activeToggles, onToggle } = props;

  return terrain &&
    typeData[terrain].toggles &&
    Object.keys(typeData[terrain].toggles).length ? (
    <Section title="Toggles">
      {Object.keys(typeData[terrain].toggles).map(
        (toggleOption, buttonIndex) => (
          <Flex.Item mb={1} key={buttonIndex}>
            <Button.Checkbox
              checked={activeToggles[toggleOption]}
              onClick={() => onToggle(toggleOption)}
            >
              {toggleOption}
            </Button.Checkbox>
          </Flex.Item>
        ),
      )}
    </Section>
  ) : (
    ''
  );
};

export const TerrainOptions = (props) => {
  const { terrain, typeData, activeOptions, onSelect } = props;

  return terrain &&
    typeData[terrain].options &&
    Object.keys(typeData[terrain].options).length
    ? Object.keys(typeData[terrain].options).map((toggleType, sectionIndex) => (
        <Section title={toggleType} key={sectionIndex}>
          {typeData[terrain].options[toggleType].map(
            (toggleOption, buttonIndex) => (
              <Flex.Item mb={1} key={buttonIndex}>
                <Button
                  fluid
                  selected={activeOptions[toggleType] === toggleOption}
                  onClick={() => onSelect(toggleType, toggleOption)}
                >
                  {toggleOption}
                </Button>
              </Flex.Item>
            ),
          )}
        </Section>
      ))
    : '';
};

interface TerrainifyData {
  typeData;
  terrain;
  fabricator;
  cars;
  allowVehicles;
  locked;
  activeOptions;
  activeToggles;
}

export const Terrainify = () => {
  const { act, data } = useBackend<TerrainifyData>();
  const {
    typeData,
    terrain,
    fabricator,
    cars,
    allowVehicles,
    locked,
    activeOptions,
    activeToggles,
  } = data;

  const handleToggleCars = () => {
    act('cars');
  };

  const handleToggleFabs = () => {
    act('fabricator');
  };

  const handleToggleAllowVehicles = () => {
    act('allowVehicles');
  };

  const handleToggleGeneric = (toggle) => {
    act('toggle', {
      toggle,
    });
  };

  const handleOptionGeneric = (key, value) => {
    act('option', {
      key: key,
      value: value,
    });
  };

  const handleSetTerrain = (terrain) => {
    act('terrain', {
      terrain,
    });
  };

  return (
    <Window title="Terrainify" width={500} height={600}>
      <Window.Content scrollable>
        <Section title="Terrainify">
          <Flex direction="row">
            <TerrainChoice
              typeData={typeData}
              terrain={terrain}
              onTerrainValue={handleSetTerrain}
            />
            <Flex.Item ml={2} />
            <Flex.Item ml={1}>
              <Section title="Description">
                {!terrain ? '...' : typeData[terrain].description}
              </Section>
              <TerrainVehicleChoice
                fabricator={fabricator}
                cars={cars}
                allowVehicles={allowVehicles}
                onToggleAllowVehicles={handleToggleAllowVehicles}
                onToggleFabricators={handleToggleFabs}
                onToggleCars={handleToggleCars}
              />
              <TerrainToggles
                typeData={typeData}
                terrain={terrain}
                activeToggles={activeToggles}
                onToggle={handleToggleGeneric}
              />
              <TerrainOptions
                typeData={typeData}
                terrain={terrain}
                activeOptions={activeOptions}
                onSelect={handleOptionGeneric}
              />
            </Flex.Item>
          </Flex>
          <Box m={1}>
            <Button fluid disabled={locked} onClick={() => act('activate')}>
              Transform Station
            </Button>
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};

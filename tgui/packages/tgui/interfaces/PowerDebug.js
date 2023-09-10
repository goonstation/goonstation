/**
 * Copyright (c) 2022 @Azrun
 * SPDX-License-Identifier: MIT
 */

import { useBackend } from '../backend';
import { Box, Button, Flex, Section } from '../components';
import { Window } from '../layouts';

export const AreaData = props => {
  const {
    areaData,
  } = props;

  return (
    <Flex.Item mb={1}>
      <Flex direction="column">
        {Object.keys(areaData).map((areaType, Index) => (
          <Flex.Item mb={1} key={Index}>
            <Section title={areaData[areaType].name} >
              {(!areaData[areaType].total) ? 'NO APC' : (
                <Flex justify="space-between">
                  <Flex.Item>Total:{areaData[areaType].total} </Flex.Item>
                  <Flex.Item>Equip:{areaData[areaType].equip}</Flex.Item>
                  <Flex.Item>Light:{areaData[areaType].light} </Flex.Item>
                  <Flex.Item>Environ:{areaData[areaType].environ}</Flex.Item>
                </Flex>
              )}
            </Section>
            <MachineData
              machineData={areaData[areaType].machines} />
          </Flex.Item>
        ))}
      </Flex>
    </Flex.Item>
  );
};

export const MachineData = (props, context) => {
  const { act } = useBackend(context);
  const {
    machineData,
  } = props;

  const handleJMP = (ref) => {
    act("jmp", {
      ref: ref,
    });
  };

  return (
    Object.keys(machineData).map((machine, index) => (
      <Flex direction="row" key={index}>
        <Flex.Item>
          <Button
            onClick={() => handleJMP(machine)}
          >
            JMP
          </Button>
        </Flex.Item>
        <Flex.Item basis={20.0}>
          {machineData[machine].name}
        </Flex.Item>
        <Flex.Item basis={8.0}>
          {machineData[machine].data}
        </Flex.Item>
        <Flex.Item>
          {machineData[machine].power_usage}
        </Flex.Item>

      </Flex>
    ))
  );
};

export const PowerDebug = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    areaData,
  } = data;

  return (
    <Window
      title="PowerDebug"
      width={500}
      height={600}>
      <Window.Content scrollable>
        <Section
          title={
            <Box
              inline>
              Power Debug
            </Box>
          }>
          <Flex direction="row">
            <AreaData
              areaData={areaData} />
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};

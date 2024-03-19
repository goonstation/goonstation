/**
 * Copyright (c) 2022 @Azrun
 * SPDX-License-Identifier: MIT
 */

import { useBackend } from '../backend';
import { Box, Button, Dropdown, Flex, NumberInput, Section } from '../components';
import { Window } from '../layouts';

export const CAViewer = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    CAType,
    CAData,
    viewWidth,
    typeData,
    settings,
  } = data;

  return (
    <Window
      title="Cellular Automata Viewer"
      width={900}
      height={800}>
      <Window.Content scrollable>
        <Section
          title={
            <Box
              inline>
              {CAType}
            </Box>
          }
          buttons={(
            <Dropdown
              displayText="CA Type"
              width={20}
              options={Object.keys(typeData)}
              onSelected={value => act('set_ca', {
                name: 'default',
                priority: 10,
                type: value,
              })} />
          )}
        >
          <Flex direction="row">
            <Flex.Item ml={2} />
            <Flex.Item ml={1}>
              <Section title="Description" >
                {"Description Goes here?"}
              </Section>
            </Flex.Item>
            <Flex.Item ml={4} />
            {(
              CAType && typeData[CAType].options && Object.keys(typeData[CAType].options).length ? (
                Object.keys(typeData[CAType].options).map((optionName, sectionIndex) => (
                  <Section title={typeData[CAType].options[optionName]} key={sectionIndex}>
                    <NumberInput
                      value={settings[typeData[CAType].options[optionName]]}
                      minValue={0}
                      maxValue={500}
                      stepPixelSize={5}
                      width="39px"
                      onDrag={(e, value) => act('settings', {
                        name: typeData[CAType].options[optionName],
                        data: value })}
                    />
                    {}
                  </Section>
                ))
              )
                : ""
            )}
          </Flex>
          <Box m={1}>
            <Button
              fluid
              onClick={() => act("generate")}
            >
              Generate
            </Button>
          </Box>
          <Section>
            <Box
              preserveWhitespace
              fontFamily="Consolas">
              {CAData.replace(/0/g, '-').replace(/(.{100})/g, "$1\n")}
            </Box>
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};

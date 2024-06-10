/**
 * Copyright (c) 2022 @Azrun
 * SPDX-License-Identifier: MIT
 */

import { useBackend } from '../backend';
import { Box, Button, Dropdown, NumberInput, Section, Stack } from '../components';
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

  const width_replace = '(.{' + viewWidth + '})';
  const width_re = new RegExp(width_replace, "g");
  let CAText = CAData;
  CAText = CAText.replace(/0/g, '▫');
  CAText = CAText.replace(/1/g, '■');
  CAText = CAText.replace(width_re, "$1\n");

  return (
    <Window
      title="Cellular Automata Viewer"
      width={1600}
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
          {typeData[CAType].description}
          <Stack>
            {(
              CAType && typeData[CAType].options && Object.keys(typeData[CAType].options).length ? (
                Object.keys(typeData[CAType].options).map((optionName, sectionIndex) => (
                  <Stack.Item key={sectionIndex}>
                    <Section title={typeData[CAType].options[optionName]} >
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
                    </Section>
                  </Stack.Item>
                ))
              )
                : ""
            )}
          </Stack>
          <Section title="Command" >
            {`${typeData[CAType].function}(`}
            {Object.keys(typeData[CAType].options).map((optionName, sectionIndex) =>
              `"${settings[typeData[CAType].options[optionName]]}"${sectionIndex < Object.keys(typeData[CAType].options).length-1 ? ", " : ""}`)}
            {`)`}
          </Section>
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
              style={{ "font-size": "9px", "line-height": "5px" }}
              fontFamily="Consolas"
            >
              {CAText}
            </Box>
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};

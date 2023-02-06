/**
 * @file
 * @copyright 2022 Y0SH1M4S73R (https://github.com/Y0SH1M4S73R)
 * @author Original Y0SH1M4S73R (https://github.com/Y0SH1M4S73R)
 * @author Changes ZeWaka (https://github.com/ZeWaka)
 * @license MIT
 */

import { useBackend } from '../backend';
import { toFixed } from 'common/math';
import { Box, Stack, Section, ByondUi, NumberInput, Button } from '../components';
import { Window } from '../layouts';

interface ColorMatrixEditorData {
  previewRef: string;
  targetIsClient: boolean;
  currentColor: string[][];
}

export const ColorMatrixEditor = (props, context) => {
  const { act, data } = useBackend<ColorMatrixEditorData>(context);
  const [
    [rr, rg, rb, ra],
    [gr, gg, gb, ga],
    [br, bg, bb, ba],
    [ar, ag, ab, aa],
    [cr, cg, cb, ca],
  ] = data.currentColor;
  const prefixes = ['r', 'g', 'b', 'a', 'c'];
  return (
    <Window
      title="Color Matrix Editor"
      width={560}
      height={245}>
      <Window.Content>
        <Stack fill>
          <Stack.Item align="center">
            <Stack fill vertical>
              <Stack.Item grow />
              <Stack.Item>
                <Section>
                  <Stack>
                    {[0, 1, 2, 3].map((col, key) => (
                      <Stack.Item key={key}>
                        <Stack vertical>
                          {[0, 1, 2, 3, 4].map((row, key) => (
                            <Stack.Item
                              key={key}>
                              <Box
                                inline
                                textColor="label"
                                width="2.1rem">
                                {`${prefixes[row]}${prefixes[col]}:`}
                              </Box>
                              <NumberInput
                                inline
                                value={data.currentColor[row*4+col]}
                                step={0.01}
                                width="50px"
                                format={value => toFixed(value, 2)}
                                onDrag={(_e, value: string[]) => {
                                  let retColor = data.currentColor;
                                  retColor[row*4+col] = value;
                                  act("transition_color", { color: retColor });
                                }} />
                            </Stack.Item>
                          ))}
                        </Stack>
                      </Stack.Item>
                    ))}
                  </Stack>
                </Section>
              </Stack.Item>
              <Stack.Item grow />
              <Stack.Item align="left">
                <Button.Confirm
                  content="Confirm"
                  confirmContent="Confirm?"
                  onClick={() => act("confirm")} />
                {
                  data.targetIsClient
                    ? (
                      <>
                        <Button
                          content="Preview Color"
                          onClick={() => act("client-preview")} />
                        <Button
                          content="Reset Your Color"
                          onClick={() => act("client-reset")} />
                      </>
                    )
                    : ''
                }
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow>
            <ByondUi
              params={{
                id: data.previewRef,
                type: 'map',
              }}
              style={{
                height: '100%',
              }}
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

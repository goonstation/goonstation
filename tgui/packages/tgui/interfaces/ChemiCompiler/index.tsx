/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license ISC
 */

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { ChemiCompilerData } from './type';
import { Button, Icon, Section, Stack, TextArea } from '../../components';

export const ChemiCompiler = (_props, context) => {
  const { act, data } = useBackend<ChemiCompilerData>(context);
  const { reservoirs, buttons, inputValue, loadTimestamp, sx, tx, ax } = data;

  return (
    <Window width={600} height={475}>
      <Window.Content>
        <Stack fill>
          <Stack.Item grow>
            <TextArea
              value={inputValue}
              onInput={(_event, value) => { act('updateInputValue', { value }); }}
              grow
              height="100%"
              width={'100%'}
              // The load button would break if we pressed it between the input's act and the next refresh.
              // This ensures a refresh after every load button click
              key={loadTimestamp}
              fontFamily="Consolas"
              fontSize="13px"
              style={{ "word-break": "break-all" }}
            />
          </Stack.Item>
          <Stack.Item basis={18} textAlign="center">
            <Section title="Reservoirs">
              <Stack wrap justify="center">
                {reservoirs.map((reservoir, index) => (
                  <Stack.Item key={index} m={0.5}>
                    <Button
                      key={index}
                      onClick={() => act('reservoir', { index })}
                      width={7}
                      tooltip={reservoir && "Eject"}>
                      {
                        reservoir
                          ? <><Icon name="eject" /> {reservoir}</>
                          : "None"
                      }
                    </Button>
                  </Stack.Item>
                ))}
              </Stack>
            </Section>

            <Section title="Memory">
              SX: <em>{sx}</em> -
              AX: <em>{tx}</em> -
              TX: <em>{ax}</em>
              <Stack wrap>
                {buttons.map((button, index) => (
                  <Stack.Item key={index} style={{ border: "1px solid white", "border-radius": "0.2rem" }} p={1} m={1}>
                    M{index+1}<br />
                    <Button
                      onClick={() => act('save', { index })}
                      tooltip="Save"
                      color="blue"
                      icon="save" />
                    <Button
                      onClick={() => act('load', { index })}
                      tooltip="Load"
                      color="yellow"
                      icon="download"
                      disabled={!button.button} />
                    <Button
                      onClick={() => act('run', { index })}
                      tooltip="Run"
                      color="green"
                      icon="play"
                      disabled={!button.cbf} />
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license ISC
 */

import { useBackend } from '../../backend';
import { ChemiCompilerData } from './type';
import { Button, Section, Stack } from '../../components';

export const ChemiCompilerMemory = (_props, context) => {
  const { act, data } = useBackend<ChemiCompilerData>(context);
  const { buttons, sx, tx, ax, theme } = data;
  return (
    <Section title="Memory">
      <Stack>
        <Stack.Item grow>
          sx: {sx}
        </Stack.Item>
        <Stack.Item grow>
          tx: {tx}
        </Stack.Item>
        <Stack.Item grow>
          ax: {ax}
        </Stack.Item>
      </Stack>
      <Stack wrap justify="space-around" mt={1}>
        {buttons.map((button, index) => (
          <Stack.Item key={index} ml={0}>
            <Section title={`M${index+1}`}>
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
            </Section>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

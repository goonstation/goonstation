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
  const { buttons, sx, tx, ax } = data;
  return (
    <Section title="Memory">
      sx: <em>{sx}</em> -
      ax: <em>{tx}</em> -
      tx: <em>{ax}</em>
      <Stack wrap>
        {buttons.map((button, index) => (
          <Stack.Item key={index} style={{ border: "1px solid #88bfff", "border-radius": "0.2rem" }} p={1} m={1}>
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
  );
};

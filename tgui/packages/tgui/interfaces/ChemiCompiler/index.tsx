/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license ISC
 */

import { useBackend, useLocalState } from '../../backend';
import { Window } from '../../layouts';
import { ChemiCompilerData } from './type';
import { Button, Input } from '../../components';

export const ChemiCompiler = (_props, context) => {
  const { act, data } = useBackend<ChemiCompilerData>(context);
  const { reservoirs, buttons, output, sx, tx, ax } = data;
  const [input, setInput] = useLocalState(context, 'input', '');

  return (
    <Window width={400} height={325}>
      <Window.Content>
        Reservoirs:<br />
        {reservoirs.map((reservoir, index) => (
          <Button
            key={index}
            onClick={() => act('reservoir', { index })}>
            {reservoir ? "**Eject" : "None"}
          </Button>
        ))} <br />

        Memory:<br />
        {buttons.map((button, index) => (
          <>
            M{index+1}
            <Button
              onClick={() => act('save', { index, input })}>
              Save
            </Button>
            <Button
              onClick={() => act('load', { index })}>
              Load
            </Button>
            <Button
              onClick={() => act('run', { index })}>
              Run
            </Button>
            <br />
          </>
        ))}

        <Input
          value={output || input}
          onInput={(_event, value) => { setInput(value); }}
          height={7}
          width={'100%'} />
        <br />

        output: {output} /
        input: {input} /
        sx: {sx} /
        tx: {tx} /
        ax: {ax}

      </Window.Content>
    </Window>
  );
};

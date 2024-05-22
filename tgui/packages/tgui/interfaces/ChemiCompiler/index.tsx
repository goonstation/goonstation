/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license ISC
 */

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { ChemiCompilerData } from './type';
import { Button, Input } from '../../components';

export const ChemiCompiler = (_props, context) => {
  const { act, data } = useBackend<ChemiCompilerData>(context);
  const { reservoirs, buttons, inputValue, loadTimestamp, sx, tx, ax } = data;

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
              onClick={() => act('save', { index })}>
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
          value={inputValue}
          onInput={(_event, value) => { act('updateInputValue', { value }); }}
          height={7}
          width={'100%'}
          // The load button would break if we pressed it between the input's act and the next refresh.
          // This ensures a refresh after every load button click
          key={loadTimestamp}
        />
        <br />

        inputValue: {inputValue} /
        sx: {sx} /
        tx: {tx} /
        ax: {ax}

      </Window.Content>
    </Window>
  );
};

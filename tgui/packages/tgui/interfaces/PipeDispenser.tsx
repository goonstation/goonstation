/**
 * @file
 * @copyright 2023
 * @author cringe (https://github.com/Laboredih123)
 * @license MIT
 */

import { useState } from 'react';
import { Box, Button, NumberInput, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { ProductList } from './common/ProductList';

interface PipeDispenserData {
  disposalpipes;
  dispenser_ready;
  windowName;
  mobile;
  removing_pipe;
  laying_pipe;
  max_disposal_pipes;
}

export const PipeDispenser = () => {
  const { data } = useBackend<PipeDispenserData>();
  const disposalpipes = data.disposalpipes || [];
  const {
    dispenser_ready,
    windowName,
    mobile,
    removing_pipe,
    laying_pipe,
    max_disposal_pipes,
  } = data;
  return (
    <Window title={windowName} width={375} height={mobile ? 350 : 255}>
      <Window.Content scrollable>
        <Section fitted>
          <ProductList showImage showOutput>
            {disposalpipes.map((disposalpipe) => {
              return (
                <DisposalPipeRow
                  key={disposalpipe.disposaltype}
                  dispenser_ready={dispenser_ready}
                  max_disposal_pipes={max_disposal_pipes}
                  disposalpipe={disposalpipe}
                />
              );
            })}
          </ProductList>
        </Section>
        {!!mobile && (
          <AutoPipeLaying
            laying_pipe={laying_pipe}
            removing_pipe={removing_pipe}
          />
        )}
      </Window.Content>
    </Window>
  );
};

export const DisposalPipeRow = (props) => {
  const { act } = useBackend();
  const [amount, setAmount] = useState(1);
  const { dispenser_ready, max_disposal_pipes, disposalpipe } = props;

  return (
    <ProductList.Item
      image={disposalpipe.image}
      extraCellsSlot={
        <ProductList.Cell align="right">
          <Box inline>Amount:</Box>
          <NumberInput
            value={amount}
            minValue={1}
            maxValue={max_disposal_pipes}
            step={1}
            onChange={(value) => setAmount(Math.round(value))}
          />
        </ProductList.Cell>
      }
      outputSlot={
        <ProductList.OutputButton
          disabled={!dispenser_ready}
          icon="gears"
          onClick={() => {
            act('dmake', {
              disposal_type: disposalpipe.disposaltype,
              amount,
            });
          }}
        />
      }
    >
      {disposalpipe.disposaltype}
    </ProductList.Item>
  );
};

export const AutoPipeLaying = (props) => {
  const { act } = useBackend<PipeDispenserData>();
  const { laying_pipe, removing_pipe } = props;

  return (
    <Section title="Automatic Pipe Options">
      <Button
        color={laying_pipe ? 'average' : 'green'}
        fluid
        align="center"
        onClick={() => act('toggle_laying')}
      >
        {laying_pipe
          ? 'Stop Laying Pipe Automatically'
          : 'Start Laying Pipe Automatically'}
      </Button>
      <Button
        color={removing_pipe ? 'average' : 'green'}
        fluid
        align="center"
        onClick={() => act('toggle_removing')}
      >
        {removing_pipe
          ? 'Stop Removing Pipe Automatically'
          : 'Start Removing Pipe Automatically'}
      </Button>
    </Section>
  );
};

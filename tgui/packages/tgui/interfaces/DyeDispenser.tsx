/**
 * @file
 * @copyright 2023
 * @author Garash (https://github.com/Garash2k)
 * @license ISC
 */

import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { Button, ColorBox, Dimmer, Stack } from '../components';
import { ColorSelector } from './ColorPickerModal';
import { hexToHsva, HsvaColor, hsvaToHex } from 'common/color';

type DyeDispenserParams = {
  bottle: boolean,
  uses_left: number,
  bottle_color: string
};
const initialColor = "#FFFFFF";

export const DyeDispenser = (_props, context) => {
  const { act, data } = useBackend<DyeDispenserParams>(context);
  const { bottle, uses_left, bottle_color } = data;

  const isFilled = bottle && uses_left > 0;

  const handleEject = () => act('eject', { });
  const handleEmptyBottle = () => act('emptyb', { });
  const handleFillBottle = () => act('fillb', { selectedColor: hsvaToHex(selectedColor) });
  const handleInsertBottle = () => act('insertb', { });

  let [selectedColor, setSelectedColor] = useLocalState<HsvaColor>(context, 'color_picker_choice', hexToHsva(bottle_color || initialColor));

  return (
    <Window width={500} height={340}>
      <Window.Content>
        <Stack mb={1} textAlign="center">
          <Stack.Item grow>
            <Button
              fontSize={1.5} bold width="100%"
              onClick={handleFillBottle}>
              <ColorBox color={hsvaToHex(selectedColor)} mr={1} />
              Fill
            </Button>
          </Stack.Item>
          <Stack.Item grow>
            <Button
              fontSize={1.5} bold width="100%"
              onClick={handleEmptyBottle}
              icon="broom"
              disabled={!isFilled}>
              Empty
            </Button>
          </Stack.Item>
          <Stack.Item grow>
            <Button
              fontSize={1.5} bold width="100%"
              onClick={handleEject}
              icon="eject">
              Eject
            </Button>
          </Stack.Item>
        </Stack>

        <ColorSelector
          color={selectedColor}
          setColor={setSelectedColor}
          defaultColor={bottle_color || initialColor}
        />
        {!bottle && (
          <Dimmer>
            <Button
              fontSize={1.5} bold
              onClick={handleInsertBottle}
              icon="eject">
              Insert Dye Bottle
            </Button>
          </Dimmer>
        )}
      </Window.Content>
    </Window>
  );
};

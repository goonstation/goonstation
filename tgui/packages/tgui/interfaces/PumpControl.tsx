/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC (https://choosealicense.com/licenses/isc/)
 */

import { hexToRgba, RgbaColor, rgbaToHex } from 'common/color';
import { useBackend } from '../backend';
import { Box, Button, Slider, Stack } from '../components';
// import { DataInputOptions } from './common/DataInput';
import { Window } from '../layouts';

type PumpData = {
  net_id: string
  id: string;
  power_status: boolean;
  target_pressure: number;
  min_pressure: number;
  max_pressure: number;
  area_name: string;
}

type PumpList = {
  pump_list: PumpData[];
  frequency: number;
};

const PumpInformation = (_:any, context:any) => {
  const { data } = useBackend<PumpData>(context);
  const { pump } = _;
  return (
    <Box
      fontSize="15px"
      fontFamily="Monospace"
      bold
      textAlign="left"
      mb={1}
      style={{
        "border-width": "0.1em",
        "border-style": "solid",
        "padding": "5px",
        "padding-top": "1px",
      }}
    >
      <Stack>
        <Stack.Item grow={1}>
          {pump.id}
        </Stack.Item>
        <Stack.Item>{pump.area_name}</Stack.Item>
      </Stack>
      <Stack>
        <Stack.Item>
          <Button
            icon="fas fa-power-off" //
            backgroundColor={(pump.power_status === "on") ? "#11AA11" : "#AA1111"}
            onClick={() => togglePump()}
          />
        </Stack.Item>
        <Stack.Item grow>
          <Slider
            value={pump.target_pressure}
            minValue={pump.min_pressure}
            maxValue={pump.max_pressure}
            stepPixelSize={0.05}
          />
        </Stack.Item>
      </Stack>
    </Box>
  );
};

export const PumpControl = (props, context) => {
  const { act, data } = useBackend<PumpList>(context);
  let isLoading = true;

  return (
    <Window
      title="Pump Control Computer"
      width={400}
      height={500}>
      <Window.Content scrollable>
        {data.pump_list.map((p) => (
          <PumpInformation pump={p} key={p.net_id} />
        ))}
      </Window.Content>
    </Window>
  );

};

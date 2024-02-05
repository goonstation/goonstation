/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC (https://choosealicense.com/licenses/isc/)
 */

import { hexToRgba, RgbaColor, rgbaToHex } from 'common/color';
import { useBackend } from '../backend';
import { Box } from '../components';
//  import { DataInputOptions } from './common/DataInput';
import { Window } from '../layouts';

type PumpData = {
  net_id: string
  id: string;
  is_on: boolean;
  pressure_now: number;
  pressure_min: number;
  pressure_max: number;
  area: string;
  area_color: string;
}

type PumpList = {
  pump_list: PumpData[];
  frequency: number;
};

const PumpInformation = (_:any, context:any) => {
  const { data } = useBackend<PumpData>(context);
  return (
    <Box
      fontSize="25px"
      fontFamily="Courier"
      bold
      textAlign="center"
      padding="3px"
      backgroundColor={data.area_color}
      style={{
        "border-width": "0.1em",
        "border-style": "solid",
        "border-color": darkenHex(data.area_color, 10),
      }}
    >
      {data.id}

    </Box>
  );
};

const darkenHex = (hex:string, amt:number) => {
  let rgba:RgbaColor = hexToRgba(hex);
  rgba.r -= amt; rgba.g -= amt; rgba.b -= amt;
  return rgbaToHex(rgba);
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

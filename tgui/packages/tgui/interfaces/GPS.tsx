/**
 * @file
 * @copyright 2025
 * @author FlameArrow57 (https://github.com/FlameArrow57)
 * @license ISC
 */

import {
  Box,
  Button,
  Collapsible,
  Divider,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface GPSInfo {
  src_x: number;
  src_y: number;
  tracking: boolean;
  trackable: boolean;
  src_name: string;
  distress: boolean;
  gps_names: Array<string>;
  gps_coords: Array<string>;
  gps_distress: Array<string>;
  imp_names: Array<string>;
  imp_coords: Array<string>;
  warp_names: Array<string>;
  warp_coords: Array<string>;
  gps_refs: Array<string>;
}

const gpsTooltip =
  'Each GPS is coined with a unique four digit number followed by a four letter identifier.';

export const GPS = () => {
  const { act, data } = useBackend<GPSInfo>();
  const {
    src_x,
    src_y,
    tracking,
    trackable,
    src_name,
    distress,
    gps_names,
    gps_coords,
    gps_distress,
    imp_names,
    imp_coords,
    warp_names,
    warp_coords,
    gps_refs,
  } = data;

  return (
    <Window title="GPS" width={420} height={555} theme="ntos">
      <Window.Content>
        <Section title={`GPS Device ${src_name}`}>
          <Stack>
            <Stack.Item>
              <LabeledList>
                <LabeledList.Item label="Coordinates">
                  {src_x}, {src_y}
                </LabeledList.Item>
                <LabeledList.Item label="Identifier">
                  <Button
                    onClick={() => act('change_identifier')}
                    tooltip={gpsTooltip}
                  >
                    {src_name.slice(5, src_name.length)}
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Tracking">
                  <Button onClick={() => act('track_gps')}>
                    {tracking ? tracking : 'None'}
                  </Button>
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
            <Stack.Item>
              <LabeledList>
                <LabeledList.Item label="Trackable">
                  <Button.Checkbox onClick={() => act('toggle_trackable')} selected={trackable} checked={trackable}>
                    {trackable ? 'Yes' : 'No'}
                  </Button.Checkbox>
                </LabeledList.Item>
                <LabeledList.Item label="Send distress">
                  <Button.Checkbox onClick={() => act('toggle_distress')} selected={distress} checked={distress}>
                    {distress ? 'Yes' : 'No'}
                  </Button.Checkbox>
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
          </Stack>
        </Section>
        <Section title="Tracking">
          <Collapsible title="GPS Devices">
            {!!gps_names.length && (
              <Stack vertical>
                <TrackableList
                  gps_names={gps_names}
                  gps_coords={gps_coords}
                  gps_distress={gps_distress}
                  gps_refs={gps_refs}
                />
              </Stack>
            )}
          </Collapsible>
          <Collapsible title="Implants">
            {!!imp_names.length && (
              <Stack vertical>
                <TrackableList
                  gps_names={imp_names}
                  gps_coords={imp_coords}
                  gps_refs={gps_refs.slice(gps_names.length, gps_refs.length)}
                />
              </Stack>
            )}
          </Collapsible>
          <Collapsible title="Warp Beacons">
            {!!warp_names.length && (
              <Stack vertical>
                <TrackableList
                  gps_names={warp_names}
                  gps_coords={warp_coords}
                  gps_refs={gps_refs.slice(
                    gps_names.length + imp_names.length,
                    gps_refs.length,
                  )}
                />
              </Stack>
            )}
          </Collapsible>
        </Section>
      </Window.Content>
    </Window>
  );
};

let distress_red = false;
const TrackableList = (props) => {
  const { act } = useBackend();
  const { gps_names, gps_coords, gps_distress, gps_refs } = props;
  const nodes: JSX.Element[] = [];

  distress_red = !distress_red;

  for (let i = 0; i < gps_names.length; i++) {
    const node = (
      <Box key={i} fontSize={0.8}>
        <Stack.Item>
          <Stack>
            <Stack.Item grow>
              <Stack vertical>
                <Stack.Item><strong>{gps_names[i]}</strong></Stack.Item>
                <Stack.Item><em>{gps_coords[i]}</em></Stack.Item>
                {gps_distress && !!gps_distress[i] && (
                  <Stack.Item textColor={distress_red ? "red" : "default"}>Distress Alert</Stack.Item>
                )}
              </Stack>
            </Stack.Item>
            <Stack.Item align="center">
              <Button
                onClick={() => act('track_gps', { gps_ref: gps_refs[i] })}
                fontSize={1}
              >
                Track
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Divider />
      </Box>
    );
    nodes.push(node);
  }
  return nodes;
};

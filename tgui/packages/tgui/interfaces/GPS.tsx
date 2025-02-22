/**
 * @file
 * @copyright 2025
 * @author FlameArrow57 (https://github.com/FlameArrow57)
 * @license ISC
 */

import { BooleanLike } from 'common/react';
import {
  Box,
  Button,
  Collapsible,
  Divider,
  LabeledList,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface GPSInfo {
  src_x: number;
  src_y: number;
  track_x: number;
  track_y: number;
  tracking: BooleanLike;
  trackable: BooleanLike;
  src_name: string;
  distress: BooleanLike;
  gps_info: GPSTrackable[];
  imp_info: GPSTrackable[];
  warp_info: GPSTrackable[];
}

interface GPSTrackable {
  name: string;
  obj_ref: string;
  x: number;
  y: number;
  z_info: string;
  distress: BooleanLike | null;
}

const gpsTooltip =
  'Each GPS is coined with a unique four digit number followed by a four letter identifier.';

export const GPS = () => {
  const { act, data } = useBackend<GPSInfo>();
  const {
    src_x,
    src_y,
    track_x,
    track_y,
    tracking,
    trackable,
    src_name,
    distress,
    gps_info,
    imp_info,
    warp_info,
  } = data;

  return (
    <Window title="GPS" width={460} height={610} theme="ntos">
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
                <LabeledList.Item label="Coords">
                  x:{' '}
                  <NumberInput
                    value={track_x}
                    width="3"
                    minValue={1}
                    maxValue={300}
                    step={1}
                    onChange={(x_val: number) => act('set_x', { x: x_val })}
                  />
                  y:{' '}
                  <NumberInput
                    value={track_y}
                    width="3"
                    minValue={1}
                    maxValue={300}
                    step={1}
                    onChange={(y_val: number) => act('set_y', { y: y_val })}
                  />
                  <Button
                    mt={0.5}
                    onClick={() =>
                      act('track_coords', { x: track_x, y: track_y })
                    }
                  >
                    Track
                  </Button>
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
            <Stack.Item>
              <LabeledList>
                <LabeledList.Item label="Trackable">
                  <Button.Checkbox
                    onClick={() => act('toggle_trackable')}
                    selected={trackable}
                    checked={trackable}
                  >
                    {trackable ? 'Yes' : 'No'}
                  </Button.Checkbox>
                </LabeledList.Item>
                <LabeledList.Item label="Send distress">
                  <Button.Checkbox
                    onClick={() => act('toggle_distress')}
                    selected={distress}
                    checked={distress}
                  >
                    {distress ? 'Yes' : 'No'}
                  </Button.Checkbox>
                </LabeledList.Item>
                <LabeledList.Item label="Tracking">
                  <Button onClick={() => act('track_gps')}>
                    {tracking || 'None'}
                  </Button>
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
          </Stack>
        </Section>
        <Section title="Tracking">
          <Collapsible title="GPS Devices">
            {!!gps_info.length && <TrackableList gps_info={gps_info} />}
          </Collapsible>
          <Collapsible title="Implants">
            {!!imp_info.length && <TrackableList gps_info={imp_info} />}
          </Collapsible>
          <Collapsible title="Warp Beacons">
            {!!warp_info.length && <TrackableList gps_info={warp_info} />}
          </Collapsible>
        </Section>
      </Window.Content>
    </Window>
  );
};

let distress_red = false;
const TrackableList = (props) => {
  const { act } = useBackend();
  const { gps_info } = props;
  const nodes: JSX.Element[] = [];

  distress_red = !distress_red;

  for (let i = 0; i < gps_info.length; i++) {
    const node = (
      <Box key={i}>
        <Stack.Item>
          <Stack>
            <Stack.Item grow>
              <Stack vertical>
                <Stack.Item>
                  <strong>{gps_info[i].name}</strong>
                </Stack.Item>
                <Stack.Item>
                  <em>{`Located at (${gps_info[i].x}), (${gps_info[i].y}) | ${gps_info[i].z_info}`}</em>
                </Stack.Item>
                {gps_info[i].distress !== null && !!gps_info[i].distress && (
                  <Stack.Item textColor={distress_red ? 'red' : 'default'}>
                    Distress Alert
                  </Stack.Item>
                )}
              </Stack>
            </Stack.Item>
            <Stack.Item align="center">
              <Button
                onClick={() =>
                  act('track_gps', { gps_ref: gps_info[i].obj_ref })
                }
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
  return <Stack vertical>{nodes}</Stack>;
};

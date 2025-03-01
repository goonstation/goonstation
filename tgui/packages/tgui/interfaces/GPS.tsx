/**
 * @file
 * @copyright 2025
 * @author FlameArrow57 (https://github.com/FlameArrow57)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */
import { type BooleanLike } from 'common/react';
import { Fragment, memo, useCallback } from 'react';
import {
  Button,
  Collapsible,
  Icon,
  LabeledList,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface GPSData {
  src_x: number;
  src_y: number;
  track_x: number;
  track_y: number;
  tracking: BooleanLike;
  trackable: BooleanLike;
  src_name: string;
  distress: BooleanLike;
  gps_info: GPSTrackableData[];
  imp_info: GPSTrackableData[];
  warp_info: GPSTrackableData[];
}

interface GPSTrackableData {
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
  const { act, data } = useBackend<GPSData>();
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
    <Window title="GPS" width={490} height={610} theme="ntos">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
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
          </Stack.Item>
          <Stack.Item grow>
            <Section title="Tracking" scrollable fill>
              <Collapsible title="GPS Devices">
                <TrackableList gps_info={gps_info} />
              </Collapsible>
              <Collapsible title="Implants">
                <TrackableList gps_info={imp_info} />
              </Collapsible>
              <Collapsible title="Warp Beacons">
                <TrackableList gps_info={warp_info} />
              </Collapsible>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

interface TrackableListProps {
  gps_info: GPSTrackableData[];
}

const TrackableList = (props: TrackableListProps) => {
  const { act } = useBackend();
  const { gps_info } = props;
  const handleTrack = useCallback(
    (gps_ref: string) => act('track_gps', { gps_ref }),
    [act],
  );
  return gps_info.length ? (
    <Stack vertical>
      {gps_info.map((item) => (
        <Fragment key={item.obj_ref}>
          <TrackableItem {...item} onTrack={handleTrack} />
          <Stack.Divider />
        </Fragment>
      ))}
    </Stack>
  ) : (
    'None found'
  );
};

type TrackableItemProps = GPSTrackableData & {
  onTrack: (gpsRef: string) => void;
};

const TrackableItem = memo((props: TrackableItemProps) => {
  const { distress, name, obj_ref, onTrack, x, y, z_info } = props;
  const handleTrackClick = useCallback(
    () => onTrack(obj_ref),
    [onTrack, obj_ref],
  );
  return (
    <Stack.Item>
      <Stack>
        <Stack.Item grow>
          <Stack vertical>
            <Stack.Item>
              <Stack>
                <Stack.Item bold>{name}</Stack.Item>
                {!!distress && (
                  <Stack.Item
                    className={distress ? 'color-orange--blinking' : undefined}
                  >
                    <Icon mr={1} name="exclamation-triangle" />
                    In Distress
                  </Stack.Item>
                )}
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <em>{`Located at (${x}, ${y}) | ${z_info}`}</em>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item align="center">
          <Button onClick={handleTrackClick}>Track</Button>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
});

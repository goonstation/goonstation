/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MyNameIsRomayne)
 * @license ISC (https://choosealicense.com/licenses/isc/)
 */

import { BooleanLike } from 'common/react';
import {
  Button,
  LabeledList,
  Section,
  Slider,
  Stack,
} from 'tgui-core/components';

type ManufacturerSettingsProps = {
  repeat: BooleanLike;
  hacked: BooleanLike;
  speed: number;
  max_speed_normal: number;
  max_speed_hacked: number;
  mode: 'working' | 'halt' | 'ready';
  onSpeedSet: (speed: number) => void;
  onRepeatToggle: () => void;
};

export const ManufacturerSettings = (props: ManufacturerSettingsProps) => {
  const {
    repeat,
    hacked,
    speed,
    max_speed_normal,
    max_speed_hacked,
    mode,
    onSpeedSet,
    onRepeatToggle,
  } = props;

  const max_speed = hacked ? max_speed_hacked : max_speed_normal;

  return (
    <Stack.Item>
      <Section textAlign="center" title="Fabricator Settings">
        <LabeledList>
          <LabeledList.Item
            label="Repeat"
            buttons={
              <Button icon="repeat" onClick={onRepeatToggle}>
                Toggle Repeat
              </Button>
            }
            textAlign="center"
          >
            {repeat ? 'On' : 'Off'}
          </LabeledList.Item>
          <LabeledList.Item label="Speed">
            <Stack>
              <Stack.Item>
                <Button
                  icon="angle-double-left"
                  onClick={() => onSpeedSet(1)}
                />
              </Stack.Item>
              <Stack.Item grow>
                <Slider
                  minValue={1}
                  value={speed}
                  maxValue={max_speed}
                  step={1}
                  stepPixelSize={50}
                  onChange={(_e: any, value: number) => onSpeedSet(value)}
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="angle-double-right"
                  onClick={() => onSpeedSet(max_speed)}
                />
              </Stack.Item>
            </Stack>
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Stack.Item>
  );
};

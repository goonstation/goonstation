/**
 * @file
 * @copyright 2025
 * @author ZeWaka (https://github.com/ZeWaka)
 * @license MIT
 */

import { useEffect, useMemo, useState } from 'react';
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { ByondDir, DIR_TO_ANGLE } from '../common/directions';
import { Window } from '../layouts';
import { ListSearch } from './common/ListSearch';

interface ObjectCreatorData {
  types: string[];
  root: string; // textual path ("/obj" | "/mob" | "/turf")
  world_max_x: number;
  world_max_y: number;
  world_max_z: number;
  picked_x?: number;
  picked_y?: number;
  picked_z?: number;
}

export const ObjectCreator = () => {
  const { data, act } = useBackend<ObjectCreatorData>();
  const [selected, setSelected] = useState<string[]>([]);
  const [offsetType, setOffsetType] = useState<'relative' | 'absolute'>(
    'relative',
  );
  const [x, setX] = useState(0);
  const [y, setY] = useState(0);
  const [z, setZ] = useState(0);
  const [count, setCount] = useState(1);
  const [dir, setDir] = useState<ByondDir>(ByondDir.South);

  // Update coordinates when picked from backend
  useEffect(() => {
    const { picked_x, picked_y, picked_z } = data;
    if (picked_x && picked_y && picked_z) {
      setOffsetType('absolute');
      setX(picked_x);
      setY(picked_y);
      setZ(picked_z);
    }
  }, [data.picked_x, data.picked_y, data.picked_z]);

  const MAX_SELECTION = 5;

  const toggleSelect = (path: string) => {
    setSelected((prev) => {
      if (prev.includes(path)) {
        return prev.filter((p) => p !== path);
      }
      if (prev.length >= MAX_SELECTION) return prev;
      return [...prev, path];
    });
  };

  const spawnShit = () => {
    if (!selected.length) return;
    act('spawn', {
      types: selected,
      offset_type: offsetType,
      x,
      y,
      z,
      direction: dir,
      count,
    });
  };

  return (
    <Window width={550} height={705} title={`${data.root} Spawner`}>
      <Window.Content>
        <Section title="Select types">
          <ListSearch
            fuzzy="smart"
            onSelect={toggleSelect}
            options={data.types}
            selectedOptions={selected}
            multipleSelect
            noResultsPlaceholder="No matches."
            virtualize
            height="28rem"
          />
          <Stack mt={1}>
            <Stack.Item align="center">
              <Box fontSize={0.8} color="label" minWidth="5em">
                Selected: {selected.length}
              </Box>
            </Stack.Item>
            <Stack.Item align="center">
              <Button
                icon="times"
                onClick={() => setSelected([])}
                disabled={!selected.length}
              >
                Clear
              </Button>
            </Stack.Item>
            <Stack.Item grow>
              <NoticeBox
                danger
                mb={0}
                style={{
                  // Done like this so no layout shift when appearing
                  visibility:
                    selected.length >= MAX_SELECTION ? 'visible' : 'hidden',
                }}
              >
                Maximum selection limit ({MAX_SELECTION}) reached.
              </NoticeBox>
            </Stack.Item>
          </Stack>
        </Section>
        <Section title="Spawn Settings">
          <LabeledList>
            <LabeledList.Item label="Offset Type">
              <Stack>
                <Stack.Item>
                  <Button.Checkbox
                    checked={offsetType === 'absolute'}
                    onClick={() => {
                      setOffsetType('absolute');
                      // Reset to default coordinates for absolute mode
                      setX(1);
                      setY(1);
                      setZ(1);
                    }}
                  >
                    Absolute
                  </Button.Checkbox>
                </Stack.Item>
                <Stack.Item>
                  <Button.Checkbox
                    checked={offsetType === 'relative'}
                    onClick={() => {
                      setOffsetType('relative');
                      // Reset to default coordinates for relative mode
                      setX(0);
                      setY(0);
                      setZ(0);
                    }}
                  >
                    Relative
                  </Button.Checkbox>
                </Stack.Item>
              </Stack>
            </LabeledList.Item>
            <LabeledList.Item label="Coordinates">
              <Stack>
                <Stack.Item>
                  <NumberInput
                    width={4}
                    value={x}
                    minValue={
                      offsetType === 'absolute' ? 1 : -1 * data.world_max_x
                    }
                    maxValue={data.world_max_x}
                    step={1}
                    onChange={setX}
                  />
                </Stack.Item>
                <Stack.Item>
                  <NumberInput
                    width={4}
                    value={y}
                    minValue={
                      offsetType === 'absolute' ? 1 : -1 * data.world_max_y
                    }
                    maxValue={data.world_max_y}
                    step={1}
                    onChange={setY}
                  />
                </Stack.Item>
                <Stack.Item>
                  <NumberInput
                    width={4}
                    value={z}
                    minValue={
                      offsetType === 'absolute' ? 1 : -1 * data.world_max_z
                    }
                    maxValue={data.world_max_z}
                    step={1}
                    onChange={setZ}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="location-crosshairs"
                    tooltip="Pick coordinate on screen"
                    onClick={() => {
                      act('pick_coordinate');
                    }}
                    width={2}
                  />
                </Stack.Item>
              </Stack>
            </LabeledList.Item>
            <LabeledList.Item label="Count">
              <NumberInput
                width={4}
                minValue={1}
                maxValue={100}
                step={1}
                value={count}
                onChange={setCount}
              />
            </LabeledList.Item>
            <DirWidget dir={dir} onChange={setDir} />
          </LabeledList>
          <Box mt={1}>
            <Button
              disabled={!selected.length}
              icon="cube"
              onClick={spawnShit}
              tooltip={
                selected.length
                  ? 'Spawn selected types'
                  : 'Select at least one type'
              }
            >
              Spawn
            </Button>
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};

const DIRECTION_GRID: ByondDir[] = [
  ByondDir.Northwest,
  ByondDir.North,
  ByondDir.Northeast,
  ByondDir.West,
  ByondDir.None, // Center space
  ByondDir.East,
  ByondDir.Southwest,
  ByondDir.South,
  ByondDir.Southeast,
];

const DirWidget = ({
  dir,
  onChange: changeDir,
}: {
  dir: ByondDir;
  onChange: (d: ByondDir) => void;
}) => {
  return (
    <LabeledList.Item label="Facing">
      <Box>
        <Stack vertical>
          {[0, 1, 2].map((row) => (
            <Stack.Item key={row}>
              <Stack>
                {DIRECTION_GRID.slice(row * 3, row * 3 + 3).map((d) => (
                  <Stack.Item key={d}>
                    {d === ByondDir.None ? (
                      <Box width={1.833} />
                    ) : (
                      <Button
                        selected={dir === d}
                        onClick={() => changeDir(d)}
                        icon="arrow-up"
                        iconRotation={DIR_TO_ANGLE[d]}
                      />
                    )}
                  </Stack.Item>
                ))}
              </Stack>
            </Stack.Item>
          ))}
        </Stack>
      </Box>
    </LabeledList.Item>
  );
};

export default ObjectCreator;

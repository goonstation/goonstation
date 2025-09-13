/**
 * @file
 * @copyright 2025
 * @author ZeWaka (https://github.com/ZeWaka)
 * @license MIT
 */

import { useEffect, useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
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

interface AdminObjectSpawnerData {
  types: string[];
  root: string; // textual path ("/obj" | "/mob" | "/turf")
  world_max_x: number;
  world_max_y: number;
  world_max_z: number;
  picked_x?: number;
  picked_y?: number;
  picked_z?: number;
}

export const AdminObjectSpawner = () => {
  const { data, act } = useBackend<AdminObjectSpawnerData>();
  const [selected, setSelected] = useState<string[]>([]);
  const [offsetType, setOffsetType] = useState<'relative' | 'absolute'>(
    'relative',
  );
  const [x, setX] = useState(0);
  const [y, setY] = useState(0);
  const [z, setZ] = useState(0);
  const [count, setCount] = useState(1);
  const [dir, setDir] = useState<ByondDir>(ByondDir.South);
  const [effect, setEffect] = useState<string>('None');

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

  const MAX_SELECTION = 10;

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
      effect,
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
            height={28}
            selectedOptions={selected}
            multipleSelect
            searchPlaceholder="Search... (Append $ for ends-with)"
            noResultsPlaceholder="No matches."
            virtualize
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
              {(() => {
                const showMax = selected.length >= MAX_SELECTION;
                const showTurfWarn =
                  !showMax && data.root === '/turf' && selected.length > 1;
                const visible = showMax || showTurfWarn;
                const message = showMax
                  ? `Maximum selection limit (${MAX_SELECTION}) reached.`
                  : 'Multiple turfs may work strange! 💀';
                return (
                  <NoticeBox
                    mb={0}
                    danger={showMax}
                    // Show/hide but keep height to avoid layout shift
                    style={{ visibility: visible ? 'visible' : 'hidden' }}
                  >
                    {message}
                  </NoticeBox>
                );
              })()}
            </Stack.Item>
          </Stack>
        </Section>
        <Section title="Spawn Settings">
          <Stack align="start">
            <Stack.Item grow>
              <LabeledList>
                <LabeledList.Item label="Offset Type">
                  <Stack>
                    <Stack.Item>
                      <Button.Checkbox
                        checked={offsetType === 'absolute'}
                        onClick={() => {
                          setOffsetType('absolute');
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
                        width={3}
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
                        width={3}
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
                        width={3}
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
                        tooltip="Pick turf coordinate on screen"
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
                    width={3}
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
            </Stack.Item>
            <Stack.Item>
              <LabeledList>
                <LabeledList.Item label="Effect">
                  <Dropdown
                    options={['None', 'Blink', 'Poof', 'Supplydrop']}
                    selected={effect}
                    onSelected={setEffect}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
          </Stack>
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

export default AdminObjectSpawner;

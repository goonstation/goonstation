/**
 * @file
 * @copyright 2025
 * @author LeahTheTech (https://github.com/TobleroneSwordfish)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import { Fragment } from 'react';
import { Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { DiskDrive } from '../common/DiskDrive';
import { Led } from './LED';
import type { DiskRackData } from './types';

const getWindowHeight = (numDisks: number) =>
  numDisks * 38 +
  2 + // extra divider
  6 * 2 + // top and bottom window padding
  31; // title bar

export const DiskRack = (_props: unknown) => {
  const { act, data } = useBackend<DiskRackData>();
  const { disks, has_lights } = data;
  return (
    <Window
      height={getWindowHeight(disks.length)}
      width={304 + (has_lights ? 26 : 0)}
    >
      <Window.Content>
        <Stack vertical reverse>
          <Stack.Divider />
          {disks.map((disk, index) => {
            const handleClick = () => act('diskAction', { dmIndex: index + 1 });
            return (
              <Fragment key={index}>
                <Stack.Item>
                  <Stack align="center">
                    <Stack.Item>
                      <DiskDrive onEject={handleClick} onInsert={handleClick}>
                        {disk && (
                          <DiskDrive.Disk color={disk.color}>
                            {disk.name}
                          </DiskDrive.Disk>
                        )}
                      </DiskDrive>
                    </Stack.Item>
                    {!!has_lights && (
                      <Stack.Item>
                        <Led flashing={disk?.light} />
                      </Stack.Item>
                    )}
                  </Stack>
                </Stack.Item>
                <Stack.Divider />
              </Fragment>
            );
          })}
        </Stack>
      </Window.Content>
    </Window>
  );
};

/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/garash2k)
 * @license MIT
 */

import { Button, NoticeBox, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { Inputs } from './Inputs';
import { Output } from './Output';
import { Pump } from './Pump';
import type { GasMixerData } from './types';

export const GasMixer = (_props: unknown) => {
  const { data, act } = useBackend<GasMixerData>();
  const { name, mixerid, mixer_information } = data;
  return (
    <Window theme="ntos" title={name} width={500} height={340}>
      <Window.Content>
        {mixerid ? (
          mixer_information ? (
            <>
              <Inputs />
              <Stack>
                <Stack.Item width="320px">
                  <Pump />
                </Stack.Item>
                <Stack.Item grow>
                  <Output />
                </Stack.Item>
              </Stack>
            </>
          ) : (
            <NoticeBox warning>
              {mixerid} can not be found!
              <br />
              <Button
                icon="arrows-rotate"
                onClick={() => act('refresh_status')}
              >
                Search
              </Button>
            </NoticeBox>
          )
        ) : (
          <NoticeBox warning>No mixers connected.</NoticeBox>
        )}
      </Window.Content>
    </Window>
  );
};

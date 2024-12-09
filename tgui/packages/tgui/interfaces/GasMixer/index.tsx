/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/garash2k)
 * @license MIT
 */

import { Button, NoticeBox } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { Inputs } from './Inputs';
import { Output } from './Output';
import { Pump } from './Pump';
import type { GasMixerData } from './types';

export const GasMixer = () => {
  const { data, act } = useBackend<GasMixerData>();
  const { name, mixerid, mixer_information } = data;
  return (
    <Window theme="ntos" title={name} width={350} height={510}>
      <Window.Content scrollable>
        {mixerid ? (
          mixer_information ? (
            <>
              <Inputs />
              <Pump />
              <Output />
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

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
import { Outputs } from './Outputs';
import { Pump } from './Pump';
import type { GasMixerData } from './types';

export const GasMixer = (_props: unknown) => {
  const { data, act } = useBackend<GasMixerData>();
  const { name, mixerid, mixer_information } = data;
  return (
    <Window theme="ntos" title={name} width={650} height={650}>
      <Window.Content>
        {mixerid ? (
          mixer_information ? (
            <>
              <Inputs />
              <Pump />
              <Outputs />
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

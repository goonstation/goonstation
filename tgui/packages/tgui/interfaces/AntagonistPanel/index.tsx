/**
 * @file
 * @copyright 2023
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import { Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { AntagonistTypeTabBody } from './AntagonistTypeTabBody';
import { AntagonistTypeTabs } from './AntagonistTypeTabs';
import { AntagonistPanelData } from './type';

export const AntagonistPanel = () => {
  const { data } = useBackend<AntagonistPanelData>();

  return (
    <Window title="Antagonist Panel" width={750} height={500}>
      <Window.Content scrollable>
        <Stack fill>
          <Stack.Item>
            <AntagonistTypeTabs {...data} />
          </Stack.Item>
          <Stack.Item grow>
            <AntagonistTypeTabBody {...data} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

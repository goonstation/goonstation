/**
 * @file
 * @copyright 2023
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { Stack } from '../../components';
import { AntagonistTypeTabs } from './AntagonistTypeTabs';
import { AntagonistTypeTabBody } from './AntagonistTypeTabBody';
import { AntagonistPanelData } from './type';

export const AntagonistPanel = (props, context) => {
  const { data } = useBackend<AntagonistPanelData>(context);

  return (
    <Window
      title="Antagonist Panel"
      width={750}
      height={500}>
      <Window.Content
        scrollable>
        <Stack
          fill>
          <Stack.Item>
            <AntagonistTypeTabs {...data} />
          </Stack.Item>
          <Stack.Item
            grow>
            <AntagonistTypeTabBody {...data} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

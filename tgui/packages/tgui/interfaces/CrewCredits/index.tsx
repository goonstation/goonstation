/**
 * @file
 * @copyright 2023
 * @author Original glowbold (https://github.com/pgmzeta)
 * @author Changes Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import { useLocalState } from '../../backend';
import { Stack, Tabs } from '../../components';
import { Window } from '../../layouts';
import { CrewTab } from './CrewTab';
import { AntagonistsTab } from './AntagonistsTab';
import { CrewCreditsTabKeys } from './type';
import { ScoreTab } from './ScoreTab';

export const CrewCredits = (props, context) => {
  const [menu, setMenu] = useLocalState(context, 'menu', CrewCreditsTabKeys.General);

  return (
    <Window title="Crew Credits" width={600} height={600}>
      <Window.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                selected={menu === CrewCreditsTabKeys.General}
                onClick={() => setMenu(CrewCreditsTabKeys.General)}>
                General
              </Tabs.Tab>
              <Tabs.Tab
                selected={menu === CrewCreditsTabKeys.Antagonists}
                onClick={() => setMenu(CrewCreditsTabKeys.Antagonists)}>
                Antagonists
              </Tabs.Tab>
              <Tabs.Tab
                selected={menu === CrewCreditsTabKeys.Score}
                onClick={() => setMenu(CrewCreditsTabKeys.Score)}>
                Station Score
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item>
            {menu === CrewCreditsTabKeys.General && <CrewTab />}
            {menu === CrewCreditsTabKeys.Antagonists && <AntagonistsTab />}
            {menu === CrewCreditsTabKeys.Score && <ScoreTab />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

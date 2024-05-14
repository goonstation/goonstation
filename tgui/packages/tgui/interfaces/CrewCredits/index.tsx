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
import { CrewCreditsTabKeys } from './type';
import { CrewTab } from './CrewTab';
import { AntagonistsTab } from './AntagonistsTab';
import { ScoreTab } from './ScoreTab';
import { CitationsTab } from './CitationsTab';

export const CrewCredits = (props, context) => {
  const [menu, setMenu] = useLocalState(context, 'menu', CrewCreditsTabKeys.Crew);
  return (
    <Window title="Round Summary" width={600} height={600}>
      <Window.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                selected={menu === CrewCreditsTabKeys.Crew}
                onClick={() => setMenu(CrewCreditsTabKeys.Crew)}>
                Crew Credits
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
              <Tabs.Tab
                selected={menu === CrewCreditsTabKeys.Citations}
                onClick={() => setMenu(CrewCreditsTabKeys.Citations)}>
                Tickets/Fines
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item>
            {menu === CrewCreditsTabKeys.Crew && <CrewTab />}
            {menu === CrewCreditsTabKeys.Antagonists && <AntagonistsTab />}
            {menu === CrewCreditsTabKeys.Score && <ScoreTab />}
            {menu === CrewCreditsTabKeys.Citations && <CitationsTab />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

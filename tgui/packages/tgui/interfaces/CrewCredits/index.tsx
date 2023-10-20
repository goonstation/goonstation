/**
 * @file
 * @copyright 2023
 * @author Original glowbold (https://github.com/pgmzeta)
 * @author Changes Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import { useBackend } from '../../backend';
import { Stack, Tabs } from '../../components';
import { Window } from '../../layouts';
import { CrewCreditsData, CrewCreditsTabKeys } from './type';
import { CrewTab } from './CrewTab';
import { AntagonistsTab } from './AntagonistsTab';
import { ScoreTab } from './ScoreTab';
import { CitationsTab } from './CitationsTab';
import { ReportsTab } from './ReportsTab';

export const CrewCredits = (props, context) => {
  const { data, act } = useBackend<CrewCreditsData>(context);
  const { current_tab, has_report_data, has_citation_data } = data;
  return (
    <Window title="Round Summary" width={700} height={700}>
      <Window.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                selected={current_tab === CrewCreditsTabKeys.Crew}
                onClick={() => act('current_tab', { tab: CrewCreditsTabKeys.Crew })}>
                Crew Credits
              </Tabs.Tab>
              <Tabs.Tab
                selected={current_tab === CrewCreditsTabKeys.Antagonists}
                onClick={() => act('current_tab', { tab: CrewCreditsTabKeys.Antagonists })}>
                Antagonists
              </Tabs.Tab>
              <Tabs.Tab
                selected={current_tab === CrewCreditsTabKeys.Score}
                onClick={() => act('current_tab', { tab: CrewCreditsTabKeys.Score })}>
                Station Score
              </Tabs.Tab>
              { !!has_citation_data && (
                <Tabs.Tab
                  selected={current_tab === CrewCreditsTabKeys.Citations}
                  onClick={() => act('current_tab', { tab: CrewCreditsTabKeys.Citations })}>
                  Tickets/Fines
                </Tabs.Tab>
              )}
              { !!has_report_data && (
                <Tabs.Tab
                  selected={current_tab === CrewCreditsTabKeys.Reports}
                  onClick={() => act('current_tab', { tab: CrewCreditsTabKeys.Reports })}>
                  Inspector&apos;s Report
                </Tabs.Tab>
              )}
            </Tabs>
          </Stack.Item>
          <Stack.Item>
            {current_tab === CrewCreditsTabKeys.Crew && <CrewTab />}
            {current_tab === CrewCreditsTabKeys.Antagonists && <AntagonistsTab />}
            {current_tab === CrewCreditsTabKeys.Score && <ScoreTab />}
            {current_tab === CrewCreditsTabKeys.Citations && <CitationsTab />}
            {current_tab === CrewCreditsTabKeys.Reports && <ReportsTab />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

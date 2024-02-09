/**
 * @file
 * @copyright 2023
 * @author Mordent (https://github.com/mordent-goonstation)
 * @author ZeWaka (https://github.com/ZeWaka)
 * @license ISC
 */

import { Stack, Tabs } from '../../components';
import { Window } from '../../layouts';
import { BanList } from './BanList/BanList';
import { JobBanList } from './JobBanList';
import { BanPanelTab } from './type';
import { useBanPanelBackend } from './useBanPanelBackend';

export const BanPanel = (_props, context) => {
  const { action, data } = useBanPanelBackend(context);
  const { current_tab } = data;
  return (
    <Window width={1100} height={640} title="Ban Panel" className="BanPanel">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                onClick={() => action.setTab(BanPanelTab.BanList)}
                selected={current_tab === BanPanelTab.BanList}>
                Ban List
              </Tabs.Tab>
              <Tabs.Tab
                onClick={() => action.setTab(BanPanelTab.JobBanList)}
                selected={current_tab === BanPanelTab.JobBanList}>
                Job Ban List
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          {current_tab === BanPanelTab.BanList && <BanList data={data} />}
          {current_tab === BanPanelTab.JobBanList && <JobBanList />}
        </Stack>
      </Window.Content>
    </Window>
  );
};

/**
 * @file
 * @copyright 2022
 * @author Original Amylizzle (https://github.com/amylizzle)
 * @author Changes Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import { Stack, Tabs } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { ExtractablesView, OverviewView, SeedsView } from './tabs';
import { type PlantmasterData, PlantmasterTab } from './type';

export const Plantmaster = () => {
  const { act, data } = useBackend<PlantmasterData>();
  const {
    category,
    inserted,
    inserted_container,
    num_extractables,
    num_seeds,
  } = data;
  return (
    <Window title="Plantmaster Mk4" width={1200} height={450}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                selected={category === PlantmasterTab.Overview}
                onClick={() => {
                  act('change_tab', { tab: PlantmasterTab.Overview });
                }}
              >
                Overview
              </Tabs.Tab>
              <Tabs.Tab
                selected={category === PlantmasterTab.Extractables}
                onClick={() => {
                  act('change_tab', { tab: PlantmasterTab.Extractables });
                }}
              >
                Seed Extraction ({num_extractables})
              </Tabs.Tab>
              <Tabs.Tab
                selected={category === PlantmasterTab.SeedList}
                onClick={() => {
                  act('change_tab', { tab: PlantmasterTab.SeedList });
                }}
              >
                Seeds ({num_seeds})
              </Tabs.Tab>
              <Tabs.Tab
                backgroundColor={inserted_container ? 'green' : 'blue'}
                selected={!!inserted_container}
                icon="eject"
                onClick={() =>
                  inserted_container ? act('ejectbeaker') : act('insertbeaker')
                }
                bold
              >
                {inserted_container ? inserted : 'Insert Beaker'}
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {category === PlantmasterTab.Overview && <OverviewView />}
            {category === PlantmasterTab.Extractables && <ExtractablesView />}
            {category === PlantmasterTab.SeedList && <SeedsView />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

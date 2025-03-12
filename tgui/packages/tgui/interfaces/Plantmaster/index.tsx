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
import type { PlantmasterData } from './type';

export const Plantmaster = () => {
  const { act, data } = useBackend<PlantmasterData>();
  const {
    category,
    inserted_desc,
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
                selected={category === 'overview'}
                onClick={() => {
                  act('change_tab', { tab: 'overview' });
                }}
              >
                Overview
              </Tabs.Tab>
              <Tabs.Tab
                selected={category === 'extractables'}
                onClick={() => {
                  act('change_tab', { tab: 'extractables' });
                }}
              >
                Seed Extraction ({num_extractables})
              </Tabs.Tab>
              <Tabs.Tab
                selected={category === 'seedlist'}
                onClick={() => {
                  act('change_tab', { tab: 'seedlist' });
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
                {inserted_container ? inserted_desc : 'Insert Beaker'}
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {category === 'overview' && <OverviewView />}
            {category === 'extractables' && <ExtractablesView />}
            {category === 'seedlist' && <SeedsView />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

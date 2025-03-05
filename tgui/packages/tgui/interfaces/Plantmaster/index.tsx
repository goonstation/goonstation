/**
 * @file
 * @copyright 2022
 * @author Original Amylizzle (https://github.com/amylizzle)
 * @author Changes Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import { useState } from 'react';
import { Stack, Tabs } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { ExtractablesView, OverviewView, SeedsView } from './tabs';
import { type PlantmasterData, PlantmasterTab } from './type';

export const Plantmaster = () => {
  const { act, data } = useBackend<PlantmasterData>();
  const {
    allow_infusion,
    category,
    category_lengths,
    inserted,
    inserted_container,
    seedoutput,
    splice_chance,
    show_splicing,
    splice_seeds,
    sortBy,
    sortAsc,
  } = data;
  const [page, setPage] = useState(1);
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
                Seed Extraction ({category_lengths[0]})
              </Tabs.Tab>
              <Tabs.Tab
                selected={category === PlantmasterTab.SeedList}
                onClick={() => {
                  act('change_tab', { tab: PlantmasterTab.SeedList });
                }}
              >
                Seeds ({category_lengths[1]})
              </Tabs.Tab>
              <Tabs.Tab
                backgroundColor={inserted_container !== null ? 'green' : 'blue'}
                selected={inserted_container !== null}
                icon="eject"
                onClick={() =>
                  inserted_container !== null
                    ? act('ejectbeaker')
                    : act('insertbeaker')
                }
                bold
              >
                {inserted_container !== null ? inserted : 'Insert Beaker'}
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {category === PlantmasterTab.Overview && (
              <OverviewView
                cat_lens={category_lengths}
                container={inserted ? inserted_container : null}
              />
            )}
            {category === PlantmasterTab.Extractables && (
              <ExtractablesView
                allow_infusion={allow_infusion}
                seedoutput={seedoutput}
                produce={data.extractables}
                sortBy={sortBy}
                sortAsc={sortAsc}
                page={page}
                setPage={setPage}
              />
            )}
            {category === PlantmasterTab.SeedList && (
              <SeedsView
                allow_infusion={allow_infusion}
                seeds={data.seeds}
                seedoutput={seedoutput}
                splicing={show_splicing}
                splice_chance={splice_chance}
                splice_seeds={splice_seeds}
                sortBy={sortBy}
                sortAsc={sortAsc}
                page={page}
                setPage={setPage}
              />
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

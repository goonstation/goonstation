/**
 * @file
 * @copyright 2021
 * @author BenLubar (https://github.com/BenLubar)
 * @license ISC
 */

import {
  Box,
  Button,
  Divider,
  Flex,
  Icon,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Tabs,
  TimeDisplay,
} from 'tgui-core/components';

import { useBackend, useSharedState } from '../../backend';
import { Window } from '../../layouts';
import { BuyMaterialsModal } from './modals/BuyMaterialsModal';
import { CombineGenesModal } from './modals/CombineGenesModal';
import { MutationsTab } from './tabs/MutationsTab';
import { ResearchTab } from './tabs/ResearchTab';
import { ScannerTab } from './tabs/ScannerTab';
import { RecordTab, StorageTab } from './tabs/StorageTab';
import type { GeneTekData } from './type';

const formatSeconds = (v) => (v > 0 ? (v / 10).toFixed(0) + 's' : 'Ready');

export const GeneTek = () => {
  const { data, act } = useBackend<GeneTekData>();
  const [menu, setMenu] = useSharedState('menu', 'research');
  const [buyMats, setBuyMats] = useSharedState('buymats', 0);
  const [isCombining] = useSharedState('iscombining', false);
  const {
    materialCur,
    materialMax,
    currentResearch,
    equipmentCooldown,
    subject,
    costPerMaterial,
    budget,
    record,
    scannerAlert,
    scannerError,
    allowed,
  } = data;

  const { name, stat, health, stability } = subject || {};

  const maxBuyMats = Math.min(
    materialMax - materialCur,
    Math.floor(budget / costPerMaterial),
  );

  const scannerAlertNoticeProps = scannerError
    ? { danger: true }
    : { info: true };

  return (
    <Window theme="genetek" width={750} height={570}>
      <Window.Content className={!allowed ? 'genetek-disabled' : ''}>
        <Flex height="100%">
          <Flex.Item
            width="245px"
            height="100%"
            style={{ padding: '5px 5px 5px 5px' }}
          >
            <Flex direction="column" height="100%">
              {!allowed && (
                <>
                  <div style={{ color: '#ff3333', textAlign: 'center' }}>
                    Insufficient access to interact.
                  </div>
                  <Divider />
                </>
              )}
              <Flex style={{ zIndex: 1 }}>
                <ProgressBar value={materialCur} maxValue={materialMax} mb={1}>
                  <Box position="absolute" bold>
                    Materials
                  </Box>
                  {materialCur}
                  {' / '}
                  {materialMax}
                </ProgressBar>
                <Flex.Item ml={1}>
                  <Button
                    circular
                    compact
                    icon="dollar-sign"
                    disabled={maxBuyMats <= 0}
                    onClick={() => setBuyMats(1)}
                  />
                </Flex.Item>
              </Flex>
              {subject && (
                <LabeledList>
                  <LabeledList.Item label="Occupant">{name}</LabeledList.Item>
                  {health && (
                    <LabeledList.Item label="Health">
                      <ProgressBar
                        ranges={{
                          bad: [-Infinity, 0.15],
                          average: [0.15, 0.75],
                          good: [0.75, Infinity],
                        }}
                        value={health}
                      >
                        {!stat || stat < 2 ? (
                          health <= 0 ? (
                            <Box color="bad">
                              <Icon name="exclamation-triangle" />
                              {' Critical'}
                            </Box>
                          ) : (
                            (health * 100).toFixed(0) + '%'
                          )
                        ) : (
                          <Box>
                            <Icon name="skull" />
                            {' Deceased'}
                          </Box>
                        )}
                      </ProgressBar>
                    </LabeledList.Item>
                  )}
                  {stability && (
                    <LabeledList.Item label="Stability">
                      <ProgressBar
                        ranges={{
                          bad: [-Infinity, 15],
                          average: [15, 75],
                          good: [75, Infinity],
                        }}
                        value={stability}
                        maxValue={100}
                      />
                    </LabeledList.Item>
                  )}
                </LabeledList>
              )}
              <Divider />
              <Flex.Item grow={1} style={{ overflow: 'hidden' }}>
                {currentResearch.map((r) => (
                  <ProgressBar
                    key={r.ref}
                    value={r.total && r.current ? r.total - r.current : 0}
                    maxValue={r.total}
                    mb={1}
                  >
                    <Box position="absolute">{r.name}</Box>
                    <TimeDisplay
                      auto
                      value={r.current ?? 0}
                      format={formatSeconds}
                    />
                  </ProgressBar>
                ))}
              </Flex.Item>
              {!!scannerAlert && (
                <NoticeBox {...scannerAlertNoticeProps}>
                  {scannerAlert}
                </NoticeBox>
              )}
              <Divider />
              <LabeledList>
                {equipmentCooldown.map((e) => (
                  <LabeledList.Item key={e.label} label={e.label}>
                    {e.cooldown < 0 ? (
                      'Ready'
                    ) : (
                      <TimeDisplay
                        auto
                        value={e.cooldown}
                        format={formatSeconds}
                      />
                    )}
                  </LabeledList.Item>
                ))}
              </LabeledList>
            </Flex>
          </Flex.Item>
          <Window.Content scrollable>
            <Flex.Item>
              <Box ml="250px">
                <Tabs>
                  <Tabs.Tab
                    icon="flask"
                    selected={menu === 'research'}
                    onClick={() => setMenu('research')}
                  >
                    Research
                  </Tabs.Tab>
                  <Tabs.Tab
                    icon="radiation"
                    selected={menu === 'mutations'}
                    onClick={() => setMenu('mutations')}
                  >
                    Mutations
                  </Tabs.Tab>
                  <Tabs.Tab
                    icon="server"
                    selected={
                      menu === 'storage' || (!record && menu === 'record')
                    }
                    onClick={() => setMenu('storage')}
                  >
                    Storage
                  </Tabs.Tab>
                  {!!record && (
                    <Tabs.Tab
                      icon="save"
                      selected={menu === 'record'}
                      onClick={() => setMenu('record')}
                      rightSlot={
                        menu === 'record' && (
                          <Button
                            circular
                            compact
                            color="transparent"
                            icon="times"
                            onClick={() => act('clearrecord')}
                          />
                        )
                      }
                    >
                      Record
                    </Tabs.Tab>
                  )}
                  {subject && (
                    <Tabs.Tab
                      icon="dna"
                      selected={menu === 'scanner'}
                      onClick={() => setMenu('scanner')}
                    >
                      Scanner
                    </Tabs.Tab>
                  )}
                </Tabs>
                {buyMats > 0 && <BuyMaterialsModal maxAmount={maxBuyMats} />}
                {!!isCombining && <CombineGenesModal />}
                {menu === 'research' && (
                  <ResearchTab
                    maxBuyMats={maxBuyMats}
                    setBuyMats={setBuyMats}
                  />
                )}
                {menu === 'mutations' && <MutationsTab />}
                {menu === 'storage' && <StorageTab />}
                {menu === 'record' && (record ? <RecordTab /> : <StorageTab />)}
                {menu === 'scanner' && <ScannerTab />}
              </Box>
            </Flex.Item>
          </Window.Content>
        </Flex>
      </Window.Content>
    </Window>
  );
};

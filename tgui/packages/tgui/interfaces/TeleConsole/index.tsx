/**
 * @file
 * @copyright 2023
 * @author Original Valtsu0 (https://github.com/Valtsu0)
 * @author Changes Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Button, Icon, Section, Stack, Tabs } from 'tgui-core/components';

import { useBackend, useSharedState } from '../../backend';
import { Window } from '../../layouts';
import { BookmarksSection } from './BookmarksSection';
import { ConnectionSection } from './ConnectionSection';
import { CoordinatesSection } from './CoordinatesSection';
import { DiskSection } from './DiskSection';
import { LongRangeSection } from './LongRangeSection';
import type { TeleConsoleData } from './types';
import { formatReadout } from './util';

const Tab = {
  Local: 'local',
  LongRange: 'lrt',
};

export const TeleConsole = () => {
  const { act, data } = useBackend<TeleConsoleData>();
  const [tab, setTab] = useSharedState('tab', Tab.Local);
  const {
    xTarget,
    yTarget,
    zTarget,
    hostId,
    bookmarks,
    readout,
    isPanelOpen,
    padNum,
    maxBookmarks,
    disk,
    destinations,
  } = data;
  const isConnectedToHost = !!hostId;

  const handleAddBookmark = (name: string) =>
    act('addbookmark', { value: name });
  const handleDeleteBookmark = (ref: string) =>
    act('deletebookmark', { value: ref });
  const handleRestoreBookmark = (ref: string) =>
    act('restorebookmark', { value: ref });
  const handleLongRangeSend = (name: string) => act('lrt_send', { name: name });
  const handleLongRangeReceive = (name: string) =>
    act('lrt_receive', { name: name });
  const handleLongRangePortal = (name: string) =>
    act('lrt_portal', { name: name });
  const handleResetConnect = () => act('reconnect', { value: 2 });
  const handleRetryConnect = () => act('reconnect', { value: 1 });
  const handleCyclePad = () => act('setpad');
  const handleScanDisk = () => act('scan_disk');
  const handleEjectDisk = () => act('eject_disk');

  return (
    <Window theme="ntos" width={410} height={515}>
      <Window.Content textAlign="center">
        <Stack vertical fill>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                icon="box"
                selected={tab === Tab.Local}
                onClick={() => setTab(Tab.Local)}
              >
                Local
              </Tabs.Tab>
              <Tabs.Tab
                icon="globe"
                selected={tab === Tab.LongRange}
                onClick={() => setTab(Tab.LongRange)}
              >
                Long Range
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>

          {tab === Tab.Local && (
            <Stack.Item>
              <Section>
                <CoordinatesSection />
                <Section>
                  <Button
                    icon="sign-out-alt"
                    onClick={() => act('send')}
                    disabled={!isConnectedToHost}
                  >
                    Send
                  </Button>
                  <Button
                    icon="sign-in-alt"
                    onClick={() => act('receive')}
                    disabled={!isConnectedToHost}
                  >
                    Receive
                  </Button>
                  <Button
                    onClick={() => act('portal')}
                    disabled={!isConnectedToHost}
                  >
                    <Icon name="ring" rotation={90} />
                    Toggle Portal
                  </Button>
                  <Button
                    icon="magnifying-glass"
                    onClick={() => act('scan')}
                    disabled={!isConnectedToHost}
                  >
                    Scan
                  </Button>
                </Section>
                {readout && <Section>{formatReadout(readout)}</Section>}
                <BookmarksSection
                  bookmarks={bookmarks}
                  maxBookmarks={maxBookmarks}
                  onAddBookmark={handleAddBookmark}
                  onDeleteBookmark={handleDeleteBookmark}
                  onRestoreBookmark={handleRestoreBookmark}
                  targetCoords={[xTarget, yTarget, zTarget]}
                />
                <ConnectionSection
                  isConnected={isConnectedToHost}
                  isPanelOpen={!!isPanelOpen}
                  onCyclePad={handleCyclePad}
                  onReset={handleResetConnect}
                  onRetry={handleRetryConnect}
                  padNum={padNum}
                />
              </Section>
            </Stack.Item>
          )}
          {tab === Tab.LongRange && (
            <Stack.Item>
              <Section>
                <LongRangeSection
                  isConnected={isConnectedToHost}
                  destinations={destinations}
                  onSend={handleLongRangeSend}
                  onReceive={handleLongRangeReceive}
                  onToggle={handleLongRangePortal}
                />
                {readout && <Section>{formatReadout(readout)}</Section>}
                <ConnectionSection
                  isConnected={isConnectedToHost}
                  isPanelOpen={!!isPanelOpen}
                  onCyclePad={handleCyclePad}
                  onReset={handleResetConnect}
                  onRetry={handleRetryConnect}
                  padNum={padNum}
                />
              </Section>
              <DiskSection
                isDiskPresent={!!disk}
                onScanDisk={handleScanDisk}
                onEjectDisk={handleEjectDisk}
              />
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

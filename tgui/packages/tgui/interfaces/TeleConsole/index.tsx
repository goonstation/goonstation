/**
 * @file
 * @copyright 2023
 * @author Original Valtsu0 (https://github.com/Valtsu0)
 * @author Changes Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { useBackend, useSharedState } from '../../backend';
import { Box, Button, Icon, LabeledList, Section, Stack, Tabs } from '../../components';
import { Window } from '../../layouts';
import { BookmarksSection } from './BookmarksSection';
import { ConnectionSection } from './ConnectionSection';
import { CoordinatesSection } from './CoordinatesSection';
import type { TeleConsoleData } from './types';
import { formatReadout } from './util';

const Tab = {
  Local: 'local',
  LongRange: 'lrt',
};

export const TeleConsole = (_props, context) => {
  const { act, data } = useBackend<TeleConsoleData>(context);
  const [tab, setTab] = useSharedState(context, 'tab', Tab.Local);
  const { xTarget, yTarget, zTarget, hostId, bookmarks,
    readout, isPanelOpen, padNum, maxBookmarks, disk, destinations } = data;
  const isConnectedToHost = !!hostId;

  const handleAddBookmark = (name: string) => act('addbookmark', { value: name });
  const handleDeleteBookmark = (ref: string) => act('deletebookmark', { value: ref });
  const handleRestoreBookmark = (ref: string) => act('restorebookmark', { value: ref });
  const handleResetConnect = () => act('reconnect', { value: 2 });
  const handleRetryConnect = () => act('reconnect', { value: 1 });
  const handleCyclePad = () => act('setpad');

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
                icon="wrench"
                selected={tab === Tab.LongRange}
                onClick={() => setTab(Tab.LongRange)}
              >
                Long Range
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>

          {(tab===Tab.Local) && (
            <Stack.Item>
              <Section>
                <CoordinatesSection />
                <Section>
                  <Button icon="sign-out-alt" onClick={() => act('send')} disabled={!isConnectedToHost}>
                    Send
                  </Button>
                  <Button icon="sign-in-alt" onClick={() => act('receive')} disabled={!isConnectedToHost}>
                    Receive
                  </Button>
                  <Button onClick={() => act('portal')} disabled={!isConnectedToHost}>
                    <Icon name="ring" rotation={90} />
                    Toggle Portal
                  </Button>
                  <Button icon="magnifying-glass" onClick={() => act('scan')} disabled={!isConnectedToHost}>
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
          {(tab===Tab.LongRange) && (
            <Stack.Item>
              <Section>
                <Section title="Destinations">
                  <LabeledList>
                    {destinations.length ? destinations.map((d) => (
                      <div key={d["name"]}>
                        <LabeledList.Item
                          label={d["name"]}>
                          <Box textAlign="right">
                            <Button
                              icon="sign-out-alt"
                              onClick={() => act("lrt_send", { name: d["name"] })}
                              disabled={!isConnectedToHost}
                            >
                              Send
                            </Button>
                            <Button
                              icon="sign-in-alt"
                              onClick={() => act("lrt_receive", { name: d["name"] })}
                              disabled={!isConnectedToHost}
                            >
                              Receive
                            </Button>
                            <Button onClick={() => act('lrt_portal', { name: d["name"] })} disabled={!isConnectedToHost}>
                              <Icon name="ring" rotation={90} />
                              Toggle Portal
                            </Button>
                          </Box>
                        </LabeledList.Item>
                      </div>
                    )) : (
                      <LabeledList.Item>
                        No destinations are currently available.
                      </LabeledList.Item>
                    )}
                  </LabeledList>
                </Section>
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
              {(!!disk) && (
                <Section
                  title="Disk Controls"
                >

                  <Button
                    icon="upload"
                    color={"blue"}
                    onClick={() => act("scan_disk")}>
                    Read from Disk
                  </Button>
                  <Button
                    icon="eject"
                    color={"bad"}
                    onClick={() => act("eject_disk")}>
                    Eject Disk
                  </Button>

                </Section>

              )}
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

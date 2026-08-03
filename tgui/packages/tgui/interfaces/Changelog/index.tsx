/**
 * @file
 * @copyright 2026
 * @author FlameArrow57 (https://github.com/FlameArrow57)
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license ISC
 */

import { useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Image,
  Section,
  Stack,
  Tabs,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { resource } from '../../goonstation/cdn';
import { Window } from '../../layouts';
import {
  ChangeEntryData,
  ChangelogData,
  ChangelogTabKeys,
  DateEntryData,
  HeaderData,
} from './type';

export const Changelog = () => {
  const { data } = useBackend<ChangelogData>();
  const [tab, setTab] = useState(ChangelogTabKeys.Changes);

  return (
    <Window title="Changelog" width={500} height={650}>
      <Window.Content scrollable>
        <Header current_commit={data.current_commit} setTab={setTab} />
        <Tabs mt={1}>
          <Tabs.Tab
            selected={tab === ChangelogTabKeys.Changes}
            onClick={() => setTab(ChangelogTabKeys.Changes)}
          >
            Changes
          </Tabs.Tab>
          {!!data.is_admin && (
            <Tabs.Tab
              selected={tab === ChangelogTabKeys.Admin}
              onClick={() => setTab(ChangelogTabKeys.Admin)}
            >
              Admin
            </Tabs.Tab>
          )}
          <Tabs.Tab
            selected={tab === ChangelogTabKeys.Attribution}
            onClick={() => setTab(ChangelogTabKeys.Attribution)}
          >
            Attribution
          </Tabs.Tab>
        </Tabs>
        {tab === ChangelogTabKeys.Changes && (
          <Box>
            {data.entries.map((item, index) => (
              <DateEntry key={index} {...item} />
            ))}
            <Section>
              Older changes can be viewed on the{' '}
              <a href={'https://wiki.ss13.co/Changelog'}>wiki</a>.
            </Section>
          </Box>
        )}
        {tab === ChangelogTabKeys.Admin && (
          <Box>
            {data.admin_entries.map((item, index) => (
              <DateEntry key={index} {...item} />
            ))}
          </Box>
        )}
        {tab === ChangelogTabKeys.Attribution && (
          <Box>
            <Section title={'Licensing'}>
              <div>
                Except where otherwise noted, Goonstation is licensed under the{' '}
                <a href="https://creativecommons.org/licenses/by-nc-sa/3.0/">
                  Creative Commons Attribution-Noncommercial-Share Alike 3.0
                  License
                </a>
                .
              </div>
              <br />
              <div>
                <b>Important:</b> This means that code from Goonstation cannot
                be ported to codebases such as /tg/station. If you wish to port
                a specific feature, you{' '}
                <b>
                  <i>must</i>
                </b>{' '}
                get the developer(s) to sublicense it to you under a license
                like AGPLv3. This also applies in the opposite direction for
                features ported from other codebases.
              </div>
              <br />
              <div>
                <b>Official GitHub:</b>{' '}
                <a href={'https://github.com/goonstation/goonstation'}>
                  https://github.com/goonstation/goonstation
                </a>
              </div>
            </Section>
            <Section title={'Official Development Team'}>
              <Stack vertical>
                <Stack.Item>
                  <b>Host: </b>
                  {data.dev_host}
                </Stack.Item>
                <Stack.Divider />
                <Stack.Item>
                  <b>Coders: </b>
                  {data.dev_coders}
                </Stack.Item>
                <Stack.Divider />
                <Stack.Item>
                  <b>Spriters: </b>
                  {data.dev_spriters}
                </Stack.Item>
              </Stack>
            </Section>
          </Box>
        )}
      </Window.Content>
    </Window>
  );
};

const Header = (props: HeaderData) => {
  return (
    <Stack vertical>
      <Stack.Item>
        <Section>
          <Stack align="center" justify="space-between">
            <Stack.Item bold fontSize={2} ml={1}>
              Goonstation 13
            </Stack.Item>
            <Stack.Item bold>
              <code>{props.current_commit}</code>
            </Stack.Item>
            <Stack.Item>
              <Button
                p={0}
                color="transparent"
                tooltip="Creative Commons CC-BY-NC-SA License"
                onClick={() => props.setTab(ChangelogTabKeys.Attribution)}
              >
                <Image
                  verticalAlign="middle"
                  src={resource('images/changelog/88x31.png')}
                />
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Stack textAlign="center">
          <Stack.Item width="50%">
            <Section>
              <b>Official Wiki</b>
              <br />
              <a href={'https://wiki.ss13.co'}>https://wiki.ss13.co</a>
            </Section>
          </Stack.Item>
          <Stack.Item width="50%">
            <Section>
              <b>Official Forums</b>
              <br />
              <a href={'https://forum.ss13.co'}>https://forum.ss13.co</a>
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const DateEntry = (props: DateEntryData) => {
  return (
    <Section
      title={props.entry_date}
      backgroundColor={
        props.entry_date.includes('Testmerge')
          ? 'color-mix(in srgb, var(--section-background), var(--color-primary) 20%)'
          : null
      }
    >
      <Stack vertical>
        {!!props.major_entries?.length && (
          <Stack.Item>
            <Stack vertical>
              {props.major_entries.map((item, index) => (
                <ChangeEntry key={index} {...item} top_entry={index === 0} />
              ))}
            </Stack>
          </Stack.Item>
        )}
        {!!props.minor_entries?.length && (
          <Stack.Item mb={-1}>
            <Collapsible title="Minor Changes">
              <Stack>
                <Stack.Divider mr={0.2} />
                <Stack.Item>
                  <Stack vertical>
                    {props.minor_entries.map((item, index) => (
                      <ChangeEntry
                        key={index}
                        {...item}
                        top_entry={index === 0}
                      />
                    ))}
                  </Stack>
                </Stack.Item>
              </Stack>
            </Collapsible>
          </Stack.Item>
        )}
      </Stack>
    </Section>
  );
};

const ChangeEntry = (props: ChangeEntryData) => {
  return (
    <>
      {!props.top_entry && <Stack.Divider />}
      <Stack.Item mb={0.5}>
        <Stack vertical>
          <Stack.Item>
            <Stack>
              <Stack.Item>
                <b>{props.author}</b> updated:
              </Stack.Item>
              {!!props.emojis && (
                <Stack.Item>
                  <Tooltip content={props.emoji_tooltips}>
                    {props.emojis}
                  </Tooltip>
                </Stack.Item>
              )}
              <Stack.Item grow />
              {!!props.pr_num && (
                <Stack.Item>
                  <a
                    href={`https://github.com/goonstation/goonstation/pull/${props.pr_num}`}
                  >
                    {`#${props.pr_num}`}
                  </a>
                </Stack.Item>
              )}
              {!!props.feedback && (
                <Stack.Item>
                  <a href={props.feedback}>Feedback</a>
                </Stack.Item>
              )}
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Stack vertical pl={1}>
              {props.changes.map((change, ind) => (
                <Stack.Item key={ind}>• {change}</Stack.Item>
              ))}
            </Stack>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </>
  );
};

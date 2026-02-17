/**
 * @file
 * @copyright 2026
 * @author FlameArrow57 (https://github.com/FlameArrow57)
 * @license ISC
 */

import { BooleanLike } from 'common/react';
import { useState } from 'react';
import {
  Box,
  Collapsible,
  Section,
  Stack,
  Tabs,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const devHost = 'Wire (#1, #3, #4, Wiki, Forums, & more)';
const devTeamCoders =
  'stuntwaffle, Showtime, Pantaloons, Nannek, Keelin, Exadv1, hobnob, 0staf, sniperchance, AngriestIBM, BrianOBlivion, I Said No, Harmar, Dropsy, ProcitizenSA, Pacra, LLJK-Mosheninkov, JackMassacre, Jewel, Dr. Singh, Infinite Monkeys, Cogwerks, Aphtonites, Wire, BurntCornMuffin, Tobba, Haine, Marquesas, SpyGuy, Conor12, Daeren, Somepotato, MyBlueCorners, ZeWaka, Gannets, Kremlin, Flourish, Mordent, Cirrial, Grayshift, Firebarrage, Kyle, Azungar, Warcrimes, HydroFloric, Zamujasa, Gerhazo, Readster, pali6, Tarmunora, UrsulaMejor, Sovexe, MarkNstein, Virvatuli, Aloe, Caro, Sord, AdharaInSpace, Azrun, Walpvrgis, & LeahTheTech';
const devTeamSpriters =
  'Supernorn, Haruhi, Stuntwaffle, Pantaloons, Rho, SynthOrange, I Said No, Cogwerks, Aphtonites, Hempuli, Gannets, Haine, SLthePyro, Sundance, Azungar, Flaborized, Erinexx, & Walpvrgis';

interface ChangelogEntries {
  entries: Entries[];
  is_admin: BooleanLike;
  admin_entries: Entries[];
}

interface Entries {
  entry_date: string;
  major_entries: Entry[];
  minor_entries: Entry[];
}

interface Entry {
  author: string;
  pr_num: string | null;
  emojis: string | null;
  emoji_tooltips: string | null;
  changes: string[];
}

export const Changelog = () => {
  const { data } = useBackend<ChangelogEntries>();
  const { entries, is_admin, admin_entries } = data;
  const [tabIndex, setTabIndex] = useState(1);
  return (
    <Window title="Changelog">
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab selected={tabIndex === 1} onClick={() => setTabIndex(1)}>
            Changes
          </Tabs.Tab>
          {!!is_admin && (
            <Tabs.Tab selected={tabIndex === 2} onClick={() => setTabIndex(2)}>
              Admin
            </Tabs.Tab>
          )}
          <Tabs.Tab selected={tabIndex === 3} onClick={() => setTabIndex(3)}>
            Attribution
          </Tabs.Tab>
        </Tabs>
        {tabIndex === 1 && (
          <Stack vertical>
            <Stack.Item>
              <AllEntries entries={entries} />
            </Stack.Item>
            <Stack.Item>
              <Section title={'Goonstation contributors'}>
                Older changes can be viewed on the{' '}
                <a href={'https://wiki.ss13.co/Changelog'}>wiki</a>.
              </Section>
            </Stack.Item>
          </Stack>
        )}
        {tabIndex === 2 && <AllEntries entries={admin_entries} />}
        {tabIndex === 3 && (
          <Box>
            <Section title={'Licensing'}>
              Except where otherwise noted, Goonstation is licensed under the{' '}
              <a href="https://creativecommons.org/licenses/by-nc-sa/3.0/">
                Creative Commons Attribution-Noncommercial-Share Alike 3.0
                License
              </a>
              .
            </Section>
            <Section title={'Official Development Team'}>
              <Stack vertical>
                <Stack.Item>{`Host: ${devHost}`}</Stack.Item>
                <Stack.Divider />
                <Stack.Item>{`Coders: ${devTeamCoders}`}</Stack.Item>
                <Stack.Divider />
                <Stack.Item>{`Spriters: ${devTeamSpriters}`}</Stack.Item>
                <Stack.Divider />
              </Stack>
            </Section>
          </Box>
        )}
      </Window.Content>
    </Window>
  );
};

interface AllEntriesProps {
  entries: Entries[];
}

const AllEntries = (props: AllEntriesProps) => {
  const { entries } = props;
  return (
    <Box>
      {entries.map((item, index) => (
        <Section
          title={item.entry_date}
          key={index}
          backgroundColor={
            item.entry_date.includes('Testmerge') ? 'black' : null
          }
        >
          {!!item.major_entries?.length && (
            <EntriesList entries={item.major_entries} />
          )}
          {!!item.minor_entries?.length && (
            <Collapsible title="Minor Changes">
              <Box ml={1}>
                <EntriesList entries={item.minor_entries} />
              </Box>
            </Collapsible>
          )}
        </Section>
      ))}
    </Box>
  );
};

interface EntriesProps {
  entries: Entry[];
}

const EntriesList = (props: EntriesProps) => {
  const { entries } = props;
  return (
    <Stack vertical>
      {entries.map((item, index) => (
        <Stack.Item key={index} mb={0.5}>
          <Stack vertical>
            <Stack.Item>
              <Stack>
                <Stack.Item>
                  <b>{item.author}</b> updated:
                </Stack.Item>
                {!!item.emojis && (
                  <Stack.Item>
                    <Tooltip content={item.emoji_tooltips}>
                      {item.emojis}
                    </Tooltip>
                  </Stack.Item>
                )}
                {!!item.pr_num && (
                  <Stack.Item grow textAlign="right">
                    <a
                      href={`https://github.com/goonstation/goonstation/pull/${item.pr_num}`}
                    >
                      {`#${item.pr_num}`}
                    </a>
                  </Stack.Item>
                )}
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Stack vertical pl={1}>
                {item.changes.map((change, ind) => (
                  <Stack.Item key={ind}>{change}</Stack.Item>
                ))}
              </Stack>
            </Stack.Item>
            <Stack.Divider />
          </Stack>
        </Stack.Item>
      ))}
    </Stack>
  );
};

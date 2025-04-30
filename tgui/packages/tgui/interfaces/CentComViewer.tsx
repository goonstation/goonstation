/**
 * @file
 * @copyright 2023
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import {
  Button,
  Input,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface CentComViewerData {
  banData;
  key;
  filterInactive;
}

const getBanLength = (bannedOn, expires) => {
  const ONE_SECOND = 1000;
  const ONE_MINUTE = 60 * ONE_SECOND;
  const ONE_HOUR = 60 * ONE_MINUTE;
  const ONE_DAY = 24 * ONE_HOUR;
  const ONE_MONTH = 30 * ONE_DAY;
  const ONE_YEAR = 365 * ONE_DAY;
  const intervals = [
    { interval: ONE_SECOND, label: 'second' },
    { interval: ONE_MINUTE, label: 'minute' },
    { interval: ONE_HOUR, label: 'hour' },
    { interval: ONE_DAY, label: 'day' },
    { interval: ONE_MONTH, label: 'month' },
    { interval: ONE_YEAR, label: 'year' },
  ];

  // `+` to convert to numbers, keeps TS happy
  const banLength = +new Date(expires) - +new Date(bannedOn);

  for (const { interval, label } of intervals.reverse()) {
    if (banLength >= interval) {
      const count = Number((banLength / interval).toFixed(2));
      return `${count} ${label}${count === 1 ? '' : 's'}`;
    }
  }
  return 'Permanent';
};

// Define a functional component for rendering a single ban.
const Ban = ({ ban }) => {
  const { bannedOn, expires, jobs, reason, sourceName, type, unbannedBy } = ban;
  const expired = new Date(expires) < new Date();

  let currentStatus = '';
  if (ban.active && !expired) {
    currentStatus = 'Banned';
  } else if (!unbannedBy && expired) {
    currentStatus = 'Expired';
  } else if (unbannedBy) {
    currentStatus = 'Unbanned';
  }

  return (
    <Section title={`${type} Ban | ${sourceName}`}>
      <LabeledList>
        <LabeledList.Item label="Banned">
          {new Date(bannedOn).toLocaleString('en-US', {
            year: 'numeric',
            month: 'long',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
          })}
        </LabeledList.Item>
        <LabeledList.Item label="Length">
          {getBanLength(bannedOn, expires)}
        </LabeledList.Item>
        <LabeledList.Item label="Reason">{reason}</LabeledList.Item>
        {jobs && (
          <LabeledList.Item label="Jobs">{jobs.join(', ')}</LabeledList.Item>
        )}
        <LabeledList.Item
          label="Status"
          color={
            currentStatus === 'Banned'
              ? 'bad'
              : currentStatus === 'Expired'
                ? 'average'
                : 'good'
          }
        >
          {currentStatus}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

// Define a functional component for rendering the list of bans.
const BanList = ({ banData, filterInactive }) => {
  const filteredBans = filterInactive
    ? banData.filter((ban) => ban.active)
    : banData;

  return (
    <Stack fill vertical>
      {filteredBans.map((ban, index) => (
        <Stack.Item key={index}>
          <Ban ban={ban} />
        </Stack.Item>
      ))}
    </Stack>
  );
};

// Define the main RenderBans component.
const RenderBans = () => {
  const { data } = useBackend<CentComViewerData>();
  const { banData, filterInactive } = data;

  return <BanList banData={banData} filterInactive={filterInactive} />;
};

export const CentComViewer = () => {
  const { act, data } = useBackend<CentComViewerData>();
  const { key, filterInactive } = data;

  return (
    <Window title="CentCom Viewer" width={650} height={500}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section
              title={
                <>
                  {`Ban Data for `}
                  <Input
                    width="50vw"
                    value={key}
                    onChange={(value) => act('updateKey', { value })}
                  />
                </>
              }
              buttons={
                <Button.Checkbox
                  checked={filterInactive}
                  onClick={() => act('toggle-filterInactive')}
                >
                  Filter Inactive
                </Button.Checkbox>
              }
            />
          </Stack.Item>
          <Stack.Item grow>
            <Section scrollable fill>
              <Stack vertical>
                <RenderBans />
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

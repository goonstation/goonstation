/**
 * @file
 * @copyright 2020
 * @author ZeWaka (https://github.com/ZeWaka)
 * @license ISC
 */

import {
  Box,
  Button,
  Divider,
  Icon,
  Knob,
  LabeledControls,
  NoticeBox,
  NumberInput,
  Section,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';

import { useBackend } from '../backend';
import { truncate } from '../format';
import { Window } from '../layouts';

interface DJPanelProps {
  adminChannel: number;
  loadedSound: string;
  volume: number;
  frequency: number;
  announceMode: boolean;
  preloadedSounds: string[];
}

export const DJPanel = () => {
  const { act, data } = useBackend<DJPanelProps>();
  const { loadedSound, adminChannel, preloadedSounds } = data;
  return (
    <Window width={430} height={306} title="DJ Panel">
      <Window.Content>
        <Section>
          <Box>
            <strong>Active Soundfile: </strong>
            <Button
              icon={loadedSound ? 'file-audio' : 'upload'}
              selected={!loadedSound}
              tooltip={loadedSound}
              onClick={() => act('set-file')}
            >
              {loadedSound ? truncate(loadedSound, 38) : 'Upload'}
            </Button>
          </Box>
          <Divider />
          <KnobZone />
        </Section>
        <Section>
          <Box>
            <Button
              icon="music"
              selected={!!loadedSound}
              disabled={!loadedSound}
              onClick={() => act('play-music')}
            >
              Play Music
            </Button>
            <Button
              icon="volume-up"
              selected={!!loadedSound}
              disabled={!loadedSound}
              onClick={() => act('play-sound')}
            >
              Play Sound
            </Button>
            <Button
              icon="record-vinyl"
              selected={!!loadedSound}
              disabled={!loadedSound}
              onClick={() => act('play-ambience')}
            >
              Play Ambience
            </Button>
            <Box as="span" color="grey" textAlign="right" pl={1}>
              <Icon name="satellite" /> Channel: <em>{-adminChannel + 1024}</em>
            </Box>
          </Box>
        </Section>
        <Section>
          <Box>
            <Button onClick={() => act('play-remote')}>Play Remote</Button>
            <Button disabled={!loadedSound} onClick={() => act('play-player')}>
              Play To Player
            </Button>
          </Box>
          <Box>
            <Button
              disabled={!loadedSound}
              onClick={() => act('preload-sound')}
            >
              Preload Sound
            </Button>
            <Button
              disabled={!Object.keys(preloadedSounds).length}
              onClick={() => act('play-preloaded')}
            >
              Play Preloaded Sound
            </Button>
          </Box>
          <Box>
            <Button color="yellow" onClick={() => act('toggle-announce')}>
              Toggle DJ Announcements
            </Button>
            <Button color="yellow" onClick={() => act('toggle-player-dj')}>
              Toggle DJ For Player
            </Button>
          </Box>
          <Box>
            <Button icon="stop" color="red" onClick={() => act('stop-sound')}>
              Stop Last Sound
            </Button>
            <Button
              icon="broadcast-tower"
              color="red"
              onClick={() => act('stop-radio')}
            >
              Stop The Radio For Everyone
            </Button>
          </Box>
        </Section>
        <AnnounceActive />
      </Window.Content>
    </Window>
  );
};

interface AnnounceActiveProps {
  announceMode: boolean;
}
const AnnounceActive = () => {
  const { data } = useBackend<AnnounceActiveProps>();
  const { announceMode } = data;

  if (announceMode) {
    return <NoticeBox info>Announce Mode Enabled</NoticeBox>;
  }
};

const formatDoublePercent = (value) => toFixed(value * 2) + '%';
const formatHundredPercent = (value) => toFixed(value * 100) + '%';

interface KnobZoneProps {
  loadedSound: string;
  volume: number;
  frequency: number;
}
const KnobZone = () => {
  const { act, data } = useBackend<KnobZoneProps>();
  const { volume, frequency } = data;

  const setVolume = (value) => act('set-volume', { volume: value });
  const resetVolume = (value) => act('set-volume', { volume: 'reset' });
  const setFreq = (value) => act('set-freq', { frequency: value });
  const resetFreq = (value) => act('set-freq', { frequency: 'reset' });

  return (
    <Box>
      <LabeledControls>
        <LabeledControls.Item label="Volume">
          <NumberInput
            animated
            value={volume}
            minValue={0}
            maxValue={100}
            format={formatDoublePercent}
            onDrag={setVolume}
            step={1}
          />
        </LabeledControls.Item>
        <LabeledControls.Item label="">
          <Knob
            minValue={0}
            maxValue={100}
            ranges={{
              primary: [20, 80],
              average: [10, 90],
              bad: [0, 100],
            }}
            value={volume}
            format={formatDoublePercent}
            onDrag={setVolume}
          />
          <Button icon="sync-alt" top="0.3em" onClick={resetVolume}>
            Reset
          </Button>
        </LabeledControls.Item>
        <LabeledControls.Item label="Frequency">
          <NumberInput
            animated
            value={frequency}
            step={0.1}
            minValue={-100}
            maxValue={100}
            format={formatHundredPercent}
            onDrag={setFreq}
          />
        </LabeledControls.Item>
        <LabeledControls.Item label="">
          <Knob
            minValue={-100}
            maxValue={100}
            step={0.1}
            stepPixelSize={0.1}
            ranges={{
              primary: [-40, 40],
              average: [-70, 70],
              bad: [-100, 100],
            }}
            value={frequency}
            format={formatHundredPercent}
            onDrag={setFreq}
          />
          <Button icon="sync-alt" top="0.3em" onClick={resetFreq}>
            Reset
          </Button>
        </LabeledControls.Item>
      </LabeledControls>
    </Box>
  );
};

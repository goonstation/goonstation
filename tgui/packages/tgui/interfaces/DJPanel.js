/**
 * @file
 * @copyright 2020
 * @author ZeWaka (https://github.com/ZeWaka)
 * @license ISC
 */

import { toFixed } from 'common/math';
import { truncate } from '../format.js';
import { useBackend } from '../backend';
import { Button, Divider, NoticeBox, Section, Box, Knob, LabeledControls, Icon, NumberInput } from '../components';
import { Window } from '../layouts';

export const DJPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const { loadedSound, adminChannel } = data;
  return (
    <Window width={430} height={305} title="DJ Panel">
      <Window.Content>
        <Section>
          <Box>
            <strong>Active Soundfile: </strong>
            <Button
              icon={loadedSound ? 'file-audio' : 'upload'}
              selected={!loadedSound}
              content={loadedSound ? truncate(loadedSound, 38) : "Upload"}
              tooltip={loadedSound}
              onClick={() => act('set-file')}
            />
          </Box>
          <Divider />
          <KnobZone />
        </Section>
        <Section>
          <Box>
            <Button
              icon="music"
              selected={loadedSound}
              disabled={!loadedSound}
              content="Play Music"
              onClick={() => act('play-music')}
            />
            <Button
              icon="volume-up"
              selected={loadedSound}
              disabled={!loadedSound}
              content="Play Sound"
              onClick={() => act('play-sound')}
            />
            <Button
              icon="record-vinyl"
              selected={loadedSound}
              disabled={!loadedSound}
              content="Play Ambience"
              onClick={() => act('play-ambience')}
            />
            <Box as="span" color="grey" textAlign="right" pl={1}>
              <Icon name="satellite" /> Channel: <em>{ -adminChannel + 1024 }</em>
            </Box>
          </Box>
        </Section>
        <Section>
          <Box>
            <Button
              content="Play Remote"
              onClick={() => act('play-remote')}
            />
            <Button
              disabled={!loadedSound}
              content="Play To Player"
              onClick={() => act('play-player')}
            />
          </Box>
          <Box>
            <Button
              color="yellow"
              content="Toggle DJ Announcements"
              onClick={() => act('toggle-announce')}
            />
            <Button
              color="yellow"
              content="Toggle DJ For Player"
              onClick={() => act('toggle-player-dj')}
            />
          </Box>
          <Box>
            <Button
              icon="stop"
              color="red"
              content="Stop Last Sound"
              onClick={() => act('stop-sound')}
            />
            <Button
              icon="broadcast-tower"
              color="red"
              content="Stop The Radio For Everyone"
              onClick={() => act('stop-radio')}
            />
          </Box>
        </Section>
        <AnnounceActive />
      </Window.Content>
    </Window>
  );
};


const AnnounceActive = (props, context) => {
  const { data } = useBackend(context);
  const { announceMode } = data;

  if (announceMode) {
    return (
      <NoticeBox info>
        Announce Mode Enabled
      </NoticeBox>
    );
  }
};

const KnobZone = (props, context) => {
  const { act, data } = useBackend(context);
  const { loadedSound, volume, frequency } = data;

  return (
    <Box>
      <LabeledControls>
        <LabeledControls.Item label="Volume">
          <NumberInput
            animated
            value={volume}
            minValue={0}
            maxValue={100}
            format={value => {
              return toFixed(value * 2) + '%';
            }}
            onDrag={(e, value) => act('set-volume', {
              volume: value,
            })}
          />
        </LabeledControls.Item>
        <LabeledControls.Item>
          <Knob
            minValue={0}
            maxValue={100}
            ranges={{
              primary: [20, 80],
              average: [10, 90],
              bad: [0, 100],
            }}
            value={volume}
            format={value => {
              return toFixed(value * 2) + '%';
            }}
            onDrag={(e, value) => act('set-volume', {
              volume: value,
            })}
          />
          <Button
            icon="sync-alt"
            top="0.3em"
            content="Reset"
            onClick={() => act('set-volume', {
              volume: "reset",
            })}
          />
        </LabeledControls.Item>
        <LabeledControls.Item label="Frequency">
          <NumberInput
            animated
            value={frequency}
            step={0.1}
            minValue={-100}
            maxValue={100}
            format={value => {
              return toFixed(value * 100) + '%';
            }}
            onDrag={(e, value) => act('set-freq', {
              frequency: value,
            })}
          />
        </LabeledControls.Item>
        <LabeledControls.Item>
          <Knob
            disabled={!loadedSound}
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
            format={value => {
              return toFixed(value * 100) + '%';
            }}
            onDrag={(e, value) => act('set-freq', {
              frequency: value,
            })}
          />
          <Button
            icon="sync-alt"
            top="0.3em"
            content="Reset"
            onClick={() => act('set-freq', {
              frequency: "reset",
            })}
          />
        </LabeledControls.Item>
      </LabeledControls>
    </Box>
  );
};

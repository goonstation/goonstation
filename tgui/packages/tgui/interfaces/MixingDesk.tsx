/**
 * @file
 * @copyright 2021
 * @author pali (https://github.com/pali6)
 * @license MIT
 */

import { KeyboardEventHandler, useCallback } from 'react';
import {
  Box,
  Button,
  Input,
  LabeledList,
  Modal,
  Section,
} from 'tgui-core/components';

import { useBackend, useSharedState } from '../backend';
import { truncate } from '../format';
import { Window } from '../layouts';

interface MixingDeskData {
  voices: VoiceData[];
  selected_voice: number;
  say_popup;
}

interface VoiceData {
  accent?: string;
  name: string;
}

export const MixingDesk = () => {
  const { act, data } = useBackend<MixingDeskData>();
  const { voices, selected_voice, say_popup } = data;
  const [message, setMessage] = useSharedState('message', '');

  const sayPopup = () => (
    <Modal>
      {`Say as ${
        selected_voice > 0 && selected_voice <= voices.length
          ? voices[selected_voice - 1].name
          : 'yourself'
      }:`}
      <br />
      <Box pt="5px" pr="10px" textAlign="center">
        <Input
          autoFocus
          selfClear
          width={20}
          value={message}
          onEnter={(_, msg) => {
            window.focus();
            act('say', { message: msg });
            setMessage('');
          }}
          onChange={(_, msg) => setMessage(msg)}
        />
      </Box>
      <br />
      <Box textAlign="center">
        <Button
          onClick={() => {
            act('say', { message });
            setMessage('');
          }}
        >
          Say
        </Button>
        <Button
          onClick={() => {
            act('cancel_say');
            setMessage('');
          }}
        >
          Cancel
        </Button>
      </Box>
    </Modal>
  );

  const handleKeyDown = useCallback<KeyboardEventHandler>(
    (e) => {
      let key = String.fromCharCode(e.keyCode);
      let caught_key = true;
      if (key === 'T') {
        act('say_popup');
      } else if (e.keyCode === 27 && say_popup) {
        // escape
        act('cancel_say');
        setMessage('');
      } else if (!say_popup) {
        let num = Number(key);
        if (String(num) === key) {
          // apparently in js this is the correct way to check if it's a number
          act('switch_voice', { id: num });
        } else {
          caught_key = false;
        }
      } else {
        caught_key = false;
      }
      if (caught_key) {
        e.stopPropagation();
      }
    },
    [act, say_popup, setMessage],
  );

  return (
    <Window height={370} width={370}>
      <Window.Content onKeyDown={handleKeyDown}>
        {!!say_popup && sayPopup()}
        <Section title="Voice Synthesizer">
          <LabeledList>
            {voices.map((entry, index) => (
              <LabeledList.Item
                key={entry.name}
                className="candystripe"
                label={
                  <Box>
                    {`${index + 1} ${truncate(entry['name'], 18)}${entry.accent ? ` [${entry.accent}]` : ''}`}
                  </Box>
                }
                labelColor={index + 1 === selected_voice ? 'red' : 'label'}
                buttons={
                  <>
                    <Button
                      icon="trash-alt"
                      onClick={() => act('remove_voice', { id: index + 1 })}
                    />
                    <Button
                      icon="bullhorn"
                      onClick={() => act('say_popup', { id: index + 1 })}
                    />
                  </>
                }
              />
            ))}
            <LabeledList.Item
              buttons={
                <Button
                  icon="plus"
                  onClick={() => act('add_voice')}
                  disabled={voices.length >= 9}
                >
                  Add
                </Button>
              }
              className="candystripe"
            />
          </LabeledList>
        </Section>
        <Section textAlign="center">
          <Box>
            Press T to talk and 1-9 keys to switch voices.
            <br />
            Press 0 to reset to your normal voice.
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};

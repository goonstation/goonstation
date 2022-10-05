import { classes } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Input, Knob, LabeledList } from '../components';
import { Window } from '../layouts';

type MusicInstrumentData = {
  name: string;
  volume: number;
  transpose: number;
  notes: string[];
  keybindToggle: boolean;
};

export const MusicInstrument = (_props, context) => {
  const { act, data } = useBackend<MusicInstrumentData>(context);
  const { name, notes, volume, transpose, keybindToggle } = data;

  const [noteKeysOrder, setNoteKeysOrder] = useLocalState(
    context,
    'keyboardBindingsOrder',
    'zsxdcvgbhnjmq2w3er5t6y7ui9o0p+'.split('')
  );

  const [activeKeys, setActiveKeys] = useLocalState(context, 'keyboardActivekeys', {}); // new Array(notes.length)
  const [keyOffset, setKeyOffset] = useLocalState(context, 'keyOffset', 0);

  const setVolume = (value: number) => {
    act('set_volume', { value });
  };

  const setTranspose = (value: number) => {
    act('set_transpose', { value });
  };

  const setKeybindToggle = (value: boolean) => {
    if (value) {
      act('play_keyboard_on');
    } else {
      act('play_keyboard_off');
    }
  };

  const toggleKeybind = () => {
    setKeybindToggle(!keybindToggle);
  };

  const keyIndexWithinRange = (index: number) => index + transpose >= 0 && index + transpose < notes.length;

  const playNote = (index: number) => {
    if (keyIndexWithinRange(index) && !activeKeys[index]) {
      act('play_note', { note: index + transpose, volume: volume });
      const newKeys = activeKeys;
      const note = notes[index];
      newKeys[note] = true;
      setActiveKeys(newKeys);
    }
  };

  const playNoteRelease = (index: number) => {
    if (keyIndexWithinRange(index)) {
      const newKeys = activeKeys;
      const note = notes[index];
      newKeys[note] = false;
      setActiveKeys(newKeys);
    }
  };

  const getKeyboardIndex = (key: string) => {
    const keyboardIndex = keyOffset + noteKeysOrder.findIndex((keyOrder) => keyOrder === key);
    if (keyboardIndex >= 0) return keyboardIndex;
    return -1;
  };

  return (
    <Window title={name} width={50 + notes.length * 30} height={410}>
      <Window.Content
        onKeyUp={(ev) => {
          if (keybindToggle) {
            let index = getKeyboardIndex(ev.key);
            playNoteRelease(index);
          }
        }}
        onKeyDown={(ev) => {
          if (keybindToggle) {
            let index = getKeyboardIndex(ev.key);
            playNote(index);
          }

          if (ev.key === 'Control') {
            toggleKeybind();
          }
        }}>
        <Box className="instrument__keyboardwrapper">
          <Box className="instrument__outerpanel">
            <Box className="instrument__speaker" />
            <Flex direction="column">
              <Box className="instrument__panel">
                <Box className="instrument__keyboardsupport">
                  <Button
                    className="instrument__toggle-keyboard-button"
                    title="Toggle keyboard support (toggle with ctrl)"
                    onClick={toggleKeybind}
                    icon="keyboard"
                  />
                  <Box
                    className="instrument__keybind-indicator"
                    style={{
                      'box-shadow': `0px 0px 5px ${keybindToggle ? '#1b9b37' : '#5a1919'}`,
                      'background': `${keybindToggle ? '#1b9b37' : '#5a1919'}`,
                    }}
                  />
                </Box>
                <Box className="instrument__panel-input">
                  <Knob
                    animated
                    stepPixelSize={24}
                    minValue={-24}
                    maxValue={24}
                    value={keyOffset}
                    onDrag={(e, v) => setKeyOffset(v)}
                    title={'Keybind offset'}
                  />
                  <span>Offset</span>
                </Box>
                <Box className="instrument_panel-info">
                  <h1 style={{ 'text-align': 'center' }}>{name.toUpperCase()}</h1>
                </Box>
                <Box className="instrument__panel-input">
                  <Knob
                    animated
                    stepPixelSize={1}
                    minValue={0}
                    maxValue={100}
                    title="Volume"
                    value={volume}
                    onDrag={(e, v) => setVolume(v)}
                  />
                  <span>Volume</span>
                </Box>
                <Box className="instrument__panel-input">
                  <Knob
                    animated
                    stepPixelSize={6}
                    minValue={-12}
                    maxValue={12}
                    title="Transpose"
                    value={transpose}
                    onDrag={(e, v) => setTranspose(v)}
                  />
                  <span>Transpose</span>
                </Box>
              </Box>
              <Box className="instrument__keyorder">
                <Box className="instrument__instructions" fontSize="1.1em">
                  Key binding order for keyboard input
                </Box>
                <Input
                  className="instrument__input_keyorder"
                  value={noteKeysOrder.join('')}
                  onInput={(e, v) => setNoteKeysOrder(v.split(''))}
                />
                <Box className="instrument__instructions" fontSize="0.8em" bold>
                  Type in the order you wish the keybindings to be placed
                </Box>
              </Box>
            </Flex>
            <Box className="instrument__speaker" />
          </Box>
          <ul className="instruments__piano">
            {notes.map((note, index) => {
              const isBlackKey = note.includes('-');
              const keybind = noteKeysOrder[index - keyOffset];
              const keyClass = isBlackKey ? 'instruments__piano-key-black' : 'instruments__piano-key-white';
              const isWhiteOffsetKey = ['d', 'e', 'g', 'a', 'b'].includes(note.split('')[0]);
              const whiteKeyOffsetClass = isWhiteOffsetKey && !isBlackKey ? 'instruments__piano-key-white-offset' : '';

              return (
                <li
                  key={index}
                  className={classes([
                    'instruments__piano-key',
                    keyClass,
                    whiteKeyOffsetClass,
                    activeKeys[notes[index]]
                      ? isBlackKey
                        ? 'instruments__piano-key-black-active'
                        : 'instruments__piano-key-white-active'
                      : '',
                  ])}
                  onMouseDown={() => playNote(index)}
                  onMouseLeave={() => playNoteRelease(index)}
                  onMouseUp={() => playNoteRelease(index)}>
                  <Box className="instruments__notedetails">
                    {keybind && <Box className="instruments__notekey">{keybind}</Box>}
                    <Box className="instruments__notename">{note.replace('-', '#')}</Box>
                  </Box>
                </li>
              );
            })}
          </ul>
        </Box>
      </Window.Content>
    </Window>
  );
};

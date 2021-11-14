import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Input, Knob, LabeledList } from '../components';
import { Window } from '../layouts';

type MusicInstrumentData = {
  name: string;
  notes: string[];
};

export const MusicInstrument = (_props, context) => {
  const { act, data } = useBackend<MusicInstrumentData>(context);
  const { name, notes } = data;

  const [noteKeysOrder, setNoteKeysOrder] = useLocalState(
    context,
    'keyboardBindingsOrder',
    'zsxdcvgbhnjmq2w3er5t6y7ui9o0p+'.split('')
  );

  const [activeKeys, setActiveKeys] = useLocalState(context, 'keyboardActivekeys', new Array(notes.length));
  const [keyOffset, setKeyOffset] = useLocalState(context, 'keyOffset', 0);
  const [keybindToggle, setKeybindToggle] = useLocalState(context, 'keybindToggle', false);
  const [volume, setVolume] = useLocalState(context, 'keyboardVolume', 50);
  const [transpose, setTranspose] = useLocalState(context, 'keyboardTranspose', 0);

  const toggleKeybind = () => {
    if (keybindToggle) {
      act('play_keyboard_off');
      setKeybindToggle(false);
    } else {
      act('play_keyboard_on');
      setKeybindToggle(true);
    }
  };

  const keyIndexWithinRange = (index: number) => index + transpose >= 0 && index + transpose < notes.length;

  const playNote = (index: number) => {
    if (keyIndexWithinRange(index) && !activeKeys[index]) {
      act('play_note', { note: index + transpose + 1, volume: volume });
      const newKeys = [...activeKeys];
      newKeys[index] = true;
      setActiveKeys(newKeys);
    }
  };

  const playNoteRelease = (index: number) => {
    if (keyIndexWithinRange(index)) {
      const newKeys = activeKeys;
      newKeys[index] = false;
      setActiveKeys(newKeys);
    }
  };

  const getKeyboardIndex = (key: string) => {
    return keyOffset + noteKeysOrder.findIndex((keyOrder) => keyOrder === key);
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
                <h4>Key binding order for keyboard input</h4>
                <Input
                  className="instrument__input_keyorder"
                  value={noteKeysOrder.join('')}
                  onInput={(e, v) => setNoteKeysOrder(v.split(''))}
                />
                <h6>Type in the order you wish the keybindings to be placed</h6>
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
              const wko = isWhiteOffsetKey && !isBlackKey ? 'instruments__piano-kwo' : '';

              return (
                <li
                  key={index}
                  className={`instruments__piano-key ${keyClass} ${wko} ${
                    activeKeys[index]
                      ? isBlackKey
                        ? 'instruments__piano-key-black-active'
                        : 'instruments__piano-key-white-active'
                      : ''
                  }`}
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

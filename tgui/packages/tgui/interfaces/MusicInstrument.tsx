import { classes } from 'common/react';
import { useEffect, useRef, useState } from 'react';
import { Box, Button, Flex, Input } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Knob } from '../components';
import { Window } from '../layouts';

type MusicInstrumentData = {
  name: string;
  volume: number;
  transpose: number;
  notes: string[];
  keybindToggle: boolean;
  noteKeysString: string;
  supportsSustain: boolean;
  legacyMode: boolean;
};

type HeldNote = {
  index: number;
  voice: string;
};

let instrumentInstanceCounter = 0;

export const MusicInstrument = () => {
  const { act, data } = useBackend<MusicInstrumentData>();
  const {
    name,
    notes,
    volume,
    transpose,
    keybindToggle,
    noteKeysString,
    supportsSustain,
    legacyMode,
  } = data;

  const [noteKeysOrder, setNoteKeysOrder] = useState(noteKeysString.split(''));

  const [activeKeys, setActiveKeys] = useState<Record<number, boolean>>({});
  const [keyOffset, setKeyOffset] = useState(0);
  const heldKeyboardNotes = useRef(new Map<string, HeldNote>());
  const heldMouseNotes = useRef(new Map<number, HeldNote>());
  const activeNoteCounts = useRef(new Map<number, number>());
  const voiceCounter = useRef(0);
  const [instanceId] = useState(() => ++instrumentInstanceCounter);
  const actRef = useRef(act);
  const stopHeldNotesRef = useRef<() => void>(() => {});
  actRef.current = act;

  const setNoteActive = (index: number, active: boolean) => {
    const count = activeNoteCounts.current.get(index) || 0;
    const nextCount = active ? count + 1 : Math.max(0, count - 1);
    if (nextCount) activeNoteCounts.current.set(index, nextCount);
    else activeNoteCounts.current.delete(index);
    setActiveKeys((current) => ({ ...current, [index]: Boolean(nextCount) }));
  };

  const stopHeldNotes = () => {
    heldKeyboardNotes.current.clear();
    heldMouseNotes.current.clear();
    activeNoteCounts.current.clear();
    setActiveKeys({});
    actRef.current('stop_notes', {});
  };

  stopHeldNotesRef.current = stopHeldNotes;

  const beginNote = (
    index: number,
    heldNotes: Map<string | number, HeldNote>,
    id: string | number,
  ) => {
    if (index < 0 || index >= notes.length || heldNotes.has(id)) return;
    const note = index + transpose;
    if (note < 0 || note >= notes.length) return;
    const voice = `instrument-${instanceId}-note-${++voiceCounter.current}`;
    heldNotes.set(id, {
      index,
      voice,
    });
    setNoteActive(index, true);
    act('start_note', { note, volume, voice });
  };

  const endNote = (
    heldNotes: Map<string | number, HeldNote>,
    id: string | number,
  ) => {
    const held = heldNotes.get(id);
    if (!held) return;
    heldNotes.delete(id);
    setNoteActive(held.index, false);
    actRef.current('stop_note', { voice: held.voice });
  };

  useEffect(() => {
    const releaseAll = () => stopHeldNotesRef.current();
    const releasePointer = (ev: PointerEvent) => {
      endNote(heldMouseNotes.current, ev.pointerId);
    };
    window.addEventListener('blur', releaseAll);
    window.addEventListener('pagehide', releaseAll);
    window.addEventListener('pointerup', releasePointer);
    window.addEventListener('pointercancel', releasePointer);
    return () => {
      releaseAll();
      window.removeEventListener('blur', releaseAll);
      window.removeEventListener('pagehide', releaseAll);
      window.removeEventListener('pointerup', releasePointer);
      window.removeEventListener('pointercancel', releasePointer);
    };
  }, []);

  const setVolume = (value: number) => {
    act('set_volume', { value });
  };

  const setTranspose = (value: number) => {
    act('set_transpose', { value });
  };

  const setKeybindToggle = (value: boolean) => {
    if (!value) stopHeldNotes();
    if (value) {
      act('play_keyboard_on');
    } else {
      act('play_keyboard_off');
    }
  };

  const toggleKeybind = () => {
    setKeybindToggle(!keybindToggle);
  };

  const setLegacyMode = (enabled: boolean) => {
    stopHeldNotes();
    act('set_legacy_mode', { enabled });
  };

  const getKeyboardIndex = (key: string) => {
    const bindingIndex = noteKeysOrder.findIndex(
      (keyOrder) => keyOrder === key,
    );
    return bindingIndex < 0 ? -1 : keyOffset + bindingIndex;
  };

  const isTypingTarget = (target: EventTarget | null) => {
    const element = target as HTMLElement | null;
    return (
      element?.tagName === 'INPUT' ||
      element?.tagName === 'TEXTAREA' ||
      element?.isContentEditable
    );
  };

  return (
    <Window title={name} width={50 + notes.length * 30} height={410}>
      <Window.Content
        // BoxProps does not expose tabIndex.
        {...{ tabIndex: -1 }}
        onKeyUp={(ev) => {
          endNote(heldKeyboardNotes.current, ev.code || ev.key);
        }}
        onKeyDown={(ev) => {
          if (
            keybindToggle &&
            !isTypingTarget(ev.target) &&
            !ev.ctrlKey &&
            !ev.altKey &&
            !ev.metaKey
          ) {
            beginNote(
              getKeyboardIndex(ev.key),
              heldKeyboardNotes.current,
              ev.code || ev.key,
            );
          }

          if (ev.key === 'Control') {
            toggleKeybind();
          }
        }}
      >
        <Box className="instrument__keyboardwrapper">
          <Box className="instrument__outerpanel">
            <Box className="instrument__speaker" />
            <Flex direction="column">
              <Box className="instrument__panel">
                <Box className="instrument__keyboardsupport">
                  <Button
                    className="instrument__toggle-keyboard-button"
                    tooltip="Toggle keyboard support (toggle with ctrl)"
                    onClick={toggleKeybind}
                    icon="keyboard"
                  />
                  <Box
                    className="instrument__keybind-indicator"
                    style={{
                      boxShadow: `0px 0px 5px ${keybindToggle ? '#1b9b37' : '#5a1919'}`,
                      background: `${keybindToggle ? '#1b9b37' : '#5a1919'}`,
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
                    onChange={(e, v) => setKeyOffset(v)}
                    title="Keybind offset"
                  />
                  <span>Offset</span>
                </Box>
                <Box className="instrument_panel-info">
                  <h1 style={{ textAlign: 'center' }}>{name.toUpperCase()}</h1>
                </Box>
                <Box className="instrument__panel-input">
                  <Knob
                    animated
                    stepPixelSize={1}
                    minValue={0}
                    maxValue={100}
                    title="Volume"
                    value={volume}
                    onChange={(e, v) => setVolume(v)}
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
                    onChange={(e, v) => setTranspose(v)}
                  />
                  <span>Transpose</span>
                </Box>
                {supportsSustain ? (
                  <Button.Checkbox
                    checked={legacyMode}
                    onClick={() => setLegacyMode(!legacyMode)}
                  >
                    Legacy Mode
                  </Button.Checkbox>
                ) : null}
              </Box>
              <Box className="instrument__keyorder">
                <Box className="instrument__instructions" fontSize="1.1em">
                  Key binding order for keyboard input
                </Box>
                <Input
                  className="instrument__input_keyorder"
                  value={noteKeysOrder.join('')}
                  onChange={(v) => setNoteKeysOrder(v.split(''))}
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
              const keyClass = isBlackKey
                ? 'instruments__piano-key-black'
                : 'instruments__piano-key-white';
              const isWhiteOffsetKey = ['d', 'e', 'g', 'a', 'b'].includes(
                note.split('')[0],
              );
              const whiteKeyOffsetClass =
                isWhiteOffsetKey && !isBlackKey
                  ? 'instruments__piano-key-white-offset'
                  : '';

              return (
                <li
                  key={index}
                  className={classes([
                    'instruments__piano-key',
                    keyClass,
                    whiteKeyOffsetClass,
                    activeKeys[index]
                      ? isBlackKey
                        ? 'instruments__piano-key-black-active'
                        : 'instruments__piano-key-white-active'
                      : '',
                  ])}
                  onPointerDown={(ev) =>
                    beginNote(index, heldMouseNotes.current, ev.pointerId)
                  }
                >
                  <Box className="instruments__notedetails">
                    {keybind && (
                      <Box className="instruments__notekey">{keybind}</Box>
                    )}
                    <Box className="instruments__notename">
                      {note.replace('-', '#')}
                    </Box>
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

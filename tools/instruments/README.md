# Instrument sample banks

All imported instruments use this layout under `sound/musical_instruments/`:

```text
instrument/sustain/
  samples.json
  normal/
    1-65/c4.ogg
    66-99/c4.ogg
    100-127/c4.ogg
  pedal/                  optional pedal-down recordings
    1-65/c4.ogg
    ...
  release/                optional key-up recordings
    1-65/c4.ogg
    ...
```

Filenames give the recording's actual pitch in scientific pitch notation:
`c4.ogg` is middle C, `cs4.ogg` is C sharp. Normalize source libraries' octave
labels when importing. Every articulation uses the same naming and velocity
folders. A single-layer instrument uses `normal/1-127/`.

## Adding recordings

1. Put the OGGs in their articulation and velocity folders. Velocity folders must
   cover 1–127 with no overlaps or gaps. Layers within an articulation must cover
   the same playable notes; pedal recordings must cover the normal note range.
2. Add `sustain/samples.json` with the instrument's playable range:

   ```json
   {
     "range": ["c3", "c6"]
   }
   ```

3. Run from the repository root with Python:

   ```sh
   python tools/instruments/generate_samples.py
   python tools/instruments/generate_samples.py --check
   ```

The generator discovers every `*/sustain/samples.json`; adding an instrument
requires no Python changes. Adding a recording inside its configured range only
requires regenerating the table. It reads durations from the OGGs and preserves
their audio bytes. The script uses Python's standard library.

For an existing TGUI instrument, enable `supports_sustain` and make sure its
`instrument_sound_directory` matches `sound/musical_instruments/instrument/notes/`.
Legacy recordings remain in `notes/` for Legacy Mode and unmapped keys.

## Mapping settings

| Setting | Default | Meaning |
| --- | --- | --- |
| `range` | Required | First and last playable note, inclusive. |
| `pitch_shift_down` | `0` | Maximum semitones a recording may be lowered. |
| `pitch_shift_up` | `0` | Maximum semitones a recording may be raised. |
| `fade` | `0.4` | Fade duration in seconds on key-up. |
| `volume_scale` | `1` | Playback gain after audibility checks. |

The nearest eligible recording supplies each key. Keys beyond the permitted
pitch shifts retain legacy playback. A normal recording applies in either pedal
state when the bank has no `pedal/` recordings.

Settings inside `normal`, `pedal`, or `release` objects override the bank's
defaults. Piano, for example, raises recordings by at most one semitone and
uses a shorter range and calibrated gain for its release recordings:

```json
{
  "range": ["c2", "c7"],
  "pitch_shift_up": 1,
  "release": {
    "range": ["c2", "ds6"],
    "fade": 0,
    "volume_scale": 0.02
  }
}
```

Output: `code/modules/items/instruments/instrument_sustain_samples.dm`.
Rows contain the recording, duration, and semitone offset. A key such as
`c2 c-2` covers consecutive pitches, starting at the row's offset. The shared
builder in `instrument_sample_mapping.dm` expands these rows at startup.

The current guitar recordings come from Meta Open Sound. Piano (JH Steinway B)
and tenor saxophone recordings come from VCSL. These imports are CC0; retain
source and license information when adding recordings from other libraries.

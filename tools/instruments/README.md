# Instrument sample table

Run from the repository root with Python

```sh
python tools/instruments/generate_samples.py
python tools/instruments/generate_samples.py --check
```

Regenerate after changing imported piano, guitar, or saxophone recordings.
`--check` reports stale output. The generator uses Python's standard library.

Note names and durations come from the OGGs. Durations round up to milliseconds
for channel cleanup. `IMPORTED` defines instrument ranges, pitch-shift limits,
and filename octave offsets; piano filenames identify articulation and velocity.

Guitar's main folder contains hard strikes. Its `soft` and `medium` subfolders
contain recorded strikes for velocities 1–65 and 66–99; hard strikes cover 100–127.
Tuning and level corrections are baked into the recordings.

Output: `code/modules/items/instruments/instrument_sustain_samples.dm`.
Piano, guitar, and saxophone share one table and selector in
`instrument_sample_mapping.dm`. Each section sets its instrument, velocity range,
and any pedal or release settings. Rows contain the recording, duration, and
semitone offset. A key such as `c2 c-2` maps one recording to consecutive pitches;
the first uses the row's offset, and each following pitch adds one semitone.
Sections with no pedal setting apply in both pedal states.
Legacy recordings use `play_note()`.

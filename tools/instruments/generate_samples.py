# Generates held-note metadata for the imported instrument recordings.

import argparse
import json
import math
import re
import struct
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOUNDS = ROOT / "sound/musical_instruments"
OUTPUT = ROOT / "code/modules/items/instruments/instrument_sustain_samples.dm"
NOTES = ("c", "c-", "d", "d-", "e", "f", "f-", "g", "g-", "a", "a-", "b")
ARTICULATIONS = ("normal", "pedal", "release")


def note_number(name):
    if not isinstance(name, str) or not re.fullmatch(r"[a-g](s|-)?[0-9]", name):
        raise ValueError(f"Expected a note such as c4 or cs4, got {name!r}")
    name = name.replace("s", "-")
    return (int(name[-1]) + 1) * 12 + NOTES.index(name[:-1])


def note_name(number):
    return NOTES[number % 12] + str(number // 12 - 1)


def duration(path):
    sample_rate = None
    stream_id = None
    last_granule = 0
    with path.open("rb") as audio:
        while header := audio.read(27):
            if len(header) != 27 or header[:5] != b"OggS\x00":
                raise ValueError(f"Invalid OGG page: {path}")
            granule, page_stream_id = struct.unpack_from("<QI", header, 6)

            segments = audio.read(header[26])
            if len(segments) != header[26]:
                raise ValueError(f"Truncated OGG page: {path}")
            payload_size = sum(segments)
            payload = audio.read(payload_size)
            if len(payload) != payload_size:
                raise ValueError(f"Truncated OGG packet: {path}")

            if sample_rate is None:
                if len(payload) < 16 or payload[:7] != b"\x01vorbis":
                    raise ValueError(f"Expected Vorbis audio: {path}")
                sample_rate = struct.unpack_from("<I", payload, 12)[0]
                stream_id = page_stream_id
            if page_stream_id != stream_id:
                raise ValueError(f"Multiple OGG streams: {path}")
            if granule != 0xFFFFFFFFFFFFFFFF:
                last_granule = granule

    if not sample_rate or not last_granule:
        raise ValueError(f"Missing audio duration: {path}")
    # The final granule gives the decoded sample count. Round up for channel cleanup.
    milliseconds = (last_granule * 1000 + sample_rate - 1) // sample_rate
    return f"{milliseconds / 1000:.3f}".rstrip("0").rstrip(".")


def sample_rows(folder, settings):
    note_range = settings.get("range")
    if not isinstance(note_range, list) or len(note_range) != 2:
        raise ValueError(f"Set range to two note names in samples.json: {folder}")
    first, last = map(note_number, note_range)
    if first > last:
        raise ValueError(f"Reversed note range in {folder}")

    shift_down = settings.get("pitch_shift_down", 0)
    shift_up = settings.get("pitch_shift_up", 0)
    for shift in (shift_down, shift_up):
        if type(shift) is not int or shift < 0:
            raise ValueError(f"Pitch-shift limits must be nonnegative integers: {folder}")

    recordings = {}
    for path in sorted(folder.glob("*.ogg")):
        root = note_number(path.stem)
        if root in recordings:
            raise ValueError(f"Duplicate recorded pitches in {folder}")
        recordings[root] = path
    if not recordings:
        raise ValueError(f"No recordings in {folder}")

    notes_by_root = {}
    for number in range(first, last + 1):
        candidates = [
            root for root in recordings
            if -shift_down <= number - root <= shift_up
        ]
        if not candidates:
            continue
        closest = min(candidates, key=lambda root: abs(root - number))
        notes_by_root.setdefault(closest, []).append(number)

    rows = []
    coverage = set()
    for root, numbers in notes_by_root.items():
        path = recordings[root]
        if numbers != list(range(numbers[0], numbers[-1] + 1)):
            raise ValueError(f"Nonconsecutive mapped notes for {path}")
        notes = " ".join(note_name(number) for number in numbers)
        recording = f"'{path.relative_to(ROOT).as_posix()}'"
        offset = numbers[0] - root
        rows.append(f'\t\t"{notes}" = list({recording}, {duration(path)}, {offset}),')
        coverage.update(numbers)
    if not coverage:
        raise ValueError(f"No playable notes in {folder}")
    return rows, coverage


def sample_section(family, rows, options):
    arguments = ", ".join(options)
    return [
        f'\tadd_instrument_sample_section(., "{family}", list(',
        *rows,
        f"\t), {arguments})",
        "",
    ]


def velocity_layers(folder):
    layers = []
    for path in folder.iterdir():
        if not path.is_dir():
            raise ValueError(f"Recordings belong in velocity folders: {path}")
        match = re.fullmatch(r"(\d+)-(\d+)", path.name)
        if not match:
            raise ValueError(f"Expected a velocity folder such as 1-127: {path}")
        low, high = map(int, match.groups())
        if not 1 <= low <= high <= 127:
            raise ValueError(f"Invalid velocity range: {path}")
        layers.append((low, high, path))

    layers.sort()
    next_velocity = 1
    for low, high, path in layers:
        if low != next_velocity:
            raise ValueError(f"Velocity ranges must cover 1-127 without gaps or overlaps: {folder}")
        next_velocity = high + 1
    if next_velocity != 128:
        raise ValueError(f"Velocity ranges must cover 1-127: {folder}")
    return layers


def playback_options(folder, settings):
    options = []
    if folder.name == "pedal":
        options.append("resonant = TRUE")
    elif folder.name == "normal" and (folder.parent / "pedal").is_dir():
        options.append("resonant = FALSE")
    elif folder.name == "release":
        options.append("release_sample = TRUE")

    fade = settings.get("fade", 0.4)
    volume_scale = settings.get("volume_scale", 1)
    for name, value in (("fade", fade), ("volume_scale", volume_scale)):
        if not isinstance(value, (int, float)) or not math.isfinite(value) or value < 0:
            raise ValueError(f"Invalid {name} in {folder.parent / 'samples.json'}")

    if fade != 0.4:
        options.append(f"release = {fade:g}")
    if volume_scale != 1:
        options.append(f"volume_scale = {volume_scale:g}")
    return options


def read_bank(config_path):
    bank = config_path.parent
    settings = json.loads(config_path.read_text(encoding="utf-8"))
    fields = {"range", "pitch_shift_down", "pitch_shift_up", "fade", "volume_scale"}
    allowed_fields = fields | set(ARTICULATIONS)
    if not isinstance(settings, dict):
        raise ValueError(f"Expected a settings object in {config_path}")
    if settings.keys() - allowed_fields:
        raise ValueError(f"Unknown bank settings in {config_path}")

    if not (bank / "normal").is_dir():
        raise ValueError(f"Missing normal recordings: {bank}")
    for path in bank.iterdir():
        if path.is_dir():
            if path.name not in ARTICULATIONS:
                raise ValueError(f"Unknown articulation folder: {path}")
            overrides = settings.get(path.name, {})
            if not isinstance(overrides, dict) or overrides.keys() - fields:
                raise ValueError(f"Unknown {path.name} settings in {config_path}")
        if path.suffix == ".ogg":
            raise ValueError(f"Recordings belong in articulation/velocity folders: {path}")
    return settings


def bank_sections(config_path):
    settings = read_bank(config_path)
    bank = config_path.parent
    family = bank.parent.name
    lines = []
    normal_coverage = None

    for articulation in ARTICULATIONS:
        folder = bank / articulation
        if not folder.is_dir():
            continue
        section = settings.copy()
        section.update(settings.get(articulation, {}))
        options = playback_options(folder, section)

        layer_coverage = None
        for low, high, layer in velocity_layers(folder):
            rows, coverage = sample_rows(layer, section)
            if layer_coverage is not None and coverage != layer_coverage:
                raise ValueError(f"Velocity layers cover different notes: {folder}")
            layer_coverage = coverage
            velocity = [f"velocity_min = {low}", f"velocity_max = {high}"]
            lines.extend(sample_section(family, rows, velocity + options))

        if articulation == "normal":
            normal_coverage = layer_coverage
        elif articulation == "pedal" and layer_coverage != normal_coverage:
            raise ValueError(f"Normal and pedal recordings must cover the same notes: {bank}")
    return lines


def render():
    lines = [
        "// Generated by tools/instruments/generate_samples.py.",
        "var/global/list/instrument_sustain_samples = build_instrument_sustain_samples()",
        "",
        "/// Columns: recording, duration in seconds, semitone offset.",
        "/// Space-separated keys cover consecutive semitones, starting at that offset.",
        "/proc/build_instrument_sustain_samples()",
        "\t. = list()",
    ]
    configs = sorted(SOUNDS.glob("*/sustain/samples.json"))
    if not configs:
        raise ValueError("No instrument samples.json files found")
    for config_path in configs:
        lines.extend(bank_sections(config_path))
    return "\n".join(lines).rstrip() + "\n"


def main():
    parser = argparse.ArgumentParser(description="Generate held-note sample metadata")
    parser.add_argument("--check", action="store_true", help="Check that the generated file is current")
    args = parser.parse_args()
    try:
        text = render()
    except (ValueError, OSError) as error:
        parser.exit(1, f"{error}\n")
    if args.check:
        if not OUTPUT.exists() or OUTPUT.read_text(encoding="utf-8") != text:
            parser.exit(1, "Sample table is outdated. Run tools/instruments/generate_samples.py\n")
        print("Sample table is current.")
    else:
        OUTPUT.write_text(text, encoding="utf-8", newline="\n")
        print(f"Wrote {OUTPUT.relative_to(ROOT)} ({len(text.encode()):,} bytes)")


if __name__ == "__main__":
    main()

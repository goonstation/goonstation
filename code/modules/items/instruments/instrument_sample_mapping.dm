/proc/build_instrument_sample_family(family, list/rows)
	. = list()
	for (var/note in rows)
		var/list/row = rows[note]
		var/key = "sound/musical_instruments/[family]/notes/[note].ogg"
		.[key] = list("file" = row[1], "duration" = row[2], \
			"pitch" = 2 ** (row[3] / 12), "gain" = 1)

/proc/piano_add_section(list/regions, list/rows, velocity_min, velocity_max, \
	resonant = FALSE, release_sample = FALSE, release = 0.4, volume_scale = 1)
	var/static/list/adjacent_classes = list("c" = "c-", "d" = "d-", "e" = "f", "f-" = "g", "g-" = "a", "a-" = "b")
	for (var/list/row as anything in rows)
		var/root_note = row[1]
		var/list/sample = list("file" = row[2], "duration" = row[3], "gain" = 1, "volume_scale" = volume_scale, "pitch" = 1, \
			"velocity_min" = velocity_min, "velocity_max" = velocity_max, "resonant" = resonant, \
			"release_sample" = release_sample, "release" = release)
		var/root_key = "sound/musical_instruments/piano/notes/[root_note].ogg"
		regions[root_key] ||= list()
		regions[root_key] += list(sample)
		// Whole-tone recordings cover their root and the next semitone, up to C7.
		if (root_note == "c7")
			continue
		var/root_class = copytext(root_note, 1, length(root_note))
		var/octave = copytext(root_note, length(root_note))
		var/adjacent_key = "sound/musical_instruments/piano/notes/[adjacent_classes[root_class]][octave].ogg"
		var/list/adjacent_sample = sample.Copy()
		adjacent_sample["pitch"] = 2 ** (1 / 12)
		regions[adjacent_key] ||= list()
		regions[adjacent_key] += list(adjacent_sample)

/// SFZ amp_veltrack=100 response.
/proc/instrument_velocity_gain(velocity)
	return (velocity / 127) ** 2

/proc/get_instrument_piano_sample(soundin, velocity = 127, resonant = FALSE, release_sample = FALSE)
	var/list/regions = global.instrument_piano_regions?[soundin]
	if (!islist(regions))
		return null
	for (var/list/region as anything in regions)
		if (region["release_sample"] != release_sample)
			continue
		if (!release_sample && region["resonant"] != resonant)
			continue
		if (velocity < region["velocity_min"] || velocity > region["velocity_max"])
			continue
		var/list/selected = region.Copy()
		selected["gain"] *= instrument_velocity_gain(velocity)
		return selected
	return null

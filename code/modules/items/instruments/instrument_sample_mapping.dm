/proc/add_instrument_sample_section(list/samples, family, list/rows, velocity_min = 1, velocity_max = 127, \
	resonant = null, release_sample = FALSE, release = 0.4, volume_scale = 1)
	for (var/notes in rows)
		var/list/row = rows[notes]
		var/list/note_names = splittext(notes, " ")
		for (var/index in 1 to length(note_names))
			var/key = "sound/musical_instruments/[family]/notes/[note_names[index]].ogg"
			var/list/sample = list("file" = row[1], "duration" = row[2], "gain" = 1, \
				"pitch" = 2 ** ((row[3] + index - 1) / 12), "volume_scale" = volume_scale, \
				"velocity_min" = velocity_min, "velocity_max" = velocity_max, "resonant" = resonant, \
				"release_sample" = release_sample, "release" = release)
			samples[key] ||= list()
			samples[key] += list(sample)

/// SFZ amp_veltrack=100 response.
/proc/instrument_velocity_gain(velocity)
	return (velocity / 127) ** 2

/proc/get_instrument_sample(soundin, velocity = 127, resonant = FALSE, release_sample = FALSE)
	var/list/regions = global.instrument_sustain_samples?[soundin]
	for (var/list/region as anything in regions)
		if (region["release_sample"] != release_sample)
			continue
		if (!release_sample && !isnull(region["resonant"]) && region["resonant"] != resonant)
			continue
		if (velocity < region["velocity_min"] || velocity > region["velocity_max"])
			continue
		var/list/selected = region.Copy()
		selected["gain"] *= instrument_velocity_gain(velocity)
		return selected
	return null

/datum/instrument_data
	var/list/notes = null
	var/note_keys_string = null
	var/list/sounds_instrument = null
	var/list/sounds_instrument_associative = null

/datum/instrument_sound_bank
	var/static/list/datum/instrument_data/bank = list()

/datum/instrument_sound_bank/New()
	. = ..()

	src.populate()

/datum/instrument_sound_bank/proc/does_instr_use_new_interface(var/obj/item/instrument/instr)
	return initial(instr.use_new_interface)

/datum/instrument_sound_bank/proc/populate()
	if (length(src.bank) != 0)
		return

	var/list/intruments = filtered_concrete_typesof(/obj/item/instrument, /datum/instrument_sound_bank/proc/does_instr_use_new_interface)
	for (var/instr_type as anything in intruments)
		if (!isnull(instr_type))
			var/obj/item/instrument/instr = new instr_type()
			var/datum/instrument_data/instr_dat = new()
			instr_dat.notes = instr.generate_note_range(instr.note_range[1], instr.note_range[length(instr.note_range)])
			instr_dat.note_keys_string = instr.generate_keybinds(instr_dat.notes)
			if(!instr_dat.note_keys_string)
				instr_dat.note_keys_string = instr.default_keys_string
			instr_dat.sounds_instrument = list()
			instr_dat.sounds_instrument_associative = list()
			for (var/i in 1 to length(instr_dat.notes))
				var/note = instr_dat.notes[i]
				var/note_path = (instr.instrument_sound_directory + "[note].ogg")
				instr_dat.sounds_instrument += note_path
				instr_dat.sounds_instrument_associative[note] = note_path
			src.bank[instr.name] = instr_dat

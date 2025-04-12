// TODO: Rework this so it inherits from /obj/item/instrument instead of the other way around
// It's less horrible copy paste of code that way
/obj/item/artifact/instrument
	name = "artifact instrument"
	associated_datum = /datum/artifact/instrument
	var/list/sounds_instrument = list()
	var/spam_flag = 0
	var/spam_timer = 250
	var/volume = 50
	var/randomized_pitch = 1
	var/desc_verb = list("plays", "makes", "causes")
	var/desc_sound = list("strange", "odd", "bizarre", "weird", "offputting", "unusual")
	var/desc_music = list("song", "ditty", "sound", "noise")

	New(var/loc, var/forceartiorigin)
		..()
		SPAWN(1 SECOND)
			var/datum/artifact/A = src.artifact
			if(A?.artitype)
				sounds_instrument = A.artitype.instrument_sounds

	// okay, i wanted to inherit from artifact, alright, not instrument
	// christ, if we only had components
	proc/play(mob/user as mob)
		if (!spam_flag)
			src.ArtifactFaultUsed(user)
			spam_flag = 1
			src.add_fingerprint(user)
			show_play_message(user)
			playsound(src, islist(src.sounds_instrument) ? pick(src.sounds_instrument) : src.sounds_instrument, src.volume, src.randomized_pitch)
			SPAWN(src.spam_timer)
				spam_flag = 0
		return

	proc/show_play_message(mob/user as mob)
		if (user) return user.visible_message("<B>[user]</B> [islist(src.desc_verb) ? pick(src.desc_verb) : src.desc_verb] \a [islist(src.desc_sound) ? pick(src.desc_sound) : src.desc_sound] [islist(src.desc_music) ? pick(src.desc_music) : src.desc_music] on [his_or_her(user)] [src.name]!")

	attack_self(mob/user as mob)
		..()
		src.play(user)

/datum/artifact/instrument
	associated_object = /obj/item/artifact/instrument
	type_name = "Instrument"
	type_size = ARTIFACT_SIZE_MEDIUM
	automatic_activation = 1
	rarity_weight = 450
	validtypes = list("wizard","eldritch","precursor","martian","ancient")
	react_xray = list(10,65,95,9,"TUBULAR")
	combine_flags = ARTIFACT_ACCEPTS_ANY_COMBINE

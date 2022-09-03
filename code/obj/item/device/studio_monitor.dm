/obj/item/device/radio/nukie_studio_monitor
	name = "Studio Monitor"
	desc = "An incredibly high quality studio monitor with an uncomfortable number of high voltage stickers. Manufactured by Funk-Tek"
	icon = 'icons/obj/loudspeakers.dmi'
	icon_state = "amp_stack"
	wear_image_icon = 'icons/mob/clothing/back.dmi'

	anchored = 0
	speaker_range = 7
	mats = 0
	broadcasting = 0
	listening = 0
	chat_class = RADIOCL_INTERCOM
	frequency = R_FREQ_LOUDSPEAKERS
	locked_frequency = TRUE
	rand_pos = 0
	flags = FPRINT | TABLEPASS | CONDUCT | ONBACK
	w_class = W_CLASS_NORMAL
	var/obj/effects/music/effect

	New()
		..()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		pixel_y = 0
		effect = new
		src.vis_contents += effect
		set_secure_frequency("l", R_FREQ_LOUDSPEAKERS)
		headset_channel_lookup["[R_FREQ_LOUDSPEAKERS]"] = "Loudspeakers"

	send_hear()
		flick("amp_stack_actv", src)

		last_transmission = world.time
		var/list/hear = hearers(src.speaker_range, get_turf(src))

		if(ismob(loc))
			hear |= loc

		if(istype(loc, /obj)) //modified so people in the same object as it can hear it
			for(var/mob/M in loc)
				hear |= M

		return hear

	speech_bubble()
		UpdateOverlays(speech_bubble, "speech_bubble")
		SPAWN(1.5 SECONDS)
			UpdateOverlays(null, "speech_bubble")

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

	proc/play_song(notes=TRUE)
		icon_state = "amp_stack_actv"
		if(notes)
			effect.play_notes()
		if(ismob(src.loc))
			var/mob/M = src.loc
			M.update_clothing()

	proc/stop_song()
		icon_state = "amp_stack"
		effect.stop_notes()
		if(ismob(src.loc))
			var/mob/M = src.loc
			M.update_clothing()


/obj/item/breaching_hammer/rock_sledge
	name = "Orpheus electric guitar"
	desc = "A bolt-on neck flying V electric guitar, finished in blood red. Manufactured by Funk-Tek."
	icon = 'icons/obj/large/64x32.dmi'
	icon_state = "guitar"
	item_state = "guitar"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	is_syndicate = 1
	click_delay = 30 / 2 // TODO

	force = 30 //this number is multiplied by 4 when attacking doors.
	stamina_damage = 60
	stamina_cost = 30
	abilities = list(/obj/ability_button/nukie_rocker/shred,
	/obj/ability_button/nukie_rocker/infrasound,
	/obj/ability_button/nukie_rocker/ultrasound,
	/obj/ability_button/nukie_rocker/focus,
	/obj/ability_button/nukie_rocker/heal,
	/obj/ability_button/nukie_rocker/death_march,
	/obj/ability_button/nukie_rocker/perseverance,
	/obj/ability_button/nukie_rocker/epic_climax)
	var/speakers = list()
	var/strums = 0
	var/obj/effects/music/effect
	var/overheated = FALSE

	New()
		..()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		effect = new
		speakers |= new /obj/item/device/radio/nukie_studio_monitor(src.loc)
		speakers |= new /obj/item/device/radio/nukie_studio_monitor(src.loc)

	dropped(mob/user)
		stop_notes()
		user.vis_contents -= effect
		. = ..()

	pickup(mob/user)
		. = ..()
		user.vis_contents |= effect

	attack_self(mob/user)
		play_notes()

	afterattack(atom/target, mob/user, reach, params)
		. = ..()
		if(ismob(target) || iscritter(target))
			if(actions.hasAction(user,"rocking_out"))
				play_notes()
			else
				playsound(src, pick('sound/musical_instruments/Guitar_bonk1.ogg', 'sound/musical_instruments/Guitar_bonk2.ogg', 'sound/musical_instruments/Guitar_bonk3.ogg'), 50, 1, -1)

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

	proc/play_notes()
		if(!actions.hasAction(usr,"rocking_out"))
			if(effect.is_playing()) return
			effect.play_notes()
			for(var/obj/item/device/radio/nukie_studio_monitor/S in speakers)
				S.play_song()
			SPAWN(2 SECONDS)
				stop_notes()
		else
			strums = ( strums + 1 % 2000 )
			effect.play_notes()
			if(!overheated)
				for(var/obj/item/device/radio/nukie_studio_monitor/S in speakers)
					S.play_song()

	proc/stop_notes()
		for(var/obj/item/device/radio/nukie_studio_monitor/S in speakers)
			S.stop_song()
		effect.stop_notes()

	proc/get_speaker_targets(range_mod=0)
		var/list/mob/targets = list()
		for(var/obj/item/device/radio/nukie_studio_monitor/S in speakers)
			for(var/mob/HH in hearers(S.speaker_range + range_mod, get_turf(S)))
				targets |= HH

		return targets

	proc/overheat(activate)
		if(activate)
			for(var/obj/ability_button/nukie_rocker/B as anything in ability_buttons)
				B.UpdateOverlays(B.rocked_out_img, "rocked_out")
			src.overheated = TIME + 30 SECONDS
		else
			src.overheated = 0
			for(var/obj/ability_button/nukie_rocker/B as anything in ability_buttons)
				B.UpdateOverlays(null, "rocked_out")

/obj/item/breaching_hammer/rock_sledge/nanotrasen
	name = "Marsyas electric guitar"
	desc = "A high-tech Syndicate guitar, reverse engineered by Nanotrasen and given a blue paint job."
	icon_state = "guitar_nt"
	item_state = "guitar_nt"
	is_syndicate = FALSE

/obj/ability_button/nukie_rocker
	name = "Nukie Rocker Ability - You shouldn't see this..."
	desc = "Waht you no see! This never happened"
	icon_state = "nostun"
	targeted = 0
	cooldown = 30 SECONDS
	var/song_duration = 3 MINUTES + 11 SECONDS // And if I ever didn't thank you you.. then just let me do it now
	var/list/status_effect_ids
	var/static/image/frame_img
	var/static/image/rocked_out_img
	var/sound_clip

	New()
		..()
		if(!frame_img)
			frame_img = image('icons/misc/abilities.dmi',"rock_frame")
			frame_img.appearance_flags = RESET_COLOR
			rocked_out_img = image('icons/misc/abilities.dmi',"rocked_out")
			rocked_out_img.appearance_flags = RESET_COLOR
		src.UpdateOverlays(frame_img, "frame")

	execute_ability()
		if(status_effect_ids)
			actions.start(new/datum/action/bar/private/icon/rock_on(the_item, src), src.the_mob)

		src.color = COLOR_MATRIX_GRAYSCALE
		. = ..()

	on_cooldown()
		. = ..()
		src.color = COLOR_MATRIX_IDENTITY

	ability_allowed()
		. = ..()
		var/obj/item/breaching_hammer/rock_sledge/I = the_item
		if(. && I.overheated)
			boutput(src.the_mob, "<span class='alert'>The speakers have overheated.  You must wait for them to cooldown!</span>")
			. = FALSE

		if(. && actions.hasAction(usr,"rocking_out"))
			boutput(src.the_mob, "<span class='alert'>You are already playing something...</span>")
			. = FALSE

	proc/is_rock_immune(mob/living/target)
		if(isvirtual(target))
			var/mob/living/carbon/human/virtual/V = target
			. = istype(V.ears, /obj/item/device/radio/headset/syndicate) || istype(V.head, /obj/item/clothing/head/helmet/space/syndicate)
		else
			if(the_item.is_syndicate)
				. = istype(target.ears, /obj/item/device/radio/headset/syndicate)
			else
				. = istype(target.ears, /obj/item/device/radio/headset/command) //Nanotrasen guitar, Nanotrasen tunes

	shred
		name = "Shred"
		desc = "Sound so shrill it shatters lights."
		icon_state = "shred"
		cooldown = 2 MINUTES

		execute_ability()
			var/obj/item/breaching_hammer/rock_sledge/I = the_item

			for(var/obj/item/device/radio/nukie_studio_monitor/S in I.speakers)
				playsound(src, 'sound/musical_instruments/bard/tapping1.ogg', 60, 1, 5)
				for (var/obj/machinery/light/L in view(7, get_turf(S)))
					if (L.status == 2 || L.status == 1)
						continue
					L.broken(1)

			for(var/mob/living/HH in I.get_speaker_targets())
				if(is_rock_immune(HH))
					continue

				HH.apply_sonic_stun(0, 0, 30, 0, 5, 4, 6)

			. = ..()

	infrasound
		name = "Infrasound"
		desc = "Play something so deep it hurts.  Causes headaches for those nearby and nausea to those that can hear it."
		icon_state = "infrasound"
		cooldown = 45 SECONDS

		execute_ability()
			var/obj/item/breaching_hammer/rock_sledge/I = the_item

			for(var/mob/living/HH in I.get_speaker_targets(2))
				if(is_rock_immune(HH))
					continue

				HH.take_brain_damage(15)

				if (HH.ears_protected_from_sound(0) || !HH.hearing_check())
					continue

				HH.setStatus("infrasound_nausea", 10 SECONDS)
			playsound(src, 'sound/musical_instruments/bard/riff.ogg', 60, 1, 5)
			. = ..()

	ultrasound
		name = "Ultrasound"
		desc = "Play something so high it hurts. Penetrate organs and stuns!"
		icon_state = "ultrasound"
		cooldown = 45 SECONDS

		execute_ability()
			var/obj/item/breaching_hammer/rock_sledge/I = the_item
			for(var/mob/living/HH in I.get_speaker_targets(-2))
				if(is_rock_immune(HH))
					continue
				HH.apply_sonic_stun(0, 0, 0, 0, 2, 8, 5)
				HH.organHolder?.damage_organs(brute=10, organs=list("liver", "heart", "left_kidney", "right_kidney", "stomach", "intestines","appendix", "pancreas", "tail"), probability=90)
			playsound(src, 'sound/musical_instruments/bard/tapping2.ogg', 60, 1, 5)
			. = ..()

	focus
		name = "Focus"
		desc = "Clear Stuns and improves resistance"
		icon_state = "focus"
		status_effect_ids = list("music_focus")
		sound_clip = 'sound/musical_instruments/bard/tapping1.ogg'

		execute_ability()
			var/obj/item/breaching_hammer/rock_sledge/I = the_item
			for(var/mob/living/HH in I.get_speaker_targets())
				if(is_rock_immune(HH))
					HH.delStatus("stunned")
					HH.delStatus("weakened")
					HH.delStatus("paralysis")
					HH.delStatus("slowed")
					HH.delStatus("disorient")
					HH.change_misstep_chance(-INFINITY)
					HH.stuttering = 0
					HH.delStatus("drowsy")
					if (HH.get_stamina() < 0) // Tasers etc.
						HH.set_stamina(1)

					boutput(HH, "<span class='notice'>You feel refreshed and ready to get back into the fight.</span>")

			logTheThing(LOG_COMBAT, src.the_mob, "uses cancel stuns at [log_loc(src.the_mob)].")
			..()

	// Songs

	heal
		name = "Chill Beats to Murder To"
		desc = "Gentle healing effect that improves your stamina."
		icon_state = "chill_murder"
		status_effect_ids = list("music_energized_big", "chill_murder")
		sound_clip = 'sound/musical_instruments/bard/lead2.ogg'

	death_march
		name = "Death March"
		desc = "Move Faster, Longer, and Silently"
		icon_state = "death_march"
		status_effect_ids = list("music_refreshed_big")
		sound_clip = 'sound/musical_instruments/bard/riff.ogg'

	perseverance
		name = "Perseverance"
		desc = "Boosts health and improves stamina regeneration"
		icon_state = "perseverance"
		status_effect_ids = list("music_hp_up", "music_refreshed")
		sound_clip = 'sound/musical_instruments/bard/lead1.ogg'

	epic_climax
		name = "EPIC CLIMAX"
		desc = "Play a sound that drives the team into a murder rage! Taxing physically and emotionally."
		icon_state = "epic_climax"
		status_effect_ids = list("music_hp_up_big", "epic_climax")
		song_duration = 69 SECONDS
		cooldown = 5 MINUTES
		sound_clip = 'sound/musical_instruments/bard/tapping2.ogg'

		execute_ability()
			var/obj/item/breaching_hammer/rock_sledge/I = the_item
			I.overheat(TRUE)
			. = ..()

		on_cooldown()
			. = ..()
			var/obj/item/breaching_hammer/rock_sledge/I = the_item
			I.overheat(FALSE)

/datum/action/bar/private/icon/rock_on
	duration = 5 SECONDS
	interrupt_flags = INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "rocking_out"
	fill_bar = FALSE

	var/obj/item/breaching_hammer/rock_sledge/instrument
	var/obj/ability_button/nukie_rocker/song
	var/looped
	var/last_strum

	New(Instrument, Effect)
		instrument = Instrument
		song = Effect
		looped = 0
		last_strum = instrument.strums

		icon = instrument.icon
		icon_state = instrument.icon_state
		..()


	onUpdate()
		..()
		var/mob/M = owner
		if(!istype(M) || M.equipped() != instrument || instrument == null || owner == null) //If the thing is suddenly out of range, interrupt the action. Also interrupt if the user or the item disappears.
			interrupt(INTERRUPT_ALWAYS)
			return
		if(last_strum != instrument.strums)
			icon_image.alpha = 90
			bar.color = src.color_success

	onStart()
		..()
		icon_image.pixel_y += 8
		icon_image.alpha = 200
		if(BOUNDS_DIST(owner, instrument) > 0 || instrument == null || owner == null) //If the thing is out of range, interrupt the action. Also interrupt if the user or the item disappears.
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/M = owner
		playsound(M, song.sound_clip, 60, 1, 5)
		instrument.play_notes()

	onRestart()
		..()
		var/mob/M = owner
		playsound(M, song.sound_clip, 60, 1, 5)
		last_strum = instrument.strums
		blast_to_speakers()
		icon_image.alpha = 200
		bar.color = src.color_active

	onDelete()
		..()
		if(istype(song, /obj/ability_button/nukie_rocker/epic_climax))
			SPAWN(30 SECONDS)
				instrument.overheat(FALSE)

	onEnd()
		..()
		if(looped > ((src.song.song_duration)/src.duration) )
			return // The Song... ends

		if(last_strum != instrument.strums)
			instrument.stop_notes()
			looped++
			src.onRestart()

	proc/blast_to_speakers()
		for(var/mob/living/HH in instrument.get_speaker_targets())
			// Beneficial Effects
			if(song.is_rock_immune(HH))
				for(var/E in src.song.status_effect_ids)
					HH.setStatus(E, 10 SECONDS)
			//else
				//BAD EFFECTS

///
///Music Status Effects
///

/datum/statusEffect/nausea/music
	id = "infrasound_nausea"
	name = "Nausea"
	desc = "Something doesn't feel quite right."
	icon_state = "miasma1"
	unique = 1
	duration = 10 SECONDS
	maxDuration = null

	onRemove()
		. = ..()
		var/mob/living/L = owner
		if(istype(L))
			L.do_disorient(25, disorient=8 SECONDS)

	onUpdate(var/timePassed)
		var/mob/living/L = owner
		if(!isalive(L))
			return
		if(prob(10))
			L.emote("shudder")
		else if(prob(5))
			L.visible_message("<span class='alert'>[L] pukes all over [himself_or_herself(L)].</span>", "<span class='alert'>You puke all over yourself!</span>")
			if(prob(5))
				L.do_disorient(25, disorient=1 SECOND)
			L.vomit()
			icon_state = "miasma5"

		return ..(timePassed)

/datum/statusEffect/staminaregen/music
	id = "music_refreshed"
	name = "Tunes (Refreshed)"
	desc = ""
	icon_state = "stam+"
	exclusiveGroup = "Music"
	maxDuration = 10 SECONDS
	unique = 1
	change = 2

	death_march
		name = "Tunes (Refreshed+)"
		id = "music_refreshed_big"
		desc = "Refreshed and Hastened!"
		change = 4
		movement_modifier = /datum/movement_modifier/death_march

		getTooltip()
			. = ..()
			. += " You are moving faster."

	getTooltip()
		. = "Your stamina regen is increased by [change]."

/datum/statusEffect/focus/music
	id = "music_focus"
	name = "Tunes (Focused)"
	desc = ""
	icon_state = "muscle"
	exclusiveGroup = "Music"
	maxDuration = 10 SECONDS
	unique = 1
	var/change = 20

	onAdd(optional=null)
		. = ..()
		if(ismob(owner))
			var/mob/M = owner
			APPLY_ATOM_PROPERTY(M, PROP_MOB_DISARM_RESIST, "focus_music", 10)
			APPLY_ATOM_PROPERTY(M, PROP_MOB_DISORIENT_RESIST_BODY, "focus_music", 10)

	onRemove()
		. = ..()
		if(ismob(owner))
			var/mob/M = owner
			REMOVE_ATOM_PROPERTY(M, PROP_MOB_DISARM_RESIST, "focus_music")
			REMOVE_ATOM_PROPERTY(M, PROP_MOB_DISORIENT_RESIST_BODY, "focus_music")

	getTooltip()
		. = "Your feel like you would be difficult to stop."

/datum/statusEffect/musicstaminamax
	id = "music_energized"
	name = "Tunes (Energized)"
	desc = ""
	icon_state = "stam+"
	exclusiveGroup = "Music"
	maxDuration = 10 SECONDS
	unique = 1
	var/change = 20

	big
		name = "Tunes (Energized+)"
		id = "music_energized_big"
		change = 40

	getTooltip()
		. = "Your max. stamina is increased by [change]."

	onAdd(optional=null)
		. = ..()
		if(ismob(owner))
			var/mob/M = owner
			M.add_stam_mod_max("music_bonus", change)

	onRemove()
		. = ..()
		if(ismob(owner))
			var/mob/M = owner
			M.remove_stam_mod_max("music_bonus")

/datum/statusEffect/maxhealth/music
	id = "music_hp_up"
	name = "Tunes (HP+)"
	desc = ""
	icon_state = "foodbuff"
	exclusiveGroup = "Music"
	maxDuration = 10 SECONDS
	unique = 1
	change = 20

	big
		name = "Tunes (HP++)"
		id = "music_hp_up_big"
		change = 40

	getTooltip()
		. = "Your max. health is increased by [change]."

	onAdd(optional=null)
		. = ..(change)

	onChange(optional=null)
		. = ..(change)

/datum/statusEffect/simplehot/chill_murder // totally not mild stimulants...
		id = "chill_murder"
		name = "Murder Beats"
		desc = "Mending tunes to keep on killing to!"
		exclusiveGroup = "Music"
		unique = 1
		tickSpacing = 4 SECONDS
		maxDuration = 10 SECONDS
		heal_brute = 2
		heal_burn = 2
		heal_tox = 2

/datum/statusEffect/simplehot/epic_climax // totally not mild stimulants...
	id = "epic_climax"
	name = "Euphoria"
	desc = "You feel on top of the world!"
	icon_state = "janktank"
	exclusiveGroup = "Music"
	unique = 1
	tickSpacing = 2 SECONDS
	maxDuration = 10 SECONDS
	heal_brute = 5
	heal_burn = 5
	heal_tox = 5
	var/tickspassed = 0

	onAdd(optional)
		. = ..()
		if(ismob(owner))
			var/mob/M = owner
			APPLY_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "stims", 100)
			M.add_stam_mod_max("stims", 100)
			APPLY_ATOM_PROPERTY(M, PROP_MOB_STUN_RESIST, "stims", 100)
			APPLY_ATOM_PROPERTY(M, PROP_MOB_STUN_RESIST_MAX, "stims", 100)

	onRemove()
		. = ..()
		if(ismob(owner))
			var/mob/M = owner
			M.jitteriness = 110
			REMOVE_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "stims")
			M.remove_stam_mod_max("stims")
			REMOVE_ATOM_PROPERTY(M, PROP_MOB_STUN_RESIST, "stims")
			REMOVE_ATOM_PROPERTY(M, PROP_MOB_STUN_RESIST_MAX, "stims")

	onUpdate(timePassed)
		. = ..()
		tickspassed += timePassed
		if(ismob(owner))
			var/mob/M = owner
			M.take_oxygen_deprivation(-timePassed)
			M.delStatus("slowed")
			M.delStatus("disorient")
			M.make_jittery(10)

			M.dizziness = max(0,M.dizziness-5)
			M.changeStatus("drowsy", -20 SECONDS)
			M.sleeping = 0

//
// Music Notes, Sweet Sweet Music Notes
//
particles/music
	width = 64
	height = 64
	count = 4
	spawning = 0.1
	bound1 = list(-1000, -240, -1000)
	lifespan = 2 SECONDS
	fade = 1.5 SECOND
	#ifndef SPACEMAN_DMM // Waiting on next release of DreamChecker
	fadein = 5
	#endif
	// spawn within a certain x,y,z space
	icon = 'icons/effects/particles.dmi'
	icon_state = list("quarter"=5, "beamed_eighth"=1, "eighth"=1)
	gradient = list(0, "#f00", 1, "#ff0", 2, "#0f0", 3, "#0ff", 4, "#00f", 5, "#f0f", 6, "#f00", "loop")
	color = generator("num", 0, 6)
	gravity = list(0, 0.5)
	friction = 0.4
	drift = generator("box", list(-1, -0.5, 0), list(1, 0.5, 0), LINEAR_RAND)

obj/effects/music
	plane = PLANE_NOSHADOW_ABOVE
	alpha = 200
	particles = new/particles/music

	New()
		..()
		add_filter("outline", 1, outline_filter(size=0.5, color="#444"))
		src.particles.spawning = 0

	proc/is_playing()
		. = src.particles.spawning == 0.1

	proc/play_notes()
		src.particles.spawning = 0.1

	proc/stop_notes()
		src.particles.spawning = 0


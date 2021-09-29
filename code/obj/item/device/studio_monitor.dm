/obj/item/device/radio/nukie_studio_monitor
	name = "Studio Monitor"
	desc = "An incredibly high quality studio monitor with an uncomfortable number of high voltage stickers."
	icon = 'icons/obj/loudspeakers.dmi'
	icon_state = "nukie_speaker"
	//inhand_image_icon = 'icons/mob/inhand/hand_cswords.dmi'
	wear_image_icon = 'icons/mob/back.dmi'

	anchored = 0
	speaker_range = 7
	mats = 0
	broadcasting = 1
	listening = 1
	chat_class = RADIOCL_INTERCOM
	frequency = R_FREQ_LOUDSPEAKERS
	rand_pos = 0
	density = 0
	flags = FPRINT | TABLEPASS | CONDUCT | ONBACK
	w_class = W_CLASS_NORMAL
	var/obj/effects/music/effect

	New()
		..()
		pixel_y = 0
		effect = new
		src.vis_contents += effect

	send_hear()
		var/list/hear = ..()

		flick("nukie_speaker_actv", src)
		for (var/mob/M in hear)
			playsound(src.loc, 'sound/misc/talk/speak_1.ogg', 50, 1)
		return hear

	proc/play_song(notes=TRUE)
		icon_state = "nukie_speaker_actv"
		if(notes)
			effect.play_notes()
		if(ismob(src.loc))
			var/mob/M = src.loc
			M.update_clothing()

	proc/stop_song()
		icon_state = "nukie_speaker"
		effect.stop_notes()
		if(ismob(src.loc))
			var/mob/M = src.loc
			M.update_clothing()

	attack_hand(mob/user)
		. = ..()


/obj/item/breaching_hammer/rock_sledge
	name = "rock sledgehammer"
	desc = "A HEAVY METAL hammer designed break down doors with the power of music."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "rock_sledge"
	item_state = "breaching_sledgehammer"
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

	New()
		..()
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
			if(actions.hasAction(usr,"rocking_out"))
				play_notes()
			else
				playsound(src, pick('sound/musical_instruments/Guitar_bonk1.ogg', 'sound/musical_instruments/Guitar_bonk2.ogg', 'sound/musical_instruments/Guitar_bonk3.ogg'), 50, 1, -1)

	proc/play_notes()
		if(!actions.hasAction(usr,"rocking_out"))
			effect.play_notes()
			for(var/obj/item/device/radio/nukie_studio_monitor/S in speakers)
				S.play_song()
			SPAWN_DBG(2 SECONDS)
				stop_notes()
		else
			strums = ( strums + 1 % 2000 )
			effect.play_notes()
			for(var/obj/item/device/radio/nukie_studio_monitor/S in speakers)
				S.play_song()

	proc/stop_notes()
		effect.stop_notes()
		for(var/obj/item/device/radio/nukie_studio_monitor/S in speakers)
			S.stop_song()


/obj/ability_button/nukie_rocker
	name = "Nukie Rocker Ability - You shouldn't see this..."
	desc = "Waht you no see! This never happened"
	icon_state = "nostun"
	targeted = 0
	cooldown = 10 SECONDS
	var/list/status_effect_ids

	execute_ability()
		if(status_effect_ids)
			actions.start(new/datum/action/bar/private/icon/rock_on(the_item, status_effect_ids), src.the_mob)
		. = ..()

	shred
		name = "Shred"
		desc = "Lightbreaker Effect"
		icon_state = "shred"

		execute_ability()
			var/obj/item/breaching_hammer/rock_sledge/I = the_item

			for(var/obj/item/device/radio/nukie_studio_monitor/S in I.speakers)
				playsound(src, "sound/effects/light_breaker.ogg", 45, 1, 5)
				for (var/obj/machinery/light/L in view(7, get_turf(S)))
					if (L.status == 2 || L.status == 1)
						continue
					L.broken(1)

				for (var/mob/living/HH in hearers(get_turf(S), null))
					if(istype(HH.ears, /obj/item/device/radio/headset/syndicate))
						continue

					if(!ON_COOLDOWN(HH, "shatter", 5 SECONDS))
						HH.apply_sonic_stun(0, 0, 30, 0, 5, 4, 6)
			. = ..()


	infrasound
		name = "Infrasound"
		desc = "Play something so deep it hurts."
		icon_state = "infrasound"

		execute_ability()
			var/obj/item/breaching_hammer/rock_sledge/I = the_item

			for(var/obj/item/device/radio/nukie_studio_monitor/S in I.speakers)
				for (var/mob/living/HH in hearers(S, null))
					if(istype(HH.ears, /obj/item/device/radio/headset/syndicate) || GET_DIST(HH,S) > S.speaker_range)
						continue
					HH.take_brain_damage(15)
					HH.do_disorient(25, disorient=10 SECONDS)
			. = ..()

	ultrasound
		name = "Ultrasound"
		desc = "Play something so high it hurts."
		icon_state = "ultrasound"

		execute_ability()
			var/obj/item/breaching_hammer/rock_sledge/I = the_item
			for(var/obj/item/device/radio/nukie_studio_monitor/S in I.speakers)
				for (var/mob/living/HH in hearers(S, null))
					if(istype(HH.ears, /obj/item/device/radio/headset/syndicate) || GET_DIST(HH,S) > S.speaker_range)
						continue
					HH.apply_sonic_stun(0, 0, 0, 0, 2, 8, 5)
					HH.organHolder.damage_organs(brute=10, organs=list("liver", "heart", "left_kidney", "right_kidney", "stomach", "intestines","appendix", "pancreas", "tail"), probability=90)
			. = ..()

	focus
		name = "Focus"
		desc = "Clear Stuns"
		icon_state = "focus"


		execute_ability()
			var/obj/item/breaching_hammer/rock_sledge/I = the_item
			for(var/obj/item/device/radio/nukie_studio_monitor/S in I.speakers)
				for (var/mob/living/HH in hearers(S, null))
					if(istype(HH.ears, /obj/item/device/radio/headset/syndicate) || GET_DIST(HH,S) > S.speaker_range)
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

						boutput(HH, __blue("You feel refreshed and ready to get back into the fight."))

			logTheThing("combat", src.the_mob, null, "uses cancel stuns at [log_loc(src.the_mob)].")
			..()

	heal
		name = "Chill Beats to Murder To"
		desc = "Gentle healing effect that allows you to do more."
		icon_state = "chill_murder"
		status_effect_ids = list("music_energized_big")

	perseverance
		name = "Perseverance"
		desc = "Health Boost and Minor Stamina Regeneration"
		icon_state = "perseverance"
		status_effect_ids = list("music_hp_up", "music_refreshed")

	death_march
		name = "Death March"
		desc = "Move Faster, Longer, and Silently"
		icon_state = "death_march"
		status_effect_ids = list("music_refreshed_big")

	epic_climax
		name = "EPIC CLIMAX"
		desc = "Play a sound that drives the time into a murder rage! Taxing physically and emotionally."
		icon_state = "epic_climax"
		status_effect_ids = list("music_hp_up_big", "music_energized")

//Use this to start the action
//actions.start(new/datum/action/bar/private/icon/magPicker(item, picker), usr)
/datum/action/bar/private/icon/rock_on
	duration = 5 SECONDS
	interrupt_flags = INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "rocking_out"
	fill_bar = FALSE

	var/obj/item/breaching_hammer/rock_sledge/instrument
	var/list/status_effects = null
	var/looped
	var/last_strum

	New(Instrument, Effects)
		instrument = Instrument
		status_effects = Effects
		looped = 0
		last_strum = instrument.strums

		icon = instrument.icon
		icon_state = instrument.icon_state
		..()


	onUpdate() //check for special conditions that could interrupt the picking-up here.
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
		if(get_dist(owner, instrument) > 1 || instrument == null || owner == null) //If the thing is out of range, interrupt the action. Also interrupt if the user or the item disappears.
			interrupt(INTERRUPT_ALWAYS)
			return
		instrument.play_notes()

	onRestart()
		..()
		last_strum = instrument.strums
		blast_to_speakers()
		icon_image.alpha = 200
		bar.color = src.color_active

	onInterrupt(var/flag) //They did something else while picking it up. I guess you dont have to do anything here unless you want to.
		..()

	onEnd()
		..()

		if(looped > (((3 MINUTES + 11 SECONDS)/src.duration)-5)  && prob(1/5) )
			return // The Song... ends

		if(last_strum != instrument.strums)
			instrument.stop_notes()
			looped++
			src.onRestart()

	proc/blast_to_speakers()
		for(var/obj/item/device/radio/nukie_studio_monitor/S in instrument.speakers)
			for(var/mob/M in range(S.speaker_range,S))
				// Beneficial Effects
				if(istype(M.ears, /obj/item/device/radio/headset/syndicate))
					for(var/E in status_effects)
						M.setStatus(E, 10 SECONDS)
				//else
					//BAD EFFECTS

///
///Music Status Effects
///

/datum/statusEffect/staminaregen/music
	id = "music_refreshed"
	name = "Tunes (Refreshed)"
	desc = ""
	icon_state = "stam+"
	exclusiveGroup = "Music"
	maxDuration = 10 SECONDS
	unique = 1
	change = 2

	big
		name = "Tunes (Refreshed+)"
		id = "music_refreshed_big"
		change = 4

	getTooltip()
		. = "Your stamina regen is increased by [change]."

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
		if(hascall(owner, "add_stam_mod_max"))
			owner:add_stam_mod_max("music_bonus", change)

	onRemove()
		. = ..()
		if(hascall(owner, "remove_stam_mod_max"))
			owner:remove_stam_mod_max("music_bonus")

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


particles/music
	width = 64
	height = 64
	count = 4
	spawning = 0.1
	bound1 = list(-1000, -240, -1000)   // end particles at Y=-240
	lifespan = 2 SECONDS  // live for 60s max
	fade = 1.5 SECOND      // fade out over the last 3.5s if still on screen
	fadein = 5
	// spawn within a certain x,y,z space
	icon = 'icons/effects/particles.dmi'
	icon_state = list("quarter"=5, "beamed_eighth"=1, "eighth"=1)
	gradient = list(0, "#f00", 1, "#ff0", 2, "#0f0", 3, "#0ff", 4, "#00f", 5, "#f0f", 6, "#f00", "loop")
	color = generator("num", 0, 6)
	gravity = list(0, 0.5)
	friction = 0.4
	drift = generator("box", list(-1, -0.5, 0), list(1, 0.5, 0), LINEAR_RAND)

obj/effects/music
	particles
	plane = PLANE_NOSHADOW_ABOVE
	alpha = 200
	mouse_opacity = 1

	var/particles/music/music_notes = new

	New()
		..()
		src.filters += filter(type="outline", size=0.5, color="#444")

	proc/play_notes()
		src.particles = music_notes

	proc/stop_notes()
		src.particles = null


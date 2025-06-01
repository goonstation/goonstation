TYPEINFO(/mob/living/critter/small_animal/plush/cryptid)
	start_speech_modifiers = list(SPEECH_MODIFIER_MOB_MODIFIERS, SPEECH_MODIFIER_CRYPTID_PLUSHIE)

/mob/living/critter/small_animal/plush/cryptid
	hand_count = 0
	pull_w_class = W_CLASS_TINY
	ghost_spawned = 1
	health_brute = 40
	health_burn = 40
	can_use_say = FALSE

	use_stunned_icon = FALSE
	var/being_seen = FALSE
	var/mob/last_witness
	var/icon_states_with_supported_eyes = list("bee", "buddy", "kitten", "monkey", "possum", "brullbar", "bunny", "penguin")
	var/image/eye_light
	var/glowing_eye_color = "#c40000ff"
	var/glowing_eyes_enabled_alpha = 190
	var/glowing_eyes_active = 0
	var/override_steps  // can move this many steps whether being seen or not, granted for a short time after movement_override ability

	bee
		icon_state = "bee"
		pick_random_icon_state = 0
	buddy
		icon_state = "buddy"
		pick_random_icon_state = 0
	kitten
		icon_state = "kitten"
		pick_random_icon_state = 0
	monkey
		icon_state = "monkey"
		pick_random_icon_state = 0
	possum
		icon_state = "possum"
		pick_random_icon_state = 0
	brullbar
		icon_state = "brullbar"
		pick_random_icon_state = 0
	bunny
		icon_state = "bunny"
		pick_random_icon_state = 0
	penguin
		icon_state = "penguin"
		pick_random_icon_state = 0

	New()
		. = ..()
		if(src.icon_state in icon_states_with_supported_eyes)
			eye_light = image('icons/obj/plushies.dmi', "[src.icon_state]-eyes")
			eye_light.plane = PLANE_SELFILLUM
			set_glowing_eyes(FALSE)

		abilityHolder.addAbility(/datum/targetable/critter/cryptid_plushie/plushie_talk)
		abilityHolder.addAbility(/datum/targetable/critter/cryptid_plushie/movement_override)
		abilityHolder.addAbility(/datum/targetable/critter/cryptid_plushie/teleportation/blink)
		abilityHolder.addAbility(/datum/targetable/critter/cryptid_plushie/teleportation/disappear)
		abilityHolder.addAbility(/datum/targetable/critter/cryptid_plushie/teleportation/vengeful_retreat)
		abilityHolder.addAbility(/datum/targetable/critter/cryptid_plushie/glowing_eyes/toggle_glowing_eyes)
		abilityHolder.addAbility(/datum/targetable/critter/cryptid_plushie/glowing_eyes/set_glowing_eyes_color)
		abilityHolder.updateButtons()

		bioHolder.AddEffect("resist_alcohol")

	death(gibbed)
		. = ..()
		// do stuff with old dead body
		if(!gibbed)
			src.visible_message(SPAN_ALERT("[src] lets out a haunting shriek as its body begins to lose its form and fades into mist..."),
				SPAN_ALERT("Your grasp on the physical realm weakens. Your form dissolves..."))
			playsound(get_turf(src), 'sound/ambience/spooky/Hospital_Haunted3.ogg', 50, 1)
			SPAWN(0)
				animate(src, alpha=0, time=7 SECONDS)
				sleep(0.1 SECONDS)
				if(src.disposed)
					return
				animate_ripple(src, 4)
				animate_wave(src, 3)
				sleep(7 SECONDS)
				if(src.disposed)
					return
				qdel(src)
		var/ckey_of_dead_player = src.ckey
		var/mob/ghost_mob = src.ghostize()
		var/our_icon_state = src.icon_state
		// resurrection attempt
		if(!ghost_mob)
			return
		SPAWN(0)
			if (tgui_alert(ghost_mob, "You have fallen, but the curse is not lifted this easily. Do you wish to return to the physical realm?", "Resurrection",
				list("Yes", "No"), timeout = 60 SECOND) == "Yes")
				// get a random not locked station container
				var/obj/storage/spawn_target = pick(get_random_station_storage_list(no_others=TRUE))
				if(isnull(spawn_target))
					boutput(ghost_mob, SPAN_ALERT("<h3>Couldn't find a suitable location to respawn. Resurrection impossible.</h3>"))
					return
				if(spawn_target.open) // close the container if it's opened
					spawn_target.close()
				var/path_to_obj_plushie = get_plush_for_icon_state(our_icon_state)
				var/atom/new_vessel = new path_to_obj_plushie(spawn_target)
				var/time_to_respawn = 2.5 MINUTES
				boutput(ghost_mob, SPAN_ALERT("<h3>Your plushie has manifested inside [spawn_target] on the station. In [time_to_respawn/10] seconds you will possess it once more as long as the vessel is not destroyed before then.</h3>"))
				ghost_mob.set_loc(get_turf(spawn_target))
				playsound(get_turf(spawn_target), 'sound/ambience/spooky/Void_Calls.ogg', 100, 1)
				sleep(time_to_respawn)
				if(!ghost_mob || !ghost_mob.client) // somewhere on the way we lost our dead player, try to find them
					ghost_mob = null
					ghost_mob = ckey_to_mob(ckey_of_dead_player, 1)
				if(!(isobserver(ghost_mob) || inafterlife(ghost_mob))) // the plushie player is no longer a ghost/in afterlife, probably revived, abort
					return

				if(!new_vessel || new_vessel.disposed)
					if(ghost_mob)
						boutput(ghost_mob, SPAN_ALERT("<h3>The vessel has been destroyed. Your return to the physical realm has been prevented.</h3>"))
				else // respawn the cryptid mob and reassign the ckey
					if(ghost_mob)
						boutput(ghost_mob, SPAN_ALERT("<h3>You awaken once more. The cycle continues.</h3>"))
					var/location_of_plushie = new_vessel.loc
					if(!isturf(location_of_plushie) && !istype(location_of_plushie, /obj/storage)) // if the location isn't a turf or storage, get turf
						location_of_plushie = get_turf(new_vessel)
					qdel(new_vessel)
					var/cryptid_mob_path = get_cryptid_mob_for_icon_state(our_icon_state)
					var/mob/living/critter/small_animal/plush/cryptid/reborn_cryptid = new cryptid_mob_path(location_of_plushie)
					reborn_cryptid.ckey = ckey_of_dead_player
					SPAWN(0.5 SECONDS)
						if(reborn_cryptid && !reborn_cryptid.disposed)
							playsound(get_turf(reborn_cryptid), 'sound/misc/jester_laugh.ogg', 60, 1)
			else
				boutput(ghost_mob, SPAN_ALERT("<h3>The cycle has been stopped.</h3>"))

	proc/get_plush_for_icon_state(var/input_icon_state)
		var/path = "/obj/item/toy/plush/small/[input_icon_state]"
		return text2path(path)

	proc/get_cryptid_mob_for_icon_state(var/input_icon_state)
		var/path = "/mob/living/critter/small_animal/plush/cryptid/[input_icon_state]"
		return text2path(path)

	Login()
		..()
		boutput(src, {"<h1>[SPAN_ALERT("You are NOT an antagonist unless stated otherwise through an obvious popup/message.")]</h1>
			[SPAN_NOTICE("You can't move when being watched. As a plush, you have the following abilities:")]
			<br>[SPAN_NOTICE("Plushie Talk allows you to communicate.")]
			<br>[SPAN_NOTICE("Override Sensors lets you temporarily move a few steps, even if being watched.")]
			<br>[SPAN_NOTICE("Teleport lets you jump to the targeted location, when you're not being watched.")]
			<br>[SPAN_NOTICE("Disappear teleports you to a random station container.")]
			<br>[SPAN_NOTICE("Vengeful Retreat will stun your recent attacker and teleport you away.")]
			<br>[SPAN_NOTICE("Toggle Glowing Eyes will toggle your eyes glowing at will.")]
			<br>[SPAN_NOTICE("Set Glowing Eyes Color lets you set your eyes' glowing color.")]
			<br>[SPAN_NOTICE("Access special emotes through *scream, *dance and *snap.")]"})

	proc/set_glowing_eyes(var/enabled)
		if (eye_light)
			if(enabled)
				eye_light.color = glowing_eye_color
				eye_light.alpha = glowing_eyes_enabled_alpha
				boutput(src, SPAN_NOTICE("Glowing eyes enabled."))
			else
				eye_light.alpha = 0
				boutput(src, SPAN_NOTICE("Glowing eyes disabled."))
			glowing_eyes_active = enabled
			src.UpdateOverlays(eye_light, "eye_light")

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 300))
					playsound(src, 'sound/misc/lincolnshire.ogg', 65, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> plays a song!")
			if ("fart")
				return
			if ("dance")
				if (src.emote_check(voluntary, 100))
					animate_bouncy(src)
					return SPAN_EMOTE("<b>[src]</b> dances!")
			if ("snap")
				if (src.emote_check(voluntary, 100))
					if (prob(33))
						playsound(src.loc, 'sound/misc/automaton_ratchet.ogg', 60, 1)
						return  "<B>[src]</B> emits [pick("a soft", "a quiet", "a curious", "an odd", "an ominous", "a strange", "a forboding", "a peculiar", "a faint")] [pick("ticking", "tocking", "humming", "droning", "clicking")] sound."
					else if (prob(33))
						playsound(src.loc, 'sound/misc/automaton_ratchet.ogg', 60, 1)
						return "<B>[src]</B> emits [pick("a peculiar", "a worried", "a suspicious", "a reassuring", "a gentle", "a perturbed", "a calm", "an annoyed", "an unusual")] [pick("ratcheting", "rattling", "clacking", "whirring")] noise."
					else
						playsound(src.loc, 'sound/misc/automaton_scratch.ogg', 50, 1)
		return ..()

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		being_seen_status_update()
		SPAWN(2 SECONDS)  // gross bandaid to work around the life loop being a tad too slow
			being_seen_status_update()

		if (src.reagents.has_reagent("ethanol"))
			if (src.reagents.get_reagent_amount("ethanol") >= 15 && prob(25))
				playsound(get_turf(src), 'sound/voice/burp.ogg', 15, TRUE, channel=VOLUME_CHANNEL_EMOTE, pitch=1.8)
				src.visible_message(SPAN_ALERT("<B>[src] burps?</B>"))
				hit_twitch(src)
				src.reagents.del_reagent("ethanol")

	proc/set_dormant_status(var/enabled)
		if(enabled)
			if(!src.hasStatus("dormant"))
				src.setStatus("dormant", INFINITE_STATUS)
		else
			src.delStatus("dormant")


	proc/being_seen_status_update()
		if(istype(src.loc, /obj/storage)) // inside a container
			being_seen = FALSE
			set_dormant_status(FALSE)
			return
		if (last_witness && last_witness.client) // optimization attempt
			if(GET_DIST(src, last_witness) < 3) // still next to last person that saw us, might be for instance pulling us or sitting next to us
				return
		last_witness = null

		for (var/mob/M in viewers(src))
			if (M == src)
				continue
			if (!isalive(M) || isintangible(M))
				continue
			if (istype(M, /mob/living/critter/small_animal/plush/cryptid)) // other cryptids are ok
				continue
			if (M.client) // Only players
				last_witness = M
				being_seen = TRUE
				set_dormant_status(TRUE)
				return
		being_seen = FALSE
		set_dormant_status(FALSE)

	update_canmove()
		if(override_steps > 0)
			src.canmove = TRUE
			override_steps -= 1
			return
		src.canmove = !being_seen

	setup_hands() // no hands
		return

ABSTRACT_TYPE(/datum/targetable/critter/cryptid_plushie)
/datum/targetable/critter/cryptid_plushie
	var/mob/living/critter/small_animal/plush/cryptid/our_plushie
	icon = 'icons/mob/spell_buttons.dmi'
	var/qdel_itself_if_not_attached_to_plushie = 0

	onAttach(datum/abilityHolder/H)
		. = ..()
		if(istype(src.holder.owner, /mob/living/critter/small_animal/plush/cryptid))
			our_plushie = src.holder.owner
		if(qdel_itself_if_not_attached_to_plushie)
			if(!our_plushie)
				qdel(src)

/datum/targetable/critter/cryptid_plushie/plushie_talk // mostly stolen from ouija board
	name = "Plushie Talk"
	desc = "Communicate."
	icon_state = "corruption"
	cooldown = 50
	qdel_itself_if_not_attached_to_plushie = 1
	var/words_min = 7
	var/words_max = 10

	cast(atom/target)
		if (..())
			return 1

		var/selected
		do
			var/list/words = list("*REFRESH*") + get_ouija_word_list(src, words_min, words_max,
				filename="plush_toy_words.txt", strings_category="plush_toy_words")
			selected = tgui_input_list(usr, "Select a word:", src.name, words, allowIllegal=FALSE)
		while(selected == "*REFRESH*")
		if(!selected)
			return
		if(!holder || !holder.owner)
			return
		playsound(holder.owner, 'sound/misc/automaton_scratch.ogg', 50, 1)
		selected = uppertext(selected)
		our_plushie.say(selected)
		return 0

/datum/targetable/critter/cryptid_plushie/movement_override
	name = "Override Sensors"
	desc = "Be able to move a few steps in spite of whether you're being looked at."
	icon = 'icons/mob/genetics_powers.dmi'
	icon_state = "adrenaline"
	cooldown = 400
	targeted = 0
	qdel_itself_if_not_attached_to_plushie = 1
	var/list/minor_event_sounds = list('sound/machines/giantdrone_boop1.ogg', 'sound/machines/giantdrone_boop3.ogg', 'sound/machines/giantdrone_boop4.ogg')
	var/list/moderate_event_sounds = list('sound/machines/giantdrone_boop2.ogg')
	var/list/major_event_sounds = list('sound/misc/android_scream.ogg')
	var/cycle

	cast(atom/target)
		if (..())
			return 1

		/* debugging
		cycle++
		cycle = cycle % 3
		if(cycle == 0)
			minor_event()
		else if(cycle == 1)
			moderate_event()
		else if(cycle == 2)
			major_event()
		*/

		var/roll = rand(1, 100)
		if(roll <= 55)
			minor_event()
		else if(roll <= 89)
			moderate_event()
		else if(roll >= 90)
			major_event()

		SPAWN(4 SECONDS)
			our_plushie.override_steps = 0

		return 0

	proc/minor_event()
		playsound(get_turf(holder.owner), "[pick(minor_event_sounds)]", 45, 1)
		our_plushie.override_steps = rand(6, 10)
		glitch_out(0.8 SECONDS, 1, 0.7)

	proc/moderate_event()
		playsound(get_turf(holder.owner), "[pick(moderate_event_sounds)]", 45, 1)
		our_plushie.override_steps = rand(8, 13)
		glitch_out(1.4 SECONDS, 1, 0.9)

	proc/major_event()
		playsound(get_turf(holder.owner), "[pick(major_event_sounds)]", 45, 1)
		our_plushie.override_steps = rand(20, 50)
		glitch_out(3 SECONDS, 1, 1.2, say_gibberish = 1)

	proc/glitch_out(var/length, var/iteration_length_scaling, var/effect_scaling, var/say_gibberish = 0)
		var/iteration_length = 0.2 SECONDS * iteration_length_scaling
		var/iterations = round(length / iteration_length)
		var/original_transform = our_plushie.transform

		var/x_lower = -0.1 * effect_scaling
		var/x_upper = 0.1 * effect_scaling
		var/y_lower = -0.1 * effect_scaling
		var/y_upper = 0.1 * effect_scaling

		var/penalty_multiplier = 1.8 / iterations

		var/scratch_chance = 40
		var/gibberish_words_chance = 30
		for(var/i = 0 to iterations)
			if(!our_plushie || our_plushie.disposed || src.disposed)
				return
			if(prob(scratch_chance))
				playsound(get_turf(holder.owner), 'sound/misc/automaton_scratch.ogg', 20, 1)
				scratch_chance -= 10
			else
				scratch_chance += 10
			if(say_gibberish)
				if(prob(gibberish_words_chance))
					plushie_says_gibberish_word()
					gibberish_words_chance -= 10
				else
					gibberish_words_chance += 10

			var/scale_penalty = 1 - (penalty_multiplier * abs((iterations/2) - i))  // animation is less intense on the edges (start, end)
			violent_standup_twitch_parametrized(our_plushie, effect_scale = effect_scaling * scale_penalty)
			var/x_scale = 1 + ((rand(x_lower * 100, x_upper * 100) / 100) * scale_penalty)
			var/y_scale = 1 + ((rand(y_lower * 100, y_upper * 100) / 100) * scale_penalty)
			our_plushie.Scale(x_scale, y_scale)
			sleep(iteration_length)

		if(say_gibberish && prob(75))
			var/list/last_words = list("FAILED TO RESOLVE ERROR, REBOOTING", "INITIATING REBOOT", "AVAILABLE IN STORES NOW", "AVAILABLE IN SEVERAL MODELS", "HELP")
			our_plushie.say(pick(last_words))
		our_plushie.transform = original_transform

	proc/plushie_says_gibberish_word()
		our_plushie.say(pick(generate_gibberish_words()))

	proc/generate_gibberish_words()
		var/list/words = list()
		for(var/i in 1 to rand(5, 10))
			var/picked = pick(strings("plush_toy_words.txt", "plush_toy_words"))
			picked = uppertext(picked)
			words |= picked
		var/list/more_words = list("... hello?", "Is anyone there?", "Please...", "Help...", "Help, please...", "Can anyone hear me?", "It hurts.", "It's so dark...")
		words += pick(more_words)
		return words

ABSTRACT_TYPE(/datum/targetable/critter/cryptid_plushie/teleportation)
/datum/targetable/critter/cryptid_plushie/teleportation
	var/animation_ripples = 4
	var/animation_waves = 3

	proc/get_a_random_station_unlocked_container()
		return pick(get_random_station_storage_list(no_others=TRUE))

	proc/teleport_to_a_target(var/teleportation_target = null, var/target_a_random_container = FALSE)
		playsound(get_turf(holder.owner), 'sound/effects/ghostbreath.ogg', 75, 1)
		animate(holder.owner, alpha=0, time=1.5 SECONDS)
		sleep(0.1 SECONDS)
		if(!holder.owner || holder.owner.disposed || src.disposed)
			return
		animate_ripple(holder.owner, animation_ripples)
		animate_wave(holder.owner, animation_waves)
		sleep(1.4 SECONDS)
		if(!holder || !holder.owner || src.disposed)
			return

		if(target_a_random_container)
			teleportation_target = get_a_random_station_unlocked_container()
		if(istype(teleportation_target, /obj/storage))
			var/is_valid_storage_target = TRUE
			var/obj/storage/container = teleportation_target
			var/turf/container_turf = get_turf(container)
			for(var/obj/storage/storage_object in container_turf)
				if(storage_object == container)
					continue
				is_valid_storage_target = FALSE // found another storage object on the same turf as our container, teleport onto the turf instead
				teleportation_target = get_turf(teleportation_target)
			if(is_valid_storage_target)
				if(container.open)
					container.close()
		else
			teleportation_target = get_turf(teleportation_target)
		if(teleportation_target)
			holder.owner.set_loc(teleportation_target)
		else
			boutput(holder.owner, SPAN_ALERT("Couldn't find a container to teleport to!"))

		playsound(get_turf(teleportation_target), 'sound/effects/ghostlaugh.ogg', 75, 1)
		animate(holder.owner, alpha=255, time=1.5 SECONDS)
		sleep(1.5 SECONDS)
		if(!holder || !holder.owner || src.disposed)
			return
		animate(holder.owner)
		for(var/i=1, i<=animation_ripples, ++i)
			holder.owner.remove_filter("ripple-[i]")
		for(var/i=1, i<=animation_waves, ++i)
			holder.owner.remove_filter("wave-[i]")

/datum/targetable/critter/cryptid_plushie/teleportation/blink
	name = "Teleport"
	desc = "Phase yourself to a nearby visible spot when not being looked at."
	icon_state = "blink"
	cooldown = 100
	targeted = 1
	target_anything = 1
	restricted_area_check = ABILITY_AREA_CHECK_ALL_RESTRICTED_Z

	cast(atom/target)
		if (..())
			return 1
		if(our_plushie && our_plushie.being_seen)
			return 1
		if (!isturf(target))
			if(istype(target, /obj/storage))
				var/obj/storage/targetted_container = target
				if(targetted_container.locked || targetted_container.welded)
					target = get_turf(target) // the container we picked is locked or welded, we don't want to trap ourselves inside
			else
				target = get_turf(target)
		if (target == get_turf(holder.owner))
			return 1

		SPAWN(0)
			teleport_to_a_target(teleportation_target = target)
		return 0

/datum/targetable/critter/cryptid_plushie/teleportation/disappear
	name = "Disappear"
	desc = "Teleport to a random container to hide, regardless of whether you're being looked at."
	icon_state = "teleport"
	cooldown = 600
	targeted = 0
	restricted_area_check = ABILITY_AREA_CHECK_ALL_RESTRICTED_Z
	needs_turf = FALSE

	cast(atom/target)
		if (..())
			return 1

		SPAWN(0)
			teleport_to_a_target(target_a_random_container = TRUE)
		return 0

/datum/targetable/critter/cryptid_plushie/teleportation/vengeful_retreat
	name = "Vengeful Retreat"
	desc = "After being attacked, harass your attacker and disappear."
	icon_state = "blind"
	cooldown = 600

	cast(atom/target)
		if (..())
			return 1
		if (holder.owner.lastattacker?.deref() && (holder.owner.lastattackertime + 40) >= world.time)
			if(holder.owner.lastattacker.deref() != holder.owner)
				var/mob/M = holder.owner.lastattacker.deref()
				if (!istype(M))
					return
				var/mob/attacker = M
				holder.owner.visible_message(SPAN_ALERT("<B>[holder.owner]'s eyes emit a vengeful glare at [attacker]!</B>"))
				var/obj/itemspecialeffect/glare/E = new /obj/itemspecialeffect/glare
				E.color = "#ff0000"
				E.setup(holder.owner.loc)
				playsound(holder.owner.loc, 'sound/effects/screech_tone.ogg', 50, 1, pitch = 1, extrarange = -4)

				SPAWN(1 DECI SECOND)
					var/obj/itemspecialeffect/glare/EE = new /obj/itemspecialeffect/glare
					EE.color = "#ff0000"
					EE.setup(attacker.loc)
					playsound(attacker.loc, 'sound/effects/screech_tone.ogg', 50, 1, pitch = 0.8, extrarange = -4)

				attacker.apply_flash(30, 5, stamina_damage = 350)

				holder.owner.lastattacker = null

				SPAWN(0)
					teleport_to_a_target(target_a_random_container = TRUE)
				return 0
		else
			boutput(holder.owner, SPAN_ALERT("No recent attacker to retaliate against."))
			return 1

ABSTRACT_TYPE(/datum/targetable/critter/cryptid_plushie/glowing_eyes)
/datum/targetable/critter/cryptid_plushie/glowing_eyes
	onAttach(datum/abilityHolder/H)
		. = ..()
		if(!our_plushie || our_plushie.eye_light == null) // no plushie or our plushie doesn't have glowing eyes
			qdel(src)

/datum/targetable/critter/cryptid_plushie/glowing_eyes/toggle_glowing_eyes
	name = "Toggle glowing eyes"
	desc = "Toggles whether your eyes glow."
	icon_state = "bullc_cd"
	cooldown = 5
	targeted = 0
	var/active_icon_state = "bullc"
	var/inactive_icon_state = "bullc_cd"

	cast(atom/target)
		if (..())
			return 1

		our_plushie.glowing_eyes_active = !our_plushie.glowing_eyes_active
		our_plushie.set_glowing_eyes(our_plushie.glowing_eyes_active)
		icon_state = our_plushie.glowing_eyes_active ? active_icon_state : inactive_icon_state

		return 0

/datum/targetable/critter/cryptid_plushie/glowing_eyes/set_glowing_eyes_color
	name = "Toggle glowing eyes color"
	desc = "Toggles the color of your glowing eyes."
	icon_state = "stinglsd"
	cooldown = 5
	targeted = 0

	cast(atom/target)
		if (..())
			return 1

		var/picked_color = input("Pick a color for the glowing eyes.", "Color", our_plushie.glowing_eye_color) as color
		if(picked_color)
			our_plushie.glowing_eye_color = picked_color

		if(our_plushie.glowing_eyes_active) // refresh the color if eyes are active
			our_plushie.set_glowing_eyes(TRUE)

		return 0

proc/get_a_random_station_unlocked_container_with_no_others_on_the_turf()
	var/list/eligible_containers = list()
	for_by_tcl(iterated_container, /obj/storage)
		if (iterated_container.z == Z_LEVEL_STATION && !iterated_container.locked && !iterated_container.welded && !istype(get_area(iterated_container), /area/listeningpost))
			eligible_containers += iterated_container
	if (!length(eligible_containers))
		return null
	var/potential_container = null
	while(isnull(potential_container))
		potential_container = pick(eligible_containers)
		eligible_containers.Remove(potential_container)
		var/turf/turf_of_potential_container = get_turf(potential_container)
		for(var/obj/storage/storage_object in turf_of_potential_container)
			if(storage_object == potential_container)
				continue
			potential_container = null // found another storage object on the same turf as our picked potential container, look for another
			break
		if(!length(eligible_containers)) // ran out of containers to look at
			break

	return potential_container

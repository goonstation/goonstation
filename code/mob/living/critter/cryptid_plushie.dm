/mob/living/critter/small_animal/plush/cryptid
	hand_count = 0
	pull_w_class = W_CLASS_TINY
	ghost_spawned = 1
	canspeak = 0
	health_brute = 40
	health_burn = 40
	var/being_seen = FALSE
	var/atom/last_witness

	Login()
		..()
		boutput(src, "<h1><span class='alert'>You are NOT an antagonist unless stated otherwise through an obvious popup/message.</span></h1>")
		boutput(src, "<span class='notice'>You can't move when being watched.</span>")
		boutput(src, "<span class='notice'>Use your talk ability to communicate.</span>")
		boutput(src, "<span class='notice'>Your blink ability lets you teleport when you're not being watched.</span>")
		boutput(src, "<span class='notice'>Your teleport away ability lets you teleport away and hide in a random station container.</span>")
		boutput(src, "<span class='notice'>Your vengeful retreat will stun your recent attacker and teleport you away.</span>")
		boutput(src, "<span class='notice'>Access special emotes through *scream, *dance and *snap.</span>")

	New()
		. = ..()
		abilityHolder.addAbility(/datum/targetable/critter/cryptid_plushie/talk)
		abilityHolder.addAbility(/datum/targetable/critter/cryptid_plushie/blink)
		abilityHolder.addAbility(/datum/targetable/critter/cryptid_plushie/teleport_away)
		abilityHolder.addAbility(/datum/targetable/critter/cryptid_plushie/vengeful_retreat)
		abilityHolder.updateButtons()

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 300))
					playsound(src, "sound/misc/lincolnshire.ogg", 65, 1, channel=VOLUME_CHANNEL_EMOTE)
					return "<span class='emote'><b>[src]</b> plays a song!</span>"
				else
					boutput(src, "TOO EARLY TO ACT AGAIN")
			if ("fart")
				return
			if ("dance")
				if (src.emote_check(voluntary, 100))
					animate_bouncy(src)
					return "<span class='emote'><b>[src]</b> dances!</span>"
				else
					boutput(src, "TOO EARLY TO ACT AGAIN")
			if ("snap")
				if (src.emote_check(voluntary, 100))
					if (prob(33))
						playsound(src.loc, "sound/misc/automaton_ratchet.ogg", 60, 1)
						return  "<B>[src]</B> emits [pick("a soft", "a quiet", "a curious", "an odd", "an ominous", "a strange", "a forboding", "a peculiar", "a faint")] [pick("ticking", "tocking", "humming", "droning", "clicking")] sound."
					else if (prob(33))
						playsound(src.loc, "sound/misc/automaton_ratchet.ogg", 60, 1)
						return "<B>[src]</B> emits [pick("a peculiar", "a worried", "a suspicious", "a reassuring", "a gentle", "a perturbed", "a calm", "an annoyed", "an unusual")] [pick("ratcheting", "rattling", "clacking", "whirring")] noise."
					else
						playsound(src.loc, "sound/misc/automaton_scratch.ogg", 50, 1)
		return ..()

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (last_witness) // optimization attempt
			if(get_dist(src, last_witness) < 3) // still next to last person that saw us, might be for instance pulling us or sitting next to us
				return
			else
				last_witness = null

		for (var/mob/M in viewers(src))
			if (M == src)
				continue
			if (!isalive(M))
				continue
			if (M.client) // Only players
				last_witness = M
				being_seen = TRUE
				return
		being_seen = FALSE

	update_canmove()
		src.canmove = !being_seen

	setup_hands() // no hands
		return

/datum/targetable/critter/cryptid_plushie
	var/mob/living/critter/small_animal/plush/cryptid/our_plushie
	icon = 'icons/mob/spell_buttons.dmi'

	onAttach(datum/abilityHolder/H)
		. = ..()
		if(istype(src.holder.owner, /mob/living/critter/small_animal/plush/cryptid))
			our_plushie = src.holder.owner

/datum/targetable/critter/cryptid_plushie/talk // mostly stolen from ouija board
	name = "Talk"
	desc = "Communicate through sound."
	icon_state = "corruption"
	cooldown = 40
	var/words_min = 5
	var/words_max = 10

	cast(atom/target)
		if (..())
			return 1

		var/selected
		do
			var/list/words = list("*REFRESH*") + src.generate_words()
			selected = tgui_input_list(usr, "Select a word:", src.name, words, allowIllegal=FALSE)
		while(selected == "*REFRESH*")
		if(!selected)
			return
		if(!holder || !holder.owner)
			return
		playsound(holder.owner, "sound/misc/automaton_scratch.ogg", 50, 1)
		selected = uppertext(selected)
		var/mob/living/our_mob = holder.owner
		our_mob.speechpopupstyle = "font-style: italic; font-family: 'XFont 6x9'; font-size: 7px;"
		if(prob(20))
			our_mob.speechpopupstyle += " color: red !important"
		our_mob.canspeak = 1
		our_mob.say(selected)
		our_mob.canspeak = 0
		return 0

	proc/generate_words()
		var/list/words = list()
		for(var/i in 1 to rand(words_min, words_max))
			var/picked = pick(strings("ouija_board.txt", "ouija_board_words"))
			words |= picked
		return words
/datum/targetable/critter/cryptid_plushie/blink
	name = "Teleport"
	desc = "Phase yourself to a nearby visible spot when not being looked at."
	icon_state = "blink"
	cooldown = 100
	targeted = 1
	target_anything = 1
	restricted_area_check = 1

	cast(atom/target)
		if (..())
			return 1
		if(our_plushie && our_plushie.being_seen)
			return 1
		if (!isturf(target))
			if(istype(target, /obj/storage))
				var/obj/storage/targetted_container
				if(targetted_container.req_access != null)
					target = get_turf(target) // couldn't find a container that wasn't access-locked
			else
				target = get_turf(target)
		if (target == get_turf(holder.owner))
			return 1
		SPAWN_DBG(0)
			playsound(get_turf(holder.owner), "sound/effects/ghostbreath.ogg", 75, 1)
			animate(holder.owner, alpha=0, time=1.5 SECONDS)
			sleep(0.1 SECONDS)
			animate_ripple(holder.owner, 4)
			animate_wave(holder.owner, 3)
			sleep(1.4 SECONDS)
			if(!holder || !holder.owner)
				return

			if(istype(target, /obj/storage))
				var/obj/storage/targetted_container
				if(targetted_container.open)
					targetted_container.close()
			holder.owner.set_loc(target)

			playsound(get_turf(holder.owner), "sound/effects/ghostlaugh.ogg", 75, 1)
			animate(holder.owner, alpha=255, time=1.5 SECONDS)
			sleep(1.5 SECONDS)
			if(!holder || !holder.owner)
				return
			animate(holder.owner)
		return 0

/datum/targetable/critter/cryptid_plushie/teleport_away
	name = "Disappear"
	desc = "Teleport to a random container to hide, regardless of whether you're being looked at."
	icon_state = "teleport"
	cooldown = 600
	targeted = 0
	restricted_area_check = 1

	cast(atom/target)
		if (..())
			return 1

		SPAWN_DBG(0)
			var/obj/storage/container = null

			var/list/eligible_containers = list()
			for_by_tcl(iterated_container, /obj/storage)
				if (iterated_container.z == Z_LEVEL_STATION && iterated_container.req_access == null)
					eligible_containers += iterated_container
			if (!length(eligible_containers))
				return
			container = pick(eligible_containers)

			playsound(get_turf(holder.owner), "sound/effects/ghostbreath.ogg", 75, 1)
			animate(holder.owner, alpha=0, time=1.5 SECONDS)
			sleep(0.1 SECONDS)
			animate_ripple(holder.owner, 4)
			animate_wave(holder.owner, 3)
			sleep(1.4 SECONDS)
			if(!holder || !holder.owner)
				return
			if(container.open)
				container.close()
			holder.owner.set_loc(container)
			playsound(get_turf(container), "sound/effects/ghostlaugh.ogg", 75, 1)
			animate(holder.owner, alpha=255, time=1.5 SECONDS)
			sleep(1.5 SECONDS)
			if(!holder || !holder.owner)
				return
			animate(holder.owner)
		return 0

/datum/targetable/critter/cryptid_plushie/vengeful_retreat
	name = "Vengeful Retreat"
	desc = "After being attacked, harass your attacker and disappear."
	icon_state = "blind"
	cooldown = 600

	cast(atom/target)
		if (..())
			return 1
		if (holder.owner.lastattacker && (holder.owner.lastattackertime + 40) >= world.time)
			if(holder.owner.lastattacker != holder.owner)
				var/mob/M = holder.owner.lastattacker
				if (!istype(M))
					return

				var/mob/attacker = holder.owner.lastattacker
				holder.owner.visible_message("<span class='alert'><B>[holder.owner]'s eyes emit a vengeful glare at [attacker]!</B></span>")
				var/obj/itemspecialeffect/glare/E = new /obj/itemspecialeffect/glare
				E.color = "#ff0000"
				E.setup(holder.owner.loc)
				playsound(holder.owner.loc,"sound/effects/screech_tone.ogg", 50, 1, pitch = 1, extrarange = -4)

				SPAWN_DBG(1 DECI SECOND)
					var/obj/itemspecialeffect/glare/EE = new /obj/itemspecialeffect/glare
					EE.color = "#ff0000"
					EE.setup(attacker.loc)
					playsound(attacker.loc,"sound/effects/screech_tone.ogg", 50, 1, pitch = 0.8, extrarange = -4)

				attacker.apply_flash(30, 5, stamina_damage = 350)

				holder.owner.lastattacker = null

				SPAWN_DBG(0)
					var/obj/storage/container = null

					var/list/eligible_containers = list()
					for_by_tcl(iterated_container, /obj/storage)
						if (iterated_container.z == Z_LEVEL_STATION && iterated_container.req_access == null)
							eligible_containers += iterated_container
					if (!length(eligible_containers))
						return
					container = pick(eligible_containers)

					playsound(get_turf(holder.owner), "sound/effects/ghostbreath.ogg", 75, 1)
					animate(holder.owner, alpha=0, time=1.5 SECONDS)
					sleep(0.1 SECONDS)
					animate_ripple(holder.owner, 4)
					animate_wave(holder.owner, 3)
					sleep(1.4 SECONDS)
					if(!holder || !holder.owner)
						return
					if(container.open)
						container.close()
					holder.owner.set_loc(container)
					playsound(get_turf(container), "sound/effects/ghostlaugh.ogg", 75, 1)
					animate(holder.owner, alpha=255, time=1.5 SECONDS)
					sleep(1.5 SECONDS)
					if(!holder || !holder.owner)
						return
					animate(holder.owner)
				return 0
		else
			return 1

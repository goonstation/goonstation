/mob/living/critter/small_animal/broodling
	name = "broodling"
	desc = "A small space tick-looking creature."
	flags = TABLEPASS
	fits_under_table = 1
	hand_count = 1
	icon = 'icons/mob/brainslug.dmi'
	icon_state = "broodling"
	icon_state_dead = "broodling-dead"
	speechverb_say = "clicks"
	speechverb_exclaim = "clacks"
	speechverb_ask = "snips"
	health_brute = 35
	health_burn = 20
	ai_type = /datum/aiHolder/broodling
	add_abilities = list(/datum/targetable/critter/broodling_sting)
	is_npc = TRUE
	var/mob/living/master = null
	var/attack_damage = 3
	var/death_burn_duration = 15 SECONDS

	New(var/atom/A, var/mob/living/summoner = null, var/duration = null)
		if (summoner)
			src.master = summoner
		if (duration)
			SPAWN (duration)
				//Did we infest it in the meantime as a slug to get away? Then let's not kill it when it expires
				if (!src.slug)
					src.death()
		..()

	death()
		var/turf/T = get_turf(src)
		if (!istype(T, /turf/simulated/shuttle) && !istype(T, /turf/unsimulated) && !istype(T, /turf/space))
			T.acidify_turf(15 SECONDS)
		..()

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/mouse_squeak.ogg', 80, 1, channel=VOLUME_CHANNEL_EMOTE)
					return "<span class='emote'><b>[src]</b> squeaks!</span>"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
		return ..()

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "claw"
		HH.limb_name = "claws"

	seek_target(range)
		. = list()
		for (var/mob/living/C in hearers(range, src))
			if (isintangible(C) || isdead(C) || istype(C, /mob/living/critter/small_animal/broodling) || istype(C, /mob/living/critter/brain_slug) || istype(C, /mob/living/critter/adult_brain_slug) || (C == master)) continue
			. += C

	critter_attack(target)
		if(ismob(target))
			var/datum/targetable/critter/broodling_sting/sting = src.abilityHolder.getAbility(/datum/targetable/critter/broodling_sting)
			if (!sting.disabled && sting.cooldowncheck() && prob(40))
				sting.handleCast(target)
			else
				src.visible_message("<span class='combat'><B>[src]</B> stings [target]!</span>", "<span class='combat'>You sting [target]!</span>")
				playsound(src.loc, 'sound/impact_sounds/Flesh_Stab_1.ogg', 40, 1, -1)
				random_brute_damage(target, rand(src.attack_damage, src.attack_damage+3))

/datum/targetable/critter/broodling_sting
	name = "Suffocating sting"
	desc = "Sting a living thing, and inject it with a debilitating chemical."
	icon_state = "clown_spider_bite"
	cooldown = 30 SECONDS
	targeted = 1
	target_anything = 0
	var/inject_amount = 3.5

	cast(atom/target)
		if (..())
			return TRUE
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living) in target
			if (!target)
				boutput(holder.owner, "<span class='alert'>Nothing to sting there.</span>")
				return TRUE
		if (target == holder.owner)
			return TRUE
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, "<span class='alert'>That is too far away to sting.</span>")
			return TRUE
		var/mob/MT = target
		if (!MT.reagents)
			random_brute_damage(target, rand(2, 4))
			holder.owner.visible_message("<span class='alert'>[holder.owner] agressively jabs [MT] with it's stinger!</span>")
			return FALSE
		else
			MT.reagents?.add_reagent("sulfonal", inject_amount)
			holder.owner.visible_message("<span class='alert'>[holder.owner] stings [MT] with it's stinger!</span>")
			return FALSE

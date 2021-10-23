/**
 * Playable bots
 */
ABSTRACT_TYPE(/mob/living/critter/bot)
/mob/living/critter/bot
	name = "base bot mob (you should never see me)"
	icon = 'icons/obj/bots/aibots.dmi'
	blood_id = "oil"
	speechverb_say = "beeps"
	speechverb_gasp = "warbles"
	speechverb_stammer = "bleeps"
	speechverb_exclaim = "boops"
	speechverb_ask = "bloops"
	stepsound = "step_plating"
	robot_talk_understand = TRUE
	hand_count = 1
	can_burn = FALSE
	dna_to_absorb = 0
	butcherable = FALSE
	metabolizes = FALSE
	custom_gib_handler = /proc/robogibs
	stepsound = null
	/// defined in new, this is the base of the icon_state with the suffix removed, i.e. "cleanbot" without the "1"
	var/icon_state_base = null
	var/brute_hp = 25
	var/burn_hp = 25
	var/emagged = FALSE

	New()
		. = ..()
		remove_lifeprocess(/datum/lifeprocess/blindness)
		remove_lifeprocess(/datum/lifeprocess/viruses)
		remove_lifeprocess(/datum/lifeprocess/blood)

		var/obj/item/implant/access/infinite/assistant/O = new /obj/item/implant/access/infinite/assistant(src)
		O.owner = src
		O.implanted = 1

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "grabber"
		HH.limb_name = "grabber"
		HH.can_hold_items = 1
		HH.can_attack = 1
		HH.can_range_attack = 0

	setup_healths()
		add_hh_robot(brute_hp, 1)
		add_hh_robot_burn(burn_hp, 1)

	get_melee_protection(zone, damage_type)
		return 3

	get_ranged_protection()
		return 2

	death(var/gibbed)
		..(gibbed, 0)
		if (!gibbed)
			gib(src)
		else
			playsound(src.loc, "sound/impact_sounds/Machinery_Break_1.ogg", 50, 1)
			make_cleanable(/obj/decal/cleanable/oil,src.loc)

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(get_turf(src), "sound/voice/screams/robot_scream.ogg" , 10, 0, pitch = -1, channel=VOLUME_CHANNEL_EMOTE)
					return "<b>[src]</b> screams!"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
		return ..()

	cleanbot
		name = "cleanbot"
		real_name = "cleanbot"
		desc = "A little cleaning robot, he looks so excited!"
		icon_state = "cleanbot1"
		icon_state_base = "cleanbot"

		New()
			. = ..()
			if(prob(50))
				icon_state = "cleanbot-red1"
				icon_state_base = "cleanbot-red"

			color = pick(list(
				null,\
				list(0,1,0,0,0,1,1,0,0),\
				list(0,0,1,1,0,0,0,1,0),\
				list(0.5,0.5,0,0,0.5,0.5,0.5,0,0.5),\
				list(0.5,0,0.5,0.5,0.5,0,0,0.5,0.5),
			))

			src.reagents.maximum_volume = 60
			src.reagents.add_reagent("cleaner", 10)
			src.abilityHolder.addAbility(/datum/targetable/critter/bot/mop_floor)
			src.abilityHolder.addAbility(/datum/targetable/critter/bot/reagent_scan_self)

		emag_act(mob/user, obj/item/card/emag/E)
			. = ..()
			if(!src.emagged)
				playsound(src, "sound/effects/sparks4.ogg", 50)
				src.audible_message("<span class='alert'><B>[src] buzzes oddly!</B></span>")
				src.abilityHolder.addAbility(/datum/targetable/critter/bot/fill_with_chem/lube)
				src.abilityHolder.addAbility(/datum/targetable/critter/bot/fill_with_chem/phlogiston_dust)
				src.emagged = TRUE

		emagged
			brute_hp = 50
			burn_hp = 50
			emagged = TRUE
			New()
				. = ..()
				src.abilityHolder.addAbility(/datum/targetable/critter/bot/fill_with_chem/lube)
				src.abilityHolder.addAbility(/datum/targetable/critter/bot/fill_with_chem/phlogiston_dust)

ABSTRACT_TYPE(/datum/targetable/critter/bot)
/datum/targetable/critter/bot/mop_floor
	name = "Mop Floor"
	desc = "Clean the floor of dirt and other grime."
	icon_state = "clean_mop"
	targeted = TRUE
	target_anything = TRUE
	cooldown = 3 SECONDS
	max_range = 1

	cast(atom/target)
		if(!holder?.owner)
			return TRUE
		actions.start(new/datum/action/bar/icon/mob_cleanbot_clean(holder.owner, target), holder.owner)

ABSTRACT_TYPE(/datum/targetable/critter/bot/fill_with_chem)
/datum/targetable/critter/bot/fill_with_chem
	name = "Synthesize Reagent"
	targeted = FALSE
	cooldown = 30 SECONDS
	var/reagent_id = null

	cast(atom/target)
		if(!holder?.owner?.reagents)
			return TRUE
		holder.owner.reagents.add_reagent(reagent_id, 30)
		playsound(holder.owner.loc, "sound/effects/zzzt.ogg", 50, 1, -6)
	lube
		name = "Synthesize Space Lube"
		desc = "Fill yourself will space lube. Creates a slipping hazard, but it makes those floors shine so well that you can see yourself in them!"
		reagent_id = "lube"
		icon_state = "clean_lube"

	phlogiston_dust
		name = "Synthesize Phlogiston Dust"
		desc = "Fill yourself will phlogiston dust. For those stuck on messes!"
		reagent_id = "firedust"
		icon_state = "clean_phlog"

/datum/targetable/critter/bot/reagent_scan_self
	name = "Reagent Scan Self"
	desc = "Scan yourself for reagents."
	targeted = FALSE
	cooldown = 10 SECONDS
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "clean_scan"
	var/reagent_id = null

	cast(atom/target)
		if(!holder?.owner?.reagents)
			return TRUE
		boutput(holder.owner, "[scan_reagents(holder.owner, visible = 1)]")

/datum/action/bar/icon/mob_cleanbot_clean
	duration = 1 SECOND
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED
	id = "mob_cleanbot_clean"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	var/mob/master
	var/turf/T
	var/const/cleaning_reagent = "cleaner"

	New(mob/user, atom/target)
		..()
		src.master = user
		src.T = get_turf(target)

	onStart()
		..()
		if (!master || is_incapacitated(master) || !T)
			interrupt(INTERRUPT_ALWAYS)
			return

		playsound(get_turf(master), "sound/impact_sounds/Liquid_Slosh_2.ogg", 25, 1)
		master.anchored = 1
		if(istype(master, /mob/living/critter/bot))
			var/mob/living/critter/bot/bot = master
			master.icon_state = "[bot.icon_state_base]-c"
		master.visible_message("<span class='alert'>[master] begins to clean the [T.name].</span>")

	onUpdate()
		..()
		if (!master || is_incapacitated(master) || !T)
			interrupt(INTERRUPT_ALWAYS)
			return

	onInterrupt(flag)
		. = ..()
		if(istype(master, /mob/living/critter/bot))
			var/mob/living/critter/bot/bot = master
			master.icon_state = "[bot.icon_state_base]1"

	onEnd()
		if (master)
			if (master.reagents)
				master.reagents.remove_any(10)
				var/cleaner_amt = master.reagents.get_reagent_amount(cleaning_reagent)
				if (cleaner_amt <= 10)
					master.reagents.add_reagent(cleaning_reagent, 10 - cleaner_amt)
				master.reagents.reaction(T, TOUCH, 10)

			if (T.active_liquid)
				if (T.active_liquid.group)
					T.active_liquid.group.drain(T.active_liquid,1,master)

			if(istype(master, /mob/living/critter/bot))
				var/mob/living/critter/bot/bot = master
				master.icon_state = "[bot.icon_state_base]1"
		..()

/mob/living/critter/bot/firebot
	name = "firebot"
	real_name = "firebot"
	desc = "A little fire-fighting robot!  He looks so darn chipper."
	icon_state = "firebot1"
	icon_state_base = "firebot"

	New()
		. = ..()
		color = pick(list(
			null,\
			list(0,1,0,0,0,1,1,0,0),\
			list(0,0,1,1,0,0,0,1,0),\
			list(0.5,0.5,0,0,0.5,0.5,0.5,0,0.5),\
			list(0.5,0,0.5,0.5,0.5,0,0,0.5,0.5),
		))

		src.abilityHolder.addAbility(/datum/targetable/critter/bot/spray_foam)


	emag_act(mob/user, obj/item/card/emag/E)
		. = ..()
		if(!src.emagged)
			playsound(src, "sound/effects/sparks4.ogg", 50)
			src.audible_message("<span class='alert'><B>[src] buzzes oddly!</B></span>")
			src.abilityHolder.addAbility(/datum/targetable/critter/bot/spray_fire)
			src.abilityHolder.addAbility(/datum/targetable/critter/bot/spray_foam/throw_humans)
			src.emagged = TRUE

	emagged
		brute_hp = 50
		burn_hp = 50
		emagged = TRUE
		New()
			. = ..()
			src.abilityHolder.addAbility(/datum/targetable/critter/bot/spray_fire)
			src.abilityHolder.addAbility(/datum/targetable/critter/bot/spray_foam/throw_humans)


/datum/targetable/critter/bot/spray_foam
	name = "Spray Foam"
	desc = "Unleash your spray foam cannon to kill the fire."
	targeted = TRUE
	target_anything = TRUE
	cooldown = 5 SECONDS
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "firebot_foam"
	var/const/num_water_effects = 5

	cast(atom/target)
		if(!holder?.owner)
			return TRUE
		flick("firebot-c", holder.owner)
		playsound(get_turf(holder.owner), "sound/effects/spray.ogg", 50, 1, -3)

		var/direction = get_dir(holder.owner,target)

		var/turf/T = get_turf(target)
		var/turf/T1 = get_step(T,turn(direction, 90))
		var/turf/T2 = get_step(T,turn(direction, -90))

		var/list/the_targets = list(T,T1,T2)

		for(var/i in 0 to num_water_effects)
			var/obj/effects/water/W = new /obj/effects/water
			if(!W) return
			W.set_loc(get_turf(holder.owner))
			var/turf/my_target = pick(the_targets)
			var/datum/reagents/R = new/datum/reagents(15)
			R.add_reagent("water", 2)
			R.add_reagent("ff-foam", 8)
			W.spray_at(my_target, R, 1)

	throw_humans
		name = "High Pressure Foam"
		desc = "Unleash your spray foam cannon to send humans flying."
		cooldown = 10 SECONDS

		cast(atom/target)
			if(..())
				return TRUE
			for(var/mob/living/carbon/human/H in view(1, target))
				var/atom/targetTurf = get_edge_target_turf(H, get_dir(holder.owner, get_step_away(H, holder.owner)))
				boutput(H, "<span class='alert'><b>[holder.owner] knocks you back!</b></span>")
				H.changeStatus("weakened", 2 SECONDS)
				H.throw_at(targetTurf, 200, 4)


/datum/targetable/critter/bot/spray_fire
	name = "Spray Flames"
	desc = "Sometimes you gotta make your own fun."
	targeted = TRUE
	target_anything = TRUE
	cooldown = 10 SECONDS
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "firebot_fire"
	var/max_fire_range = 3
	cooldown = 10 SECONDS
	var/temp = 1200

	cast(atom/target)
		if (..())
			return 1

		var/turf/T = get_turf(target)
		var/list/affected_turfs = getline(holder.owner, T)
		flick("firebot-c", holder.owner)
		playsound(holder.owner.loc, "sound/effects/mag_fireballlaunch.ogg", 50, 0)
		var/turf/currentturf
		var/turf/previousturf
		for(var/turf/F in affected_turfs)
			previousturf = currentturf
			currentturf = F
			if(currentturf.density || istype(currentturf, /turf/space))
				break
			if(previousturf && LinkBlocked(previousturf, currentturf))
				break
			if (F == get_turf(holder.owner))
				continue
			if (get_dist(holder.owner,F) > max_fire_range)
				continue
			tfireflash(F,0.5,temp)


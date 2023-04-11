/datum/targetable/werewolf/werewolf_feast
	name = "Maul victim"
	desc = "Feast on the target to quell your hunger."
	icon_state = "feast"
	targeted = TRUE
	target_nodamage_check = TRUE
	target_self = FALSE
	max_range = 1
	cooldown = 1 SECOND
	can_cast_while_cuffed = FALSE
	werewolf_only = TRUE
	restricted_area_check = ABILITY_AREA_CHECK_VR_ONLY

	cast(mob/target)
		. = ..()
		var/mob/living/user = src.holder.owner

		logTheThing(LOG_COMBAT, user, "starts to maul [constructTarget(target,"combat")] at [log_loc(user)].")
		actions.start(new/datum/action/bar/private/icon/werewolf_feast(target, src), user)
		return TRUE // don't go on cooldown

	castcheck(mob/target)
		. = ..()
		var/mob/user = src.holder.owner
		if (!ishuman(target)) // Critter mobs include robots and combat drones. There's not a lot of meat on them.
			boutput(user, "<span class='alert'>[target] probably wouldn't taste very good.</span>")
			return FALSE

		if (isnpc(target)) // Critter mobs include robots and combat drones. There's not a lot of meat on them.
			boutput(user, "<span class='alert'>Something about [target]'s smell puts you off feasting on them.</span>")
			return FALSE

		if (!target.lying)
			boutput(user, "<span class='alert'>[target] needs to be lying on the ground first.</span>")
			return FALSE

		// What do we do if the body is dead?
		if (isdead(target))
			if (target.reagents)
				if (target.reagents.has_reagent("formaldehyde", 15))
					boutput(user, "<span class='alert'>Urgh, this cadaver tastes horrible. Better find some chemical free meat.</span>")
					return FALSE

		var/mob/living/carbon/human/H = target
		//If they are at the decay or greater decomp stage, no eat
		if (istype(H) && H.decomp_stage >= DECOMP_STAGE_DECAYED)
			boutput(user, "<span class='alert'>Urgh, this cadaver tastes horrible. Better find some fresh meat.</span>")
			return FALSE

/datum/action/bar/private/icon/werewolf_feast
	duration = 25 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "werewolf_feast"
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "devour_over"
	var/mob/living/target
	var/datum/targetable/werewolf/werewolf_feast/feast
	var/times_attacked = 0
	var/do_we_get_points = FALSE // For the specialist objective. Did we feed on the target enough times?

	New(Target, Feast)
		target = Target
		feast = Feast
		..()

	onStart()
		. = ..()

		var/mob/living/M = owner
		var/datum/abilityHolder/A = feast.holder

		if (!feast || GET_DIST(M, target) > feast.max_range || target == null || M == null || !ishuman(target) || !ishuman(M) || !A || !istype(A))
			interrupt(INTERRUPT_ALWAYS)
			return

		playsound(M.loc, pick('sound/voice/animal/werewolf_attack1.ogg', 'sound/voice/animal/werewolf_attack2.ogg', 'sound/voice/animal/werewolf_attack3.ogg'), 50, 1)
		M.visible_message("<span class='alert'><B>[M] lunges at [target]!</b></span>")

	onUpdate()
		..()

		var/mob/living/M = owner
		var/datum/abilityHolder/A = feast.holder

		if (!feast || GET_DIST(M, target) > feast.max_range || target == null || M == null || !ishuman(target) || !ishuman(M) || !A || !istype(A) || (!target.lying))
			interrupt(INTERRUPT_ALWAYS)
			return

		if (!ON_COOLDOWN(M, "ww feast", 2.5 SECONDS)) // Enough time between attacks for them to happen 9 times
			M.werewolf_attack(target, "feast")
			times_attacked += 1

		if ((times_attacked >= 7)) // Can't farm npc monkeys.
			src.do_we_get_points = TRUE

	onEnd()
		..()

		var/datum/abilityHolder/A = feast.holder
		var/mob/living/M = owner

		// AH parent var for AH.locked vs. specific one for the feed objective.
		// Critter mobs only use one specific type of abilityHolder for instance.
		if (istype(A, /datum/abilityHolder/werewolf))
			var/datum/abilityHolder/werewolf/W = A
			if (W.feed_objective && istype(W.feed_objective, /datum/objective/specialist/werewolf/feed/))
				if (src.do_we_get_points == 1)
					if (istype(target) && target.bioHolder)
						if (!W.feed_objective.mobs_fed_on.Find(target.bioHolder.Uid))
							W.feed_objective.mobs_fed_on.Add(target.bioHolder.Uid)
							W.feed_objective.feed_count++
							APPLY_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "feast-[W.feed_objective.feed_count]", 2)
							M.add_stam_mod_max("feast-[W.feed_objective.feed_count]", 10)
							M.max_health += 10
							health_update_queue |= M
							W.lower_cooldowns(0.1)
							boutput(M, "<span class='notice'>You finish chewing on [target], but what a feast it was!</span>")
						else
							boutput(M, "<span class='alert'>You've mauled [target] before and didn't like the aftertaste. Better find a different prey.</span>")
					else
						boutput(M, "<span class='alert'>What a meagre meal. You're still hungry...</span>")
				else
					boutput(M, "<span class='alert'>What a meagre meal. You're still hungry...</span>")
			else
				boutput(M, "<span class='alert'>You finish chewing on [target].</span>")
		else
			boutput(M, "<span class='alert'>You finish chewing on [target].</span>")

	onInterrupt()
		..()

		var/datum/abilityHolder/A = feast.holder
		var/mob/living/M = owner
		var/mob/living/carbon/human/HH = target

		if (istype(A, /datum/abilityHolder/werewolf))
			var/datum/abilityHolder/werewolf/W = A
			if (W.feed_objective && istype(W.feed_objective, /datum/objective/specialist/werewolf/feed/))
				if (src.do_we_get_points == 1)
					if (istype(HH) && HH.bioHolder)
						if (!W.feed_objective.mobs_fed_on.Find(HH.bioHolder.Uid))
							W.feed_objective.mobs_fed_on.Add(HH.bioHolder.Uid)
							W.feed_objective.feed_count++
							APPLY_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "feast-[W.feed_objective.feed_count]", 1)
							M.add_stam_mod_max("feast-[W.feed_objective.feed_count]", 5)
							M.max_health += 10
							health_update_queue |= M
							W.lower_cooldowns(0.1)
							boutput(M, "<span class='notice'>Your feast was interrupted, but it satisfied your hunger for the time being.</span>")
						else
							boutput(M, "<span class='alert'>You've mauled [HH] before and didn't like the aftertaste. Better find a different prey.</span>")
					else
						boutput(M, "<span class='alert'>Your feast was interrupted and you're still hungry...</span>")
				else
					boutput(M, "<span class='alert'>Your feast was interrupted and you're still hungry...</span>")
			else
				boutput(M, "<span class='alert'>Your feast was interrupted.</span>")
		else
			boutput(M, "<span class='alert'>Your feast was interrupted.</span>")

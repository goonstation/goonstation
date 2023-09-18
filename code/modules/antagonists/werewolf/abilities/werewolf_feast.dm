/datum/targetable/werewolf/werewolf_feast
	name = "Maul victim"
	desc = "Feast on the target to quell your hunger."
	icon_state = "feast"
	targeted = TRUE
	target_nodamage_check = TRUE
	target_self = FALSE
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
			boutput(user, "<span class='alert'>Something about [target]'s smell puts you off feasting on [him_or_her(target)].</span>")
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

// TODO move checks to canRunCheck(), add isNPC check
/datum/action/bar/private/icon/werewolf_feast
	duration = 10 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "werewolf_feast"
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "devour_over"
	var/mob/living/target
	var/datum/targetable/werewolf/werewolf_feast/feast

	New(Target, Feast)
		target = Target
		feast = Feast
		..()

	onStart()
		. = ..()

		var/mob/living/M = owner

		if (GET_DIST(M, target) > feast.max_range)
			interrupt(INTERRUPT_ALWAYS)
			return

		playsound(M.loc, pick('sound/voice/animal/werewolf_attack1.ogg', 'sound/voice/animal/werewolf_attack2.ogg', 'sound/voice/animal/werewolf_attack3.ogg'), 50, 1)
		M.visible_message("<span class='alert'><B>[M] lunges at [target]!</b></span>")

	onUpdate()
		..()

		var/mob/living/M = owner


		if (GET_DIST(M, target) > feast.max_range)
			interrupt(INTERRUPT_ALWAYS)
			return

		if (!ON_COOLDOWN(M, "ww feast", 2.5 SECONDS))
			M.werewolf_attack(target, "feast")

	onEnd()
		..()

		var/datum/abilityHolder/werewolf/AH = feast.holder
		var/mob/living/M = owner

		if (AH.feed_objective)
			if (target.bioHolder)
				if (!AH.feed_objective.mobs_fed_on.Find(target.bioHolder.Uid))
					AH.feed_objective.mobs_fed_on.Add(target.bioHolder.Uid)
					AH.feed_objective.feed_count++
					APPLY_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "feast-[AH.feed_objective.feed_count]", 2)
					M.add_stam_mod_max("feast-[AH.feed_objective.feed_count]", 10)
					M.max_health += 10
					health_update_queue |= M
					AH.lower_cooldowns(0.1)
					boutput(M, "<span class='notice'>You finish chewing on [target], but what a feast it was!</span>")
				else
					boutput(M, "<span class='alert'>You've mauled [target] before. Better find a different prey.</span>")
			else
				boutput(M, "<span class='alert'>Something about this food is wrong...</span>")
				stack_trace("Werewolf feed tried to complete on mob [identify_object(target)] which had no bioHolder.")
		else
			boutput(M, "<span class='alert'>You finish chewing on [target].</span>")

	onInterrupt()
		..()
		boutput(src.owner, "<span class='alert'>Your feast was interrupted.</span>")

/datum/targetable/vampire/blood_steal
	name = "Blood Steal"
	desc = "Steal blood from a victim at range. This ability will continue to channel until you move."
	icon_state = "bloodsteal"
	targeted = TRUE
	target_nodamage_check = TRUE
	check_range = FALSE
	cooldown = 45 SECONDS
	incapacitation_restriction = ABILITY_CAN_USE_WHEN_STUNNED
	can_cast_while_cuffed = TRUE
	sticky = TRUE

	cast(mob/target)
		. = ..()

		var/mob/living/M = holder.owner
		var/datum/abilityHolder/vampire/V = holder

		actions.start(new /datum/action/bar/private/icon/vamp_ranged_blood_suck(M, V, target, src), M)

	castcheck(atom/target)
		. = ..()
		if (actions.hasAction(src.holder.owner, "vamp_blood_suck"))
			boutput(src.holder.owner, "<span class='alert'>You are already performing a Bite action and cannot start a Blood Steal.</span>")
			return FALSE

		if (isnpc(target))
			boutput(src.holder.owner, "<span class='alert'>The blood of this target would provide you with no sustenance.</span>")
			return FALSE


/datum/action/bar/private/icon/vamp_ranged_blood_suck
	duration = 1 SECOND
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED
	id = "vamp_blood_suck_ranged"
	icon = 'icons/ui/actions.dmi'
	icon_state = "blood"
	bar_icon_state = "bar-vampire"
	border_icon_state = "border-vampire"
	color_active = "#d73715"
	color_success = "#f21b1b"
	color_failure = "#8d1422"
	var/mob/living/carbon/human/user
	var/datum/abilityHolder/vampire/AH
	var/mob/living/carbon/human/target
	var/datum/targetable/vampire/blood_steal/ability

	New(user,vampabilityholder,target,biteabil)
		src.user = user
		src.target = target
		AH = vampabilityholder
		ability = biteabil
		..()

	onUpdate()
		..()
		if(GET_DIST(user, target) > 7 || user == null || target == null || target.blood_volume <= 0)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(user == null || target == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if (!AH.can_bite(target, is_pointblank = FALSE))
			interrupt(INTERRUPT_ALWAYS)
			return

		if (GET_DIST(user, target) > 7)
			boutput(user, "<span class='alert'>That target is too far away!</span>")
			return

		if (istype(AH))
			AH.vamp_isbiting = target

		src.loopStart()

	loopStart()
		..()
		var/obj/projectile/proj = initialize_projectile_pixel_spread(HH, new/datum/projectile/special/homing/vamp_blood, M)
		var/tries = 10
		while (tries > 0 && (!proj || proj.disposed))
			proj = initialize_projectile_pixel_spread(HH, new/datum/projectile/special/homing/vamp_blood, M)
			tries--
		if(isnull(proj) || proj.disposed)
			boutput(user, "<span class='alert'>Blood steal interrupted.</span>")
			interrupt(INTERRUPT_ALWAYS)
			return

		proj.special_data["vamp"] = AH
		proj.special_data["victim"] = target
		proj.special_data["returned"] = FALSE
		proj.targets = list(target)

		proj.launch()

		if (prob(25))
			boutput(target, "<span class='alert'>Some blood is forced right out of your body!</span>")

		logTheThing(LOG_COMBAT, user, "steals blood from [constructTarget(target,"combat")] at [log_loc(user)].")

	onEnd()
		if(GET_DIST(user, target) > 7 || user == null || target == null || !AH.can_bite(target, is_pointblank = FALSE))
			..()
			interrupt(INTERRUPT_ALWAYS)
			src.end()
			return

		src.onRestart()

	onInterrupt() //Called when the action fails / is interrupted.
		if (state == ACTIONSTATE_RUNNING)
			if (target.blood_volume <= 0)
				boutput(user, "<span class='alert'>[target] doesn't have enough blood left to drink.</span>")
			else if (!AH.can_take_blood_from(AH, target))
				boutput(user, "<span class='alert'>You have drank your fill [target]'s blood. It tastes all bland and gross now.</span>")
			else
				boutput(user, "<span class='alert'>Your feast was interrupted.</span>")

		if (ability)
			ability.doCooldown()
		src.end()

		..()

	proc/end()
		AH.vamp_isbiting = null

/datum/projectile/special/homing/vamp_blood
#if defined(APRIL_FOOLS)
	name = "blood morb"
#else
	name = "blood glob"
#endif
	icon_state = "bloodproj"
	start_speed = 9
	goes_through_walls = 1
	//goes_through_mobs = 1
	auto_find_targets = 0
	silentshot = 1
	pierces = -1
	max_range = 10
	shot_sound = 'sound/impact_sounds/Flesh_Tear_1.ogg'

	on_launch(var/obj/projectile/P)
		if (!("victim" in P.special_data))
			P.die()
			return

		if (!("vamp" in P.special_data))
			P.die()
			return
		P.layer = EFFECTS_LAYER_BASE
		flick("bloodproj",P)
		..()

	on_hit(atom/hit, direction, var/obj/projectile/P)
		if (("vamp" in P.special_data))
			var/datum/abilityHolder/vampire/vampire = P.special_data["vamp"]
			if (vampire.owner == hit && !P.special_data["returned"])
				P.travelled = 0
				P.max_range = 4
				P.special_data["returned"] = TRUE
			..()

	on_end(var/obj/projectile/P)
		if (("vamp" in P.special_data) && ("victim" in P.special_data) && P.special_data["returned"])
			var/datum/abilityHolder/vampire/vampire = P.special_data["vamp"]
			var/mob/living/victim = P.special_data["victim"]

			if (vampire && victim)
				if (vampire.can_bite(victim,is_pointblank = 0))
					vampire.do_bite(victim, mult = 0.3333)

				if(istype(vampire.owner))
					vampire.owner?.add_stamina(20)
				victim.remove_stamina(4)

		..()

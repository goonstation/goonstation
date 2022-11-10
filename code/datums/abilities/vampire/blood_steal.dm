/datum/targetable/vampire/blood_steal
	name = "Blood Steal"
	desc = "Steal blood from a victim at range. This ability will continue to channel until you move."
	icon_state = "bloodsteal"
	targeted = 1
	target_nodamage_check = 1
	max_range = 999
	cooldown = 45 SECONDS
	pointCost = 0
	when_stunned = 1
	not_when_handcuffed = 0
	sticky = 1

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner
		var/datum/abilityHolder/vampire/V = holder

		if (actions.hasAction(M, "vamp_blood_suck"))
			boutput(M, "<span class='alert'>You are already performing a Bite action and cannot start a Blood Steal.</span>")
			return 1

		if (isnpc(target))
			boutput(M, "<span class='alert'>The blood of this target would provide you with no sustenance.</span>")
			return 1

		actions.start(new/datum/action/bar/private/icon/vamp_ranged_blood_suc(M,V,target, src), M)

		return 0

/datum/action/bar/private/icon/vamp_ranged_blood_suc
	duration = 10
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED
	id = "vamp_blood_suck_ranged"
	icon = 'icons/ui/actions.dmi'
	icon_state = "blood"
	bar_icon_state = "bar-vampire"
	border_icon_state = "border-vampire"
	color_active = "#d73715"
	color_success = "#f21b1b"
	color_failure = "#8d1422"
	var/mob/living/carbon/human/M
	var/datum/abilityHolder/vampire/H
	var/mob/living/carbon/human/HH
	var/datum/targetable/vampire/blood_steal/ability

	New(user,vampabilityholder,target,biteabil)
		M = user
		H = vampabilityholder
		HH = target
		ability = biteabil
		..()

	onUpdate()
		..()
		if(GET_DIST(M, HH) > 7 || M == null || HH == null || HH.blood_volume <= 0)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(M == null || HH == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if (!H.can_bite(HH, is_pointblank = 0))
			interrupt(INTERRUPT_ALWAYS)
			return

		if (GET_DIST(M, HH) > 7)
			boutput(M, "<span class='alert'>That target is too far away!</span>")
			return

		if (istype(H))
			H.vamp_isbiting = HH

		src.loopStart()

	loopStart()
		..()
		var/obj/projectile/proj = initialize_projectile_ST(HH, new/datum/projectile/special/homing/vamp_blood, M)
		var/tries = 10
		while (tries > 0 && (!proj || proj.disposed))
			proj = initialize_projectile_ST(HH, new/datum/projectile/special/homing/vamp_blood, M)
			tries--
		if(isnull(proj) || proj.disposed)
			boutput(HH, "<span class='alert'>Blood steal interrupted.</span>")
			interrupt(INTERRUPT_ALWAYS)
			return

		proj.special_data["vamp"] = H
		proj.special_data["victim"] = HH
		proj.special_data["returned"] = FALSE
		proj.targets = list(M)

		proj.launch()

		if (prob(25))
			boutput(HH, "<span class='alert'>Some blood is forced right out of your body!</span>")

		logTheThing(LOG_COMBAT, M, "steals blood from [constructTarget(HH,"combat")] at [log_loc(M)].")

	onEnd()
		if(GET_DIST(M, HH) > 7 || M == null || HH == null || !H.can_bite(HH, is_pointblank = 0))
			..()
			interrupt(INTERRUPT_ALWAYS)
			src.end()
			return

		src.onRestart()

	onInterrupt() //Called when the action fails / is interrupted.
		if (state == ACTIONSTATE_RUNNING)
			if (HH.blood_volume <= 0)
				boutput(M, "<span class='alert'>[HH] doesn't have enough blood left to drink.</span>")
			else if (!H.can_take_blood_from(H, HH))
				boutput(M, "<span class='alert'>You have drank your fill [HH]'s blood. It tastes all bland and gross now.</span>")
			else
				boutput(M, "<span class='alert'>Your feast was interrupted.</span>")

		if (ability)
			ability.doCooldown()
		src.end()

		..()

	proc/end()
		if (istype(H))
			H.vamp_isbiting = null

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

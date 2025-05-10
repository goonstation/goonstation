/datum/targetable/vampire/enthrall
	name = "Enthrall"
	desc = "Cast this ability on a dead human to revive them as a loyal thrall. Thralls will weaken as their blood drains : use this ability on existing thralls to donate additional blood."
	icon_state = "enthrall"
	targeted = 1
	target_nodamage_check = 1
	max_range = 1
	cooldown = 300
	pointCost = 200 //copy pasted below. sorry.
	when_stunned = 0
	not_when_handcuffed = 1
	restricted_area_check = ABILITY_AREA_CHECK_VR_ONLY
	unlock_message = "You have gained Enthrall. It allows you to enthrall dead humans."

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner
		//var/datum/abilityHolder/vampire/H = holder

		if (!M || !target || !ismob(target))
			return 1

		if (M == target)
			boutput(M, SPAN_ALERT("Why would you want to enthrall yourself?"))
			return 1

		if (GET_DIST(M, target) > src.max_range)
			boutput(M, SPAN_ALERT("[target] is too far away."))
			return 1

		if (!ishuman(target))
			return 1

		. = ..()
		actions.start(new/datum/action/bar/private/icon/vampire_enthrall_thrall(target, src, pointCost), M)
		return 1 //not 0, we dont awnna deduct points until cast finishes

/datum/action/bar/private/icon/vampire_enthrall_thrall
	duration = 20
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/ui/actions.dmi'
	icon_state = "enthrall"
	bar_icon_state = "bar-vampire"
	border_icon_state = "border-vampire"
	color_active = "#3c6dc3"
	color_success = "#3fb54f"
	color_failure = "#8d1422"
	var/mob/living/carbon/human/target
	var/datum/targetable/vampire/enthrall/enthrall
	var/cost = 200

	New(Target, Enthrall, pointCost)
		target = Target
		enthrall = Enthrall
		cost = pointCost
		..()

	onStart()
		..()

		var/mob/living/M = owner

		if (!enthrall || GET_DIST(M, target) > enthrall.max_range || target == null || M == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if (!isdead(target) && !istype(target.mutantrace, /datum/mutantrace/vampiric_thrall))
			boutput(M, SPAN_ALERT("[target] needs to be dead first."))
			interrupt(INTERRUPT_ALWAYS)
			return

		if(istype(M))
			M.visible_message(SPAN_ALERT("<B>[M] stabs [target] with [his_or_her(M)] sharp fingers!</B>"))
			boutput(M, SPAN_NOTICE("You begin to pump your [pick("polluted","spooky","bad","gross","icky","evil","necrotic")] blood into [target]'s chest."))
			boutput(target, SPAN_ALERT("You feel cold . . ."))

	onUpdate()
		..()

		var/mob/living/M = owner

		if (!enthrall || GET_DIST(M, target) > enthrall.max_range || target == null || M == null)
			interrupt(INTERRUPT_ALWAYS)
			return


	onEnd()
		..()

		var/mob/living/M = owner
		var/datum/abilityHolder/vampire/H = enthrall.holder

		if (!istype(target.mutantrace, /datum/mutantrace/vampiric_thrall))
			H.make_thrall(target)
		else
			target.full_heal()
			target.mind?.add_subordinate_antagonist(ROLE_VAMPTHRALL, master = enthrall.holder)

		if (target in H.thralls)
			//and add blood!
			var/datum/abilityHolder/vampiric_thrall/thrallHolder = target.get_ability_holder(/datum/abilityHolder/vampiric_thrall)
			if (thrallHolder)
				thrallHolder.points += 200
			//we also restore their real actual blood pressure a bit, to allow vampires to save their thralls who are drained
			target.blood_volume = min(target.blood_volume + 200, initial(target.blood_volume))

			H.deductPoints(cost)

			boutput(M, SPAN_NOTICE("You donate 200 blood points to [target]."))
			boutput(target, SPAN_NOTICE("[M] has donated you 200 blood points. Your health is temporarily increased."))
		else
			boutput(M, SPAN_NOTICE("You were not able to enthrall [target] - [his_or_her(target)] ghost has departed."))

	onInterrupt()
		..()
		boutput(owner, SPAN_ALERT("Your attempt to enthrall the target was interrupted!"))

// aloe wuz here making nonhumans thrallable in a refactor PR
/datum/targetable/vampire/enthrall
	name = "Enthrall"
	desc = "Cast this ability on a dead human to revive them as a loyal thrall. Thralls will weaken as their blood drains : use this ability on existing thralls to donate additional blood."
	icon_state = "enthrall"
	targeted = TRUE
	max_range = 1
	cooldown = 30 SECONDS
	pointCost = 200 //copy pasted below. sorry.
	can_cast_while_cuffed = FALSE
	restricted_area_check = ABILITY_AREA_CHECK_VR_ONLY
	unlock_message = "You have gained Enthrall. It allows you to enthrall dead humans."

	cast(mob/target)
		. = ..()
		actions.start(new/datum/action/bar/private/icon/vampire_enthrall_thrall(target, src, pointCost), src.holder.owner)
		return TRUE //not FALSE, we dont awnna deduct points until cast finishes

	castcheck(atom/target)
		. = ..()
		var/mob/M = src.holder.owner
		if (M == target)
			boutput(M, "<span class='alert'>Why would you want to enthrall yourself?</span>")
			return TRUE


/datum/targetable/vampire/speak_thrall
	name = "Speak to Thralls"
	desc = "Telepathically speak to all of your undead thralls."
	icon_state = "thrallspeak"
	targeted = FALSE
	not_when_in_an_object = FALSE
	incapacitation_restriction = ABILITY_CAN_USE_WHEN_STUNNED
	can_cast_while_cuffed = TRUE
	unlock_message = "You have gained 'Speak to Thralls'. It allows you to telepathically speak to all of your undead thralls."

	cast(mob/target)
		. = ..()
		var/mob/living/M = holder.owner
		var/datum/abilityHolder/vampire/H = holder

		var/message = html_encode(input("Choose something to say:","Enter Message.","") as null|text)
		if (!message)
			return TRUE

		H.transmit_thrall_msg(message, M)


/datum/action/bar/private/icon/vampire_enthrall_thrall
	duration = 2 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "vampire_enthrall"
	icon = 'icons/ui/actions.dmi'
	icon_state = "enthrall"
	bar_icon_state = "bar-vampire"
	border_icon_state = "border-vampire"
	color_active = "#3c6dc3"
	color_success = "#3fb54f"
	color_failure = "#8d1422"
	var/mob/living/target
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

		if (!enthrall || GET_DIST(M, target) > enthrall.max_range || M == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if (!isdead(src.target) && !isvampiricthrall(src.target))
			boutput(M, "<span class='alert'>[target] needs to be dead first.</span>")
			interrupt(INTERRUPT_ALWAYS)
			return

		if(istype(M))
			M.visible_message("<span class='alert'><B>[M] stabs [target] with their sharp fingers!</B></span>")
			boutput(M, "<span class='notice'>You begin to pump your [pick("polluted","spooky","bad","gross","icky","evil","necrotic")] blood into [target]'s chest.</span>")
			boutput(target, "<span class='alert'>You feel cold . . .</span>")

	onUpdate()
		..()

		var/mob/living/M = owner

		if (!enthrall || GET_DIST(M, target) > enthrall.max_range || target == null || M == null)
			interrupt(INTERRUPT_ALWAYS)
			return


	onEnd()
		..()

		var/mob/living/M = owner
		var/datum/abilityHolder/vampire/AH = enthrall.holder

		if (isvampiricthrall(target))
			target.full_heal()
			target.mind?.add_subordinate_antagonist(ROLE_VAMPTHRALL, master = enthrall.holder)

		if (target in AH.thralls)
			//and add blood!
			if (ishuman(target))
				var/mob/living/carbon/human/human_target = src.target
				var/datum/mutantrace/vampiric_thrall/V = human_target.mutantrace
				if (V)
					V.blood_points += 200

				AH.blood_tracking_output(cost)

				AH.deductPoints(cost)

				boutput(M, "<span class='notice'>You donate 200 blood points to [target].</span>")
				boutput(target, "<span class='notice'>[M] has donated you 200 blood points. Your health is temporarily increased.</span>")
		else
			boutput(M, "<span class='notice'>You were not able to enthrall [target] - [his_or_her(target)] ghost has departed.</span>")

	onInterrupt()
		..()
		boutput(owner, "<span class='alert'>Your attempt to enthrall the target was interrupted!</span>")

/datum/targetable/vampire/enthrall
	name = "Enthrall"
	desc = "Cast this ability on a dead human to revive them as a loyal thrall. Thralls will weaken as their blood drains : use this ability on existing thralls to donate additional blood."
	icon_state = "enthrall"
	targeted = 1
	target_nodamage_check = 1
	max_range = 1
	cooldown = 300
	pointCost = 100 //copy pasted below. sorry.
	when_stunned = 0
	not_when_handcuffed = 1
	restricted_area_check = 2
	unlock_message = "You have gained Enthrall. It allows you to enthrall dead humans."

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner
		//var/datum/abilityHolder/vampire/H = holder

		if (!M || !target || !ismob(target))
			return 1

		if (M == target)
			boutput(M, "<span class='alert'>Why would you want to enthrall yourself?</span>")
			return 1

		if (GET_DIST(M, target) > src.max_range)
			boutput(M, "<span class='alert'>[target] is too far away.</span>")
			return 1

		if (!ishuman(target))
			return 1

		actions.start(new/datum/action/bar/private/icon/vampire_enthrall_thrall(target, src), M)
		return 1 //not 0, we dont awnna deduct points until cast finishes

/datum/targetable/vampire/speak_thrall
	name = "Speak to Thralls"
	desc = "Telepathically speak to all of your undead thralls."
	icon_state = "thrallspeak"
	targeted = 0
	target_nodamage_check = 1
	max_range = 1
	cooldown = 1
	pointCost = 0
	not_when_in_an_object = FALSE
	when_stunned = 1
	not_when_handcuffed = 0
	restricted_area_check = 0
	unlock_message = "You have gained 'Speak to Thralls'. It allows you to telepathically speak to all of your undead thralls."

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner
		var/datum/abilityHolder/vampire/H = holder
		if (!M)
			return 1

		var/message = html_encode(tgui_input_text(usr, "Choose something to say:", "Enter Message."))
		if (!message)
			return
		logTheThing(LOG_SAY, holder.owner, "[message]")

		.= H.transmit_thrall_msg(message, M)

		return 0


/datum/action/bar/private/icon/vampire_enthrall_thrall
	duration = 20
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "vampire_enthrall"
	icon = 'icons/ui/actions.dmi'
	icon_state = "enthrall"
	bar_icon_state = "bar-vampire"
	border_icon_state = "border-vampire"
	color_active = "#3c6dc3"
	color_success = "#3fb54f"
	color_failure = "#8d1422"
	var/mob/living/carbon/human/target
	var/datum/targetable/vampire/enthrall/enthrall

	New(Target, Enthrall)
		target = Target
		enthrall = Enthrall
		..()

	onStart()
		..()

		var/mob/living/M = owner

		if (!enthrall || GET_DIST(M, target) > enthrall.max_range || target == null || M == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if (!isdead(target) && !istype(target.mutantrace, /datum/mutantrace/vampiric_thrall))
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
		var/datum/abilityHolder/vampire/H = enthrall.holder

		if (!istype(target.mutantrace, /datum/mutantrace/vampiric_thrall))
			H.make_thrall(target)
		else
			target.full_heal()

		if (target in H.thralls)
			//and add blood!
			var/datum/mutantrace/vampiric_thrall/V = target.mutantrace
			if (V)
				V.blood_points += 200

			H.blood_tracking_output(100)

			H.deductPoints(100)

			boutput(M, "<span class='notice'>You donate 200 blood points to [target].</span>")
			boutput(target, "<span class='notice'>[M] has donated you 200 blood points. Your health is temporarily increased.</span>")
		else
			boutput(M, "<span class='notice'>You were not able to enthrall [target] - their ghost has departed.</span>")

	onInterrupt()
		..()
		boutput(owner, "<span class='alert'>Your attempt to enthrall the target was interrupted!</span>")

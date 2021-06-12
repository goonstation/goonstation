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
	unlock_message = "You have gained Enthrall. It allows you to enslave dead humans."

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner
		//var/datum/abilityHolder/vampire/H = holder

		if (!M || !target || !ismob(target))
			return 1

		if (M == target)
			boutput(M, __red("Why would you want to enslave yourself?"))
			return 1

		if (get_dist(M, target) > src.max_range)
			boutput(M, __red("[target] is too far away."))
			return 1

		if (!ishuman(target))
			return 1

		actions.start(new/datum/action/bar/private/icon/vampire_enthrall_ghoul(target, src), M)
		return 1 //not 0, we dont awnna deduct points until cast finishes

/datum/targetable/vampire/speak_thrall
	name = "Speak to Ghouls"
	desc = "Telepathically speak to all of your undead thralls."
	icon_state = "ghoulspeak"
	targeted = 0
	target_nodamage_check = 1
	max_range = 1
	cooldown = 1
	pointCost = 0
	when_stunned = 1
	not_when_handcuffed = 0
	restricted_area_check = 0
	unlock_message = "You have gained 'Speak to Ghouls'. It allows you to telepathically speak to all of your undead thralls."

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner
		var/datum/abilityHolder/vampire/H = holder
		if (!M)
			return 1

		var/message = html_encode(input("Choose something to say:","Enter Message.","") as null|text)
		if (!message)
			return
		logTheThing("say", holder.owner, holder.owner.name, "[message]")

		.= H.transmit_ghoul_msg(message, M)

		return 0


/datum/action/bar/private/icon/vampire_enthrall_ghoul
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
	var/datum/targetable/vampire/enthrall/enslave

	New(Target, Enslave)
		target = Target
		enslave = Enslave
		..()

	onStart()
		..()

		var/mob/living/M = owner

		if (!enslave || get_dist(M, target) > enslave.max_range || target == null || M == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if (!isdead(target) && !istype(target.mutantrace, /datum/mutantrace/vamp_zombie))
			boutput(M, __red("[target] needs to be dead first."))
			interrupt(INTERRUPT_ALWAYS)
			return

		M.visible_message("<span class='alert'><B>[M] stabs [target] with their sharp fingers!</B></span>")
		boutput(M, __blue("You begin to pump your [pick("polluted","spooky","bad","gross","icky","evil","necrotic")] blood into [target]'s chest."))
		boutput(target, __red("You feel cold . . ."))

	onUpdate()
		..()

		var/mob/living/M = owner

		if (!enslave || get_dist(M, target) > enslave.max_range || target == null || M == null)
			interrupt(INTERRUPT_ALWAYS)
			return


	onEnd()
		..()

		var/mob/living/M = owner
		var/datum/abilityHolder/vampire/H = enslave.holder

		if (!istype(target.mutantrace, /datum/mutantrace/vamp_zombie))
			H.make_thrall(target)
		else
			target.full_heal()

		if (target in H.ghouls)
			//and add blood!
			var/datum/mutantrace/vamp_zombie/V = target.mutantrace
			if (V)
				V.blood_points += 200

			H.blood_tracking_output(100)

			H.deductPoints(100)

			boutput(M, __blue("You donate 200 blood points to [target]."))
			boutput(target, __blue("[M] has donated you 200 blood points. Your health is temporarily increased."))
		else
			boutput(M, __blue("You were not able to enthrall [target] - their ghost has departed."))

	onInterrupt()
		..()
		boutput(owner, __red("Your attempt to enthrall the target was interrupted!"))
/*
/datum/action/bar/private/icon/vampire_enthrall_old
	duration = 180
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "vampire_enthrall_old"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "grabbed"
	var/mob/living/target
	var/datum/targetable/vampire/enthrall/enslave
	var/last_complete = 0

	New(Target, Enslave)
		target = Target
		enslave = Enslave
		..()

	onStart()
		..()

		var/mob/living/M = owner
		var/datum/abilityHolder/vampire/H = enslave.holder

		if (!enslave || get_dist(M, target) > enslave.max_range || target == null || M == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		M.visible_message("<span class='alert'><B>[M] bites [target]!</B></span>")
		boutput(M, __blue("You begin to pump your polluted blood into [target]'s [issilicon(target) ? "serial port" : "neck"]."))
		if (issilicon(target))
			boutput(target, __red("New device found. Attempting plug & play configuration."))
		else
			boutput(target, __red("You feel a little cold all the sudden."))
		if (istype(H)) H.vamp_isbiting = target
		target.vamp_beingbitten = 1

	onUpdate()
		..()

		var/mob/living/M = owner

		if (!enslave || get_dist(M, target) > enslave.max_range || target == null || M == null || isdead(target) || !target.mind || !target.client)
			interrupt(INTERRUPT_ALWAYS)
			return

		if (target.bioHolder && target.traitHolder.hasTrait("training_chaplain"))
			boutput(M, __red("Wait, this is a chaplain!!! <B>AGDFHSKFGBLDFGLHSFDGHDFGH</B>"))
			boutput(target, __blue("Your divine protection saves you from enthrallment, and brands [M] as a thing of evil!"))
			M.emote("scream")
			M.changeStatus("weakened", 150)
			M.name_suffix("the Dracula")
			M.UpdateName()
			M.TakeDamage("chest", 0, 30)
			interrupt(INTERRUPT_ALWAYS)
			return

		var/done = world.time - started
		var/complete = max(min((done / duration), 1), 0)

		if (complete >= 0.2 && last_complete < 0.2)
			if (issilicon(target))
				boutput(target, __red("Coolant systems register decreased load near serial interface."))
			else
				boutput(target, __red("You feel a chill spreading out from your neck."))
			boutput(M, __blue("You continue to pump blood into [target]."))

		if (complete >= 0.4 && last_complete < 0.4)
			if (issilicon(target))
				boutput(target, __red("System temperature continues to decrease."))
			else
				boutput(target, __red("The cold spreads through your upper torso."))
			boutput(M, __blue("You continue to pump blood into [target]."))

		if (complete >= 0.6 && last_complete < 0.6)
			if (issilicon(target))
				boutput(target, __red("Low temperature region approaching memory core. Temperature variation may affect memory access!"))
			else
				boutput(target, __red("The icy cold spreads to your lower torso and arms."))
			boutput(M, __blue("You continue to pump blood into [target]."))

		if (complete >= 0.8 && last_complete < 0.8)
			if (!target.getStatusDuration("paralysis"))
				target.setStatus("paralysis", max(target.getStatusDuration("paralysis"), 100))
			if (issilicon(target))
				boutput(target, __red("Low temperature reggggggg92309392"))
				boutput(target, __red("<b>MEM ERR BLK 0  ADDR 30FC500 HAS 010F NOT 0000</b>"))
			else
				boutput(target, __red("The freezing cold envelops your entire body."))
			boutput(M, __blue("[target] has almost been enslaved."))

		last_complete = complete

	onEnd()
		..()

		var/mob/living/M = owner
		var/datum/abilityHolder/vampire/H = enslave.holder

		if (target.mind)
			target.mind.special_role = "vampthrall"
			target.mind.master = M.ckey
			if (!(target.mind in ticker.mode.Agimmicks))
				ticker.mode.Agimmicks += target.mind

		boutput(target, __red("<b>You awaken filled with purpose - you must serve your master, [M.real_name]!</B>"))

		target.delStatus("paralysis")
		if (istype(H)) H.vamp_isbiting = null
		target.vamp_beingbitten = 0

		boutput(M, __blue("[target] has been enslaved and is now your thrall."))
		logTheThing("combat", M, target, "enthralled [constructTarget(target,"combat")], making them a loyal mindslave at [log_loc(M)].")

	onInterrupt()
		..()

		var/mob/living/M = owner
		var/datum/abilityHolder/vampire/H = enslave.holder

		if (istype(H))
			H.vamp_isbiting = null

		if (target)
			target.vamp_beingbitten = 0
			if (!isdead(target))
				if (issilicon(target))
					boutput(target, __blue("System temperature appears to return to normal."))
				else
					boutput(target, __blue("The overwhelming feeling of coldness appears to recede. You immediately feel better."))

		boutput(M, __red("Your attempt to enthrall the target was interrupted!"))
*/

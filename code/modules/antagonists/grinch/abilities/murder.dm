/datum/action/bar/private/icon/grinchFlatline
	duration = 120
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "grinch_flatline"
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "devour_over"
	color_active = "#d73715"
	color_success = "#3fb54f"
	color_failure = "#8d1422"
	var/mob/living/target
	var/last_complete = 0
	New(Target)
		target = Target
		..()

	onUpdate()
		..()

		if(get_dist(owner, target) > 1 || target == null || owner == null )
			interrupt(INTERRUPT_ALWAYS)
			return

		var/mob/ownerMob = owner

		var/done = TIME - started
		var/complete = clamp((done / duration), 0, 1)
		if (complete >= 0.2 && last_complete < 0.2)
			ownerMob.visible_message(text("<span class='alert'><B>[ownerMob] makes a weird gesture at [target]!</B></span>"))

		if (complete > 0.6 && last_complete <= 0.6)
			ownerMob.visible_message(text("<span class='alert'><B>[ownerMob] starts shrinking [target]'s heart!</B></span>"))
			boutput(target, "<span class='alert'><B>You feel a sharp stabbing pain in your chest!</B></span>")

		last_complete = complete

	onStart()
		..()
		if(get_dist(owner, target) > 1 || target == null || owner == null )
			interrupt(INTERRUPT_ALWAYS)
			return

		var/mob/ownerMob = owner

		if (isliving(target))
			target:was_harmed(owner, special = "grinch")

		ownerMob.show_message("<span class='notice'>You are now inducing flatline in [target.real_name], you must hold still...</span>", 1)

	onEnd()
		..()

		var/mob/ownerMob = owner
		if(owner && ownerMob && target && get_dist(owner, target) <= 1)
			boutput(ownerMob, "<span class='notice'>You have successfully induced flatline!</span>")
			ownerMob.visible_message("<span class='alert'><b>[ownerMob] shrinks [target]'s heart down two sizes too small!</b></span>")
			playsound(target.loc, 'sound/impact_sounds/Flesh_Tear_1.ogg', 75, 1, -1)
			target.add_fingerprint(ownerMob) // Why not leave some forensic evidence?
			target.contract_disease(/datum/ailment/malady/flatline, null, null, 1) // path, name, strain, bypass resist
			//target.organHolder.drop_organ("heart") // a little trollin
		logTheThing("combat", ownerMob, target, "uses the murder ability to induce cardiac arrest on [constructTarget(target,"combat")] at [log_loc(ownerMob)].")

	onInterrupt()
		..()
		boutput(owner, "<span class='alert'>Your killing of [target] has been interrupted!</span>")

/datum/targetable/grinch/instakill
	name = "Murder"
	desc = "Induces cardiac arrest in a target. You and your target must hold still for this."
	targeted = 1
	target_anything = 0
	target_nodamage_check = 1
	max_range = 1
	cooldown = 4800
	start_on_cooldown = 0
	pointCost = 0
	when_stunned = 0
	not_when_handcuffed = 1

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner

		if (!M || !target || !ismob(target))
			return 1

		if (M == target)
			boutput(M, __red("Why would you want to kill yourself?"))
			return 1

		if (get_dist(M, target) > src.max_range)
			boutput(M, __red("[target] is too far away."))
			return 1

		if (isdead(target))
			boutput(M, __red("It would be a waste of time to murder the dead."))
			return 1

		if (!iscarbon(target))
			boutput(M, __red("[target] is immune to the disease."))
			return 1

		var/mob/living/L = target
		actions.start(new/datum/action/bar/private/icon/grinchFlatline(L), M)
		return 0

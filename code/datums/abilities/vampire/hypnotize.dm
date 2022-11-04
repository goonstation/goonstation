/datum/targetable/vampire/hypnotize
	name = "Hypnotize"
	desc = "KO's the target for a long time. Takes a few seconds to cast."
	icon_state = "hypno"
	targeted = 1
	target_nodamage_check = 1
	max_range = 2
	cooldown = 700
	pointCost = 0
	when_stunned = 0
	not_when_handcuffed = 0

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner
		var/datum/abilityHolder/vampire/H = holder

		if (!M || !target || !ismob(target))
			return 1

		if (M == target)
			boutput(M, "<span class='alert'>Why would you want to stun yourself?</span>")
			return 1

		if (GET_DIST(M, target) > src.max_range)
			boutput(M, "<span class='alert'>[target] is too far away.</span>")
			return 1

		if (isdead(target))
			boutput(M, "<span class='alert'>It would be a waste of time to stun the dead.</span>")
			return 1

		if (!isliving(target) || (isliving(target) && issilicon(target)))
			boutput(M, "<span class='alert'>This spell would have no effect on [target].</span>")
			return 1

		if (!M.sight_check(1))
			boutput(M, "<span class='alert'>How do you expect this to work? You can't use your eyes right now.</span>")
			M.visible_message("<span class='alert'>What was that? There's something odd about [M]'s eyes.</span>")
			if (istype(H)) H.blood_tracking_output(src.pointCost)
			return 1

		M.visible_message("<span class='alert'><B>[M] stares into [target]'s eyes!</B></span>")
		boutput(M, "<span class='alert'>You have to stand still...</span>")

		actions.start(new/datum/action/bar/icon/vamp_hypno(M,target,src), M)

		if (istype(H) && src.pointCost)
			H.blood_tracking_output(src.pointCost)

		if (isliving(target))
			target:was_harmed(M, special = "vamp")

		logTheThing(LOG_COMBAT, M, "uses hypnotise on [target ? "[constructTarget(target,"combat")]" : "*UNKNOWN*"] at [log_loc(M)].") // Target might have been gibbed, who knows.
		return 1


/datum/action/bar/icon/vamp_hypno
	duration = 40
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "vamp_hypno"
	icon = 'icons/ui/actions.dmi'
	icon_state = "hypno"
	bar_icon_state = "bar-vampire"
	border_icon_state = "border-vampire"
	color_active = "#b320c3"
	color_success = "#3fb54f"
	color_failure = "#8d1422"
	var/mob/living/carbon/human/M
	var/mob/living/carbon/human/target
	var/datum/targetable/vampire/hypnotize/hypno

	New(U,T,H)
		M = U
		target = T
		hypno = H
		..()

	onUpdate()
		..()
		if(hypno == null || GET_DIST(M, target) > hypno.max_range || M == null || target == null)
			interrupt(INTERRUPT_ALWAYS)
			boutput(M, "<span class='alert'>Your attempt to hypnotize the target was interrupted!</span>")
			return

	onStart()
		..()
		if(hypno == null || GET_DIST(M, target) > hypno.max_range || M == null || target == null)
			interrupt(INTERRUPT_ALWAYS)
			boutput(M, "<span class='alert'>Your attempt to hypnotize the target was interrupted!</span>")
			return

	onEnd()
		..()
		if (target.bioHolder && target.traitHolder.hasTrait("training_chaplain"))
			boutput(target, "<span class='notice'>Your faith protects you from [M]'s dark designs!</span>")
			JOB_XP(target, "Chaplain", 2)
			target.visible_message("<span class='alert'><b>[target] just stares right back at [M]!</b></span>")

		else if (target.sight_check(1)) // Can't stare through a blindfold very well, no?
			boutput(target, "<span class='alert'>Your consciousness is overwhelmed by [M]'s dark glare!</span>")
			boutput(M, "<span class='notice'>Your piercing gaze knocks out [target].</span>")
			target.changeStatus("stunned", 30 SECONDS)
			target.changeStatus("weakened", 30 SECONDS)
			target.changeStatus("paralysis", 30 SECONDS)
			target.remove_stamina(300)
			target.force_laydown_standup()

			var/obj/itemspecialeffect/glare/E = new /obj/itemspecialeffect/glare
			E.color = "#AA02FF"
			E.setup(target.loc)

		hypno.doCooldown()


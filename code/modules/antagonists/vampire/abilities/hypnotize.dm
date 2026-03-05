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

		if (!M || !target || !ismob(target))
			return 1

		if (M == target)
			boutput(M, SPAN_ALERT("Why would you want to stun yourself?"))
			return 1

		if (GET_DIST(M, target) > src.max_range)
			boutput(M, SPAN_ALERT("[target] is too far away."))
			return 1

		if (isdead(target))
			boutput(M, SPAN_ALERT("It would be a waste of time to stun the dead."))
			return 1

		if (!isliving(target) || (isliving(target) && issilicon(target)))
			boutput(M, SPAN_ALERT("This spell would have no effect on [target]."))
			return 1

		if (!M.sight_check(1))
			boutput(M, SPAN_ALERT("How do you expect this to work? You can't use your eyes right now."))
			M.visible_message(SPAN_ALERT("What was that? There's something odd about [M]'s eyes."))
			return 1

		. = ..()
		M.visible_message(SPAN_ALERT("<B>[M] stares into [target]'s eyes!</B>"))
		boutput(M, SPAN_ALERT("You have to stand still..."))

		actions.start(new/datum/action/bar/icon/vamp_hypno(M,target,src), M)

		if (isliving(target))
			target:was_harmed(M, special = "vamp")

		logTheThing(LOG_COMBAT, M, "uses hypnotise on [target ? "[constructTarget(target,"combat")]" : "*UNKNOWN*"] at [log_loc(M)].") // Target might have been gibbed, who knows.
		return 1


/datum/action/bar/icon/vamp_hypno
	duration = 40
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
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
			boutput(M, SPAN_ALERT("Your attempt to hypnotize the target was interrupted!"))
			return

	onStart()
		..()
		if(hypno == null || GET_DIST(M, target) > hypno.max_range || M == null || target == null)
			interrupt(INTERRUPT_ALWAYS)
			boutput(M, SPAN_ALERT("Your attempt to hypnotize the target was interrupted!"))
			return

	onEnd()
		..()
		if (target.bioHolder && target.traitHolder.hasTrait("training_chaplain"))
			boutput(target, SPAN_NOTICE("Your faith protects you from [M]'s dark designs!"))
			JOB_XP(target, "Chaplain", 2)
			target.visible_message(SPAN_ALERT("<b>[target] just stares right back at [M]!</b>"))

		else if (target.sight_check(1)) // Can't stare through a blindfold very well, no?
			boutput(target, SPAN_ALERT("Your consciousness is overwhelmed by [M]'s dark glare!"))
			boutput(M, SPAN_NOTICE("Your piercing gaze knocks out [target]."))
			target.changeStatus("stunned", 30 SECONDS)
			target.changeStatus("knockdown", 30 SECONDS)
			target.changeStatus("unconscious", 30 SECONDS)
			target.remove_stamina(300)
			target.force_laydown_standup()

			var/obj/itemspecialeffect/glare/E = new /obj/itemspecialeffect/glare
			E.color = "#AA02FF"
			E.setup(target.loc)

		hypno.doCooldown()

/// Upgraded hypnotize that starts working from range (unused)
/datum/targetable/vampire/sinister_gaze
	name = "Sinister Gaze"
	desc = "Draw someone closer to you and hypnotize them afterwards"
	icon_state = "hypno"
	targeted = 1
	target_nodamage_check = 1
	max_range = 10
	cooldown = 700
	pointCost = 0
	when_stunned = 0
	not_when_handcuffed = 0
	unlock_message = "You have gained Sinister Gaze, an upgrade to Hypnotize. Use on distant targets to draw them to you."

/datum/targetable/vampire/sinister_gaze/cast(mob/target)
	if (!holder)
		return 1

	var/mob/living/M = holder.owner

	if (!M || !target || !ismob(target))
		return 1

	if (M == target)
		boutput(M, SPAN_ALERT("Why would you want to gaze into yourself?"))
		return 1

	if (GET_DIST(M, target) > src.max_range)
		boutput(M, SPAN_ALERT("[target] is too far away."))
		return 1

	if (isdead(target))
		boutput(M, SPAN_ALERT("It would be a waste of time to gaze into the dead."))
		return 1

	if (!isliving(target) || (isliving(target) && issilicon(target)))
		boutput(M, SPAN_ALERT("This spell would have no effect on [target]."))
		return 1

	if (!M.sight_check(1))
		boutput(M, SPAN_ALERT("How do you expect this to work? You can't use your eyes right now."))
		M.visible_message(SPAN_ALERT("What was that? There's something odd about [M]'s eyes."))
		return 1

	. = ..()

	M.set_dir(get_dir(M, target))

	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		H.emote("stare", emoteTarget=target)
	boutput(M, SPAN_ALERT("You have to stand still..."))

	actions.start(new/datum/action/bar/icon/sinster_gaze(M,target,src), M)

	if (isliving(target))
		target:was_harmed(M, special = "vamp")

	logTheThing(LOG_COMBAT, M, "uses Sinister Gaze on [target ? "[constructTarget(target,"combat")]" : "*UNKNOWN*"] at [log_loc(M)].") // Target might have been gibbed, who knows.
	return 1

/datum/action/bar/icon/sinster_gaze
	duration = 80
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/ui/actions.dmi'
	icon_state = "hypno"
	bar_icon_state = "bar-vampire"
	border_icon_state = "border-vampire"
	color_active = "#b320c3"
	color_success = "#3fb54f"
	color_failure = "#8d1422"
	var/mob/living/carbon/human/M
	var/mob/living/carbon/human/target
	var/datum/targetable/vampire/sinister_gaze/gaze
	var/do_step = TRUE

	New(U,T,G)
		M = U
		target = T
		gaze = G
		..()

	proc/try_hypnotize()
		if (GET_DIST(M, target) > 1)
			return FALSE

		M.set_dir(get_dir(M, target))
		target.set_dir(get_dir(target, M))

		var/time_left = /datum/action/bar/icon/vamp_hypno::duration - src.time_spent()
		if (time_left > 0)
			interrupt(INTERRUPT_ALWAYS)
			var/datum/action/bar/icon/vamp_hypno/short_hypno = new /datum/action/bar/icon/vamp_hypno(M,target,gaze)
			short_hypno.duration = time_left
			actions.start(short_hypno, M)
			return TRUE

		if (target.bioHolder && target.traitHolder.hasTrait("training_chaplain"))
			boutput(target, SPAN_NOTICE("Your faith protects you from [M]'s dark designs!"))
			JOB_XP(target, "Chaplain", 2)
			target.visible_message(SPAN_ALERT("<b>[target] just stares right back at [M]!</b>"))
			return TRUE
		else if (target.sight_check(1)) // Can't stare through a blindfold very well, no?
			boutput(target, SPAN_ALERT("Your consciousness is overwhelmed by [M]'s dark glare!"))
			boutput(M, SPAN_NOTICE("Your piercing gaze knocks out [target]."))
			target.changeStatus("stunned", 30 SECONDS)
			target.changeStatus("knockdown", 30 SECONDS)
			target.changeStatus("unconscious", 30 SECONDS)
			target.remove_stamina(300)
			target.force_laydown_standup()

			var/obj/itemspecialeffect/glare/E = new /obj/itemspecialeffect/glare
			E.color = "#AA02FF"
			E.setup(target.loc)
			return TRUE
		return FALSE

	onUpdate()
		..()
		if(gaze == null || GET_DIST(M, target) > gaze.max_range || M == null || target == null || !target.sight_check(1))
			interrupt(INTERRUPT_ALWAYS)
			boutput(M, SPAN_ALERT("Your attempt to hypnotize the target was interrupted!"))
			gaze.doCooldown()
			return
		if(src.try_hypnotize())
			interrupt(INTERRUPT_ALWAYS)
			return
		if (do_step)
			step_towards(target, M)
		do_step = !do_step

	onStart()
		..()
		if(gaze == null || GET_DIST(M, target) > gaze.max_range || M == null || target == null || !target.sight_check(1))
			interrupt(INTERRUPT_ALWAYS)
			boutput(M, SPAN_ALERT("Your attempt to hypnotize the target was interrupted!"))
			gaze.doCooldown()
			return
		if (target.bioHolder && target.traitHolder.hasTrait("training_chaplain"))
			M.emote("blink")
			boutput(M, SPAN_ALERT("They don't seem swayed at all!"))
			interrupt(INTERRUPT_ALWAYS)
			return
		target.setStatusMin("entranced", src.duration)
		if(src.try_hypnotize())
			interrupt(INTERRUPT_ALWAYS)
			return
		boutput(target, SPAN_ALERT("You lock eyes with [M] and feel compelled..."))


	onEnd()
		target.delStatus("entranced")
		gaze.doCooldown()
		..()

/datum/statusEffect/entranced
	id = "entranced"
	name = "Entranced"
	desc = "You are entranced. Unable to turn away."
	unique = 1
	maxDuration = 30 SECONDS
	icon_state = "paralysis"
	var/original_m_intent

	onAdd(optional=null)
		. = ..()
		if (ismob(owner) && !QDELETED(owner))
			var/mob/mob_owner = owner
			APPLY_ATOM_PROPERTY(mob_owner, PROP_MOB_CANTMOVE, src.type)
			APPLY_ATOM_PROPERTY(mob_owner, PROP_MOB_CANTTURN, src.type)
			original_m_intent = mob_owner.m_intent
			mob_owner.set_m_intent("walk")
	onRemove()
		if (ismob(owner) && !QDELETED(owner))
			var/mob/mob_owner = owner
			REMOVE_ATOM_PROPERTY(mob_owner, PROP_MOB_CANTMOVE, src.type)
			REMOVE_ATOM_PROPERTY(mob_owner, PROP_MOB_CANTTURN, src.type)
			mob_owner.set_m_intent(original_m_intent)
		. = ..()

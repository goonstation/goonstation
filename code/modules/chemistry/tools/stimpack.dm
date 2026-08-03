/obj/item/storage/box/stimulants
	name = "stimulants box"
	desc = "A box containing 3 stimpacks. Use responsibly."
	spawn_contents = list(/obj/item/stimpack = 3)

/obj/item/stimpack
	name = "Stimpack"
	desc = "A single dose of incredibly strong stimulants."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "stims"
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_TINY
	object_flags = NO_GHOSTCRITTER
	var/empty = FALSE
	var/duration = 3 MINUTES

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if(empty)
			boutput(user, SPAN_ALERT("This stimpack is empty!"))
			return
		if(!isliving(target) || issilicon(target) || isintangible(target) || isrobocritter(target))
			boutput(user, SPAN_ALERT("You can't use this item on that!"))
			return
		if(user == target)
			src.stimulant_action(user, target)
			return
		else
			actions.start(new/datum/action/bar/icon/stimulant(target, src, src.icon, src.icon_state), user)
			return

	proc/stimulant_action(mob/user, mob/target)
		target.changeStatus("stimulants", src.duration)
		src.empty = TRUE
		src.icon_state = "stims0"
		logTheThing(LOG_COMBAT, user, "injects [constructTarget(target,"combat")] with stimulants at [log_loc(user)].")
		if(user == target)
			user.visible_message(SPAN_ALERT("[user.name] injects themselves with the [src.name]!"))
		else
			user.visible_message(SPAN_ALERT("[user.name] injects [target.name] with the [src.name]!"))
		boutput(target, SPAN_NOTICE("Ah! That's the stuff!"))


/obj/item/stimpack/large_dose
	duration = 15 MINUTES

/datum/action/bar/icon/stimulant
	duration = 3 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED
	var/mob/mob_owner
	var/mob/target
	var/obj/item/stimpack/S

	New(var/mob/target, var/item, var/icon, var/icon_state)
		..()
		src.target = target
		if (istype(item, /obj/item/stimpack))
			S = item
		else
			logTheThing(LOG_DEBUG, src, "/datum/action/bar/icon/stimulant called with invalid type [item].")
			return
		src.icon = icon
		src.icon_state = icon_state


	onStart()
		if (!isliving(owner))
			interrupt(INTERRUPT_ALWAYS)
			return

		src.mob_owner = owner
		logTheThing(LOG_COMBAT, mob_owner, "starts trying to inject a stimpack into [constructTarget(target)].")

		if(BOUNDS_DIST(owner, target) > 0 || !target || !owner || mob_owner.equipped() != S)
			interrupt(INTERRUPT_ALWAYS)
			return
		..()

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || !target || !owner || mob_owner.equipped() != S)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || !target || !owner || mob_owner.equipped() != S)
			interrupt(INTERRUPT_ALWAYS)
			return
		if (!isnull(S) && !S.empty)
			S.stimulant_action(owner, target)

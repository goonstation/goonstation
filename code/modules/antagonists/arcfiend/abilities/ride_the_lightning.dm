/**
 * This ability lets arcfiends travel through power cables like a Voltron (hence the type name).
 * Each tile traveled costs 3 units of power.
 */
/datum/targetable/arcfiend/voltron
	name = "Ride the Lightning"
	desc = "Expend energy to travel through electrical cables. \
		Remaining in this form will drain power over time, and each tile you travel will cost 3 units of energy.<br><br>\
		You must be standing above a power cable to initiate travel."
	icon_state = "voltron"
	cooldown = 1 SECONDS
	pointCost = 75
	container_safety_bypass = TRUE

	/// Whether or not we're using this ability.
	var/active = FALSE
	/// Each tile traveled will cost this many units of energy.
	var/step_cost = 3
	/// The user will be able to see all cables within this many tiles of their location.
	var/view_range = 2
	/// A cache of images for each cable.
	var/list/cable_images = null
	/// Dummy effect used to represent and hold the traveling mob.
	var/obj/dummy/voltron/dummy_holder = null

	New(datum/abilityHolder/holder)
		. = ..()
		var/obj/cable/ctype = /obj/cable
		var/cicon = initial(ctype.icon)

		// fill up the list with however many image object we're going to be using
		src.cable_images = new/list((view_range * 2 + 1) ** 2)
		for (var/i in 1 to length(src.cable_images))
			var/image/cimg = image(cicon)
			cimg.layer = 100
			cimg.plane = 100
			src.cable_images[i] = cimg

	cast(atom/target)
		. = ..()
		if (src.active)
			src.deactivate()
			return TRUE
		else
			var/turf/T = get_turf(src.holder.owner)
			if (!T.z || isrestrictedz(T.z))
				boutput(src.holder.owner, "<span class='alert'>You are forbidden from using that here!</span>")
				return TRUE
			if (T != src.holder.owner.loc) // See: no escaping port-a-brig
				boutput(src.holder.owner, "<span class='alert'>You cannot use this ability while inside [src.holder.owner.loc]!</span>")
				return TRUE
			if (!(locate(/obj/cable) in T))
				boutput(src.holder.owner, "<span class='alert'>You must use this ability on top of a cable!</span>")
				return TRUE
			playsound(src.holder.owner, 'sound/machines/ArtifactBee2.ogg', 30, TRUE, -2)
			actions.start(new/datum/action/bar/private/voltron(src), src.holder.owner)

	proc/activate()
		src.active = TRUE
		src.pointCost = 0
		var/atom/movable/screen/ability/topBar/B = src.object
		B.point_overlay.maptext = null
		src.handle_move()
		src.holder.owner.setStatus("ev_voltron", INFINITE_STATUS, list(holder, src))
		src.dummy_holder = new/obj/dummy/voltron(get_turf(src.holder.owner), src.holder.owner)
		RegisterSignals(src.dummy_holder, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_SET_LOC), .proc/handle_move)

	proc/handle_move()
		var/turf/user_turf = get_turf(src.holder.owner)
		if (isrestrictedz(user_turf.z) || is_incapacitated(src.holder.owner) || !src.holder.owner.client)
			src.deactivate(TRUE)
			return
		var/turf/T1 = locate(clamp((user_turf.x - view_range), 1, world.maxx), clamp((user_turf.y - view_range), 1, world.maxy), user_turf.z)
		var/turf/T2 = locate(clamp((user_turf.x + view_range), 1, world.maxx), clamp((user_turf.y + view_range), 1, world.maxy), user_turf.z)

		for (var/turf/T as anything in block(T1, T2))
			for (var/obj/cable/C in T)
				var/idx = ((C.y - user_turf.y + src.view_range) * src.view_range * 2) + (C.x - user_turf.x + src.view_range * 2) + 1
				var/image/img = src.cable_images[idx]
				img.appearance = C.appearance
				img.invisibility = 0
				img.alpha = 255
				img.layer = 100
				img.plane = 100
				img.loc = locate(C.x, C.y, C.z)

		src.holder.owner.client.images += src.cable_images
		src.holder.points = max((src.holder.points - step_cost), 0)
		src.holder.updateText()
		src.holder.updateButtons()
		if (!src.holder.points)
			deactivate(TRUE)

	proc/deactivate(force = FALSE)
		if (force)
			boutput(src.holder.owner, "<span class='alert'>You are ejected from the cable!</span>")
		else
			boutput(src.holder.owner, "<span class='notice'>You exit the cable.</span>")
		src.active = FALSE
		src.pointCost = initial(src.pointCost)
		var/atom/movable/screen/ability/topBar/B = src.object
		B.update_cooldown_cost()
		src.holder.owner.client?.images -= src.cable_images
		src.holder.owner.delStatus("ev_voltron")
		UnregisterSignal(src.dummy_holder, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_SET_LOC))
		qdel(src.dummy_holder)
		src.dummy_holder = null

/datum/action/bar/private/voltron
	duration = 1 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED | INTERRUPT_ACTION | INTERRUPT_ACT
	var/datum/targetable/arcfiend/voltron/abil

	New(abil)
		. = ..()
		src.abil = abil

	onEnd()
		. = ..()
		abil.activate()

/datum/statusEffect/ev_voltron
	id = "ev_voltron"
	name = "Ride the Lightning"
	desc = "You're expending energy to travel through electrical cables."
	icon_state = "empulsar"
	unique = TRUE
	maxDuration = null
	var/datum/abilityHolder/arcfiend/holder
	var/datum/targetable/arcfiend/voltron/ability

	onAdd(optional)
		. = ..()
		if (islist(optional))
			src.holder = optional[1]
			src.ability = optional[2]
		if (!istype(src.holder) || !istype(src.ability))
			src.owner.delStatus(id)

	onUpdate(timePassed)
		. = ..()
		if (!ON_COOLDOWN(src.owner, "ev_voltron", 1 SECOND))
			src.holder.points = max((src.holder.points - (timePassed)), 0)
			src.holder.updateText()
			src.holder.updateButtons()
			if (!src.holder.points)
				ability.deactivate()

/datum/targetable/arcfiend/voltron
	name = "Ride The Lightning"
	desc = "Expend energy to travel through electrical cables"
	icon_state = "voltron"
	cooldown = 1 SECONDS
	pointCost = 75
	var/active = FALSE
	var/view_range = 2
	var/list/cable_images = null
	var/obj/dummy/voltron/D = null
	var/step_cost = 3
	container_safety_bypass = TRUE

	New(datum/abilityHolder/holder)
		. = ..()
		var/obj/cable/ctype = /obj/cable
		var/cicon = initial(ctype.icon)

		// fill up the list with however many image object we're going to be using
		cable_images = new/list((view_range*2+1)**2)
		for(var/i in 1 to length(cable_images))
			var/image/cimg = image(cicon)
			cimg.layer = 100
			cimg.plane = 100
			cable_images[i] = cimg

	cast(atom/target)
		. = ..()
		if (active)
			deactivate()
		else
			var/turf/T = get_turf(holder.owner)
			if (!T.z || isrestrictedz(T.z))
				boutput(holder.owner, "<span class='alert'>You are forbidden from using that here!</span>")
				return TRUE
			if (T != holder.owner.loc) // See: no escaping port-a-brig
				boutput(holder.owner, "<span class='alert'>You cannot use this ability while inside [holder.owner.loc]!</span>")
				return TRUE
			if (!(locate(/obj/cable) in T))
				boutput(holder.owner, "<span class='alert'>You must use this ability on top of a cable!</span>")
				return TRUE
			playsound(holder.owner, "sound/machines/ArtifactBee2.ogg", 30, 1, -2)
			actions.start(new/datum/action/bar/private/voltron(src), holder.owner)

	proc/activate()
		active = TRUE
		handle_move()
		D = new/obj/dummy/voltron(get_turf(holder.owner), holder.owner)
		RegisterSignal(D, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_SET_LOC), .proc/handle_move)
		pointCost = 0
		var/atom/movable/screen/ability/topBar/B = src.object
		B.point_overlay.maptext = null
		holder.owner.setStatus("ev_voltron", INFINITE_STATUS, list(holder, src))

	proc/handle_move()
		var/turf/user_turf = get_turf(holder.owner)
		if (isrestrictedz(user_turf.z) || is_incapacitated(holder.owner))
			deactivate()
			active = FALSE
			return
		var/turf/T1 = locate(clamp((user_turf.x - view_range), 1, world.maxx), clamp((user_turf.y - view_range), 1, world.maxy), user_turf.z)
		var/turf/T2 = locate(clamp((user_turf.x + view_range), 1, world.maxx), clamp((user_turf.y + view_range), 1, world.maxy), user_turf.z)

		for(var/turf/T as anything in block(T1, T2))
			for(var/obj/cable/C in T)
				var/idx = ((C.y - user_turf.y + src.view_range) * src.view_range*2) + (C.x - user_turf.x + src.view_range*2) + 1
				var/image/img = cable_images[idx]
				img.appearance = C.appearance
				img.invisibility = 0
				img.alpha = 255
				img.layer = 100
				img.plane = 100
				img.loc = locate(C.x, C.y, C.z)

		send_images_to_client()
		holder.points = max((holder.points - step_cost), 0)
		if (!holder.points)
			deactivate()

	proc/deactivate()
		boutput(holder.owner, "<span class='alert'>You are ejected from the cable!</span>")
		active = FALSE
		var/atom/movable/screen/ability/topBar/B = src.object
		pointCost = initial(pointCost)
		B.update_cooldown_cost()

		UnregisterSignal(D, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_SET_LOC))
		src.holder.owner.client?.images -= cable_images
		qdel(D)
		D = null
		holder.owner.delStatus("ev_voltron")

	tryCast(atom/target, params)
		. = ..()
		//restore points cost when deactivating
		if(!pointCost) pointCost = initial(pointCost)

	proc/send_images_to_client()
		var/turf/T = get_turf(holder.owner)
		if ((!holder.owner?.client) || (!isalive(holder.owner)) || (isrestrictedz(T.z)))
			deactivate()
			return
		holder.owner.client.images += cable_images

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
	name = "Ride The Lightning"
	desc = "You're expending energy to travel through electrical cables"
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
			owner.delStatus(id)

	onUpdate(timePassed)
		. = ..()
		if (!ON_COOLDOWN(owner, "ev_voltron", 1 SECOND))
			src.holder.points = max((holder.points - (timePassed)), 0)
			if (!holder.points)
				ability.deactivate()

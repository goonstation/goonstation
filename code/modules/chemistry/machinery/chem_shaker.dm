TYPEINFO(/obj/machinery/chem_shaker)
	mats = 10

// A lot of boilerplate code from this is borrowed from `/obj/machinery/chem_heater`.
/obj/machinery/chem_shaker
	name = "\improper Orbital Shaker"
	desc = "A machine which continuously agitates beakers and flasks when activated."
	icon = 'icons/obj/shaker.dmi'
#ifdef IN_MAP_EDITOR
	icon_state = "orbital_shaker-map"
#else
	icon_state = "orbital_shaker"
#endif
	anchored = ANCHORED
	flags = NOSPLASH
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH
	pixel_y = 4

	var/list/obj/item/reagent_containers/glass/held_containers = list()
	var/obj/dummy/platform_holder
	var/list/first_container_offsets = list("X" = 0, "Y" = 8)
	var/list/container_offsets = list ("X" = 10, "Y" = -4)
	var/active = FALSE
	var/emagged = FALSE
	/// The arrangement of the containers on the platform in the X direction.
	var/container_row_length = 1
	/// Also acts as the number of containers in the Y direction when divided by `src.container_row_length`.
	var/max_containers = 1
	/// The time it takes for the platform to complete one orbit.
	var/orbital_period = 0.6 SECONDS
	/// Radius of the platform's orbit in pixels.
	var/radius = 2
	/// How much force does the shaker apply on `process()`?
	var/physical_shock_force = 5

	New()
		..()
		src.platform_holder = new()
		src.platform_holder.icon = src.icon
		src.platform_holder.icon_state = "[src.icon_state]-platform"
		src.platform_holder.vis_flags |= VIS_INHERIT_ID | VIS_INHERIT_LAYER | VIS_INHERIT_PLANE
		src.platform_holder.appearance_flags |= KEEP_TOGETHER
		src.vis_contents.Add(src.platform_holder)

	disposing()
		for (var/obj/item/reagent_containers/glass/glass_container in src.held_containers)
			MOVE_OUT_TO_TURF_SAFE(glass_container, src)
			src.held_containers -= glass_container
		UnsubscribeProcess()
		..()

	attack_hand(mob/user)
		if (!can_act(user)) return
		switch (src.active)
			if (TRUE)
				if (src.emagged)
					boutput(user, SPAN_ALERT("[src] refuses to shut off!"))
					return FALSE
				src.set_inactive()
			if (FALSE)
				src.set_active()
		boutput(user, SPAN_NOTICE("You [!src.active ? "de" : ""]activate [src]."))

	attackby(obj/item/reagent_containers/glass/glass_container, var/mob/user)
		if(istype(glass_container, /obj/item/reagent_containers/glass))
			src.try_insert(glass_container, user)

	emag_act(mob/user, obj/item/card/emag/E)
		if (!src.emagged)
			src.emagged = TRUE
			boutput(user, SPAN_ALERT("[src]'s safeties have been disabled."))
			src.set_active()
			return TRUE
		return FALSE

	ex_act(severity)
		switch (severity)
			if (1)
				qdel(src)
				return
			if (2)
				if (prob(50))
					qdel(src)
					return

	blob_act(power)
		if (prob(25 * power/20))
			qdel(src)

	meteorhit()
		qdel(src)
		return

	attack_ai(mob/user as mob)
		return src.Attackhand(user)

	process(mult)
		..()
		if (src.status & (NOPOWER|BROKEN)) return src.set_inactive()
		for (var/obj/item/reagent_containers/glass/glass_container in src.held_containers)
			if (src.emagged)
				src.remove_container(glass_container)
				glass_container.throw_at(pick(range(5, src)), 5, 1)
				continue
			glass_container.reagents?.physical_shock(src.physical_shock_force)

	proc/arrange_containers()
		if (!src.count_held_containers()) return
		for (var/i in 1 to length(src.held_containers))
			if (!src.held_containers[i]) continue
			var/current_y = ceil(i / src.container_row_length)
			var/current_x = i - (src.container_row_length * (current_y - 1))
			src.held_containers[i].pixel_x = src.first_container_offsets["X"] + ((current_x - 1) * src.container_offsets["X"])
			src.held_containers[i].pixel_y = src.first_container_offsets["Y"] + ((current_y - 1) *src.container_offsets["Y"])

	proc/count_held_containers()
		var/count_buffer = 0
		for (var/i in 1 to length(src.held_containers))
			if (src.held_containers[i])
				++count_buffer
		return count_buffer

	proc/set_active()
		src.active = TRUE
		src.power_usage = src.emagged ? 1000 : 200
		animate_orbit(src.platform_holder, radius = src.radius, time = src.emagged ? src.orbital_period / 5 : src.orbital_period, loops = -1)
		if (src.emagged)
			src.audible_message(SPAN_ALERT("[src] is rotating a bit too fast!"))
		else
			src.audible_message(SPAN_NOTICE("[src] whirs to life, rotating its platform!"))
		if (!(src in processing_machines))
			SubscribeToProcess()

	proc/set_inactive()
		src.active = FALSE
		src.power_usage = 0
		animate(src.platform_holder, pixel_x = 0, pixel_y = 0, time = src.orbital_period/2, easing = SINE_EASING, flags = ANIMATION_LINEAR_TRANSFORM)
		src.audible_message(SPAN_NOTICE("[src] dies down, returning its platform to its initial position."))
		UnsubscribeProcess()

	proc/try_insert(obj/item/reagent_containers/glass/glass_container, var/mob/user)
		if (src.status & (NOPOWER|BROKEN))
			user.show_text("[src] seems to be out of order.", "red")
			return

		if (src.count_held_containers() >= src.max_containers)
			boutput(user, SPAN_ALERT("There's too many beakers on the platform already!"))
			return

		if (isrobot(user))
			boutput(user, "Robot beakers won't work with this!")
			return

		user.drop_item(glass_container)
		glass_container.set_loc(src)
		glass_container.appearance_flags |= RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
		glass_container.vis_flags |= VIS_INHERIT_PLANE | VIS_INHERIT_LAYER
		glass_container.event_handler_flags |= NO_MOUSEDROP_QOL
		var/append_container = TRUE
		for (var/i in 1 to length(src.held_containers))
			if (!src.held_containers[i])
				src.held_containers[i] = glass_container
				append_container = FALSE
				break
		if (append_container)
			src.held_containers += glass_container
		src.platform_holder.vis_contents += glass_container
		src.arrange_containers()
		RegisterSignal(glass_container, COMSIG_ATTACKHAND, PROC_REF(remove_container))
		boutput(user, "You add the beaker to the machine!")

	proc/remove_container(obj/item/reagent_containers/glass/glass_container)
		if (!(glass_container in src.contents)) return
		for (var/i in 1 to length(src.held_containers))
			if (src.held_containers[i] == glass_container)
				src.held_containers[i] = null
		MOVE_OUT_TO_TURF_SAFE(glass_container, src)
		glass_container.appearance_flags = initial(glass_container.appearance_flags)
		glass_container.vis_flags = initial(glass_container.vis_flags)
		glass_container.event_handler_flags = initial(glass_container.event_handler_flags)
		src.platform_holder.vis_contents -= glass_container
		src.arrange_containers()
		UnregisterSignal(glass_container, COMSIG_ATTACKHAND)

	chemistry
		icon = 'icons/obj/shaker_chem.dmi'

TYPEINFO(/obj/machinery/chem_shaker/large)
	mats = 25
/obj/machinery/chem_shaker/large
	name = "large orbital shaker"
	icon_state = "orbital_shaker_large"
	max_containers = 4
	container_row_length = 2
	first_container_offsets = list("X" = -5, "Y" = 9)

	chemistry
		icon = 'icons/obj/shaker_chem.dmi'

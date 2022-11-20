///Ping component, for highlighting something to the flock
/datum/component/flock_ping
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/duration = 5 SECOND
	var/end_time = -1
	var/obj/dummy = null
	var/outline_color = "#00ff9d"
	var/outline_thickness = 1
	var/animate = TRUE
	var/plane = PLANE_FLOCKVISION

	Initialize()
		if (!ismovable(parent) && !isturf(parent))
			return COMPONENT_INCOMPATIBLE

	RegisterWithParent()
		//this cast looks horribly unsafe, but we've guaranteed that parent is a type with vis_contents in Initialize
		var/atom/movable/target = parent

		src.end_time = TIME + duration

		dummy = new()
		dummy.layer = target.layer
		dummy.plane = src.plane
		dummy.invisibility = INVIS_FLOCK
		dummy.appearance_flags = PIXEL_SCALE | RESET_TRANSFORM | RESET_COLOR | PASS_MOUSE
		dummy.icon = target.icon
		dummy.icon_state = target.icon_state
		target.render_target = ref(parent)
		dummy.render_source = target.render_target
		dummy.add_filter("outline", 1, outline_filter(size=src.outline_thickness,color=src.outline_color))
		if (isturf(target))
			dummy.add_filter("mask", 2, alpha_mask_filter(icon=dummy.icon, flags=MASK_INVERSE))
		target.vis_contents += dummy

		if (src.animate)
			play_animation()

		if (src.duration == INFINITY)
			return

		SPAWN(0)
			while(TIME < src.end_time)
				var/delta = src.end_time - TIME
				sleep(min(src.duration, delta))
			qdel(src)

	//when a new ping component is added, reset the original's duration
	InheritComponent(datum/component/flock_ping/C, i_am_original)
		if (i_am_original)
			play_animation()
			src.end_time = TIME + duration

	disposing()
		qdel(dummy)
		. = ..()

	proc/play_animation()
		animate(dummy, time = duration/9, alpha = 100)
		for (var/i in 1 to 4)
			animate(time = duration/9, alpha = 255)
			animate(time = duration/9, alpha = 100)

///Used to mark objects blocking the construction of a flock tealprint
/datum/component/flock_ping/obstruction
	outline_color = "#910707"

/datum/component/flock_ping/selected
	animate = FALSE
	outline_thickness = 3
	duration = INFINITY

/datum/component/flock_ping/tutorial_highlight
	outline_thickness = 2
	duration = INFINITY
	//render above HUD
	plane = PLANE_SCREEN_OVERLAYS

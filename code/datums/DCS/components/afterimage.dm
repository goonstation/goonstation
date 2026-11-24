/datum/component/afterimage
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/delay
	var/list/obj/afterimage/afterimages
	var/afterimage_type = /obj/afterimage
	var/list/afterimage_args

TYPEINFO(/datum/component/afterimage)
	initialization_args = list(
		ARG_INFO("count", DATA_INPUT_NUM, "Number of afterimages", 10),
		ARG_INFO("delay", DATA_INPUT_NUM, "Time delay in-between afterimages' movements", 0.1 SECONDS)
	)

/datum/component/afterimage/Initialize(count=10, delay=0.1 SECONDS)
	..()
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	src.delay = delay
	src.afterimages = list()
	src.set_afterimage_args()
	if(count > 1)
		for(var/i = 1 to count)
			var/obj/afterimage/afterimage = new afterimage_type(arglist(afterimage_args))
			afterimage.correct_alpha = 200 - 100 * (i - 1) / (count - 1)
			afterimages += afterimage
	else
		var/obj/afterimage/afterimage = new afterimage_type(arglist(afterimage_args))
		afterimage.correct_alpha = 100
		afterimages += afterimage
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(move))
	RegisterSignal(parent, COMSIG_MOVABLE_SET_LOC, PROC_REF(move))
	RegisterSignal(parent, COMSIG_ATOM_DIR_CHANGED, PROC_REF(change_dir))
	RegisterSignal(parent, COMSIG_MOVABLE_THROW_END, PROC_REF(throw_end))

/datum/component/afterimage/RegisterWithParent()
	for(var/obj/afterimage/afterimage in src.afterimages)
		afterimage.active = TRUE
	src.sync_afterimages()

/datum/component/afterimage/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_SET_LOC, COMSIG_ATOM_DIR_CHANGED, COMSIG_MOVABLE_THROW_END))
	for(var/obj/afterimage/afterimage in src.afterimages)
		afterimage.active = FALSE
		afterimage.set_loc(null)
	. = ..()

/datum/component/afterimage/disposing()
	if(length(src.afterimages))
		for(var/obj/afterimage/afterimage in src.afterimages)
			qdel(afterimage)
		src.afterimages.Cut()
		src.afterimages = null
	. = ..()

/datum/component/afterimage/proc/set_afterimage_args()
	afterimage_args = list(null)

/datum/component/afterimage/proc/change_dir(atom/movable/AM, new_dir, old_dir)
	src.sync_afterimages(new_dir)

/datum/component/afterimage/proc/set_loc(atom/movable/AM, atom/last_loc)
	return src.move(AM, last_loc, AM.dir)

/datum/component/afterimage/proc/move(atom/movable/AM, turf/last_turf, direct)
	src.sync_afterimages()

/datum/component/afterimage/proc/throw_end(atom/movable/AM, datum/thrown_thing/thr)
	src.sync_afterimages() // necessary to fix pixel_x and pixel_y

/datum/component/afterimage/proc/sync_afterimages(dir_override=null)
	set waitfor = FALSE
	var/obj/afterimage/target_state = new afterimage_type(arglist(afterimage_args))
	target_state.active = TRUE
	target_state.sync_with_parent(parent)
	target_state.loc = null
	if(!isnull(dir_override))
		target_state.set_dir(dir_override)
	var/atom/movable/parent_am = parent
	var/atom/target_loc = parent_am.loc
	for(var/obj/afterimage/afterimage in src.afterimages)
		sleep(src.delay)
		afterimage.sync_with_parent(target_state, target_loc)
	qdel(target_state)




/obj/afterimage
	mouse_opacity = FALSE
	plane = PLANE_NOSHADOW_BELOW
	anchored = ANCHORED_ALWAYS
	var/correct_alpha = 120
	var/appearance_ref = null
	var/active = FALSE

/obj/afterimage/New()
	. = ..()
	animate(src, pixel_x=0, time=1, flags=ANIMATION_PARALLEL, loop=-1)
	var/count = rand(5, 10)
	for(var/i = 1 to count)
		var/time = 0.5 SECONDS + rand() * 3 SECONDS
		var/pixel_x = i == count ? 0 : rand(-2, 2)
		var/pixel_y = i == count ? 0 : rand(-2, 2)
		animate(time=time, easing=pick(LINEAR_EASING, SINE_EASING, CIRCULAR_EASING, CUBIC_EASING), pixel_x=pixel_x, pixel_y=pixel_y, loop=-1)

/obj/afterimage/proc/sync_with_parent(atom/movable/parent, loc_override=null)
	if(!src.active)
		return
	src.name = parent.name
	src.desc = parent.desc
	src.glide_size = parent.glide_size
	var/parent_appearance_ref = ref(parent.appearance)
	if(istype(parent, /obj/afterimage))
		var/obj/afterimage/parent_afterimage = parent
		parent_appearance_ref = parent_afterimage.appearance_ref
	if(src.appearance_ref != parent_appearance_ref)
		src.appearance_ref = parent_appearance_ref
		src.appearance = parent.appearance
		src.alpha = src.alpha / 255.0 * src.correct_alpha
		src.plane = initial(src.plane)
		src.mouse_opacity = initial(src.mouse_opacity)
		src.anchored = initial(src.anchored)
	var/atom/target_loc = loc_override ? loc_override : parent.loc
	if(target_loc != src.loc)
		src.set_loc(target_loc)
	if(src.dir != parent.dir)
		src.set_dir(parent.dir)

/obj/afterimage/disposing()
	src.active = FALSE
	. = ..()

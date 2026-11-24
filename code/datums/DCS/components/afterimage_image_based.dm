TYPEINFO(/datum/component/afterimage/image_based)
	initialization_args = list(
		ARG_INFO("count", DATA_INPUT_NUM, "Number of afterimages", 10),
		ARG_INFO("delay", DATA_INPUT_NUM, "Time delay in-between afterimages' movements", 0.1 SECONDS),
		ARG_INFO("owner", DATA_INPUT_REF, "ref of mob that can see the afterimages", null)
	)

/datum/component/afterimage/image_based
	afterimage_type = /obj/afterimage/image_based
	var/mob/owner

/datum/component/afterimage/image_based/Initialize(count, delay, owner)
	src.owner = owner
	if(..() == COMPONENT_INCOMPATIBLE)
		return COMPONENT_INCOMPATIBLE
	if(src.owner.client)
		RegisterSignal(owner, COMSIG_MOB_LOGOUT, PROC_REF(drop_images))
	RegisterSignal(owner, COMSIG_MOB_LOGIN, PROC_REF(new_owner))

/datum/component/afterimage/image_based/set_afterimage_args()
	src.afterimage_args = list(null, owner)

/datum/component/afterimage/image_based/proc/drop_images()
	if(owner.last_client)
		for(var/obj/afterimage/image_based/AI in afterimages)
			owner.last_client -= AI
	UnregisterSignal()

/datum/component/afterimage/image_based/proc/new_owner()
	RegisterSignal(owner, COMSIG_MOB_LOGOUT, PROC_REF(drop_images))

/datum/component/afterimage/image_based/UnregisterFromParent()
	drop_images()
	. = ..()
	UnregisterSignal(owner, list(COMSIG_MOB_LOGOUT, COMSIG_MOB_LOGIN))



/obj/afterimage/image_based
	var/image/myimage

/obj/afterimage/image_based/New(loc, mob/owner)
	. = ..()
	myimage = image(src, src)
	myimage.override = 1
	owner << src.myimage

/obj/afterimage/image_based/sync_with_parent(atom/movable/parent, loc_override=null)
	if(!src.active)
		return
	src.name = parent.name
	src.desc = parent.desc
	src.glide_size = parent.glide_size
	var/parent_appearance_ref = ref(parent.appearance)
	if(istype(parent, /obj/afterimage))
		var/obj/afterimage/image_based/parent_afterimage = parent
		parent_appearance_ref = parent_afterimage.appearance_ref
	if(src.appearance_ref != parent_appearance_ref)
		src.appearance_ref = parent_appearance_ref
		if(istype(parent, /obj/afterimage))
			var/obj/afterimage/image_based/A = parent
			src.myimage.appearance = A.myimage.appearance
		else
			src.myimage.appearance = parent.appearance
		src.myimage.alpha = src.myimage.alpha / 255.0 * src.correct_alpha
		src.plane = initial(src.plane)
		src.mouse_opacity = initial(src.mouse_opacity)
		src.anchored = initial(src.anchored)
	var/atom/target_loc = loc_override ? loc_override : parent.loc
	if(target_loc != src.loc)
		src.set_loc(target_loc)
	if(myimage.dir != parent.dir)
		src.set_dir(parent.dir)

/obj/afterimage/image_based/set_dir(new_dir)
	. = ..()
	src.myimage.dir = src.dir

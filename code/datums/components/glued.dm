TYPEINFO(/datum/component/glued)
	initialization_args = list(
		ARG_INFO("target", "ref", "What is this glued to", null),
		ARG_INFO("glue_duration", "num", "How long the glue lasts, null for infinity", null),
		ARG_INFO("glue_removal_time", "num", "How long does it take to unglue stuff", null),
	)

/datum/component/glued
	var/dries_up_timestamp
	var/glue_removal_time
	var/original_animate_movement
	var/original_anchored
	var/atom/glued_to

/datum/component/glued/Initialize(atom/target, glue_duration=null, glue_removal_time=null)
	if(!istype(src.parent, /atom/movable))
		return COMPONENT_INCOMPATIBLE
	src.glued_to = target
	RegisterSignal(glued_to, COMSIG_PARENT_PRE_DISPOSING, .proc/delete_self)
	src.dries_up_timestamp = glue_duration ? TIME + glue_duration : null
	src.glue_removal_time = glue_removal_time
	var/atom/movable/parent = src.parent
	parent.add_filter("glued_outline", 0, outline_filter(size=1, color="#e6e63c44"))
	if(glue_duration != null)
		SPAWN(glue_duration)
			dry_up()
	if(ismovable(glued_to))
		var/atom/movable/glued_to = src.glued_to
		LAZYLISTADDUNIQUE(glued_to.attached_objs, parent)
		glued_to.vis_contents += parent
	if(isitem(parent) && ismob(parent.loc))
		var/mob/parent_holder = parent.loc
		var/obj/item/item_parent = parent
		parent_holder.u_equip(parent)
		item_parent.dropped(parent_holder)
	parent.set_loc(isturf(glued_to) ? glued_to : glued_to.loc)
	src.original_animate_movement = parent.animate_movement
	src.original_anchored = parent.anchored
	parent.animate_movement = SYNC_STEPS
	parent.anchored = TRUE
	parent.layer = OBJ_LAYER
	if(isturf(glued_to))
		parent.plane = PLANE_DEFAULT
	else
		parent.plane = PLANE_UNDERFLOOR
	parent.vis_flags |= VIS_INHERIT_PLANE | VIS_INHERIT_LAYER
	RegisterSignal(parent, COMSIG_ATTACKHAND, .proc/start_ungluing)

/datum/component/glued/proc/delete_self()
	qdel(src)

/datum/component/glued/proc/dry_up()
	if(src.disposed || !src.parent || src.parent.disposed || !glued_to || glued_to.disposed)
		return
	var/atom/movable/parent = src.parent
	var/turf/T = get_turf(parent)
	T.visible_message("<span class='notice'>The glue on [parent] dries up and it falls off from [glued_to].</span>")
	qdel(src)

/datum/component/glued/proc/start_ungluing(atom/movable/parent, mob/user)
	if(isnull(src.glue_removal_time))
		boutput(user, "<span class='alert'>You try to unglue [parent] from [src.glued_to] but the glue is too strong.</span>")
		return
	var/turf/T = get_turf(parent)
	T.visible_message("<span class='notice'>[user] starts ungluing [parent] from [src.glued_to].</span>")
	actions.start(
		new /datum/action/bar/icon/callback(user, parent, src.glue_removal_time, .proc/delete_self, null, parent.icon, parent.icon_state,\
		"<span class='notice'>[user] manages to unglue [parent] from [src.glued_to].</span>", 0, src), user)

/datum/component/glued/UnregisterFromParent()
	var/atom/movable/parent = src.parent
	parent.remove_filter("glued_outline")
	parent.animate_movement = src.original_animate_movement
	parent.anchored = src.original_anchored
	parent.layer = initial(parent.layer)
	parent.plane = initial(parent.plane)
	parent.vis_flags &= ~(VIS_INHERIT_PLANE | VIS_INHERIT_LAYER)
	if(ismovable(glued_to))
		var/atom/movable/glued_to = src.glued_to
		glued_to.attached_objs -= parent
		glued_to.vis_contents -= parent
	parent.set_loc(get_turf(parent))
	src.glued_to = null
	. = ..()

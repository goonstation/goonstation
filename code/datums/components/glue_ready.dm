TYPEINFO(/datum/component/glue_ready)
	initialization_args = list(
		ARG_INFO("glue_duration", "num", "How long the glue lasts, null for infinity", null),
		ARG_INFO("glue_removal_time", "num", "How long does it take to unglue stuff", null),
	)

/datum/component/glue_ready
	var/dries_up_timestamp
	var/glue_removal_time

/datum/component/glue_ready/Initialize(glue_duration=null, glue_removal_time=null)
	if(!istype(src.parent, /atom/movable))
		return COMPONENT_INCOMPATIBLE
	if(src.parent.GetComponent(/datum/component/glued))
		return COMPONENT_INCOMPATIBLE
	src.dries_up_timestamp = glue_duration ? TIME + glue_duration : null
	src.glue_removal_time = glue_removal_time
	var/atom/movable/parent = src.parent
	parent.add_filter("glue_ready_outline", 0, outline_filter(size=1, color="#e6e63c44"))
	if(glue_duration != null)
		SPAWN(glue_duration)
			dry_up()
	RegisterSignal(parent, COMSIG_ATTACKBY, .proc/glue_thing_to_parent)
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, .proc/glue_parent_to_thing) // won't do anything if not an item but it doesn't hurt

/datum/component/glue_ready/proc/dry_up()
	if(src.disposed || !src.parent || src.parent.disposed)
		return
	var/turf/T = get_turf(parent)
	T.visible_message("<span class='notice'>The glue on [parent] dries up.</span>")
	qdel(src)

/datum/component/glue_ready/UnregisterFromParent()
	var/atom/movable/parent = src.parent
	parent.remove_filter("glue_ready_outline")
	. = ..()

/datum/component/glue_ready/proc/gluability_check(atom/movable/glued_to, obj/item/thing_glued, mob/user)
	if(thing_glued.cant_drop)
		boutput(user, "<span class='alert'>You can't glue [thing_glued] to stuff.</span>")
		return FALSE
	if(isitem(glued_to))
		var/obj/item/item_glued_to = glued_to
		if(item_glued_to.w_class < thing_glued.w_class)
			boutput(user, "<span class='alert'>[thing_glued] is too large to be glued to the smaller [glued_to].</span>")
			return FALSE
	return TRUE

/datum/component/glue_ready/proc/glue_thing_to_parent(atom/movable/parent, obj/item/item, mob/user)
	if(!gluability_check(parent, item, user))
		return
	item.AddComponent(/datum/component/glued, parent, src.dries_up_timestamp - TIME, src.glue_removal_time)
	var/turf/T = get_turf(parent)
	T.visible_message("<span class='notice'>[user] glues [item] to [parent].</span>")
	qdel(src)

/datum/component/glue_ready/proc/glue_parent_to_thing(obj/item/parent, atom/target, mob/user, reach, params)
	if(isnull(target))
		return
	if(!can_reach(user, target))
		return
	if(istype(target, /obj/fluid) || istype(target, /obj/effect))
		target = get_turf(target)
	if(!gluability_check(target, parent, user))
		return
	parent.AddComponent(/datum/component/glued, target, src.dries_up_timestamp - TIME, src.glue_removal_time)
	if("icon-x" in params)
		parent.pixel_x = text2num(params["icon-x"]) - world.icon_size / 2
		parent.pixel_y = text2num(params["icon-y"]) - world.icon_size / 2
	var/turf/T = get_turf(target)
	T.visible_message("<span class='notice'>[user] glues [parent] to [target].</span>")
	qdel(src)

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
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, .proc/glue_parent_to_thing_afterattack) // won't do anything if not an item but it doesn't hurt
	RegisterSignal(parent, COMSIG_ATOM_HITBY_THROWN, .proc/glue_thing_to_parent)
	RegisterSignal(parent, COMSIG_MOVABLE_HIT_THROWN, .proc/glue_parent_to_thing_hit_thrown)

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

/datum/component/glue_ready/proc/gluability_check(atom/movable/glued_to, atom/movable/thing_glued, mob/user)
	if(isnull(glued_to) || isnull(thing_glued))
		return FALSE
	if(istype(glued_to)) // ended up on a nonactive sticker in the sticker loc chain, still need to prevent implanting
		if(user)
			boutput(user, "<span class='alert'>You can't glue things to a sticker.</span>")
		return FALSE
	var/obj/item/item_glued = thing_glued
	ENSURE_TYPE(item_glued)
	if(thing_glued.anchored || item_glued?.cant_drop)
		if(user)
			boutput(user, "<span class='alert'>You can't glue [thing_glued] to stuff.</span>")
		return FALSE
	if(istype(thing_glued, /obj/storage))
		return FALSE
	if(isitem(glued_to))
		var/obj/item/item_glued_to = glued_to
		if(!isitem(thing_glued) || item_glued_to.w_class < item_glued.w_class)
			if(user)
				boutput(user, "<span class='alert'>[thing_glued] is too large to be glued to the smaller [glued_to].</span>")
			return FALSE
	if(istype(glued_to, /obj/window))
		if(user)
			boutput(user, "<span class='alert'>[thing_glued] slids off the smooth window without adhering to it.</span>")
		return FALSE
	return TRUE

/datum/component/glue_ready/proc/glue_things(atom/movable/glued_to, atom/movable/thing_glued, mob/user=null)
	var/obj/item/sticker/maybe_sticker = glued_to
	while(istype(maybe_sticker) && maybe_sticker.active) // prevent implanting items via gluing onto stickers attached to a thing
		glued_to = maybe_sticker.loc
		maybe_sticker = glued_to
	if(!gluability_check(glued_to, thing_glued, user))
		return
	thing_glued.AddComponent(/datum/component/glued, glued_to, src.dries_up_timestamp - TIME, src.glue_removal_time)
	var/turf/T = get_turf(glued_to)
	if(user)
		T.visible_message("<span class='notice'>[user] glues [thing_glued] to [glued_to].</span>")
	else
		T.visible_message("<span class='notice'>[thing_glued] sticks to [glued_to].</span>")
	qdel(src)

/datum/component/glue_ready/proc/glue_thing_to_parent(atom/movable/parent, obj/item/item, mob/user)
	ENSURE_TYPE(user)
	glue_things(parent, item, user)
	return TRUE

/datum/component/glue_ready/proc/glue_parent_to_thing_afterattack(obj/item/parent, atom/target, mob/user, reach, params)
	if(isnull(target))
		return
	if(!can_reach(user, target))
		return
	if(istype(target, /obj/fluid) || istype(target, /obj/effect))
		target = get_turf(target)
	glue_things(target, parent, user)
	if("icon-x" in params)
		parent.pixel_x = text2num(params["icon-x"]) - world.icon_size / 2
		parent.pixel_y = text2num(params["icon-y"]) - world.icon_size / 2

/datum/component/glue_ready/proc/glue_parent_to_thing_hit_thrown(obj/item/parent, atom/target)
	if(isnull(target))
		return
	if(isfloor(target))
		return
	if(istype(target, /obj/fluid) || istype(target, /obj/effect))
		target = get_turf(target)
	glue_things(target, parent, null)
	return TRUE

TYPEINFO(/datum/component/glue_ready)
	initialization_args = list(
		ARG_INFO("glue_duration", DATA_INPUT_NUM, "How long the glue lasts, null for infinity", null),
		ARG_INFO("glue_removal_time", DATA_INPUT_NUM, "How long does it take to unglue stuff", null),
	)

/datum/component/glue_ready
	var/dries_up_timestamp
	var/glue_removal_time

/datum/component/glue_ready/Initialize(glue_duration=null, glue_removal_time=null)
	. = ..()
	if(!istype(src.parent, /atom/movable))
		return COMPONENT_INCOMPATIBLE
	if(src.parent.GetComponent(/datum/component/glued))
		return COMPONENT_INCOMPATIBLE
	src.dries_up_timestamp = glue_duration ? TIME + glue_duration : null
	src.glue_removal_time = glue_removal_time
	var/atom/movable/parent = src.parent
	parent.add_filter("glue_ready_outline", 0, outline_filter(size=1, color="#e6e63c44"))
	delayed_dry_up(glue_duration)
	RegisterSignal(parent, COMSIG_ATTACKBY, PROC_REF(glue_thing_to_parent))
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, PROC_REF(glue_parent_to_thing_afterattack)) // won't do anything if not an item but it doesn't hurt
	RegisterSignal(parent, COMSIG_ATOM_HITBY_THROWN, PROC_REF(glue_thing_to_parent))
	RegisterSignal(parent, COMSIG_MOVABLE_HIT_THROWN, PROC_REF(glue_parent_to_thing_hit_thrown))

/datum/component/glue_ready/proc/delayed_dry_up(glue_duration)
	set waitfor = FALSE
	if(glue_duration != null)
		sleep(glue_duration)
		dry_up()

/datum/component/glue_ready/proc/dry_up()
	if(src.disposed || !src.parent || src.parent.disposed)
		return
	var/turf/T = get_turf(parent)
	T?.visible_message(SPAN_NOTICE("The glue on [parent] dries up."))
	qdel(src)

/datum/component/glue_ready/UnregisterFromParent()
	var/atom/movable/parent = src.parent
	UnregisterSignal(parent, list(COMSIG_ATTACKBY, COMSIG_ITEM_AFTERATTACK, COMSIG_ATOM_HITBY_THROWN, COMSIG_MOVABLE_HIT_THROWN))
	parent.remove_filter("glue_ready_outline")
	. = ..()

/datum/component/glue_ready/proc/gluability_check(atom/movable/glued_to, atom/movable/thing_glued, mob/user)
	if(isnull(glued_to) || isnull(thing_glued))
		return FALSE
	if(!isnull(user) && thing_glued.loc != user) // if attackby inserted an organ into a person or stacked sheets etc.
		return FALSE
	if(glued_to.invisibility >= INVIS_ALWAYS_ISH || thing_glued.invisibility >= INVIS_ALWAYS_ISH)
		return FALSE
	if(istype(glued_to, /obj/item/sticker)) // ended up on a nonactive sticker in the sticker loc chain, still need to prevent implanting
		if(user)
			boutput(user, SPAN_ALERT("You can't glue things to a sticker."))
		return FALSE
	var/obj/item/item_glued = thing_glued
	ENSURE_TYPE(item_glued)
	if(thing_glued.anchored || item_glued?.cant_drop)
		if(user)
			boutput(user, SPAN_ALERT("You can't glue [thing_glued] to stuff."))
		return FALSE
	if(istype(thing_glued, /obj/storage) || isgrab(thing_glued) || isgrab(glued_to) || istype(thing_glued, /obj/item/dummy) | istype(glued_to, /obj/item/dummy))
		return FALSE
	if(isitem(glued_to))
		var/obj/item/item_glued_to = glued_to
		if(!isitem(thing_glued) || item_glued_to.w_class < item_glued.w_class)
			if(user)
				boutput(user, SPAN_ALERT("[thing_glued] is too large to be glued to the smaller [glued_to]."))
			return FALSE
	if(istype(glued_to, /obj/window))
		if(user)
			boutput(user, SPAN_ALERT("[thing_glued] slids off the smooth window without adhering to it."))
		return FALSE
	if(istype(glued_to, /obj/machinery/door) || istype(glued_to, /obj/mesh/grille))
		return FALSE
	if(istype(glued_to, /mob/dead) || istype(glued_to, /mob/living/intangible) )
		if(user)
			boutput(user, SPAN_ALERT("Your hand with [thing_glued] passes straight through \the [glued_to]."))
		return FALSE
	if(istype(thing_glued, /obj/artifact) || istype(thing_glued, /obj/machinery/artifact))
		if(user)
			boutput(user, SPAN_ALERT("The alien energies of [thing_glued] evaporate the glue."))
		return FALSE
	if(istype(thing_glued, /obj/machinery/nuclearbomb))
		if(user)
			boutput(user, SPAN_ALERT("\The [glued_to]'s radiation dissolves the glue."))
		qdel(src)
		return FALSE
	if(istype(glued_to, /mob/living/critter) && !isitem(thing_glued))
		if(user)
			boutput(user, SPAN_ALERT("You can only glue items to [glued_to]."))
		return FALSE
	if(istype(thing_glued, /obj/machinery/portapuke))
		return FALSE
	if(isturf(glued_to))
		var/turf/glued_turf = glued_to
		if(glued_turf.density)
			return FALSE

	var/datum/component/glued/maybe_glued_component = glued_to.GetComponent(/datum/component/glued)
	while(istype(maybe_glued_component))
		if(maybe_glued_component.glued_to == thing_glued)
			if(user)
				boutput(user, SPAN_ALERT("You can't glue [thing_glued] to [glued_to] because [glued_to] is already glued to [thing_glued]."))
			return FALSE
		maybe_glued_component = maybe_glued_component.glued_to.GetComponent(/datum/component/glued)
	return TRUE

/datum/component/glue_ready/proc/glue_things(atom/movable/glued_to, atom/movable/thing_glued, mob/user=null, mob/log_user=null)
	if(isnull(log_user))
		log_user = user || usr
	var/obj/item/sticker/maybe_sticker = glued_to
	while(istype(maybe_sticker) && maybe_sticker.active) // prevent implanting items via gluing onto stickers attached to a thing
		glued_to = maybe_sticker.loc
		maybe_sticker = glued_to
	if(!gluability_check(glued_to, thing_glued, user))
		return
	thing_glued.AddComponent(/datum/component/glued, glued_to, src.dries_up_timestamp - TIME, src.glue_removal_time)
	var/turf/T = get_turf(glued_to)
	if(user)
		T.visible_message(SPAN_NOTICE("[user] glues [thing_glued] to [glued_to]."))
	else
		T.visible_message(SPAN_NOTICE("[thing_glued] sticks to [glued_to]."))
	logTheThing(LOG_COMBAT, log_user, "glued [ismob(thing_glued) ? constructTarget(thing_glued, "combat") : thing_glued] to [ismob(glued_to) ? constructTarget(glued_to, "combat") : glued_to] at [log_loc(glued_to)]")
	qdel(src)

/datum/component/glue_ready/proc/glue_thing_to_parent(atom/movable/parent, obj/item/item, user_or_datum_thrownthing)
	var/datum/thrown_thing/thrown_thing = user_or_datum_thrownthing
	ENSURE_TYPE(thrown_thing)
	var/mob/user = user_or_datum_thrownthing
	ENSURE_TYPE(user)
	glue_things(parent, item, user, user || thrown_thing.user)
	return TRUE

/datum/component/glue_ready/proc/glue_parent_to_thing_afterattack(obj/item/parent, atom/target, mob/user, reach, params)
	if(isnull(target))
		return
	if(!can_reach(user, target))
		return
	if(istype(target, /obj/effect))
		target = get_turf(target)
	glue_things(target, parent, user, user)
	if("icon-x" in params)
		parent.pixel_x = text2num(params["icon-x"]) - world.icon_size / 2
		parent.pixel_y = text2num(params["icon-y"]) - world.icon_size / 2

/datum/component/glue_ready/proc/glue_parent_to_thing_hit_thrown(obj/item/parent, atom/target, datum/thrown_thing/thrown_thing)
	if(isnull(target))
		return
	if(isfloor(target))
		return
	if(istype(target, /obj/effect))
		target = get_turf(target)
	glue_things(target, parent, null, thrown_thing.user)
	return TRUE

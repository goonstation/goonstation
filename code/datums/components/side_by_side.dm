/datum/component/side_by_side
	var/compatible_type = null
	var/x_offset = 8
	var/y_offset = 0
	/// /datum ahh var :skull:
	var/obj/parent_obj = null

TYPEINFO(/datum/component/side_by_side)
	initialization_args = list(
		ARG_INFO("compatible_type", DATA_INPUT_TYPE, "What type of things should this go side-by-side with?", null),
		ARG_INFO("x_offset", DATA_INPUT_NUM, "x offset when side-by-side"),
		ARG_INFO("y_offset", DATA_INPUT_NUM, "y offset when side-by-side"),
	)

/datum/component/side_by_side/Initialize(compatible_type, x_offset, y_offset)
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE)
		return
	src.compatible_type = compatible_type
	src.x_offset = x_offset
	src.y_offset = y_offset
	RegisterSignal(src.parent, COMSIG_ATTACKBY, PROC_REF(handle_attackby))
	src.parent_obj = src.parent

/datum/component/side_by_side/proc/duplicate_check()
	var/duplicates_found = 0
	for (var/obj/object in get_turf(src.parent))
		if (istype(object, src.compatible_type))
			duplicates_found++
			if (duplicates_found > 1)
				return TRUE
	return FALSE

/datum/component/side_by_side/proc/handle_attackby(_source, obj/item/electronics/frame/frame, mob/living/user)
	if (!istype(frame))
		return

	if (!ispath(frame.store_type, src.compatible_type) && !istype(frame.deconstructed_thing, src.compatible_type))
		return

	if (src.duplicate_check())
		return

	if (!user.find_tool_in_hand(TOOL_SOLDERING))
		boutput(user, SPAN_ALERT("You need a soldering iron to deploy that!"))
		return

	actions.start(new /datum/action/bar/icon/callback(user, src.parent_obj, 1 SECOND, PROC_REF(deploy_frame), list(frame, user), 'icons/ui/actions.dmi', "working", null, INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION, src), user)


/datum/component/side_by_side/proc/deploy_frame(obj/item/electronics/frame/frame, mob/user)
	if (frame.loc != user || src.duplicate_check())
		return
	user.drop_item(frame)
	frame.set_loc(src.parent_obj.loc)
	var/obj/other = frame.deploy(user)
	src.offset(other)

/datum/component/side_by_side/proc/offset(obj/other)
	other.pixel_x = src.x_offset
	other.pixel_y = src.y_offset
	src.parent_obj.pixel_x = -src.x_offset
	src.parent_obj.pixel_y = -src.y_offset

/* How to Use:
Regular variant: Edit the ID of this helper. It will make door buttons (regular and remote) and poddoors/airlocks use its ID.

Area variant: Do not edit this helper at all. It will automatically turn the area name into an identifier.
This is useful if you only have one button-operated feature in an area.

Pair variant: Edit the direction of this helper after placing it on a button. It will generate an ID from coordinates.
This ID is then placed on buttons in your active tile, and doors one tile away in the facing direction. Great for bathroom stalls, bedrooms, etc.
*/
/obj/mapping_helper/button
	name = "door button helper"
	icon = 'icons/map-editing/airlocks.dmi'
	icon_state = "id"
	var/id = "FIXME"
	var/use_area_name = FALSE
	var/do_pair = FALSE
	color = "#FF9900"

	var/list/valid_types = list(
		/obj/machinery/door_control,
		/obj/machinery/r_door_control,
		/obj/machinery/door/airlock,
		/obj/machinery/door/poddoor,
	)

/obj/mapping_helper/button/setup()
	var/object_found = FALSE
	var/turf/T = get_turf(src)
	var/pair_id = null
	for (var/obj/O in T)
		if (!istypes(O, src.valid_types))
			continue

		if (src.use_area_name)
			var/area/A = get_area(T)
			O:id = ckey(A.name)

		else if (src.do_pair)
			O:id = pair_id = "AUTO_[T.x]_[T.y]"

		else
			O:id = src.id

		astype(O, /obj/machinery/r_door_control)?.id_setup()
		object_found = TRUE

	if (src.do_pair)
		var/turf/looking_at = get_step(T, src.dir)
		for (var/obj/O in looking_at)
			if (istype(O, /obj/machinery/door/airlock) || istype(O,/obj/machinery/door/poddoor))
				O:id = pair_id

	if (!object_found)
		return "[CI.format_position(src)] could not locate any objects of type [CI.type_list(src.valid_types, " or ")]."


/obj/mapping_helper/button/area
	name = "area-name door button helper"
	icon_state = "id"
	use_area_name = TRUE
	color = "#C8FF00"

/obj/mapping_helper/button/pair
	name = "pair door button helper"
	icon_state = "id-dir"
	do_pair = TRUE
	color = "#FFDD00"

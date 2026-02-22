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

	setup()
		var/turf/our_spot = get_turf(src)
		var/pair_id
		for (var/obj/O in our_spot)
			if(istype(O,/obj/machinery/door_control) || istype(O,/obj/machinery/r_door_control) || istype(O,/obj/machinery/door/airlock) || istype(O,/obj/machinery/door/poddoor))
				if(use_area_name)
					var/area/our_area = get_area(our_spot)
					O:id = ckey(our_area.name)
				else if(do_pair)
					pair_id = "AUTO_[our_spot.x]_[our_spot.y]"
					O:id = pair_id
				else
					O:id = src.id
		if(do_pair)
			var/turf/looking_at = get_step(our_spot,src.dir)
			for(var/obj/O in looking_at)
				if(istype(O,/obj/machinery/door/airlock) || istype(O,/obj/machinery/door/poddoor))
					O:id = pair_id


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

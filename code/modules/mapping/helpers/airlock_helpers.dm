ABSTRACT_TYPE(/obj/mapping_helper/airlock)
/obj/mapping_helper/airlock
	name = "airlock helper parent"
	icon = 'icons/map-editing/airlocks.dmi'
	var/bolt = FALSE
	var/weld = FALSE
	var/ai_disable = FALSE

/obj/mapping_helper/airlock/setup()
	var/door_found = FALSE
	for (var/obj/machinery/door/airlock/D in get_turf(src))
		if (src.bolt)
			D.locked = TRUE
		if (src.weld)
			D.welded = TRUE
		if (src.ai_disable)
			D.aiControlDisabled = TRUE
		D.UpdateIcon()
		door_found = TRUE

	if (!door_found)
		return "[CI.format_position(src)] could not locate any objects of type (/obj/machinery/door/airlock)."

/obj/mapping_helper/airlock/bolter
	name = "airlock bolter"
	icon_state = "bolted"
	bolt = TRUE

/obj/mapping_helper/airlock/welder
	name = "airlock welder"
	icon_state = "welded"
	weld = TRUE

/obj/mapping_helper/airlock/aiDisabler
	name = "airlock aiDisabler"
	icon_state = "aiDisable"
	ai_disable = TRUE


ABSTRACT_TYPE(/obj/mapping_helper/airlock/cycler)
/obj/mapping_helper/airlock/cycler
	name = "airlock cycler linkage"
	// for var editing:
	var/cycle_id = ""	//! The ID of the cycling airlock. All airlocks connected should have the same ID
	var/enter_id = ""	//! Used within a network for things like double doors.

/obj/mapping_helper/airlock/cycler/setup()
	. = list()
	if (!src.cycle_id)
		. += "[CI.format_position(src)] has no cycle ID set."

	var/door_found = FALSE
	for (var/obj/machinery/door/airlock/D in get_turf(src))
		D.cycle_id = src.cycle_id
		D.cycle_enter_id = src.enter_id
		D.attempt_cycle_link()
		door_found = TRUE

	if (!door_found)
		. += "[CI.format_position(src)] could not locate any objects of type (/obj/machinery/door/airlock)."

/* How to Use:
For standard airlocks which are just a single tile in width, you use these ones.
This links them together by their cycle_id.
If you have a double door setup, set both doors in the same direction to have the same entrance_id.

For instance, you have 2 doors facing space and 2 facing inward, with an air lock between.
All four have the same cycle_id. The space facing ones have the same enter_id, and the interior ones have a different ones (that matches)
e.g. "Inside" or just "1" can work as ids. It's based on string matching.

This way, opening one of the double doors on the space side won't close the other space door.
But opening an interior door will still close both space doors.

It's different to tg's direction based one, but these can have 3 way intersections and 90 degree airlocks,
so I feel they're better and more versatile, even if they're harder to set up.. ~Tyrant
*/
/obj/mapping_helper/airlock/cycler/manual
	name = "manual airlock cycler linkage"
	icon_state = "cycle"

ABSTRACT_TYPE(/obj/mapping_helper/airlock/cycler/auto)
///For many cases when you have a simple pair of inner/outer airlocks and nothing else, this will allow setup without any variable editing.
/obj/mapping_helper/airlock/cycler/auto
	name = "proximity airlock cycler linkage"
	/// When looking for airlocks near the helper, do it in this radius.
	var/radius_around_helper = 0
	/// When looking for airlocks near the "outer" airlock/set, do it in this radius.
	var/radius_around_pair_turf = 0

/obj/mapping_helper/airlock/cycler/auto/setup()
	. = list()
	if (src.cycle_id)
		. += "[CI.format_position(src)] has a manually set cycle ID. This should not be done with proximity cycler helpers."

	src.cycle_id = "AUTO_[src.x]_[src.y]"

	var/inner_found = FALSE
	for (var/obj/machinery/door/airlock/D in range(src.radius_around_helper, src))
		D.cycle_id = src.cycle_id
		D.cycle_enter_id = "inner"
		D.attempt_cycle_link()
		inner_found = TRUE

	var/outer_found = FALSE
	var/turf/other_turf = src.seek_pair_turf()
	for (var/obj/machinery/door/airlock/D in range(src.radius_around_pair_turf, other_turf))
		D.cycle_id = src.cycle_id
		D.cycle_enter_id = "outer"
		D.attempt_cycle_link()
		outer_found = TRUE

	if (!inner_found)
		. += "[CI.format_position(src)] could not locate any INNER objects of type (/obj/machinery/door/airlock)."
	if (!outer_found)
		. += "[CI.format_position(src)] could not locate any OUTER objects of type (/obj/machinery/door/airlock)."

/// Proc to locate the turf that is under/near the "outer" airlock set. Should return one turf.
/obj/mapping_helper/airlock/cycler/auto/proc/seek_pair_turf()
	return


/// Connects to an airlock which is two cardinal steps away.
/obj/mapping_helper/airlock/cycler/auto/queen
	icon_state = "cycle-auto-queen"

/obj/mapping_helper/airlock/cycler/auto/queen/seek_pair_turf()
	var/offset_amt = (src.dir in global.cardinal) ? 2 : 1
	return get_steps(src, src.dir, offset_amt)


/// Connects to an airlock which is three (2+1) cardinal steps away, akin to the valid targets of a knight in chess (hence the name).
/obj/mapping_helper/airlock/cycler/auto/knight
	icon_state = "cycle-auto-knight"

/obj/mapping_helper/airlock/cycler/auto/knight/seek_pair_turf()
	switch (src.dir)
		if (NORTH)
			return locate(src.x - 1, src.y + 2, src.z)
		if (SOUTH)
			return locate(src.x + 1, src.y - 2, src.z)
		if (EAST)
			return locate(src.x + 2, src.y + 1, src.z)
		if (WEST)
			return locate(src.x - 2, src.y - 1, src.z)
		if (NORTHEAST)
			return locate(src.x + 1, src.y + 2, src.z)
		if (NORTHWEST)
			return locate(src.x - 2, src.y + 1, src.z)
		if (SOUTHEAST)
			return locate(src.x + 2, src.y - 1, src.z)
		if (SOUTHWEST)
			return locate(src.x - 1, src.y - 2, src.z)


/// Connects airlocks within a 1-tile radius of the helper to those within a 1-tile radius of a spot 2 tiles away (useful for wide airlocks and some edge cases)
/obj/mapping_helper/airlock/cycler/auto/rook
	icon_state = "cycle-auto-rook"
	radius_around_helper = 1
	radius_around_pair_turf = 1

/obj/mapping_helper/airlock/cycler/auto/rook/seek_pair_turf()
	return get_steps(src, src.dir, 2)


/// Connects airlocks within a 1-tile radius of the helper to a single outer airlock 2 tiles away (useful for airlocks with multiple interior-facing doors)
/obj/mapping_helper/airlock/cycler/auto/pawn
	icon_state = "cycle-auto-pawn"
	radius_around_helper = 1

/obj/mapping_helper/airlock/cycler/auto/pawn/seek_pair_turf()
	return get_steps(src, src.dir, 2)


/obj/mapping_helper/airlock/breaker
	name = "fake airlock converter"
	desc = "Turns a real door into a false one that can't be opened."
	icon_state = "broken"

/obj/mapping_helper/airlock/breaker/setup()
	// Use the bolt and weld vars to determine how the fake door should look.
	for (var/atom/A in get_turf(src))
		if (istype(A, /obj/mapping_helper/airlock/bolter))
			src.bolt = TRUE
			qdel(A)
		else if (istype(A, /obj/mapping_helper/airlock/welder))
			src.weld = TRUE
			qdel(A)

	var/door_found = FALSE
	for (var/obj/machinery/door/airlock/D in get_turf(src))
		var/obj/fakeobject/airlock_broken/F = new /obj/fakeobject/airlock_broken(D.loc)
		src.bolt ||= D.locked // It's possible for a bolter to activate first.

		if (src.weld || D.welded)
			F.UpdateOverlays(image(D.icon, D.welded_icon_state), "weld")

		F.icon = D.icon
		F.icon_state = (src.bolt ? "[D.icon_base]_locked" : D.icon_state)
		F.name = D.name
		F.desc = D.desc
		F.density = D.density
		qdel(D)
		door_found = TRUE

	if (!door_found)
		return "[CI.format_position(src)] could not locate any objects of type (/obj/machinery/door)."

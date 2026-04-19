ABSTRACT_TYPE(/obj/mapping_helper/airlock)
/obj/mapping_helper/airlock
	name = "airlock helper parent"
	icon = 'icons/map-editing/airlocks.dmi'
	var/bolt = FALSE
	var/weld = FALSE

	setup()
		for (var/obj/machinery/door/airlock/D in get_turf(src))
			if (src.bolt)
				D.locked = TRUE
			if (src.weld)
				D.welded = TRUE
			D.UpdateIcon()

/obj/mapping_helper/airlock/bolter
	name = "airlock bolter"
	icon_state = "bolted"
	bolt = TRUE

/obj/mapping_helper/airlock/welder
	name = "airlock welder"
	icon_state = "welded"
	weld = TRUE

ABSTRACT_TYPE(/obj/mapping_helper/airlock/cycler)
/obj/mapping_helper/airlock/cycler
	name = "airlock cycler linkage"
	// for var editing:
	var/cycle_id = ""	//! The ID of the cycling airlock. All airlocks connected should have the same ID
	var/enter_id = ""	//! Used within a network for things like double doors.

	setup()
		if (!src.cycle_id)
			CRASH("[src] has no cycle ID set. Coords: [src.x], [src.y], [src.z]")
		for (var/obj/machinery/door/airlock/D in get_turf(src))
			D.cycle_id = src.cycle_id
			D.cycle_enter_id = src.enter_id
			D.attempt_cycle_link()

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
	///When looking for airlocks at either end, check for them within this radius.
	var/seek_radius = 0

	///Proc to locate the turf that is under/near the "outer" airlock set. Should return one turf.
	proc/seek_pair_turf()
		return

	setup()
		if (src.cycle_id)
			CRASH("[src] has a manually set cycle ID. This should not be done with proximity cycler helpers. Coords: [src.x], [src.y], [src.z]")
		src.cycle_id = "AUTO_[src.x]_[src.y]"
		for (var/obj/machinery/door/airlock/D in range(src.seek_radius,src))
			D.cycle_id = src.cycle_id
			D.cycle_enter_id = "inner"
			D.attempt_cycle_link()
		var/turf/other_turf = src.seek_pair_turf()
		for (var/obj/machinery/door/airlock/D in range(src.seek_radius,other_turf))
			D.cycle_id = src.cycle_id
			D.cycle_enter_id = "outer"
			D.attempt_cycle_link()

///Connects to an airlock which is two cardinal steps away.
/obj/mapping_helper/airlock/cycler/auto/queen
	icon_state = "cycle-auto-queen"

	seek_pair_turf()
		var/offset_amt = 1
		if(src.dir in cardinal) offset_amt = 2
		var/turf/other_turf = get_steps(src,src.dir,offset_amt)
		return other_turf

///Connects to an airlock which is three (2+1) cardinal steps away, akin to the valid targets of a knight in chess (hence the name).
/obj/mapping_helper/airlock/cycler/auto/knight
	icon_state = "cycle-auto-knight"

	seek_pair_turf()
		var/x_offset = 0
		var/y_offset = 0
		switch(src.dir)
			if(NORTH)
				x_offset = -1
				y_offset = 2
			if(SOUTH)
				x_offset = 1
				y_offset = -2
			if(EAST)
				x_offset = 2
				y_offset = 1
			if(WEST)
				x_offset = -2
				y_offset = -1
			if(NORTHEAST)
				x_offset = 1
				y_offset = 2
			if(NORTHWEST)
				x_offset = -2
				y_offset = 1
			if(SOUTHEAST)
				x_offset = 2
				y_offset = -1
			if(SOUTHWEST)
				x_offset = -1
				y_offset = -2
		var/turf/other_turf = locate(src.x + x_offset, src.y + y_offset, src.z)
		return other_turf

///Connects airlocks within a 1-tile radius of the helper to those within a 1-tile radius of a spot 2 tiles away (useful for multi-door airlocks)
/obj/mapping_helper/airlock/cycler/auto/rook
	icon_state = "cycle-auto-rook"
	seek_radius = 1

	seek_pair_turf()
		var/turf/other_turf = get_steps(src,src.dir,2)
		return other_turf

/obj/mapping_helper/airlock/breaker
	name = "fake airlock converter"
	desc = "Turns a real door into a false one that can't be opened."
	icon_state = "broken"

	setup()
		// use the bolt and weld vars to determine how the fake door should look.
		for (var/atom/A in get_turf(src))
			if (istype(A, /obj/mapping_helper/airlock/bolter))
				src.bolt = TRUE
				qdel(A)
				continue
			if (istype(A, /obj/mapping_helper/airlock/welder))
				src.weld = TRUE
				qdel(A)
				continue
		var/counter = 0
		for (var/obj/machinery/door/airlock/D in get_turf(src))
			counter++
			var/obj/fakeobject/airlock_broken/F = new /obj/fakeobject/airlock_broken(D.loc)
			if (!src.bolt && D.locked) // it's possible for a bolter to activate first
				src.bolt = TRUE
			if (src.weld || D.welded)
				F.UpdateOverlays(image(D.icon, D.welded_icon_state), "weld")
			// set icon on the fake image
			F.icon = D.icon
			F.icon_state = (src.bolt ? "[D.icon_base]_locked" : D.icon_state)
			F.name = D.name
			F.desc = D.desc
			F.density = D.density
			qdel(D)
		if (counter > 1)
			CRASH("[counter] airlocks on tile [src.x], [src.y], [src.x]")

/obj/mapping_helper/airlock/aiDisabler
	name = "airlock aiDisabler"
	icon_state = "aiDisable"

	setup()
		. = ..()
		for (var/obj/machinery/door/airlock/secure_airlock in get_turf(src))
			secure_airlock.aiControlDisabled = TRUE

ABSTRACT_TYPE(/obj/mapping_helper/airlock)
/obj/mapping_helper/airlock
	name = "airlock helper parent"
	icon = 'icons/map-editing/airlocks.dmi'
	var/bolt = FALSE
	var/weld = FALSE
	var/cycle = FALSE
	var/cycleid = ""

	setup()
		for (var/obj/machinery/door/airlock/D in src.loc)
			if (src.bolt)
				D.locked = TRUE
			if (src.weld)
				D.welded = TRUE
			if (src.cycle)
				D.closeOtherId = src.cycleid
				D.attempt_cycle_link()
			D.UpdateIcon()

/obj/mapping_helper/airlock/bolter
	name = "airlock bolter"
	icon_state = "bolted"
	bolt = TRUE

/obj/mapping_helper/airlock/welder
	name = "airlock welder"
	icon_state = "welded"
	weld = TRUE

/obj/mapping_helper/airlock/cycler
	name = "airlock cycler linkage"
	icon_state = "cycle"
	cycle = TRUE
	cycleid = "1"

	id1
		cycleid = "1"
	id2
		cycleid = "2"
	id3
		cycleid = "3"
	id4
		cycleid = "4"
	id5
		cycleid = "5"
	id6
		cycleid = "6"
	id7
		cycleid = "7"

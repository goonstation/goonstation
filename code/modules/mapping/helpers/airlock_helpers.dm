ABSTRACT_TYPE(/obj/mapping_helper/airlock)
/obj/mapping_helper/airlock
	name = "airlock helper parent"
	icon = 'icons/map-editing/airlocks.dmi'
	var/bolt = FALSE
	var/weld = FALSE
	var/cycle = FALSE
	var/cycle_id = ""

	setup()
		for (var/obj/machinery/door/airlock/D in src.loc)
			if (src.bolt)
				D.locked = TRUE
			if (src.weld)
				D.welded = TRUE
			if (src.cycle)
				D.airlock_cycle_id = src.cycle_id
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
	cycle_id = "1"

	id1
		cycle_id = "1"
	id2
		cycle_id = "2"
	id3
		cycle_id = "3"
	id4
		cycle_id = "4"
	id5
		cycle_id = "5"
	id6
		cycle_id = "6"
	id7
		cycle_id = "7"

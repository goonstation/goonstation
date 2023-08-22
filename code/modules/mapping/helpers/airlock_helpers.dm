ABSTRACT_TYPE(/obj/mapping_helper/airlock)
/obj/mapping_helper/airlock
	name = "airlock helper parent"
	icon = 'icons/map-editing/airlocks.dmi'
	var/bolt = FALSE
	var/weld = FALSE
	var/harden = FALSE
	var/cant_emag = FALSE

	setup()
		for (var/obj/machinery/door/airlock/D in src.loc)
			if (src.bolt)
				D.locked = TRUE
			if (src.weld)
				D.welded = TRUE
			D.UpdateIcon()
			if (src.harden)
				D.hardened = TRUE
			if (src.cant_emag)
				D.cant_emag = TRUE
/obj/mapping_helper/airlock/bolter
	name = "airlock bolter"
	icon_state = "bolted"
	bolt = TRUE

/obj/mapping_helper/airlock/welder
	name = "airlock welder"
	icon_state = "welded"
	weld = TRUE

/obj/mapping_helper/airlock/hardener
	name = "airlock hardener"
	icon_state = "hardened"
	harden = TRUE

/obj/mapping_helper/airlock/anti_emag
	name = "airlock antiemagger"
	icon_state = "cant_emag"
	cant_emag = TRUE

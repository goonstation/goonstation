/obj/machinery/door/airlock/command
	name = "command airlock"
	icon = 'icons/obj/doors/Doorcom.dmi'
	req_access = list(access_heads)

/obj/machinery/door/airlock/security
	name = "security airlock"
	icon = 'icons/obj/doors/Doorsec.dmi'
	req_access = list(access_security)

/obj/machinery/door/airlock/engineering
	name = "engineering airlock"
	icon = 'icons/obj/doors/Dooreng.dmi'
	req_access = list(access_engineering)

/obj/machinery/door/airlock/medical
	name = "medical airlock"
	icon = 'icons/obj/doors/doormed.dmi'
	req_access = list(access_medical)

/obj/machinery/door/airlock/maintenance
	name = "maintenance airlock"
	icon = 'icons/obj/doors/Doormaint.dmi'
	req_access = list(access_maint_tunnels)

/obj/machinery/door/airlock/external
	name = "external airlock"
	icon = 'icons/obj/doors/Doorext.dmi'
	sound_airlock = 'sound/machines/airlock.ogg'
	opacity = 0
	visible = 0
	operation_time = 10

/obj/machinery/door/airlock/classic
	name = "large airlock"
	icon = 'icons/obj/doors/Doorclassic.dmi'
	sound_airlock = 'sound/machines/airlock.ogg'
	operation_time = 10

// ------------ syndicate airlocks ------------

TYPEINFO(/obj/machinery/door/airlock/syndicate)
	mats = 0

/obj/machinery/door/airlock/syndicate // fuck our players for making us (or at least me) need this
	name = "reinforced external airlock"
	desc = "Looks pretty tough. I wouldn't take this door on in a fight."
	icon = 'icons/obj/doors/Doorext.dmi'
	req_access = list(access_syndicate_shuttle)
	cant_emag = TRUE
	hardened = TRUE
	aiControlDisabled = TRUE
	object_flags = BOTS_DIRBLOCK

/obj/machinery/door/airlock/syndicate/meteorhit()
	return

/obj/machinery/door/airlock/syndicate/ex_act()
	return

// ------------ centcomm airlocks ------------

TYPEINFO(/obj/machinery/door/airlock/centcom)
	mats = 0

/obj/machinery/door/airlock/centcom
	icon = 'icons/obj/doors/Doorcom.dmi'
	req_access = list(access_centcom)
	cant_emag = TRUE
	cyborgBumpAccess = FALSE
	hardened = TRUE
	aiControlDisabled = TRUE
	object_flags = BOTS_DIRBLOCK

/obj/machinery/door/airlock/centcom/meteorhit()
	return

/obj/machinery/door/airlock/centcom/ex_act()
	return

// // ------------ glass airlocks ------------

/obj/machinery/door/airlock/glass
	name = "glass airlock"
	icon = 'icons/obj/doors/Doorglass.dmi'
	opacity = 0
	visible = 0

/obj/machinery/door/airlock/glass/command
	name = "command airlock"
	icon = 'icons/obj/doors/Doorcom-glass.dmi'
	req_access = list(access_heads)

/obj/machinery/door/airlock/glass/engineering
	name = "engineering airlock"
	icon = 'icons/obj/doors/Dooreng-glass.dmi'
	req_access = list(access_engineering)

/obj/machinery/door/airlock/glass/medical
	name = "medical airlock"
	icon = 'icons/obj/doors/Doormed-glass.dmi'
	req_access = list(access_medical)

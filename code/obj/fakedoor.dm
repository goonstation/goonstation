/obj/fakeobject/airlock_broken
	name = "rusted airlock"
	desc = "Rust has rendered this airlock useless."
	icon = 'icons/obj/doors/Door1.dmi';
	icon_state = "doorl";
	anchored = ANCHORED_ALWAYS
	density = 1
	opacity = 1

	sealed // used in dojozone
		name = "laboratory door"
		desc = "It appears to be sealed."
		icon = 'icons/obj/dojo.dmi'
		icon_state = "sealed_door"
		anchored = ANCHORED_ALWAYS

		owlery // used in owlery
			name = "Busted Airlock"
			desc = "This airlock is all shot up. The control panel seems to have taken several hits and is beyond repair."
			icon = 'icons/misc/Owlzone.dmi'
			icon_state = "airlock_broken"

	firelock // what used to be /obj/fakeobject/airlock_broken/firelock
		name = "rusted firelock"
		desc = "Rust has rendered this firelock useless."
		icon = 'icons/obj/doors/door_fire2.dmi'
		icon_state = "door0"

/obj/fakeobject/airlock_broken/command
	name = "command airlock"
	icon = 'icons/obj/doors/Doorcom.dmi'
	icon_state = "door_closed"

	bolted
		icon_state = "door_locked"

/obj/fakeobject/airlock_broken/security
	name = "security airlock"
	icon = 'icons/obj/doors/Doorsec.dmi'
	icon_state = "door_closed"

	bolted
		icon_state = "door_locked"

/obj/fakeobject/airlock_broken/engineering
	name = "engineering airlock"
	icon = 'icons/obj/doors/Dooreng.dmi'
	icon_state = "door_closed"

	bolted
		icon_state = "door_locked"

/obj/fakeobject/airlock_broken/medical
	name = "medical airlock"
	icon = 'icons/obj/doors/doormed.dmi'
	icon_state = "door_closed"

	bolted
		icon_state = "door_locked"

/obj/fakeobject/airlock_broken/maintenance
	name = "maintenance airlock"
	icon = 'icons/obj/doors/Doormaint.dmi'
	icon_state = "door_closed"

	bolted
		icon_state = "door_locked"

/obj/fakeobject/airlock_broken/external
	name = "external airlock"
	icon = 'icons/obj/doors/Doorext.dmi'
	icon_state = "door_closed"

	bolted
		icon_state = "door_locked"

/obj/fakeobject/airlock_broken/classic
	name = "large airlock"
	icon = 'icons/obj/doors/Doorclassic.dmi'
	icon_state = "door_closed"

	bolted
		icon_state = "door_locked"


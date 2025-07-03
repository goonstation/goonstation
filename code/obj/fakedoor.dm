/obj/fakeobject/airlock_broken
	name = "rusted airlock"
	desc = "Rust has rendered this airlock useless."
	icon = 'icons/obj/doors/Door1.dmi';
	icon_state = "doorl";
	anchored = ANCHORED_ALWAYS
	density = 1
	opacity = 1
	flags = IS_PERSPECTIVE_FLUID | FLUID_DENSE

	bolted
		icon_state = "door_locked"

	sealed // used in dojozone
		name = "laboratory door"
		desc = "It appears to be sealed."
		icon = 'icons/obj/dojo.dmi'
		icon_state = "sealed_door"

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
		density = FALSE
		opacity = FALSE

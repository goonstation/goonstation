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

// ===============
// normal airlocks
// ===============

/obj/fakeobject/airlock_broken/command
	name = "rusted command airlock"
	icon = 'icons/obj/doors/Doorcom.dmi'
	icon_state = "door_closed"

	bolted
		icon_state = "door_locked"

/obj/fakeobject/airlock_broken/security
	name = "rusted security airlock"
	icon = 'icons/obj/doors/Doorsec.dmi'
	icon_state = "door_closed"

	bolted
		icon_state = "door_locked"

/obj/fakeobject/airlock_broken/engineering
	name = "rusted engineering airlock"
	icon = 'icons/obj/doors/Dooreng.dmi'
	icon_state = "door_closed"

	bolted
		icon_state = "door_locked"

/obj/fakeobject/airlock_broken/medical
	name = "rusted medical airlock"
	icon = 'icons/obj/doors/doormed.dmi'
	icon_state = "door_closed"

	bolted
		icon_state = "door_locked"

/obj/fakeobject/airlock_broken/maintenance
	name = "rusted maintenance airlock"
	icon = 'icons/obj/doors/Doormaint.dmi'
	icon_state = "door_closed"

	bolted
		icon_state = "door_locked"

/obj/fakeobject/airlock_broken/external
	name = "rusted external airlock"
	icon = 'icons/obj/doors/Doorext.dmi'
	icon_state = "door_closed"

	bolted
		icon_state = "door_locked"

/obj/fakeobject/airlock_broken/classic
	name = "large rusted airlock"
	icon = 'icons/obj/doors/Doorclassic.dmi'
	icon_state = "door_closed"

	bolted
		icon_state = "door_locked"

/obj/fakeobject/airlock_broken/syndicate
	name = "rusted reinforced airlock"
	desc = "Looks pretty tough. I wouldn't take this door on in a fight."
	icon = 'icons/obj/doors/Doorext.dmi'
	icon_state = "door_closed"

	bolted
		icon_state = "door_locked"

// ===========
// glass doors
// ===========

/obj/fakeobject/airlock_broken/glass
	name = "rusted glass airlock"
	icon = 'icons/obj/doors/Doorglass.dmi'
	opacity = 0
	visible = 0
	icon_state = "door_closed"

	bolted
		icon_state = "door_locked"

/obj/fakeobject/airlock_broken/glass/command
	name = "rusted command airlock"
	icon = 'icons/obj/doors/Doorcom-glass.dmi'
	icon_state = "door_closed"

	bolted
		icon_state = "door_locked"

/obj/fakeobject/airlock_broken/glass/engineering
	name = "rusted engineering airlock"
	icon = 'icons/obj/doors/Dooreng-glass.dmi'
	icon_state = "door_closed"

	bolted
		icon_state = "door_locked"

/obj/fakeobject/airlock_broken/glass/medical
	name = "rusted medical airlock"
	icon = 'icons/obj/doors/Doormed-glass.dmi'
	icon_state = "door_closed"

	bolted
		icon_state = "door_locked"

// =============
// gannets doors
// =============

/obj/fakeobject/airlock_broken/gannets
	name = "rusted airlock"
	icon = 'icons/obj/doors/destiny.dmi'
	icon_state = "gen_closed"
	icon_base = "gen"
	icon_state = "door_closed"

	bolted
		icon_state = "gen_locked"

	alt
		icon_state = "fgen_closed"

		bolted
			icon_state = "fgen_locked"

	command
		name = "rusted command airlock"
		icon_state = "com_closed"

		bolted
			icon_state = "com_locked"

	command/alt
		icon_state = "fcom_closed"

		bolted
			icon_state = "fcom_locked"

	security
		name = "rusted security airlock"
		icon_state = "sec_closed"

		bolted
			icon_state = "sec_locked"

	security/alt
		icon_state = "fsec_closed"

		bolted
			icon_state = "fsec_locked"

	engineering
		name = "rusted engineering airlock"
		icon_state = "eng_closed"

		bolted
			icon_state = "eng_locked"

	engineering/alt
		icon_state = "feng_closed"

		bolted
			icon_state = "feng_locked"

	medical
		name = "rusted medical airlock"
		icon_state = "med_closed"

		bolted
			icon_state = "med_locked"

	medical/alt
		icon_state = "fmed_closed"

		bolted
			icon_state = "fmed_locked"

	morgue
		name = "rusted morgue airlock"
		icon_state = "morg_closed"

		bolted
			icon_state = "morg_locked"

	morgue/alt
		icon_state = "fmorg_closed"

		bolted
			icon_state = "fmorg_locked"

	chemistry
		name = "rusted chemistry airlock"
		icon_state = "chem_closed"

		bolted
			icon_state = "chem_locked"

	chemistry/alt
		icon_state = "fchem_closed"

		bolted
			icon_state = "fchem_locked"

	toxins
		name = "rusted toxins airlock"
		icon_state = "tox_closed"

		bolted
			icon_state = "tox_locked"

	toxins/alt
		icon_state = "ftox_closed"

		bolted
			icon_state = "ftox_locked"

	maintenance
		name = "rusted maintenance airlock"
		icon_state = "maint_closed"

		bolted
			icon_state = "maint_locked"


/obj/fakeobject/airlock_broken/gannets/glass
	name = "rusted glass airlock"
	icon = 'icons/obj/doors/destiny.dmi'
	icon_state = "tgen_closed"
	opacity = 0
	visible = 0

	bolted
		icon_state = "tgen_locked"

	alt
		icon_state = "tfgen_closed"

		bolted
			icon_state = "tfgen_locked"

	command
		name = "rusted command airlock"
		icon_state = "tcom_closed"

		bolted
			icon_state = "tcom_locked"

	command/alt
		icon_state = "tfcom_closed"

		bolted
			icon_state = "tfcom_locked"

	security
		name = "rusted security airlock"
		icon_state = "tsec_closed"

		bolted
			icon_state = "tsec_locked"

	security/alt
		icon_state = "tfsec_closed"

		bolted
			icon_state = "tfsec_locked"

	engineering
		name = "rusted engineering airlock"
		icon_state = "teng_closed"

		bolted
			icon_state = "teng_locked"

	engineering/alt
		icon_state = "tfeng_closed"

		bolted
			icon_state = "tfeng_locked"

	medical
		name = "rusted medical airlock"
		icon_state = "tmed_closed"

		bolted
			icon_state = "tmed_locked"

	medical/alt
		icon_state = "tfmed_closed"

		bolted
			icon_state = "tfmed_locked"

	morgue
		name = "rusted morgue airlock"
		icon_state = "tmorg_closed"

		bolted
			icon_state = "tmorg_locked"

	morgue/alt
		icon_state = "tfmorg_closed"

		bolted
			icon_state = "tfmorg_locked"

	chemistry
		name = "rusted chemistry airlock"
		icon_state = "tchem_closed"

		bolted
			icon_state = "tchem_locked"

	chemistry/alt
		icon_state = "tfchem_closed"

		bolted
			icon_state = "tfchem_locked"

	toxins
		name = "rusted toxins airlock"
		icon_state = "ttox_closed"

		bolted
			icon_state = "ttox_locked"

	toxins/alt
		icon_state = "tftox_closed"

		bolted
			icon_state = "tftox_locked"

	maintenance
		name = "rusted maintenance airlock"
		icon_state = "tmaint_closed"

		bolted
			icon_state = "tmaint_locked"

// ==========
// pyro doors
// ==========

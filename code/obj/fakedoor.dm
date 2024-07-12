/obj/fakeobject/airlock_broken
	name = "rusted airlock"
	desc = "Rust has rendered this airlock useless."
	icon = 'icons/obj/doors/Door1.dmi';
	icon_state = "doorl";
	anchored = ANCHORED_ALWAYS
	density = 1
	opacity = 1
	flags = IS_PERSPECTIVE_FLUID | ALWAYS_SOLID_FLUID

	bolted
		icon_state = "door_locked"

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

/obj/fakeobject/airlock_broken/pyro
	icon = 'icons/obj/doors/SL_doors.dmi'
	icon_state = "door_closed"

	bolted
		icon_state = "door_locked"

/obj/fakeobject/airlock_broken/pyro/alt
	icon_state = "generic2_closed"

	bolted
		icon_state = "generic2_locked"

/obj/fakeobject/airlock_broken/pyro/classic
	name = "rusted old airlock"
	icon_state = "old_closed"

	bolted
		icon_state = "old_locked"

/obj/fakeobject/airlock_broken/pyro/command
	name = "rusted command airlock"
	icon_state = "com_closed"

	bolted
		icon_state = "com_locked"

/obj/fakeobject/airlock_broken/pyro/command/alt
	icon_state = "com2_closed"

	bolted
		icon_state = "com2_locked"

/obj/fakeobject/airlock_broken/pyro/weapons
	icon_state = "manta_closed"

	bolted
		icon_state = "manta_locked"

/obj/fakeobject/airlock_broken/pyro/security
	name = "rusted security airlock"
	icon_state = "sec_closed"

	bolted
		icon_state = "sec_locked"

/obj/fakeobject/airlock_broken/pyro/security/alt
	icon_state = "sec2_closed"

	bolted
		icon_state = "sec_locked"

/obj/fakeobject/airlock_broken/pyro/engineering
	name = "rusted engineering airlock"
	icon_state = "eng_closed"

	bolted
		icon_state = "eng_locked"

/obj/fakeobject/airlock_broken/pyro/engineering/alt
	icon_state = "eng2_closed"

	bolted
		icon_state = "eng_locked"

/obj/fakeobject/airlock_broken/pyro/mining
	name = "rusted mining airlock"
	icon_state = "mining_closed"

	bolted
		icon_state = "eng_locked"

/obj/fakeobject/airlock_broken/pyro/medical
	name = "rusted medical airlock"
	icon_state = "research_closed"

	bolted
		icon_state = "research_locked"

/obj/fakeobject/airlock_broken/pyro/medical/alt
	icon_state = "research2_closed"

	bolted
		icon_state = "research2_locked"

/obj/fakeobject/airlock_broken/pyro/medical/alt2
	icon_state = "med_closed"

	bolted
		icon_state = "med_locked"

/obj/fakeobject/airlock_broken/pyro/medical/morgue
	icon_state = "morgue_closed"

	bolted
		icon_state = "morgue_locked"

/obj/fakeobject/airlock_broken/pyro/sci_alt
	name = "rusted research airlock"
	icon_state = "sci_closed"

	bolted
		icon_state = "sci_locked"

/obj/fakeobject/airlock_broken/pyro/toxins_alt
	name = "rusted toxins airlock"
	icon_state = "toxins2_closed"

	bolted
		icon_state = "toxins2_locked"

/obj/fakeobject/airlock_broken/pyro/maintenance
	name = "rusted maintenance airlock"
	icon_state = "maint_closed"

	bolted
		icon_state = "maint_locked"

/obj/fakeobject/airlock_broken/pyro/maintenance/alt
	icon_state = "maint2_closed"

	bolted
		icon_state = "maint2_locked"

/obj/fakeobject/airlock_broken/pyro/external
	name = "rusted external airlock"
	icon_state = "airlock_closed"

	bolted
		icon_state = "airlock_locked"

/obj/fakeobject/airlock_broken/pyro/reinforced
	name = "rusted reinforced airlock"
	desc = "Looks pretty tough. I wouldn't take this door on in a fight."
	icon_state = "airlock_closed"

	bolted
		icon_state = "airlock_locked"

/obj/fakeobject/airlock_broken/pyro/reinforced/arrivals
	icon_state = "arrivals_closed"
	opacity = 0

	bolted
		icon_state = "arrivals_locked"

/obj/fakeobject/airlock_broken/pyro/glass
	name = "rusted glass airlock"
	icon_state = "glass_closed"
	opacity = 0

	bolted
		icon_state = "glass_locked"

/obj/fakeobject/airlock_broken/pyro/glass/command
	name = "rusted command airlock"
	icon_state = "com_glass_closed"

	bolted
		icon_state = "com_glass_locked"

/obj/fakeobject/airlock_broken/pyro/glass/engineering
	name = "rusted engineering airlock"
	icon_state = "eng_glass_closed"

	bolted
		icon_state = "eng_glass_locked"

/obj/fakeobject/airlock_broken/pyro/glass/security
	name = "rusted security airlock"
	icon_state = "sec_glass_closed"

	bolted
		icon_state = "sec_glass_locked"

/obj/fakeobject/airlock_broken/pyro/glass/security/alt
	name = "rusted security airlock"
	icon_state = "sec_glassalt_closed"

	bolted
		icon_state = "sec_glassalt_locked"

/obj/fakeobject/airlock_broken/pyro/glass/med
	name = "rusted medical airlock"
	icon_state = "med_glass_closed"

	bolted
		icon_state = "med_glass_locked"

/obj/fakeobject/airlock_broken/pyro/glass/sci
	name = "rusted research airlock"
	icon_state = "sci_glass_closed"

	bolted
		icon_state = "sci_glass_locked"

/obj/fakeobject/airlock_broken/pyro/glass/toxins
	name = "rusted toxins airlock"
	icon_state = "toxins_glass_closed"

	bolted
		icon_state = "toxins_glass_locked"

/obj/fakeobject/airlock_broken/pyro/glass/mining
	name = "rusted mining airlock"
	icon_state = "mining_glass_closed"

	bolted
		icon_state = "mining_glass_locked"

/obj/fakeobject/airlock_broken/pyro/glass/botany
	name = "rusted botany airlock"
	icon_state = "botany_glass_closed"

	bolted
		icon_state = "botany_glass_locked"

/obj/fakeobject/airlock_broken/pyro/glass/windoor
	name = "rusted thin glass airlock"
	icon_state = "windoor_closed"

	bolted
		icon_state = "windoor_locked"

/obj/fakeobject/airlock_broken/pyro/glass/windoor/alt
	icon_state = "windoor2_closed"

	bolted
		icon_state = "windoor2_locked"

/obj/machinery/manufacturer/pod_wars
	name = "ship component fabricator"
	desc = "A manufacturing unit calibrated to produce parts for ships."
	icon_state = "fab-hangar"
	icon_base = "hangar"
	var/team_num = 0			//NT = 1, SY = 2
	free_resource_amt = 20
	free_resources = list(
		/obj/item/material_piece/mauxite,
		/obj/item/material_piece/pharosium,
		/obj/item/material_piece/molitz
	)
	available = list(
		/datum/manufacture/pod_wars/lock,
		/datum/manufacture/putt/engine,
		/datum/manufacture/putt/boards,
		/datum/manufacture/putt/control,
		/datum/manufacture/putt/parts,
		/datum/manufacture/pod/boards,
		/datum/manufacture/pod/control,
		/datum/manufacture/pod/parts,
		/datum/manufacture/pod/engine,
		/datum/manufacture/engine2,
		/datum/manufacture/engine3,
		/datum/manufacture/pod/lock,
		/datum/manufacture/cargohold,
		/datum/manufacture/orescoop,
		/datum/manufacture/conclave,
		/datum/manufacture/communications/mining,
		/datum/manufacture/pod/weapon/mining_podwars,
		/datum/manufacture/pod/weapon/mining/drill,
		/datum/manufacture/pod/weapon/ltlaser,
		/datum/manufacture/pod/weapon/mining_weak,
		/datum/manufacture/pod/weapon/taser,
		/datum/manufacture/pod/weapon/laser/short,
		/datum/manufacture/pod/weapon/laser,
		/datum/manufacture/pod/weapon/disruptor,
		/datum/manufacture/pod/weapon/disruptor/light,
		/datum/manufacture/pod/weapon/shotgun
	)

	New()
		START_TRACKING
		..()

	disposing()
		STOP_TRACKING
		..()

	claim_free_resources(datum/game_mode/pod_wars/PW)
		if (team_num == TEAM_NANOTRASEN)
			src.resource_amounts = PW.team_NT.resources
		else if (team_num == TEAM_SYNDICATE)
			src.resource_amounts = PW.team_SY.resources
		..()

	attack_hand(var/mob/user)
		if (get_pod_wars_team_num(user) != src.team_num)
			boutput(user, "<span class='alert'>This machine's design makes no sense to you, you can't figure out how to use it!</span>")
			return

		..()

/obj/machinery/manufacturer/pod_wars/nanotrasen
	name = "\improper NanoTrasen ship component fabricator"
	team_num = TEAM_NANOTRASEN
	available = list(
		/datum/manufacture/pod_wars/lock,
		/datum/manufacture/putt/engine,
		/datum/manufacture/putt/boards,
		/datum/manufacture/putt/control,
		/datum/manufacture/putt/parts,
		/datum/manufacture/pod/boards,
		/datum/manufacture/pod/control,
		/datum/manufacture/pod/parts,
		/datum/manufacture/pod/engine,
		/datum/manufacture/engine2,
		/datum/manufacture/engine3,
		/datum/manufacture/pod/lock,
		/datum/manufacture/cargohold,
		/datum/manufacture/orescoop,
		/datum/manufacture/conclave,
		/datum/manufacture/communications/mining,
		/datum/manufacture/pod/weapon/mining_podwars,
		/datum/manufacture/pod/weapon/mining/drill,
		/datum/manufacture/pod/weapon/ltlaser,
		/datum/manufacture/pod/weapon/mining_weak,
		/datum/manufacture/pod/weapon/taser,
		/datum/manufacture/pod/weapon/laser/short,
		/datum/manufacture/pod/weapon/laser,
		/datum/manufacture/pod/weapon/disruptor,
		/datum/manufacture/pod/weapon/disruptor/light,
		/datum/manufacture/pod/weapon/shotgun,
		/datum/manufacture/pod_wars/pod/armor_light/nt,
		/datum/manufacture/pod_wars/pod/armor_robust/nt

	)

/obj/machinery/manufacturer/pod_wars/syndicate
	name = "\improper Syndicate ship component fabricator"
	team_num = TEAM_SYNDICATE
	available = list(
		/datum/manufacture/pod_wars/lock,
		/datum/manufacture/putt/engine,
		/datum/manufacture/putt/boards,
		/datum/manufacture/putt/control,
		/datum/manufacture/putt/parts,
		/datum/manufacture/pod/boards,
		/datum/manufacture/pod/control,
		/datum/manufacture/pod/parts,
		/datum/manufacture/pod/engine,
		/datum/manufacture/engine2,
		/datum/manufacture/engine3,
		/datum/manufacture/pod/lock,
		/datum/manufacture/cargohold,
		/datum/manufacture/orescoop,
		/datum/manufacture/conclave,
		/datum/manufacture/communications/mining,
		/datum/manufacture/pod/weapon/mining_podwars,
		/datum/manufacture/pod/weapon/mining/drill,
		/datum/manufacture/pod/weapon/ltlaser,
		/datum/manufacture/pod/weapon/mining_weak,
		/datum/manufacture/pod/weapon/taser,
		/datum/manufacture/pod/weapon/laser/short,
		/datum/manufacture/pod/weapon/laser,
		/datum/manufacture/pod/weapon/disruptor,
		/datum/manufacture/pod/weapon/disruptor/light,
		/datum/manufacture/pod/weapon/shotgun,
		/datum/manufacture/pod_wars/pod/armor_light/sy,
		/datum/manufacture/pod_wars/pod/armor_robust/sy
		)

////////////////pod-weapons//////////////////
/datum/manufacture/pod/weapon/mining_weak
	name = "Mining Phaser System"
	item_paths = list("MET-1","CON-1")
	item_amounts = list(10,10)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/bad_mining)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/pod/weapon/mining_podwars
	name = "Plasma Cutter System"
	item_paths = list("MET-2","CON-2", "telecrystal")
	item_amounts = list(50,50,10)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/mining)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/pod/weapon/taser
	name = "Mk.1 Combat Taser"
	item_paths = list("MET-2","CON-1","CRY-1")
	item_amounts = list(20,20,30)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/taser)
	time = 10 SECONDS
	create  = 1
	category = "Tool"

/datum/manufacture/pod/weapon/laser
	name = "Mk.2 Scout Laser"
	item_paths = list("MET-2","CON-1","CRY-1")
	item_amounts = list(25,40,30)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/laser)
	time = 10 SECONDS
	create  = 1
	category = "Tool"

/datum/manufacture/pod/weapon/laser/short
	name = "Mk.2 CQ Laser"
	item_paths = list("MET-2","CON-1","CRY-1")
	item_amounts = list(20,20,20)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/laser/short)
	time = 10 SECONDS

/datum/manufacture/pod/weapon/disruptor
	name = "Heavy Disruptor Array"
	item_paths = list("MET-3","CON-2","CRY-1", "telecrystal")
	item_amounts = list(20,20,50, 20)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/disruptor)
	time = 10 SECONDS
	create  = 1
	category = "Tool"

/datum/manufacture/pod/weapon/disruptor/light
	name = "Mk.3 Disruptor"
	item_paths = list("MET-2","CON-1","CRY-1")
	item_amounts = list(20,30,30)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/disruptor_light)
	time = 10 SECONDS
	create  = 1
	category = "Tool"

/datum/manufacture/pod/weapon/ass_laser
	name = "Mk.4 Assault Laser"
	item_paths = list("MET-3","CON-2","CRY-1", "telecrystal")
	item_amounts = list(35,30,30, 30)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/laser_ass)
	time = 10 SECONDS
	create  = 1
	category = "Tool"

/datum/manufacture/pod/weapon/shotgun
	name = "SPE-12 Ballistic System"
	item_paths = list("MET-3","CON-2","CRY-1")
	item_amounts = list(50,40,10)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/gun)
	time = 10 SECONDS
	create  = 1
	category = "Tool"

////////////pod-armor///////////////////////

ABSTRACT_TYPE(/datum/manufacture/pod_wars)

ABSTRACT_TYPE(/datum/manufacture/pod_wars/pod)

/datum/manufacture/pod_wars/pod/armor_light
	name = "Light NT Pod Armor"
	item_paths = list("MET-3","CON-1")
	item_amounts = list(50,50)
	item_outputs = list(/obj/item/podarmor/armor_light)
	time = 20 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/pod_wars/pod/armor_light/nt
	name = "Light NT Pod Armor"
	item_outputs = list(/obj/item/podarmor/nt_light)

/datum/manufacture/pod_wars/pod/armor_light/sy
	name = "Light Syndicate Pod Armor"
	item_outputs = list(/obj/item/podarmor/sy_light)

/datum/manufacture/pod_wars/pod/armor_robust
	name = "Heavy Pod Armor"
	item_paths = list("MET-3","CON-2", "CRY-2")
	item_amounts = list(50,30, 10)
	item_outputs = list(/obj/item/podarmor/armor_heavy)
	time = 30 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/pod_wars/pod/armor_robust/nt
	name = "Robust NT Pod Armor"
	item_outputs = list(/obj/item/podarmor/nt_robust)

/datum/manufacture/pod_wars/pod/armor_robust/sy
	name = "Robust Syndicate Pod Armor"
	item_outputs = list(/obj/item/podarmor/sy_robust)

//costs a good bit more than the standard jetpack. for balance reasons here. to make jetpacks a commodity.
/datum/manufacture/pod_wars/jetpack
	name = "Jetpack"
	item_paths = list("MET-2","CON-1")
	item_amounts = list(30,50)
	item_outputs = list(/obj/item/tank/jetpack)
	time = 60 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/pod_wars/jetpack/syndicate
	name = "Jetpack"
	item_paths = list("MET-2","CON-1")
	item_amounts = list(30,50)
	item_outputs = list(/obj/item/tank/jetpack/syndicate)
	time = 60 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/pod_wars/industrialboots
	name = "Mechanised Boots"
	item_paths = list("MET-3","CON-2","POW-2", "DEN-2")
	item_amounts = list(50,50,70,50)
	item_outputs = list(/obj/item/clothing/shoes/industrial)
	time = 120 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/pod_wars/accumulator
	name = "Mineral Accumulator"
	item_paths = list("MET-2","CON-2","DEN-1")
	item_amounts = list(25,15,2)
	item_outputs = list(/obj/machinery/oreaccumulator)
	time = 120 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/pod_wars/accumulator/syndicate
	name = "Syndicate Mineral Accumulator"
	item_outputs = list(/obj/machinery/oreaccumulator/pod_wars/syndicate)

/datum/manufacture/pod_wars/accumulator/nanotrasen
	name = "NanoTrasen Mineral Accumulator"
	item_outputs = list(/obj/machinery/oreaccumulator/pod_wars/nanotrasen)

/datum/manufacture/pod_wars/medical_refill
	name = "NanoMed Refill Cartridge"
	item_outputs = list(/obj/item/vending/restock_cartridge/medical)
	item_paths = list("MET-1","FAB-1","DEN-1")
	item_amounts = list(25,25,20)
	time = 60 SECONDS
	category = "Ammo"

/obj/machinery/manufacturer/mining/pod_wars/
	var/team_num = 0

	New()
		START_TRACKING
		available -= /datum/manufacture/ore_accumulator
		available -= /datum/manufacture/jetpack

		available -= /datum/manufacture/industrialboots
		available += /datum/manufacture/pod_wars/industrialboots

		hidden = list()
		..()

	disposing()
		STOP_TRACKING
		..()

	claim_free_resources(datum/game_mode/pod_wars/PW)
		if (team_num == TEAM_NANOTRASEN)
			src.resource_amounts = PW.team_NT.resources
		else if (team_num == TEAM_SYNDICATE)
			src.resource_amounts = PW.team_SY.resources
		..()

/obj/machinery/manufacturer/mining/pod_wars/syndicate
	team_num = TEAM_SYNDICATE

	New()
		available += /datum/manufacture/pod_wars/accumulator/syndicate
		available += /datum/manufacture/pod_wars/jetpack/syndicate
		..()

/obj/machinery/manufacturer/mining/pod_wars/nanotrasen
	team_num = TEAM_NANOTRASEN

	New()
		available += /datum/manufacture/pod_wars/accumulator/nanotrasen
		available += /datum/manufacture/pod_wars/jetpack
		..()

/obj/machinery/manufacturer/medical/pod_wars
	New()
		available += /datum/manufacture/medical_backpack
		available += /datum/manufacture/pod_wars/medical_refill
		..()


/datum/manufacture/pod_wars/cell_high
	name = "Standard Large Weapon Cell"
	item_paths = list("MET-2", "CON-2", "POW-1")
	item_amounts = list(5, 20, 30)
	item_outputs = list(/obj/item/ammo/power_cell/high_power)
	time = 1 SECONDS
	create = 1
	category = "Ammo"

/datum/manufacture/pod_wars/cell_higher
	name = "Standard Bubs Weapon Cell"
	item_paths = list("MET-3", "CON-2", "POW-1", "telecrystal")
	item_amounts = list(5, 20, 60, 20)
	item_outputs = list(/obj/item/ammo/power_cell/higher_power)
	time = 1 SECONDS
	create = 1
	category = "Ammo"

////////////////////////////

/datum/manufacture/pod_wars/cell_pod_wars_basic
	name = "Basic Self-Charging Weapon Cell"
	item_paths = list("MET-2", "DEN-1", "CON-2", "POW-1")
	item_amounts = list(10, 20, 30, 30)
	item_outputs = list(/obj/item/ammo/power_cell/self_charging/pod_wars_basic)
	time = 1 SECONDS
	create = 1
	category = "Ammo"

/datum/manufacture/pod_wars/cell_pod_wars_standard
	name = "Standard Self-Charging Weapon Cell"
	item_paths = list("DEN-2", "CON-2", "POW-1", "telecrystal")
	item_amounts = list(30, 60, 50, 10)
	item_outputs = list(/obj/item/ammo/power_cell/self_charging/pod_wars_standard)
	time = 1 SECONDS
	create = 1
	category = "Ammo"

/datum/manufacture/pod_wars/cell_pod_wars_high
	name = "Robust Self-Charging Weapon Cell"
	item_paths = list("DEN-2", "CON-2", "POW-2", "telecrystal")
	item_amounts = list(30, 70, 30, 30)
	item_outputs = list(/obj/item/ammo/power_cell/self_charging/pod_wars_high)
	time = 1 SECONDS
	create = 1
	category = "Ammo"



//It's cheap, use it!
/datum/manufacture/pod_wars/lock
	name = "Pod Lock (ID Card)"
	item_paths = list("MET-1")
	item_amounts = list(1)
	item_outputs = list(/obj/item/shipcomponent/secondary_system/lock/pw_id)
	time = 1 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/pod_wars/barricade
	name = "Deployable Barricade"
	item_paths = list("MET-2")
	item_amounts = list(5)
	item_outputs = list(/obj/item/deployer/barricade)
	time = 1 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/pod_wars/energy_concussion_grenade

	name = "Concussion Grenade"
	item_paths = list("MET-1", "CON-1", "telecrystal")
	item_amounts = list(5, 5, 5)
	item_outputs = list(/obj/item/old_grenade/energy_concussion)
	time = 1 SECONDS
	create = 1
	category = "Weapon"

/datum/manufacture/pod_wars/energy_frag_grenade

	name = "Blast Grenade"
	item_paths = list("MET-2", "CON-2", "telecrystal")
	item_amounts = list(5, 5, 5)
	item_outputs = list(/obj/item/old_grenade/energy_frag)
	time = 1 SECONDS
	create = 1
	category = "Weapon"

/datum/manufacture/pod_wars/handcuffs

	name = "Handcuffs"
	item_paths = list("MET-1")
	item_amounts = list(5)
	item_outputs = list(/obj/item/handcuffs)
	time = 2 SECONDS
	create = 1
	category = "Weapon"


/obj/machinery/chem_dispenser/medical
	name = "medical reagent dispenser"
	desc = "It dispenses chemicals. Mostly harmless ones, but who knows?"
	dispensable_reagents = list("antihol", "charcoal", "epinephrine", "mutadone", "proconvertin", "atropine",\
		 "salbutamol", "anti_rad",\
		"oculine", "mannitol", "saline",\
		"salicylic_acid", "blood",\
		"menthol", "antihistamine")

	icon_state = "dispenser"
	icon_base = "dispenser"
	dispenser_name = "Medical"


/obj/machinery/chem_dispenser/medical/fortuna
	dispensable_reagents = list("antihol", "charcoal", "epinephrine", "mutadone", "proconvertin", "filgrastim", "atropine",\
	"salbutamol", "perfluorodecalin", "synaptizine", "anti_rad",\
	"oculine", "mannitol", "penteticacid", "saline",\
	"salicylic_acid", "blood", \
	"menthol", "antihistamine", "smelling_salt")

/obj/machinery/manufacturer/general/pod_wars
	New()
		#ifdef RP_MODE
		available += /datum/manufacture/pod_wars/handcuffs
		#endif
		available += /datum/manufacture/pod_wars/barricade
		available += /datum/manufacture/pod_wars/energy_frag_grenade
		available += /datum/manufacture/pod_wars/energy_concussion_grenade
		available += /datum/manufacture/pod_wars/cell_pod_wars_basic
		available += /datum/manufacture/pod_wars/cell_pod_wars_standard
		available += /datum/manufacture/pod_wars/cell_pod_wars_high
		available += /datum/manufacture/pod_wars/cell_high
		available += /datum/manufacture/pod_wars/cell_higher

		hidden = list()
		..()

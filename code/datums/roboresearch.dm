// Robot Research Datums

/datum/roboresearch/
	var/name = "robotics research"
	var/list/schematics = list() // What blueprints does this research allow Robotics Fabricators to download?
	var/manubonus = 0  // Does this research give a bonus to manufacturing unit efficiency?
	var/timebonus = 0  // Manufacturing time has this subtracted from it
	var/multiplier = 1 // Manufacturing time is divided by this (unless it's zero, we dont want to crash)
	var/powbonus = 0   // How much manufacturing unit power usage is reduced by (base of 1500/tick while in use)
	var/resebonus = 0  // Does this research give a bonus to research time?
	var/resemulti = 1  // Research time is divided by this

// T1

/datum/roboresearch/manufone
	name = "Improved Manufacturing Units"
	manubonus = 1
	timebonus = 2
	multiplier = 0
	powbonus = 100

/datum/roboresearch/drones
	name = "Basic Drone Schematics"

	New()
		..()
		src.schematics += new /datum/manufacture/secbot(src)
		src.schematics += new /datum/manufacture/medbot(src)
		src.schematics += new /datum/manufacture/firebot(src)
		src.schematics += new /datum/manufacture/floorbot(src)
		src.schematics += new /datum/manufacture/cleanbot(src)

/datum/roboresearch/implants1
	name = "Sensory Prostheses"

	New()
		..()
		src.schematics += new /datum/manufacture/visor(src)
		src.schematics += new /datum/manufacture/deafhs(src)

/datum/roboresearch/modules1
	name = "Improved Cyborg Modules"

/datum/roboresearch/upgrades1
	name = "Basic Cyborg Upgrades"

	New()
		..()
		src.schematics += new /datum/manufacture/robup_jetpack(src)
		src.schematics += new /datum/manufacture/robup_recharge(src)
		src.schematics += new /datum/manufacture/robup_repairpack(src)
		src.schematics += new /datum/manufacture/robup_speed(src)
		src.schematics += new /datum/manufacture/robup_meson(src)

// T2

/datum/roboresearch/manuftwo
	name = "Superior Manufacturing Units"
	manubonus = 1
	timebonus = 3
	multiplier = 0
	powbonus = 150

/datum/roboresearch/rewriter
	name = "Improved Rewriting & Recharging"

/datum/roboresearch/resespeedone
	name = "Improved Development Algorithms"
	resebonus = 1
	resemulti = 1.25

/datum/roboresearch/modules2
	name = "Superior Cyborg Modules"

/datum/roboresearch/upgrades2
	name = "Improved Cyborg Upgrades"

	New()
		..()
		src.schematics += new /datum/manufacture/robup_aware(src)
		src.schematics += new /datum/manufacture/robup_physshield(src)
		src.schematics += new /datum/manufacture/robup_fireshield(src)
		src.schematics += new /datum/manufacture/robup_teleport(src)
//		src.schematics += new /datum/manufacture/robup_thermal(src) // shit don't work
		//src.schematics += new /datum/manufacture/robup_chargexpand(src)

// T3

/datum/roboresearch/manufthree
	name = "Efficient Manufacturing Units"
	manubonus = 1
	timebonus = 0
	multiplier = 0
	powbonus = 500

/datum/roboresearch/manuffour
	name = "Rapid Manufacturing Units"
	manubonus = 1
	timebonus = 1.5
	multiplier = 0
	powbonus = 0

/datum/roboresearch/upgrades3
	name = "Superior Cyborg Upgrades"

	New()
		..()
		src.schematics += new /datum/manufacture/robup_efficiency(src)
		src.schematics += new /datum/manufacture/robup_repair(src)
		//src.schematics += new /datum/manufacture/robup_expand(src)

/datum/roboresearch/implants2
	name = "Improved Implants"

	New()
		..()
		src.schematics += new /datum/manufacture/implant_robotalk(src)
//		src.schematics += new /datum/manufacture/implant_bloodmonitor(src) // does nothing

// T4

/datum/roboresearch/manuffive
	name = "Advanced Manufacturing Units"
	manubonus = 1
	timebonus = 5
	multiplier = 2
	powbonus = 500

/datum/roboresearch/resespeedtwo
	name = "Advanced Development Algorithms"
	resebonus = 1
	resemulti = 2


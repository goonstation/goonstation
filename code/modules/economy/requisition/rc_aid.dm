ABSTRACT_TYPE(/datum/req_contract/aid)
/datum/req_contract/aid //in your final hour, astral wolf...
	req_class = 2

/datum/req_contract/aid/wrecked
	name = "Breach Recovery"
	payout = 1200
	var/list/namevary = list("Breach Recovery","Breach Response","Integrity Failure","Crisis Response","Disaster Assistance","Disaster Response")
	var/list/desc0 = list("research","mining","security","cargo transfer")
	var/list/desc1 = list("vessel","ship","station","outpost")
	var/list/desc2 = list("suffered","experienced","been damaged by","incurred")
	var/list/desc3 = list("severe","catastrophic","hazardous","critical","disastrous")
	var/list/desc4 = list("reactor failure","hull breach","core breach","hull rupture","gravimetric shear","collision","canister explosion")

	New()
		src.name = pick(namevary)
		src.flavor_desc = "An affiliated [pick(desc0)] [pick(desc1)] has [pick(desc2)] a [pick(desc3)] [pick(desc4)] and requires repair supplies as soon as possible."
		src.payout += rand(0,60) * 10

		var/suitsets = rand(2,4)

		src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/spacesuit,suitsets)
		src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/spacehelmet,suitsets)

		if(prob(70)) src.rc_entries += rc_buildentry(/datum/rc_entry/stack/steelsheet,rand(5,35)*2)

		for(var/S in concrete_typesof(/datum/rc_entry/itembypath/basictool))
			if(prob(70))
				src.rc_entries += rc_buildentry(S,rand(1,4))
		..()

/datum/rc_entry/itembypath/spacesuit
	name = "space suit"
	typepath = /obj/item/clothing/suit/space
	feemod = 430

/datum/rc_entry/itembypath/spacehelmet
	name = "space helmet"
	typepath = /obj/item/clothing/head/helmet/space
	feemod = 430

/datum/rc_entry/stack/steelsheet
	name = "NT-spec steel sheet"
	typepath = /obj/item/sheet/steel
	feemod = 15

ABSTRACT_TYPE(/datum/rc_entry/itembypath/basictool)
/datum/rc_entry/itembypath/basictool/crowbar
	name = "crowbar"
	typepath = /obj/item/crowbar
	feemod = 90

/datum/rc_entry/itembypath/basictool/screwdriver
	name = "screwdriver"
	typepath = /obj/item/screwdriver
	feemod = 110

/datum/rc_entry/itembypath/basictool/wirecutters
	name = "wirecutters"
	typepath = /obj/item/wirecutters
	feemod = 120

/datum/rc_entry/itembypath/basictool/wrench
	name = "wrench"
	typepath = /obj/item/wrench
	feemod = 110

/datum/rc_entry/itembypath/basictool/welder
	name = "welding tool"
	typepath = /obj/item/weldingtool
	feemod = 160



/datum/req_contract/aid/triage
	name = "Medical Aid"
	payout = 1100
	var/list/namevary = list("Medical Aid","Medical Emergency","Triage Support","Aid Request","Critical Condition")
	var/list/desc0 = list("A medical facility","An affiliated station's medical bay","A triage center","A medical outpost","Our nearest station")
	var/list/desc1 = list("to assist with","after heavy load due to","to restock after")
	var/list/desc2 = list(
		"treatment of injuries from a skirmish",
		"a mining accident that left several wounded",
		"station unrest leading to multiple assaults",
		"tending to victims of a chemical spill",
		"treatment of wounds sustained during a Syndicate incursion",
		"a Space Wizard Federation encounter",
		"intensive care of several burn victims"
	)
	var/list/desc3 = list(
		"Please assemble the listed equipment as soon as possible.",
		"Expedience is of the utmost importance.",
		"No other transmission from the facility has been able to reach us.",
		"Further wounded may be arriving soon.",
		"Several individuals are yet unaccounted for, and may require care."
	)

	New()
		src.name = pick(namevary)
		src.flavor_desc = "[pick(desc0)] requires additional supplies [pick(desc1)] [pick(desc2)]. [pick(desc3)]"
		src.payout += rand(0,40) * 10

		for(var/S in concrete_typesof(/datum/rc_entry/itembypath/surgical))
			if(prob(50))
				src.rc_entries += rc_buildentry(S,rand(1,4))

		if(prob(80))
			src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/bandage,rand(3,8))
		else
			src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/hypospray,rand(2,5))

		if(prob(70))
			src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/lgloves,rand(3,8))
		else
			src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/med_analyzer,rand(2,5))
		..()

ABSTRACT_TYPE(/datum/rc_entry/itembypath/surgical)
/datum/rc_entry/itembypath/surgical
	feemod = 90

	scalpel
		name = "scalpel"
		typepath = /obj/item/scalpel

	saw
		name = "circular saw"
		feemod = 110
		typepath = /obj/item/circular_saw

	scissors
		name = "surgical scissors"
		typepath = /obj/item/scissors/surgical_scissors

	hemostat
		name = "hemostat"
		typepath = /obj/item/hemostat

	suture
		name = "suture"
		typepath = /obj/item/suture

	stapler
		name = "staple gun"
		feemod = 180
		typepath = /obj/item/staple_gun

/datum/rc_entry/itembypath/bandage
	name = "bandage roll"
	feemod = 80
	typepath = /obj/item/bandage

/datum/rc_entry/itembypath/lgloves
	name = "latex glove pair"
	feemod = 70
	typepath = /obj/item/clothing/gloves/latex

/datum/rc_entry/itembypath/hypospray
	name = "hypospray"
	feemod = 260
	typepath = /obj/item/reagent_containers/hypospray

/datum/rc_entry/itembypath/med_analyzer
	name = "health analyzer"
	feemod = 350
	typepath = /obj/item/device/analyzer/healthanalyzer



/datum/req_contract/aid/geeksquad
	name = "Computer Failure"
	payout = 900
	var/list/namevary = list("Systems Failure","Short Circuit","Computer Overload","Electronics Failure","Systems Breakdown")
	var/list/desc0 = list("research","mining","security","cargo transfer","communications","deep-space survey")
	var/list/desc1 = list("vessel","ship","station","outpost")
	var/list/desc2 = list("experienced","lost systems control due to","ceased operation after","suffered a power surge resulting in")
	var/list/desc3 = list("severe damage to","near-total failure of","erratic behavior in","considerable damage to","concerning readings from")
	var/list/desc4 = list(
		"atmospheric monitoring systems",
		"short-range communications",
		"grid regulation systems",
		"main computer core",
		"lighting control system",
		"espresso machine",
		"gyroscopic stabilizers",
		"adjustment thruster controls",
		"docking guidance computer",
		"atmospheric regulators",
		"carbon dioxide scrubbers",
		"proximity sensors",
		"artificial intelligence core")
	var/list/desc5 = list(
		"Expedience is of the utmost importance.",
		"Further systems failures are expected if the issue is not rectified.",
		"The situation is stable for now, but will likely deteriorate if repairs do not begin promptly.",
		"Ensure shipping container meets standard ESD protection specifications.",
		"Where applicable, please update firmware on included items.",
		"The system is hard-wired into several others, and malfunctions may propagate if not repaired."
	)

	New()
		src.name = pick(namevary)
		src.flavor_desc = "An affiliated [pick(desc0)] [pick(desc1)] has [pick(desc2)] [pick(desc3)] its [pick(desc4)]. [pick(desc5)]"
		src.payout += rand(0,40) * 10

		if(prob(70)) src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/mainboard,rand(1,3))
		if(prob(60))
			if(prob(40))
				src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/cardscan,1)
			else
				src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/netcard,1)

		if(!length(src.rc_entries)) src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/interfaceboard,1)

		if(prob(50)) src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/basictool/screwdriver,1)
		if(prob(50)) src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/basictool/wirecutters,1)
		if(prob(50)) src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/t_ray,rand(1,2))
		if(prob(60)) src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/soldering,rand(1,2))
		if(prob(60)) src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/multitool,1)
		if(prob(70)) src.rc_entries += rc_buildentry(/datum/rc_entry/stack/cable,rand(8,25))

		..()

/datum/rc_entry/itembypath/mainboard
	name = "computer mainboard"
	typepath = /obj/item/motherboard
	feemod = 320

/datum/rc_entry/itembypath/cardscan
	name = "ID scanner module"
	typepath = /obj/item/peripheral/card_scanner
	exactpath = TRUE
	feemod = 360

/datum/rc_entry/itembypath/netcard
	name = "wired network card"
	typepath = /obj/item/peripheral/network/powernet_card
	exactpath = TRUE
	feemod = 340

/datum/rc_entry/itembypath/interfaceboard
	name = "AI interface board"
	typepath = /obj/item/ai_interface
	feemod = 750

/datum/rc_entry/itembypath/t_ray
	name = "T-ray scanner"
	typepath = /obj/item/device/t_scanner
	feemod = 340

/datum/rc_entry/itembypath/soldering
	name = "soldering iron"
	typepath = /obj/item/electronics/soldering
	feemod = 260

/datum/rc_entry/itembypath/multitool
	name = "multitool"
	typepath = /obj/item/device/multitool
	feemod = 450

/datum/rc_entry/stack/cable
	name = "lengths of electrical cabling"
	typepath = /obj/item/cable_coil
	feemod = 30



/datum/req_contract/aid/supplyshort
	name = "Supply Chain Failure"
	payout = 800
	var/list/namevary = list("Urgent Restock","Supply Crisis","Supply Chain Failure","Short Stock","Emergency Resupply")
	var/list/desc0 = list("research","mining","hydroponics","civilian","Nanotrasen")
	var/list/desc1 = list("vessel","station","outpost","colony")
	var/list/desc2 = list("food","rations","food and water","furnace fuel","liquid fuel","coffee","medical herbs")
	var/list/desc3 = list("after","due to","following")
	var/list/desc4 = list(
		"its regular supply shuttle experiencing a disastrous hull breach",
		"catastrophic damage to a storage bay",
		"a ransacking by an unknown assailant",
		"an influx of personnel rescued from a damaged vessel",
		"a nearby station's purchase of almost all available supply, skyrocketing prices",
		"theft by a group of disgruntled personnel"
	)
	var/list/desc5 = list(
		null,
		" Please assemble the listed items as soon as possible.",
		" The urgency of this request cannot be overstated.",
		" Supplies are only expected to last a few more days.",
		" If the shortage gets much worse, unrest will likely escalate into a riot.",
		" No further transmission has been sent since requisition posting."
	)

	New()
		src.name = pick(namevary)
		var/tilter = pick(desc2)
		src.flavor_desc = "An affiliated [pick(desc0)] [pick(desc1)] is experiencing a severe shortage of [tilter] [pick(desc3)] [pick(desc4)].[pick(desc5)]"
		src.payout += rand(0,40) * 10

		switch(tilter)
			if("food","rations")
				src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/literallyanyfood,rand(30,48))
			if("food and water")
				src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/literallyanyfood,rand(24,40))
				src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/water,rand(18,36)*10)
			if("furnace fuel")
				src.rc_entries += rc_buildentry(/datum/rc_entry/stack/char,rand(24,36))
			if("liquid fuel")
				src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/fuel,rand(40,60)*10)
			if("coffee")
				src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/coffee,rand(24,36)*10)
			if("medical herbs")
				src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/medherb/alpha,rand(12,18))
				if(prob(60))
					src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/medherb/beta,rand(12,18))
				else
					src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/medherb/gamma,rand(8,14))

		..()

/datum/rc_entry/stack/char
	name = "char ore"
	typepath = /obj/item/raw_material/char
	feemod = 90

/datum/rc_entry/reagent/fuel
	name = "welding-grade liquid fuel"
	chemname = "fuel"
	feemod = 4

/datum/rc_entry/reagent/coffee //TEST THIS COFFEE, TEST NEW CHECK PROTOCOL. DEBUG DEBUG DEBUG
	name = "coffee"
	chemname = list(
		"coffee",
		"coffee_fresh",
		"espresso",
		"expresso",
		"energydrink"
	)
	feemod = 4

/datum/rc_entry/itembypath/medherb
	name = "medical herb"
	typepath = /obj/item/plant/herb
	feemod = 140
	var/list/herblist = list()

	alpha
		herblist = list(
			/obj/item/plant/herb/asomna,
			/obj/item/plant/herb/commol,
			/obj/item/plant/herb/contusine
		)

	beta
		herblist = list(
			/obj/item/plant/herb/mint,
			/obj/item/plant/herb/nureous,
			/obj/item/plant/herb/venne
		)

	gamma
		herblist = list(
			/obj/item/plant/herb/cannabis,
			/obj/item/plant/herb/sassafras,
			/obj/item/plant/herb/tobacco
		)

	New()
		var/obj/plantalyze = pick(src.herblist)
		src.name = initial(plantalyze.name)
		src.typepath = plantalyze
		..()

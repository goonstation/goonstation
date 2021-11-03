ABSTRACT_TYPE(/datum/req_contract/aid)
/datum/req_contract/aid //in your final hour, astral wolf...
	req_class = AID_CONTRACT

/datum/req_contract/aid/wrecked
	//name = "Breach Recovery"
	payout = 3000
	var/list/namevary = list("Breach Recovery","Breach Response","Integrity Failure","Crisis Response","Disaster Assistance","Disaster Response")
	var/list/desc_placejob = list("research","mining","security","cargo transfer")
	var/list/desc_placetype = list("vessel","ship","station","outpost")
	var/list/desc_enhancer1 = list("suffered","experienced","been damaged by","incurred")
	var/list/desc_enhancer2 = list("severe","catastrophic","hazardous","critical","disastrous")
	var/list/desc_whatborked = list("reactor failure","hull breach","core breach","hull rupture","gravimetric shear","collision","canister explosion")

	New()
		src.name = pick(namevary)
		src.flavor_desc = "An affiliated [pick(desc_placejob)] [pick(desc_placetype)] has [pick(desc_enhancer1)] a [pick(desc_enhancer2)] [pick(desc_whatborked)]"
		src.flavor_desc += " and requires repair supplies as soon as possible."
		src.payout += rand(0,60) * 10

		var/suitsets = rand(2,4)

		src.rc_entries += rc_buildentry(/datum/rc_entry/item/spacesuit,suitsets)
		src.rc_entries += rc_buildentry(/datum/rc_entry/item/spacehelmet,suitsets)

		if(prob(70)) src.rc_entries += rc_buildentry(/datum/rc_entry/stack/steelsheet,rand(5,35)*2)

		for(var/S in concrete_typesof(/datum/rc_entry/item/basictool))
			if(prob(70))
				src.rc_entries += rc_buildentry(S,rand(1,4))
		..()

/datum/rc_entry/item/spacesuit
	name = "space suit"
	typepath = /obj/item/clothing/suit/space
	feemod = 630

/datum/rc_entry/item/spacehelmet
	name = "space helmet"
	typepath = /obj/item/clothing/head/helmet/space
	feemod = 630

/datum/rc_entry/stack/steelsheet
	name = "NT-spec steel sheet"
	typepath = /obj/item/sheet/steel
	feemod = 15

ABSTRACT_TYPE(/datum/rc_entry/item/basictool)
/datum/rc_entry/item/basictool/crowbar
	name = "crowbar"
	typepath = /obj/item/crowbar
	feemod = 130

/datum/rc_entry/item/basictool/screwdriver
	name = "screwdriver"
	typepath = /obj/item/screwdriver
	feemod = 140

/datum/rc_entry/item/basictool/wirecutters
	name = "wirecutters"
	typepath = /obj/item/wirecutters
	feemod = 140

/datum/rc_entry/item/basictool/wrench
	name = "wrench"
	typepath = /obj/item/wrench
	feemod = 140

/datum/rc_entry/item/basictool/welder
	name = "welding tool"
	typepath = /obj/item/weldingtool
	feemod = 220



/datum/req_contract/aid/triage
	//name = "Medical Aid"
	payout = 3000
	var/list/namevary = list("Medical Aid","Medical Emergency","Triage Support","Aid Request","Critical Condition")
	var/list/desc_helpsite = list("A medical facility","An affiliated station's medical bay","A triage center","A medical outpost","Our nearest station")
	var/list/desc_tense = list("to assist with","after heavy load due to","to restock after")
	var/list/desc_crisis = list(
		"treatment of injuries from a skirmish",
		"a mining accident that left several wounded",
		"station unrest leading to multiple assaults",
		"tending to victims of a chemical spill",
		"treatment of wounds sustained during a Syndicate incursion",
		"a Space Wizard Federation encounter",
		"intensive care of several burn victims"
	)
	var/list/desc_emphasis = list(
		"Please assemble the listed equipment as soon as possible.",
		"Expedience is of the utmost importance.",
		"No other transmission from the facility has been able to reach us.",
		"Further wounded may be arriving soon.",
		"Several individuals are yet unaccounted for, and may require care."
	)

	New()
		src.name = pick(namevary)
		src.flavor_desc = "[pick(desc_helpsite)] requires additional supplies [pick(desc_tense)] [pick(desc_crisis)]. [pick(desc_emphasis)]"
		src.payout += rand(0,40) * 10

		for(var/S in concrete_typesof(/datum/rc_entry/item/surgical))
			if(prob(50))
				src.rc_entries += rc_buildentry(S,rand(1,4))

		if(prob(80))
			src.rc_entries += rc_buildentry(/datum/rc_entry/item/bandage,rand(3,8))
		else
			src.rc_entries += rc_buildentry(/datum/rc_entry/item/hypospray,rand(2,5))

		if(prob(70))
			src.rc_entries += rc_buildentry(/datum/rc_entry/item/lgloves,rand(3,8))
		else
			src.rc_entries += rc_buildentry(/datum/rc_entry/item/med_analyzer,rand(2,5))
		..()

ABSTRACT_TYPE(/datum/rc_entry/item/surgical)
/datum/rc_entry/item/surgical
	feemod = 180

	scalpel
		name = "scalpel"
		typepath = /obj/item/scalpel

	saw
		name = "circular saw"
		feemod = 190
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
		feemod = 330
		typepath = /obj/item/staple_gun

/datum/rc_entry/item/bandage
	name = "bandage roll"
	feemod = 210
	typepath = /obj/item/bandage

/datum/rc_entry/item/lgloves
	name = "latex glove pair"
	feemod = 150
	typepath = /obj/item/clothing/gloves/latex

/datum/rc_entry/item/hypospray
	name = "hypospray"
	feemod = 350
	typepath = /obj/item/reagent_containers/hypospray

/datum/rc_entry/item/med_analyzer
	name = "health analyzer"
	feemod = 600
	typepath = /obj/item/device/analyzer/healthanalyzer



/datum/req_contract/aid/geeksquad
	//name = "Computer Failure"
	payout = 2500
	var/list/namevary = list("Systems Failure","Short Circuit","Computer Overload","Electronics Failure","Systems Breakdown")
	var/list/desc_wherebork = list("research","mining","security","cargo transfer","communications","deep-space survey")
	var/list/desc_whobork = list("vessel","ship","station","outpost")
	var/list/desc_whybork = list("experienced","lost systems control due to","ceased operation after","suffered a power surge resulting in")
	var/list/desc_howmuchbork = list("severe damage to","near-total failure of","erratic behavior in","considerable damage to","concerning readings from")
	var/list/desc_sys = list(
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
	var/list/desc_emphasis = list(
		"Expedience is of the utmost importance.",
		"Further systems failures are expected if the issue is not rectified.",
		"The situation is stable for now, but will likely deteriorate if repairs do not begin promptly.",
		"Ensure shipping container meets standard ESD protection specifications.",
		"Where applicable, please update firmware on included items.",
		"The system is hard-wired into several others, and malfunctions may propagate if not repaired."
	)

	New()
		src.name = pick(namevary)
		src.flavor_desc = "An affiliated [pick(desc_wherebork)] [pick(desc_whobork)] has [pick(desc_whybork)] [pick(desc_howmuchbork)] its [pick(desc_sys)]. [pick(desc_emphasis)]"
		src.payout += rand(0,40) * 10

		if(prob(70)) src.rc_entries += rc_buildentry(/datum/rc_entry/item/mainboard,rand(1,3))
		if(prob(60))
			if(prob(40))
				src.rc_entries += rc_buildentry(/datum/rc_entry/item/cardscan,1)
			else
				src.rc_entries += rc_buildentry(/datum/rc_entry/item/netcard,1)

		if(!length(src.rc_entries)) src.rc_entries += rc_buildentry(/datum/rc_entry/item/interfaceboard,1)

		if(prob(50)) src.rc_entries += rc_buildentry(/datum/rc_entry/item/basictool/screwdriver,1)
		if(prob(50)) src.rc_entries += rc_buildentry(/datum/rc_entry/item/basictool/wirecutters,1)
		if(prob(50)) src.rc_entries += rc_buildentry(/datum/rc_entry/item/t_ray,rand(1,2))
		if(prob(60)) src.rc_entries += rc_buildentry(/datum/rc_entry/item/soldering,rand(1,2))
		if(prob(60)) src.rc_entries += rc_buildentry(/datum/rc_entry/item/multitool,1)
		if(prob(70)) src.rc_entries += rc_buildentry(/datum/rc_entry/stack/cable,rand(8,25))

		..()

/datum/rc_entry/item/mainboard
	name = "computer mainboard"
	typepath = /obj/item/motherboard
	feemod = 520

/datum/rc_entry/item/cardscan
	name = "ID scanner module"
	typepath = /obj/item/peripheral/card_scanner
	exactpath = TRUE
	feemod = 560

/datum/rc_entry/item/netcard
	name = "wired network card"
	typepath = /obj/item/peripheral/network/powernet_card
	exactpath = TRUE
	feemod = 540

/datum/rc_entry/item/interfaceboard
	name = "AI interface board"
	typepath = /obj/item/ai_interface
	feemod = 1250

/datum/rc_entry/item/t_ray
	name = "T-ray scanner"
	typepath = /obj/item/device/t_scanner
	feemod = 340

/datum/rc_entry/item/soldering
	name = "soldering iron"
	typepath = /obj/item/electronics/soldering
	feemod = 260

/datum/rc_entry/item/multitool
	name = "multitool"
	typepath = /obj/item/device/multitool
	feemod = 450

/datum/rc_entry/stack/cable
	name = "lengths of electrical cabling"
	typepath = /obj/item/cable_coil
	feemod = 30



/datum/req_contract/aid/supplyshort
	//name = "Supply Chain Failure"
	payout = 2400
	var/list/namevary = list("Urgent Restock","Supply Crisis","Supply Chain Failure","Short Stock","Emergency Resupply")
	var/list/desc_placejob = list("research","mining","hydroponics","civilian","Nanotrasen")
	var/list/desc_place = list("vessel","station","outpost","colony")
	var/list/desc_shortage = list("food","rations","food and water","furnace fuel","liquid fuel","coffee","certain herbs")
	var/list/desc_after = list("after","due to","following")
	var/list/desc_whybork = list(
		"its regular supply shuttle experiencing a disastrous hull breach",
		"catastrophic damage to a storage bay",
		"a ransacking by an unknown assailant",
		"an influx of personnel rescued from a damaged vessel",
		"a nearby station's purchase of almost all available supply, skyrocketing prices",
		"theft by a group of disgruntled personnel"
	)
	var/list/desc_emphasis = list(
		null,
		" Please assemble the listed items as soon as possible.",
		" The urgency of this request cannot be overstated.",
		" Supplies are only expected to last a few more days.",
		" If the shortage gets much worse, unrest will likely escalate into a riot.",
		" No further transmission has been sent since requisition posting."
	)

	New()
		src.name = pick(namevary)
		var/tilter = pick(desc_shortage)
		src.flavor_desc = "An affiliated [pick(desc_placejob)] [pick(desc_place)] is experiencing"
		src.flavor_desc += " a severe shortage of [tilter] [pick(desc_after)] [pick(desc_whybork)].[pick(desc_emphasis)]"
		src.payout += rand(0,40) * 10

		switch(tilter)
			if("food","rations")
				src.rc_entries += rc_buildentry(/datum/rc_entry/item/literallyanyfood,rand(30,48))
			if("food and water")
				src.rc_entries += rc_buildentry(/datum/rc_entry/item/literallyanyfood,rand(24,40))
				src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/water,rand(18,36)*10)
			if("furnace fuel")
				src.rc_entries += rc_buildentry(/datum/rc_entry/stack/char,rand(24,36))
			if("liquid fuel")
				src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/fuel,rand(40,60)*10)
			if("coffee")
				src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/coffee,rand(24,36)*10)
			if("certain herbs")
				src.rc_entries += rc_buildentry(/datum/rc_entry/item/medherb/alpha,rand(12,18))
				if(prob(60))
					src.rc_entries += rc_buildentry(/datum/rc_entry/item/medherb/beta,rand(12,18))
				else
					src.rc_entries += rc_buildentry(/datum/rc_entry/item/medherb/gamma,rand(8,14))

		..()

/datum/rc_entry/stack/char
	name = "char ore"
	commodity = /datum/commodity/ore/char
	feemod = 50

/datum/rc_entry/reagent/fuel
	name = "welding-grade liquid fuel"
	chemname = "fuel"
	feemod = 6

/datum/rc_entry/reagent/coffee
	name = "coffee"
	chemname = list(
		"coffee",
		"coffee_fresh",
		"espresso",
		"expresso",
		"energydrink"
	)
	feemod = 5

/datum/rc_entry/item/medherb
	name = "medical herb"
	typepath = /obj/item/plant/herb
	commodity = /datum/commodity/herbs
	feemod = 80
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

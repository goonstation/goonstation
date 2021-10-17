ABSTRACT_TYPE(/datum/req_contract/aid)
/datum/req_contract/aid //in your final hour, astral wolf...
	req_class = 2

/datum/req_contract/aid/wrecked
	name = "Breach Recovery"
	payout = 1000
	var/list/namevary = list("Breach Recovery","Breach Response","Integrity Failure","Crisis Response","Disaster Assistance","Disaster Response")
	var/list/desc0 = list("research","mining","security","cargo transfer")
	var/list/desc1 = list("vessel","ship","station","outpost")
	var/list/desc2 = list("suffered","experienced","been damaged by","incurred")
	var/list/desc3 = list("severe","catastrophic","hazardous","critical","disastrous")
	var/list/desc4 = list("reactor failure","hull breach","core breach","hull rupture","gravimetric shear","collision","canister explosion")

	New()
		src.name = pick(namevary)
		src.flavor_desc = "An affiliated [pick(desc0)] [pick(desc1)] has [pick(desc2)] a [pick(desc3)] [pick(desc4)] and requires repair supplies as soon as possible."
		src.payout += rand(0,80) * 10

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
	feemod = 70

/datum/rc_entry/itembypath/basictool/screwdriver
	name = "screwdriver"
	typepath = /obj/item/screwdriver
	feemod = 90

/datum/rc_entry/itembypath/basictool/wirecutters
	name = "wirecutters"
	typepath = /obj/item/wirecutters
	feemod = 90
	isplural = TRUE

/datum/rc_entry/itembypath/basictool/wrench
	name = "wrench"
	typepath = /obj/item/wrench
	feemod = 80
	es = TRUE

/datum/rc_entry/itembypath/basictool/welder
	name = "welding tool"
	typepath = /obj/item/weldingtool
	feemod = 160

/datum/req_contract/aid/triage
	name = "Medical Aid"
	payout = 1500
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
		src.payout += rand(0,80) * 10

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
		isplural = TRUE

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
	feemod = 220
	typepath = /obj/item/device/analyzer/healthanalyzer

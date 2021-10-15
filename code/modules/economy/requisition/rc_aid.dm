ABSTRACT_TYPE(/datum/req_contract/aid)
/datum/req_contract/aid

/datum/req_contract/aid/wrecked
	name = "Breach Recovery"
	payout = 5000
	var/list/desc0 = list("research","mining","security","cargo transfer")
	var/list/desc1 = list("vessel","ship","station","outpost")
	var/list/desc2 = list("severe","catastrophic","hazardous","critical","disastrous")
	var/list/desc3 = list("reactor failure","integrity breach","core breach","hull rupture","gravimetric shear","collision","canister explosion")

	New()
		src.flavor_desc = "An affiliated [pick(desc0)] [pick(desc1)] has suffered a [pick(desc2)] [pick(desc3)] and requires recovery supplies as soon as possible."
		src.payout += rand(0,200) * 10

		var/suitsets = rand(2,5)
		var/datum/rc_entry/ssuit = new /datum/rc_entry/itembypath/spacesuit
		ssuit.count = suitsets
		src.rc_entries += ssuit

		var/datum/rc_entry/shelm = new /datum/rc_entry/itembypath/spacehelmet
		shelm.count = suitsets
		src.rc_entries += shelm

		for(var/S in concrete_typesof(/datum/rc_entry/itembypath/basictool))
			var/datum/rc_entry/crow = new S()
			crow.count = rand(1,6)
			src.rc_entries += crow
		..()

/datum/rc_entry/itembypath/spacesuit
	name = "space suit"
	typepath = /obj/item/clothing/suit/space
	feemod = 440

/datum/rc_entry/itembypath/spacehelmet
	name = "space helmet"
	typepath = /obj/item/clothing/head/helmet/space
	feemod = 440

ABSTRACT_TYPE(/datum/rc_entry/itembypath/basictool)
/datum/rc_entry/itembypath/basictool/crowbar
	name = "crowbar"
	typepath = /obj/item/crowbar
	feemod = 120

/datum/rc_entry/itembypath/basictool/screwdriver
	name = "screwdriver"
	typepath = /obj/item/screwdriver
	feemod = 120

/datum/rc_entry/itembypath/basictool/wirecutters
	name = "wirecutters"
	typepath = /obj/item/wirecutters
	feemod = 120
	isplural = TRUE

/datum/rc_entry/itembypath/basictool/wrench
	name = "wrench"
	typepath = /obj/item/wrench
	feemod = 120
	es = TRUE

/datum/rc_entry/itembypath/basictool/welder
	name = "welding tool"
	typepath = /obj/item/weldingtool
	feemod = 180

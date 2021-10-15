ABSTRACT_TYPE(/datum/req_contract/civilian)
/datum/req_contract/civilian

/datum/req_contract/civilian/slumberparty
	name = "Slumber Party"
	payout = 1000
	var/list/desc0 = list("space ranchers","monkey monks","self-styled Rad Dudes","freelancers","Stations and Syndicates enthusiasts")
	var/list/desc1 = list("quiet","relaxing","radical","most excellent","tubular","bodacious","zesty","robust")
	var/list/desc2 = list("sleepover","hangout session","slumber party","stay-over convention")

	New()
		src.flavor_desc = "A group of [pick(desc0)] seek to host a [pick(desc1)] [pick(desc2)], and require comfort supplies to this end."
		src.payout += rand(0,50) * 10

		var/datum/rc_entry/sheets = new /datum/rc_entry/itembypath/bedsheet
		sheets.count = rand(4,8)
		src.rc_entries += sheets

		var/pajamasets = rand(1,5)
		var/datum/rc_entry/jammies = new /datum/rc_entry/itembypath/pajamas
		jammies.count = pajamasets
		src.rc_entries += jammies
		if(prob(60))
			var/datum/rc_entry/hats = new /datum/rc_entry/itembypath/pajamas
			hats.count = pajamasets
			src.rc_entries += hats
		..()

/datum/rc_entry/itembypath/bedsheet
	name = "Bedsheet"
	typepath = /obj/item/clothing/suit/bedsheet
	feemod = 180

/datum/rc_entry/itembypath/pajamas
	name = "Pajamas"
	typepath = /obj/item/clothing/under/gimmick/pajamas
	feemod = 280
	isplural = TRUE

/datum/rc_entry/itembypath/bedsheet
	name = "Nightcap"
	typepath = /obj/item/clothing/head/pajama_cap
	feemod = 240

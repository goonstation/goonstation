ABSTRACT_TYPE(/datum/req_contract/civilian)
/datum/req_contract/civilian
/*
/datum/req_contract/civilian/slumber_party
	name = "Slumber Party"
	payout = 1000
	var/list/desc0 = list("space ranchers","monkey monks","self-styled Rad Dudes","freelancers","Stations and Syndicates enthusiasts")
	var/list/desc1 = list("quiet","relaxing","radical","most excellent","tubular","bodacious","zesty","robust")
	var/list/desc2 = list("sleepover","hangout session","slumber party","stay-over convention")

	New()
		src.flavor_desc = "A group of [pick(desc0)] seek to host a [pick(desc1)] [pick(desc2)], and require supplies to this end."
		src.payout += rand(0,50) * 10

		var/datum/rc_entry/sheets = new /datum/rc_entry/itembypath/bedsheet
		sheets.count = rand(4,8)
		src.rc_entries += sheets

		var/pajamasets = rand(1,5)
		var/datum/rc_entry/jammies = new /datum/rc_entry/itembypath/pajamas
		jammies.count = pajamasets
		src.rc_entries += jammies
		if(prob(60))
			var/datum/rc_entry/hats = new /datum/rc_entry/itembypath/pajamacap
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

/datum/rc_entry/itembypath/pajamacap
	name = "Nightcap"
	typepath = /obj/item/clothing/head/pajama_cap
	feemod = 240
*/

/datum/req_contract/civilian/event_catering
	name = "Event Catering"
	payout = 500

	var/list/desc0 = list("reception","formal event","welcoming party","going-away party","commemorative dinner","dinner")
	var/list/desc1 = list("an esteemed","an infamous","a famous","a renowned")
	var/list/desc2 = list(" Nanotrasen"," Martian"," freelancing"," frontier"," - if only barely -","-in-their-field")
	var/list/desc3 = list("researcher","technician","clown","soldier","medic","surgeon","freighter captain","rescue crew","mariachi band","comedian")

	New()
		src.flavor_desc = "A [pick(desc0)] is being held for [pick(desc1)][pick(desc2)] [pick(desc3)]. Catering services are requested posthaste."
		src.payout += rand(0,50) * 10

		for(var/S in concrete_typesof(/datum/rc_entry/itembypath/caterfood))
			if(prob(60))
				var/datum/rc_entry/burg = new S()
				burg.count = rand(8,16)
				src.rc_entries += burg

		if(!length(src.rc_entries))
			var/datum/rc_entry/wich = new /datum/rc_entry/itembypath/caterfood/sandwich
			wich.count = rand(16,30)
			src.rc_entries += wich

		for(var/S in concrete_typesof(/datum/rc_entry/reagent/caterdrink))
			if(prob(40))
				var/datum/rc_entry/bev = new S()
				bev.count = rand(3,10) * 10
				src.rc_entries += bev
		..()

ABSTRACT_TYPE(/datum/rc_entry/itembypath/caterfood)
/datum/rc_entry/itembypath/caterfood/sandwich
	name = "sandwich"
	typepath = /obj/item/reagent_containers/food/snacks/sandwich
	feemod = 330
	es = TRUE

/datum/rc_entry/itembypath/caterfood/burger
	name = "burger"
	typepath = /obj/item/reagent_containers/food/snacks/burger
	feemod = 330

/datum/rc_entry/itembypath/caterfood/soup
	name = "pre-portioned soup bowl"
	typepath = /obj/item/reagent_containers/food/snacks/soup
	feemod = 280

/datum/rc_entry/itembypath/caterfood/salad
	name = "pre-portioned salad"
	typepath = /obj/item/reagent_containers/food/snacks/salad
	feemod = 240

ABSTRACT_TYPE(/datum/rc_entry/reagent/caterdrink)
/datum/rc_entry/reagent/caterdrink/appletini
	name = "appletini"
	chemname = "appletini"
	feemod = 50

/datum/rc_entry/reagent/caterdrink/fruitpunch
	name = "fruit punch"
	chemname = "fruit_punch"
	feemod = 60

/datum/rc_entry/reagent/caterdrink/margarita
	name = "margarita"
	chemname = "margarita"
	feemod = 30

/datum/rc_entry/reagent/caterdrink/champagne
	name = "champagne"
	chemname = "champagne"
	feemod = 30


//NEEDS STACK TO WORK
/datum/req_contract/civilian/furnishing
	name = "Interior Outfitting"
	payout = 800
	var/list/desc0 = list("A new gaming","An extraction","A medical","A research","A cartographic","A transit")
	var/list/desc1 = list("vessel","station","platform","outpost")
	var/list/desc2 = list("its commissary","the docking wing","crew quarters","staff facilities","additional operating space","a storage bay")

	New()
		src.flavor_desc = "[pick(desc0)] [pick(desc1)] requires supplies to furnish [pick(desc2)]. Please use standard compact packing techniques."
		src.payout += rand(0,50) * 10

		if(prob(70))
			var/datum/rc_entry/furn = new /datum/rc_entry/itembypath/table
			furn.count = rand(2,8)
			src.rc_entries += furn
			var/datum/rc_entry/bern = new /datum/rc_entry/itembypath/chair
			bern.count = rand(4,12)
			src.rc_entries += bern
		else
			var/datum/rc_entry/floort = new /datum/rc_entry/stack/floortiles
			floort.count = rand(5,20) * 4
			src.rc_entries += floort
			var/datum/rc_entry/bark = new /datum/rc_entry/itembypath/basictool/crowbar //defined over in aid
			bark.count = rand(1,3)
			src.rc_entries += bark

		if(prob(70))
			var/datum/rc_entry/furn
			if(prob(40))
				furn = new /datum/rc_entry/itembypath/light_bulb
			else
				furn = new /datum/rc_entry/itembypath/light_tube
			furn.count = rand(1,4) * 7
			src.rc_entries += furn

		if(prob(60))
			var/datum/rc_entry/furn = new /datum/rc_entry/itembypath/rack
			furn.count = rand(2,8)
			src.rc_entries += furn

		if(prob(40))
			var/datum/rc_entry/carpent = new /datum/rc_entry/reagent/carpet
			carpent.count = rand(3,9) * 10
			src.rc_entries += carpent
		..()

/datum/rc_entry/stack/floortiles
	name = "floor tile"
	typepath = /obj/item/tile
	feemod = 20

/datum/rc_entry/reagent/carpet
	name = "liquid carpet"
	chemname = "carpet"
	feemod = 60

/datum/rc_entry/itembypath/table
	name = "table"
	typepath = /obj/item/furniture_parts/table
	feemod = 120

/datum/rc_entry/itembypath/rack
	name = "rack part set"
	typepath = /obj/item/furniture_parts/rack
	feemod = 100

/datum/rc_entry/itembypath/chair
	name = "folding chair"
	typepath = /obj/item/chair/folded
	feemod = 100

/datum/rc_entry/itembypath/light_bulb
	name = "light bulb"
	typepath = /obj/item/light/bulb
	feemod = 60

/datum/rc_entry/itembypath/light_tube
	name = "light bulb"
	typepath = /obj/item/light/tube
	feemod = 60

ABSTRACT_TYPE(/datum/req_contract/civilian)
/datum/req_contract/civilian
	req_class = 1

/datum/req_contract/civilian/event_catering
	name = "Event Catering"
	payout = 500
	var/list/desc0 = list("reception","formal event","welcoming party","going-away party","commemorative dinner","dinner")
	var/list/desc1 = list("an esteemed","an infamous","a famous","a renowned")
	var/list/desc2 = list(" Nanotrasen"," Martian"," freelancing"," frontier"," - if only barely -"," retired")
	var/list/desc3 = list("researcher","technician","clown","soldier","medic","surgeon","freighter captain","rescue crew","mariachi band","comedian")
	var/list/desc4 = list(
		"Catering services are requested posthaste.",
		"Please ensure goods are well-chilled before shipment.",
		"Inadequate cooking of shipped food will result in immediate retaliatory action.",
		"Deliver promptly.",
		"Please pack securely; cargo service to destination is unreliable.",
		"The guest of honor is mildly allergic to nuts. Prepare on cleaned surfaces.",
		"Prompt service may result in a thank-you letter, if the guest of honor sobers up for long enough.",
		"Stay excellent, cargo dudes.",
		"okay i gout out of the template. dont throw in any weed. it would be dope but they wouldnt sejd it to us."
	)

	New()
		src.flavor_desc = "A [pick(desc0)] is being held for [pick(desc1)][pick(desc2)] [pick(desc3)]. [pick(desc4)]"
		src.payout += rand(0,50) * 10

		for(var/S in concrete_typesof(/datum/rc_entry/itembypath/caterfood))
			if(prob(60))
				src.rc_entries += rc_buildentry(S,rand(8,16))

		if(!length(src.rc_entries))
			src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/caterfood/sandwich,rand(16,30))

		for(var/S in concrete_typesof(/datum/rc_entry/reagent/caterdrink))
			if(prob(40))
				src.rc_entries += rc_buildentry(S,rand(3,10) * 10)
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
			src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/table,rand(2,8))
			src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/chair,rand(4,12))
		else
			src.rc_entries += rc_buildentry(/datum/rc_entry/stack/floortiles,rand(5,20)*4)
			src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/basictool/crowbar,rand(1,3))

		if(prob(70))
			var/datum/rc_entry/furn
			if(prob(40))
				furn = new /datum/rc_entry/itembypath/light_bulb
			else
				furn = new /datum/rc_entry/itembypath/light_tube
			furn.count = rand(1,4) * 7
			src.rc_entries += furn

		if(prob(60))
			src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/rack,rand(2,8))

		if(prob(30))
			src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/carpet,rand(3,7) * 10)
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


/datum/req_contract/civilian/greytide
	name = "Crew Embarcation"
	payout = 700

	var/list/desc0 = list("mining","hydroponics","cargo handling","engineering","medical","research","cartographic")
	var/list/desc1 = list("vessel","station","platform","outpost")
	var/list/desc2 = list("hired","acquired","recruited","reassigned","graduated")
	var/list/desc3 = list("personnel","crew members","staff","interns")

	New()
		var/task = pick(desc0) //subvariation
		src.flavor_desc = "An affiliated [task] [pick(desc1)] requires sets of attire for newly [pick(desc2)] [pick(desc3)]."
		src.payout += rand(0,10) * 10

		var/crewcount = rand(4,12)

		//uniform pickin
		if(prob(70))
			switch(task)
				if("mining") src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/jumpsuit/orange,crewcount)
				if("hydroponics") src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/jumpsuit/green,crewcount)
				if("cargo handling") src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/jumpsuit/brown,crewcount)
				if("engineering") src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/jumpsuit/yellow,crewcount)
				if("medical") src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/jumpsuit/blue,crewcount)
				if("research") src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/jumpsuit/white,crewcount)
				if("cartographic") src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/jumpsuit,crewcount)
		else
			src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/jumpsuit/grey,crewcount)
		src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/shoes,crewcount)

		//job related gearsets should also be added here sometimes

		..()

/datum/rc_entry/itembypath/jumpsuit
	name = "black jumpsuit"
	feemod = 120

	white
		name = "white jumpsuit"
		typepath = /obj/item/clothing/under/color/white

	grey
		name = "grey jumpsuit"
		typepath = /obj/item/clothing/under/color/grey

	brown
		name = "brown jumpsuit"
		typepath = /obj/item/clothing/under/color/brown

	orange
		name = "orange jumpsuit"
		typepath = /obj/item/clothing/under/color/orange

	yellow
		name = "yellow jumpsuit"
		typepath = /obj/item/clothing/under/color/yellow

	green
		name = "green jumpsuit"
		typepath = /obj/item/clothing/under/color/green

	blue
		name = "blue jumpsuit"
		typepath = /obj/item/clothing/under/color/blue

/datum/rc_entry/itembypath/backpack
	name = "backpack"
	typepath = /obj/item/storage/backpack
	feemod = 250

/datum/rc_entry/itembypath/shoes
	name = "pair of shoes"
	typepath = /obj/item/clothing/shoes
	feemod = 110
	isplural = TRUE

ABSTRACT_TYPE(/datum/req_contract/civilian)
/datum/req_contract/civilian //masters of the three seashells
	req_class = CIV_CONTRACT

/datum/req_contract/civilian/event_catering
	name = "Event Catering"
	payout = 6000
	weight = 70
	var/list/desc_event = list("reception","formal event","welcoming party","going-away party","commemorative dinner","dinner")
	var/list/desc_honorific = list("an esteemed","an infamous","a famous","a renowned")
	var/list/desc_origin = list(" Nanotrasen"," Martian"," freelancing"," frontier"," - if only barely -"," retired")
	var/list/desc_role = list("researcher","technician","clown","soldier","medic","surgeon","freighter captain","rescue crew","mariachi band","comedian")
	var/list/desc_bonusflavor = list(
		"Catering services are requested posthaste.",
		"Please ensure goods are well-chilled before shipment.",
		"Inadequate cooking of shipped food will result in immediate retaliatory action.",
		"Deliver promptly.",
		"Please pack securely; cargo service to destination is unreliable.",
		"The guest of honor is mildly allergic to nuts. Prepare on cleaned surfaces.",
		"Prompt service may result in a thank-you letter, if the guest of honor sobers up for long enough.",
		"Message included from requisitioning entity: Stay excellent, cargo dudes.",
		"okay i gout out of the template. dont throw in any hogg. it would be dope but they wouldnt sejd it to us."
	)

	New()
		src.flavor_desc = "A [pick(desc_event)] is being held for [pick(desc_honorific)][pick(desc_origin)] [pick(desc_role)]. [pick(desc_bonusflavor)]"
		src.payout += rand(0,50) * 10

		for(var/S in concrete_typesof(/datum/rc_entry/item/caterfood))
			if(prob(60))
				src.rc_entries += rc_buildentry(S,rand(8,16))

		if(!length(src.rc_entries))
			src.rc_entries += rc_buildentry(/datum/rc_entry/item/caterfood/sandwich,rand(16,30))

		for(var/S in concrete_typesof(/datum/rc_entry/reagent/caterdrink))
			if(prob(40))
				src.rc_entries += rc_buildentry(S,rand(3,10) * 10)
		..()

ABSTRACT_TYPE(/datum/rc_entry/item/caterfood)
/datum/rc_entry/item/caterfood/sandwich
	name = "sandwich"
	typepath = /obj/item/reagent_containers/food/snacks/sandwich
	feemod = 330

/datum/rc_entry/item/caterfood/burger
	name = "burger"
	typepath = /obj/item/reagent_containers/food/snacks/burger
	feemod = 330

/datum/rc_entry/item/caterfood/soup
	name = "pre-portioned soup bowl"
	typepath = /obj/item/reagent_containers/food/snacks/soup
	feemod = 280

/datum/rc_entry/item/caterfood/salad
	name = "pre-portioned salad"
	typepath = /obj/item/reagent_containers/food/snacks/salad
	feemod = 250

ABSTRACT_TYPE(/datum/rc_entry/reagent/caterdrink)
/datum/rc_entry/reagent/caterdrink/appletini
	name = "appletini"
	chemname = "appletini"
	feemod = 30

/datum/rc_entry/reagent/caterdrink/fruitpunch
	name = "fruit punch"
	chemname = "fruit_punch"
	feemod = 30

/datum/rc_entry/reagent/caterdrink/spacecuba
	name = "space-cuba libre"
	chemname = "libre"
	feemod = 15

/datum/rc_entry/reagent/caterdrink/margarita
	name = "margarita"
	chemname = "margarita"
	feemod = 10

/datum/rc_entry/reagent/caterdrink/champagne
	name = "champagne"
	chemname = "champagne"
	feemod = 12


/datum/req_contract/civilian/furnishing
	//name = "Interior Outfitting"
	payout = 2200
	var/list/namevary = list("Interior Outfitting","Furnishing Assistance","Interior Decorating","Occupancy Preparations","Last-Minute Furnishing")
	var/list/desc_whatitdoes = list("A new gaming","An extraction","A medical","A research","A cartographic","A transit")
	var/list/desc_whatitis = list("vessel","station","platform","outpost")
	var/list/desc_furnroom = list("its commissary","the docking wing","crew quarters","staff facilities","additional operating space","a storage bay")

	New()
		src.name = pick(namevary)
		src.flavor_desc = "[pick(desc_whatitdoes)] [pick(desc_whatitis)] requires supplies to furnish [pick(desc_furnroom)]. Please use standard compact packing techniques."
		src.payout += rand(0,50) * 10

		if(prob(70))
			var/datum/rc_entry/furn
			if(prob(40))
				furn = new /datum/rc_entry/item/light_bulb
			else
				furn = new /datum/rc_entry/item/light_tube
			furn.count = rand(1,4) * 7
			src.rc_entries += furn

		if(prob(60))
			src.rc_entries += rc_buildentry(/datum/rc_entry/item/rack,rand(2,8))

		if(!length(src.rc_entries) || prob(30))
			src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/carpet,rand(3,7) * 10)

		if(prob(70))
			src.rc_entries += rc_buildentry(/datum/rc_entry/item/table,rand(2,8))
			src.rc_entries += rc_buildentry(/datum/rc_entry/item/chair,rand(4,12))
			src.rc_entries += rc_buildentry(/datum/rc_entry/item/basictool/wrench,rand(1,3))
		else
			src.rc_entries += rc_buildentry(/datum/rc_entry/stack/floortiles,rand(5,20)*4)
			src.rc_entries += rc_buildentry(/datum/rc_entry/item/basictool/crowbar,rand(1,3))
		..()

/datum/rc_entry/stack/floortiles
	name = "floor tile"
	typepath = /obj/item/tile
	feemod = 20

/datum/rc_entry/reagent/carpet
	name = "liquid carpet"
	chemname = "carpet"
	feemod = 60

/datum/rc_entry/item/table
	name = "table"
	typepath = /obj/item/furniture_parts/table
	feemod = 220

/datum/rc_entry/item/rack
	name = "rack part set"
	typepath = /obj/item/furniture_parts/rack
	feemod = 180

/datum/rc_entry/item/chair
	name = "folding chair"
	typepath = /obj/item/chair/folded
	feemod = 190

/datum/rc_entry/item/light_bulb
	name = "light bulb"
	typepath = /obj/item/light/bulb
	feemod = 60

/datum/rc_entry/item/light_tube
	name = "light bulb"
	typepath = /obj/item/light/tube
	feemod = 60


/datum/req_contract/civilian/greytide
	//name = "Crew Embarcation"
	payout = 1500
	var/list/namevary = list("Crew Embarcation","Crew Onboarding","New Hands on Deck","Expedited Outfitting","Personnel Rotation")
	var/list/desc_task = list("mining","hydroponics","cargo handling","engineering","medical","research","cartographic")
	var/list/desc_place = list("vessel","station","platform","outpost")
	var/list/desc_hiring = list("hired","acquired","recruited","reassigned","graduated")
	var/list/desc_noobs = list("personnel","crew members","staff","interns")

	New()
		src.name = pick(namevary)
		var/task = pick(desc_task) //subvariation
		src.flavor_desc = "An affiliated [task] [pick(desc_place)] requires sets of attire for newly [pick(desc_hiring)] [pick(desc_noobs)]."

		var/crewcount = rand(4,12)
		src.payout += rand(3,4) * 10 * crewcount

		//uniform pickin
		if(prob(70))
			switch(task)
				if("mining") src.rc_entries += rc_buildentry(/datum/rc_entry/item/jumpsuit/orange,crewcount)
				if("hydroponics") src.rc_entries += rc_buildentry(/datum/rc_entry/item/jumpsuit/green,crewcount)
				if("cargo handling") src.rc_entries += rc_buildentry(/datum/rc_entry/item/jumpsuit/brown,crewcount)
				if("engineering") src.rc_entries += rc_buildentry(/datum/rc_entry/item/jumpsuit/yellow,crewcount)
				if("medical") src.rc_entries += rc_buildentry(/datum/rc_entry/item/jumpsuit/scrubs,crewcount)
				if("research") src.rc_entries += rc_buildentry(/datum/rc_entry/item/jumpsuit/white,crewcount)
				if("cartographic") src.rc_entries += rc_buildentry(/datum/rc_entry/item/jumpsuit,crewcount)
		else
			src.rc_entries += rc_buildentry(/datum/rc_entry/item/jumpsuit/any,crewcount)
		src.rc_entries += rc_buildentry(/datum/rc_entry/item/shoes,crewcount)
		if(prob(30))
			src.rc_entries += rc_buildentry(/datum/rc_entry/item/headset,crewcount)
		if(prob(50)) //turns out they need something to eat too
			src.rc_entries += rc_buildentry(/datum/rc_entry/item/literallyanyfood,crewcount)
			src.flavor_desc += " Food would also be appreciated."
			if(prob(70)) src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/water,crewcount*10*rand(1,3))
		//job related gearsets could also be added here sometimes

		..()

/datum/rc_entry/item/jumpsuit
	name = "black jumpsuit"
	typepath = /obj/item/clothing/under/color
	feemod = 260
	exactpath = TRUE

	any
		name = "single-color jumpsuit"
		feemod = 190
		exactpath = FALSE

	scrubs
		name = "medical scrubs"
		feemod = 230
		typepath = /obj/item/clothing/under/scrub
		exactpath = FALSE

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

/datum/rc_entry/item/backpack
	name = "backpack"
	typepath = /obj/item/storage/backpack
	feemod = 350

/datum/rc_entry/item/shoes
	name = "pair of shoes"
	typepath = /obj/item/clothing/shoes
	feemod = 220

/datum/rc_entry/item/headset
	name = "radio headset"
	typepath = /obj/item/device/radio/headset
	feemod = 470

/datum/rc_entry/item/literallyanyfood
	name = "solid food, preferably nutritious"
	typepath = /obj/item/reagent_containers/food/snacks
	feemod = 70

/datum/rc_entry/reagent/water
	name = "water"
	chemname = "water"
	feemod = 5


/datum/req_contract/civilian/birthdaybash
	//name = "Birthday Party"
	payout = 2000
	hide_item_payouts = TRUE
	var/list/namevary = list("Birthday Party","Birthday Bash","Surprise Party","One Year Older")
	var/list/desc_event = list("party","celebration","gathering","party","event") //yes party twice

	var/list/descpacito = list("ducks","Stations and Syndicates","cool hats","pride gear","instruments","sports","candy","electronics","tinkering")

	var/list/desc_partyzone = list(
		"at their station's cafeteria",
		"at their outpost's mess hall",
		"in a somewhat impromptu arrangement",
		"in their vessel's commissary",
		"at their station's bar",
		"at their outpost's bar",
		"at an undisclosed location",
		"on their personal vessel",
		"at their terrestrial vacation home",
		"at their planet-side timeshare",
		"here at our requisitions handling center"
	)

	New()
		src.name = pick(namevary)
		//let's get personal!
		var/whodat = prob(50)
		var/firstnom = whodat ? pick_string_autokey("names/first_male.txt") : pick_string_autokey("names/first_female.txt")
		var/lastnom = prob(80) ? pick(consonants_upper) : pick(vowels_upper)
		var/age = rand(23,55)

		src.flavor_desc = "A birthday [pick(desc_event)] is being held for [firstnom] [lastnom]. [pick(desc_partyzone)]."
		src.payout += rand(0,50) * 10

		if(prob(70)) //pizza party
			src.rc_entries += rc_buildentry(/datum/rc_entry/stack/pizza,rand(2,3)*6)
			src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/cola,rand(4,8)*10)

		switch(rand(1,50)) //Special Outcomes Zone
			if(1)
				src.rc_entries += rc_buildentry(/datum/rc_entry/item/chaps,rand(3,6))
			if(11 to 15)
				src.rc_entries += rc_buildentry(/datum/rc_entry/item/grapes,rand(3,6))
			if(16 to 20)
				src.rc_entries += rc_buildentry(/datum/rc_entry/item/banana,rand(4,8))
			if(21 to 25)
				src.rc_entries += rc_buildentry(/datum/rc_entry/item/cannabis,rand(4,8))
			if(26 to 30)
				src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/glitter,rand(4,8)*5)
			if(30 to 40)
				src.rc_entries += rc_buildentry(/datum/rc_entry/item/paperhat,rand(6,12))

		if(!length(src.rc_entries)) src.rc_entries += rc_buildentry(/datum/rc_entry/item/paperhat,rand(6,12)) //fallback

		if(prob(70)) //cookies or cakes?
			src.rc_entries += rc_buildentry(/datum/rc_entry/item/cake,1+prob(20))
		else //yep cookies
			src.rc_entries += rc_buildentry(/datum/rc_entry/item/cookie,rand(2,4)*6)

		var/bonusducks
		if(prob(50))
			bonusducks = list(
				" Throw in a gift of your own for the birthday [whodat ? "boy" : "girl"]!",
				" And how about you send along a present too?",
				" We ask that you send a gift of your choice for [firstnom]. [whodat ? "he" : "she"]'s fond of [pick(descpacito)].",
				" About the gift, wrap up whatever you want, but something to do with [pick(descpacito)] would be particularly nice.",
				" If you could gift-wrap something extra for them, it'd be appreciated - they like [pick(descpacito)].",
				" [whodat ? "He" : "She"]'s feeling a little down - a present of your own would be nice."
			)
			src.rc_entries += rc_buildentry(/datum/rc_entry/item/yourowngift,1)
		else
			bonusducks = list(
				null,
				" Custom frosting is preferred on the baked goods.",
				" It's not every day your pal turns [age]!",
				" If contacted by their relatives, please refrain from discussing this.",
				" Please do not contact [firstnom] directly - we're trying to keep it a surprise.",
				" Suppliers which handle shedding animals are encouraged not to reply.",
				" The quality of your response to this contract will be reported to your regional manager."
			)

		src.flavor_desc += "[pick(bonusducks)]"

		if(prob(30))
			var/collate = "[firstnom] [lastnom]"
			var/datum/rc_itemreward/birthdaypic/picc = new /datum/rc_itemreward/birthdaypic
			picc.whodatflag = whodat
			picc.bdayname = collate
			src.item_rewarders += picc
		..()

/datum/rc_itemreward/birthdaypic
	name = "commemorative photo"
	var/whodatflag
	var/bdayname
	var/list/proximitate = list("surrounded by","hanging out with","in a shuttle with","posing with","sitting around a table with")
	var/list/compatriots = list("coworkers","friends","family","crewmates","pals","buds")
	var/list/sendoff = list("We'll make it a good one!","Something to remember us by","Don't forget","Until next time, spacers","Birthday Friends Forever!")

	build_reward()
		var/obj/item/paper/pic = new /obj/item/paper/postcard
		pic.desc = "It's a picture of [bdayname] [pick(proximitate)] [whodatflag ? "his" : "her"] [pick(compatriots)]."
		pic.icon_state = prob(50) ? "postcard" : "postcard-mushroom"
		pic.info = "<font face='Comic Sans MS' color='#F75AA4' size=5><b>[pick(sendoff)]</b></font>"
		return pic

/datum/rc_entry/item/yourowngift
	name = "wrapped gift of your choice"
	typepath = /obj/item/gift
	feemod = 300

/datum/rc_entry/item/cake
	name = "cake"
	typepath = /obj/item/reagent_containers/food/snacks/cake
	feemod = 800

/datum/rc_entry/item/cookie
	name = "cookie"
	typepath = /obj/item/reagent_containers/food/snacks/cookie
	feemod = 240

/datum/rc_entry/stack/pizza
	name = "slices' worth of pizza"
	typepath = /obj/item/reagent_containers/food/snacks/pizza
	feemod = 50

/datum/rc_entry/reagent/cola
	name = "cola"
	chemname = "cola"
	feemod = 6

/datum/rc_entry/item/chaps
	name = "assless chaps"
	typepath = /obj/item/clothing/under/gimmick/chaps
	feemod = 800

/datum/rc_entry/item/grapes
	name = "grapes"
	typepath = /obj/item/reagent_containers/food/snacks/plant/grape
	commodity = /datum/commodity/produce
	feemod = 90

/datum/rc_entry/item/banana
	name = "banana"
	typepath = /obj/item/reagent_containers/food/snacks/plant/banana
	commodity = /datum/commodity/produce
	feemod = 80

/datum/rc_entry/item/cannabis
	name = "cannabis"
	commodity = /datum/commodity/drugs/cannabis
	feemod = 80

/datum/rc_entry/reagent/glitter
	name = "glitter"
	chemname = "glitter"
	feemod = 80

/datum/rc_entry/item/paperhat
	name = "paper hat"
	typepath = /obj/item/clothing/head/paper_hat
	feemod = 40

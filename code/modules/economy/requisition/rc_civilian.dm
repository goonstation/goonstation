ABSTRACT_TYPE(/datum/req_contract/civilian)
/**
 * Civilian contracts are a class of standard (market-listed) contract.
 * These contracts should typically be somewhat "tame", revolving around what a station might need in normal, non-catastrophe operation.
 * If you can picture a station or colony needing something for expansion, or under-provisioned it, it's a good candidate for a Civilian contract.
 */
/datum/req_contract/civilian
	req_class = CIV_CONTRACT

/datum/req_contract/civilian/event_catering
	name = "Event Catering"
	payout = 9000
	weight = 60
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
		src.payout += rand(0,100) * 10

		for(var/S in concrete_typesof(/datum/rc_entry/item/caterfood))
			if(prob(60))
				src.rc_entries += rc_buildentry(S,rand(2,5)*2) //4 to 10

		if(!length(src.rc_entries))
			src.rc_entries += rc_buildentry(/datum/rc_entry/item/caterfood/sandwich,18)

		for(var/S in concrete_typesof(/datum/rc_entry/reagent/caterdrink))
			if(prob(40))
				src.rc_entries += rc_buildentry(S,rand(3,10) * 10)
		..()

ABSTRACT_TYPE(/datum/rc_entry/item/caterfood)
/datum/rc_entry/item/caterfood/sandwich
	name = "sandwich"
	typepath = /obj/item/reagent_containers/food/snacks/sandwich
	feemod = 1400

/datum/rc_entry/item/caterfood/burger
	name = "burger"
	typepath = /obj/item/reagent_containers/food/snacks/burger
	feemod = 1550

/datum/rc_entry/item/caterfood/soup
	name = "pre-portioned soup bowl"
	typepath = /obj/item/reagent_containers/food/snacks/soup
	feemod = 1160

/datum/rc_entry/item/caterfood/salad
	name = "pre-portioned salad"
	typepath = /obj/item/reagent_containers/food/snacks/salad
	feemod = 920

ABSTRACT_TYPE(/datum/rc_entry/reagent/caterdrink)
/datum/rc_entry/reagent/caterdrink/appletini
	name = "appletini"
	chem_ids = "appletini"
	feemod = 90

/datum/rc_entry/reagent/caterdrink/fruitpunch
	name = "fruit punch"
	chem_ids = "fruit_punch"
	feemod = 90

/datum/rc_entry/reagent/caterdrink/spacecuba
	name = "space-cuba libre"
	chem_ids = "libre"
	feemod = 50

/datum/rc_entry/reagent/caterdrink/margarita
	name = "margarita"
	chem_ids = "margarita"
	feemod = 40

/datum/rc_entry/reagent/caterdrink/champagne
	name = "champagne"
	chem_ids = "champagne"
	feemod = 50


/datum/req_contract/civilian/furnishing
	//name = "Interior Outfitting"
	payout = 3200
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
	feemod = 60

/datum/rc_entry/reagent/carpet
	name = "liquid carpet"
	chem_ids = "carpet"
	feemod = 120

/datum/rc_entry/item/table
	name = "table"
	typepath = /obj/item/furniture_parts/table
	feemod = 300

/datum/rc_entry/item/rack
	name = "rack part set"
	typepath = /obj/item/furniture_parts/rack
	feemod = 250

/datum/rc_entry/item/chair
	name = "folding chair"
	typepath = /obj/item/chair/folded
	feemod = 230

/datum/rc_entry/item/light_bulb
	name = "light bulb"
	typepath = /obj/item/light/bulb
	feemod = 90

/datum/rc_entry/item/light_tube
	name = "light tube"
	typepath = /obj/item/light/tube
	feemod = 80


/datum/req_contract/civilian/greytide
	//name = "Crew Embarcation"
	payout = 1800
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
			src.rc_entries += rc_buildentry(/datum/rc_entry/food/any,crewcount)
			src.flavor_desc += " Food would also be appreciated."
			if(prob(70)) src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/water,crewcount*10*rand(1,3))
		//job related gearsets could also be added here sometimes

		..()

/datum/rc_entry/item/jumpsuit
	name = "black jumpsuit"
	typepath = /obj/item/clothing/under/color
	feemod = 450
	exactpath = TRUE

	any
		name = "single-color jumpsuit"
		feemod = 300
		exactpath = FALSE

	scrubs
		name = "medical scrubs"
		feemod = 680
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
	feemod = 800

/datum/rc_entry/item/shoes
	name = "pair of shoes"
	typepath = /obj/item/clothing/shoes
	feemod = 380

/datum/rc_entry/item/headset
	name = "radio headset"
	typepath = /obj/item/device/radio/headset
	feemod = 940

/datum/rc_entry/food/any
	name = "solid food, preferably nutritious"
	typepath = /obj/item/reagent_containers/food/snacks
	feemod = 250

/datum/rc_entry/reagent/water
	name = "water"
	chem_ids = "water"
	feemod = 10


/datum/req_contract/civilian/birthdaybash
	//name = "Birthday Party"
	payout = 3500
	hide_item_payouts = TRUE
	weight = 80
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

		if (prob(70)) //pizza party
			src.rc_entries += rc_buildentry(/datum/rc_entry/food/pizza,rand(2,3)*6)
			src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/cola,rand(10,20)*10)

		switch (rand(1, 50)) //Special Outcomes Zone
			if (1)
				src.rc_entries += rc_buildentry(/datum/rc_entry/item/chaps,rand(3,6))
			if (2 to 6)
				src.rc_entries += rc_buildentry(/datum/rc_entry/food/grapes,rand(3,6))
			if (7 to 11)
				src.rc_entries += rc_buildentry(/datum/rc_entry/food/banana,rand(4,8))
			if (12 to 16)
				src.rc_entries += rc_buildentry(/datum/rc_entry/item/cannabis,rand(4,8))
			if (17 to 21)
				src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/glitter,rand(4,8)*5)
			if (22 to 31)
				src.rc_entries += rc_buildentry(/datum/rc_entry/item/paperhat,rand(6,12))
			else
				// nothing

		if(!length(src.rc_entries)) src.rc_entries += rc_buildentry(/datum/rc_entry/item/paperhat,rand(6,12)) //fallback

		if(prob(70)) //cookies or cakes?
			src.rc_entries += rc_buildentry(/datum/rc_entry/food/cake,1+prob(20))
		else //yep cookies
			src.rc_entries += rc_buildentry(/datum/rc_entry/food/cookie,rand(2,4)*6)

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
	feemod = 600

/datum/rc_entry/food/cake
	name = "cake"
	typepath = /obj/item/reagent_containers/food/snacks/cake
	feemod = 2500

/datum/rc_entry/food/cookie
	name = "cookie"
	typepath = /obj/item/reagent_containers/food/snacks/cookie
	feemod = 600

/datum/rc_entry/food/pizza
	name = "slices' worth of pizza"
	typepath = /obj/item/reagent_containers/food/snacks/pizza
	feemod = 120

/datum/rc_entry/reagent/cola
	name = "cola"
	chem_ids = "cola"
	feemod = 20

/datum/rc_entry/item/chaps
	name = "assless chaps"
	typepath = /obj/item/clothing/under/gimmick/chaps
	feemod = 5000

/datum/rc_entry/food/grapes
	name = "grapes"
	typepath = /obj/item/reagent_containers/food/snacks/plant/grape
	feemod = 450

/datum/rc_entry/food/banana
	name = "banana"
	typepath = /obj/item/reagent_containers/food/snacks/plant/banana
	feemod = 300

/datum/rc_entry/item/cannabis
	name = "cannabis"
	commodity = /datum/commodity/drugs/cannabis
	feemod = 420

/datum/rc_entry/reagent/glitter
	name = "glitter"
	chem_ids = "glitter"
	feemod = 160

/datum/rc_entry/item/paperhat
	name = "paper hat"
	typepath = /obj/item/clothing/head/paper_hat
	feemod = 110


/datum/req_contract/civilian/architecture
	//name = "Architecture Deluxe"
	payout = 5200
	var/list/namevary = list("Structural Setup","Brick by Brick","New Construction","Building Supply","Structure Fabrication","Asset Development")
	var/list/desc_thingbuilt = list("A planetary habitation site","A new deluxe retreat","A new station wing","An affiliated construction project")
	var/list/desc_progress = list("currently underway","delayed by supply difficulties","planned for near-term assembly","commissioned by a third party")
	var/list/desc_resource = list("stone","turf seed","window treatment","wood","solvent","detailing metal")
	var/list/desc_flavorize = list(
		null,
		" Packing material will be returned to you for reuse if possible.",
		" Prompt delivery would be heavily appreciated.",
		" Site foreman is growing agitated with delays; price offered is above market rate.",
		" Please pack precisely as specified; excess will cause hassle on our end.",
		" Goods need not be in perfect condition."
	)


	New()
		src.name = pick(namevary)
		var/req1 = pick(desc_resource)
		var/req2 = pick(desc_resource)
		var/req_quant = 1 //if this is 2, doubles the first and skips the second
		if(req1 == req2) //allow doubling up, but have the description and additions handle it gracefully
			req_quant = 2
			src.flavor_desc = "[pick(desc_thingbuilt)] [pick(desc_progress)] is in need of considerable additional [req1] before further progress can be made.[pick(desc_flavorize)]"
		else
			src.flavor_desc = "[pick(desc_thingbuilt)] [pick(desc_progress)] is in need of additional [req1] and [req2] before further progress can be made.[pick(desc_flavorize)]"
		src.payout += rand(0,50) * 10

		switch(req1)
			if("stone")
				src.rc_entries += rc_buildentry(/datum/rc_entry/stack/rock,rand(8,14)*2*req_quant)
			if("turf seed")
				src.rc_entries += rc_buildentry(/datum/rc_entry/seed/grass,rand(20,30)*req_quant)
			if("window treatment")
				src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/silicate,rand(3,10)*10*req_quant)
			if("wood")
				src.rc_entries += rc_buildentry(/datum/rc_entry/item/plank,rand(5,12)*req_quant)
			if("solvent")
				src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/acetone,rand(4,8)*10*req_quant)
			if("detailing metal")
				if(prob(70))
					src.rc_entries += rc_buildentry(/datum/rc_entry/stack/cobryl,rand(1,6)*req_quant)
				else
					src.rc_entries += rc_buildentry(/datum/rc_entry/stack/syreline,rand(3,5)*req_quant)

		if(req_quant == 1)
			switch(req2)
				if("stone")
					src.rc_entries += rc_buildentry(/datum/rc_entry/stack/rock,rand(8,14)*2)
				if("turf seed")
					src.rc_entries += rc_buildentry(/datum/rc_entry/seed/grass,rand(20,30))
				if("window treatment")
					src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/silicate,rand(3,10)*10)
				if("wood")
					src.rc_entries += rc_buildentry(/datum/rc_entry/item/plank,rand(5,12))
				if("solvent")
					src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/acetone,rand(4,8)*10)
				if("detailing metal")
					if(prob(70))
						src.rc_entries += rc_buildentry(/datum/rc_entry/stack/cobryl,rand(1,6))
					else
						src.rc_entries += rc_buildentry(/datum/rc_entry/stack/syreline,rand(3,5))

		..()

/datum/rc_entry/stack/rock
	name = "rock"
	typepath = /obj/item/raw_material/rock
	feemod = 250

/datum/rc_entry/seed/grass
	name = "grass seed"
	cropname = "Grass"
	feemod = 300

/datum/rc_entry/reagent/silicate
	contained_in = /obj/item/reagent_containers/glass
	container_name = "Bottles"
	name = "liquid silicate"
	chem_ids = "silicate"
	feemod = 18

/datum/rc_entry/item/plank
	name = "wooden plank"
	typepath = /obj/item/sheet/wood
	exactpath = TRUE
	feemod = 1220

/datum/rc_entry/reagent/acetone
	name = "acetone"
	chem_ids = "acetone"
	feemod = 18

/datum/rc_entry/stack/cobryl
	name = "cobryl"
	commodity = /datum/commodity/ore/cobryl
	typepath_alt = /obj/item/material_piece/cobryl
	feemod = 450

/datum/rc_entry/stack/syreline
	name = "syreline"
	commodity = /datum/commodity/ore/syreline
	typepath_alt = /obj/item/material_piece/syreline
	feemod = 1100

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
	payout = PAY_IMPORTANT*10
	weight = 40
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
	feemod = PAY_TRADESMAN*4

/datum/rc_entry/item/caterfood/burger
	name = "burger"
	typepath = /obj/item/reagent_containers/food/snacks/burger
	feemod = PAY_TRADESMAN*4

/datum/rc_entry/item/caterfood/soup
	name = "pre-portioned soup bowl"
	typepath = /obj/item/reagent_containers/food/snacks/soup
	feemod = PAY_TRADESMAN*4

/datum/rc_entry/item/caterfood/salad
	name = "pre-portioned salad"
	typepath = /obj/item/reagent_containers/food/snacks/salad
	feemod = PAY_TRADESMAN*3

ABSTRACT_TYPE(/datum/rc_entry/reagent/caterdrink)
/datum/rc_entry/reagent/caterdrink/appletini
	name = "appletini"
	chem_ids = "appletini"
	feemod = PAY_IMPORTANT/10

/datum/rc_entry/reagent/caterdrink/fruitpunch
	name = "fruit punch"
	chem_ids = "fruit_punch"
	feemod = PAY_IMPORTANT/10

/datum/rc_entry/reagent/caterdrink/spacecuba
	name = "space-cuba libre"
	chem_ids = "libre"
	feemod = PAY_IMPORTANT/10

/datum/rc_entry/reagent/caterdrink/margarita
	name = "margarita"
	chem_ids = "margarita"
	feemod = PAY_IMPORTANT/10

/datum/rc_entry/reagent/caterdrink/champagne
	name = "champagne"
	chem_ids = "champagne"
	feemod = PAY_IMPORTANT/10


/datum/req_contract/civilian/furnishing
	//name = "Interior Outfitting"
	payout = PAY_EMBEZZLED
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
	feemod = PAY_TRADESMAN/5

/datum/rc_entry/reagent/carpet
	name = "liquid carpet"
	chem_ids = "carpet"
	feemod = PAY_DOCTORATE/2

/datum/rc_entry/item/table
	name = "table"
	typepath = /obj/item/furniture_parts/table
	feemod = PAY_TRADESMAN

/datum/rc_entry/item/rack
	name = "rack part set"
	typepath = /obj/item/furniture_parts/rack
	feemod = PAY_TRADESMAN

/datum/rc_entry/item/chair
	name = "folding chair"
	typepath = /obj/item/chair/folded
	feemod = PAY_TRADESMAN

/datum/rc_entry/item/light_bulb
	name = "light bulb"
	typepath = /obj/item/light/bulb
	feemod = PAY_TRADESMAN/5

/datum/rc_entry/item/light_tube
	name = "light tube"
	typepath = /obj/item/light/tube
	feemod = PAY_TRADESMAN/5


/datum/req_contract/civilian/greytide
	//name = "Crew Embarcation"
	payout = PAY_UNTRAINED*10*2
	var/list/namevary = list("Crew Embarcation","Crew Onboarding","New Hands on Deck","Expedited Outfitting","Personnel Rotation")
	var/list/desc_task = list("mining","hydroponics","cargo handling","engineering","medical","research","cartographic")
	var/list/desc_place = list("vessel","station","platform","outpost")
	var/list/desc_hiring = list("hired","acquired","recruited","reassigned","graduated")
	var/list/desc_noobs = list("personnel","crew members","staff","interns")

	New()
		src.name = pick(namevary)
		var/task = pick(desc_task) //subvariation
		src.flavor_desc = "An affiliated [task] [pick(desc_place)] requires sets of attire for newly [pick(desc_hiring)] [pick(desc_noobs)]."

		var/crewcount = rand(3,8)
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
	feemod = PAY_TRADESMAN*1.5
	exactpath = TRUE

	any
		name = "single-color jumpsuit"
		feemod = PAY_TRADESMAN
		exactpath = FALSE

	scrubs
		name = "medical scrubs"
		feemod = PAY_DOCTORATE
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
	feemod = PAY_TRADESMAN*4

/datum/rc_entry/item/shoes
	name = "pair of shoes"
	typepath = /obj/item/clothing/shoes
	feemod = PAY_TRADESMAN

/datum/rc_entry/item/headset
	name = "radio headset"
	typepath = /obj/item/device/radio/headset
	feemod = PAY_IMPORTANT

/datum/rc_entry/food/any
	name = "solid food, preferably nutritious"
	typepath = /obj/item/reagent_containers/food/snacks
	food_integrity = FOOD_REQ_BY_ITEM
	feemod = PAY_TRADESMAN

/datum/rc_entry/reagent/water
	name = "water"
	chem_ids = "water"
	feemod = PAY_UNTRAINED/15


/datum/req_contract/civilian/birthdaybash
	//name = "Birthday Party"
	payout = PAY_TRADESMAN*10*2
	hide_item_payouts = TRUE
	weight = 60
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
			src.rc_entries += rc_buildentry(/datum/rc_entry/food/pizza,rand(2,3)*12)
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
				; // nothing

		if(!length(src.rc_entries))
			src.rc_entries += rc_buildentry(/datum/rc_entry/item/paperhat,rand(6,12)) //fallback

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
	feemod = PAY_TRADESMAN*4

/datum/rc_entry/food/cake
	name = "cake"
	typepath = /obj/item/reagent_containers/food/snacks/cake
	feemod = PAY_TRADESMAN*4

/datum/rc_entry/food/cookie
	name = "cookie"
	typepath = /obj/item/reagent_containers/food/snacks/cookie
	feemod = PAY_TRADESMAN*2

/datum/rc_entry/food/pizza
	name = "bites' worth of whole pizza"
	commodity = /datum/commodity/
	typepath = /obj/item/reagent_containers/food/snacks/pizza
	food_integrity = FOOD_REQ_BY_BITE
	feemod = PAY_UNTRAINED

/datum/rc_entry/reagent/cola
	name = "cola"
	chem_ids = "cola"
	feemod = PAY_UNTRAINED/10

/datum/rc_entry/item/chaps
	name = "chaps"
	typepath = /obj/item/clothing/suit/chaps
	feemod = PAY_EXECUTIVE*2

/datum/rc_entry/food/grapes
	name = "grapes"
	commodity = /datum/commodity/produce
	typepath = /obj/item/reagent_containers/food/snacks/plant/grape
	feemod = PAY_TRADESMAN

/datum/rc_entry/food/banana
	name = "banana"
	commodity = /datum/commodity/produce
	typepath = /obj/item/reagent_containers/food/snacks/plant/banana
	feemod = PAY_TRADESMAN

/datum/rc_entry/item/cannabis
	name = "cannabis"
	commodity = /datum/commodity/drugs/buy/cannabis
	feemod = 420

/datum/rc_entry/reagent/glitter
	name = "glitter"
	chem_ids = "glitter"
	feemod = PAY_UNTRAINED

/datum/rc_entry/item/paperhat
	name = "paper hat"
	typepath = /obj/item/clothing/head/paper_hat
	feemod = PAY_UNTRAINED


/datum/req_contract/civilian/architecture
	//name = "Architecture Deluxe"
	payout = PAY_EMBEZZLED
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
				src.rc_entries += rc_buildentry(/datum/rc_entry/plant/seed/grass,rand(20,30)*req_quant)
			if("window treatment")
				src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/silicate,rand(3,10)*10*req_quant)
			if("wood")
				src.rc_entries += rc_buildentry(/datum/rc_entry/stack/woodsheet,rand(5,12)*10*req_quant)
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
					src.rc_entries += rc_buildentry(/datum/rc_entry/plant/seed/grass,rand(20,30))
				if("window treatment")
					src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/silicate,rand(3,10)*10)
				if("wood")
					src.rc_entries += rc_buildentry(/datum/rc_entry/stack/woodsheet,rand(5,12)*10)
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
	commodity = /datum/commodity/ore
	typepath = /obj/item/raw_material/rock
	feemod = PAY_UNTRAINED

/datum/rc_entry/plant/seed/grass
	name = "grass seed"
	cropname = "Grass"
	feemod = PAY_TRADESMAN

/datum/rc_entry/reagent/silicate
	contained_in = /obj/item/reagent_containers/glass
	container_name = "Bottles"
	name = "liquid silicate"
	chem_ids = "silicate"
	feemod = PAY_DOCTORATE/10

/datum/rc_entry/stack/woodsheet
	name = "wooden sheet"
	typepath = /obj/item/sheet
	mat_id = "wood"
	feemod = PAY_UNTRAINED/2

/datum/rc_entry/reagent/acetone
	name = "acetone"
	chem_ids = "acetone"
	feemod = PAY_DOCTORATE/10

/datum/rc_entry/stack/cobryl
	name = "cobryl"
	commodity = /datum/commodity/ore/cobryl
	typepath_alt = /obj/item/material_piece/cobryl
	feemod = PAY_TRADESMAN

/datum/rc_entry/stack/syreline
	name = "syreline"
	commodity = /datum/commodity/ore/syreline
	typepath_alt = /obj/item/material_piece/syreline
	feemod = PAY_IMPORTANT

/datum/req_contract/civilian/robotics
	//name = "Borg Buds"
	payout = PAY_TRADESMAN*10
	var/list/namevary = list("Robot Overhaul","Loose Sprockets","Parts Wanted","Servo Service")
	var/list/desc_whatbork = list("mining operation","security post","automated refueling station","cultivation platform","hazardous material processor")
	var/list/desc_whatget = list(
		"a selection of robotics components",
		"specialized hardware",
		"NT-spec replacement parts",
		"high-grade cybernetics equipment",
		"specified robotics equipment",
		"made-to-order components",
		"expedited delivery of listed items")
	var/list/desc_whyget = list(
		"to repair erroneous function in on-site cyborgs",
		"to complete a site-wide machinery overhaul",
		"in furtherance of efficiency improvements",
		"as spares for mission-critical robotics",
		"precisely as enumerated in contract",
		"suitable for long-term use",
		"for maintenance of their guard bots")
	var/list/desc_flavorize = list(
		null,
		null,
		" Attempts at passing off rusted components as adequate will be met with legal action.",
		" Please electrically ground each item before packing.",
		" Quality control was lacking in prior order from another supplier; please ensure no cracks or cuts.",
		" Individual packaging of items within shipment should not be necessary."
	)

	New()
		src.name = pick(namevary)
		src.flavor_desc = "An affiliated [pick(desc_whatbork)] is seeking [pick(desc_whatget)] [pick(desc_whyget)].[pick(desc_flavorize)]"
		src.payout += rand(0,30) * 10

		var/botsets = 1
		if(prob(30)) botsets = 2

		if(prob(60))
			src.rc_entries += rc_buildentry(/datum/rc_entry/item/robot_arm_any,rand(2,5))
		else
			src.rc_entries += rc_buildentry(/datum/rc_entry/item/botpart_std/head,botsets)
			src.rc_entries += rc_buildentry(/datum/rc_entry/item/botpart_std/chest,botsets)
			src.rc_entries += rc_buildentry(/datum/rc_entry/item/botpart_std/arm_l,botsets)
			src.rc_entries += rc_buildentry(/datum/rc_entry/item/botpart_std/arm_r,botsets)
			src.rc_entries += rc_buildentry(/datum/rc_entry/item/botpart_std/leg_l,botsets)
			src.rc_entries += rc_buildentry(/datum/rc_entry/item/botpart_std/leg_r,botsets)

		if(prob(55))
			src.rc_entries += rc_buildentry(/datum/rc_entry/item/borgmodule,rand(2,4))
			if(prob(30)) src.rc_entries += rc_buildentry(/datum/rc_entry/item/multitool,1)

		if(prob(45))
			src.rc_entries += rc_buildentry(/datum/rc_entry/item/powercell,botsets)
			if(prob(40)) src.rc_entries += rc_buildentry(/datum/rc_entry/item/basictool/crowbar,1)

		if(prob(40)) src.rc_entries += rc_buildentry(/datum/rc_entry/item/prox_sensor,rand(1,3))
		if(prob(40)) src.rc_entries += rc_buildentry(/datum/rc_entry/stack/cable,rand(8,25))
		if(prob(20)) src.rc_entries += rc_buildentry(/datum/rc_entry/item/interfaceboard,1)

		..()

/datum/rc_entry/item/robot_arm_any
	name = "robot arm (any grade/facing)"
	typepath = /obj/item/parts/robot_parts/arm
	feemod = PAY_TRADESMAN

/datum/rc_entry/item/botpart_std
	name = "beepy boopy boye (you shouldn't see this)"
	typepath = /obj/item/parts/robot_parts/drone
	exactpath = TRUE
	feemod = PAY_TRADESMAN*2

/datum/rc_entry/item/botpart_std/head
	name = "standard cyborg head"
	typepath = /obj/item/parts/robot_parts/head/standard

/datum/rc_entry/item/botpart_std/chest
	name = "standard cyborg chest"
	typepath = /obj/item/parts/robot_parts/chest/standard

/datum/rc_entry/item/botpart_std/arm_l
	name = "standard cyborg left arm"
	typepath = /obj/item/parts/robot_parts/arm/left/standard

/datum/rc_entry/item/botpart_std/arm_r
	name = "standard cyborg right arm"
	typepath = /obj/item/parts/robot_parts/arm/right/standard

/datum/rc_entry/item/botpart_std/leg_l
	name = "standard cyborg left leg"
	typepath = /obj/item/parts/robot_parts/leg/left/standard

/datum/rc_entry/item/botpart_std/leg_r
	name = "standard cyborg right leg"
	typepath = /obj/item/parts/robot_parts/leg/right/standard

/datum/rc_entry/item/powercell
	name = "standard 15000u power cell"
	typepath = /obj/item/cell
	feemod = PAY_IMPORTANT

	extra_eval(atom/eval_item)
		. = FALSE
		var/obj/item/cell/cell = eval_item
		if(cell.maxcharge >= 15000)
			return TRUE

/datum/rc_entry/item/borgmodule
	name = "cyborg module"
	typepath = /obj/item/robot_module
	feemod = PAY_DOCTORATE

/datum/rc_entry/item/prox_sensor
	name = "proximity sensor"
	typepath = /obj/item/device/prox_sensor
	feemod = PAY_TRADESMAN

/datum/req_contract/civilian/pod
	//name = "Space Hogg"
	payout = PAY_TRADESMAN*10
	var/list/namevary = list("Back in the Shop","Vehicular Teardown","Rebuild Assistance","Nuts and Bolts")
	var/list/flavor_descs = list(
		"I'm overhauling my daily driver and my usual suppliers are giving me a lead time of weeks. Get everything together and I'll pay way too much.",
		"Commercial hangar seeking components for rebuild of a client's personal vessel. Timely, well-secured delivery is required.",
		"goddamn console says i have to fill this shit in GET ME MY PARTS",
		"HELLO, FELLOW HUMANS. I SEEK VEHICULAR COMPONENTS FOR LEGITIMATE PURPOSES. I WILL REWARD YOU WITH MANY OF THESE CREDITS WE SO DEEPLY CHERISH.",
		"Private hangar requesting expedited shipment of specified parts. Please use gloves when loading; any fingerprints will be scanned and recorded for later punitive action.",
		"Transport service requesting parts for overhaul of a passenger vessel. Please be aware any 'mismatched' requests are not erroneous.",
		"rick says hi",
		"LF parts for a total overhaul. Used is fine, as long as I can't tell from the stains. Or smell. Peace out")

	New()
		src.name = pick(namevary)
		src.flavor_desc = pick(flavor_descs)
		src.flavor_desc += "<br><i>REQHUB ADVISORY: MiniPutt or Minisub components not accepted</i>"
		src.payout += rand(0,40) * 10

		if(prob(80)) src.rc_entries += rc_buildentry(/datum/rc_entry/item/engine_component,1)
		if(prob(50)) src.rc_entries += rc_buildentry(/datum/rc_entry/item/pod_mining,1)
		if(prob(80)) src.rc_entries += rc_buildentry(/datum/rc_entry/item/pod_tank,1)
		if(prob(70) || length(src.rc_entries) < 2) src.rc_entries += rc_buildentry(/datum/rc_entry/item/pod_armor,1)
		if(prob(60) || length(src.rc_entries) < 4) src.rc_entries += rc_buildentry(/datum/rc_entry/item/pod_tool,1)
		if(prob(50)) src.rc_entries += rc_buildentry(/datum/rc_entry/item/pod_secondary,1)

		..()

/datum/rc_entry/item/engine_component
	name = "any pod-compatible engine but you shouldn't see this particular name for it"

	New()
		switch(rand(1, 6))
			if(1 to 5)
				name = "Helios Mark-II engine"
				typepath = /obj/item/shipcomponent/engine/helios
				feemod = PAY_TRADESMAN*5
			if(6)
				name = "Hermes Mark-III engine"
				typepath = /obj/item/shipcomponent/engine/hermes
				feemod = PAY_DOCTORATE*5
		..()

/datum/rc_entry/item/pod_mining
	name = "pod mining accessory"

	New()
		switch(rand(1, 10))
			if(1 to 6)
				name = "magnet link array"
				typepath = /obj/item/shipcomponent/communications/mining
				feemod = PAY_TRADESMAN*4
			if(7 to 9)
				name = "pod-mounted ore scoop with hold"
				typepath = /obj/item/shipcomponent/secondary_system/orescoop
				feemod = PAY_TRADESMAN*5
			if(10)
				name = "pod-mounted geological scanner"
				typepath = /obj/item/shipcomponent/sensor/mining
				feemod = PAY_TRADESMAN*12
		..()

/datum/rc_entry/item/pod_tank
	name = "pod atmospheric tank"

	New()
		switch(rand(1, 10))
			if(1 to 6)
				name = "pod-compatible gas tank"
				typepath = /obj/item/tank
				feemod = PAY_TRADESMAN*2
			if(7 to 9)
				name = "pod air tank"
				typepath = /obj/item/tank/air
				feemod = PAY_TRADESMAN*5
			if(10)
				name = "pod fuel tank"
				typepath = /obj/item/tank/plasma
				feemod = PAY_TRADESMAN*8
		..()

/datum/rc_entry/item/pod_armor
	name = "pod armor but you shouldn't see this particular name for it"

	New()
		switch(rand(1, 10))
			if(1 to 6)
				name = "any pod armor"
				typepath = /obj/item/podarmor
				feemod = PAY_TRADESMAN*4
			if(7 to 9)
				name = "heavy pod armor"
				typepath = /obj/item/podarmor/armor_heavy
				feemod = PAY_DOCTORATE*5
			if(10)
				name = "industrial pod armor"
				typepath = /obj/item/podarmor/armor_industrial
				feemod = PAY_TRADESMAN*12
		..()


/datum/rc_entry/item/pod_tool
	name = "youshouldn'tseemium cannon"

	New()
		switch(rand(1,20))
			if(1 to 11)
				name = "Mk 1.5 light phaser"
				typepath = /obj/item/shipcomponent/mainweapon/phaser
				feemod = PAY_TRADESMAN*2
			if(12 to 19)
				name = "plasma cutter system"
				typepath = /obj/item/shipcomponent/mainweapon/mining
				feemod = PAY_TRADESMAN*5
			if(20)
				name = "Mk.2 scout laser"
				typepath = /obj/item/shipcomponent/mainweapon/laser
				feemod = (PAY_DONTBUYIT*2) + (PAY_DOCTORATE * rand(3,6))
		..()

/datum/rc_entry/item/pod_secondary
	name = "youshouldn'tseemium dongle"
	feemod = PAY_TRADESMAN*2

	New()
		switch(rand(1, 10))
			if(1 to 4)
				name = "cargo hold"
				typepath = /obj/item/shipcomponent/secondary_system/cargo
			if(5 to 7)
				name = "pod locking mechanism"
				typepath = /obj/item/shipcomponent/secondary_system/lock
			if(8 to 10)
				name = "ship's navigation GPS"
				typepath = /obj/item/shipcomponent/secondary_system/gps
		..()


/datum/req_contract/civilian/botanical
	payout = PAY_TRADESMAN*15*2
	var/list/namevary = list("Diplomatic Meal Preparation","High-Grade Dinner Prep","Captain's Meal Ingredients","NT-Official Kitchen","NT Pantry Stocking")
	var/list/desc_wherebuying = list(
		"A nearby outpost hosting an NT official",
		"A passing high-class cruiser",
		"A VIP shuttle",
		"A \[redacted\]", // military vessel commanders probably also have gourmet appetites
		"Central command's kitchen",
		"The kitchen staff of an affiliated station",
		"The kitchen staff of an affiliated vessel",
		"A luxury exploratory vessel"
	)
	var/list/desc_plants = list("high-quality produce","upscale fruit and veg","gourmet produce","high-grade ingredients",
								"artisan fruits and greens","boutique ingredients")
	var/list/desc_bonusflavor = list(
		null,
		" Ensure all produce is free from blemishes or signs of spoilage.",
		" Double-check that no substandard crops are included before packaging.",
		" Certify that produce has been grown without synthetic fertilisers.",
		" Individually wrapping each item will ensure maximum freshness.",
		" Shipment should include detailed cultivation records for quality assurance.",
		" Ensure any fruits will be fully ripened prior to reception."
	)

	New()
		src.name = pick(namevary)
		src.flavor_desc = "[pick(desc_wherebuying)] is stocking [pick(desc_plants)] with very particular genetically-inclined flavour profiles. [pick(desc_bonusflavor)]"
		src.payout += rand(0,30) * 10
		var/quant = 0
		var/randm = rand(1, 100)
		if (randm > 50)
			quant = 2
		else if (randm > 5)
			quant = 1
		else
			quant = 3
			src.payout += 8000

		for (var/i = 1; i <= quant; i++)
			src.rc_entries += GetFruitOrVegEntry()
		src.item_rewarders += new /datum/rc_itemreward/large_satchel
		src.item_rewarders += new /datum/rc_itemreward/phyto_upgrade
		if(prob(30))
			src.item_rewarders += new /datum/rc_itemreward/strange_seed
		else if (prob(60))
			src.item_rewarders += new /datum/rc_itemreward/tumbleweed

		..()

	proc/GetFruitOrVegEntry()
		if (prob(50))
			return rc_buildentry(/datum/rc_entry/plant/civilian/fruit,rand(4,10))
		else
			return rc_buildentry(/datum/rc_entry/plant/civilian/veg,rand(4,10))

/datum/rc_entry/plant/civilian
	name = "genetically fussy plant"
	cropname = "Durian"
	feemod = PAY_DOCTORATE
	// This worked for seeds, but it only works for produce because all fruits and veg products are members of
	// obj/item/reagent_containers/food/snacks/plant and thus have plant genes. As long as that remains a hard-stuck rule though, this should be fine.
	var/crop_genpath = /datum/plant

	fruit
		crop_genpath = /datum/plant/fruit
	veg
		crop_genpath = /datum/plant/veg
	crop
		crop_genpath = /datum/plant/crop

	New()
		var/datum/plant/plantalyze = pick(concrete_typesof(crop_genpath))
		src.cropname = initial(plantalyze.name)

		switch(rand(1,7))
			if(1) src.gene_reqs["Maturation"] = rand(10,20)
			if(2) src.gene_reqs["Production"] = rand(10,20)
			if(3)
				src.gene_reqs["Production"] = rand(5,10)
				src.gene_reqs["Potency"] = rand(3,5)
			if(4) src.gene_reqs["Yield"] = rand(3,5)
			if(5) src.gene_reqs["Potency"] = rand(3,5)
			if(6) src.gene_reqs["Endurance"] = rand(3,5)
			if(7)
				src.gene_reqs["Maturation"] = rand(5,10)
				src.gene_reqs["Production"] = rand(5,10)
		..()

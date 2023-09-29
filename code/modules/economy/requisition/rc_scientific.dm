ABSTRACT_TYPE(/datum/req_contract/scientific)
/**
 * Scientific contracts are a class of standard (market-listed) contract.
 * Of the contract types, these should typically lean more heavily on unusual materials or ones that require a sophisticated acquisition process.
 * This doesn't have to be limited to what the science department puts out; if a researcher somewhere wants it, that could be a contract.
 */
/datum/req_contract/scientific
	req_class = SCI_CONTRACT

/datum/req_contract/scientific/internalaffairs //get it?
	//name = "Don't Ask Too Many Questions"
	payout = PAY_DOCTORATE*10*2
	weight = 80
	var/list/namevary = list("Organ Analysis","Organ Research","Biolab Supply","Biolab Partnership","ERROR: CANNOT VERIFY ORIGIN","Organ Study")
	var/list/desc_begins = list("conducting","performing","beginning","initiating","seeking supplies for","organizing")
	var/list/desc_whatstudy = list("long-term study","intensive trialing","in-depth analysis","study","regulatory assessment")
	var/list/desc_whystudy = list("decay","function","robustness","response to a new medication","atrophy in harsh conditions","therapies","bounciness")

	New()
		src.name = pick(namevary)
		var/dombler = pick(concrete_typesof(/datum/rc_entry/item/organ))
		var/datum/rc_entry/organic = new dombler
		organic.count = rand(2,4)
		src.rc_entries += organic

		src.flavor_desc = "An affiliated research group is [pick(desc_begins)] a [pick(desc_whatstudy)] of [organic.name] [pick(desc_whystudy)]"
		src.flavor_desc += " and requires genetically-human specimens in adequate condition."
		src.payout += rand(0,40) * 20
		..()

ABSTRACT_TYPE(/datum/rc_entry/item/organ)
/datum/rc_entry/item/organ
	feemod = PAY_IMPORTANT*2
	exactpath = TRUE

/datum/rc_entry/item/organ/appendix
	name = "appendix"
	commodity = /datum/commodity/bodyparts/appendix

/datum/rc_entry/item/organ/heart
	name = "heart"
	commodity = /datum/commodity/bodyparts/heart

/datum/rc_entry/item/organ/liver
	name = "liver"
	commodity = /datum/commodity/bodyparts/liver

/datum/rc_entry/item/organ/spleen
	name = "spleen"
	commodity = /datum/commodity/bodyparts/spleen



/datum/req_contract/scientific/spectrometry
	//name = "Totally Will Not Result In A Resonance Cascade"
	payout = PAY_DOCTORATE*10*2
	var/list/namevary = list("Beamline Calibration","Spectral Analysis","Chromatic Analysis","Refraction Survey","Component Restock","Photonics Project")
	var/list/desc_wherestudy = list(
		"Optics calibration laboratory",
		"Field laboratory at crystal excavation site",
		"Anti-mass spectrometry platform",
		"Transmission laser prototyping facility",
		"Restricted research operation",
		"An affiliated research facility is",
		"An affiliated research vessel is",
		"An affiliated research outpost is"
	)
	var/list/desc_whystudy = list("micro-reflection","latticed capacitive crystal","photonic data encoding","telecrystal stabilization")
	var/list/desc_bonusflavor = list(
		null,
		" Ensure all materials are free of flammable particulates.",
		" Please use shock-absorbent packing material if possible.",
		" Discussion of this contract with nonessential personnel is discouraged.",
		" If possible, verify all included materials with a third-party quality assessor.",
		" Any damage to included materials not caused by shipping will be reported to your regional manager."
	)

	New()
		src.name = pick(namevary)
		src.flavor_desc = "[pick(desc_wherestudy)] seeking vital components for [pick(desc_whystudy)] research.[pick(desc_bonusflavor)]"
		src.payout += rand(0,40) * 10

		if(prob(80)) src.rc_entries += rc_buildentry(/datum/rc_entry/stack/gemstone,rand(1,8))
		if(prob(20)) src.rc_entries += rc_buildentry(/datum/rc_entry/stack/telec,rand(1,3))
		if(prob(50)) src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/cryox,rand(4,10)*5)
		if(prob(40)) src.rc_entries += rc_buildentry(/datum/rc_entry/item/lambdarod,1)
		if(!length(src.rc_entries) || prob(70)) src.rc_entries += rc_buildentry(/datum/rc_entry/item/lens,rand(2,6))

		..()

/datum/rc_entry/item/lens
	name = "nano-fabricated lens"
	typepath = /obj/item/lens
	feemod = PAY_IMPORTANT

/datum/rc_entry/stack/gemstone
	name = "non-anomalous gemstone"
	commodity = /datum/commodity/ore/gemstone
	typepath = /obj/item/raw_material/gemstone
	feemod = PAY_IMPORTANT

/datum/rc_entry/stack/telec
	name = "telecrystal"
	commodity = /datum/commodity/ore/telecrystal
	typepath_alt = /obj/item/material_piece/telecrystal
	feemod = PAY_IMPORTANT //augmented by commodity price

/datum/rc_entry/reagent/cryox
	name = "cryoxadone coolant"
	chem_ids = "cryoxadone"
	feemod = PAY_DOCTORATE/3

/datum/rc_entry/item/lambdarod
	name = "Lambda phase-control rod"
	typepath = /obj/item/interdictor_rod
	exactpath = TRUE
	feemod = PAY_IMPORTANT*10



/datum/req_contract/scientific/botanical
	//name = "Feed Me, Seymour (Butz)"
	payout = PAY_TRADESMAN*10*2
	var/list/namevary = list("Botanical Prototyping","Hydroponic Acclimation","Cultivar Propagation","Plant Genotype Study","Botanical Advancement")
	var/list/desc_wherestudy = list(
		"An affiliated hydroponics lab",
		"A cultivation analysis project",
		"A Nanotrasen botanical researcher",
		"A genome profiling project",
		"A terrestrial cultivar developer",
		"The botanical wing of an affiliated station",
		"The botanical team of an affiliated vessel",
		"The botanist of an affiliated outpost"
	)
	var/list/desc_seeds = list("cultivars","seeds","plant specimens","plant strains")
	var/list/desc_bonusflavor = list(
		null,
		" Please ensure all involved seeds have not sprouted.",
		" Secondary beneficial traits are preferred, but not required.",
		" Make absolutely certain to remove all trace seeds of other species before shipping.",
		" Please do not ship extra seeds; only a finite amount of space is available for cultivation.",
		" Ensure any seed coatings used are non-flammable; test conditions may become harsh."
	)

	New()
		src.name = pick(namevary)
		src.flavor_desc = "[pick(desc_wherestudy)] is seeking multiple pure [pick(desc_seeds)] with certain desired genetic traits. [pick(desc_bonusflavor)]"
		src.payout += rand(0,30) * 10

		if(prob(60)) src.rc_entries += rc_buildentry(/datum/rc_entry/seed/scientific/fruit,rand(1,3))
		if(!length(src.rc_entries) || prob(50)) src.rc_entries += rc_buildentry(/datum/rc_entry/seed/scientific/crop,rand(1,3))
		if(length(src.rc_entries) == 1 || prob(30)) src.rc_entries += rc_buildentry(/datum/rc_entry/seed/scientific/veg,rand(1,3))
		if(length(src.rc_entries) == 3) src.item_rewarders += new /datum/rc_itemreward/strange_seed
		src.payout += 8000 * length(src.rc_entries)

		src.item_rewarders += new /datum/rc_itemreward/plant_cartridge
		..()

/datum/rc_entry/seed/scientific
	name = "genetically fussy seed"
	cropname = "Durian"
	feemod = PAY_DOCTORATE*3
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
			if(3) src.gene_reqs["Lifespan"] = rand(3,5)
			if(4) src.gene_reqs["Yield"] = rand(3,5)
			if(5) src.gene_reqs["Potency"] = rand(3,5)
			if(6) src.gene_reqs["Endurance"] = rand(3,5)
			if(7)
				src.gene_reqs["Maturation"] = rand(5,10)
				src.gene_reqs["Production"] = rand(5,10)
		..()


/datum/rc_itemreward/plant_cartridge
	name = "Hydroponics restock cartridge"

	build_reward()
		var/cart = new /obj/item/vending/restock_cartridge/hydroponics
		return cart

/datum/rc_itemreward/strange_seed
	name = "strange seed"

	build_reward()
		var/seed = new /obj/item/seed/alien
		return seed

//Prototypist contract; payout is significantly lower than usual on purpose, since you get "paid in items"
/datum/req_contract/scientific/prototypist
	//name = "Wheatley Moment"
	payout = PAY_DOCTORATE
	weight = 8000
	var/list/namevary = list("Prototyping Assistance","Cutting-Edge Endeavor","Investment Opportunity","Limited Run","Overhaul Project")
	var/list/prototypists = list(
		"Mining technologist",
		//"Biochemical research centre",
		"Engineering firm"
	)
	var/list/protogoals = list(
		"prototyping of a new product",
		"use in devising an improved manufacturing method",
		"refinement of an offered product"
	)
	var/list/desc_bonusflavor = list(
		"Funds are scarce due to budgetary restrictions; a cut of the product will be offered in return.",
		"Requisition fulfiller receives a small stake in the current production run.",
		"Assisting party will receive accreditation in a major publication, and a complementary product sample.",
		"Primary funding is locked up in inventory, so a partial barter is offered - see contract details."
	)

	New()
		src.name = pick(namevary)
		var/prototypist = pick(prototypists) //subvariation 1
		var/goal = pick(protogoals) //subvariation 2
		src.flavor_desc = "[prototypist] seeking supplies for [goal]. [pick(desc_bonusflavor)]"
		src.payout += rand(0,80) * 10

		switch(prototypist)
			if("Mining technologist")
				if(prob(80)) src.rc_entries += rc_buildentry(/datum/rc_entry/stack/molitz_minprice,rand(1,3))
				if(prob(80)) src.rc_entries += rc_buildentry(/datum/rc_entry/stack/pharosium_minprice,rand(1,3))
				if(prob(80) || !length(src.rc_entries))
					src.rc_entries += rc_buildentry(/datum/rc_entry/stack/mauxite_minprice,rand(1,3))

				if(prob(50)) src.rc_entries += rc_buildentry(/datum/rc_entry/item/multitool,1)
				if(prob(50)) src.rc_entries += rc_buildentry(/datum/rc_entry/stack/cable,rand(8,12))

				switch(goal)
					if("prototyping of a new product")
						src.item_rewarders += new /datum/rc_itemreward/turbohammer
						src.rc_entries += rc_buildentry(/datum/rc_entry/stack/cerenkite_minprice,1)
					if("use in devising an improved manufacturing method")
						src.item_rewarders += new /datum/rc_itemreward/manyboom
						src.rc_entries += rc_buildentry(/datum/rc_entry/stack/char,rand(2,5))
						src.payout += PAY_TRADESMAN * 10
					if("refinement of an offered product")
						src.item_rewarders += new /datum/rc_itemreward/concussive_insul
						src.rc_entries += rc_buildentry(/datum/rc_entry/item/free_insuls,1)

			if("Engineering firm")
				if(prob(60))
					src.rc_entries += rc_buildentry(/datum/rc_entry/item/tscan,rand(2,4))
				else
					if(prob(60)) src.rc_entries += rc_buildentry(/datum/rc_entry/item/mainboard_noprice,rand(1,3))
				if(prob(70) || !length(src.rc_entries))
					src.rc_entries += rc_buildentry(/datum/rc_entry/stack/pharosium_minprice,rand(1,3))

				if(prob(60))
					src.rc_entries += rc_buildentry(/datum/rc_entry/item/interval_timer,rand(1,2))
				else
					if(prob(60)) src.rc_entries += rc_buildentry(/datum/rc_entry/item/graviton,rand(1,2))
				if(prob(60)) src.rc_entries += rc_buildentry(/datum/rc_entry/item/lens,1)

				switch(goal)
					if("prototyping of a new product")
						src.item_rewarders += new /datum/rc_itemreward/biorcd
						src.rc_entries += rc_buildentry(/datum/rc_entry/stack/viscerite_minprice,2)
						src.rc_entries += rc_buildentry(/datum/rc_entry/item/dna_activator,1)
					if("use in devising an improved manufacturing method")
						src.item_rewarders += new /datum/rc_itemreward/production_line
						src.rc_entries += rc_buildentry(/datum/rc_entry/stack/claretine_minprice,2)
						//src.rc_entries += rc_buildentry(/datum/rc_entry/item/robot_arm_any,1)
					if("refinement of an offered product")
						src.item_rewarders += new /datum/rc_itemreward/upgraded_welders
						src.rc_entries += rc_buildentry(/datum/rc_entry/item/soldering_noprice,rand(1,2))

		..()

/datum/rc_entry/stack/mauxite_minprice
	name = "mauxite"
	commodity = /datum/commodity/ore/mauxite
	typepath_alt = /obj/item/material_piece/mauxite

/datum/rc_entry/stack/pharosium_minprice
	name = "pharosium"
	commodity = /datum/commodity/ore/pharosium
	typepath_alt = /obj/item/material_piece/pharosium

/datum/rc_entry/stack/molitz_minprice
	name = "molitz"
	commodity = /datum/commodity/ore/molitz
	typepath_alt = /obj/item/material_piece/molitz

/datum/rc_entry/stack/cerenkite_minprice
	name = "cerenkite"
	commodity = /datum/commodity/ore/cerenkite
	typepath_alt = /obj/item/material_piece/cerenkite

/datum/rc_entry/stack/viscerite_minprice
	name = "viscerite"
	commodity = /datum/commodity/ore/viscerite
	typepath_alt = /obj/item/material_piece/viscerite

/datum/rc_entry/item/free_insuls
	name = "NT-standard insulated gloves"
	typepath = /obj/item/clothing/gloves/yellow

/datum/rc_entry/item/tscan
	name = "T-ray scanner"
	typepath = /obj/item/device/t_scanner

/datum/rc_entry/item/mainboard_noprice
	name = "computer mainboard"
	typepath = /obj/item/motherboard

/datum/rc_entry/item/soldering_noprice
	name = "soldering iron"
	typepath = /obj/item/electronics/soldering

/datum/rc_entry/item/dna_activator
	name = "human DNA sample (injector or activator)"
	typepath = /obj/item/genetics_injector

/datum/rc_entry/stack/claretine_minprice
	name = "claretine"
	commodity = /datum/commodity/ore/claretine
	typepath_alt = /obj/item/material_piece/claretine

/datum/rc_entry/item/graviton
	name = "graviton accelerator"
	typepath = /obj/item/mechanics/accelerator

/datum/rc_entry/item/interval_timer
	name = "automatic signaller component"
	typepath = /obj/item/mechanics/interval_timer

/datum/rc_entry/item/magnet_link
	name = "NT vehicle-grade magnet link array"
	typepath = /obj/item/shipcomponent/communications/mining

//mining technologist rewards

/datum/rc_itemreward/turbohammer
	name = "TC-7 Turbohammer"
	build_reward()
		var/theitem = new /obj/item/mining_tool/powerhammer/turbo
		return theitem

/datum/rc_itemreward/manyboom
	name = "standard mining charge"

	New()
		..()
		count = rand(5,9) * 2

	build_reward()
		var/list/charges = list()
		for(var/i in 1 to count)
			charges += new /obj/item/breaching_charge/mining
		return charges

/datum/rc_itemreward/concussive_insul
	name = "insulated concussive gauntlets"

	New()
		..()
		count = rand(2,3)

	build_reward()
		var/list/yielder = list()
		for(var/i in 1 to count)
			yielder += new /obj/item/clothing/gloves/concussive/insulated
		return yielder

//engineering firm rewards

/datum/rc_itemreward/biorcd
	name = "biomimetic rapid construction device"
	build_reward()
		var/theitem = new /obj/item/rcd/material/viscerite
		return theitem

/datum/rc_itemreward/production_line
	name = "engineering equipment"
	var/list/possible_rewards = list("cable coil",
		"RCD cartridges",
		"10-sheet mauxite pack",
		"high-grade power cell",
		"utility belt",
		"RTG pellets + Leigong RTG"
	)
	var/rewardthing

	New()
		..()
		name = pick(possible_rewards)
		switch(name)
			if("cable coil")
				rewardthing = /obj/item/cable_coil
			if("RCD cartridges")
				rewardthing = /obj/item/rcd_ammo/medium
			if("10-sheet mauxite pack")
				rewardthing = /obj/item/sheet/mauxite
			if("high-grade power cell")
				rewardthing = /obj/item/cell/supercell/charged
			if("utility belt")
				rewardthing = /obj/item/storage/belt/utility
			if("RTG pellets + Leigong RTG")
				rewardthing = /obj/item/fuel_pellet/cerenkite
		count = rand(4,6) * 2

	build_reward()
		var/list/yielder = list()
		if(rewardthing == /obj/item/fuel_pellet/cerenkite)
			var/obj/item/electronics/frame/F = new
			F.store_type = /obj/machinery/power/rtg
			F.name = "Leigong RTG frame"
			F.viewstat = 2
			F.secured = 2
			F.icon_state = "dbox_big"
			F.w_class = W_CLASS_BULKY
			yielder += F
		for(var/i in 1 to count)
			yielder += new rewardthing
		return yielder

/datum/rc_itemreward/upgraded_welders
	name = "high-capacity welding tool"

	New()
		..()
		count = rand(3,5)

	build_reward()
		var/list/yielder = list()
		for(var/i in 1 to count)
			yielder += new /obj/item/weldingtool/high_cap
		return yielder






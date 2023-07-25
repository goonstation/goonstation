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
	payout = 5000
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
	feemod = 2550
	exactpath = TRUE

/datum/rc_entry/item/organ/appendix
	name = "appendix"
	feemod = 400
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
	payout = 3300
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
	feemod = 2000

/datum/rc_entry/stack/gemstone
	name = "non-anomalous gemstone"
	typepath = /obj/item/raw_material/gemstone
	feemod = 3500

/datum/rc_entry/stack/telec
	name = "telecrystal"
	commodity = /datum/commodity/ore/telecrystal
	typepath_alt = /obj/item/material_piece/telecrystal
	feemod = 1240 //augmented by commodity price

/datum/rc_entry/reagent/cryox
	name = "cryoxadone coolant"
	chem_ids = "cryoxadone"
	feemod = 90

/datum/rc_entry/item/lambdarod
	name = "Lambda phase-control rod"
	typepath = /obj/item/interdictor_rod
	exactpath = TRUE
	feemod = 11000



/datum/req_contract/scientific/botanical
	//name = "Feed Me, Seymour (Butz)"
	payout = 2500
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
	feemod = 1000
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

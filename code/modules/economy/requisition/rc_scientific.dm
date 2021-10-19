ABSTRACT_TYPE(/datum/req_contract/scientific)
/datum/req_contract/scientific //adam savage dense gas voice: it's scientific!
	req_class = 3

/datum/req_contract/scientific/internalaffairs //get it?
	name = "Don't Ask Too Many Questions"
	payout = 1750
	var/list/namevary = list("Organ Analysis","Organ Research","Biolab Supply","Biolab Partnership","ERROR: CANNOT VERIFY ORIGIN")
	var/list/desc0 = list("conducting","performing","beginning","initiating","seeking supplies for","organizing")
	var/list/desc1 = list("long-term study","intensive trialing","in-depth analysis","study","regulatory assessment")
	var/list/desc2 = list("decay","function","robustness","response to a new medication","atrophy in harsh conditions","therapies","bounciness")

	New()
		src.name = pick(namevary)
		var/dombler = pick(concrete_typesof(/datum/rc_entry/itembypath/organ))
		var/datum/rc_entry/organic = new dombler
		organic.count = rand(2,4)
		src.rc_entries += organic

		src.flavor_desc = "An affiliated research group is [pick(desc0)] a [pick(desc1)] of [organic.name] [pick(desc2)]"
		src.flavor_desc += " and requires genetically-human specimens in adequate condition."
		src.payout += rand(0,40) * 10
		..()

ABSTRACT_TYPE(/datum/rc_entry/itembypath/organ)
/datum/rc_entry/itembypath/organ
	feemod = 1600
	exactpath = TRUE

/datum/rc_entry/itembypath/organ/appendix
	name = "appendix"
	typepath = /obj/item/organ/appendix

/datum/rc_entry/itembypath/organ/brain
	name = "brain"
	typepath = /obj/item/organ/brain

/datum/rc_entry/itembypath/organ/heart
	name = "heart"
	typepath = /obj/item/organ/heart

/datum/rc_entry/itembypath/organ/liver
	name = "liver"
	typepath = /obj/item/organ/liver

/datum/rc_entry/itembypath/organ/spleen
	name = "spleen"
	typepath = /obj/item/organ/spleen



/datum/req_contract/scientific/spectrometry
	name = "Totally Will Not Result In A Resonance Cascade"
	payout = 750
	var/list/namevary = list("Beamline Calibration","Spectral Analysis","Chromatic Analysis","Refraction Survey")
	var/list/desc0 = list(
		"Optics calibration laboratory",
		"Field laboratory at crystal excavation site",
		"Anti-mass spectrometry platform",
		"Transmission laser prototyping facility",
		"Restricted research operation",
		"An affiliated research facility is",
		"An affiliated research vessel is",
		"An affiliated research outpost is"
	)
	var/list/desc1 = list("micro-reflection","latticed capacitive crystal","photonic data encoding","telecrystal stabilization")
	var/list/desc2 = list(
		null,
		" Ensure all materials are free of flammable particulates.",
		" Please use shock-absorbent packing material if possible.",
		" Discussion of this contract with nonessential personnel is discouraged.",
		" If possible, verify all included materials with a third-party quality assessor.",
		" Any damage to included materials not caused by shipping will be reported to your regional manager."
	)

	New()
		src.name = pick(namevary)
		src.flavor_desc = "[pick(desc0)] seeking vital components for [pick(desc1)] research.[pick(desc2)]"
		src.payout += rand(0,40) * 10

		if(prob(80)) src.rc_entries += rc_buildentry(/datum/rc_entry/stack/gemstone,rand(1,8))
		if(prob(20)) src.rc_entries += rc_buildentry(/datum/rc_entry/stack/telec,rand(1,3))
		if(prob(50)) src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/cryox,rand(4,10)*5)
		if(prob(40)) src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/lambdarod,1)
		if(!length(src.rc_entries) || prob(70)) src.rc_entries += rc_buildentry(/datum/rc_entry/itembypath/lens,rand(2,6))

		..()

/datum/rc_entry/itembypath/lens
	name = "lens"
	typepath = /obj/item/lens
	feemod = 260

/datum/rc_entry/stack/gemstone
	name = "non-anomalous gemstone"
	typepath = /obj/item/raw_material/gemstone
	feemod = 420

/datum/rc_entry/stack/telec
	name = "telecrystal"
	typepath = /obj/item/raw_material/telecrystal
	typepath_alt = /obj/item/material_piece/telecrystal
	feemod = 620

/datum/rc_entry/reagent/cryox
	name = "cryoxadone coolant"
	chemname = "cryoxadone"
	feemod = 30

/datum/rc_entry/itembypath/lambdarod
	name = "Lambda phase-control rod"
	typepath = /obj/item/interdictor_rod
	exactpath = TRUE
	feemod = 1000



/datum/req_contract/scientific/botanical
	name = "Feed Me, Seymour (Butz)"
	payout = 950
	var/list/namevary = list("Botanical Prototyping","Hydroponic Acclimation","Cultivar Propagation","Plant Genotype Study")
	var/list/desc0 = list(
		"An affiliated hydroponics lab",
		"A cultivation analysis project",
		"A Nanotrasen botanical researcher",
		"A genome profiling project",
		"A terrestrial cultivar developer",
		"The botanical wing of an affiliated station",
		"The botanical team of an affiliated vessel",
		"The botanist of an affiliated outpost"
	)
	var/list/desc1 = list("cultivars","seeds","plant specimens","plant strains")
	var/list/desc2 = list(
		null,
		" Please ensure all involved seeds have not sprouted.",
		" Secondary beneficial traits are preferred, but not required.",
		" Make absolutely certain to remove all trace seeds of other species before shipping.",
		" Please do not ship extra seeds; only a finite amount of space is available for cultivation.",
		" Ensure any seed coatings used are non-flammable; test conditions may become harsh."
	)

	New()
		src.name = pick(namevary)
		src.flavor_desc = "[pick(desc0)] is seeking multiple pure [pick(desc1)] with certain desired genetic traits. [pick(desc2)]"
		src.payout += rand(0,30) * 10

		if(prob(60)) src.rc_entries += rc_buildentry(/datum/rc_entry/seed/scientific/fruit,rand(1,3))
		if(!length(src.rc_entries) || prob(50)) src.rc_entries += rc_buildentry(/datum/rc_entry/seed/scientific/crop,rand(1,3))
		if(length(src.rc_entries) == 1 || prob(30)) src.rc_entries += rc_buildentry(/datum/rc_entry/seed/scientific/veg,rand(1,3))
		if(length(src.rc_entries) == 3) src.item_rewarders += new /datum/rc_itemreward/strange_seed

		src.item_rewarders += new /datum/rc_itemreward/plant_cartridge
		..()

/datum/rc_entry/seed/scientific
	name = "genetically fussy seed"
	cropname = "Durian"
	feemod = 140
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
			if(1) src.gene_reqs["Maturation"] = rand(10,20) * -1
			if(2) src.gene_reqs["Production"] = rand(10,20) * -1
			if(3) src.gene_reqs["Lifespan"] = rand(3,5)
			if(4) src.gene_reqs["Yield"] = rand(3,5)
			if(5) src.gene_reqs["Potency"] = rand(3,5)
			if(6) src.gene_reqs["Endurance"] = rand(3,5)
			if(7)
				src.gene_reqs["Maturation"] = rand(5,10) * -1
				src.gene_reqs["Production"] = rand(5,10) * -1
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

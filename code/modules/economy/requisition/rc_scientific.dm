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
	var/list/namevary = list("Organ Analysis","Organ Research","Biolab Supply","Biolab Partnership","CANNOT VERIFY ORIGIN","Organ Study")
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


/datum/req_contract/scientific/clonejuice
	payout = PAY_DOCTORATE*5
	weight = 80
	var/list/namevary = list("Biotechnical Project","Gruesome Undertaking","Any Means Necessary","Protein Purchase","Special Slurry")
	var/list/desc_wherestudy = list(
		"(REDACTED)",
		"Biotechnical development site",
		"NT-sanctioned medical systems technician",
		"An affiliated research facility is",
		"An affiliated research vessel is",
		"An affiliated research outpost is"
	)
	var/list/desc_whatstudy = list(
		"suitable naturally-derived fluids",
		"any available protein emulsion of adequate composition",
		"liquefied viscera of appropriate concentration",
		"biologically-sourced fluid"
	)
	var/list/desc_whystudy = list(
		"organism replication research",
		"test operation of a recently repaired system",
		"an undisclosed project",
		"a prototype genetically-synchronized mending system",
		"resupply of depleted biomass reserves"
	)
	var/list/desc_bonusflavor = list(
		null,
		" Impurity below a seven percent concentration is preferable.",
		" Contents need not be single-origin or sterile; integration process includes sterilization.",
		" Please do not source product from NT personnel while they are alive without their explicit permission.",
		" Homogeneity of mixture composition is not of crucial importance."
	)

	New()
		src.name = pick(namevary)
		src.payout += rand(0,9) * 100
		src.flavor_desc = "[pick(desc_wherestudy)] seeking [pick(desc_whatstudy)] for [pick(desc_whystudy)].[pick(desc_bonusflavor)]"
		src.flavor_desc += "<br><br><i>REQHUB ADVISORY: Parameters from contract issuer indicate the following NT-recognized reagents to be compositionally adequate</i>"
		src.flavor_desc += "<br>BLOOD | SYNTHFLESH | BEFF | PEPPERONI | MEAT SLURRY"

		src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/clonejuice,rand(8,15)*20)
		..()

/datum/rc_entry/reagent/clonejuice
	name = "protein solution"
	chem_ids = list(
		"blood",
		"synthflesh",
		"beff",
		"pepperoni",
		"meat_slurry",
		"bloodc"
	)
	feemod = PAY_DOCTORATE/30

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
		if(prob(50)) src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/cryost,rand(4,10)*5)
		if(prob(40)) src.rc_entries += rc_buildentry(/datum/rc_entry/item/lambdarod,1)
		if(!length(src.rc_entries) || prob(70)) src.rc_entries += rc_buildentry(/datum/rc_entry/item/lens,rand(2,6))

		..()

/datum/rc_entry/item/lens
	name = "nano-fabricated lens"
	typepath = /obj/item/lens
	feemod = PAY_IMPORTANT

/datum/rc_entry/item/lens/free
	feemod = 0

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

/datum/rc_entry/stack/telec/minprice
	feemod = 0

/datum/rc_entry/reagent/cryost
	name = "cryostylane coolant"
	chem_ids = "cryostylane"
	feemod = PAY_DOCTORATE/5

/datum/rc_entry/item/lambdarod
	name = "Lambda phase-control rod"
	typepath = /obj/item/interdictor_rod
	exactpath = TRUE
	feemod = PAY_IMPORTANT*10

#define NUM_CHEMLABS 3
#define CHEMLAB_COMBUSTIBLES 1
#define CHEMLAB_SOLVENTS 2
#define CHEMLAB_CULINARY 3

/datum/req_contract/scientific/chemlab
	payout = PAY_DOCTORATE*10
	var/list/desc_friendliness = list(
		"Associated",
		"Nanotrasen",
		"Regional",
		"Private",
		"Consigning"
	)
	var/list/desc_wherestudy = list(
		"development group",
		"studies laboratory",
		"research facility",
		"research vessel",
		"research outpost"
	)

	New()
		src.payout += rand(0,20) * 20

		var/chemlab_id = rand(1,NUM_CHEMLABS)
		switch(chemlab_id)
			if(CHEMLAB_COMBUSTIBLES)
				src.name = pick("Combustibles Research","Exothermic Endeavor")
				src.flavor_desc = "[pick(desc_friendliness)] combustibles [pick(desc_wherestudy)] requesting secure delivery of specified reagents. "
				src.flavor_desc += pick("Ensure reagents are sent in robust containers.","Utilize extreme caution.","Personnel fulfilling order should have appropriate safety equipment.")

				if(prob(70)) src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/phlog_bottle,50)
				if(prob(70) || !length(src.rc_entries)) src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/pyrosium_bottle,50)
				if(prob(70)) src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/sorium_bottle,50)

			if(CHEMLAB_SOLVENTS)
				src.name = pick("Solvent Studies","Break it Down")
				src.flavor_desc = "[pick(desc_friendliness)] solvent [pick(desc_wherestudy)] seeking reagents "
				src.flavor_desc += pick("for prototyping of improved cleaning products.","potentially capable of dissolving a newly-acquired sample.")

				if(prob(70)) src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/fluoro_bottle,50)
				if(prob(70) || !length(src.rc_entries)) src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/nitric_bottle,50)
#ifdef MAP_OVERRIDE_NADIR
				if(prob(70)) src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/tene_bottle,50)
#endif
				if(prob(70)) src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/acetic_bottle,50)

			if(CHEMLAB_CULINARY)
				src.name = pick("Gastro-Chemistry","Culinary Additives","Taste Test Tube")
				src.flavor_desc = "[pick(desc_friendliness)] food sciences [pick(desc_wherestudy)] in need of specified extracts for "
				src.flavor_desc += pick("development of new food additives.","improvement of rations taste profile.","xenoflora edibility enhancement.")

				if(prob(30)) src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/matcha_bottle,rand(3,5)*10)
				if(prob(80)) src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/citrus_bottle,rand(3,5)*10)
				if(prob(40)) src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/mint_bottle,rand(3,5)*10)
				if(prob(30) || !length(src.rc_entries)) src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/capsaicin_bottle,rand(3,5)*10)
				if(prob(40)) src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/cinnamon_bottle,rand(3,5)*10)
				if(prob(50)) src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/cornsyrup_bottle,rand(3,5)*10)
				if(prob(70) || length(src.rc_entries) < 2) src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/chocolate_bottle,rand(3,5)*10)

		..()

//combustibles
/datum/rc_entry/reagent/phlog_bottle
	name = "phlogiston"
	chem_ids = "phlogiston"
	feemod = PAY_DOCTORATE/3
	single_container = TRUE

/datum/rc_entry/reagent/sorium_bottle
	name = "sorium"
	chem_ids = "sorium"
	feemod = PAY_DOCTORATE/5
	single_container = TRUE

/datum/rc_entry/reagent/pyrosium_bottle
	name = "pyrosium"
	chem_ids = "pyrosium"
	feemod = PAY_DOCTORATE/6
	single_container = TRUE

//solvents
/datum/rc_entry/reagent/fluoro_bottle
	name = "fluorosulfuric acid"
	chem_ids = "pacid"
	feemod = PAY_DOCTORATE/3
	single_container = TRUE

/datum/rc_entry/reagent/acetic_bottle
	name = "acetic acid"
	chem_ids = "acetic_acid"
	feemod = PAY_DOCTORATE/5
	single_container = TRUE

/datum/rc_entry/reagent/tene_bottle
	name = "aqua tenebrae"
	chem_ids = "tene"
	feemod = PAY_DOCTORATE/10
	single_container = TRUE

/datum/rc_entry/reagent/nitric_bottle
	name = "nitric acid"
	chem_ids = "nitric_acid"
	feemod = PAY_DOCTORATE/6
	single_container = TRUE

//culinary
/datum/rc_entry/reagent/matcha_bottle
	name = "matcha powder"
	chem_ids = "matcha"
	feemod = PAY_DOCTORATE/3
	single_container = TRUE

/datum/rc_entry/reagent/citrus_bottle
	name = "citrus juice"
	chem_ids = list(
		"juice_orange",
		"juice_lemon",
		"juice_lime",
		"juice_grapefruit",
		"cocktail_citrus"
	)
	feemod = PAY_DOCTORATE/10
	single_container = TRUE

/datum/rc_entry/reagent/mint_bottle
	name = "mint extract"
	chem_ids = "mint"
	feemod = PAY_DOCTORATE/5
	single_container = TRUE

/datum/rc_entry/reagent/capsaicin_bottle
	name = "capsaicin"
	chem_ids = "capsaicin"
	feemod = PAY_DOCTORATE/3
	single_container = TRUE

/datum/rc_entry/reagent/chocolate_bottle
	name = "chocolate"
	chem_ids = "chocolate"
	feemod = PAY_TRADESMAN/10
	single_container = TRUE

/datum/rc_entry/reagent/cinnamon_bottle
	name = "cinnamon"
	chem_ids = "cinnamon"
	feemod = PAY_DOCTORATE/3
	single_container = TRUE

/datum/rc_entry/reagent/cornsyrup_bottle
	name = "corn syrup"
	chem_ids = "cornsyrup"
	feemod = PAY_DOCTORATE/3
	single_container = TRUE


#undef NUM_CHEMLABS
#undef CHEMLAB_COMBUSTIBLES
#undef CHEMLAB_SOLVENTS
#undef CHEMLAB_CULINARY

/datum/req_contract/scientific/botanical_mutates
	payout = PAY_TRADESMAN*10*2
	var/list/namevary = list("Plant Mutation Research","Bio-Mutate Engineering","Agricultural Variation Study","Crop Innovation",
							"Botanical Advancement", "Agronomic Specimen Testing", "Cultivar Innovation Study","Eco-Evolution Research",
							 "Plant-Deviate Experimentation")
	var/list/desc_wherestudy = list(
		"An advanced phytogenetic study lab",
		"The flora development branch of a nearby outpost",
		"The botanical division of a partnered research station",
		"The agricultural innovation department of an allied lab",
		"A terrestrially-based agronomic development team",
		"The botanical wing of an affiliated station",
		"The botanical team of an affiliated vessel",
		"A Nanotrasen horticultural scientist"
	)
	var/list/desc_items = list("botanical mutates","mutated produce","deviant plant specimens","aberrant crop samples", "botanical aberrations",
								"cultivar deviants","anomalous plant varieties")
	var/list/desc_bonusflavor = list(
		null,
		" All specimens must be properly decontaminated before shipment.",
		" Ensure container is properly sealed before sending.",
		" Follow mandatory packing guidelines to ensure specimens are not damaged by transit.",
		" Damaged or low-quality specimens received will be reflected in filed paperwork.",
		" Please use appropriate container to avoid in-transit loss of specimens."
	)

	New()
		src.name = pick(namevary)
		src.flavor_desc = "[pick(desc_wherestudy)] is requesting a specific batch of [pick(desc_items)]. [pick(desc_bonusflavor)]"
		src.payout += rand(0,30) * 10

		if (prob(60))
			src.rc_entries += new /datum/rc_entry/item/mutated_produce(rc_entries,rand(5,12))
			src.payout += 8000
			if (prob(70))
				src.rc_entries += new /datum/rc_entry/item/mutated_produce(rc_entries,rand(5,12))
				src.payout += 5000
			if (prob(20))
				src.rc_entries += new /datum/rc_entry/item/mutated_produce(rc_entries,rand(5,12))
				src.payout += 5000
			AddReward(30)
		else
			src.rc_entries += new /datum/rc_entry/item/mutated_produce/complex(rc_entries,rand(5,12))
			src.payout += 13000 // mutations with prerequisites tend to take considerably more work to produce, so they demand a better reward.
			if (prob(30))
				src.rc_entries += new /datum/rc_entry/item/mutated_produce/complex(rc_entries,rand(5,12))
				src.payout += 10000
			if (prob(30))
				src.rc_entries += new /datum/rc_entry/item/mutated_produce(rc_entries,rand(5,12))
				src.payout += 5000
				if (length(src.rc_entries) < 3 && prob(50))
					src.rc_entries += new /datum/rc_entry/item/mutated_produce(rc_entries,rand(5,12))
					src.payout += 5000
			AddReward(60)
		..()

	proc/AddReward(var/probability)
		if(prob(probability))
			src.item_rewarders += new /datum/rc_itemreward/strange_seed
		else
			src.item_rewarders += new /datum/rc_itemreward/tumbleweed

/datum/rc_entry/item/mutated_produce
	name = "mutated produce"
	// Easy to get mutations, ones which don't have prerequisites.
	// These are chosen either because they're lesser-oft grown mutations, or mutations that are usually associated with antag gimmicks,
	// thus potentially providing a bit of plausible deniability.
	var/list/mutates = list(
		/obj/item/reagent_containers/food/snacks/plant/slurryfruit/omega,
		/obj/item/plant/oat/salt,
		/obj/item/reagent_containers/food/snacks/plant/corn/pepper,
		/obj/item/reagent_containers/food/snacks/plant/soy/soylent,
		/obj/item/plant/herb/commol/burning,
		/obj/item/plant/herb/sassafras,
		/obj/item/reagent_containers/food/snacks/plant/raspberry/blackberry,
		/obj/item/reagent_containers/food/snacks/plant/raspberry/blueraspberry,
		/obj/item/reagent_containers/food/snacks/plant/melon/george,
		/obj/item/reagent_containers/food/snacks/plant/peas/ammonia,
		/obj/item/reagent_containers/food/snacks/plant/grapefruit
	)
	// Group the synth organs together so they don't overwhelm every other option.
	var/list/synthorgans = list(
		/obj/item/organ/eye/synth,/obj/item/organ/brain/synth,/obj/item/organ/heart/synth,/obj/item/organ/lung/synth,/obj/item/organ/appendix/synth,
		/obj/item/organ/pancreas/synth,/obj/item/organ/liver/synth,/obj/item/organ/kidney/synth,/obj/item/organ/spleen/synth,
		/obj/item/organ/intestines/synth,/obj/item/organ/stomach/synth
	)

	complex
		// plants which require specific stats or infusions to mutate, and are thus a little tougher to get.
		mutates = list(
			/obj/item/reagent_containers/food/snacks/plant/tomato/incendiary,
			///datum/plantmutation/rice/ricein,
			/obj/item/reagent_containers/food/snacks/plant/orange/clockwork,
			/obj/item/reagent_containers/food/snacks/mushroom/amanita,
			/obj/item/reagent_containers/food/snacks/mushroom/cloak,
			/obj/item/reagent_containers/food/snacks/plant/apple/poison,
			/obj/item/plant/herb/tobacco/twobacco,
			/obj/item/reagent_containers/food/snacks/plant/coffeeberry/mocha,
			/obj/item/reagent_containers/food/snacks/plant/coffeeberry/latte,
			"synth"
		)

	proc/select_mutate(mutates_list, synthorgans_list)
		var/type = pick(mutates_list)
		if (type == "synth")
			type = pick(synthorgans_list)
		return type

	New(list/entries = null, var/numberof = 1)
		var/obj/item/item
		// duplicate avoidance
		if (entries != null && entries.len > 0)
			var/list/mutates_copy = mutates.Copy()
			var/list/synthorgans_copy = synthorgans.Copy()
			for(var/datum/rc_entry/item/entry in entries)
				mutates_copy -= entry.typepath
				synthorgans_copy -= entry.typepath
			item = select_mutate(mutates_copy, synthorgans_copy)
		else
			item = select_mutate(mutates, synthorgans)
		name = initial(item.name)
		typepath = item
		count = numberof
		..()
		// Override the names of things that are too generic.
		if (typepath == /obj/item/reagent_containers/food/snacks/mushroom/cloak) name = "cloaked panellus mushroom"
		else if (typepath == /obj/item/reagent_containers/food/snacks/mushroom/amanita) name = "amanita mushroom"
		else if (typepath == /obj/item/reagent_containers/food/snacks/plant/tomato/incendiary) name = "volatile tomato"



// old seed requisition
/* /datum/req_contract/scientific/botanical
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
		if(length(src.rc_entries) == 3) src.item_rewarders += new /datum/rc_itemreward/plant_cartridge
		src.payout += 8000 * length(src.rc_entries)

		if(prob(30))
			src.item_rewarders += new /datum/rc_itemreward/strange_seed
		else
			src.item_rewarders += new /datum/rc_itemreward/tumbleweed
		..()*/




/datum/rc_itemreward/plant_cartridge
	name = "Hydroponics restock cartridge"

	build_reward()
		var/cart = new /obj/item/vending/restock_cartridge/hydroponics
		return cart

/datum/rc_itemreward/strange_seed
	name = "strange seed"

	New()
		..()
		src.count = rand(1,3)

	build_reward()
		var/list/seed_list = list()
		for (var/i in 1 to src.count)
			seed_list += new /obj/item/seed/alien
		return seed_list

/datum/rc_itemreward/tumbleweed
	name = "aggressive plant specimen"

	build_reward()
		return new /obj/item/plant/tumbling_creeper

/datum/rc_itemreward/uv_lamp_frame
	name = "ultraviolet botanical lamp"

	build_reward()
		var/obj/item/electronics/frame/F = new
		F.store_type = /obj/machinery/hydro_growlamp
		F.name = "UV Grow Lamp frame"
		F.viewstat = 2
		F.secured = 2
		F.icon_state = "dbox"
		return F


#define NUM_PROTOTYPISTS 4

#define PROTOTYPIST_SAFETY 1
#define PROTOTYPIST_ENERGY 2
#define PROTOTYPIST_ENGINEER 3
#define PROTOTYPIST_REV_ENG 4

#define NUM_GOALS 3

#define GOAL_PROTOTYPING 1
#define GOAL_MANUFACTURE 2
#define GOAL_REFINEMENT 3

//Prototypist contract; payout in cash is notably lower than usual on purpose, since you get "paid in items"
/datum/req_contract/scientific/prototypist
	payout = PAY_DOCTORATE
	weight = 180

	var/list/namevary = list("Prototyping Assistance","Cutting-Edge Endeavor","Investment Opportunity","Limited Run","Overhaul Project")
	var/list/desc_bonusflavor = list(
		"Funds are scarce due to budgetary restrictions; a cut of the product will be offered in return.",
		"Requisition fulfiller receives a small stake in the current production run.",
		"Assisting party will receive accreditation in a major publication, and exclusive (limited) preliminary access.",
		"Primary funding is locked up in inventory, so a partial barter is offered - see contract details."
	)

	New()
		src.name = pick(namevary)
		src.payout += rand(0,80) * 10

		///Identifier of the "prototypist", using defines set up above; associated with what category of product is being developed by the client.
		var/prototypist_id = rand(1,NUM_PROTOTYPISTS)
		/**
		 * Identifier of the prototypist's goal, using defines set up above.
		 * Prototyping goals are developing a novel product; this should be something you can't get anywhere else with a distinct capability.
		 * Manufacture goals are upgrading production for an existing product; these should reward multiple already-existing items (can be dissimilar).
		 * Refinement goals are improving quality or material use efficiency of an existing product; this can sometimes be novel, and sometimes just a high-tier item.
 		*/
		var/goal_id = rand(1,NUM_GOALS)

		var/prototypist_desc //for later description building
		var/goal_desc //ditto

		switch(prototypist_id)
			if(PROTOTYPIST_SAFETY)
				prototypist_desc = "Safety equipment manufacturer"
				if(prob(70)) src.rc_entries += rc_buildentry(/datum/rc_entry/stack/fibrilith_minprice,rand(1,3))
				if(prob(70)) src.rc_entries += rc_buildentry(/datum/rc_entry/stack/cotton,rand(1,3))
				if(prob(30)) src.rc_entries += rc_buildentry(/datum/rc_entry/stack/pharosium_minprice,1)
				if(prob(70) || !length(src.rc_entries)) src.rc_entries += rc_buildentry(/datum/rc_entry/item/matanalyzer,1)

				switch(goal_id)
					if(GOAL_PROTOTYPING)
						goal_desc = "prototyping of an upgraded environment suit"
						src.item_rewarders += new /datum/rc_itemreward/cool_suit
						src.rc_entries += rc_buildentry(/datum/rc_entry/stack/fancy_cloth,2)
						src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/silicate,20)
					if(GOAL_MANUFACTURE)
						goal_desc = "improvement of a suit manufacture line"
						src.item_rewarders += new /datum/rc_itemreward/suit_set
						src.rc_entries += rc_buildentry(/datum/rc_entry/item/coil,1)
						src.rc_entries += rc_buildentry(/datum/rc_entry/item/robot_arm_any,1)
						src.rc_entries += rc_buildentry(/datum/rc_entry/item/control_unit,1)
					if(GOAL_REFINEMENT)
						goal_desc = "refinement of a hazard suit assembly procedure"
						src.item_rewarders += new /datum/rc_itemreward/suv_suit
						src.rc_entries += rc_buildentry(/datum/rc_entry/stack/fancy_cloth,2)
						src.rc_entries += rc_buildentry(/datum/rc_entry/stack/uqill_minprice,1)

			if(PROTOTYPIST_ENERGY)
				prototypist_desc = "Directed energy laboratory"
				if(prob(40))
					src.rc_entries += rc_buildentry(/datum/rc_entry/item/free_insuls,rand(1,2))
				if(prob(80) || !length(src.rc_entries))
					src.rc_entries += rc_buildentry(/datum/rc_entry/item/lens/free,rand(1,2))

				if(prob(80))
					src.rc_entries += rc_buildentry(/datum/rc_entry/stack/claretine/minprice,rand(2,3))
				else
					src.rc_entries += rc_buildentry(/datum/rc_entry/stack/electrum,1)
				src.rc_entries += rc_buildentry(/datum/rc_entry/stack/cable,30)

				switch(goal_id)
					if(GOAL_PROTOTYPING)
						goal_desc = "prototyping of a multifunctional industrial tool"
						src.item_rewarders += new /datum/rc_itemreward/hedron
						src.rc_entries += rc_buildentry(/datum/rc_entry/item/laser_drill,1)
					if(GOAL_MANUFACTURE)
						goal_desc = "enhancement of the quality assurance process"
						src.item_rewarders += new /datum/rc_itemreward/beam_devices
					if(GOAL_REFINEMENT)
						goal_desc = "augmentation of cargo transporter functionality"
						src.item_rewarders += new /datum/rc_itemreward/cargotele
						src.rc_entries += rc_buildentry(/datum/rc_entry/stack/telec/minprice,1)

			if(PROTOTYPIST_ENGINEER)
				prototypist_desc = "Engineering firm"
				if(prob(60))
					src.rc_entries += rc_buildentry(/datum/rc_entry/item/tscan,rand(1,2))
				else
					if(prob(60)) src.rc_entries += rc_buildentry(/datum/rc_entry/item/mainboard_noprice,rand(1,3))
				if(prob(70) || !length(src.rc_entries))
					src.rc_entries += rc_buildentry(/datum/rc_entry/stack/pharosium_minprice,rand(1,3))

				if(prob(60))
					src.rc_entries += rc_buildentry(/datum/rc_entry/item/interval_timer,rand(1,2))
				else
					if(prob(60)) src.rc_entries += rc_buildentry(/datum/rc_entry/item/graviton,rand(1,2))
				if(prob(60)) src.rc_entries += rc_buildentry(/datum/rc_entry/item/coil,1)

				switch(goal_id)
					if(GOAL_PROTOTYPING)
						goal_desc = "prototyping of a tool for biodegradable construction"
						src.item_rewarders += new /datum/rc_itemreward/biorcd
						src.rc_entries += rc_buildentry(/datum/rc_entry/stack/viscerite_minprice,2)
						src.rc_entries += rc_buildentry(/datum/rc_entry/item/dna_activator,1)
					if(GOAL_MANUFACTURE)
						goal_desc = "production line efficiency improvements"
						src.item_rewarders += new /datum/rc_itemreward/production_line
						if(prob(40))
							src.rc_entries += rc_buildentry(/datum/rc_entry/item/control_unit,1)
						else
							src.rc_entries += rc_buildentry(/datum/rc_entry/stack/claretine,2)
						src.rc_entries += rc_buildentry(/datum/rc_entry/item/robot_arm_any,1)
					if(GOAL_REFINEMENT)
						goal_desc = "sanitation hardware enhancement"
						src.payout += rand(80,130) * 20
						src.item_rewarders += new /datum/rc_itemreward/sonic_shower
						src.rc_entries += rc_buildentry(/datum/rc_entry/item/soldering_noprice,rand(1,2))

			if(PROTOTYPIST_REV_ENG)
				prototypist_desc = "Artifact reverse-engineer"
				src.payout += rand(80,120) * 20

				if(prob(60))
					var/suitsets = rand(1,2)
					src.rc_entries += rc_buildentry(/datum/rc_entry/item/radsuit,suitsets)
					src.rc_entries += rc_buildentry(/datum/rc_entry/item/radhelm,suitsets)
				else
					if(prob(40)) src.rc_entries += rc_buildentry(/datum/rc_entry/stack/uqill_minprice,1)
				if(prob(70) || !length(src.rc_entries))
					src.rc_entries += rc_buildentry(/datum/rc_entry/item/geiger,1)
				if(prob(60)) src.rc_entries += rc_buildentry(/datum/rc_entry/item/coil,1)
				if(prob(60)) src.rc_entries += rc_buildentry(/datum/rc_entry/item/mini_ox,rand(1,3)*2)

				switch(goal_id)
					if(GOAL_PROTOTYPING)
						goal_desc = "cutting-edge decentralized storage technology"
						src.rc_entries += rc_buildentry(/datum/rc_entry/stack/telec/minprice,3)
						src.rc_entries += rc_buildentry(/datum/rc_entry/artifact/force_projection,1)
						src.item_rewarders += new /datum/rc_itemreward/terminus
					if(GOAL_MANUFACTURE)
						goal_desc = "production of a medical biomatter recombinator"
						//when built and powered, slowly makes weak healing patches out of food you load in
						src.rc_entries += rc_buildentry(/datum/rc_entry/artifact/martian,1)
						src.item_rewarders += new /datum/rc_itemreward/medimulcher
					if(GOAL_REFINEMENT)
						goal_desc = "development of an enhanced mobile recharging bay"
						//special backpack capable of accepting a large power cell to recharge contents automatically
						src.rc_entries += rc_buildentry(/datum/rc_entry/artifact/chamber,1)
						src.item_rewarders += new /datum/rc_itemreward/recharge_bay

		src.flavor_desc = "[prototypist_desc] seeking supplies for [goal_desc]. [pick(desc_bonusflavor)]"

		..()

#undef NUM_PROTOTYPISTS

#undef PROTOTYPIST_SAFETY
#undef PROTOTYPIST_ENERGY
#undef PROTOTYPIST_ENGINEER
#undef PROTOTYPIST_REV_ENG

#undef NUM_GOALS

#undef GOAL_PROTOTYPING
#undef GOAL_MANUFACTURE
#undef GOAL_REFINEMENT

/datum/rc_entry/artifact/martian
	name = "any martian artifact"
	required_origin = "Martian"

/datum/rc_entry/artifact/force_projection
	name = "force projection artifact"
	acceptable_types = list(
		"Elemental Wand",
		"Energy Gun",
		"Forcefield Wand",
		"Melee Weapon"
	)

/datum/rc_entry/artifact/chamber
	name = "chamber-type artifact"
	acceptable_types = list(
		"Bag of Holding",
		"Beaker",
		"Instrument",
		"Large power cell",
		"Small power cell",
		"Pitcher"
	)

/datum/rc_entry/item/radsuit
	name = "radiation suit"
	typepath = /obj/item/clothing/suit/hazard/rad
	feemod = PAY_TRADESMAN

/datum/rc_entry/item/radhelm
	name = "radiation helmet"
	typepath = /obj/item/clothing/head/rad_hood
	feemod = PAY_TRADESMAN

/datum/rc_entry/item/geiger
	name = "Geiger counter"
	typepath = /obj/item/device/geiger

/datum/rc_entry/item/mini_ox
	name = "personnel-class 'mini' pressure tank"
	typepath = /obj/item/tank/mini_oxygen

/datum/rc_entry/stack/fibrilith_minprice
	name = "fibrilith"
	commodity = /datum/commodity/ore/fibrilith
	typepath_alt = /obj/item/material_piece/fibrilith

/datum/rc_entry/stack/cotton
	name = "cotton"
	typepath = /obj/item/raw_material/cotton
	typepath_alt = /obj/item/material_piece/cloth/cottonfabric

/datum/rc_entry/item/matanalyzer
	name = "material analyzer"
	typepath = /obj/item/device/matanalyzer

/datum/rc_entry/stack/fancy_cloth
	name = "high-grade cloth (carbon or bee wool)"
	typepath = /obj/item/material_piece/cloth

	extra_eval(obj/item/eval_item)
		. = FALSE
		if(eval_item.material?.getID() == "carbonfibre" || eval_item.material?.getID() == "beewool")
			return TRUE

/datum/rc_entry/stack/uqill_minprice
	name = "uqill"
	commodity = /datum/commodity/ore/uqill
	typepath_alt = /obj/item/material_piece/uqill

/datum/rc_entry/stack/pharosium_minprice
	name = "pharosium"
	commodity = /datum/commodity/ore/pharosium
	typepath_alt = /obj/item/material_piece/pharosium

/datum/rc_entry/stack/viscerite_minprice
	name = "viscerite"
	commodity = /datum/commodity/ore/viscerite
	typepath_alt = /obj/item/material_piece/viscerite

/datum/rc_entry/item/free_insuls
	name = "NT-standard insulated gloves"
	typepath = /obj/item/clothing/gloves/yellow

/datum/rc_entry/item/coil
	name = "nano-fabricated metal coil"
	typepath = /obj/item/coil/small

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

/datum/rc_entry/item/laser_drill
	name = "handheld laser drill"
	typepath = /obj/item/mining_tool/powered/drill

/datum/rc_entry/stack/claretine
	name = "claretine"
	commodity = /datum/commodity/ore/claretine
	typepath_alt = /obj/item/material_piece/claretine
	feemod = PAY_DOCTORATE

/datum/rc_entry/stack/claretine/minprice
	feemod = 0

/datum/rc_entry/stack/electrum
	name = "electrum"
	typepath = /obj/item/material_piece
	mat_id = "electrum"
	feemod = PAY_IMPORTANT

/datum/rc_entry/item/graviton
	name = "graviton accelerator"
	typepath = /obj/item/mechanics/accelerator

/datum/rc_entry/item/interval_timer
	name = "automatic signaller component"
	typepath = /obj/item/mechanics/interval_timer

/datum/rc_entry/item/control_unit
	name = "programmable control unit"
	typepath = /obj/item/mechanics/mc14500

/datum/rc_entry/item/magnet_link
	name = "NT vehicle-grade magnet link array"
	typepath = /obj/item/shipcomponent/communications/mining


//safety equipment manufacturer rewards

/datum/rc_itemreward/cool_suit
	name = "prototype space suit set"
	build_reward()
		var/list/theitems = list()
		theitems += new /obj/item/clothing/suit/space/custom/prototype
		theitems += new /obj/item/clothing/head/helmet/space/custom/prototype
		return theitems

/datum/rc_itemreward/suit_set
	name = "buncha suits"
	var/list/possible_rewards = list("paramedic suit",
		"heavy firesuit",
		"light space suit set",
		"emergency space suit set",
		"radiation suit set"
	)
	var/rewardthing1
	var/rewardthing2

	New()
		..()
		name = pick(possible_rewards)
		count = rand(4,6)
		switch(name)
			if("paramedic suit")
				rewardthing1 = /obj/item/clothing/suit/hazard/paramedic
			if("heavy firesuit")
				rewardthing1 = /obj/item/clothing/suit/hazard/fire/heavy
			if("light space suit set")
				rewardthing1 = /obj/item/clothing/suit/space/light
				rewardthing2 = /obj/item/clothing/head/helmet/space/light
			if("emergency space suit set")
				count *= 2
				rewardthing1 = /obj/item/clothing/suit/space/emerg
				rewardthing2 = /obj/item/clothing/head/emerg
			if("radiation suit set")
				rewardthing1 = /obj/item/clothing/head/rad_hood
				rewardthing2 = /obj/item/clothing/suit/hazard/rad

	build_reward()
		var/list/yielder = list()
		for(var/i in 1 to count)
			yielder += new rewardthing1
			if(rewardthing2)
				yielder += new rewardthing2
		return yielder

/datum/rc_itemreward/suv_suit
	name = "hazard-rated suit set"
	build_reward()
		var/list/theitems = list()
		theitems += new /obj/item/clothing/suit/space/suv
		theitems += new /obj/item/clothing/head/helmet/space/industrial
		return theitems


//directed energy laboratory rewards

/datum/rc_itemreward/hedron
	name = "prototype multifunction tool"
	build_reward()
		var/theitem = new /obj/item/mining_tool/powered/hedron_beam
		return theitem

/datum/rc_itemreward/beam_devices
	name = "surplus directed-energy equipment"
	var/list/possible_rewards = list(/obj/item/shipcomponent/mainweapon/mining,
		/obj/item/shipcomponent/mainweapon/laser,
		/obj/item/shipcomponent/mainweapon/taser,
		/obj/item/gun/energy/phaser_small,
		/obj/item/gun/energy/taser_gun,
		/obj/item/gun/energy/egun_jr,
		/obj/machinery/emitter,
		/obj/item/interdictor_rod/epsilon,
		/obj/item/interdictor_rod/sigma
	)

	New()
		..()
		count = rand(2,3)

	build_reward()
		var/list/yielder = list()
		for(var/i in 1 to count)
			var/beamy = pick(possible_rewards)
			yielder += new beamy
		return yielder

/datum/rc_itemreward/cargotele
	name = "upgraded cargo transporter"
	build_reward()
		var/theitem = new /obj/item/cargotele/efficient
		return theitem


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
		count = rand(4,6)

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

/datum/rc_itemreward/sonic_shower
	name = "sonic shower head"

	New()
		..()
		count = rand(2,3)

	build_reward()
		var/list/yielder = list()
		for(var/i in 1 to count)
			var/obj/item/electronics/frame/F = new
			F.store_type = /obj/machinery/sonic_shower
			F.name = "sonic shower head frame"
			F.viewstat = 2
			F.secured = 2
			F.icon_state = "dbox_big"
			F.w_class = W_CLASS_BULKY
			yielder += F
		return yielder

//artifact reverse engineer rewards

/datum/rc_itemreward/terminus
	name = "prototype terminus drive"
	count = 3
	build_reward()
		var/list/yielder = list()
		for(var/i in 1 to count)
			yielder += new /obj/item/terminus_drive
		return yielder

/datum/rc_itemreward/medimulcher
	name = "APS-4 bio-integrator"
	build_reward()
		var/obj/item/electronics/frame/F = new
		F.store_type = /obj/machinery/medimulcher
		F.name = "APS-4 bio-integrator frame"
		F.viewstat = 2
		F.secured = 2
		F.icon_state = "dbox_big"
		F.w_class = W_CLASS_BULKY
		return F

/datum/rc_itemreward/recharge_bay
	name = "mobile recharging bay"
	build_reward()
		var/theitem = new /obj/item/storage/backpack/recharge_bay
		return theitem

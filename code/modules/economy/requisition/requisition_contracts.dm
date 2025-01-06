//quartermasters export requisition contracts
//inspired by azrun's special order events
//but a whole other thing

/**
 * Small helper proc to simplify basic contract entry creation.
 * Accepts the path to the entry datum, and the count (in whatever unit it uses) to require.
 */
/proc/rc_buildentry(entry_datum_type,number_of)
	var/datum/rc_entry/entryize = new entry_datum_type
	entryize.count = number_of
	return entryize

/**
 * Proc to test a standard market contract for functionality. Test special orders with random event trigger instead.
 *
 * Will add the contract to requisitions list and pin the contract, ignoring the one-pin limit or any contract type pin restrictions.
 * Don't use this in live rounds, pin behavior will be wonky.
 */
/client/proc/TestMarketReq()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Requisition Test"
	set desc = "Generates a specified requisition path and pins it to market."
	ADMIN_ONLY
	SHOW_VERB_DESC
	var/contract_path = input("Specify type path", "Requisition", null, null)
	if (!contract_path) return
	if (istext(contract_path))
		contract_path = text2path(contract_path)
	if (!ispath(contract_path))
		boutput(usr, SPAN_ALERT("Requisition test failed - no path specified."))
		return
	var/datum/req_contract/new_contract = new contract_path
	if(!istype(new_contract))
		boutput(usr, SPAN_ALERT("Requisition test failed - invalid type path."))
		return
	shippingmarket.req_contracts += new_contract
	new_contract.pinned = TRUE
	boutput(usr, "Pinned [new_contract.name] to shipping market.")

//contract entries: contract creation instantiates these for "this much of whatever"
//these entries each have their own "validation protocol", automatically set up when instantiated

//base entry
ABSTRACT_TYPE(/datum/rc_entry)
///Requisition contract entry: analyzes things passed to it, returns whether they were needed, and is checked for completion at end of analyses.
/datum/rc_entry
	///Name as shown on the requisition contract itself. Can be different from your item's real name for flavor purposes.
	var/name
	///What quantity this entry requires (examples: item quantity, stack quantity or reagent units); can be adjusted at any point during creation.
	var/count = 1
	///When an item contributes to fulfillment, this value should be incremented; when it matches or exceeds the count, the entry is fully satisfied.
	var/rollcount = 0
	///How much this entry will contribute to a contract's overall payout, PER COUNT. Some entry types can configure this from commodity data.
	var/feemod = 0

	/**
	 * Evaluation proc called by contracts to see whether an item fulfills the entry's requirements.
	 *
	 * When creating an entry type, there are two required outputs from the variant's rc_eval proc.
	 * First, it must return true if the atom the entry has been passed contributes to satisfying the condition, so the atom can be consumed.
	 * Second, you must increment rollcount if the condition was satisfied; often by 1, but can be multiple for things like reagents or stacks.
	 */
	proc/rc_eval(atom/eval_item)
		. = FALSE

	/**
	 * Hook point for slight modifications to a contract entry's fulfillment condition.
	 * This should ALWAYS be included in any entry variant, as late as possible in primary checks but before the rolling count is incremented.
	 * It should return TRUE if additional checks pass, and FALSE if they do not.
	 */
	proc/extra_eval(atom/eval_item)
		return TRUE

	// Mandatory: override to generate descriptions
	proc/generate_requis_description()
		return "This description has not been generated correctly, please submit a bug report."

	// Procs for default descriptions
	proc/requis_description_item()
		return "[count]x [name]<br>"


	proc/requis_description_stack()
		return "[count]+ [name]<br>"

	// A shortened description for use with shopping lists
	proc/shoppinglist_description()
		return "<li>[name]</li>"

ABSTRACT_TYPE(/datum/rc_entry/item)
///Basic item entry. Use for items that can't stack, and whose properties outside of path aren't relevant.
/datum/rc_entry/item
	///Type path of the item the entry is looking for.
	var/typepath
	///Optional alternate type path to look for. Useful when an item has two functionally interchangeable forms, such as an empty or charged power cell.
	var/typepath_alt
	///If true, requires precise path; if false (default), sub-paths are accepted.
	var/exactpath = FALSE
	///Commodity path. If defined, will augment the per-item payout with the highest market rate for that commodity, and set the type path if not initially specified.
	var/commodity

	New()
		if(src.commodity) // Fetch configuration data from commodity if specified
			var/datum/commodity/CM = src.commodity
			if(!src.typepath) src.typepath = initial(CM.comtype)
			src.feemod += initial(CM.baseprice)
			src.feemod += initial(CM.upperfluc)
		..()

	rc_eval(obj/eval_item)
		. = ..()
		if(rollcount >= count) return // Standard skip-if-complete
		var/valid_item = FALSE
		if(src.exactpath) // More fussy type evaluation
			if(eval_item.type == typepath || (typepath_alt && eval_item.type == typepath_alt)) valid_item = TRUE
		else // Regular type evaluation
			if(istype(eval_item,typepath) || (typepath_alt && istype(eval_item,typepath_alt))) valid_item = TRUE
		if(!valid_item) return
		if(!extra_eval(eval_item)) return
		src.rollcount++
		. = TRUE

	generate_requis_description()
		return requis_description_item()

	shoppinglist_description()
		return "<li>[count]x [name]</li>"

ABSTRACT_TYPE(/datum/rc_entry/food)
///Food item entry, used to properly detect food integrity.
/datum/rc_entry/food
	///Type path of the item the entry is looking for.
	var/typepath
	///If true, requires precise path; if false (default), sub-paths are accepted.
	var/exactpath = FALSE
	/**
	 * Food integrity determines how the requisition handles bites_left.
	 * FOOD_REQ_BY_ITEM means each individual item fulfills one count, regardless of how many bites it has left.
	 * FOOD_REQ_BY_BITE means each bite fulfills one count - useful for orders of sliceable foods like pizza.
	 * FOOD_REQ_INTACT means the item's bites_left must be equal to the initial defined, suitable for items like fresh produce that should arrive intact.
	 * If you are making a requisition for a particular food item and it's not sliceable, leave this with its default value.
	 */
	var/food_integrity = FOOD_REQ_INTACT

	///Commodity path. If defined, will augment the per-item payout with the highest market rate for that commodity, and set the type path if not initially specified.
	var/commodity

	New()
		if(src.commodity) // Fetch configuration data from commodity if specified
			var/datum/commodity/CM = src.commodity
			if(!src.typepath) src.typepath = initial(CM.comtype)
			src.feemod += initial(CM.baseprice)
			src.feemod += initial(CM.upperfluc)
		..()

	rc_eval(obj/item/reagent_containers/food/snacks/eval_item)
		. = ..()
		if(rollcount >= count) return // Standard skip-if-complete
		if(src.exactpath && eval_item.type != typepath) return // More fussy type evaluation
		else if(!istype(eval_item,typepath)) return // Regular type evaluation
		if(!extra_eval(eval_item)) return
		switch(food_integrity)
			if(FOOD_REQ_INTACT)
				if(eval_item.bites_left != eval_item.uneaten_bites_left) return
				src.rollcount++
			if(FOOD_REQ_BY_BITE)
				src.rollcount += eval_item.bites_left
			if(FOOD_REQ_BY_ITEM)
				src.rollcount++
		. = TRUE

	generate_requis_description()
		return requis_description_item()

	shoppinglist_description()
		return "<li>[count]x [name]</li>"

ABSTRACT_TYPE(/datum/rc_entry/stack)
///Stackable item entry. Remarkably, used for items that can be stacked.
/datum/rc_entry/stack
	///Type path of the item the entry is looking for.
	var/typepath
	///Optional alternate type path to look for. Useful when an item has two functionally interchangeable forms, such as raw or refined ore.
	var/typepath_alt
	///Commodity path. If defined, will augment the per-item payout with the highest market rate for that commodity, and set the type path if not initially specified.
	var/commodity
	///Material ID string. If defined, will require the stack's material's mat_id to match the specified mat_id.
	var/mat_id

	New()
		if(src.commodity) // Fetch configuration data from commodity if specified
			var/datum/commodity/CM = src.commodity
			if(!src.typepath) src.typepath = initial(CM.comtype)
			src.feemod += initial(CM.baseprice)
			src.feemod += initial(CM.upperfluc)
		..()

	rc_eval(obj/item/eval_item)
		. = ..()
		if(rollcount >= count) return // Standard skip-if-complete
		if(!istype(eval_item)) return // If it's not an item, it's not a stackable
		if(mat_id) // If we're checking for a material, do that here with a tag comparison
			if(!eval_item.material || eval_item.material.getID() != src.mat_id)
				return
		if(istype(eval_item,typepath) || (typepath_alt && istype(eval_item,typepath_alt)))
			if(!extra_eval(eval_item)) return
			rollcount += eval_item.amount
			. = TRUE // Let manager know passed eval item is claimed by contract

	generate_requis_description()
		return requis_description_stack()

	shoppinglist_description()
		return "<li>[count]+ [name]</li>"

///Reagent entry. Searches for reagents in sent objects, consuming any suitable reagent containers until the quantity is satisfied.
ABSTRACT_TYPE(/datum/rc_entry/reagent)
/datum/rc_entry/reagent
	///IDs of reagents being looked for in the evaluation; can be a single one in string form, or a list containing several strings.
	var/chem_ids = "water"
	///Reagent container type: optionally set this to a path to require reagents be contained in that particular thing to count.
	var/contained_in
	///Plural description of that container - beakers, patches, pills, etc. First letter capitalized. Should be set if contained_in is set.
	var/container_name
	///If set to true, entirety of requested reagent must be within a single reagent container in the shipment
	var/single_container = FALSE

	rc_eval(atom/eval_item)
		. = ..()
		if(rollcount >= count) return //standard skip-if-complete
		if(contained_in && !istype(eval_item,contained_in)) return // Do we have a required container type? If so, validate it
		if(!extra_eval(eval_item)) return
		if(eval_item.reagents)
			var/C // Total count of matching reagents, by unit
			if(islist(src.chem_ids)) // If there are multiple reagents to evaluate, iterate by chem IDs
				for(var/chemplural in src.chem_ids)
					C += eval_item.reagents.get_reagent_amount(chemplural)
			else // If there's just the one, check for it directly
				C = eval_item.reagents.get_reagent_amount(src.chem_ids)
			if(single_container && C >= count) // for single-container evaluation
				rollcount += C
				. = TRUE
			else
				if(C)
					rollcount += C
					. = TRUE // Let manager know reagent was found in passed eval item

	generate_requis_description()
		return requis_description_reagent()

	proc/requis_description_reagent()
		. = ""
		if(single_container)
			. += "[count] unit[s_es(count)] of [name] in discrete vessel<br>"
		else
			if(container_name)
				. += "[container_name] containing [count]+ unit[s_es(count)] of [name]<br>"
			else
				. += "[count]+ unit[s_es(count)] of [name]<br>"

	shoppinglist_description()
		return "<li>[count]+ unit[s_es(count)] of [name]</li>"

///Plant genetics entry. Searches for items of the correct crop name, typically matching a particular genetic makeup.
ABSTRACT_TYPE(/datum/rc_entry/plant)
/datum/rc_entry/plant
	///Name of the desired crop, as it appears in plant genes.
	var/cropname = "Tomato"
	/**
	 * List of required plant gene parameters, each formatted as a key-value pair.
	 * Add your key value pairs to this list, either hard-coded or with a thing in New() BEFORE ..(), for evaluation. Example of the latter:
	 * src.gene_reqs["Maturation"] = rand(10,20) * -1
	 *
	 * Available keys (strings): Maturation, Production, Lifespan, Yield, Potency, Endurance.
	 * Number paired with key should be a negative integer for maturation or production, or a positive integer otherwise.
	 *
	 * If this is left empty, any seed with a genome and the appropriate crop name will be accepted.
	 */
	var/gene_reqs = list()

	//Variables for evaluation purposes. Should not be changed in base type configuration.
	var/gene_factors = 0
	var/gene_count = 0

	New()
		src.gene_factors = length(src.gene_reqs)
		..()

	// override to account for any item type that has plantgenes and planttype. Boy do I miss interfaces.
	proc/GetGenesAndPlantType(atom/eval_item)
		if (!istype(eval_item,/obj/item/reagent_containers/food/snacks/plant)) return
		var/GenesAndType = list()
		var/obj/item/reagent_containers/food/snacks/plant/plant = eval_item
		GenesAndType += plant.plantgenes
		GenesAndType += plant.planttype
		return GenesAndType

	rc_eval(atom/eval_item)
		. = ..()
		if(rollcount >= count) return // Standard skip-if-complet
		var/genesandtype = GetGenesAndPlantType(eval_item)
		if (!genesandtype) return
		var/datum/plantgenes/genes
		var/datum/plant/plant_type
		genes = genesandtype[1]
		plant_type = genesandtype[2]

		if(!genes) return // No genome? Skip it
		if(plant_type.name != cropname) return // Wrong species? Skip it
		if(!extra_eval(eval_item)) return

		gene_count = 0
		for(var/index in gene_reqs) // Iterate over each parameter to see if the genome meets it, or exceeds it in the right direction
			switch(index)
				if("Maturation")
					if(genes.growtime >= gene_reqs["Maturation"]) gene_count++
				if("Production")
					if(genes.harvtime >= gene_reqs["Production"]) gene_count++
				if("Lifespan")
					if(genes.harvests >= gene_reqs["Lifespan"]) gene_count++
				if("Yield")
					if(genes.cropsize >= gene_reqs["Yield"]) gene_count++
				if("Potency")
					if(genes.potency >= gene_reqs["Potency"]) gene_count++
				if("Endurance")
					if(genes.endurance >= gene_reqs["Endurance"]) gene_count++

		if(gene_count >= gene_factors) // Compare satisfied parameter count to number of parameters. Met or exceeded means seed satisfies requirements
			increase_rollcount(eval_item)
			. = TRUE // Let manager know seed passes muster and is claimed by contract

	proc/increase_rollcount(atom/eval_item)
		src.rollcount++

	generate_requis_description()
		return requis_description_plant()

	proc/requis_description_plant(is_seed = FALSE)
		. = ""
		var/seed_text = is_seed ? " seed" : "" // need to manually add the word 'seed' if it's a seed
		if(length(gene_reqs))
			. += "[count]x [cropname][seed_text] with following traits:<br>"
			for(var/index in gene_reqs)
				. += "* [index]: [gene_reqs[index]] or higher<br>"
		else
			. += "[count]x [cropname][seed_text]<br>"

// Plant genetics entry that specifically checks for seeds
/datum/rc_entry/plant/seed
	GetGenesAndPlantType(eval_item)
		if (!istype(eval_item,/obj/item/seed)) return
		var/GenesAndType = list()
		var/obj/item/seed/seed = eval_item
		GenesAndType += seed.plantgenes
		GenesAndType += seed.planttype
		return GenesAndType

	generate_requis_description()
		return requis_description_plant(TRUE)

	// Account for seed packets, treat each seed charge as an item.
	increase_rollcount(atom/eval_item)
		var/obj/item/seed/eval_seed = eval_item
		src.rollcount += eval_seed.charges

///Artifact entry. Evaluates provided handheld artifacts based on their artifact parameters.
ABSTRACT_TYPE(/datum/rc_entry/artifact)
/datum/rc_entry/artifact
	///Origin requirement, checked against the artifact's type_name if specified. Current type names are Silicon, Martian, Wizard, Eldritch, Precursor
	var/required_origin
	///Types of artifact functionality desired. Can be left empty.
	var/acceptable_types = list()

	New()
		..()

	rc_eval(atom/eval_item)
		. = ..()
		if(rollcount >= count) return // Standard skip-if-complete
		var/obj/eval_obj = eval_item
		if(!istype(eval_obj)) return // Not an object? Not an artifact
		if(!istype(eval_obj.artifact,/datum/artifact/)) return // No artifact data? Skip it

		var/datum/artifact/arty = eval_obj.artifact

		if(required_origin && arty.artitype.type_name != required_origin) return
		if(length(acceptable_types))
			var/is_acceptable_type = FALSE
			for(var/nom in acceptable_types)
				if(arty.type_name == nom)
					is_acceptable_type = TRUE
			if(!is_acceptable_type) return

		if(!extra_eval(eval_item)) return
		src.rollcount++
		. = TRUE // Let manager know artifact passes muster and is claimed by contract

	generate_requis_description()
		return requis_description_artifact()

	proc/requis_description_artifact()
		. = ""
		. += "x[count] handheld artifact with following parameters<br>"
		if(required_origin)
			. += "| Origin class: [required_origin]<br>"
		else
			. += "| Origin class: any<br>"
		if(length(acceptable_types))
			. += "| Acceptable categories:<br>"
			for(var/index in acceptable_types)
				. += "| [index]<br>"
		else
			. += "| Acceptable categories: Any<br>"

/**
 * Item reward datum optionally used in contract creation.
 * Should generally return an object, or set of objects that makes sense as a list entry (i.e. "fast food meal" for a burger, fries and soda).
 * To use: in a contract's New(), instantiate one of these and add it to src.item_rewarders.
 *
 * Rewards are only physically created once the contract is successfully fulfilled, so time-sensitive rewards should be feasible if desired.
 */
/datum/rc_itemreward
	///What the reward is, as shown in front-end if showing item rewards is not disabled
	var/name = "something"
	///How many of the reward you'll get; optional, used for more flexibility in front end descriptions
	var/count

	New()
		..()

	///This should return an item or list of items (NOT A PATH) for the requisition handler to physically pack.
	proc/build_reward()


ABSTRACT_TYPE(/datum/req_contract)
/**
 * The primary datum for requisitions contracts.
 * Top level contains cargo handling data, payout data, item reward generators if present, and formatted descriptions for the QM requisitions menu.
 *
 * Actual evaluation of contract entries occurs through requisition entries (/datum/rc_entry) contained within.
 * The contents of containers are evaluated sequentially, using the rc_eval proc of each entry that hasn't been fulfilled yet at time of evaluation.
 *
 * Fulfillment is managed internally within entries; the contract only cares about whether an item was needed, and whether the entry is satisfied.
 * You can have any sort of evaluation you like within new types of contract entry, as long as you're feeding back those two pieces of information.
 *
 * Contracts are divided by requisition class. Three market classes of requisition currently exist: Aid, Civilian and Scientific.
 * Each market cycle, these requisitions are refreshed, with at least one requisition from each category being present after the refresh.
 * These contract types have different requirements and sometimes an influence on what you can do with them. See individual files for more details.
 * Special requisition contracts also exist, shipped directly as a hard copy. These obey notably different rules, as described in rc_special.dm.
 */
/datum/req_contract
	///Title of the contract as used by the requisitions clearinghouse seen in the QM supply computer
	var/name = "Requisition Contract"
	///Class of the requisition contract, defaulting to misc (0); aid requisitions are urgent and will not wait for you
	var/req_class = MISC_CONTRACT
	///Requisition code used for standard contracts; is automatically generated if not specified, but can be manually set if desired
	var/req_code
	///Contract's roll weight; dictates frequency of market appearance, or probability of selection for special order event. Can be left default
	var/weight = 100

	///A baseline amount of cash you'll be given for fulfilling the requisition; this is modified by entries
	///The current thinking as of the time of writing this comment is for this to be 10 times some salary's wage,
	///times an additional modifier based on difficulty
	var/payout = 0
	///List of contract entry datums; sent cargo will be passed into these for evaluation
	var/list/rc_entries = list()
	///Optional list of item rewarder datums; their descriptions will be shown on contract unless flagged otherwise
	var/list/item_rewarders = list()
	///Is set to true to prevent any included item rewarders from being shown on contract
	var/hide_item_payouts
	///Optional but recommended flavor text to accompany the contract
	var/flavor_desc
	///Mandatory descriptive text that lists contract requirements; automatically populated from the list of rc_entries
	var/requis_desc = ""
	///Tracks whether contract is pinned; one contract at a time may be pinned, reserving it for QM and preventing it from leaving with market shift
	var/pinned = FALSE
	///determines payout multiplier
	var/static/count = 0

	New() //in individual definitions, create entries and THEN call this, it'll get things set up for you
		..()
		if(!src.req_code)
			var/flavoraffix = rand(0,9)
			switch(req_class)
				if(CIV_CONTRACT) flavoraffix = prob(50) ? "C" : "P"
				if(AID_CONTRACT) flavoraffix = prob(50) ? "A" : "E"
				if(SCI_CONTRACT) flavoraffix = prob(50) ? "S" : "R"
			src.req_code = "REQ-[flavoraffix][rand(0,9)][rand(0,9)][rand(0,9)]-[pick(consonants_upper)][prob(20) ? pick(consonants_upper) : rand(0,9)]"

		for(var/datum/rc_entry/rce in rc_entries) //Visual formatting of list entries
			requis_desc += rce.generate_requis_description()
			src.payout += rce.feemod * rce.count
		src.payout *= round(1.1**count + 0.1*count)

/**
 * Called to tally a crate's contents, to evaluate whether they've fulfilled the contract.
 * If only_evaluate is FALSE, the proc will actually consume relevant contents, and return a post-sale handling code appropriately.
 * If only_evaluate is TRUE, the proc will simply index relevant contents, and return a textual summary of detected contract fulfillment.
 */
	proc/requisify(obj/storage/crate/sell_crate, only_evaluate = FALSE)
		var/contents_index = list() //Registry of everything in crate, including contents of item containers within it
		var/contents_to_cull = list() //Things consumed to fulfill the requisition - extras are sent back
		var/eval_message = "<font color=#FF9900>Contents insufficient for marked requisition" //Used in only_evaluate mode, start of the return text
		var/successes_needed = length(src.rc_entries) //Decremented with each successful fulfillment, reach 0 to win

		contents_index += sell_crate.contents

		for(var/atom/A in sell_crate.contents)
			if (A.storage)
				contents_index += A.storage.get_all_contents()

		. = REQ_RETURN_NOSALE //by default return no success

		//item boxes can require evaluation of items that don't physically exist, so they need special logic
		for(var/obj/item/item_box/IB in contents_index)
			LAGCHECK(LAG_LOW)
			contents_index -= IB
			if(IB.item_amount < 1) return //no empty or infinite box evals
			contents_index += IB.contents //evaluate real items through conventional means
			var/illusory_contents = IB.item_amount - length(IB.contents) //how many nonexistent items we have to iterate over
			var/box_satisfies = FALSE

			if(illusory_contents && IB.contained_item)
				var/testbench_item = new IB.contained_item //create a temporary example item to check
				while(illusory_contents > 0)
					illusory_contents--
					for(var/datum/rc_entry/shoppin in rc_entries)
						if(shoppin.rc_eval(testbench_item))
							box_satisfies = TRUE
				qdel(testbench_item)

			if(box_satisfies && !only_evaluate)
				contents_to_cull += IB

		for(var/atom/A in contents_index)
			LAGCHECK(LAG_LOW)
			for(var/datum/rc_entry/shoppin in rc_entries)
				if(shoppin.rc_eval(A) && !only_evaluate) //if we found something that the requisition asked for, prepare it for removal if live
					if(A.loc != sell_crate && isobj(A.loc)) //if you sent your stuff in an item container, recipient will keep it
						contents_to_cull |= A.loc
					else
						contents_to_cull += A

		for(var/datum/rc_entry/shopped in rc_entries)
			if(shopped.rollcount >= shopped.count)
				successes_needed--
			else if(only_evaluate)
				eval_message += " | '[shopped.name]' [shopped.rollcount]/[shopped.count]"

		if(only_evaluate) //evaluation mode conclusion: return evaluation text, do nothing else
			if(!successes_needed) //would successfully sell
				. = "Contents sufficient for marked requisition."
			else //wouldn't successfully sell; close out the red
				eval_message += "</font>"
				. = eval_message
			for(var/datum/rc_entry/shopped in rc_entries) //clean up afterwards, either way
				shopped.rollcount = 0

		else //live mode conclusion: cull contents, return an appropriate handling code
			if(!successes_needed)
				if(src.req_code == "REQ-THIRDPARTY") //third party sales do not preserve leftover items, returns are only done if there is an item reward
					for(var/atom/X in contents_index)
						if(X) qdel(X)
					return REQ_RETURN_FULLSALE
				. = REQ_RETURN_SALE //sale, but may be leftover items. find out by culling
				for(var/atom/X in contents_to_cull)
					if(X) qdel(X)
				if(!length(sell_crate.contents)) //total clean sale, tell shipping manager to del the crate
					. = REQ_RETURN_FULLSALE
			else //sale unsuccessful; reset rolling counts of all contract entries in preparation for subsequent fulfillment attempts
				for(var/datum/rc_entry/shopped in rc_entries)
					shopped.rollcount = 0


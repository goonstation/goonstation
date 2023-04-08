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

	var/contract_path = input("Specify type path", "Requisition", null, null)
	if (!contract_path) return
	if (istext(contract_path))
		contract_path = text2path(contract_path)
	if (!ispath(contract_path))
		boutput(usr, "<span class='alert'>Requisition test failed - no path specified.</span>")
		return
	var/datum/req_contract/new_contract = new contract_path
	if(!istype(new_contract))
		boutput(usr, "<span class='alert'>Requisition test failed - invalid type path.</span>")
		return
	shippingmarket.req_contracts += new_contract
	new_contract.pinned = TRUE
	boutput(usr, "Pinned [new_contract.name] to shipping market.")

//contract entries: contract creation instantiates these for "this much of whatever"
//these entries each have their own "validation protocol", automatically set up when instantiated

//entry classes
#define RC_ITEM 1
#define RC_REAGENT 2
#define RC_STACK 3
#define RC_SEED 4

//base entry
ABSTRACT_TYPE(/datum/rc_entry)
///Requisition contract entry: analyzes things passed to it, returns whether they were needed, and is checked for completion at end of analyses.
/datum/rc_entry
	///Name as shown on the requisition contract itself. Can be different from your item's real name for flavor purposes.
	var/name
	///The evaluation class of the entry; used for formatting when building the text form of a contract's list of requirements.
	var/entryclass = RC_ITEM
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

ABSTRACT_TYPE(/datum/rc_entry/item)
///Basic item entry. Use for items that can't stack, and whose properties outside of path aren't relevant.
/datum/rc_entry/item
	entryclass = RC_ITEM
	///Type path of the item the entry is looking for.
	var/typepath
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
		if(src.exactpath && eval_item.type != typepath) return // More fussy type evaluation
		else if(!istype(eval_item,typepath)) return // Regular type evaluation
		src.rollcount++
		. = TRUE

ABSTRACT_TYPE(/datum/rc_entry/food)
///Food item entry, used to properly detect food integrity.
/datum/rc_entry/food
	entryclass = RC_ITEM
	///Type path of the item the entry is looking for.
	var/typepath
	///If true, requires precise path; if false (default), sub-paths are accepted.
	var/exactpath = FALSE
	///Must-be-whole switch. If true, food must be at initial bites_left value and is counted by whole units; if false, it is counted by bites left.
	var/must_be_whole = TRUE

	rc_eval(obj/item/reagent_containers/food/snacks/eval_item)
		. = ..()
		if(rollcount >= count) return // Standard skip-if-complete
		if(src.exactpath && eval_item.type != typepath) return // More fussy type evaluation
		else if(!istype(eval_item,typepath)) return // Regular type evaluation
		if(must_be_whole)
			if(eval_item.bites_left != initial(eval_item.bites_left)) return
			src.rollcount++
		else
			src.rollcount += eval_item.bites_left
		. = TRUE

ABSTRACT_TYPE(/datum/rc_entry/stack)
///Stackable item entry. Remarkably, used for items that can be stacked.
/datum/rc_entry/stack
	entryclass = RC_STACK
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
		if(mat_id) // If we're checking for materials, do that here with a tag comparison
			if(!eval_item.material || eval_item.material.mat_id != src.mat_id)
				return
		if(istype(eval_item,typepath) || (typepath_alt && istype(eval_item,typepath_alt)))
			rollcount += eval_item.amount
			. = TRUE // Let manager know passed eval item is claimed by contract

///Reagent entry. Searches for reagents in sent objects, consuming any suitable reagent containers until the quantity is satisfied.
ABSTRACT_TYPE(/datum/rc_entry/reagent)
/datum/rc_entry/reagent
	entryclass = RC_REAGENT
	///IDs of reagents being looked for in the evaluation; can be a single one in string form, or a list containing several strings.
	var/chem_ids = "water"
	///Reagent container type: optionally set this to a path to require reagents be contained in that particular thing to count.
	var/contained_in
	///Plural description of that container - beakers, patches, pills, etc. First letter capitalized. Should be set if contained_in is set.
	var/container_name

	rc_eval(atom/eval_item)
		. = ..()
		if(rollcount >= count) return //standard skip-if-complete
		if(contained_in && !istype(eval_item,contained_in)) return // Do we have a required container type? If so, validate it
		if(eval_item.reagents)
			var/C // Total count of matching reagents, by unit
			if(islist(src.chem_ids)) // If there are multiple reagents to evaluate, iterate by chem IDs
				for(var/chemplural in src.chem_ids)
					C += eval_item.reagents.get_reagent_amount(chemplural)
			else // If there's just the one, check for it directly
				C = eval_item.reagents.get_reagent_amount(src.chem_ids)
			if(C)
				rollcount += C
				. = TRUE // Let manager know reagent was found in passed eval item

///Seed entry. Searches for seeds of the correct crop name, typically matching a particular genetic makeup.
ABSTRACT_TYPE(/datum/rc_entry/seed)
/datum/rc_entry/seed
	entryclass = RC_SEED
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

	rc_eval(atom/eval_item)
		. = ..()
		if(rollcount >= count) return // Standard skip-if-complete
		if(!istype(eval_item,/obj/item/seed)) return // Not a seed? Skip it

		var/obj/item/seed/cultivar = eval_item
		if(!cultivar.plantgenes) return // No genome? Skip it
		if(cultivar.planttype.name != cropname) return // Wrong species? Skip it

		gene_count = 0
		for(var/index in gene_reqs) // Iterate over each parameter to see if the genome meets it, or exceeds it in the right direction
			switch(index)
				if("Maturation")
					if(cultivar.plantgenes.growtime >= gene_reqs["Maturation"]) gene_count++
				if("Production")
					if(cultivar.plantgenes.harvtime >= gene_reqs["Production"]) gene_count++
				if("Lifespan")
					if(cultivar.plantgenes.harvests >= gene_reqs["Lifespan"]) gene_count++
				if("Yield")
					if(cultivar.plantgenes.cropsize >= gene_reqs["Yield"]) gene_count++
				if("Potency")
					if(cultivar.plantgenes.potency >= gene_reqs["Potency"]) gene_count++
				if("Endurance")
					if(cultivar.plantgenes.endurance >= gene_reqs["Endurance"]) gene_count++

		if(gene_count >= gene_factors) // Compare satisfied parameter count to number of parameters. Met or exceeded means seed satisfies requirements
			src.rollcount++
			. = TRUE // Let manager know seed passes muster and is claimed by contract

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
			switch(rce.entryclass)
				if(RC_ITEM)
					src.requis_desc += "[rce.count]x [rce.name]<br>"
				if(RC_REAGENT)
					var/datum/rc_entry/reagent/rchem = rce
					if(rchem.container_name)
						src.requis_desc += "[rchem.container_name] containing [rchem.count]+ unit[s_es(rchem.count)] of [rchem.name]<br>"
					else
						src.requis_desc += "[rchem.count]+ unit[s_es(rchem.count)] of [rchem.name]<br>"
				if(RC_STACK)
					src.requis_desc += "[rce.count]+ [rce.name]<br>"
				if(RC_SEED)
					var/datum/rc_entry/seed/rceed = rce
					if(length(rceed.gene_reqs))
						src.requis_desc += "[rce.count]x [rceed.cropname] seed with following traits:<br>"
						for(var/index in rceed.gene_reqs)
							if(index == "Maturation" || index == "Production")
								src.requis_desc += "* [index]: [rceed.gene_reqs[index]] or lower<br>"
							else
								src.requis_desc += "* [index]: [rceed.gene_reqs[index]] or higher<br>"
					else
						src.requis_desc += "[rce.count]x [rceed.cropname] seed<br>"
			src.payout += rce.feemod * rce.count

	proc/requisify(obj/storage/crate/sell_crate)
		var/contents_index = list() //registry of everything in crate, including contents of item containers within it
		var/contents_to_cull = list() //things consumed to fulfill the requisition, extras are sent back
		var/successes_needed = length(src.rc_entries) //decremented with each successful fulfillment, reach 0 to win

		contents_index += sell_crate.contents

		for(var/obj/item/storage/S in sell_crate.contents)
			contents_index += S.get_all_contents()

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

			if(box_satisfies)
				contents_to_cull += IB

		for(var/atom/A in contents_index)
			LAGCHECK(LAG_LOW)
			for(var/datum/rc_entry/shoppin in rc_entries)
				if(shoppin.rc_eval(A)) //found something that the requisition asked for, let it know
					if(A.loc != sell_crate && isobj(A.loc)) //if you sent your stuff in an item container, it'll be kept
						contents_to_cull |= A.loc
					else
						contents_to_cull += A

		for(var/datum/rc_entry/shopped in rc_entries)
			if(shopped.rollcount >= shopped.count)
				successes_needed--

		if(!successes_needed)
			if(src.req_code == "REQ-THIRDPARTY") //third party sales do not preserve leftover items, returns are only done if there is an item reward
				for(var/atom/X in contents_index)
					if(X) qdel(X)
				return REQ_RETURN_FULLSALE
			if(src.pinned) shippingmarket.has_pinned_contract = FALSE //tell shipping market pinned contract was fulfilled
			. = REQ_RETURN_SALE //sale, but may be leftover items. find out by culling
			for(var/atom/X in contents_to_cull)
				if(X) qdel(X)
			if(!length(sell_crate.contents)) //total clean sale, tell shipping manager to del the crate
				. = REQ_RETURN_FULLSALE
		else //sale unsuccessful; reset rolling counts of all contract entries in preparation for subsequent fulfillment attempts
			for(var/datum/rc_entry/shopped in rc_entries)
				shopped.rollcount = 0
		return

#undef RC_ITEM
#undef RC_REAGENT
#undef RC_STACK
#undef RC_SEED

//quartermasters export requisition contracts
//inspired by azrun's special order events
//but a whole other thing

//simplify entry creation
/proc/rc_buildentry(entry_datum_type,number_of)
	var/datum/rc_entry/entryize = new entry_datum_type
	entryize.count = number_of
	return entryize

//contract entries: contract creation instantiates these for "this much of whatever"
//these entries each have their own "validation protocol", automatically set up when instantiated

//entry classes
#define RC_ITEM 1
#define RC_REAGENT 2
#define RC_STACK 3
#define RC_SEED 4

//base entry
ABSTRACT_TYPE(/datum/rc_entry)
///Requisition contract entry: analyzes objects passed to it, returns whether they were needed, and is checked for completion at end of analyses
/datum/rc_entry
	///Name as shown on the requisition contract itself. Can be different from your item's real name for flavor purposes
	var/name
	///The evaluation class of the entry; used when building the text form of a contract's list of requirements
	var/entryclass = RC_ITEM
	///What quantity this entry requires, be it in item quantity, stack quantity or reagent units; can be adjusted at any point during creation
	var/count = 1
	///When an item fulfills a requirement, this value should be incremented; when it matches or exceeds the count, the entry is fully satisfied
	var/rollcount = 0
	///How much this entry will contribute to a contract's overall payout, PER COUNT; commodities will add to this themselves
	var/feemod = 0

	proc/rc_eval(atom/eval_item) //evaluation procedure, used in different entry classes
		. = FALSE

//when performing custom evaluations, there are 2 actions that must occur
//first, you must return true if the atom the entry has been passed contributes to satisfying the condition
//second, you must increment rollcount on satisfying condition; for a simple "is satisfied or not", increment rollcount by 1 with count left default

//items, by the path
ABSTRACT_TYPE(/datum/rc_entry/item)
/datum/rc_entry/item
	entryclass = RC_ITEM
	var/typepath //item that must be sold
	var/exactpath = FALSE //evaluates precise path, instead of path and subtypes
	var/commodity //commodity path. if defined, will automatically adjust feemod and (if unset) typepath

	New()
		if(src.commodity)
			var/datum/commodity/CM = src.commodity
			if(!src.typepath) src.typepath = initial(CM.comtype)
			src.feemod += initial(CM.baseprice)
			src.feemod += initial(CM.upperfluc)
		..()

	rc_eval(obj/eval_item)
		. = ..()
		if(rollcount >= count) return // standard skip-if-complete
		if(src.exactpath && eval_item.type != typepath) return // more fussy type evaluation
		else if(!istype(eval_item,typepath)) return // regular type evaluation
		src.rollcount++
		. = TRUE

//reagents, by the unit
ABSTRACT_TYPE(/datum/rc_entry/reagent)
/datum/rc_entry/reagent
	entryclass = RC_REAGENT
	var/chemname = "water" //chem(s) being looked for in the evaluation; can be a list of several, or just the one

	rc_eval(atom/eval_item)
		. = ..()
		if(rollcount >= count) return // standard skip-if-complete
		if(eval_item.reagents)
			var/C
			if(islist(src.chemname))
				for(var/chemplural in src.chemname)
					C += eval_item.reagents.get_reagent_amount(chemplural)
			else
				C = eval_item.reagents.get_reagent_amount(src.chemname)
			if(C)
				rollcount += C
				. = TRUE //let manager know reagent was found in passed eval item

//stacks, path (or alt path) and amount
ABSTRACT_TYPE(/datum/rc_entry/stack)
/datum/rc_entry/stack
	entryclass = RC_STACK
	var/typepath
	var/typepath_alt //use when an item can have two stackable forms, such as with a raw and refined ore (can use this along commodity)
	var/commodity //commodity path. if defined, will automatically adjust feemod and (if unset) typepath

	New()
		if(src.commodity)
			var/datum/commodity/CM = src.commodity
			src.typepath = initial(CM.comtype)
			src.feemod += initial(CM.baseprice)
			src.feemod += initial(CM.upperfluc)
		..()

	rc_eval(obj/item/eval_item)
		. = ..()
		if(rollcount >= count) return // standard skip-if-complete
		if(!istype(eval_item)) return //if it's not an item, it's not a stackable
		if(eval_item.type == typepath || (typepath_alt && eval_item.type == typepath_alt))
			rollcount += eval_item.amount
			. = TRUE //let manager know passed eval item is claimed by contract

//seeds, analyzed by genetic composition
ABSTRACT_TYPE(/datum/rc_entry/seed)
/datum/rc_entry/seed
	entryclass = RC_SEED
	var/cropname = "Tomato"
	var/gene_factors = 0
	var/gene_count = 0

	var/gene_reqs = list() //this and cropname are the only things you need to set
	// add your key value pairs to this list, either hard-coded or with a thing in New before ..(), for evaluation
	// available keys (strings): Maturation, Production, Lifespan, Yield, Potency, Endurance
	// number paired with key should be a negative integer for maturation or production, or a positive integer otherwise

	New()
		src.gene_factors = length(src.gene_reqs)
		..()

	rc_eval(atom/eval_item)
		. = ..()
		if(rollcount >= count) return // standard skip-if-complete
		gene_count = 0

		if(!istype(eval_item,/obj/item/seed)) return
		var/obj/item/seed/cultivar = eval_item
		if(!cultivar.plantgenes) return
		if(cultivar.planttype.name != cropname) return

		for(var/index in gene_reqs)
			switch(index)
				if("Maturation")
					if(cultivar.plantgenes.growtime <= gene_reqs["Maturation"]) gene_count++
				if("Production")
					if(cultivar.plantgenes.harvtime <= gene_reqs["Production"]) gene_count++
				if("Lifespan")
					if(cultivar.plantgenes.harvests >= gene_reqs["Lifespan"]) gene_count++
				if("Yield")
					if(cultivar.plantgenes.cropsize >= gene_reqs["Yield"]) gene_count++
				if("Potency")
					if(cultivar.plantgenes.potency >= gene_reqs["Potency"]) gene_count++
				if("Endurance")
					if(cultivar.plantgenes.endurance >= gene_reqs["Endurance"]) gene_count++

		if(gene_count >= gene_factors)
			src.rollcount++
			. = TRUE

//item rewarders: contract creation instantiates these to fill item payout list if applicable
//distinct from rc_entry datums, these -!! are instantiators of their own !!- that the requisition handler calls on
/datum/rc_itemreward
	var/name = "something" // what the reward is, description wise
	var/count // how many of the reward you'll get; optional, used for front end descriptive purposes

	New()
		..()

	proc/build_reward() // this should return an item or list of items, for requisition handler to pack


ABSTRACT_TYPE(/datum/req_contract)
///Datum that holds and manages contract entries; most handling of contracts should reference these
/datum/req_contract
	///Title of the contract as used by the requisitions clearinghouse seen in the QM supply computer
	var/name = "Gary's Secret Mission"
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

		for(var/datum/rc_entry/rce in rc_entries)
			switch(rce.entryclass)
				if(RC_ITEM)
					src.requis_desc += "[rce.count]x [rce.name]<br>"
				if(RC_REAGENT)
					src.requis_desc += "[rce.count]+ unit[s_es(rce.count)] of [rce.name]<br>"
				if(RC_STACK)
					src.requis_desc += "[rce.count]+ [rce.name]<br>"
				if(RC_SEED)
					var/datum/rc_entry/seed/rceed = rce
					src.requis_desc += "[rce.count]x [rceed.cropname] seed with following traits:<br>"
					for(var/index in rceed.gene_reqs)
						if(index == "Maturation" || index == "Production")
							src.requis_desc += "* [index]: [rceed.gene_reqs[index]] or lower<br>"
						else
							src.requis_desc += "* [index]: [rceed.gene_reqs[index]] or higher<br>"
			src.payout += rce.feemod * rce.count

	proc/requisify(obj/storage/crate/sell_crate)
		var/contents = list() //everything in crate
		var/contents_to_cull = list() //things consumed to fulfill the requisition, extras are sent back
		var/successes_needed = length(src.rc_entries) //decremented with each successful fulfillment, reach 0 to win

		contents += sell_crate.contents
		for(var/obj/item/storage/S in contents)
			contents |= S.get_all_contents()

		. = REQ_RETURN_NOSALE //by default return no success
		for(var/atom/A in contents)
			LAGCHECK(LAG_LOW)
			for(var/datum/rc_entry/shoppin in rc_entries)
				if(shoppin.rc_eval(A)) //found something that the requisition asked for, let it know
					contents_to_cull |= A

		for(var/datum/rc_entry/shopped in rc_entries)
			if(shopped.rollcount >= shopped.count)
				successes_needed--

		if(!successes_needed)
			if(src.req_code == "REQ-THIRDPARTY") //third party sales do not preserve leftover items, returns are only done if there is an item reward
				for(var/atom/X in contents)
					if(X) qdel(X)
				return REQ_RETURN_FULLSALE
			if(src.pinned) shippingmarket.has_pinned_contract = FALSE //tell shipping market pinned contract was fulfilled
			. = REQ_RETURN_SALE //sale, but may be leftover items. find out by culling
			for(var/atom/X in contents_to_cull)
				if(X) qdel(X)
			if(!length(sell_crate.contents)) //total clean sale, tell shipping manager to del the crate
				. = REQ_RETURN_FULLSALE
		return

#undef RC_ITEM
#undef RC_REAGENT
#undef RC_STACK
#undef RC_SEED

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
#define RC_ITEMBYPATH 1
#define RC_REAGENT 2
#define RC_STACK 3
#define RC_SEED 4

//base entry
ABSTRACT_TYPE(/datum/rc_entry)
/datum/rc_entry
	var/name //what the entry is for, description wise
	var/entryclass = RC_ITEMBYPATH // type of entry this is, tracked like this for formatting purposes
	var/count = 1 // how much this contract entry is for, be it in item quantity, stack quantity or reagent units
	var/rollcount = 0 //when an item is analyzed, this increments on a successful evaluation, for later tallying
	var/feemod = 0 // how much cash this item adds to the overall payout

	proc/rc_eval(atom/eval_item) //evaluation procedure, used in different entry classes
		. = FALSE
		if(rollcount >= count) return //if you've already got enough, skip and tell the manager as such

//when performing custom evaluations, there are 2 actions that must occur
//first, you must return true if the atom the entry has been passed contributes to satisfying the condition
//second, you must increment rollcount on satisfying condition; for a simple "is satisfied or not", increment rollcount by 1 with count left default

//items, by the path
ABSTRACT_TYPE(/datum/rc_entry/itembypath)
/datum/rc_entry/itembypath
	entryclass = RC_ITEMBYPATH
	var/typepath = /obj/gibtyson //item that must be sold
	var/exactpath = FALSE //evaluates precise path, instead of path and subtypes

	rc_eval(obj/eval_item)
		. = ..()
		if(!istype(eval_item)) return //if it's not an object, it's definitely not an itembypath
		if(exactpath && eval_item.type == typepath)
			src.rollcount++
			. = TRUE //let manager know passed eval item is claimed by contract
		else if(istype(eval_item,typepath))
			src.rollcount++
			. = TRUE
		return

//reagents, by the unit
ABSTRACT_TYPE(/datum/rc_entry/reagent)
/datum/rc_entry/reagent
	entryclass = RC_REAGENT
	var/chemname = "water" //chem(s) being looked for in the evaluation; can be a list of several, or just the one

	rc_eval(atom/eval_item)
		. = ..()
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
		return

//stacks, path (or alt path) and amount
ABSTRACT_TYPE(/datum/rc_entry/stack)
/datum/rc_entry/stack
	entryclass = RC_STACK
	name = "super bass" //for things like ores, you may want to tag as plural, so you end up with something like "4 or more Bohrum"
	var/typepath = /obj/item/raw_material/bohrum
	var/typepath_alt //use when an item can have two stackable forms, such as with a raw and refined ore

	rc_eval(obj/item/eval_item)
		. = ..()
		if(!istype(eval_item)) return //if it's not an item, it's not a stackable
		if(eval_item.type == typepath || (typepath_alt && eval_item.type == typepath_alt))
			if(eval_item.amount)
				rollcount += eval_item.amount
				. = TRUE //let manager know passed eval item is claimed by contract
		return

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
		return

//reward items: contract creation instantiates these to fill item payout list if applicable
//distinct from rc_entry datums, these -!! are instantiators of their own !!- that the requisition handler calls on
/datum/rc_itemreward
	var/name = "something" // what the reward is, description wise
	var/count // how many of the reward you'll get; optional, used for front end descriptive purposes

	New()
		..()

	proc/build_reward() // this should return an item or list of items, for requisition handler to pack

//contracts, which contain entries and are what are exposed to the qm side of things
ABSTRACT_TYPE(/datum/req_contract)
/datum/req_contract
	var/name = "Henry Whip a Zamboni" // title text that gets a big front row seat
	var/req_class = 0 // class of the requisition contract; aid requisitions are urgent and will not wait for you
	//0 is unclassified/misc, 1 is civilian, 2 is emergency aid, 3 is scientific
	var/req_code // requisition code for cargo handling purposes
	// clearinghouse requisitions will get a randomly-generated one, third party ones will get REQ-THIRDPARTY and require their requisition papers

	var/payout = 0 // a baseline amount of cash you'll be given for fulfilling the requisition, modified by entries
	var/list/item_rewarders = list() // optional list for items you're sent as payment; will be shown on contract unless flagged otherwise
	var/hide_item_payouts // set this to prevent the item payout from being shown on contract
	var/flavor_desc // optional flavor text for the contract
	var/requis_desc = "" // mandatory descriptive text for the contract contents, to be generated alongside them
	var/list/rc_entries = list() // list of requisition contact entries
	var/pinned = 0 // one contract at a time may be pinned, preventing it from rotating out with market shift

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
				if(RC_ITEMBYPATH)
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

		. = 0 //by default return no success
		for(var/atom/A in contents)
			LAGCHECK(LAG_LOW)
			for(var/datum/rc_entry/shoppin in rc_entries)
				if(shoppin.rc_eval(A)) //found something that the requisition asked for, let it know
					contents_to_cull |= A

		for(var/datum/rc_entry/shopped in rc_entries)
			if(shopped.rollcount >= shopped.count)
				successes_needed--

		if(!successes_needed)
			if(src.req_code == "REQ-THIRDPARTY") //third party sales do not preserve leftover items, returns are only on item reward
				for(var/atom/X in contents)
					if(X) qdel(X)
				return 2
			if(src.pinned) shippingmarket.has_pinned_contract = 0 //tell shipping market pinned contract was fulfilled
			. = 1 //sale, but may be leftover items
			for(var/atom/X in contents_to_cull)
				if(X) qdel(X)
			if(!length(sell_crate.contents)) //total clean sale, tell shipping manager to del the crate
				. = 2
		return

#undef RC_ITEMBYPATH
#undef RC_REAGENT
#undef RC_STACK
#undef RC_SEED

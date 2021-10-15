//quartermasters export requisition contracts
//inspired by azrun's special order events
//but a whole other thing

//todo: pinning one contract to persist past market cycles

//contract entries: contract creation instantiates these for "this much of whatever"
//these entries each have their own "validation protocol", automatically set up when instantiated

#define RC_ITEMBYPATH 1
#define RC_REAGENT 2
#define RC_STACK 3

//base entry
ABSTRACT_TYPE(/datum/rc_entry)
/datum/rc_entry
	var/name //what the entry is for, description wise
	var/entryclass = RC_ITEMBYPATH // type of entry this is, tracked like this for formatting purposes
	var/count = 1 // how much this contract entry is for, be it in item quantity, stack quantity or reagent units
	var/rollcount = 0 //when an item is analyzed, this increments on a successful evaluation, for later tallying
	var/feemod = 0 // how much cash this item adds to the overall payout
	var/isplural = FALSE //skips item pluralization, i.e. you'd set this to true for "jeans". can usually be ignored
	var/es = FALSE //used for item pluralization, i.e. you'd set this to true for "tomato". can usually be ignored

	proc/rc_eval(obj/eval_item) //evaluation procedure, used in different entry classes
		if(rollcount >= count) return FALSE //if you've already got enough, skip and tell the manager as such

//items, by the path
ABSTRACT_TYPE(/datum/rc_entry/itembypath)
/datum/rc_entry/itembypath
	entryclass = RC_ITEMBYPATH
	var/typepath = /obj/gibtyson //item that must be sold
	var/exactpath = FALSE //evaluates precise path, instead of path and subtypes

	rc_eval(obj/eval_item)
		..()
		. = FALSE
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
	var/chemname = "water" //chem being looked for in the evaluation

	rc_eval(obj/eval_item)
		..()
		. = FALSE
		if(istype(eval_item,/obj/item/reagent_containers))
			var/obj/item/reagent_containers/C = eval_item
			rollcount += C.reagents.get_reagent_amount(chemname)
			. = TRUE //let manager know reagent was found in passed eval item
		return


ABSTRACT_TYPE(/datum/rc_entry/stack)
/datum/rc_entry/stack
	entryclass = RC_STACK
	name = "super bass" //for things like ores, you may want to tag as plural, so you end up with something like "4 or more Bohrum"
	var/typepath = /obj/item/raw_material/bohrum
	var/typepath_alt //use when an item can have two stackable forms, such as with a raw and refined ore

	rc_eval(obj/item/eval_item)
		..()
		. = FALSE
		if(eval_item.type == typepath || (typepath_alt && eval_item.type == typepath_alt))
			if(eval_item.amount)
				rollcount += eval_item.amount
				. = TRUE //let manager know passed eval item is claimed by contract
		return

//contracts, which contain entries and are what are exposed to the qm side of things
ABSTRACT_TYPE(/datum/req_contract)
/datum/req_contract
	var/name = "Henry Whip a Zamboni" // title text that gets a big front row seat
	var/payout = 0 // a baseline amount of cash you'll be given for fulfilling the requisition, modified by entries
	var/flavor_desc // optional flavor text for the contract
	var/requis_desc = "" // mandatory descriptive text for the contract contents, to be generated alongside them
	var/list/rc_entries = list() // list of requisition contact entries
	var/pinned = 0 // one contract at a time may be pinned, preventing it from rotating out with market shift

	New() //in individual definitions, create entries and THEN call this, it'll get things set up for you
		..()

		for(var/datum/rc_entry/rce in rc_entries)
			switch(rce.entryclass)
				if(RC_ITEMBYPATH)
					src.requis_desc += "[rce.count]x [rce.name][rce.isplural ? null : s_es(rce.count,rce.es)]<br>"
				if(RC_REAGENT)
					src.requis_desc += "[rce.count] or more unit[s_es(rce.count)] of [rce.name]<br>"
				if(RC_STACK)
					src.requis_desc += "[rce.count] or more [rce.name][rce.isplural ? null : s_es(rce.count,rce.es)]<br>"
			src.payout += rce.feemod * rce.count

	proc/requisify(obj/storage/crate/sell_crate)
		var/contents = list() //everything in crate
		var/contents_to_cull = list() //things consumed to fulfill the requisition, extras are sent back
		var/successes_needed = length(src.rc_entries) //decremented with each successful fulfillment, reach 0 to win

		contents += sell_crate.contents
		for(var/obj/item/storage/S in contents)
			contents |= S.get_all_contents()

		. = 0 //by default return no success
		for(var/datum/rc_entry/shoppin as anything in rc_entries)
			for(var/obj/O in contents)
				if(shoppin.rc_eval(O)) //found something that the requisition asked for, time to delet
					contents_to_cull |= O
		for(var/datum/rc_entry/shopped as anything in rc_entries)
			if(shopped.rollcount >= shopped.count)
				successes_needed--

		if(!successes_needed)
			if(src.pinned) shippingmarket.has_pinned_contract = 0
			. = 1 //sale, but may be leftover items
			for(var/obj/item/X in contents_to_cull)
				if(X) qdel(X)
				contents_to_cull -= X
			if(!length(sell_crate.contents)) //total clean sale, tell shipping manager to del the crate
				. = 2
		return



#undef RC_ITEMBYPATH
#undef RC_REAGENT
#undef RC_STACK

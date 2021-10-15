//quartermasters export requisition contracts
//adapted in small part from azrun's special order stuff
//this does not send its own crate so it's a lot more cut down

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

	proc/rc_eval(/obj/eval_item) //evaluation procedure, used in different entry classes
		if(rollcount >= count) return FALSE //if you've already got enough, skip and tell the manager as such

//items, by the path
ABSTRACT_TYPE(/datum/rc_entry/itembypath)
/datum/rc_entry/itembypath
	var/typepath = /obj/gibtyson //item that must be sold

	rc_eval(/obj/eval_item)
		..()
		. = FALSE
		if(eval_shoppin.type == typepath)
			src.rollcount++
			. = TRUE //let manager know something was found in passed eval item
		return

//reagents, by the unit
ABSTRACT_TYPE(/datum/rc_entry/reagent)
/datum/rc_entry/reagent
	var/chemname = "water" //chem being looked for in the evaluation

	rc_eval(/obj/eval_item)
		..()
		. = FALSE
		if(istype(eval_item,/obj/item/reagent_containers))
			var/obj/item/reagent_containers/C = eval_item
			rollcount += C.reagents.get_reagent_amount(chemname)
			. = TRUE //let manager know something was found in passed eval item
		return

//stackeroo, yet to do
//ABSTRACT_TYPE(/datum/rc_entry/stack)
//datum/rc_entry/stack

//contracts, which contain entries and are what are exposed to the qm side of things
ABSTRACT_TYPE(/datum/req_contract)
/datum/req_contract
	var/name = "Henry Whip a Zamboni" // title text that gets a big front row seat
	var/payout = 0 // a baseline amount of cash you'll be given for fulfilling the requisition, modified by entries
	var/flavor_desc // optional flavor text for the contract
	var/requis_desc = "" // mandatory descriptive text for the contract contents, to be generated alongside them
	var/list/rc_entries = list() //list of requisition contact entries

	New() //in individual definitions, create entries and THEN call this, it'll get things set up for you
		..()

		for(var/datum/rc_entry/rce in rc_entries)
			switch(rce.entryclass)
				if(RC_ITEMBYPATH)
					src.requis_desc += "[rce.count]x [rce.name][rce.isplural ? : s_es(rce.count,rce.es)]"
				if(RC_REAGENT)
					src.requis_desc += "[rce.count] unit[s_es(rce.count)] of [rce.name]"
				if(RC_STACK)
					src.requis_desc += "[rce.count] count of [rce.name]"
			src.payout += rce.feemod

	proc/requisify(obj/storage/crate/sell_crate)
		var/contents = list() //everything in crate
		var/contents_to_cull = list() //things consumed to fulfill the requisition, extras are sent back
		var/successes_needed = length(src.rc_entries) //decremented with each successful fulfillment, reach 0 to win

		contents += sell_crate.contents
		for(var/obj/item/storage/S in contents)
			contents |= S.get_all_contents()

		. = FALSE
		for(var/datum/rc_entry/shoppin as anything in rc_entries)
			for(var/obj/O in contents)
				if(shoppin.rc_eval(O)) //found something that the requisition asked for, time to delet
					contents_to_cull |= O
					contents -= O
		for(var/datum/rc_entry/shopped as anything in rc_entries)
			if(shopped.rollcount >= shopped.count)
				successes_needed--

		if(successes_needed)
			youcanhaveitback(sell_crate)
		else
			. = TRUE
			if(length(contents))
				for(var/obj/item/X in contents_to_cull)
					qdel(X)
					contents_to_cull -= X
				youcanhaveitback(sell_crate)
			else
				qdel(sell_crate)

	proc/youcanhaveitback(obj/storage/crate/sold_crate)
		if(sold_crate))
			shippingmarket.receive_crate(sold_crate)



#undef RC_ITEMBYPATH
#undef RC_ITEMBYFLAG
#undef RC_REAGENT

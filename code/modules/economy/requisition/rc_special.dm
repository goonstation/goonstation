ABSTRACT_TYPE(/datum/req_contract/special)
/**
 * Contracts for utilisation by the special order event.
 * These are distinguished by the requisition being sent physically, either standalone or in a crate with stuff.
 * They are not inspected by the requisitions handler, and do not receive the screwup protection that is afforded to regular contracts.
 * They do not appear in the general market.
 */
/datum/req_contract/special
	req_code = "REQ-THIRDPARTY"

	///Specify a crate to send the requisition in, if desired.
	var/obj/storage/crate/sendingCrate

	//Physical manifest of requested items. Its presence in the crate is required to send order back successfully. Automatically set up.
	var/obj/item/paper/req_sheet
	//These are contained in special_order.dm, along with the event that creates these contracts

	New()
		//in subtypes, add entries, then call back to this
		..()
		update_requisition(req_sheet)

	proc/update_requisition(obj/item/paper/req_sheet)
		if(ispath(req_sheet))
			req_sheet = new req_sheet
		req_sheet.info = replacetext(req_sheet.info, "%ITEMS%", src.get_shopping_list())
		req_sheet.info += "<BR/><BR/>Requisition Offer: <B>[payout]</B>"
		if(length(item_rewarders))
			req_sheet.info += get_rewards_list()
		req_sheet.info += "<BR/><BR/><font face='System' size='1'><span style='color:#666666;'><center>╔ REQHUB: THIRD PARTY REQUISITION ╗<br>TAG SENT CRATE WITH REQ_THIRDPARTY<br>╚ RETURNS AT DISCRETION OF CLIENT ╝</center></span>"

	///Formats src.rc_entries for being put onto paper.
	proc/get_shopping_list()
		. = "<ul>"
		for(var/datum/rc_entry/rce in src.rc_entries)
			if(rce.name)
				switch(rce.entryclass)
					if(1) //item by path
						. += "<li>[rce.count]x [rce.name]</li>"
					if(2) //reagent
						. += "<li>[rce.count]+ unit[s_es(rce.count)] of [rce.name]</li>"
					if(3) //item stacks
						. += "<li>[rce.count]+ [rce.name]</li>"
					else //something else entirely custom
						. += "<li>[rce.name]</li>"
		. += "</ul>"
		return

	///Formats the requisition's item rewarders for being put on paper.
	proc/get_rewards_list()
		. += "<br/><ul>"
		if(src.payout) . += "<li>[src.payout] credits</li>"
		for(var/datum/rc_itemreward/rwe in src.item_rewarders)
			if(rwe.name)
				. += "<li>[rwe.count] [rwe.name]</li>"
		. += "</ul>"
		return

	//proc stub. Override this with code for filling sendingCrate during event setup
	proc/pack_crate()
		return


ABSTRACT_TYPE(/datum/req_contract/special/surgery)
/datum/req_contract/special/surgery
	get_shopping_list()
		. = ""

/datum/req_contract/special/surgery/organ_swap
	name = "Organ Swap"
	weight = 50
	payout = 8000
	var/mob/living/carbon/human/target
	var/target_organs = list()
	sendingCrate = new /obj/storage/crate/wooden
	req_sheet = new /obj/item/paper/requisition/surgery/organ_swap

	New()
		var/possible_targets = list("brain", "left_eye", "right_eye", "heart", "left_lung", "right_lung", "butt", "left_kidney", "right_kidney", "liver", "stomach", "intestines", "spleen", "pancreas", "appendix")
		for(var/i in 1 to rand(3,6))
			target_organs |= pick(possible_targets)
		var/datum/rc_entry/organ_swap/paired_entry = new /datum/rc_entry/organ_swap
		paired_entry.home = src
		src.rc_entries += paired_entry
		src.item_rewarders += new /datum/rc_itemreward/bootlegmed
		..()

	pack_crate()
		//Make Mob
		src.target = new /mob/living/carbon/human/npc/assistant
		randomize_look(target, 1, 1, 1, 1, 1, 0)
		//Let people have time to figure out what is going on before he starts fucking shit up
		src.target.reagents.add_reagent("capulettium_plus", rand(15,30) ) // 5 minutes to 8.3 minutes (AI will disrupt it before then but creates the illusion)
		src.target.reagents.add_reagent("ether", rand(25, 60) ) //
		var/datum/reagent/capulettium_plus/R = target.reagents.get_reagent("capulettium_plus")
		R.counter = 20
		var/datum/reagent/capulettium_plus/E = target.reagents.get_reagent("ether")
		E.counter = 36
		src.target.ai_lastaction = TIME + 2 MINUTES
		src.target.set_loc(sendingCrate)
		//Organ Damage Ensues. Send The Invoice To God
		src.target.TakeDamage("All", rand(10, 20), rand(10, 20))
		src.target.organHolder.damage_organs(1, 6, 10, target_organs)

		SPAWN(0.5 SECOND) // Delay for JobEquipSpawned to resolve
			for(var/slot in list(SLOT_EARS, SLOT_WEAR_ID, SLOT_BACK, SLOT_BELT))
				var/obj/O = src.target.get_slot(slot)
				if(O)
					src.target.u_equip(O)
					qdel(O)

		src.req_sheet.set_loc(sendingCrate)

/datum/rc_entry/organ_swap
	name = "organ replacement"
	var/datum/req_contract/special/surgery/organ_swap/home

	rc_eval(atom/eval_item)
		..()
		if(!home)
			return
		if(eval_item == home.target)
			for(var/organ in home.target_organs)
				var/obj/item/organ/O = home.target.organHolder.get_organ(organ)
				//Check if organ was not replaced or if it was originally from target...
				if(!O || (O.donor_original==home.target && O.donor_name))
					// Well shit bye bye... target
					return FALSE
			src.rollcount++
			return TRUE

/datum/rc_itemreward/bootlegmed
	name = "medical restock cartridges"

	build_reward()
		var/list/carts = list()
		for(var/i in 1 to 3) carts += new /obj/item/vending/restock_cartridge/medical
		carts += new /obj/item/vending/restock_cartridge/portamed
		return carts



/datum/req_contract/special/weed_sampler
	name = "Weed Flight"
	req_sheet = new /obj/item/paper/requisition/weed_sample
	payout = 41714

	New()
		src.rc_entries += rc_buildentry(/datum/rc_entry/item/megaweed,1)
		src.rc_entries += rc_buildentry(/datum/rc_entry/item/whiteweed,1)
		src.rc_entries += rc_buildentry(/datum/rc_entry/item/omegaweed,1)
		src.rc_entries += rc_buildentry(/datum/rc_entry/stack/pizza/spacer,6)
		..()

/datum/rc_entry/item
	megaweed
		name = "Rainbow Weed"
		typepath = /obj/item/plant/herb/cannabis/mega
	whiteweed
		name = "White Weed"
		typepath = /obj/item/plant/herb/cannabis/white
	omegaweed
		name = "Omega Weed"
		typepath = /obj/item/plant/herb/cannabis/omega

/datum/rc_entry/stack/pizza/spacer
	name = "Pizza Hexa-Subsections (May Be Unseparated)"



/datum/req_contract/special/pizza_party
	name = "Pizza Party"
	req_sheet = new /obj/item/paper/requisition/pizza_party
	payout = 2500 //pizza adds from 2400 to 3600

	nt
		name = "Pizza Party (NanoTrasen)"
		req_sheet = new /obj/item/paper/requisition/pizza_party/nt
		payout = 3300

	New()
		src.rc_entries += rc_buildentry(/datum/rc_entry/stack/pizza,rand(20,30)*6)
		..()



ABSTRACT_TYPE(/datum/req_contract/special/chef)
/datum/req_contract/special/chef
	weight = 50
	payout = 12000
	req_sheet = new /obj/item/paper/requisition/food_order
	var/mealflag = MEAL_TIME_BREAKFAST
	var/list/cornucopia = list()
	var/list/name_of_food = list()

	breakfast_order
		name = "Breakfast Order"
		mealflag = MEAL_TIME_BREAKFAST
		New()
			src.build_foodlist()
			for(var/i in 1 to rand(3,6))
				var/datum/rc_entry/item/nom = new /datum/rc_entry/item
				nom.typepath = pick(src.cornucopia)
				nom.name = src.name_of_food[nom.typepath]
				nom.count = pick(60; 1, 30; 2, 10; 3)
				src.rc_entries += nom
			..()

	lunch_order
		name = "Lunch Order"
		mealflag = MEAL_TIME_LUNCH
		New()
			src.build_foodlist()
			for(var/i in 1 to rand(3,6))
				var/datum/rc_entry/item/nom = new /datum/rc_entry/item
				nom.typepath = pick(src.cornucopia)
				nom.name = src.name_of_food[nom.typepath]
				nom.count = pick(60; 1, 40; 2)
				src.rc_entries += nom
			..()

	dinner_order
		name = "Dinner Order"
		mealflag = MEAL_TIME_DINNER
		New()
			src.build_foodlist()
			for(var/i in 1 to rand(3,6))
				var/datum/rc_entry/item/nom = new /datum/rc_entry/item
				nom.typepath = pick(src.cornucopia)
				nom.name = src.name_of_food[nom.typepath]
				nom.count = pick(60; 1, 40; 2)
				src.rc_entries += nom
			..()

	snack_order
		name = "Snack Order"
		mealflag = MEAL_TIME_SNACK
		New()
			src.build_foodlist()
			for(var/i in 1 to rand(3,6))
				var/datum/rc_entry/item/nom = new /datum/rc_entry/item
				nom.typepath = pick(src.cornucopia)
				nom.name = src.name_of_food[nom.typepath]
				nom.count = pick(40; 1, 40; 2, 20; 3)
				src.rc_entries += nom
			..()

	proc/build_foodlist()
		for(var/food_type in concrete_typesof(/obj/item/reagent_containers/food/snacks))
			var/obj/item/reagent_containers/food/snacks/F = food_type
			if(initial(F.meal_time_flags) & src.mealflag)
				src.cornucopia += food_type
				src.name_of_food[food_type] = initial(F.name)



/datum/req_contract/special/blood
	name = "Blood Request"
	req_sheet = new /obj/item/paper/requisition/blood
	payout = 0 //price in blood

	New()
		src.rc_entries += rc_buildentry(/datum/rc_entry/reagent/blood,rand(8,12)*100)
		..()

/datum/rc_entry/reagent/blood
	name = "blood"
	chem_ids = "blood"
	feemod = 10

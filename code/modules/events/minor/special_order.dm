
/datum/random_event/minor/special_order
	name = "Special Order"
	customization_available = TRUE
	var/list/special_order_weights

	admin_call(var/source)
		if (..())
			return
		var/list/option_list = list()
		for(var/type in concrete_typesof(/datum/req_contract/special))
			var/datum/req_contract/special/O = type
			option_list[initial(O.name)] = type
		var/selection = tgui_input_list(usr,"Which special order?", "Special Order Menu", option_list)
		if(selection)
			src.event_effect(option_list[selection])

	event_effect(datum/req_contract/special/order_type)
		..()
		// build list of possible orders

		// pick one at random or by weight
		if(!ispath(order_type))
			if(!special_order_weights)
				special_order_weights = list()
				for(var/type in concrete_typesof(/datum/req_contract/special))
					var/datum/req_contract/O = type
					special_order_weights[type] = initial(O.weight)
			order_type = weighted_pick(special_order_weights)
		var/datum/req_contract/special/new_order = new order_type
		LAZYLISTADD(shippingmarket.special_orders, new_order)

		if(new_order.sendingCrate)
			new_order.pack_crate()
			shippingmarket.receive_crate(new_order.sendingCrate)
		else
			shippingmarket.receive_crate(new_order.req_sheet)

/obj/item/paper/requisition
	name = "Order Requisition"

/obj/item/paper/requisition/weed_sample
	info = {"Hellos, we the people of <B>\[REDACTED\]</B> would like to partake in what appears to be a human past time.  A sampling of your fine flora!<BR>
	%ITEMS%
	Love and solutions,<BR/>
	%TARGET%"}

	New()
		..()
		info = replacetext(info, "%TARGET%", pick("X̶e̸e̶ ̵P̶'̸X'", "TOM", "Smith Smithington", "Mx. Grey"))
		src.stamp(rand(50,160), rand(50,90), rand(-20,20), "stamp-gtc.png", "stamp-syndicate")

/obj/item/paper/requisition/pizza_party
	info = {"We have quite the situation where all our pizza ovens are having a fit.  We a number of orders to fill and could really use your help, my manager said by any means necessary!  We have quotas to meet! We have <i>guarantee</i> to uphold!<BR>
	%ITEMS%
	Thanks this could really save the day,<BR/>
	%TARGET%"}

	New()
		..()
		var/target_name = ""
		if(prob(50))
			target_name += pick_string_autokey("names/first_female.txt")
		else
			target_name = pick_string_autokey("names/first_male.txt")
		target_name += " [pick_string_autokey("names/last.txt")]"
		info = replacetext(info, "%TARGET%", target_name)
		if(src.type == /obj/item/paper/requisition/pizza_party)
			src.stamp(rand(50,160), rand(50,90), rand(-20,20), "stamp-gtc.png", "stamp-syndicate")

	nt
		info = {"TO: Space Station 13<BR/>
		FROM: CentComm<BR/>
		<BR/><p>We are in quite the pickle.  Someone said we would coordinate a pizza party to celebrate employee of the month for %BDAY% but all our typical suppliers say they are <i>unavailable</i> and may not arrive in the estimated lifetime of the employee in question.  This should greatly improve the morale of a nearby outpost!</p><BR>
		%ITEMS%
		Don't let a fellow employee down!<BR/>
		%TARGET%"}
		New()
			..()
			var/target_name = ""
			if(prob(50))
				target_name += pick_string_autokey("names/first_female.txt")
			else
				target_name = pick_string_autokey("names/first_male.txt")
			target_name += " [pick_string_autokey("names/last.txt")]"
			info = replacetext(info, "%BDAY%", target_name)
			src.stamp(rand(130,180), rand(160,190), rand(-40,40), "stamp-req-nt.png", "stamp-centcom")


/obj/item/paper/requisition/blood
	info = {"<BR/><BR/><BR/>
	<p>Blood. Blood. Blood. Blood. Blood. Blood. Blood. Blood. Blood. Blood.</p>
	<BR/><BR/>
	%ITEMS%
	<BR/>"}

	New()
		..()
		if(prob(2))
			if(prob(50))
				info += "Alucard"
			else
				info += "V. D."
		src.stamp(rand(50,160), rand(50,90), rand(-60,-20), "stamp-gtc.png", "stamp-syndicate")
		src.stamp(rand(50,160), rand(190,290), rand(-40,40), "stamp-gtc.png", "stamp-syndicate")
		src.stamp(rand(120,260), rand(50,390), rand(20,60), "stamp-gtc.png", "stamp-syndicate")

/obj/item/paper/requisition/surgery/organ_swap
	info = {"TO: Space Station 13<BR/>
	FROM: Outpost \[REDACTED\]<BR/>
	<h3>Cadaver Surgery Exercise 32-21-A</h3>
	<BR/><p>Replace all internal organs of the individual co-located with these instructions.</p><BR/>
	<BR/><p>Removed organs are to be destroyed.</p><BR/>
	<BR/><p>Return individual once complete for evaluation.</p><BR/>
	<BR/><BR/>
	<i>All information included or obtained regarding the individual should be ignored and are all part of the training exercise.</i>"}
	New()
		..()
		src.stamp(rand(90,160), rand(120,160), rand(-20,20), "stamp-classified.png", "stamp-syndicate")


/obj/item/paper/requisition/food_order
	info = {"TO: Space Station 13<BR/>
	FROM: %FOOD_COMPANY%<BR/>
	<h3>Food Order:</h3>
	%ITEMS%
	"}
	var/static/list/company = list("SpaceHub Delivery Services", "SnackAttack - Hunger Destroyer", "FoodDirect", "CelestialEats Delivery", "Technically Fresh")
	New()
		..()

		info = replacetext(info, "%FOOD_COMPANY%", pick(company))
		src.stamp(rand(90,260), rand(150,390), rand(-20,20), "stamp-gtc.png", "stamp-syndicate")

//non-integrated special order system

/*
/datum/commodity/proc/item_check(var/obj)
		return TRUE

/datum/special_order
	///name of the order - used for manually calling event
	var/name
	///list of items needed to fill order - not used when check_order is overridden
	var/list/datum/commodity/order_items
	///specify a crate to be sent - pack_crate proc generally to fill it
	var/obj/storage/crate/sendingCrate
	///piece of paper (subtypes) with order info etc
	var/obj/item/paper/requisition
	///bonus rewards shipped when order is filled
	var/list/atom/movable/rewards
	///credit value for filling the order
	var/price
	///weighting for event pick
	var/weight = 100

	New()
		..()
		var/list/datum/commodity/shopping_list = list()
		update_requisition(requisition)
		for(var/i in 1 to length(order_items))
			if(ispath(order_items[i]))
				var/path = order_items[i]
				for(var/j in 1 to max(1,order_items[order_items[i]]))
					shopping_list += new path
			else
				shopping_list += order_items[i]
		order_items = shopping_list

	///check if order is filled by a given crate
	proc/check_order(obj/storage/crate/sell_crate)
		var/contents = list()
		contents += sell_crate.contents
		for(var/obj/item/storage/S in contents)
			contents |= S.get_all_contents()

		. = TRUE
		for(var/datum/commodity/item as anything in order_items)
			var/found = null
			for(var/obj/O in contents)
				if( ( item.subtype_valid && istype(O, item.comtype)  )  \
				 || (!item.subtype_valid && (O.type == item.comtype) ) )
					if(item.item_check(O))
						found = O
						contents -= O
						break
			if(!found)
				return FALSE

	///updates requisition paper with shopping list, and appends the price reward for the order
	proc/update_requisition(obj/item/paper/requisition)
		if(ispath(requisition))
			requisition = new requisition
		requisition.info = replacetext(requisition.info, "%ITEMS%", src.get_shopping_list())
		requisition.info += "<BR/><BR/>Requisition Offer: <B>[price]</B>"
		if(length(rewards))
			requisition.info += get_rewards_list()

	///formats src.order_items for being put onto paper
	proc/get_shopping_list()
		. = "<ul>"
		for(var/datum/commodity/C as anything in src.order_items)
			if(src.order_items[C])
				. += "<li>([src.order_items[C]]) [capitalize(initial(C.comname))]</li>"
			else
				. += "<li>[capitalize(initial(C.comname))]</li>"
		. += "</ul>"

	///formats src.rewards for being put on paper
	proc/get_rewards_list()
		. += "<br/><ul>"
		for(var/atom/movable/AM as anything in rewards)
			if(src.rewards[AM])
				. += "<li>[src.rewards[AM]]x [capitalize(initial(AM.name))]</li>"
			else
				. += "<li>[capitalize(initial(AM.name))]</li>"
		. += "</ul>"

	///proc stub. Override this with code for filling sendingCrate during event setup
	proc/pack_crate()
		return

	///if we have item rewards to send upon order fulfillment, shove them in a crate and ship it off to cargo
	proc/send_rewards()
		if(length(rewards))
			var/obj/storage/crate/C = new
			for(var/type in rewards)
				new type(C)
			shippingmarket.receive_crate(C)

ABSTRACT_TYPE(/datum/special_order/reagents)
/datum/special_order/reagents
	var/list/reagents_list

	check_order(obj/storage/crate/sell_crate)
		var/reagents_count = reagents_list?.Copy()
		var/contents = list()
		contents += sell_crate.contents
		for(var/obj/item/storage/S in contents)
			contents |= S.get_all_contents()
		for(var/obj/item/reagent_containers/C in contents)
			for(var/I in reagents_count)
				reagents_count[I] -= C.reagents.get_reagent_amount(I)
		for(var/I in reagents_count)
			if(reagents_count[I] > 0)
				return FALSE
		return TRUE

	get_shopping_list()
		. = "<ul>"
		for(var/R in reagents_list)
			if(src.reagents_list[R])
				. += "<li>([src.reagents_list[R]]u) [R]</li>"
		. += "</ul>"

ABSTRACT_TYPE(/datum/special_order/surgery)
/datum/special_order/surgery
	get_shopping_list()
		. = ""

/datum/commodity/special_order/pizza
	comname = "Pizza"
	comtype = /obj/item/reagent_containers/food/snacks/pizza
	subtype_valid = TRUE

	item_check(obj/item/reagent_containers/food/snacks/pizza/P)
		return(!P.sliced)

/datum/special_order/weed_sampler
	name = "Weed Flight"
	order_items = list(/datum/commodity/trader/buford/megaweed=1, /datum/commodity/trader/buford/whiteweed=1, /datum/commodity/trader/buford/omegaweed=1, /datum/commodity/special_order/pizza=1)
	requisition = new /obj/item/paper/requisition/weed_sample
	price = 41834

/datum/special_order/pizza_party
	name = "Pizza Party"
	order_items = list(/datum/commodity/special_order/pizza=20)
	requisition = new /obj/item/paper/requisition/pizza_party
	price = 5000

	nt
		name = "Pizza Party (NanoTrasen)"
		requisition = new /obj/item/paper/requisition/pizza_party/nt
		price = 6000

ABSTRACT_TYPE(/datum/special_order/chef)
/datum/special_order/chef
	weight = 50
	price = 2000
	requisition = new /obj/item/paper/requisition/food_order
	var/list/food_order = list()
	var/static/list/breakfast
	var/static/list/lunch
	var/static/list/dinner
	var/static/list/snacks

	check_order(obj/storage/crate/sell_crate)
		var/contents = list()
		var/food_count = food_order?.Copy()
		contents += sell_crate.contents
		for(var/obj/item/storage/S in contents)
			contents |= S.get_all_contents()

		. = TRUE

		for(var/obj/item/reagent_containers/F in contents)
			for(var/I in food_count)
				if(F.type == I)
					food_count[I] -= max(1, F.amount)
		for(var/I in food_count)
			if(food_count[I] > 0)
				return FALSE
		return TRUE

	get_shopping_list()
		. = "<ul>"
		for(var/f_type in src.food_order)
			var/obj/item/reagent_containers/F = f_type
			if(src.food_order[f_type])
				. += "<li>([src.food_order[f_type]]) [initial(F.name)]</li>"
			else
				. += "<li>[initial(F.name)]</li>"
		. += "</ul>"

	breakfast_order
		name = "Breakfast Order"

		New()
			if(!breakfast)
				breakfast = list()
				for(var/food_type in concrete_typesof(/obj/item/reagent_containers/food/snacks))
					var/obj/item/reagent_containers/food/snacks/F = food_type
					if(initial(F.meal_time_flags) & MEAL_TIME_BREAKFAST)
						breakfast += food_type
			for(var/i in 1 to rand(3,6))
				src.food_order[pick(breakfast)] = pick(60; 1, 30; 2, 10; 3)
			..()

	lunch_order
		name = "Lunch Order"

		New()
			if(!lunch)
				lunch = list()
				for(var/food_type in concrete_typesof(/obj/item/reagent_containers/food/snacks))
					var/obj/item/reagent_containers/food/snacks/F = food_type
					if(initial(F.meal_time_flags) & MEAL_TIME_LUNCH)
						lunch += food_type
			for(var/i in 1 to rand(3,6))
				src.food_order[pick(lunch)] = pick(60; 1, 30; 2)
			..()

	dinner_order
		name = "Dinner Order"

		New()
			if(!dinner)
				dinner = list()
				for(var/food_type in concrete_typesof(/obj/item/reagent_containers/food/snacks))
					var/obj/item/reagent_containers/food/snacks/F = food_type
					if(initial(F.meal_time_flags) & MEAL_TIME_DINNER)
						dinner += food_type
			for(var/i in 1 to rand(3,6))
				src.food_order[pick(dinner)] = pick(60; 1, 30; 2)
			..()

	snack_order
		name = "Snack Order"

		New()
			if(!snacks)
				snacks = list()
				for(var/food_type in concrete_typesof(/obj/item/reagent_containers/food/snacks))
					var/obj/item/reagent_containers/food/snacks/F = food_type
					if(initial(F.meal_time_flags) & MEAL_TIME_SNACK)
						snacks += food_type
			for(var/i in 1 to rand(3,6))
				src.food_order[pick(snacks)] = pick(40; 1, 40; 2, 20; 3)
			..()

/datum/special_order/reagents/blood
	name = "Blood Request"
	requisition = new /obj/item/paper/requisition/blood
	price = 9000
	reagents_list = list("blood"=1000)

/datum/special_order/surgery/organ_swap
	name = "Organ Swap"
	weight = 50
	price = 5000
	sendingCrate = new /obj/storage/crate/wooden
	requisition = new /obj/item/paper/requisition/surgery/organ_swap
	var/mob/living/carbon/human/target
	var/target_organs = list()
	rewards = list(/obj/item/vending/restock_cartridge/medical = 3, /obj/item/vending/restock_cartridge/portamed = 1)

	New()
		..()
		var/possible_targets = list("brain", "left_eye", "right_eye", "heart", "left_lung", "right_lung", "butt", "left_kidney", "right_kidney", "liver", "stomach", "intestines", "spleen", "pancreas", "appendix")
		for(var/i in 1 to rand(3,6))
			target_organs |= pick(possible_targets)

	pack_crate()
		//Make Mob
		target = new /mob/living/carbon/human/npc/assistant
		randomize_look(target, 1, 1, 1, 1, 1, 0)
		//Let people have time to figure out what is going on before he starts fucking shit up
		target.reagents.add_reagent("capulettium_plus", rand(15,30) ) // 5 minutes to 8.3 minutes (AI will fuck it before then but creates the illusion)
		target.reagents.add_reagent("ether", rand(25, 60) ) //
		var/datum/reagent/capulettium_plus/R = target.reagents.get_reagent("capulettium_plus")
		R.counter = 20
		var/datum/reagent/capulettium_plus/E = target.reagents.get_reagent("ether")
		E.counter = 36
		target.ai_lastaction = TIME + 2 MINUTES
		target.set_loc(sendingCrate)
		//Fuck up Organs
		target.TakeDamage("All", rand(10, 20), rand(10, 20))
		target.organHolder.damage_organs(1, 6, 10, target_organs)

		SPAWN(0.5 SECOND) // Delay for JobEquipSpawned to resolve
			for(var/slot in list(SLOT_EARS, SLOT_WEAR_ID, SLOT_BACK, SLOT_BELT))
				var/obj/O = target.get_slot(slot)
				if(O)
					target.u_equip(O)
					qdel(O)

		requisition.set_loc(sendingCrate)

	check_order(obj/storage/crate/sell_crate)
		if(target in sell_crate)
			for(var/organ in target_organs)
				var/obj/item/organ/O = target.organHolder.get_organ(organ)
				//Check if organ was not replaced or if it was originally from target...
				if(!O || (O.donor_original==target && O.donor_name))
					// Well shit bye bye... target
					shippingmarket.active_orders -= src
					return FALSE
		return TRUE
*/

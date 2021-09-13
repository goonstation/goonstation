
/datum/random_event/minor/special_order
	name = "Special Order"
	var/list/special_order_weights

	event_effect()
		..()
		// build list of possible orders

		// pick one at random or by weight
		if(!special_order_weights)
			special_order_weights = list()
			for(var/type in concrete_typesof(/datum/special_order))
				var/datum/special_order/O = type
				special_order_weights[type] = initial(O.weight)
		var/order_type = weighted_pick(special_order_weights)
		var/datum/special_order/new_order = new order_type
		LAZYLISTADD(shippingmarket.active_orders, new_order)

		shippingmarket.receive_crate(new_order.requisition)

/datum/commodity/proc/item_check(var/obj)
		return TRUE

/datum/special_order
	var/name
	var/list/datum/commodity/order_items
	var/obj/storage/crate/C
	var/obj/item/paper/requisition
	var/list/stamps
	var/price
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

	proc/update_requisition(obj/item/paper/requisition)
		if(ispath(requisition))
			requisition = new requisition
		requisition.info = replacetext(requisition.info, "%ITEMS%", src.get_shopping_list())
		requisition.info += "<BR/><BR/>Requisition Offer: <B>[price]</B>"

	proc/get_shopping_list()
		. = "<ul>"
		for(var/datum/commodity/C as anything in src.order_items)
			if(src.order_items[C])
				. += "<li>([src.order_items[C]]) [initial(C.comname)]</li>"
			else
				. += "<li>[initial(C.comname)]</li>"
		. += "</ul>"

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

/datum/commodity/special_order/pizza
	comname = "Pizza"
	comtype = /obj/item/reagent_containers/food/snacks/pizza
	subtype_valid = TRUE

/datum/commodity/special_order/megaweed
	comname = "Rainbow Weed"
	comtype = /obj/item/plant/herb/cannabis/mega

/datum/commodity/special_order/whiteweed
	comname = "White Weed"
	comtype = /obj/item/plant/herb/cannabis/white

/datum/commodity/special_order/omegaweed
	comname = "Omega Weed"
	comtype = /obj/item/plant/herb/cannabis/omega

/datum/special_order/weed_sampler
	name = "Weed Flight"
	order_items = list(/datum/commodity/special_order/megaweed=1, /datum/commodity/special_order/whiteweed=1, /datum/commodity/special_order/omegaweed=1, /datum/commodity/special_order/pizza=1)
	requisition = new /obj/item/paper/requisition/weed_sample
	price = 41834

/datum/special_order/pizza_party
	name = "Pizza Party"
	order_items = list(/datum/commodity/special_order/pizza=20)
	requisition = new /obj/item/paper/requisition/pizza_party
	price = 5000

	nt
		requisition = new /obj/item/paper/requisition/pizza_party/nt
		price = 6000


/datum/special_order/reagents/blood
	name = "Blood Request"
	requisition = new /obj/item/paper/requisition/blood
	price = 9000
	reagents_list = list("blood"=1000)



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
		info = {"TO:Space Station 13<BR/>
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


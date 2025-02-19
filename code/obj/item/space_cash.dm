/obj/item/currency
	name = "1 coin"
	real_name = "coins"
	desc = "Coins for the coin god. You shouldn't be seeing this."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "coin"
	opacity = 0
	density = 0
	anchored = UNANCHORED
	force = 1
	throwforce = 1
	throw_speed = 1
	throw_range = 8
	w_class = W_CLASS_TINY
	burn_point = 400
	burn_possible = TRUE
	burn_output = 750
	amount = 1
	max_stack = 1000000
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 1
	inventory_counter_enabled = 1
	var/display_name = "currency"
	var/default_min_amount = 0
	var/default_max_amount = 0

	New(var/atom/loc, var/amt = 1 as num)
		var/default_amount = default_min_amount == default_max_amount ? default_min_amount : rand(default_min_amount, default_max_amount)
		src.amount = max(amt,default_amount) //take higher
		..(loc)
		src.UpdateStackAppearance()

	proc/set_amt(amt = 1)
		var/default_amount = rand(default_min_amount, default_max_amount)
		src.amount = max(amt,default_amount)
		src.UpdateStackAppearance()

	proc/setup(var/atom/L, var/amt = 1 as num, try_add_to_storage = FALSE)
		if (!try_add_to_storage)
			set_loc(L)
		else
			if (L.storage)
				L.storage.add_contents(src)
			else
				src.set_loc(L)
		set_amt(amt)

	UpdateName()
		src.name = "[src.amount == src.max_stack ? "1000000" : src.amount] [name_prefix(null, 1)][src.real_name][s_es(src.amount)][name_suffix(null, 1)]"

	before_stack(atom/movable/O as obj, mob/user as mob)
		user.visible_message(SPAN_NOTICE("[user] is stacking [display_name]!"))

	after_stack(atom/movable/O as obj, mob/user as mob, var/added)
		boutput(user, SPAN_NOTICE("You finish stacking [display_name]."))

	failed_stack(atom/movable/O as obj, mob/user as mob, var/added)
		boutput(user, SPAN_ALERT("You need another stack!"))

	attackby(var/obj/item/I, mob/user)
		if (istype(I, /obj/item/currency) && src.amount < src.max_stack)

			user.visible_message(SPAN_NOTICE("[user] stacks some [display_name]."))
			stack_item(I)
		else
			..(I, user)

	attack_hand(mob/user)
		if ((user.l_hand == src || user.r_hand == src) && user.equipped() != src)
			var/amt = round(input("How much [display_name] do you want to take from the stack?") as null|num)
			if (isnum_safe(amt) && src.loc == user && !user.equipped())
				if (amt > src.amount || amt < 1)
					boutput(user, SPAN_ALERT("You wish!"))
					return
				var/young_money = split_stack(amt)
				user.put_in_hand_or_drop(young_money)
		else
			..(user)

	onMaterialChanged()
		. = ..()
		if(src.amount > 1)
			src.visible_message("[src] melds together into a single item. What?")
			src.desc += " It looks all melted together or something."
			src.change_stack_amount(-(src.amount-1))
			UpdateStackAppearance()

/obj/item/currency/spacecash
	name = "1 credit"
	real_name = "credit"
	desc = "You gotta have money."
	icon_state = "cashgreen"
	stack_type = /obj/item/currency/spacecash // so all cash types can stack with each other
	display_name = "cash"

	HYPsetup_DNA(var/datum/plantgenes/passed_genes, var/obj/machinery/plantpot/harvested_plantpot, var/datum/plant/origin_plant, var/quality_status)
		src.amount = max(1, passed_genes?.get_effective_value("potency") * rand(2,4))
		src.UpdateStackAppearance()
		return src

	stack_item(obj/item/I)
		if (istype(I,/obj/item/currency/spacecash))
			if (src.hasStatus("freshly_laundered") || I.hasStatus("freshly_laundered"))
				if (!(src.hasStatus("freshly_laundered") && I.hasStatus("freshly_laundered")))
					if (ismob(src.loc))
						boutput(src.loc, "Ew, this other cash is FILTHY. It's ruined the whole stack!")
					I.delStatus("freshly_laundered")
					src.delStatus("freshly_laundered")
		..()

	get_desc()
		if (src.hasStatus("freshly_laundered"))
			. += "It feels warm and soft."

	_update_stack_appearance()
		src.UpdateName()
		src.inventory_counter.update_number(src.amount)
		switch (src.amount)
			if (-INFINITY to 9)
				src.icon_state = "cashgreen"
			if (10 to 49)
				src.icon_state = "cashblue"
			if (50 to 499)
				src.icon_state = "cashindi"
			if (500 to 999)
				src.icon_state = "cashpurp"
			if (1000 to 999999)
				src.icon_state = "cashred"
			else // 1mil bby
				src.icon_state = "cashrbow"

	five
		default_min_amount = 5
		default_max_amount = 5

	ten
		default_min_amount = 10
		default_max_amount = 10

	twenty
		default_min_amount = 20
		default_max_amount = 20

	fifty
		default_min_amount = 50
		default_max_amount = 50

	hundred
		default_min_amount = 100
		default_max_amount = 100

	fivehundred
		default_min_amount = 500
		default_max_amount = 500

	thousand
		default_min_amount = 1000
		default_max_amount = 1000
	twothousandfivehundred
		default_min_amount = 2500
		default_max_amount = 2500
	hundredthousand
		default_min_amount = 100000
		default_max_amount = 100000

	million
		default_min_amount = 1000000
		default_max_amount = 1000000

	random
		default_min_amount = 1
		default_max_amount = 1000000

// That's what tourists spawn with.
	tourist
		default_min_amount = PAY_TRADESMAN
		default_max_amount = PAY_EXECUTIVE

// for couches
	small
		default_min_amount = 1
		default_max_amount = 500

	really_small
		default_min_amount = 1
		default_max_amount = 50

	bag // hufflaw cashbags
		New(var/atom/loc)
			..(loc)
			amount = rand(1,10000)
			name = "money bag"
			desc = "Loadsamoney!"
			icon = 'icons/obj/items/items.dmi'
			icon_state = "moneybag"
			item_state = "moneybag"
			inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'

/obj/item/currency/buttcoin
	name = "buttcoin"
	real_name = "credit"
	desc = "The crypto-currency of the future (If you don't pay for your own electricity and got in early and don't lose the file and don't want transactions to be faster than half an hour and . . .)"
	icon_state = "buttcoin"
	stack_type = /obj/item/currency/buttcoin
	display_name = "cash"

	New()
		..()
		processing_items |= src

	_update_stack_appearance()
		return

	UpdateName()
		src.name = "[src.amount] [name_prefix(null, 1)][pick("bit","butt","shitty-bill ","bart", "bat", "bet", "bot")]coin[s_es(src.amount)][name_suffix(null, 1)]"

	process()
		src.amount = rand(1, 1000) / rand(10, 1000)
		if (prob(25))
			src.amount *= (rand(1,100)/100)
		if (prob(5))
			src.amount *= 10000

		src.UpdateName()

	attack_hand(mob/user)
		if ((user.l_hand == src || user.r_hand == src) && user.equipped() != src)
			var/amt = round(input("How much cash do you want to take from the stack?") as null|num)
			if (isnum_safe(amt))
				if (amt > src.amount || amt < 1)
					boutput(user, SPAN_ALERT("You wish!"))
					return

				boutput(user, "Your transaction will complete anywhere within 10 to 10e27 minutes from now.")
		else
			..()

	attackby(var/obj/item/I, mob/user)
		if (istype(I, /obj/item/currency/buttcoin) && src.amount < src.max_stack)
			boutput(user, "Your transaction will complete anywhere within 10 to 10e27 minutes from now.")
		else
			..(I, user)

	disposing()
		processing_items.Remove(src)
		..()

/obj/item/currency/spacebux // Not space cash. Actual spacebux. Wow.
	name = "\improper Spacebux token"
	icon_state = "spacebux_gray"
	desc = "A Spacebux token, neat! You can insert this into an ATM to add it to your account."
	amount = 0
	var/spent = 0
	stack_type = /obj/item/currency/spacebux
	display_name = "spacebux"

	New(var/atom/loc, var/amt = null)
		..(loc)
		if (amt != null)
			src.amount = amt

		src.UpdateStackAppearance()

	get_desc()
		. += "This one is worth [amount >= 1000000 ? "ONE FUCKING GOD DAMN MILLION" : amount] spacebux."

	setup(atom/L, amt = 1)
		set_loc(L)
		set_amt(amt)

	set_amt(amt = 1)
		tooltip_rebuild = 1
		src.amount = amt
		src.UpdateStackAppearance()

	_update_stack_appearance()
		src.UpdateName()
		src.inventory_counter?.update_number(amount)
		animate(src, transform = null, time = 1, easing = SINE_EASING, flags = ANIMATION_END_NOW)
		switch (src.amount)
			if (1000000 to INFINITY)
				animate_spin(src, "L", 1, -1)
				animate_rainbow_glow(src)
				src.color = null	// god DAMN
			if (250000 to INFINITY)
				src.color = null	// jesus fuckin christ
				animate_rainbow_glow(src)
			if (50000 to 250000)
				src.color = "#e5e4e2"	// platinum-ish
			if (10000 to 50000)
				src.color = "#ffd700"	// gold
			if (1000 to 10000)
				src.color = "#b0b0b0"	// silver
			if (-INFINITY to 1000)
				src.color = "#cd7f32"	// bronze

		src.sparkle(src.amount >= 10000)


	proc/sparkle(var/enable = 1)
		if (enable)
			if (!particleMaster.CheckSystemExists(/datum/particleSystem/sparkles, src))
				particleMaster.SpawnSystem(new /datum/particleSystem/sparkles(src))
		else
			if (particleMaster.CheckSystemExists(/datum/particleSystem/sparkles, src))
				particleMaster.RemoveSystem(/datum/particleSystem/sparkles, src)


	UpdateName()
		if (src.amount >= 1000000)
			src.name = "\proper ONE MILLION SPACEBUX!!! HOLY SHIT!!!"
			src.desc = "what the fuck are you <strong>DOING</strong> stop reading this stupid description and <em>slam this shit into the nearest ATM!</em>"
		else
			src.name = "\improper [src.amount] [initial(src.name)]"
			src.desc = initial(src.desc)

	attackby(var/obj/item/I, mob/user)
		if (istype(I, /obj/item/currency/spacebux) && src.spent == 0)
			user.visible_message(SPAN_NOTICE("[user] stacks some spacebux."))
			stack_item(I)
		else
			..(I, user)

	check_valid_stack(atom/movable/O as obj)
		if (istype(O, /obj/item/currency/spacebux))
			// Immediately fail if it's been spent already
			var/obj/item/currency/spacebux/SB = O
			if (src.spent || SB.spent)
				return 0
		return ..()

	ten
		default_min_amount = 10
		default_max_amount = 10

	fifty
		default_min_amount = 50
		default_max_amount = 50

	hundred
		default_min_amount = 100
		default_max_amount = 100

	fivehundred
		default_min_amount = 500
		default_max_amount = 500

	thousand
		default_min_amount = 1000
		default_max_amount = 1000

//not a good spot for this but idc
TYPEINFO(/obj/item/stamped_bullion)
	mat_appearances_to_ignore = list("gold")
/obj/item/stamped_bullion //*not* a material piece - therefore doesn't stack, needs to be refined, etc. etc. etc.
	name = "stamped bullion"
	desc = "Oh wow! This stuff's got to be worth a lot of money!"
	icon = 'icons/obj/materials.dmi'
	icon_state = "stamped_gold"
	force = 4
	throwforce = 6
	mat_changename = FALSE
	default_material = "gold"

/obj/item/currency/fakecash // im the king of bad ideas
	name = "1 discount credit"
	real_name = "discount credit"
	desc = "You gotta have mon- Wait why does this say Discount Dan's Genuine Authentic Credit-like Currency?"
	stack_type = /obj/item/currency/fakecash // so all FAKE cash types can stack with each other
	display_name = "cash"

	_update_stack_appearance()
		src.UpdateName()
		src.inventory_counter.update_number(src.amount)
		switch (src.amount)
			if (-INFINITY to 9)
				src.icon_state = "cashgreen"
			if (10 to 49)
				src.icon_state = "cashblue"
			if (50 to 499)
				src.icon_state = "cashindi"
			if (500 to 999)
				src.icon_state = "cashpurp"
			if (1000 to 999999)
				src.icon_state = "cashred"
			else // 1mil bby
				src.icon_state = "cashrbow"

	five
		name = "5 discount credits" //names are so they show up correctly in vendors and stuff
		default_min_amount = 5
		default_max_amount = 5

	ten
		name = "10 discount credits"
		default_min_amount = 10
		default_max_amount = 10

	twenty
		name = "20 discount credits"
		default_min_amount = 20
		default_max_amount = 20

	fifty
		name = "50 discount credits"
		default_min_amount = 50
		default_max_amount = 50

	hundred
		name = "100 discount credits"
		default_min_amount = 100
		default_max_amount = 100

	fivehundred
		name = "500 discount credits"
		default_min_amount = 500
		default_max_amount = 500

	thousand
		name = "1000 discount credits"
		default_min_amount = 1000
		default_max_amount = 1000

	hundredthousand
		name = "100000 discount credits"
		default_min_amount = 100000
		default_max_amount = 100000

	million
		name = "1000000 discount credits"
		default_min_amount = 1000000
		default_max_amount = 1000000


/obj/item/currency/fishing
	name = "1 research ticket"
	real_name = "research ticket"
	icon_state = "fish_common"
	layer = 4.5
	desc = "A Nanotrasen aquatic research ticket compatible with the Fishing Equipment Vendor."
	stack_type = /obj/item/currency/fishing // so all fishing tokens stack
	default_min_amount = 1
	default_max_amount = 1
	display_name = "research tickets"

	_update_stack_appearance()
		src.UpdateName()
		src.inventory_counter.update_number(src.amount)
		switch (src.amount)
			if (-INFINITY to 1)
				src.icon_state = "fish_common"
			if (1 to 2)
				src.icon_state = "fish_uncommon"
			if (2 to 3)
				src.icon_state = "fish_rare"
			if (3 to 4)
				src.icon_state = "fish_epic"
			else
				src.icon_state = "fish_legendary"

	attackby(var/obj/item/I, mob/user)
		if (istype(I, /obj/item/currency/fishing) && src.amount < src.max_stack)

			user.visible_message(SPAN_NOTICE("[user] stacks some tickets."))
			stack_item(I)
		else
			..(I, user)

	mouse_drop(atom/over_object, src_location, over_location) //src dragged onto over_object
		if (isobserver(usr))
			boutput(usr, "<span class='alert'>Quit that! You're dead!</span>")
			return

		if(!istype(over_object, /atom/movable/screen/hud))
			if (BOUNDS_DIST(usr, src) > 0)
				boutput(usr, "<span class='alert'>You're too far away from it to do that.</span>")
				return
			if (BOUNDS_DIST(usr, over_object) > 0)
				boutput(usr, "<span class='alert'>You're too far away from it to do that.</span>")
				return

		if (istype(over_object,/obj/item/currency/fishing) && isturf(over_object.loc)) //piece to piece only if on ground
			var/obj/item/targetObject = over_object
			if(targetObject.stack_item(src))
				usr.visible_message("<span class='notice'>[usr.name] stacks \the [src]!</span>")
		else if(isturf(over_object)) //piece to turf. piece loc doesnt matter.
			if(isturf(src.loc))
				src.set_loc(over_object)
			for(var/obj/item/I in view(1,usr))
				if (!I || I == src)
					continue
				if (!src.check_valid_stack(I))
					continue
				src.stack_item(I)
			usr.visible_message("<span class='notice'>[usr.name] stacks \the [src]!</span>")
		else
			..()


	uncommon
		name = "uncommon research ticket"
		icon_state = "fish_uncommon"
		default_min_amount = 2
		default_max_amount = 2

	rare
		name = "rare research ticket"
		icon_state = "fish_rare"
		default_min_amount = 3
		default_max_amount = 3

	epic
		name = "epic research ticket"
		icon_state = "fish_epic"
		default_min_amount = 4
		default_max_amount = 4

	legendary
		name = "legendary research ticket"
		icon_state = "fish_legendary"
		default_min_amount = 5
		default_max_amount = 5

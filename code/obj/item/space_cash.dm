/obj/item/spacecash
	name = "1 credit"
	real_name = "credit"
	desc = "You gotta have money."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "cashgreen"
	uses_multiple_icon_states = 1
	opacity = 0
	density = 0
	anchored = UNANCHORED
	force = 1
	throwforce = 1
	throw_speed = 1
	throw_range = 8
	w_class = W_CLASS_TINY
	burn_point = 400
	burn_possible = 2
	burn_output = 750
	amount = 1
	max_stack = 1000000
	stack_type = /obj/item/spacecash // so all cash types can stack iwth each other
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 1
	inventory_counter_enabled = 1
	var/default_min_amount = 0
	var/default_max_amount = 0

	New(var/atom/loc, var/amt = 1 as num)
		var/default_amount = default_min_amount == default_max_amount ? default_min_amount : rand(default_min_amount, default_max_amount)
		src.amount = max(amt,default_amount) //take higher
		..(loc)
		src.UpdateStackAppearance()

	proc/setup(var/atom/L, var/amt = 1 as num)
		set_loc(L)
		set_amt(amt)

	proc/set_amt(var/amt = 1 as num)
		var/default_amount = default_min_amount == default_max_amount ? default_min_amount : rand(default_min_amount, default_max_amount)
		src.amount = max(amt,default_amount)
		src.UpdateStackAppearance()

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

	UpdateName()
		src.name = "[src.amount == src.max_stack ? "1000000" : src.amount] [name_prefix(null, 1)][src.real_name][s_es(src.amount)][name_suffix(null, 1)]"

	before_stack(atom/movable/O as obj, mob/user as mob)
		user.visible_message("<span class='notice'>[user] is stacking cash!</span>")

	after_stack(atom/movable/O as obj, mob/user as mob, var/added)
		boutput(user, "<span class='notice'>You finish stacking cash.</span>")

	failed_stack(atom/movable/O as obj, mob/user as mob, var/added)
		boutput(user, "<span class='alert'>You need another stack!</span>")

	attackby(var/obj/item/I, mob/user)
		if (istype(I, /obj/item/spacecash) && src.amount < src.max_stack)
			if (istype(I, /obj/item/spacecash/buttcoin))
				boutput(user, "Your transaction will complete anywhere within 10 to 10e27 minutes from now.")
				return

			user.visible_message("<span class='notice'>[user] stacks some cash.</span>")
			stack_item(I)
		else
			..(I, user)

	attack_hand(mob/user)
		if ((user.l_hand == src || user.r_hand == src) && user.equipped() != src)
			var/amt = round(input("How much cash do you want to take from the stack?") as null|num)
			if (isnum_safe(amt) && src.loc == user && !user.equipped())
				if (amt > src.amount || amt < 1)
					boutput(user, "<span class='alert'>You wish!</span>")
					return
				change_stack_amount( 0 - amt )
				var/obj/item/spacecash/young_money = new /obj/item/spacecash
				young_money.setup(user.loc, amt)
				young_money.Attackhand(user)
		else
			..(user)

	onMaterialChanged()
		. = ..()
		if(src.amount > 1)
			src.visible_message("[src] melds together into a single credit. What?")
			src.desc += " It looks all melted together or something."
			src.change_stack_amount(-(src.amount-1))
			UpdateStackAppearance()

//	attack_self(mob/user as mob)
//		user.visible_message("fart")

/obj/item/spacecash/five
	default_min_amount = 5
	default_max_amount = 5

/obj/item/spacecash/ten
	default_min_amount = 10
	default_max_amount = 10

/obj/item/spacecash/twenty
	default_min_amount = 20
	default_max_amount = 20

/obj/item/spacecash/fifty
	default_min_amount = 50
	default_max_amount = 50

/obj/item/spacecash/hundred
	default_min_amount = 100
	default_max_amount = 100

/obj/item/spacecash/fivehundred
	default_min_amount = 500
	default_max_amount = 500

/obj/item/spacecash/thousand
	default_min_amount = 1000
	default_max_amount = 1000

/obj/item/spacecash/hundredthousand
	default_min_amount = 100000
	default_max_amount = 100000

/obj/item/spacecash/million
	default_min_amount = 1000000
	default_max_amount = 1000000

/obj/item/spacecash/random
	default_min_amount = 1
	default_max_amount = 1000000

// That's what tourists spawn with.
/obj/item/spacecash/random/tourist
	default_min_amount = 500
	default_max_amount = 1500

// for couches
/obj/item/spacecash/random/small
	default_min_amount = 1
	default_max_amount = 500

/obj/item/spacecash/random/really_small
	default_min_amount = 1
	default_max_amount = 50

/obj/item/spacecash/buttcoin
	name = "buttcoin"
	desc = "The crypto-currency of the future (If you don't pay for your own electricity and got in early and don't lose the file and don't want transactions to be faster than half an hour and . . .)"
	icon_state = "cashblue"

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
					boutput(user, "<span class='alert'>You wish!</span>")
					return

				boutput(user, "Your transaction will complete anywhere within 10 to 10e27 minutes from now.")
		else
			..()

	attackby(var/obj/item/I, mob/user)
		if (istype(I, /obj/item/spacecash) && src.amount < src.max_stack)
			boutput(user, "Your transaction will complete anywhere within 10 to 10e27 minutes from now.")
		else
			..(I, user)

	disposing()
		processing_items.Remove(src)
		..()



/obj/item/spacecash/bag // hufflaw cashbags
	New(var/atom/loc)
		..(loc)
		amount = rand(1,10000)
		name = "money bag"
		desc = "Loadsamoney!"
		icon = 'icons/obj/items/items.dmi'
		icon_state = "moneybag"
		item_state = "moneybag"
		inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'



/obj/item/spacebux // Not space cash. Actual spacebux. Wow.
	name = "\improper Spacebux token"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "spacebux_gray"
	desc = "A Spacebux token, neat! You can insert this into an ATM to add it to your account."

	amount = 0
	var/spent = 0

	opacity = 0
	density = 0
	anchored = UNANCHORED
	force = 1
	throwforce = 1
	throw_speed = 1
	throw_range = 8
	w_class = W_CLASS_TINY
	burn_possible = 0
	amount = 1
	max_stack = 1000000
	stack_type = /obj/item/spacebux


	New(var/atom/loc, var/amt = null)
		..(loc)
		if (amt != null)
			src.amount = amt

		src.UpdateStackAppearance()

	get_desc()
		. += "This one is worth [amount >= 1000000 ? "ONE FUCKING GOD DAMN MILLION" : amount] spacebux."

	proc/setup(var/atom/L, var/amt = 1 as num)
		set_loc(L)
		set_amt(amt)

	proc/set_amt(var/amt = 1 as num)
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

	before_stack(atom/movable/O as obj, mob/user as mob)
		user.visible_message("<span class='notice'>[user] is stacking spacebux!</span>")

	after_stack(atom/movable/O as obj, mob/user as mob, var/added)
		boutput(user, "<span class='notice'>You finish stacking spacebux.</span>")

	failed_stack(atom/movable/O as obj, mob/user as mob, var/added)
		boutput(user, "<span class='alert'>You need another stack!</span>")

	attackby(var/obj/item/I, mob/user)
		if (istype(I, /obj/item/spacebux) && src.spent == 0)
			user.visible_message("<span class='notice'>[user] stacks some spacebux.</span>")
			stack_item(I)
		else
			..(I, user)

	check_valid_stack(atom/movable/O as obj)
		if (istype(O, /obj/item/spacebux))
			// Immediately fail if it's been spent already
			var/obj/item/spacebux/SB = O
			if (src.spent || SB.spent)
				return 0
		return ..()

	attack_hand(mob/user)
		if ((user.l_hand == src || user.r_hand == src) && user.equipped() != src)
			var/amt = round(input("How much spacebux do you want to split from the token?") as null|num)
			if (isnum_safe(amt) && src.loc == user && !user.equipped())
				if (amt > src.amount || amt < 1)
					boutput(user, "<span class='alert'>You wish!</span>")
					return
				change_stack_amount( 0 - amt )
				var/obj/item/spacebux/new_token = new
				new_token.setup(user.loc, amt)
				user.put_in_hand_or_drop(new_token)
		else
			..(user)

	ten
		amount = 10

	fifty
		amount = 50

	hundred
		amount = 100

	fivehundred
		amount = 500

	thousand
		amount = 1000

//not a good spot for this but idc
/obj/item/stamped_bullion //*not* a material piece - therefore doesn't stack, needs to be refined, etc. etc. etc.
	name = "stamped bullion"
	desc = "Oh wow! This stuff's got to be worth a lot of money!"
	icon = 'icons/obj/materials.dmi'
	icon_state = "stamped_gold"
	force = 4
	throwforce = 6

	New()
		. = ..()
		src.setMaterial(getMaterial("gold"), appearance = 0, setname = 0)

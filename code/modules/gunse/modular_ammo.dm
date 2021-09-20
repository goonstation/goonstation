
ABSTRACT_TYPE(/obj/item/stackable_ammo/)
/obj/item/stackable_ammo/
	name = "1 round"
	real_name = "round"
	desc = "You gotta have bullets."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "custom-8"
	//uses_multiple_icon_states = 1
	opacity = 0
	density = 0
	anchored = 0.0
	force = 1.0
	throwforce = 1.0
	throw_speed = 1
	throw_range = 8
	w_class = W_CLASS_TINY
	burn_point = 700
	burn_possible = 2
	burn_output = 750
	health = 10
	amount = 1
	max_stack = 1000
	stack_type = null
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 1
	inventory_counter_enabled = 1
	var/default_min_amount = 1
	var/default_max_amount = 1
	var/datum/projectile/projectile_type = null
	var/ammo_DRM = null
	var/reloading = 0


	New(var/atom/loc, var/amt = 1 as num)
		var/default_amount = default_min_amount == default_max_amount ? default_min_amount : rand(default_min_amount, default_max_amount)
		src.amount = max(amt,default_amount) //take higher
		..(loc)
		src.update_stack_appearance()

	proc/setup(var/atom/L, var/amt = 1 as num)
		set_loc(L)
		set_amt(amt)

	proc/set_amt(var/amt = 1 as num)
		var/default_amount = default_min_amount == default_max_amount ? default_min_amount : rand(default_min_amount, default_max_amount)
		src.amount = max(amt,default_amount)
		src.update_stack_appearance()

	unpooled()
		..()
		var/default_amount = default_min_amount == default_max_amount ? default_min_amount : rand(default_min_amount, default_max_amount)
		src.amount = max(1, default_amount) //take higher
		src.update_stack_appearance()

	pooled()
		if (usr)
			usr.u_equip(src) //wonder if that will work?
		amount = 1
		..()

	update_stack_appearance()
		src.UpdateName()
		src.inventory_counter.update_number(src.amount)
		/*
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
*/
	UpdateName()
		src.name = "[src.amount == src.max_stack ? "1000" : src.amount] [name_prefix(null, 1)][src.real_name][s_es(src.amount)][name_suffix(null, 1)]"

	before_stack(atom/movable/O as obj, mob/user as mob)
		user.visible_message("<span class='notice'>[user] is stacking rounds!</span>")

	after_stack(atom/movable/O as obj, mob/user as mob, var/added)
		boutput(user, "<span class='notice'>You finish stacking rounds.</span>")

	failed_stack(atom/movable/O as obj, mob/user as mob, var/added)
		boutput(user, "<span class='alert'>You need another stack!</span>")

	attackby(var/obj/item/I as obj, mob/user as mob)
		if (istype(I, /obj/item/stackable_ammo) && src.amount < src.max_stack)

			user.visible_message("<span class='notice'>[user] stacks some rounds.</span>")
			stack_item(I)
		else
			if(istype(I, /obj/item/gun/modular/))
				src.reload(I, user)
			else
				..(I, user)

	attack_hand(mob/user as mob)
		if ((user.l_hand == src || user.r_hand == src) && user.equipped() != src)
			var/amt = round(input("How many rounds do you want to take from the stack?") as null|num)
			if (amt && src.loc == user && !user.equipped())
				if (amt > src.amount || amt < 1)
					boutput(user, "<span class='alert'>You wish!</span>")
					return
				change_stack_amount( 0 - amt )
				var/obj/item/stackable_ammo/young_money = unpool(/obj/item/stackable_ammo)
				young_money.setup(user.loc, amt)
				young_money.Attackhand(user)
		else
			..(user)

	proc/reload(var/obj/item/gun/modular/M, mob/user as mob)
		if(reloading)
			return
		if(!istype(M))
			return
		if(!projectile_type)
			return
		if(!M.ammo_list)
			M.ammo_list = list()
		if(M.ammo_list.len >= M.max_ammo_capacity)
			return
		reloading = 1
		SPAWN_DBG(0)
			boutput(user, "<span class='notice'>You start loading rounds into [M]</span>")
			while(M.ammo_list.len < M.max_ammo_capacity)
				if(amount < 1)
					user.u_equip(src)
					src.dropped(user)
					pool(src)
					break
				playsound(src.loc, "sound/weapons/casings/casing-0[rand(1,9)].ogg", 10, 0.1, 0, 0.8)
				amount--
				M.ammo_list += projectile_type
				update_stack_appearance()
				sleep(5)
			playsound(src.loc, "sound/weapons/gunload_heavy.ogg", 30, 0.1, 0, 0.8)
			reloading = 0
		if(amount < 1)
			user.u_equip(src)
			src.dropped(user)
			pool(src)



/obj/item/stackable_ammo/capacitive/
	name = "\improper NT Stunner Fuckers"
	real_name = "\improper NT Stunner Fuckers"
	desc = "pee pee, poo poo"
	projectile_type = /datum/projectile/energy_bolt
	ammo_DRM = GUN_NANO | GUN_FOSS
	color = "#FFFF30"

	three
		default_min_amount = 3
		default_max_amount = 3

	five
		default_min_amount = 5
		default_max_amount = 5

	ten
		default_min_amount = 10
		default_max_amount = 10

/obj/item/stackable_ammo/zaubertube/
	name = "\improper Elektrograd лазерный Zaubertube"
	real_name = "Elektrograd лазерный Zaubertube"
	desc = "A small glass bulb filled with hypergolic incandescent chemicals."
	projectile_type = /datum/projectile/laser
	ammo_DRM = GUN_SOVIET | GUN_FOSS
	color = "#c89"

	three
		default_min_amount = 3
		default_max_amount = 3

	five
		default_min_amount = 5
		default_max_amount = 5

	ten
		default_min_amount = 10
		default_max_amount = 10



/obj/item/stackable_ammo/flashbulb/
	name = "\improper FOSSYN. CATHODIC FLASH BULBS"
	real_name = "FOSSYN. CATHODIC FLASH BULB"
	desc = "A hefty glass tube filled with ionic gas, and two opposing electrodes."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tbulb"
	projectile_type = null
	max_stack = 1 // not stackable! scandalous!
	ammo_DRM = GUN_FOSS
	var/max_health = 20
	var/min_health = 15


	reload(var/obj/item/gun/modular/M, mob/user as mob)
		if(reloading)
			return
		if(!istype(M))
			return
		if(!M.flashbulb_only)
			return
		if(!M.ammo_list)
			M.ammo_list = list()
		if(M.ammo_list.len >= M.max_ammo_capacity)
			return
		reloading = 1
		SPAWN_DBG(0)
			boutput(user, "<span class='notice'>You start loading a bulb into [M].</span>")
			if(M.ammo_list.len < M.max_ammo_capacity)
				playsound(src.loc, "sound/weapons/casings/casing-0[rand(1,9)].ogg", 10, 0.1, 0, 0.8)
				M.ammo_list += src
				user.u_equip(src)
				src.dropped(user)
				src.set_loc(M)
				sleep(5)
				if(M.ammo_list.len == M.max_ammo_capacity)
					playsound(src.loc, "sound/weapons/gunload_heavy.ogg", 30, 0.1, 0, 0.8)
				reloading = 0


//The neon lining object, used for placing neon lining.

#define MAXLINING 40
#define STARTLINING 1
/obj/item/neon_lining
	name = "neon lining"
	var/base_name = "neon lining"
	desc = "A coil of neon lining."
	amount = STARTLINING
	max_stack = MAXLINING
	stack_type = /obj/item/neon_lining
	icon = 'icons/obj/decals/neon_lining.dmi'
	icon_state = "item_blue"
	item_state = "electronic"
	throwforce = 2
	w_class = 1.0
	throw_speed = 2
	throw_range = 5
	flags = TABLEPASS|EXTRADELAY|FPRINT|CONDUCT|ONBELT
	stamina_damage = 5
	stamina_cost = 5
	stamina_crit_chance = 10
	rand_pos = 1
	event_handler_flags = USE_GRAB_CHOKE | USE_FLUID_ENTER
	special_grab = /obj/item/grab

	var/lining_item_color = "blue"

	New(loc, length = STARTLINING)
		src.amount = length
		pixel_x = rand(-2,2)
		pixel_y = rand(-2,2)
		..(loc)
		BLOCK_ROPE

	before_stack(atom/movable/O as obj, mob/user as mob)
		user.visible_message("<span class='notice'>[user] begins coiling neon lining!</span>")

	after_stack(atom/movable/O as obj, mob/user as mob, var/added)
		boutput(user, "<span class='notice'>You finish coiling neon lining.</span>")

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] wraps neon lining around \his neck and tightens it.</b></span>")
		user.take_oxygen_deprivation(160)
		SPAWN_DBG(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

	proc/use(var/used)
		if (src.amount < used)
			return 0
		else if (src.amount == used)
			qdel(src)
			return 1
		else
			amount -= used
			tooltip_rebuild = 1
			return 1

	proc/take(var/amt, var/newloc)
		if (amt > amount)
			amt = amount
			tooltip_rebuild = 1
		if (amt == amount)
			if (ismob(loc))
				var/mob/owner = loc
				owner.u_equip(src)
			set_loc(newloc)
			return src
		src.use(amt)
		var/obj/item/neon_lining/C = new /obj/item/neon_lining(newloc)
		C.amount = amt
		return

	proc/updateicon()
		set_icon_state("item_[lining_item_color]")
		return

/obj/item/neon_lining/cut
	New(loc, length)
		if (length)
			..(loc, length)
		else
			..(loc, rand(1,2))

/obj/item/neon_lining/cut/small
	New(loc, length)
		..(loc, rand(1,5))

/obj/item/neon_lining/shipped
	New(loc, length)
		..(loc, 20)

/obj/item/neon_lining/attack_self(mob/user as mob)
	if (lining_item_color == "blue")
		lining_item_color = "pink"
	else if (lining_item_color == "pink")
		lining_item_color = "yellow"
	else
		lining_item_color = "blue"
	tooltip_rebuild = 1
	boutput(user, "You change the [base_name]'s color to [lining_item_color].")
	updateicon()
	return

/obj/item/neon_lining/get_desc()
	return " There's [amount] length[s_es(amount)] left. It is [lining_item_color]."

/obj/item/neon_lining/attackby(obj/item/W, mob/user)
	if (issnippingtool(W) && src.amount > 1)
		src.amount--
		tooltip_rebuild = 1
		take(1, usr.loc)
		boutput(user, "You cut a piece off the [base_name].")
		return

	else if (istype(W, /obj/item/neon_lining))
		var/obj/item/neon_lining/C = W

		if (C.amount == MAXLINING)
			boutput(user, "The coil is too long, you cannot add any more lining to it.")
			return

		if ((C.amount + src.amount <= MAXLINING))
			C.amount += src.amount
			boutput(user, "You join the lining coils together.")
			C.tooltip_rebuild = 1
			C.updateicon()
			if(istype(src.loc, /obj/item/storage))
				var/obj/item/storage/storage = src.loc
				storage.hud.remove_object(src)
			else if(istype(src.loc, /mob))
				var/mob/M = src.loc
				M.u_equip(src)
				M.drop_item(src)
			qdel(src)
			return

		else
			boutput(user, "You transfer [MAXLINING - src.amount] length\s of lining from one coil to the other.")
			src.amount -= (MAXLINING-C.amount)
			src.updateicon()
			tooltip_rebuild = 1
			C.amount = MAXLINING
			C.updateicon()
			C.tooltip_rebuild = 1
			return

/obj/item/neon_lining/MouseDrop_T(atom/movable/O as obj, mob/user as mob)
	..(O, user)
	for (var/obj/item/neon_lining/C in view(1, user))
		C.updateicon()

/obj/item/neon_lining/afterattack(turf/F, mob/user)
	if (!isturf(user.loc))
		return

	if (!istype(F,/turf/simulated/floor))
		return

	if (get_dist(F,user) > 1)
		boutput(user, "You can't lay neon lining at a place that far away.")
		return

	else
		var/dirn

		if (user.loc == F)
			dirn = user.dir			//If laying on the tile we're on, lay in the direction we're facing.
		else
			dirn = get_dir(F, user)

		var/obj/neon_lining/C = new /obj/neon_lining(F, src)
		if (dirn == 2)
			C.lining_rotation = 1
		else if (dirn == 4)
			C.lining_rotation = 2
		else if (dirn == 8)
			C.lining_rotation = 3
		else
			C.lining_rotation = 0
		boutput(user, "You set some neon lining on the floor.")
		C.lining_color = lining_item_color
		C.add_fingerprint(user)
		C.lining_update_icon()
		use(1)
	return

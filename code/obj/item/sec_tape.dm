#define MAXTAPE 40
#define STARTAMOUNT 1
/// The security tape roll object, used to create security tapes.
/obj/item/sec_tape
	name = "security tape roll"
	var/base_name = "security tape roll"
	desc = "A roll of security tape."
	amount = STARTAMOUNT
	max_stack = MAXTAPE
	stack_type = /obj/item/sec_tape
	icon = 'icons/obj/sec_tape.dmi'
	icon_state = "sec_tape_roll"
	w_class = W_CLASS_TINY
	flags = TABLEPASS|EXTRADELAY|FPRINT|CONDUCT|ONBELT
	rand_pos = 1
	event_handler_flags = USE_GRAB_CHOKE | USE_FLUID_ENTER
	special_grab = /obj/item/grab
	inventory_counter_enabled = 1

	New(loc, length = STARTAMOUNT)
		src.amount = length
		pixel_x = rand(-2,2)
		pixel_y = rand(-2,2)
		..(loc)
		BLOCK_SETUP(BLOCK_ROPE)

	before_stack(atom/movable/O as obj, mob/user as mob)
		user.visible_message("<span class='notice'>[user] begins awkwardly sticking the tape back onto the roll.</span>")

	after_stack(atom/movable/O as obj, mob/user as mob, var/added)
		boutput(user, "<span class='notice'>You finish sticking the tape back together.</span>")

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] wraps some tape around \his neck and tightens it.</b></span>")
		user.take_oxygen_deprivation(160)
		SPAWN(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

	proc/use(var/used) // remove "used" amount from the coil
		if (src.amount < used)
			return 0
		else if (src.amount == used)
			qdel(src)
			return 1
		else
			amount -= used
			tooltip_rebuild = 1
			src.UpdateIcon()
			return 1

	proc/take(var/amt, var/newloc) // removes "amt" from the coil and put it somewhere, use for coil splitting with wirecutters
		if (amt > amount)
			amt = amount
			tooltip_rebuild = 1
			src.UpdateIcon()
		if (amt == amount)
			if (ismob(loc))
				var/mob/owner = loc
				owner.u_equip(src)
			set_loc(newloc)
			return src
		src.use(amt)
		var/obj/item/sec_tape/C = new /obj/item/sec_tape(newloc)
		C.amount = amt
		return

	update_icon()
		inventory_counter?.update_number(amount)
		return

/obj/item/sec_tape/vended //Tape in secvends has a pre-set amount of uses
	New(loc, length)
		..(loc, 20)

/obj/item/sec_tape/get_desc()
	return "There's [amount] length[s_es(amount)] left."

/obj/item/sec_tape/attackby(obj/item/W, mob/user)
	if (issnippingtool(W) && src.amount > 1) //Cut some of it off to share
		take(1, user.loc)
		tooltip_rebuild = 1
		boutput(user, "You cut a piece off the [base_name].")
		src.UpdateIcon()
		return

	else if (istype(W, /obj/item/sec_tape))
		var/obj/item/sec_tape/C = W

		if (C.amount == MAXTAPE)
			boutput(user, "The coil is too long, you cannot add any more tape to it.")
			return

		if ((C.amount + src.amount <= MAXTAPE))
			C.amount += src.amount
			boutput(user, "You join the tape ends together.")
			C.tooltip_rebuild = 1
			C.UpdateIcon()
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
			boutput(user, "You transfer [MAXTAPE - src.amount] length\s of tape from one roll to the other.")
			src.amount -= (MAXTAPE-C.amount)
			src.UpdateIcon()
			tooltip_rebuild = 1
			C.amount = MAXTAPE
			C.UpdateIcon()
			C.tooltip_rebuild = 1
			return

/obj/item/sec_tape/MouseDrop_T(atom/movable/O as obj, mob/user as mob)
	..(O, user)
	for (var/obj/item/sec_tape/C in view(1, user))
		C.UpdateIcon()

/obj/item/sec_tape/afterattack(turf/F, mob/user)
	if (!isturf(user.loc))
		return

	if (!istype(F,/turf/simulated/floor))
		return

	if (BOUNDS_DIST(F, user) > 0)
		boutput(user, "You can't setup a cordon at a place that far away.")
		return

	else
		var/dirn = user.dir

		var/obj/sec_tape/ST = new /obj/sec_tape(F, src)
		if (dirn == SOUTH)
			ST.dir = SOUTH
		else if (dirn == EAST)
			ST.dir = EAST
		else if (dirn == WEST)
			ST.dir = WEST
		else
			ST.dir = NORTH
		boutput(user, "You [pick("hastily", "quickly", "haphazardly")] setup a security cordon.")
		ST.add_fingerprint(user)
		ST.tape_UpdateIcon()
		ST.layerify()
		use(1)
	return

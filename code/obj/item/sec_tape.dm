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
	flags = TABLEPASS|EXTRADELAY|CONDUCT
	c_flags = ONBELT
	rand_pos = 1
	event_handler_flags = USE_GRAB_CHOKE | USE_FLUID_ENTER
	special_grab = /obj/item/grab
	inventory_counter_enabled = 1

	New(loc, length = STARTAMOUNT)
		src.amount = length
		..(loc)
		BLOCK_SETUP(BLOCK_ROPE)

	before_stack(atom/movable/O, mob/user)
		user.visible_message(SPAN_NOTICE("[user] begins awkwardly sticking the tape back onto the roll."))

	after_stack(atom/movable/O, mob/user, var/added)
		boutput(user, SPAN_NOTICE("You finish sticking the tape back together."))

	change_stack_amount(diff)
		. = ..()
		tooltip_rebuild = TRUE
		src.UpdateIcon()

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		//Are we on valid turf?
		var/turf/T = get_turf(user)
		if (isturf(user.loc) && istype(T, /turf/simulated/floor) && amount >= 4)
			//Setup the perfect crime
			user.visible_message(SPAN_ALERT("<b>[user] carefully sets up some security tape around themselves then swallows the tape and chokes on it, satisfied that they created the perfect crime scene.</b>"))
			var/obj/sec_tape/T1 = new /obj/sec_tape(T, src)
			T1.set_dir(EAST)
			var/obj/sec_tape/T2 = new /obj/sec_tape(T, src)
			T2.set_dir(WEST)
			var/obj/sec_tape/T3 = new /obj/sec_tape(T, src)
			T3.set_dir(NORTH)
			var/obj/sec_tape/T4 = new /obj/sec_tape(T, src)
			T4.set_dir(SOUTH)
			//No need to set it up to the south, it already is by default
			user.death(FALSE)
			qdel(src)
		else
			//Else we'll choke ourselves out
			user.visible_message(SPAN_ALERT("<b>[user] wraps some tape around [his_or_her(user)] neck and tightens it.</b>"))
			user.take_oxygen_deprivation(160)
			SPAWN(50 SECONDS)
				if (user && !isdead(user))
					user.suiciding = 0
		return 1

	update_icon()
		inventory_counter?.update_number(amount)

/obj/item/sec_tape/vended //Tape in secvends has a pre-set amount of uses
	New(loc)
		..(loc)
		amount = 20
		src.UpdateIcon()

/obj/item/sec_tape/get_desc()
	return "There's [amount] length[s_es(amount)] left."

/obj/item/sec_tape/attackby(obj/item/W, mob/user)
	if (issnippingtool(W) && src.amount > 1) //Cut some of it off to share
		var/obj/item/sec_tape/split_tape = split_stack(1)
		user.put_in_hand_or_drop(split_tape)
		tooltip_rebuild = TRUE
		boutput(user, SPAN_NOTICE("You cut a piece off the [base_name]."))
		src.UpdateIcon()
		return

	else if (istype(W, /obj/item/sec_tape))
		var/obj/item/sec_tape/C = W

		if (C.amount == src.max_stack)
			boutput(user, SPAN_NOTICE("The coil is too long, you cannot add any more tape to it."))
			return

		if ((C.amount + src.amount <= src.max_stack))
			stack_item(W)
			boutput(user, SPAN_NOTICE("You join the tape ends together."))
			C.tooltip_rebuild = TRUE
			C.UpdateIcon()
			return

		else
			boutput(user, SPAN_NOTICE("You transfer [src.max_stack - src.amount] length\s of tape from one roll to the other."))
			src.amount -= (src.max_stack-C.amount)
			src.UpdateIcon()
			tooltip_rebuild = TRUE
			C.amount = src.max_stack
			C.UpdateIcon()
			C.tooltip_rebuild = TRUE
			return

/obj/item/sec_tape/MouseDrop_T(atom/movable/O as obj, mob/user as mob)
	..(O, user)

/obj/item/sec_tape/afterattack(turf/F, mob/user)
	if (!isturf(user.loc))
		return

	if (!istype(F,/turf/simulated/floor))
		return

	if (BOUNDS_DIST(F, user) > 0)
		boutput(user, SPAN_NOTICE("You can't setup a cordon at a place that far away."))
		return

	var/dirn = user.dir
	for (var/obj/sec_tape/T in F)
		if (T.dir == dirn)
			boutput(user, SPAN_NOTICE("There is already a cordon setup there!"))
			return

	var/obj/sec_tape/ST = new /obj/sec_tape(F, src)
	if (dirn == SOUTH)
		ST.set_dir(SOUTH)
	else if (dirn == EAST)
		ST.set_dir(EAST)
	else if (dirn == WEST)
		ST.set_dir(WEST)
	else
		ST.set_dir(NORTH)
	boutput(user, SPAN_NOTICE("You [pick("hastily", "quickly", "haphazardly")] setup a security cordon."), group="sectape_setup")
	ST.add_fingerprint(user)
	change_stack_amount(-1)

#undef MAXTAPE
#undef STARTAMOUNT

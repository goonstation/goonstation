/obj/sec_tape
	anchored = 1
	icon = 'icons/obj/sec_tape.dmi'
	icon_state = "sec_tape_s"
	name = "security cordon"
	real_name = "security cordon"
	desc = "A small cordon of security tape, used to keep assistants off crime scenes."
	density = 1
	flags = FPRINT | USEDELAY | ON_BORDER
	object_flags = HAS_DIRECTIONAL_BLOCKING
	dir = SOUTH

	New()
		..()
		UpdateIcon()

	set_dir()
		. = ..()
		UpdateIcon()

	update_icon()
		. = ..()
		//Setup the layer

		if (dir == SOUTH)
			layer = MOB_LAYER + 0.1
		else
			layer = OBJ_LAYER
		//Setup the icon
		switch (dir)
			if (WEST)
				set_icon_state("sec_tape_w")
			if (NORTH)
				set_icon_state("sec_tape_n")
			if (EAST)
				set_icon_state("sec_tape_e")
			else //Default position is south
				set_icon_state("sec_tape_s")

	Cross(atom/movable/O as mob|obj)
		if (O == null)
			return 0
		if (!src.density || (O.flags & TABLEPASS) || istype(O, /obj/newmeteor) || istype(O, /obj/lpt_laser) )
			return 1
		if (dir & get_dir(loc, O))
			return !density
		return 1

	Uncross(atom/movable/O, do_bump = TRUE)
		if (!src.density || (O.flags & TABLEPASS) || istype(O, /obj/newmeteor) || istype(O, /obj/lpt_laser) )
			. = 1
		else if (dir & get_dir(O.loc, O.movement_newloc))
			. = 0
		else
			. = 1
		UNCROSS_BUMP_CHECK(O)

	attackby(obj/item/W, mob/user)
		if (issnippingtool(W)) //Cut tape can be reused
			new /obj/item/sec_tape(get_turf(src))
			src.visible_message("[user] neatly cuts [src] with [W].")
			qdel(src)
		else if (!istype(W, /obj/item/sec_tape)) //Avoid accidentally breaking the tape trying to setup more
			make_cleanable(/obj/decal/cleanable/sec_tape, src.loc)
			qdel(src)

	attack_hand(mob/M)
		if (M.a_intent == INTENT_HELP)
			src.try_vault(M)
		else
			make_cleanable(/obj/decal/cleanable/sec_tape, src.loc)
			src.visible_message("<span class='alert'>[M] rips up [src].</span>")
			qdel(src)

	Bumped(var/mob/AM as mob)
		. = ..()
		if(!istype(AM)) return
		if(AM.client?.check_key(KEY_RUN)) //In a rush? Run through it
			playsound(src, 'sound/effects/snaptape.ogg', 10)
			make_cleanable(/obj/decal/cleanable/sec_tape, src.loc)
			qdel(src)
		else	//Just walking? Vault it
			src.try_vault(AM)

	proc/try_vault(mob/user, use_owner_dir = FALSE)
		if(!actions.hasAction(user, "railing_jump"))
			actions.start(new /datum/action/bar/icon/railing_jump(user, src, use_owner_dir), user)

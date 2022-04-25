/obj/sec_tape
	anchored = 1
	icon = 'icons/obj/decals/neon_lining.dmi'
	icon_state = "base2"
	name = "security cordon"
	real_name = "security_cordon"
	density = 1
	flags = FPRINT | USEDELAY | ON_BORDER
	object_flags = HAS_DIRECTIONAL_BLOCKING
	dir = SOUTH
	var/tape_shape = 2          												//Shapes: 1 = circle, 2 = _ that's a tile long, 3 = _ that's half a tile long, 4 = |_| shape, 5 = _| shape, 6 = _| shape but twice as wide & tall.
	var/tape_rotation = 0		  												//Rotation: 0 = south, 1 = west, 2 = north, 3 = east.
	var/tape_icon_state = 1													//This is used for choosing the proper icon state for reasons stated in the lining_pattern comment.

	New()
		..()
		layerify()

	proc/layerify()
		SPAWN(3 DECI SECONDS)
		if (dir == SOUTH)
			layer = MOB_LAYER + 0.1
		else
			layer = OBJ_LAYER

	proc/tape_UpdateIcon()
		if (dir == SOUTH)
			set_dir(0)
		else if (dir == WEST)
			set_dir(8)
		else if (dir == NORTH)
			set_dir(2)
		else
			set_dir(4)
		return

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
		if (issnippingtool(W))
			new /obj/item/sec_tape(get_turf(src))
			src.visible_message("[user] neatly cuts [src] with [W].")
			qdel(src)
		else if (!istype(W, /obj/item/sec_tape))
			make_cleanable(/obj/decal/cleanable/blood/splatter, L.loc)
			qdel(src)
		else
			return

	attack_hand(mob/M as mob)
		if (M.a_intent == INTENT_HELP)
			src.try_vault(M)
		else
			src.visible_message("[M] rips up [src].")
			qdel(src)

	Bumped(var/mob/AM as mob)
		. = ..()
		if(!istype(AM)) return
		if(AM.client?.check_key(KEY_RUN))
			make_cleanable(/obj/decal/cleanable/blood/splatter, L.loc)
			qdel(src)
		else
			src.try_vault(AM)

	proc/try_vault(mob/user, use_owner_dir = FALSE)
		if(!actions.hasAction(user, "railing_jump"))
			actions.start(new /datum/action/bar/icon/railing_jump(user, src, use_owner_dir), user)
		else
			return

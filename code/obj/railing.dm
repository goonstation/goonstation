/obj/railing
	name = "railing"
	desc = "Two sets of bars shooting onward with the sole goal of blocking you off. They can't stop you from vaulting over them though!"
	anchored = 1
	density = 1
	icon = 'icons/obj/objects.dmi'
	icon_state = "railing"
	layer = OBJ_LAYER - 0.1
	color = "#ffffff"
	flags = FPRINT | USEDELAY | ON_BORDER | ALWAYS_SOLID_FLUID
	event_handler_flags = USE_FLUID_ENTER | USE_CHECKEXIT | USE_CANPASS
	dir = SOUTH

/*	This was made for the old railing sprites that just didn't work out :c
	proc/layerify()
		if (dir == SOUTH)
			layer = MOB_LAYER + 1

		else if (dir == SOUTHWEST || dir == SOUTHEAST)
			layer = MOB_LAYER + 1.1

		else if (dir == NORTH)
			layer = OBJ_LAYER - 0.2

		else
			layer = OBJ_LAYER - 0.1

	New()
		..()
		SPAWN_DBG(1 DECI SECOND) // why are you like this why is this necessary
		layerify()

 */
	CanPass(atom/movable/O as mob|obj, turf/target, height=0, air_group=0)
		if (O == null)
			logTheThing("debug", src, O, "Target is null! CanPass failed.")
			return 0
		if (!src.density || (O.flags & TABLEPASS) || istype(O, /obj/newmeteor) || istype(O, /obj/lpt_laser) )
			return 1
		if(air_group || (height==0))
			return 1
		if(get_dir(loc, O) == dir)
			return !density
		else
			return 1

	CheckExit(atom/movable/O as mob|obj, target as turf)
		if (!src.density)
			return 1
		else if (!src.density || (O.flags & TABLEPASS || istype(O, /obj/newmeteor)) || istype(O, /obj/lpt_laser) )
			return 1
		else if (get_dir(O.loc, target) == src.dir)
			return 0
		else
			return 1
/*
	CanPass(atom/movable/O as mob|obj, turf/target, height=0, air_group=0)
		if (!src.density || (O.flags & TABLEPASS || istype(O, /obj/newmeteor)) )
			return 1
			world.log << "CanPass: [O.name] Is nodense / tablepass! Pass!"
		if(air_group || (height==0))
			return 1
			world.log << "CanPass: [O.name] Is air/height0! Pass!"
		if (src.dir == SOUTHWEST || src.dir == SOUTHEAST || src.dir == NORTHWEST || src.dir == NORTHEAST) // why would you be like this
			return 0
			world.log << "CanPass: [src.name] Is diagonal ([src.dir])! FAIL!"
		if(get_dir(loc, O) == dir)
			return !density
			world.log << "CanPass: [O.name] Not our dir! Pass!"
		else
			world.log << "CanPass: [O.name] Passed all checks! Pass!"
			return 1
	CheckExit(atom/movable/O as mob|obj, target as turf)
		if (!src.density)
			world.log << "CheckExit: [O.name] Is not dense! Pass!"
			return 1
		else if (!src.density || (O.flags & TABLEPASS || istype(O, /obj/newmeteor)) )
			world.log << "CheckExit: [O.name] Is nodense / tablepass! Pass!"
			return 1
		else if (get_dir(O.loc, target) == src.dir)
			world.log << "CheckExit: Same dir as ours ([src.dir])! FAIL!"
			return 0
		else
			world.log << "CheckExit: Passed all checks! Pass!"
			return 1
 */

/*
	Turn()
		..()
		layerify()
 */
	attackby(obj/item/W as obj, mob/user)
		if (istype(W, /obj/item/weldingtool))
			var/obj/item/weldingtool/WELD = W
			if (WELD.get_fuel() >= 2)
				actions.start(new /datum/action/bar/icon/railingDeconstruct(src,user), user)
			else
				user.show_text("[WELD] doesn't have enough fuel!", "red")

	orange
		color = "#ff7b00"

	red
		color = "#ff0000"

	green
		color = "#09ff00"

	yellow
		color = "#ffe600"

	cyan
		color = "#00f7ff"

	purple
		color = "#cc00ff"

	blue
		color = "#0026ff"
/*
	// Inner railings so you can make some weirder connections work!
	inner
		icon_state = "railing-inner"

		CanPass(atom/movable/O as mob|obj, turf/target, height=0, air_group=0)
			if (O == null)
				..()
			if (!src.density || (O.flags & TABLEPASS) || istype(O, /obj/newmeteor) || istype(O, /obj/lpt_laser) )
				..()
			if(air_group || (height==0))
				..()
			if(get_dir(loc, O) == dir)
				return !density
			// If we're facing north or south (both east and west are covered in both railing sprite dirs)
			if(src.dir == SOUTH || src.dir == NORTH)
				if(O.dir == WEST || O.dir == EAST)
					return !density
			// ^ Same thing here but for east and west! v
			if(src.dir == EAST || src.dir == WEST)
				if(O.dir == NORTH || O.dir == SOUTH)
					return !density
			else
				..()

		orange
			color = "#ff7b00"

		red
			color = "#ff0000"

		green
			color = "#09ff00"

		yellow
			color = "#ffe600"

		cyan
			color = "#00f7ff"

		purple
			color = "#cc00ff"

		blue
			color = "#0026ff"
*/


/datum/action/bar/icon/railingDeconstruct
	duration = 30
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "railing_deconstruct"
	icon = 'icons/obj/items/tools/weldingtool.dmi'
	icon_state = "weldingtool_on"
	var/obj/railing/target
	var/mob/ownerMob
	var/obj/item/weldingtool/WELD

	New(Target)
		..()
		target = Target
		ownerMob = owner
		world.log << ("OWNER - [ownerMob.name]")
		//world.log << ("OWNERPATH - [owner.path]")
		WELD = ownerMob.find_type_in_hand(/obj/item/weldingtool)

	onUpdate()
		..()
		if(WELD && (WELD.get_fuel() >= 2))
			if(get_dist(owner, target) > 1 || target == null || owner == null)
				interrupt(INTERRUPT_ALWAYS)
				return
		else
			ownerMob.show_text("[WELD] doesn't have enough fuel!", "red")
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(get_dist(owner, target) > 1 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		for(var/mob/O in AIviewers(owner))
			O.show_text("[owner] begins to weld [target]!", "red")

	onEnd()
		..()
		//if (owner && target && (get_dist(owner, target) <= 1) && (istype(ownerMob.equipped(), /obj/item/weldingtool)))

		if(owner)
			ownerMob.show_text("OWNER", "green")
		if(target)
			ownerMob.show_text("TARGET","green")
		if(get_dist(owner, target) <= 1)
			ownerMob.show_text("DISTANCE","green")
		if(istype(ownerMob.equipped(), /obj/item/weldingtool))
			ownerMob.show_text("EQUIPPED","green")

			/*for(var/mob/O in AIviewers(owner))
				O.show_text("[owner] welds [target] apart.", "red")
			var/obj/item/ammo/bullets/rod/R = new(target)
			R.amount = 4
			qdel(target)
			WELD.eyecheck(user)
			WELD.use_fuel(2)*/

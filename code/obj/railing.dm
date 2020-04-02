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

	proc/layerify()
		if (dir == SOUTH)
			layer = MOB_LAYER + 1

		else if (dir == NORTH)
			layer = OBJ_LAYER - 0.2

		else
			layer = OBJ_LAYER - 0.1

	New()
		..()
		SPAWN_DBG(1 DECI SECOND) // why are you like this why is this necessary
		layerify()


	CanPass(atom/movable/O as mob|obj, turf/target, height=0, air_group=0)
		if (O == null)
			return 0
			logTheThing("debug", src, O, "Target is null! CanPass failed.")
		if (!src.density || (O.flags & TABLEPASS) || istype(O, /obj/newmeteor) || istype(O, /obj/lpt_laser) )
			return 1
		if(air_group || (height==0))
			return 1
		if (src.dir == SOUTHWEST || src.dir == SOUTHEAST || src.dir == NORTHWEST || src.dir == NORTHEAST) // why would you be like this
			return 0
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
	Turn()
		..()
		layerify()

	attackby(obj/item/I, mob/user)
		var/obj/item/weldingtool/WELDER
		if (I == WELDER)
			if (WELDER.get_fuel() == 2)
				actions.start(new /datum/action/bar/icon/railingDeconstruct(src), user)
			else
				user.show_text("[WELDER] doesn't have enough fuel!", "red")

	orange
		color = "#ff7b00"

	red
		color = "#ff0000"

	green
		color = "#09ff00"

	yellow
		color = "#ffe600"

	purple
		color = "#cc00ff"

	blue
		color = "#0026ff"

/datum/action/bar/icon/railingDeconstruct
	duration = 30
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "railing_deconstruct"
	icon = 'icons/obj/items/tools/weldingtool.dmi'
	icon_state = "weldingtool_on"
	var/obj/railing/target
	var/mob/living/user
	var/obj/item/weldingtool/WELDER
	var/mob/ownerMob

	New(Target)
		target = Target
		WELDER = user.find_type_in_hand(/obj/item/weldingtool)
		ownerMob = owner
		..()

	onUpdate()
		..()
		if(get_dist(owner, target) > 1 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(get_dist(owner, target) > 1 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		for(var/mob/O in AIviewers(owner))
			O.show_text("[owner] begins to weld [target]!", "red")
		WELDER.eyecheck(user)

	onEnd()
		..()
		if (owner && target && get_dist(owner, target) <= 1 && (istype(ownerMob.equipped(), /obj/item/weldingtool)))
			for(var/mob/O in AIviewers(owner))
				O.show_text("[owner] welds [target] apart.", "red")
			var/obj/item/ammo/bullets/rod/R = new(target)
			R.amount = 4
			qdel(target)
			WELDER.use_fuel(1)

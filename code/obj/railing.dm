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
	custom_suicide = 1

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
		if (isweldingtool(W) && W:try_weld(user, 2))
			actions.start(new /datum/action/bar/icon/railing_tool_interact(user, src, W, RAILING_DISASSEMBLE, 30), user)

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


/datum/action/bar/icon/railing_tool_interact
	duration = 30
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "railing_deconstruct"
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"
	var/obj/railing/the_railing
	var/mob/ownerMob
	var/obj/item/tool
	var/interaction = RAILING_DISASSEMBLE

	New(The_Owner, The_Target, var/obj/item/The_Tool, The_Interaction, The_Duration)
		..()
		if (The_Target)
			the_railing = The_Target
		if (The_Owner)
			owner = The_Owner
			ownerMob = The_Owner
		if (The_Tool)
			tool = The_Tool
			icon = The_Tool.icon
			icon_state = The_Tool.icon_state
		if (The_Duration)
			duration = The_Duration
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (H.traitHolder.hasTrait("carpenter"))
				duration = round(duration / 2)
		if (The_Interaction)
			interaction = The_Interaction
			switch (interaction)
				if (RAILING_DISASSEMBLE)
					The_Tool = ownerMob.find_type_in_hand(/obj/item/weldingtool)
				if (RAILING_FASTEN)
					The_Tool = ownerMob.find_type_in_hand(/obj/item/screwdriver)
				if (RAILING_UNFASTEN)
					The_Tool = ownerMob.find_type_in_hand(/obj/item/screwdriver)



	onUpdate()
		..()
		if (tool == null || the_railing == null || owner == null || get_dist(owner, the_railing) > 1)
			interrupt(INTERRUPT_ALWAYS)
			return
		else if (interaction == RAILING_DISASSEMBLE)
			if(get_dist(ownerMob, the_railing) > 1 || the_railing == null || ownerMob == null)
				interrupt(INTERRUPT_ALWAYS)
				return

	onStart()
		//featuring code shamelessly copypasted from table.dm because fuuuuuuuck
		..()
		if (get_dist(ownerMob, the_railing) > 1 || the_railing == null || ownerMob == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		if (!tool)
			ownerMob.show_text("Wait, what the fuck? Where's your tool?!", "red")
			interrupt(INTERRUPT_ALWAYS)
			return
		var/verbing = "doing something to"
		switch (interaction)
			if (RAILING_DISASSEMBLE)
				verbing = "to disassemble"
				playsound(get_turf(the_railing), "sound/items/Welder.ogg", 50, 1)
			if (RAILING_FASTEN)
				verbing = "fastening"
				playsound(get_turf(the_railing), "sound/items/Screwdriver.ogg", 50, 1)
			if (RAILING_UNFASTEN)
				verbing = "unfastening"
				playsound(get_turf(the_railing), "sound/items/Screwdriver.ogg", 50, 1)
		for(var/mob/O in AIviewers(ownerMob))
			O.show_text("[owner] begins [verbing] [the_railing].", "red")

	onEnd()
		..()
		var/verbens = "does something to"
		switch (interaction)
			if (RAILING_DISASSEMBLE)
				verbens = "disassembles"
				deconstruct()
				playsound(get_turf(the_railing), "sound/items/Welder.ogg", 50, 1)
			if (RAILING_FASTEN)
				verbens = "fastens"
				the_railing.anchored = 1
				playsound(get_turf(the_railing), "sound/items/Screwdriver.ogg", 50, 1)
			if (RAILING_UNFASTEN)
				verbens = "unfastens"
				the_railing.anchored = 0
				playsound(get_turf(the_railing), "sound/items/Screwdriver.ogg", 50, 1)
		for(var/mob/O in AIviewers(ownerMob))
			O.show_text("[owner] [verbens] [the_railing].", "red")

	proc/deconstruct()
		var/obj/item/sheet/steel/S
		S = new (the_railing.loc)
		if (S && the_railing.material)
			S.setMaterial(the_railing.material)
		qdel(the_railing)


/*
		if(owner)
			ownerMob.show_text("OWNER", "green")
		if(target)
			ownerMob.show_text("TARGET","green")
		if(get_dist(owner, target) <= 1)
			ownerMob.show_text("DISTANCE","green")
		if(istype(ownerMob.equipped(), /obj/item/weldingtool))
			ownerMob.show_text("EQUIPPED","green")
*/

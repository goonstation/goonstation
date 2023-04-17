obj/structure
	icon = 'icons/obj/structures.dmi'

	girder
		icon_state = "girder"
		anchored = ANCHORED
		density = 1
		material_amt = 0.2
		var/state = 0
		desc = "A metal support for an incomplete wall. Metal could be added to finish the wall, reinforced metal could make the girders stronger, or it could be pried to displace it."

		displaced
			name = "displaced girder"
			icon_state = "displaced"
			anchored = UNANCHORED
			desc = "An unsecured support for an incomplete wall. A screwdriver would seperate the metal into sheets, or adding metal or reinforced metal could turn it into fake wall that could opened by hand."

		reinforced
			name = "reinforced girder"
			icon_state = "reinforced"
			state = 2
			desc = "A reinforced metal support for an incomplete wall. Reinforced metal could turn it into a reinforced wall, or it could be disassembled with various tools."

	blob_act(var/power)
		if (power < 30)
			return
		if (prob(power - 29))
			qdel(src)

	meteorhit(obj/O as obj)
		qdel(src)

obj/structure/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
			return
		if(2)
			if(prob(50))
				qdel(src)
				return
		if(3)
			return
	return

/obj/structure/girder/attack_hand(mob/user)
	if (user.is_hulk())
		if (prob(50))
			playsound(user.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 50, 1)
			if (src.material)
				src.material.triggerOnAttacked(src, user, user, src)
			for (var/mob/N in AIviewers(user, null))
				if (N.client)
					shake_camera(N, 4, 1, 8)
		if (prob(80))
			boutput(user, text("<span class='notice'>You smash through the girder.</span>"))
			logTheThing(LOG_COMBAT, user, "uses hulk to smash a girder at [log_loc(src)].")
			if (istype(src, /obj/structure/girder/reinforced))
				var/atom/A = new /obj/structure/girder(src)
				if (src.material)
					A.setMaterial(src.material)
				else
					var/datum/material/M = getMaterial("steel")
					A.setMaterial(M)
				qdel(src)
			else
				if (prob(30))
					var/atom/A = new /obj/structure/girder/displaced(src)
					if (src.material)
						A.setMaterial(src.material)
					else
						var/datum/material/M = getMaterial("steel")
						A.setMaterial(M)
				else
					qdel(src)

		else
			boutput(user, text("<span class='notice'>You punch the [src.name].</span>"))
			return
	..()

/obj/structure/girder/attackby(obj/item/W, mob/user)
	if (iswrenchingtool(W) && state == 0 && anchored && !istype(src, /obj/structure/girder/displaced))
		actions.start(new /datum/action/bar/icon/girder_tool_interact(src, W, GIRDER_DISASSEMBLE, null, user), user)


	else if (isscrewingtool(W) && state == 2 && istype(src, /obj/structure/girder/reinforced))
		actions.start(new /datum/action/bar/icon/girder_tool_interact(src, W, GIRDER_UNSECURESUPPORT, null, user), user)

	else if (issnippingtool(W) && istype(src, /obj/structure/girder/reinforced) && state == 1)
		actions.start(new /datum/action/bar/icon/girder_tool_interact(src, W, GIRDER_REMOVESUPPORT, null, user), user)

	else if (ispryingtool(W) && state == 0 && anchored )
		actions.start(new /datum/action/bar/icon/girder_tool_interact(src, W, GIRDER_DISLODGE, null, user), user)

	else if (iswrenchingtool(W) && state == 0 && !anchored )
		if (!istype(src.loc, /turf/simulated/floor/))
			boutput(user, "<span class='alert'>Not sure what this floor is made of but you can't seem to wrench a hole for a bolt in it.</span>")
			return
		actions.start(new /datum/action/bar/icon/girder_tool_interact(src, W, GIRDER_SECURE, null, user), user)
	else if (istype(W, /obj/item/sheet))
		var/obj/item/sheet/S = W
		if (S.amount < 2)
			boutput(user, "<span class='alert'>You need at least two sheets on the stack to do this.</span>")
			return

		if (src.icon_state != "reinforced" && S.reinforcement)
			actions.start(new /datum/action/bar/icon/girder_tool_interact(src, W, GIRDER_REINFORCE, null, user), user)

		else
			actions.start(new /datum/action/bar/icon/girder_tool_interact(src, W, GIRDER_PLATE, null, user), user)
	else
		..()

/datum/action/bar/icon/girder_tool_interact
	id = "girder_tool_interact"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 3 SECONDS
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/structure/girder/the_girder
	var/obj/item/the_tool
	var/interaction = GIRDER_DISASSEMBLE

	New(var/obj/table/girdr, var/obj/item/tool, var/interact, var/duration_i, var/mob/user)
		..()
		if (girdr)
			the_girder = girdr
		if (tool)
			the_tool = tool
			icon = the_tool.icon
			icon_state = the_tool.icon_state
		if (interact)
			interaction = interact
		if (duration_i)
			duration = duration_i
		if (ishuman(user))
			var/mob/living/carbon/human/H = user

			if (H.traitHolder.hasTrait("training_engineer"))
				duration = duration / 2

			else if (H.traitHolder.hasTrait("carpenter")) // It's so one nullifies the other. Carpenter and engineer training shouldn't stack up.
				duration = duration / 1.5

		var/mob/living/critter/robotic/bot/engibot/E = user
		if(istype(E))
			interrupt_flags = INTERRUPT_STUNNED | INTERRUPT_MOVE
			duration = 1 DECI SECOND

	onUpdate()
		..()
		if (the_girder == null || the_tool == null || owner == null || BOUNDS_DIST(owner, the_girder) > 0)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && !equipped_or_holding(the_tool, source))
			interrupt(INTERRUPT_ALWAYS)
			return
		if (istype(source) && !equipped_or_holding(the_tool, source) && the_tool.amount >= 2 && interaction == GIRDER_PLATE)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		var/verbing = ""
		switch (interaction)
			if (GIRDER_DISASSEMBLE)
				verbing = "disassembling"
				playsound(the_girder, 'sound/items/Ratchet.ogg', 100, 1)
			if (GIRDER_UNSECURESUPPORT)
				verbing = "unsecuring support struts from"
				playsound(the_girder, 'sound/items/Screwdriver.ogg', 100, 1)
			if (GIRDER_REMOVESUPPORT)
				verbing = "removing support struts from"
				playsound(the_girder, 'sound/items/Wirecutter.ogg', 100, 1)
			if (GIRDER_DISLODGE)
				verbing = "dislodging"
				playsound(the_girder, 'sound/items/Crowbar.ogg', 100, 1)
			if (GIRDER_REINFORCE)
				verbing = "reinforcing"
			if (GIRDER_SECURE)
				playsound(the_girder, 'sound/items/Ratchet.ogg', 100, 1)
				verbing = "securing"
			if (GIRDER_PLATE)
				verbing = "plating"
		owner.visible_message("<span class='notice'>[owner] begins [verbing] [the_girder].</span>")

	onEnd()
		..()
		var/verbens = "does something to"
		switch (interaction)
			if (GIRDER_DISASSEMBLE)
				verbens = "disassembles"
				playsound(the_girder, 'sound/items/Ratchet.ogg', 100, 1)
				var/atom/A = new /obj/item/sheet(get_turf(the_girder))
				if (the_girder.material)
					A.setMaterial(the_girder.material)
				else
					var/datum/material/M = getMaterial("steel")
					A.setMaterial(M)
				qdel(the_girder)
			if (GIRDER_UNSECURESUPPORT)
				verbens = "unsecured the support struts of"
				the_girder.state = 1
			if (GIRDER_REMOVESUPPORT)
				verbens = "removed the support struts of"
				var/atom/A = new/obj/structure/girder( the_girder.loc )
				if(the_girder.material) A.setMaterial(the_girder.material)
				qdel(the_girder)
			if (GIRDER_DISLODGE)
				verbens = "dislodged"
				var/atom/A = new/obj/structure/girder/displaced( the_girder.loc )
				if(the_girder.material) A.setMaterial(the_girder.material)
				qdel(the_girder)
			if (GIRDER_REINFORCE)
				verbens = "reinforced"
				var/atom/A = new/obj/structure/girder/reinforced( the_girder.loc )
				if (the_tool.material)
					A.setMaterial(the_girder.material)
				else
					var/datum/material/M = getMaterial("steel")
					A.setMaterial(M)
				qdel(the_girder)
			if (GIRDER_SECURE)
				if (!istype(the_girder.loc, /turf/simulated/floor/))
					owner.visible_message("<span class='alert'>You feel like your body is being ripped apart from the inside. Maybe you shouldn't try that again. For your own safety, I mean.</span>")
					return
				verbens = "secured"
				var/atom/A = new/obj/structure/girder( the_girder.loc )
				if(the_girder.material) A.setMaterial(the_girder.material)
				qdel(the_girder)
			if (GIRDER_PLATE)
				verbens = "finishes plating"
				logTheThing(LOG_STATION, owner, "builds a Wall in [owner.loc.loc] ([log_loc(owner)])")
				var/turf/Tsrc = get_turf(the_girder)
				var/turf/simulated/wall/WALL
				var/obj/item/sheet/S = the_tool
				if (S.reinforcement)
					WALL = Tsrc.ReplaceWithRWall()
				else
					WALL = Tsrc.ReplaceWithWall()
				if (the_girder.material)
					WALL.setMaterial(the_girder.material)
				else
					var/datum/material/M = getMaterial("steel")
					WALL.setMaterial(M)
				WALL.inherit_area()
				S?.change_stack_amount(-2)

				qdel(the_girder)
		owner.visible_message("<span class='notice'>[owner] [verbens] [the_girder].</span>")

/obj/structure/girder/displaced/attack_hand(mob/user)
	if (user.is_hulk())
		if (prob(70))
			playsound(user.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 50, 1)
			if (src.material)
				src.material.triggerOnAttacked(src, user, user, src)
			for (var/mob/N in AIviewers(user, null))
				if (N.client)
					shake_camera(N, 4, 1, 8)
		if (prob(70))
			boutput(user, text("<span class='notice'>You smash through the girder.</span>"))
			logTheThing(LOG_COMBAT, user, "uses hulk to smash a girder at [log_loc(src)].")
			qdel(src)
			return
		else
			boutput(user, text("<span class='notice'>You punch the [src.name].</span>"))
			return
	..()

/obj/structure/girder/displaced/attackby(obj/item/W, mob/user)

	if (istype(W, /obj/item/sheet))
		if (!istype(src.loc, /turf/simulated/floor/))
			boutput(user, "<span class='alert'>You can't build a false wall there.</span>")
			return

		var/obj/item/sheet/S = W
		var/turf/simulated/floor/T = src.loc

		var/FloorIcon = T.icon
		var/FloorState = T.icon_state
		var/FloorIntact = T.intact
		var/FloorBurnt = T.burnt
		var/FloorName = T.name
		var/oldmat = src.material

		var/target_type = S.reinforcement ? /turf/simulated/wall/false_wall/reinforced : /turf/simulated/wall/false_wall

		T.ReplaceWith(target_type, FALSE, FALSE, FALSE)
		var/atom/A = src.loc
		if(oldmat)
			A.setMaterial(oldmat)
		else
			var/datum/material/M = getMaterial("steel")
			A.setMaterial(M)

		var/turf/simulated/wall/false_wall/FW = A
		FW.inherit_area()

		FW.setFloorUnderlay(FloorIcon, FloorState, FloorIntact, 0, FloorBurnt, FloorName)
		FW.known_by += user
		S.change_stack_amount(-1)
		boutput(user, "You finish building the false wall.")
		logTheThing(LOG_STATION, user, "builds a False Wall in [user.loc.loc] ([log_loc(user)])")
		qdel(src)
		return

	else if (isscrewingtool(W))
		var/obj/item/sheet/S = new /obj/item/sheet(src.loc)
		if(src.material)
			S.setMaterial(src.material)
		else
			var/datum/material/M = getMaterial("steel")
			S.setMaterial(M)
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 75, 1)
		qdel(src)
		return
	else
		return ..()

/obj/structure/woodwall
	name = "barricade"
	desc = "This was thrown up in a hurry."
	icon = 'icons/obj/structures.dmi'
	icon_state = "woodwall"
	anchored = ANCHORED
	density = 1
	opacity = 1
	mat_appearances_to_ignore = list("wood")
	var/health = 30
	var/health_max = 30
	var/builtby = null
	var/anti_z = 0

	virtual
		icon = 'icons/effects/VR.dmi'

	anti_zombie
		name = "anti-zombie wooden barricade"
		anti_z = 1

		get_desc()
			..()
			. += "Looks like normal spacemen can easily pull themselves over or crawl under it."
	proc/checkhealth()
		if (src.health <= 0)
			src.visible_message("<span class='alert'><b>[src] collapses!</b></span>")
			playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Lowfi_1.ogg', 100, 1)
			qdel(src)
			return
		else if (src.health <= 5)
			icon_state = "woodwall4"
			set_opacity(0)
		else if (src.health <= 10)
			icon_state = "woodwall3"
			set_opacity(0)
		else if (src.health <= 20)
			icon_state = "woodwall2"
		else
			icon_state = "woodwall"

	attack_hand(mob/user)
		if (ishuman(user) && !user.is_zombie)
			var/mob/living/carbon/human/H = user
			if (src.anti_z && H.a_intent != INTENT_HARM && isfloor(get_turf(src)))
				H.set_loc(get_turf(src))
				if (health > 15)
					H.visible_message("<span class='notice'><b>[H]</b> [pick("rolls under", "jaunts over", "barrels through")] [src] slightly damaging it!</span>")
					boutput(H, "<span class='alert'><b>OWW! You bruise yourself slightly!</span>")
					playsound(src.loc, 'sound/impact_sounds/Wood_Hit_1.ogg', 100, 1)
					random_brute_damage(H, 5)
					src.health -= rand(0,2)
					checkhealth()
				return

		if (ishuman(user))
			user.lastattacked = src
			src.visible_message("<span class='alert'><b>[user]</b> bashes [src]!</span>")
			playsound(src.loc, 'sound/impact_sounds/Wood_Hit_1.ogg', 100, 1)
			//Zombies do less damage
			var/mob/living/carbon/human/H = user
			if (istype(H.mutantrace, /datum/mutantrace/zombie))
				if(prob(40))
					H.emote("scream")
				src.health -= rand(0,2)
			else
				src.health -= rand(1,3)
			checkhealth()
			return
		else
			return

	attackby(var/obj/item/W, mob/user)
		if (istype(W, /obj/item/plank))
			actions.start(new /datum/action/bar/icon/plank_repair_wall(W, src, 30), user)
			return
		..()
		user.lastattacked = src
		playsound(src.loc, 'sound/impact_sounds/Wood_Hit_1.ogg', 100, 1)
		src.health -= W.force
		checkhealth()
		return

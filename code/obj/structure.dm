obj/structure
	icon = 'icons/obj/structures.dmi'

	girder
		icon_state = "girder"
		anchored = 1
		density = 1
		var/state = 0
		desc = "A metal support for an incomplete wall. Metal could be added to finish the wall, reinforced metal could make the girders stronger, or it could be pried to displace it."

		displaced
			name = "displaced girder"
			icon_state = "displaced"
			anchored = 0
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
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				qdel(src)
				return
		if(3.0)
			return
	return

/obj/structure/girder/attack_hand(mob/user as mob)
	if (user.is_hulk())
		if (prob(50))
			playsound(user.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 50, 1)
			if (src.material)
				src.material.triggerOnAttacked(src, user, user, src)
			for (var/mob/N in AIviewers(usr, null))
				if (N.client)
					shake_camera(N, 4, 1, 8)
		if (prob(80))
			boutput(user, text("<span class='notice'>You smash through the girder.</span>"))
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
					del(src)

		else
			boutput(user, text("<span class='notice'>You punch the [src.name].</span>"))
			return
	..()

/obj/structure/girder/attackby(obj/item/W as obj, mob/user as mob)
	if (iswrenchingtool(W) && state == 0 && anchored && !istype(src, /obj/structure/girder/displaced))
		actions.start(new /datum/action/bar/icon/girder_tool_interact(src, W, GIRDER_DISASSEMBLE), user)


	else if (isscrewingtool(W) && state == 2 && istype(src, /obj/structure/girder/reinforced))
		actions.start(new /datum/action/bar/icon/girder_tool_interact(src, W, GIRDER_UNSECURESUPPORT), user)

	else if (issnippingtool(W) && istype(src, /obj/structure/girder/reinforced) && state == 1)
		actions.start(new /datum/action/bar/icon/girder_tool_interact(src, W, GIRDER_REMOVESUPPORT), user)

	else if (ispryingtool(W) && state == 0 && anchored )
		actions.start(new /datum/action/bar/icon/girder_tool_interact(src, W, GIRDER_DISLODGE), user)

	else if (iswrenchingtool(W) && state == 0 && !anchored )
		if (!istype(src.loc, /turf/simulated/floor/))
			boutput(user, "<span class='alert'>Not sure what this floor is made of but you can't seem to wrench a hole for a bolt in it.</span>")
			return
		actions.start(new /datum/action/bar/icon/girder_tool_interact(src, W, GIRDER_SECURE), user)
	else if (istype(W, /obj/item/sheet))
		var/obj/item/sheet/S = W
		if (S.amount < 2)
			boutput(user, "<span class='alert'>You need at least two sheets on the stack to do this.</span>")
			return

		if (src.icon_state != "reinforced" && S.reinforcement)
			actions.start(new /datum/action/bar/icon/girder_tool_interact(src, W, GIRDER_REINFORCE), user)

		else
			actions.start(new /datum/action/bar/icon/girder_tool_interact(src, W, GIRDER_PLATE), user)
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

	New(var/obj/table/girdr, var/obj/item/tool, var/interact, var/duration_i)
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
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (H.traitHolder.hasTrait("carpenter") || H.traitHolder.hasTrait("training_engineer"))
				duration = round(duration / 2)

	onUpdate()
		..()
		if (the_girder == null || the_tool == null || owner == null || get_dist(owner, the_girder) > 1)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && the_tool != source.equipped())
			interrupt(INTERRUPT_ALWAYS)
			return
		if (istype(source) && the_tool != source.equipped() && the_tool.amount >= 2 && interaction == GIRDER_PLATE)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		var/verbing = ""
		switch (interaction)
			if (GIRDER_DISASSEMBLE)
				verbing = "disassembling"
				playsound(get_turf(the_girder), "sound/items/Ratchet.ogg", 100, 1)
			if (GIRDER_UNSECURESUPPORT)
				verbing = "unsecuring support struts from"
				playsound(get_turf(the_girder), "sound/items/Screwdriver.ogg", 100, 1)
			if (GIRDER_REMOVESUPPORT)
				verbing = "removing support struts from"
				playsound(get_turf(the_girder), "sound/items/Wirecutter.ogg", 100, 1)
			if (GIRDER_DISLODGE)
				verbing = "dislodging"
				playsound(get_turf(the_girder), "sound/items/Crowbar.ogg", 100, 1)
			if (GIRDER_REINFORCE)
				verbing = "reinforcing"
			if (GIRDER_SECURE)
				playsound(get_turf(the_girder), "sound/items/Ratchet.ogg", 100, 1)
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
				playsound(get_turf(the_girder), "sound/items/Ratchet.ogg", 100, 1)
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
				logTheThing("station", owner, null, "builds a Wall in [owner.loc.loc] ([showCoords(owner.x, owner.y, owner.z)])")
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
				// drsingh attempted fix for Cannot read null.amount
				if (!isnull(S))
					S.amount -= 2
					if (S.amount <= 0)
						qdel(the_tool)
					else
						S.inventory_counter.update_number(S.amount)

				qdel(the_girder)
		owner.visible_message("<span class='notice'>[owner] [verbens] [the_girder].</span>")

/obj/structure/girder/displaced/attack_hand(mob/user as mob)
	if (user.is_hulk())
		if (prob(70))
			playsound(user.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 50, 1)
			if (src.material)
				src.material.triggerOnAttacked(src, user, user, src)
			for (var/mob/N in AIviewers(usr, null))
				if (N.client)
					shake_camera(N, 4, 1, 8)
		if (prob(70))
			boutput(user, text("<span class='notice'>You smash through the girder.</span>"))
			qdel(src)
			return
		else
			boutput(user, text("<span class='notice'>You punch the [src.name].</span>"))
			return
	..()

/obj/structure/girder/displaced/attackby(obj/item/W as obj, mob/user as mob)

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
		S.consume_sheets(1)
		boutput(user, "You finish building the false wall.")
		logTheThing("station", user, null, "builds a False Wall in [user.loc.loc] ([showCoords(user.x, user.y, user.z)])")
		qdel(src)
		return

	else if (isscrewingtool(W))
		var/obj/item/sheet/S = new /obj/item/sheet(src.loc)
		if(src.material)
			S.setMaterial(src.material)
		else
			var/datum/material/M = getMaterial("steel")
			S.setMaterial(M)
		playsound(src.loc, "sound/items/Screwdriver.ogg", 75, 1)
		qdel(src)
		return
	else
		return ..()

/obj/structure/woodwall
	name = "wooden barricade"
	desc = "This was thrown up in a hurry."
	icon = 'icons/obj/structures.dmi'
	icon_state = "woodwall"
	anchored = 1
	density = 1
	opacity = 1
	var/health = 30
	var/builtby = null
	var/anti_z = 0

	virtual
		icon = 'icons/effects/VR.dmi'

	anti_zombie
		name = "anti-zombie wooden barricade"
		anti_z = 1
		get_desc()
			..()
			. += "Looks like normal spacemen can easily pull themselves over it."

	proc/checkhealth()
		if (src.health <= 0)
			src.visible_message("<span class='alert'><b>[src] collapses!</b></span>")
			playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Lowfi_1.ogg', 100, 1)
			qdel(src)
			return
		else if (src.health <= 5)
			icon_state = "woodwall4"
			opacity = 0
		else if (src.health <= 10)
			icon_state = "woodwall3"
			opacity = 0
		else if (src.health <= 20)
			icon_state = "woodwall2"
		else
			icon_state = "woodwall"

	attack_hand(mob/user as mob)
		if (ishuman(user) && !user.is_zombie)
			var/mob/living/carbon/human/H = user
			if (src.anti_z && H.a_intent != INTENT_HARM && isfloor(get_turf(src)))
				H.set_loc(get_turf(src))
				H.visible_message("<span class='notice'><b>[H]</b> [pick("rolls under", "jaunts over", "barrels through")] [src] slightly damaging it!</span>")
				boutput(H, "<span class='alert'><b>OWW! You bruise yourself slightly!</span>")
				random_brute_damage(H, 5)
				src.health -= rand(0,2)
				return

		if (ishuman(user))
			user.lastattacked = src
			src.visible_message("<span class='alert'><b>[user]</b> bashes [src]!</span>")
			playsound(src.loc, "sound/impact_sounds/Wood_Hit_1.ogg", 100, 1)
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

	attackby(var/obj/item/W as obj, mob/user as mob)
		..()
		user.lastattacked = src
		playsound(src.loc, "sound/impact_sounds/Wood_Hit_1.ogg", 100, 1)
		src.health -= W.force
		checkhealth()
		return

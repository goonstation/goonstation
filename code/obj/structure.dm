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
					shake_camera(N, 4, 1, 0.5)
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
		playsound(src.loc, "sound/items/Ratchet.ogg", 100, 1)
		var/turf/T = get_turf(user)
		boutput(user, "<span class='notice'>Now disassembling the girder</span>")
		sleep(4 SECONDS)
		if(get_turf(user) == T)
			boutput(user, "<span class='notice'>You dissasembled the girder!</span>")
			var/atom/A = new /obj/item/sheet(get_turf(src))
			if (src.material)
				A.setMaterial(src.material)
			else
				var/datum/material/M = getMaterial("steel")
				A.setMaterial(M)
			qdel(src)

	else if (isscrewingtool(W) && state == 2 && istype(src, /obj/structure/girder/reinforced))
		playsound(src.loc, "sound/items/Screwdriver.ogg", 100, 1)
		var/turf/T = get_turf(user)
		boutput(user, "<span class='notice'>Now unsecuring support struts</span>")
		sleep(4 SECONDS)
		if(get_turf(user) == T)
			boutput(user, "<span class='notice'>You unsecured the support struts!</span>")
			state = 1

	else if (issnippingtool(W) && istype(src, /obj/structure/girder/reinforced) && state == 1)
		playsound(src.loc, "sound/items/Wirecutter.ogg", 100, 1)
		var/turf/T = get_turf(user)
		boutput(user, "<span class='notice'>Now removing support struts</span>")
		sleep(4 SECONDS)
		if(get_turf(user) == T)
			boutput(user, "<span class='notice'>You removed the support struts!</span>")
			var/atom/A = new/obj/structure/girder( src.loc )
			if(src.material) A.setMaterial(src.material)
			qdel(src)

	else if (ispryingtool(W) && state == 0 && anchored )
		playsound(src.loc, "sound/items/Crowbar.ogg", 100, 1)
		var/turf/T = get_turf(user)
		boutput(user, "<span class='notice'>Now dislodging the girder</span>")
		sleep(4 SECONDS)
		if(get_turf(user) == T)
			boutput(user, "<span class='notice'>You dislodged the girder!</span>")
			var/atom/A = new/obj/structure/girder/displaced( src.loc )
			if(src.material) A.setMaterial(src.material)
			qdel(src)

	else if (iswrenchingtool(W) && state == 0 && !anchored )
		if (!istype(src.loc, /turf/simulated/floor/))
			boutput(user, "<span class='alert'>Not sure what this floor is made of but you can't seem to wrench a hole for a bolt in it.</span>")
			return
		playsound(src.loc, "sound/items/Ratchet.ogg", 100, 1)
		var/turf/T = get_turf(user)
		boutput(user, "<span class='notice'>Now securing the girder</span>")
		sleep(4 SECONDS)
		if (!istype(src.loc, /turf/simulated/floor/))
			boutput(user, "<span class='alert'>You feel like your body is being ripped apart from the inside. Maybe you shouldn't try that again. For your own safety, I mean.</span>")
			return
		if(get_turf(user) == T)
			boutput(user, "<span class='notice'>You secured the girder!</span>")
			var/atom/A = new/obj/structure/girder( src.loc )
			if(src.material) A.setMaterial(src.material)
			qdel(src)

	else if (istype(W, /obj/item/sheet))
		var/obj/item/sheet/S = W
		if (S.amount < 2)
			boutput(user, "<span class='alert'>You need at least two sheets on the stack to do this.</span>")
			return

		var/turf/T = get_turf(user)

		if (src.icon_state != "reinforced" && S.reinforcement)
			user.visible_message("<b>[user]</b> begins reinforcing [src].")
			sleep(6 SECONDS)
			if (user.loc == T)
				boutput(user, "You finish reinforcing the girder.")
				var/atom/A = new/obj/structure/girder/reinforced( src.loc )
				if (W.material)
					A.setMaterial(src.material)
				else
					var/datum/material/M = getMaterial("steel")
					A.setMaterial(M)
				qdel(src)
				return
			else
				boutput(user, "<span class='alert'>You'll need to stand still while reinforcing the girder.</span>")
				return

		else
			user.visible_message("<b>[user]</b> begins adding plating to [src].")
			sleep(2 SECONDS)
			if(!user)
				return
			// it was a good run, finishing all those walls with a sheet of 2 metal, but this is now causing runtimes
			// so i'm going to be hitler yet again -- marquesas

			var/obj/item/equippedThing = user.equipped()
			if (equippedThing.useInnerItem && istype(equippedThing.holding, /obj/item/sheet))
				equippedThing = equippedThing.holding

			if (get_turf(user) == T && W && equippedThing == W && S.amount >= 2 && istype(src.loc, /turf/simulated/floor/))
				boutput(user, "You finish building the wall.")
				logTheThing("station", user, null, "builds a Wall in [user.loc.loc] ([showCoords(user.x, user.y, user.z)])")
				var/turf/Tsrc = get_turf(src)
				var/turf/simulated/wall/WALL
				if (S.reinforcement)
					WALL = Tsrc.ReplaceWithRWall()
				else
					WALL = Tsrc.ReplaceWithWall()
				if (src.material)
					WALL.setMaterial(src.material)
				else
					var/datum/material/M = getMaterial("steel")
					WALL.setMaterial(M)
				WALL.inherit_area()
				// drsingh attempted fix for Cannot read null.amount
				if (S != null)
					S.amount -= 2
					if (S.amount <= 0)
						qdel(W)
					else
						S.inventory_counter.update_number(S.amount)

				qdel(src)
		return

	else
		..()

/obj/structure/girder/displaced/attack_hand(mob/user as mob)
	if (user.is_hulk())
		if (prob(70))
			playsound(user.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 50, 1)
			if (src.material)
				src.material.triggerOnAttacked(src, user, user, src)
			for (var/mob/N in AIviewers(usr, null))
				if (N.client)
					shake_camera(N, 4, 1, 0.5)

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

		var/atom/A = new /turf/simulated/wall/false_wall(src.loc)
		if(oldmat)
			A.setMaterial(oldmat)
		else
			var/datum/material/M = getMaterial("steel")
			A.setMaterial(M)

		var/turf/simulated/wall/false_wall/FW = A
		FW.inherit_area()

		FW.setFloorUnderlay(FloorIcon, FloorState, FloorIntact, 0, FloorBurnt, FloorName)
		FW.known_by += user
		if (S.reinforcement)
			FW.icon_state = "rdoor1"
		S.amount--
		if (S.amount < 1)
			qdel(S)
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

	virtual
		icon = 'icons/effects/VR.dmi'

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
		user.lastattacked = src
		if (ishuman(user))
			src.visible_message("<span class='alert'><b>[user]</b> bashes [src]!</span>")
			playsound(src.loc, "sound/impact_sounds/Wood_Hit_1.ogg", 100, 1)
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

/turf/simulated/wall
	name = "wall"
	desc = "Looks like a regular wall."
	icon = 'icons/turf/walls.dmi'
#ifndef IN_MAP_EDITOR // display disposal pipes etc. above walls in map editors
	plane = PLANE_WALL
#else
	plane = PLANE_FLOOR
#endif
	opacity = 1
	density = 1
	blocks_air = 1
	pathable = 1
	flags = ALWAYS_SOLID_FLUID
	text = "<font color=#aaa>#"

	var/health = 100
	var/list/proj_impacts = list()
	var/list/forensic_impacts = list()
	var/image/proj_image = null
	var/last_proj_update_time = null

	New()
		..()
		var/obj/plan_marker/wall/P = locate() in src
		if (P)
			P.check()

		//for fluids
		if (src.active_liquid && src.active_liquid.group)
			src.active_liquid.group.displace(src.active_liquid)

	ReplaceWithFloor()
		. = ..()
		if (map_currently_underwater)
			var/turf/space/fluid/n = get_step(src,NORTH)
			var/turf/space/fluid/s = get_step(src,SOUTH)
			var/turf/space/fluid/e = get_step(src,EAST)
			var/turf/space/fluid/w = get_step(src,WEST)
			if(istype(n))
				n.tilenotify(src)
			if(istype(s))
				s.tilenotify(src)
			if(istype(e))
				e.tilenotify(src)
			if(istype(w))
				w.tilenotify(src)

	get_desc()
		if (islist(src.proj_impacts) && src.proj_impacts.len)
			var/shots_taken = 0
			for (var/i in src.proj_impacts)
				shots_taken ++
			. += "<br>[src] has [shots_taken] hole[s_es(shots_taken)] in it."

	onMaterialChanged()
		..()
		if(istype(src.material))
			health = material.hasProperty("density") ? round(material.getProperty("density") * 2.5) : health
			if(src.material.material_flags & MATERIAL_CRYSTAL)
				health /= 2
		return

	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 312500 //a little over 5 cm thick , 312500 for 1 m by 2.5 m by 0.25 m steel wall
	explosion_resistance = 2

	proc/update_projectile_image(var/update_time)
		if (src.proj_impacts.len > 10)
			return
		if (src.last_proj_update_time && (src.last_proj_update_time + 1) < ticker.round_elapsed_ticks)
			return
		if (!src.proj_image)
			src.proj_image = image('icons/obj/projectiles.dmi', "blank")
		//src.overlays -= src.proj_image
		src.proj_image.overlays = null
		for (var/image/i in src.proj_impacts)
			src.proj_image.overlays += i
		src.UpdateOverlays(src.proj_image, "projectiles")
		//src.overlays += src.proj_image

/turf/simulated/wall/New()
	..()
	if(!ticker && istype(src.loc, /area/station/maintenance) && prob(7))
		make_cleanable( /obj/decal/cleanable/fungus,src)

// Made this a proc to avoid duplicate code (Convair880).
/turf/simulated/wall/proc/attach_light_fixture_parts(var/mob/user, var/obj/item/W)
	if (!user || !istype(W, /obj/item/light_parts/) || istype(W, /obj/item/light_parts/floor))	//hack, no floor lights on walls
		return

	// the wall is the target turf, the source is the turf where the user is standing
	var/obj/item/light_parts/parts = W
	var/turf/target = src
	var/turf/source = get_turf(user)

	// need to find the direction to orient the new light
	var/dir = 0

	// find the direction from the mob to the target wall
	for (var/d in cardinal)
		if (get_step(source,d) == target)
			dir = d
			break

	// if no direction was found, fail. need to be standing cardinal to the wall to put the fixture up
	if (!dir)
		return //..(parts, user)

	playsound(src, "sound/items/Screwdriver.ogg", 50, 1)
	boutput(user, "You begin to attach the light fixture to [src]...")

	if (!do_after(user, 40))
		user.show_text("You were interrupted!", "red")
		return

	if (!parts) //ZeWaka: Fix for null.fixture_type
		return

	// if they didn't move, put it up
	boutput(user, "You attach the light fixture to [src].")

	var/obj/machinery/light/newlight = new parts.fixture_type(source)
	newlight.dir = dir
	newlight.icon_state = parts.installed_icon_state
	newlight.base_state = parts.installed_base_state
	newlight.fitting = parts.fitting
	newlight.status = 1 // LIGHT_EMPTY

	newlight.add_fingerprint(user)
	src.add_fingerprint(user)

	user.u_equip(parts)
	qdel(parts)
	return

/turf/simulated/wall/proc/take_hit(var/obj/item/I)
	if(src.material)
		if(I.material)
			if((I.material.getProperty("hard") ? I.material.getProperty("hard") : (I.throwing ? I.throwforce : I.force)) >= (src.material.getProperty("hard") ? src.material.getProperty("hard") : 60))
				src.health -= round((I.throwing ? I.throwforce : I.force) / 10)
				src.visible_message("<span class='alert'>[usr ? usr : "Someone"] hits [src] with [I]!</span>", "<span class='alert'>You hit [src] with [I]!</span>")
			else
				src.visible_message("<span class='alert'>[usr ? usr : "Someone"] uselessly hits [src] with [I].</span>", "<span class='alert'>You hit [src] with [I] but it takes no damage.</span>")
		else
			if((I.throwing ? I.throwforce : I.force) >= 80)
				src.health -= round((I.throwing ? I.throwforce : I.force) / 10)
				src.visible_message("<span class='alert'>[usr ? usr : "Someone"] hits [src] with [I]!</span>", "<span class='alert'>You hit [src] with [I]!</span>")
			else
				src.visible_message("<span class='alert'>[usr ? usr : "Someone"] uselessly hits [src] with [I].</span>", "<span class='alert'>You hit [src] with [I] but it takes no damage.</span>")
	else
		if(I.material)
			if((I.material.getProperty("hard") ? I.material.getProperty("hard") : (I.throwing ? I.throwforce : I.force)) >= 60)
				src.health -= round((I.throwing ? I.throwforce : I.force) / 10)
				src.visible_message("<span class='alert'>[usr ? usr : "Someone"] hits [src] with [I]!</span>", "<span class='alert'>You hit [src] with [I]!</span>")
			else
				src.visible_message("<span class='alert'>[usr ? usr : "Someone"] uselessly hits [src] with [I].</span>", "<span class='alert'>You hit [src] with [I] but it takes no damage.</span>")
		else
			if((I.throwing ? I.throwforce : I.force) >= 80)
				src.health -= round((I.throwing ? I.throwforce : I.force) / 10)
				src.visible_message("<span class='alert'>[usr ? usr : "Someone"] hits [src] with [I]!</span>", "<span class='alert'>You hit [src] with [I]!</span>")
			else
				src.visible_message("<span class='alert'>[usr ? usr : "Someone"] uselessly hits [src] with [I].</span>", "<span class='alert'>You hit [src] with [I] but it takes no damage.</span>")

	if(health <= 0)
		src.visible_message("<span class='alert'>[usr ? usr : "Someone"] destroys [src]!</span>", "<span class='alert'>You destroy [src]!</span>")
		dismantle_wall(1)
	return

/turf/simulated/wall/proc/dismantle_wall(devastated=0)
	if (istype(src, /turf/simulated/wall/r_wall) || istype(src, /turf/simulated/wall/auto/reinforced))
		if (!devastated)
			playsound(src, "sound/items/Welder.ogg", 100, 1)
			var/atom/A = new /obj/structure/girder/reinforced(src)
			var/obj/item/sheet/B = new /obj/item/sheet( src )
			if (src.material)
				A.setMaterial(src.material)
				B.setMaterial(src.material)
				B.set_reinforcement(src.material)
			else
				var/datum/material/M = getMaterial("steel")
				A.setMaterial(M)
				B.setMaterial(M)
				B.set_reinforcement(M)
		else
			if (prob(50)) // pardon all these nested probabilities, just trying to vary the damage appearance a bit
				var/atom/A = new /obj/structure/girder/reinforced(src)
				if (src.material)
					A.setMaterial(src.material)
				else
					var/datum/material/M = getMaterial("steel")
					A.setMaterial(M)

				if (prob(50))
					var/atom/movable/B = unpool(/obj/item/raw_material/scrap_metal)
					B.set_loc(src)
					if (src.material)
						B.setMaterial(src.material)
					else
						var/datum/material/M = getMaterial("steel")
						B.setMaterial(M)

			else if( prob(50))
				var/atom/A = new /obj/structure/girder(src)
				if (src.material)
					A.setMaterial(src.material)
				else
					var/datum/material/M = getMaterial("steel")
					A.setMaterial(M)

	else
		if (!devastated)
			playsound(src, "sound/items/Welder.ogg", 100, 1)
			var/atom/A = new /obj/structure/girder(src)
			var/atom/B = new /obj/item/sheet( src )
			var/atom/C = new /obj/item/sheet( src )
			if (src.material)
				A.setMaterial(src.material)
				B.setMaterial(src.material)
				C.setMaterial(src.material)
			else
				var/datum/material/M = getMaterial("steel")
				A.setMaterial(M)
				B.setMaterial(M)
				C.setMaterial(M)
		else
			if (prob(50))
				var/atom/A = new /obj/structure/girder/displaced(src)
				if (src.material)
					A.setMaterial(src.material)
				else
					var/datum/material/M = getMaterial("steel")
					A.setMaterial(M)

			else if (prob(50))
				var/atom/B = new /obj/structure/girder(src)

				if (src.material)
					B.setMaterial(src.material)
				else
					var/datum/material/M = getMaterial("steel")
					B.setMaterial(M)

				if (prob(50))
					var/atom/movable/C = unpool(/obj/item/raw_material/scrap_metal)
					C.set_loc(src)
					if (src.material)
						C.setMaterial(src.material)
					else
						var/datum/material/M = getMaterial("steel")
						C.setMaterial(M)

	var/atom/D = ReplaceWithFloor()
	if (src.material)
		D.setMaterial(src.material)
	else
		var/datum/material/M = getMaterial("steel")
		D.setMaterial(M)

/turf/simulated/wall/burn_down()
	src.ReplaceWithFloor()

/turf/simulated/wall/ex_act(severity)
	switch(severity)
		if(1)
			src.ReplaceWithSpace()
			return
		if(2)
			if (prob(40))
				dismantle_wall(1)
		if(3)
			if (prob(66))
				dismantle_wall(1)
		else
	return

/turf/simulated/wall/blob_act(var/power)
	if(prob(power))
		dismantle_wall(1)

/turf/simulated/wall/attack_hand(mob/user as mob)
	if (user.is_hulk())
		if (prob(70))
			playsound(user.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 50, 1)
			if (src.material)
				src.material.triggerOnAttacked(src, user, user, src)
			for (var/mob/N in AIviewers(usr, null))
				if (N.client)
					shake_camera(N, 4, 1, 0.5)
		if (prob(40))
			boutput(user, text("<span class='notice'>You smash through the [src.name].</span>"))
			dismantle_wall(1)
			return
		else
			boutput(user, text("<span class='notice'>You punch the [src.name].</span>"))
			return

	if(src.material)
		var/fail = 0
		if(src.material.hasProperty("stability") && src.material.getProperty("stability") < 15) fail = 1
		if(src.material.quality < 0) if(prob(abs(src.material.quality))) fail = 1

		if(fail)
			user.visible_message("<span class='alert'>You punch the wall and it [getMatFailString(src.material.material_flags)]!</span>","<span class='alert'>[user] punches the wall and it [getMatFailString(src.material.material_flags)]!</span>")
			playsound(src, "sound/impact_sounds/Generic_Stab_1.ogg", 25, 1)
			dismantle_wall(1)
			return

	boutput(user, "<span class='notice'>You hit the [src.name] but nothing happens!</span>")
	playsound(src, "sound/impact_sounds/Generic_Stab_1.ogg", 25, 1)
	interact_particle(user,src)
	return

/turf/simulated/wall/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/spray_paint) || istype(W, /obj/item/gang_flyer))
		return

	if (istype(W, /obj/item/pen))
		var/obj/item/pen/P = W
		P.write_on_turf(src, user, params)
		return

	else if (istype(W, /obj/item/light_parts))
		src.attach_light_fixture_parts(user, W) // Made this a proc to avoid duplicate code (Convair880).
		return

	else if (isweldingtool(W))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		if(!W:try_weld(user, 5, burn_eyes = 1))
			return

		boutput(user, "<span class='notice'>Now disassembling the outer wall plating.</span>")

		sleep(10 SECONDS)

		if ((user.loc == T && user.equipped() == W))
			boutput(user, "<span class='notice'>You disassembled the outer wall plating.</span>")
			dismantle_wall()
		else if((isrobot(user) && (user.loc == T)))
			boutput(user, "<span class='notice'>You disassembled the outer wall plating.</span>")
			dismantle_wall()

//Spooky halloween key
	else if(istype(W,/obj/item/device/key/haunted))
		//Okay, create a temporary false wall.
		if(W:last_use && ((W:last_use + 300) >= world.time))
			boutput(user, "<span class='alert'>The key won't fit in all the way!</span>")
			return
		user.visible_message("<span class='alert'>[user] inserts [W] into [src]!</span>","<span class='alert'>The key seems to phase into the wall.</span>")
		W:last_use = world.time
		blink(src)
		new /turf/simulated/wall/false_wall/temp(src)
		return

//grabsmash
	else if (istype(W, /obj/item/grab/))
		var/obj/item/grab/G = W
		if  (!grab_smash(G, user))
			return ..(W, user)
		else return

	else
		if(src.material)
			var/fail = 0
			if(src.material.hasProperty("stability") && src.material.getProperty("stability") < 15) fail = 1
			if(src.material.quality < 0) if(prob(abs(src.material.quality))) fail = 1

			if(fail)
				user.visible_message("<span class='alert'>You hit the wall and it [getMatFailString(src.material.material_flags)]!</span>","<span class='alert'>[user] hits the wall and it [getMatFailString(src.material.material_flags)]!</span>")
				playsound(src, "sound/impact_sounds/Generic_Stab_1.ogg", 25, 1)
				del(src)
				return

		src.take_hit(W)
		//return attack_hand(user)

/turf/simulated/wall/r_wall
	name = "reinforced wall"
	desc = "Looks a lot tougher than a regular wall."
	icon = 'icons/turf/walls.dmi'
	icon_state = "r_wall"
	opacity = 1
	density = 1
	pathable = 0
	var/d_state = 0
	explosion_resistance = 7
	health = 300

	onMaterialChanged()
		..()
		if(istype(src.material))
			health = material.hasProperty("density") ? round(material.getProperty("density") * 4.5) : health
			if(src.material.material_flags & MATERIAL_CRYSTAL)
				health /= 2
		return

/turf/simulated/wall/r_wall/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/spray_paint) || istype(W, /obj/item/gang_flyer))
		return

	if (istype(W, /obj/item/pen))
		var/obj/item/pen/P = W
		P.write_on_turf(src, user, params)
		return

	else if (istype(W, /obj/item/light_parts))
		src.attach_light_fixture_parts(user, W) // Made this a proc to avoid duplicate code (Convair880).
		return

	else if (isweldingtool(W))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		if (src.d_state == 2)
			if(!W:try_weld(user,1,-1,1,1))
				return
			boutput(user, "<span class='notice'>Slicing metal cover.</span>")
			sleep(6 SECONDS)
			if ((user.loc == T && user.equipped() == W))
				src.d_state = 3
				boutput(user, "<span class='notice'>You removed the metal cover.</span>")
			else if((isrobot(user) && (user.loc == T)))
				src.d_state = 3
				boutput(user, "<span class='notice'>You removed the metal cover.</span>")

		else if (src.d_state == 5)
			if(!W:try_weld(user,1,-1,1,1))
				return
			boutput(user, "<span class='notice'>Removing support rods.</span>")
			sleep(10 SECONDS)
			if ((user.loc == T && user.equipped() == W))
				src.d_state = 6
				var/atom/A = new /obj/item/rods( src )
				if (src.material)
					A.setMaterial(src.material)
				else
					A.setMaterial(getMaterial("steel"))
				boutput(user, "<span class='notice'>You removed the support rods.</span>")
			else if((isrobot(user) && (user.loc == T)))
				src.d_state = 6
				var/atom/A = new /obj/item/rods( src )
				if (src.material)
					A.setMaterial(src.material)
				else
					A.setMaterial(getMaterial("steel"))
				boutput(user, "<span class='notice'>You removed the support rods.</span>")

	else if (iswrenchingtool(W))
		if (src.d_state == 4)
			var/turf/T = user.loc
			boutput(user, "<span class='notice'>Detaching support rods.</span>")
			playsound(src, "sound/items/Ratchet.ogg", 100, 1)
			sleep(4 SECONDS)
			if ((user.loc == T && user.equipped() == W))
				src.d_state = 5
				boutput(user, "<span class='notice'>You detach the support rods.</span>")
			else if((isrobot(user) && (user.loc == T)))
				src.d_state = 5
				boutput(user, "<span class='notice'>You detach the support rods.</span>")

	else if (issnippingtool(W))
		if (src.d_state == 0)
			playsound(src, "sound/items/Wirecutter.ogg", 100, 1)
			src.d_state = 1
			var/atom/A = new /obj/item/rods( src )
			if (src.material)
				A.setMaterial(src.material)
			else
				A.setMaterial(getMaterial("steel"))

	else if (isscrewingtool(W))
		if (src.d_state == 1)
			var/turf/T = user.loc
			playsound(src, "sound/items/Screwdriver.ogg", 100, 1)
			boutput(user, "<span class='notice'>Removing support lines.</span>")
			sleep(4 SECONDS)
			if ((user.loc == T && user.equipped() == W))
				src.d_state = 2
				boutput(user, "<span class='notice'>You removed the support lines.</span>")
			else if((isrobot(user) && (user.loc == T)))
				src.d_state = 2
				boutput(user, "<span class='notice'>You removed the support lines.</span>")

	else if (ispryingtool(W))
		if (src.d_state == 3)
			var/turf/T = user.loc
			boutput(user, "<span class='notice'>Prying cover off.</span>")
			playsound(src, "sound/items/Crowbar.ogg", 100, 1)
			sleep(10 SECONDS)
			if ((user.loc == T && user.equipped() == W))
				src.d_state = 4
				boutput(user, "<span class='notice'>You removed the cover.</span>")
			else if((isrobot(user) && (user.loc == T)))
				src.d_state = 4
				boutput(user, "<span class='notice'>You removed the cover.</span>")
		else if (src.d_state == 6)
			var/turf/T = user.loc
			boutput(user, "<span class='notice'>Prying outer sheath off.</span>")
			playsound(src, "sound/items/Crowbar.ogg", 100, 1)
			sleep(10 SECONDS)
			if ((user.loc == T && user.equipped() == W))
				boutput(user, "<span class='notice'>You removed the outer sheath.</span>")
				dismantle_wall()
				logTheThing("station", user, null, "dismantles a reinforced wall at [log_loc(user)].")
				return
			else if((isrobot(user) && (user.loc == T)))
				boutput(user, "<span class='notice'>You removed the outer sheath.</span>")
				dismantle_wall()
				logTheThing("station", user, null, "dismantles a reinforced wall at [log_loc(user)].")
				return

	//More spooky halloween key
	else if(istype(W,/obj/item/device/key/haunted))
		//Okay, create a temporary false wall.
		if(W:last_use && ((W:last_use + 300) >= world.time))
			boutput(user, "<span class='alert'>The key won't fit in all the way!</span>")
			return
		user.visible_message("<span class='alert'>[user] inserts [W] into [src]!</span>","<span class='alert'>The key seems to phase into the wall.</span>")
		W:last_use = world.time
		blink(src)
		var/turf/simulated/wall/false_wall/temp/fakewall = new /turf/simulated/wall/false_wall/temp(src)
		fakewall.was_rwall = 1
		return

	else if ((istype(W, /obj/item/sheet)) && (src.d_state))
		var/obj/item/sheet/S = W
		var/turf/T = user.loc
		boutput(user, "<span class='notice'>Repairing wall.</span>")
		sleep(10 SECONDS)
		if ((user.loc == T && user.equipped() == S))
			src.d_state = 0
			src.icon_state = initial(src.icon_state)
			if(S.material)
				src.setMaterial(S.material)
			else
				var/datum/material/M = getMaterial("steel")
				src.setMaterial(M)
			boutput(user, "<span class='notice'>You repaired the wall.</span>")
			if (S.amount > 1)
				S.amount--
			else
				qdel(W)
		else if((isrobot(user) && (user.loc == T)))
			src.d_state = 0
			src.icon_state = initial(src.icon_state)
			if(W.material) src.setMaterial(S.material)
			boutput(user, "<span class='notice'>You repaired the wall.</span>")
			if (S.amount > 1)
				S.amount--
			else
				qdel(W)

//grabsmash
	else if (istype(W, /obj/item/grab/))
		var/obj/item/grab/G = W
		if  (!grab_smash(G, user))
			return ..(W, user)
		else return

	if(istype(src, /turf/simulated/wall/r_wall) && src.d_state > 0)
		src.icon_state = "r_wall-[d_state]"

	if(src.material)
		var/fail = 0
		if(src.material.hasProperty("stability") && src.material.getProperty("stability") < 15) fail = 1
		if(src.material.quality < 0) if(prob(abs(src.material.quality))) fail = 1

		if(fail)
			user.visible_message("<span class='alert'>You hit the wall and it [getMatFailString(src.material.material_flags)]!</span>","<span class='alert'>[user] hits the wall and it [getMatFailString(src.material.material_flags)]!</span>")
			playsound(src.loc, "sound/impact_sounds/Generic_Stab_1.ogg", 25, 1)
			del(src)
			return

	src.take_hit(W)
	//return attack_hand(user)


/turf/simulated/wall/meteorhit(obj/M as obj)
	dismantle_wall()
	return 0

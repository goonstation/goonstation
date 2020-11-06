/obj/item/sword_core
	name = "SWORD core"
	desc = "An incredibly advanced power core created by the Syndicate."
	icon = 'icons/misc/retribution/SWORD_loot.dmi'
	icon_state = "engine_core"
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	w_class = 2.0
	throw_speed = 4
	throw_range = 20
	is_syndicate = 1
	contraband = 5

/obj/item/syndicate_destruction_system
	name = "Syndicate Destruction System"
	desc = "An unfinished melee weapon, the blueprints for which have been plundered from a raid on a now-destroyed Syndicate base."
	icon = 'icons/misc/retribution/SWORD_loot.dmi'
	icon_state = "SDS_empty"
	uses_multiple_icon_states = 1
	inhand_image_icon = 'icons/misc/retribution/SWORD_loot.dmi'
	item_state = "SDS_empty_inhands"
	hit_type = DAMAGE_BLUNT
	force = 1
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0	//Becomes 5.0 when the core is inserted.
	flags = FPRINT | TABLEPASS | NOSHIELD | USEDELAY
	tool_flags = TOOL_CUTTING  | TOOL_CHOPPING | TOOL_SAWING
	mats = 18
	is_syndicate = 1
	contraband = 10
	two_handed = 1
	stamina_damage = 5
	stamina_cost = 5
	stamina_crit_chance = 42
	var/core_inserted = false
	var/active_force = 50
	var/active_stamina_dmg = 50
	var/active_stamina_cost = 40
	var/inactive_force = 1
	var/inactive_stamina_dmg = 5
	var/inactive_stamina_cost = 5
	var/do_stun = 0
	var/cooldown = 0
	var/scan_center_x
	var/scan_center_y
	var/destruction_point_z
	var/datum/component/holdertargeting/simple_light/light

	New()
		..()
		light = src.AddComponent(/datum/component/holdertargeting/simple_light, 255, 250, 245, 150)
		light.update(0)
		src.setItemSpecial(/datum/item_special/simple)
		BLOCK_SETUP(BLOCK_ALL)

	attackby(obj/item/W, mob/user)
		if (isscrewingtool(W) && core_inserted)
			core_inserted = false
			user.put_in_hand_or_drop(new /obj/item/sword_core)
			icon = 'icons/misc/retribution/SWORD_loot.dmi'
			src.icon_state = "SDS_empty"
			src.item_state = "SDS_empty_inhands"
			src.setItemSpecial(/datum/item_special/simple)
			SET_BLOCKS(BLOCK_KNIFE)
			var/datum/component/holdertargeting/simple_light/light = src.GetComponent(/datum/component/holdertargeting/simple_light)
			light.update(0)
			force = inactive_force
			stamina_damage = inactive_stamina_dmg
			stamina_cost = inactive_stamina_cost
			
			user.show_message("<span class='notice'>You remove the SWORD core from the Syndicate Destruction System!</span>", 1)
			desc = "After a delay, scans nearby tiles, damaging walls and enemies. The core is missing."
			tooltip_rebuild = 1
			return
		else if ((istype(W,/obj/item/sword_core) && !core_inserted))
			core_inserted = true
			qdel(W)
			icon = 'icons/misc/retribution/48x32.dmi'
			src.icon_state = "SDS"
			src.item_state = "SDS_inhands"
			src.setItemSpecial(/datum/item_special/swipe)
			SET_BLOCKS(BLOCK_ALL)
			var/datum/component/holdertargeting/simple_light/light = src.GetComponent(/datum/component/holdertargeting/simple_light)
			light.update(1)
			force = active_force
			stamina_damage = active_stamina_dmg
			stamina_cost = active_stamina_cost

			user.show_message("<span class='notice'>You insert the SWORD core into the Syndicate Destruction System!</span>", 1)
			desc = "After a delay, scans nearby tiles, damaging walls and enemies. The core is installed."
			tooltip_rebuild = 1
			return

	attack_self(mob/user as mob)
		src.add_fingerprint(user)

		if(!core_inserted)
			boutput(user, "<span class='alert'><B>The system requires a unique power source to function!</B></span>")
			return
		else if(cooldown > world.time)
			boutput(user, "<span class='alert'><B>The system is still recharging!</B></span>")
			return
		boutput(user, "<span class='alert'><B>Scan initiated.</B></span>")
		icon = 'icons/misc/retribution/48x32.dmi'
		src.icon_state = "SDS_activated"
		cooldown = 5 SECONDS + world.time
		scan_center_x = user.loc.x
		scan_center_y = user.loc.y
		var/destruction_point_x
		var/destruction_point_y
		var/increment_x
		var/increment_y
		leavescan(user.loc, 0)
		destruction_point_z = user.loc.z
		spawn(16)
			if(core_inserted)
				icon = 'icons/misc/retribution/48x32.dmi'
				src.icon_state = "SDS"
			else
				icon = 'icons/misc/retribution/SWORD_loot.dmi'
				src.icon_state = "SDS_empty"

			for (increment_y = -1; increment_y <= 1; increment_y++)
				for (increment_x = -1; increment_x <= 1; increment_x++)
					if (increment_x == 0 && increment_y == 0)
						playsound(user.loc, 'sound/effects/shielddown.ogg', 50, 1)
					else
						destruction_point_x = scan_center_x + increment_x
						destruction_point_y = scan_center_y + increment_y
						destruction_sds(destruction_point_x, destruction_point_y,destruction_point_z)
		..()

	proc/destruction_sds(var/point_x, var/point_y, var/point_z)
		var/create_scan_decal = 0
		var/window_step = 0
		for (var/mob/M in locate(point_x,point_y,point_z))
			create_scan_decal++
			if (istype(M,/mob/living/silicon/robot))
				random_burn_damage(M, 15)
				M.changeStatus("stunned", 2 SECOND)
			else
				random_burn_damage(M, 30)
				M.changeStatus("weakened", 2 SECOND)
			INVOKE_ASYNC(M, /mob.proc/emote, "scream")
			playsound(M.loc, "sound/impact_sounds/burn_sizzle.ogg", 70, 1)
		var/turf/T = locate(point_x,point_y,point_z)
		if(!isfloor(T))
			create_scan_decal++
			T.ex_act(1)
			var/atom/new_floor
			switch(rand(1, 3))
				if(1)
					new_floor = new /turf/simulated/floor/plating/damaged1(locate(point_x,point_y,point_z))
				if(2)
					new_floor = new /turf/simulated/floor/plating/damaged2(locate(point_x,point_y,point_z))
				else
					new_floor = new /turf/simulated/floor/plating/damaged3(locate(point_x,point_y,point_z))
		for (var/obj/structure/girder/S in locate(point_x,point_y,point_z))
			create_scan_decal++
			S.ex_act(1)
		for (var/obj/grille/G in locate(point_x,point_y,point_z))
			create_scan_decal++
			window_step++
			G.ex_act(1)
		for (var/obj/window/W in locate(point_x,point_y,point_z))
			if(window_step == 0)
				create_scan_decal++
				W.ex_act(1)
		if(create_scan_decal != 0)
			leavescan(locate(point_x,point_y,point_z), 1)
			playsound(locate(point_x,point_y,point_z), 'sound/effects/smoke_tile_spread.ogg', 50, 1)
		return

/obj/decal/syndicate_destruction_scan_center
	name = "Scan"
	desc = "A glowing hologram, indicating the center of a scan."
	anchored = 1
	density = 0
	opacity = 0
	icon = null
	icon_state = null
	var/image/activation

	New()
		..()
		activation = image('icons/misc/retribution/SWORD_loot.dmi', "SDS_tile_activate")
		activation.plane = PLANE_SELFILLUM
		src.UpdateOverlays(activation, "activation")


/obj/decal/syndicate_destruction_scan_side
	name = "Scan"
	desc = "A hardlight hologram, hot to the touch."
	anchored = 1
	density = 0
	opacity = 0
	icon = null
	icon_state = null
	var/image/activation

	New()
		..()
		activation = image('icons/misc/retribution/SWORD_loot.dmi', "SDS_tile_scan")
		activation.plane = PLANE_SELFILLUM
		src.UpdateOverlays(activation, "activation")

// Salvager Gear

/obj/item/salvager
	name = "salvage reclaimer"
	desc = "A strange hodgepodge of industrial equipment used to break apart equipment and structures and reclaim the material.  A retractable crank acts as a great belt hook and recharging aid."
	icon = 'icons/obj/items/device.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "salvager"
	item_state = "salvager"
	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	force = 10.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	two_handed = 1
	w_class = W_CLASS_NORMAL
	m_amt = 50000
	stamina_damage = 15
	stamina_cost = 15
	stamina_crit_chance = 5
	inventory_counter_enabled = 1
	/// do we really actually for real want this to work in adventure zones?? just do this with varedit dont make children with this on
	var/really_actually_bypass_z_restriction = FALSE

	New()
		..()
		var/cell = new/obj/item/ammo/power_cell
		AddComponent(/datum/component/cell_holder, new_cell=cell, chargable=TRUE, max_cell=100, swappable=FALSE)
		RegisterSignal(src, COMSIG_UPDATE_ICON, /atom/proc/UpdateIcon)
		UpdateIcon()

	proc/get_welding_positions()
		var/start = list(-15,15)
		var/stop = list(15,-15)
		. = list(start,stop)

	update_icon()
		var/list/ret = list()
		if (SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			inventory_counter.update_percent(ret["charge"], ret["max_charge"])
		else
			inventory_counter.update_text("-")

	afterattack(atom/A, mob/user as mob)
		if ((isrestrictedz(user.z) || isrestrictedz(A.z)) && !src.really_actually_bypass_z_restriction)
			boutput(user, "\The [src] won't work here for some reason. Oh well!")
			return

		if (BOUNDS_DIST(get_turf(src), get_turf(A)) > 0)
			return
		else if (istype(A, /turf/simulated/wall))
			. = 20 SECONDS
			if (istype(A, /turf/simulated/wall/r_wall) || istype(A, /turf/simulated/wall/auto/reinforced))
				. += 5 SECONDS
			else if (istype(A, /turf/simulated/wall/auto/shuttle))
				return

			var/turf/simulated/wall/W = A
			. *= max(W.health/initial(W.health),0.1)

		else if (istype(A, /turf/simulated/floor))
			var/turf/simulated/floor/floor_turf = A
#ifdef UNDERWATER_MAP
			. = 45 SECONDS
#else
			. = 30 SECONDS
#endif
			if(floor_turf.broken)
				. -= 5 SECONDS
			if(!floor_turf.intact)
				. -= 5 SECONDS
		else if (istype(A, /obj/machinery/door/airlock)||istype(A, /obj/machinery/door/unpowered/wood))
			var/obj/machinery/door/airlock/AL = A
			if (AL.hardened == 1)
				boutput(user, SPAN_ALERT("\The [AL] is reinforced against deconstruction!"))
				return
			. = 30 SECONDS
		else if (istype(A, /obj/structure/girder))
			. = 10 SECONDS
		else if (istype(A, /obj/mesh/grille))
			. = 6 SECONDS
			var/obj/mesh/grille/the_grille = A
			. *= max(the_grille.health/the_grille.health_max,0.1)
		else if (istype(A, /obj/window))
			. = 10 SECONDS
		else if (istype(A, /obj/lattice))
			. = 5 SECONDS
		else if( isobj(A) )
			var/obj/O = A

			// Based on /obj/item/deconstructor/proc/afterattack()
			var/decon_complexity = O.build_deconstruction_buttons()
			if (!decon_complexity)
				boutput(user, SPAN_ALERT("[O] cannot be deconstructed."))
				return

			if (istext(decon_complexity))
				boutput(user, SPAN_ALERT("[decon_complexity]"))
				return

			if(locate(/mob/living) in O)
				boutput(user, SPAN_ALERT("You cannot deconstruct [O] while someone is inside it!"))
				return

			if (isrestrictedz(O.z) && !isitem(A))
				boutput(user, SPAN_ALERT("You cannot bring yourself to deconstruct [O] in this area."))
				return

			. += 5 SECONDS
			. += decon_complexity * 3 SECONDS
			boutput(user, "You start to destructively deconstruct [A].")

		if(user.traitHolder.hasTrait("carpenter") || user.traitHolder.hasTrait("training_engineer"))
			. = round(. * 0.75)

		if(.)
			. = max(., 2 SECONDS)
			icon_state = "salvager-on"
			item_state = "salvager-on"
			user.update_inhands()
			var/positions = src.get_welding_positions()
			actions.start(new /datum/action/bar/private/welding/salvage(user, A, ., /obj/item/salvager/proc/weld_action, \
				list(A, user), null, positions[1], positions[2], src),user)

	proc/weld_action(atom/A, mob/user as mob)
		icon_state = "salvager"
		item_state = "salvager"
		user.update_inhands()

		if (istype(A, /turf/simulated/wall/r_wall) || istype(A, /turf/simulated/wall/auto/reinforced))
			var/turf/simulated/wall/W = A
			W.dismantle_wall(prob(10))
			log_construction(user, "deconstructs a reinforced wall into a normal wall ([A])")
			return

		else if (istype(A, /turf/simulated/wall))
			var/turf/simulated/wall/W = A
			W.dismantle_wall(prob(33))
			log_construction(user, "deconstructs a wall ([A])")

		else if (istype(A, /turf/simulated/floor))
			var/turf/simulated/floor/F = A
			if (prob(50))
				var/atom/movable/B = new /obj/item/raw_material/scrap_metal
				B.set_loc(get_turf(A))
				if (F.material)
					B.setMaterial(F.material)
				else
					var/datum/material/M = getMaterial("steel")
					B.setMaterial(M)
			F.ReplaceWithSpace()
			log_construction(user, "removes flooring ([A])")

		else if (istype(A, /obj/machinery/door/airlock)||istype(A, /obj/machinery/door/unpowered/wood))
			for(var/i in 1 to 3)
				if (prob(50))
					var/atom/movable/B = new /obj/item/raw_material/scrap_metal
					B.set_loc(get_turf(A))
					if (A.material)
						B.setMaterial(A.material)
					else
						var/datum/material/M = getMaterial("steel")
						B.setMaterial(M)

			log_construction(user, "deconstructs an airlock ([A])")
			qdel(A)

		else if (istype(A, /obj/structure/girder))
			var/atom/movable/B = new /obj/item/raw_material/scrap_metal(get_turf(A))

			if (A.material)
				B.setMaterial(A.material)
			else
				var/datum/material/M = getMaterial("steel")
				B.setMaterial(M)

			log_construction(user, "deconstructs a girder ([A])")
			qdel(A)

		else if (istype(A, /obj/window))
			for(var/i in 1 to 3)
				var/atom/movable/B = new /obj/item/raw_material/shard(get_turf(A))
				if (A.material)
					B.setMaterial(A.material)
				else
					var/datum/material/M = getMaterial("glass")
					B.setMaterial(M)
			log_construction(user, "deconstructs a ([A])")
			qdel(A)

		else if (istype(A, /obj/mesh/grille))
			var/atom/movable/B
			if(prob(20))
				B = new /obj/item/raw_material/scrap_metal(get_turf(A))

				if (A.material)
					B.setMaterial(A.material)
				else
					var/datum/material/M = getMaterial("steel")
					B.setMaterial(M)

			log_construction(user, "deconstructs a grille ([A])")
			qdel(A)

		else if (istype(A, /obj/lattice))
			var/atom/movable/B = new /obj/item/raw_material/scrap_metal
			B.set_loc(get_turf(A))
			if (A.material)
				B.setMaterial(A.material)
			else
				var/datum/material/M = getMaterial("steel")
				B.setMaterial(M)
			log_construction(user, "deconstructs a lattice ([A])")
			qdel(A)
		else if(isobj(A))
			var/obj/O = A
			if(O.deconstruct_flags)
				var/atom/movable/B
				var/scrap = 1
				scrap += HAS_ALL_FLAGS( O.deconstruct_flags, DECON_SCREWDRIVER)
				scrap += HAS_ALL_FLAGS( O.deconstruct_flags, DECON_WRENCH)
				scrap += HAS_ALL_FLAGS( O.deconstruct_flags, DECON_CROWBAR)
				scrap += HAS_ALL_FLAGS( O.deconstruct_flags, DECON_WELDER) * 2
				if(O.deconstruct_flags & DECON_WIRECUTTERS)
					new /obj/item/cable_coil/cut/small(get_turf(A))
				for(var/i in 1 to scrap)
					B = new /obj/item/raw_material/scrap_metal(get_turf(A))
					if (A.material)
						B.setMaterial(A.material)
					else
						var/datum/material/M = getMaterial("steel")
						B.setMaterial(M)
				log_construction(user, "deconstructs a ([A])")
				qdel(A)

	proc/log_construction(mob/user as mob, var/what)
		logTheThing(LOG_STATION, user, "[what] using \the [src] at [user.loc.loc] ([log_loc(user)])")

	proc/use_power(watts)
		if(watts == 0 || !(SEND_SIGNAL(src, COMSIG_CELL_USE, watts) & CELL_INSUFFICIENT_CHARGE))
			. = TRUE

	proc/check_power(watts)
		if(watts == 0 || !(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, watts) & CELL_INSUFFICIENT_CHARGE))
			return TRUE

/datum/action/bar/private/welding/salvage

	onUpdate()
		if(QDELETED(target))
			interrupt(INTERRUPT_ALWAYS)
			return
		..()
		if(istype(target, /turf/simulated/wall))
			var/turf/simulated/wall/W = target
			W.health -= 5
			if (istype(W, /turf/simulated/wall/r_wall) || istype(W, /turf/simulated/wall/auto/reinforced))
				W.health -= 5
		else if(istype(target, /obj/mesh/grille))
			var/obj/mesh/grille/the_grille = target
			the_grille.health -= 5

		var/obj/item/salvager/S = src.call_proc_on
		if(istype(S))
			if(!S.use_power(1))
				resumable = FALSE
				interrupt(INTERRUPT_ALWAYS)
				boutput(owner,"\The [S] is out of power!")

		if(!ON_COOLDOWN(S,"welding_sound", rand(5 SECONDS, 10 SECONDS)))
			playsound(owner, list('sound/items/Welder.ogg', 'sound/items/Welder2.ogg')[1], 20, 1)

	onDelete()
		var/obj/item/salvager/S = src.call_proc_on
		if(istype(S))
			S.icon_state = "salvager"
			S.item_state = "salvager"
			var/mob/M = owner
			if(istype(M))
				M.update_inhands()
		..()


/obj/item/weldingtool/arcwelder
	name = "arc welder"
	desc = "A tool that, when turned on, uses electricity to emit a concentrated arc, welding metal together or slicing it apart."
	icon = 'icons/obj/items/tools/weldingtool.dmi'
	inhand_image_icon = 'icons/mob/inhand/tools/weldingtool.dmi'
	wear_image_icon = null // TODO: replace with a belt icon
	icon_state = "arcwelder-off"
	item_state = "arcwelder-off"
	inventory_counter_enabled = TRUE
	var/charge_to_fuel = 7

	New()
		..()
		var/cell = new/obj/item/ammo/power_cell/self_charging{charge = 100; max_charge = 100; recharge_rate = 4}
		AddComponent(/datum/component/cell_holder, new_cell=cell, chargable=TRUE, max_cell=500, swappable=FALSE)
		src.setItemSpecial(/datum/item_special/spark/arcwelder)
		RegisterSignal(src, COMSIG_UPDATE_ICON, /atom/proc/UpdateIcon)
		UpdateIcon()

	examine()
		return

	afterattack(obj/O, mob/user)
		if (src.welding)
			use_fuel((ismob(O) || istype(O, /obj/blob) || istype(O, /obj/critter)) ? 2 : 0.2)
			if (get_fuel() <= 0)
				src.set_state(on = FALSE, user = user)
			var/turf/location = user.loc
			if (istype(location, /turf))
				location.hotspot_expose(700, 50, 1)
			if (O && !ismob(O) && O.reagents)
				boutput(user, SPAN_NOTICE("You heat \the [O.name]."))
				O.reagents.temperature_reagents(4000,50, 100, 100, 1)

	attackby(obj/item/I, mob/user)
		return

	get_fuel()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			. = ret["charge"] / charge_to_fuel

	use_fuel(var/amount)
		amount = min(get_fuel(), amount)
		amount *= src.charge_to_fuel
		SEND_SIGNAL(src, COMSIG_CELL_USE, amount)

	process()
		..()
		if(welding)
			use_fuel(1)
			if (!get_fuel())
				src.set_state(on = FALSE, user = ismob(src.loc) ? src.loc : null)

	try_weld(mob/user, var/fuel_amt = 2, var/use_amt = -1, var/noisy=1, var/burn_eyes=1)
		if (src.welding)
			if(use_amt == -1)
				use_amt = fuel_amt
			if (src.get_fuel() < fuel_amt)
				boutput(user, SPAN_NOTICE("Need more energy!"))
				return FALSE //welding, doesnt have fuel
			src.use_fuel(use_amt)
			if(noisy)
				playsound(user.loc, list('sound/effects/welding_arc.ogg'), 50, 1)
			if(burn_eyes)
				src.eyecheck(user)
			return TRUE //welding, has fuel
		return FALSE //not welding

	firesource_interact()
		return

	set_state(on, mob/user)
		if (src.welding != on)
			src.welding = on
			if (src.welding)
				if (get_fuel() <= 0)
					boutput(user, SPAN_NOTICE("Need more fuel!"))
					src.welding = FALSE
					return FALSE
				boutput(user, SPAN_NOTICE("You will now weld when you attack."))
				src.force = 25
				hit_type = DAMAGE_BURN
				set_icon_state("arcwelder-on")
				src.item_state = "arcwelder-on"
				processing_items |= src
				if(user && !ON_COOLDOWN(src, "playsound", 1.5 SECONDS))
					playsound(src.loc, 'sound/effects/welderarc_ignite.ogg', 65, 1)
				SEND_SIGNAL(src, COMSIG_LIGHT_ENABLE)
			else
				boutput(user, SPAN_NOTICE("Not welding anymore."))
				src.force = 3
				hit_type = DAMAGE_BLUNT
				set_icon_state("arcwelder-off")
				src.item_state = "arcwelder-off"
				SEND_SIGNAL(src, COMSIG_LIGHT_DISABLE)
		if(istype(user))
			user.update_inhands()

	update_icon()
		var/list/ret = list()
		if (SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			inventory_counter.update_percent(ret["charge"], ret["max_charge"])
		else
			inventory_counter.update_text("-")


/datum/item_special/spark/arcwelder
	cooldown = 1.5 SECONDS

	pixelaction(atom/target, params, mob/user, reach)
		var/fuel_cost = 2
		// ITEMSPECIAL_PIXELDIST_SQUARED
		if(!istype(master, /obj/item/weldingtool/arcwelder) || get_dist_pixel_squared(user, target, params) <= (70 * 70) ) return
		var/obj/item/weldingtool/arcwelder/ARC = master
		if (!ARC.welding) return
		if ( ARC.get_fuel() < ( fuel_cost * 1.1 ) )
			playsound(master, 'sound/weapons/Gunclick.ogg', 50, 0, 0.1, 2)
			return
		if(..())
			ARC.use_fuel(fuel_cost)

/obj/item/storage/box/salvager_frame_compartment
	name = "electronics frame compartment"
	desc = "A special compartment designed to neatly and safely store deconstructed electronics and machinery frames."
	max_wclass = W_CLASS_HUGE
	can_hold = list(/obj/item/electronics/frame)
	slots = 8

	attack_hand(mob/user)
		if (src.stored)
			src.stored.hide_hud(user)
			// in case its somehow attacked without opening where its stored
			if (user.s_active)
				user.detach_hud(user.s_active)
				user.s_active = null
			src.storage.show_hud(user)
		else
			. = ..()

/obj/item/storage/backpack/salvager
	name = "salvager rucksack"
	desc = "A repurposed military backpack made of high density fabric, designed to fit a wide array of tools and junk."
	icon_state = "tactical_backpack"
	spawn_contents = list()
	slots = 10
	can_hold = list(/obj/item/electronics/frame, /obj/item/salvager)
	check_wclass = 1
	color = "#ff9933"
	satchel_compatible = FALSE

/obj/item/device/radio/headset/salvager
	protected_radio = 1 // Ops can spawn with the deaf trait.

/obj/item/device/powersink/salvager
	desc = "A nulling power sink which drains energy from electrical systems.  Installed with high capacity cells to steal away power."
	drain_rate = 45000		// amount of power to drain per tick
	max_power = 2e7		// maximum power that can be drained before exploding
	color = list(1,0,0,-0.00168067,0.998559,0.00168067,0.213445,0.182953,0.786555)

	New()
		. = ..()
		light.set_brightness(1.5)

	get_desc(dist)
		if(dist <= 1)
			var/ratio = round(src.power_drained / src.max_power * 100, 2)
			. += " The display indicates [engineering_notation(power_drained)]W and [ratio]% capacity."

	process()
		var/previous_drain_rate = drain_rate
		//... decentivize non-station power...
		if(!istype(get_area(src), /area/station))
			src.light.set_color(0.5, 0.2, 0.2)
			drain_rate *= 0.3
		else
			src.light.set_color(1, 1, 1)
		. = ..()
		if(attached)
			var/datum/powernet/PN = attached.get_powernet()
			if(PN)
				if(!ON_COOLDOWN(src,"noise",rand(1 SECOND, 5 SECONDS)))
					playsound(src,'sound/machines/engine_highpower.ogg', 70, 1, 3, -2)
		drain_rate = previous_drain_rate


/obj/item/deployer/barricade/barbed
	name = "barbed barricade deployer"
	object_type = /obj/barricade/barbed

	New()
		. = ..()
		var/overlay = image(src.icon_state, "b_sharp")
		UpdateOverlays(overlay, "barb")

/obj/item/deployer/barricade/barbed/wire
	name = "barbed wire segment"
	desc = "A coiled up length of barbed wire that can be used to make some kind of barricade."
	icon_state = "barbed_wire"
	amount = 3
	inventory_counter_enabled = TRUE
	object_type = /obj/barricade/barbed/wire
	build_duration = 1.5 SECONDS

	deploy(mob/user as mob, turf/T as turf)
		. = ..()
		if(.)
			var/obj/barricade/B = .
			B.dir = user.dir

/obj/item/breaching_hammer/salvager
	name = "battered breaching sledgehammer"
	desc = "A heavy metal hammer designed to crumple space stations. And crumple just about anything else too."
	color = list(2.15523,3.9902,-1.72794,-1.54738,-3.42157,2.1152,0.654062,0.621849,0.422269)

	click_delay = 25
	force = 25 //this number is multiplied by 4 when attacking doors.
	stamina_damage = 60
	stamina_cost = 25

/obj/item/gun/kinetic/pumpweapon/riotgun/salvager
	name = "reclaimed shotgun"
	desc = "A pump action shotgun."
	gildable = FALSE
	max_ammo_capacity = 4
	color = list(1.47114,0.473684,-0.473684,-1.4581,-0.473684,1.47368,0.983451,1,5.43476e-007)

	New()
		..()
		ammo.amount_left = 0


/obj/item/gun/energy/makeshift/basic_salvager // for salvagers

	New()
		..()
		var/obj/item/cell/charged/C = new /obj/item/cell/charged
		C.UpdateIcon() // fix visual bug
		src.attach_cell(C)
		var/obj/item/light/tube/T = new /obj/item/light/tube/yellowish
		src.attach_light(T)

/obj/item/storage/grenade_pouch/salvager_distract
	spawn_contents = list(/obj/item/old_grenade/smoke=3,/obj/item/chem_grenade/flashbang = 2)

TYPEINFO(/obj/item/salvager_hand_tele)
	mats = list("MET-1" = 5, "POW-1"=5, "CON-2" = 5, "telecrystal" = 30)

/obj/item/salvager_hand_tele
	name = "makeshift teleporter"
	desc = "A questionable portable teleportation device that is coupled to a specific location."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "hand_tele_s"
	item_state = "electronic"
	throwforce = 5
	health = 5
	w_class = W_CLASS_SMALL
	c_flags = ONBELT
	throw_speed = 3
	throw_range = 5
	m_amt = 10000
	var/charges = 3
	var/image/indicator
	var/image/indicator_light

	New()
		..()
		indicator = image(src.icon, "hand_tele_o")
		indicator_light = image(src.icon, "hand_tele_o", layer=LIGHTING_LAYER_BASE)
		indicator_light.blend_mode = BLEND_ADD
		indicator_light.plane = PLANE_LIGHTING
		indicator_light.color = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5)
		UpdateIcon()

	update_icon()
		if(charges)
			src.UpdateOverlays(indicator, "indicator")
		else
			src.UpdateOverlays(null, "indicator")

	get_desc(dist)
		if(dist < 1)
			. += " The display indicates that there are [charges] charges remaining and there is small hole that telecrystals can inserted on the side."

	attack_self(mob/user)
		. = ..()
		if(user.mind.get_antagonist(ROLE_SALVAGER))
			if(length(landmarks[LANDMARK_SALVAGER_TELEPORTER]))
				actions.start(new /datum/action/bar/private/salvager_tele(user, src), user)
			else
				boutput(user, SPAN_ALERT("Something is wrong..."))
		else
			var/results = rand(1,10)
			switch( results )
				if(1 to 5)
					boutput(user, SPAN_ALERT("You can't make any sense of this device.  Maybe it isn't for you."))
				if(6 to 8)
					boutput(user, SPAN_ALERT("\the [src] screen flashes momentarily before discharing a shock."))
					user.shock(src, 2500, "chest", 1, 1)
					user.changeStatus("stunned", 3 SECONDS)
				if(9 to 10)
					boutput(user, SPAN_ALERT("[src] gets really hot... and explodes?!?"))
					elecflash(src)
					user.u_equip(src)
					qdel(src)

	attackby(obj/item/W, mob/user, params)
		if(istype(W, /obj/item/raw_material/telecrystal))
			if(charges < 5)
				boutput(user, SPAN_ALERT("You gently place \the [W] into a small receptical on the side of \the [src]."))
				user.u_equip(W)
				qdel(W)
				charges++
				src.UpdateIcon()
			else
				boutput(user, SPAN_ALERT("You can't quite seem to get \the [W] into \the [src].  There are already enough crystals inside."))
		else
			..()

/datum/action/bar/private/salvager_tele
	duration = 6 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED
	var/mob/target
	var/obj/item/salvager_hand_tele/device

	New(Target, Device)
		target = Target
		device = Device
		..()

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		if(prob(25))
			elecflash(device)

	onStart()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		playsound(owner.loc, 'sound/machines/click.ogg', 60, 1)

	onEnd()
		..()
		var/turf/destination = pick(landmarks[LANDMARK_SALVAGER_TELEPORTER])
		animate_teleport(target)
		target.emote("scream")
		SPAWN(6 DECI SECONDS)
			showswirl(target)
			target.set_loc(destination)
			showswirl(target)
			elecflash(src)
			device.charges--
			device.UpdateIcon()
			if(device.charges <= 0)
				if(prob(33))
					boutput(target, SPAN_ALERT("\The [device] disintegrates!  Well, I guess there are more where that came from."))
					target.u_equip(device)
					qdel(device)
				else
					boutput(target, SPAN_ALERT("\The [device] lights stop flashing!  Must need more fuel?"))

/obj/item/clothing/glasses/salvager
	name = "\improper S.A.V. goggles"
	icon_state = "salvager"
	item_state = "salvager"
	desc = "The Salvager Appraisal Visualizer is latest in value viewing technology!."

	equipped(var/mob/user, var/slot)
		..()
		if (slot == SLOT_GLASSES)
			get_image_group(CLIENT_IMAGE_GROUP_SALVAGER_VALUES).add_mob(user)

	unequipped(var/mob/user)
		if(src.equipped_in_slot == SLOT_GLASSES)
			get_image_group(CLIENT_IMAGE_GROUP_SALVAGER_VALUES).remove_mob(user)
		..()

/obj/item/device/radio_upgrade/salvager
	name = "private radio channel upgrade"
	desc = "A device capable of communicating over a private secure radio channel. Can be installed in a radio headset."
	secure_frequencies = null
	secure_classes = null

	pickup(mob/user)
		. = ..()
		if(secure_frequencies || secure_classes)
			return
		var/datum/antagonist/salvager/SA = user?.mind?.get_antagonist(ROLE_SALVAGER)
		if(SA)
			var/salv_freq = SA.pick_radio_freq()
			src.secure_frequencies = list("z" = salv_freq)
			src.secure_classes = list(RADIOCL_OTHER)


/obj/salvager_putt_spawner
	name = "syndiputt spawner"
	icon = 'icons/obj/ship.dmi'
	icon_state = "syndi_mini_spawn"
	New()
		..()
#ifdef UNDERWATER_MAP
		new/obj/machinery/vehicle/tank/minisub/salvsub(src.loc)
#else
		new/obj/machinery/vehicle/miniputt/armed/salvager(src.loc)
#endif
		qdel(src)

/obj/machinery/vehicle/tank/minisub/salvsub
	body_type = "minisub"
	icon_state = "whitesub_body"
	health = 150
	maxhealth = 150
	acid_damage_multiplier = 0.5
	init_comms_type = /obj/item/shipcomponent/communications/salvager
	color = list(-0.269231,0.75,3.73077,0.269231,-0.249999,-2.73077,1,0.5,0)

	New()
		..()
		name = "salvager minisub"
		Install(new /obj/item/shipcomponent/mainweapon/taser(src))
		Install(new /obj/item/shipcomponent/secondary_system/cargo(src))
		Install(new /obj/item/shipcomponent/secondary_system/lock/bioscan(src))

// MAGPIE Equipment
/obj/machinery/vehicle/miniputt/armed/salvager
	desc = "A repeatedly rebuilt and refitted pod.  Looks like it has seen some things."
	color = list(-0.269231,0.75,3.73077,0.269231,-0.249999,-2.73077,1,0.5,0)
	init_comms_type = /obj/item/shipcomponent/communications/salvager

	health = 250
	maxhealth = 250
	armor_score_multiplier = 0.7
	speed = 0.85

	New()
		..()
		src.lock = new /obj/item/shipcomponent/secondary_system/lock/bioscan(src)
		src.lock.ship = src
		src.components += src.lock
		myhud.update_systems()
		myhud.update_states()

/datum/manufacture/pod/armor_light/salvager
	name = "Salvager Pod Armor"
	item_requirements = list("metal_dense" = 30,
							 "conductive" = 20)
	item_outputs = list(/obj/item/podarmor/salvager)
	create = 1
	time = 20 SECONDS
	category = "Component"

/obj/item/podarmor/salvager
	name = "Salvager Pod Armor"
	desc = "Exterior plating for vehicle pods."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"
	vehicle_types = list("/obj/structure/vehicleframe/puttframe" = /obj/machinery/vehicle/miniputt/armed/salvager,
						 "/obj/structure/vehicleframe/subframe" = /obj/machinery/vehicle/tank/minisub/salvsub )

/obj/item/shipcomponent/communications/salvager
	name = "Salvager Communication Array"
	desc = "A rats nest of cables and extra parts fashioned into a shipboard communicator."
	color = "#91681c"
	access_type = list(POD_ACCESS_SALVAGER)

	go_home()
		var/escape_planet
#ifdef UNDERWATER_MAP
		escape_planet = !isrestrictedz(ship.z)
#else
		escape_planet = !isnull(station_repair.station_generator) && (ship.z == Z_LEVEL_STATION)
#endif

		if(!escape_planet)
			return

		var/turf/target = get_home_turf()
		if(!src.active)
			boutput(usr, "[ship.ship_message("Sensors inactive! Unable to calculate trajectory!")]")
			return TRUE
		if(!target)
			boutput(usr, "[ship.ship_message("Sensor error! Unable to calculate trajectory!")]")
			return TRUE

		if(ship.engine.active)
			if(ship.engine.ready)
				//brake the pod, we must stop to calculate warp trajectory.
				if (istype(ship.movement_controller, /datum/movement_controller/pod))
					var/datum/movement_controller/pod/MCP = ship.movement_controller
					if (MCP.velocity_x != 0 || MCP.velocity_y != 0)
						boutput(usr, "[ship.ship_message("Ship must have ZERO relative velocity to calculate trajectory to destination!")]")
						playsound(src, 'sound/machines/buzz-sigh.ogg', 50)
						return TRUE
				else if (istype(ship.movement_controller, /datum/movement_controller/tank))
					var/datum/movement_controller/tank/MCT = ship.movement_controller
					if (MCT.input_x != 0 || MCT.input_y != 0)
						boutput(usr, "[ship.ship_message("Ship must have ZERO relative velocity (be stopped) to calculate trajectory destination!")]")
						playsound(src, 'sound/machines/buzz-sigh.ogg', 50)
						return TRUE


				ship.engine.warp_autopilot = 1
				boutput(usr, "[ship.ship_message("Charging engines for escape velocity! Overriding manual control!")]")

				var/health_perc = ship.health_percentage
				ship.going_home = FALSE
				sleep(5 SECONDS)

				if(ship.health_percentage < (health_perc - 30))
					boutput(usr, "[ship.ship_message("Trajectory calculation failure! Ship characteristics changed from calculations!")]")
				else if(ship.engine.active && ship.engine.ready && src.active)
					var/old_color = ship.color
					animate_teleport(ship)
					sleep(0.8 SECONDS)
					ship.set_loc(target)
					ship.color = old_color // revert color from teleport color-shift
				else
					boutput(usr, "[ship.ship_message("Trajectory calculation failure! Loss of systems!")]")

				ship.engine.ready = 0
				ship.engine.warp_autopilot = 0
				ship.engine.ready()
			else
				boutput(usr, "[ship.ship_message("Engine recharging! Unable to minimize trajectory error!")]")
		else
			boutput(usr, "[ship.ship_message("Engines inactive! Unable to calculate trajectory!")]")

		return TRUE

	get_home_turf()
		if((POD_ACCESS_SALVAGER in src.access_type) && length(landmarks[LANDMARK_SALVAGER_BEACON]))
			. = pick(landmarks[LANDMARK_SALVAGER_BEACON])





// Stubs for the public
/obj/item/clothing/suit/space/salvager
/obj/item/clothing/head/helmet/space/engineer/salvager
/obj/salvager_cryotron
/obj/item/salvager_hand_tele
/obj/item/device/pda2/salvager


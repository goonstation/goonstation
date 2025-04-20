/datum/abilityHolder/silicon/ai
	var/datum/targetable/ai/module/camera_gun/active_camera_gun

	updateButtons(var/called_by_owner = 0, var/start_x = 2, var/start_y = 0)
		. = ..()
/datum/targetable/ai
	preferred_holder_type = /datum/abilityHolder/silicon/ai
	icon = 'icons/mob/hud_ai.dmi'

	castcheck(atom/target)
		. = TRUE
		var/mob/living/silicon/ai/AI = holder.owner
		if(istype(AI))
			if (!AI.deployed_to_eyecam)
				boutput(holder.owner, "Deploy to an AI Eye first to do that.")
				. = FALSE
				return

	cast(atom/target)
		. = ..()
		if(.)
			return

		var/turf/T = get_turf(target)
		if(src.targeted)
			if (!istype(T) || !istype(T.cameras) || !length(T.cameras))
				boutput(holder.owner, "No camera available to target that location.")
				. = FALSE
				return 1

	proc/get_law_module()
		var/mob/living/silicon/ai/AI
		if(istype(holder.owner,/mob/living/silicon/ai))
			AI = holder.owner
		else if(istype(holder.owner, /mob/living/intangible/aieye))
			var/mob/living/intangible/aieye/Aeye = holder.owner
			AI = Aeye.mainframe

		if(istype(AI))
			var/obj/machinery/lawrack/law_rack = AI.law_rack_connection
			for (var/i in 1 to law_rack.MAX_CIRCUITS)
				var/obj/item/aiModule/ability_expansion/expansion = law_rack.law_circuits[i]
				if(istype(expansion))
					if(src.type in expansion.ai_abilities)
						return expansion

/datum/targetable/ai/module
	icon_state = "ai_template"

	castcheck(atom/target)
		. = ..()
		if(.)
			var/obj/item/aiModule/ability_expansion/expansion = get_law_module()
			if(expansion)
				if (expansion.last_use > world.time)
					boutput(holder.owner, SPAN_ALERT("The source module is on cooldown for [round((expansion.last_use - world.time) / 10)] seconds."))
					return FALSE

	doCooldown()
		..()
		var/obj/item/aiModule/ability_expansion/expansion = get_law_module()
		if(expansion)
			expansion.last_use = world.time + expansion.shared_cooldown

	proc/can_shoot_to(obj/machinery/camera/C, turf/target, atom/A, max_length=10)

		if(isnull(A))
			A = new /obj/projectile
		var/turf/current = get_turf(C)
		var/turf/target_turf = get_turf(target)
		var/turf/next = get_step_towards(current, target_turf)
		var/steps = 0

		while(next != target_turf)
			if (steps > max_length) return 0
			if (!next) return 0
			if(!jpsTurfPassable(next, source=current, passer=A))
				return 0

			current = next
			next = get_step_towards(next, target_turf)
			steps++

		return 1

/datum/targetable/ai/module/chems
	targeted = TRUE
	target_anything = 1
	var/obj/item/thrown_reagents/reagent_capsule

	cast(atom/target)
		if (..())
			return 1

		if(!ispath(reagent_capsule))
			boutput(holder.owner, SPAN_ALERT("Something appears to be wrong with the chem module... Call 1-800-CODER."))
			return 1

		var/turf/T = get_turf(target)
		for(var/obj/machinery/camera/cam in T.cameras)
			if(!isturf(cam.loc) || !istype_exact(cam,/obj/machinery/camera))
				continue

			if(!can_shoot_to(cam, T, max_length=15))
				continue

			if(!ON_COOLDOWN(cam,"[src.type]", 15 SECONDS))
				var/obj/decal/D = new/obj/decal(cam.loc)

				D.set_dir(get_dir(cam,target))
				D.name = "metal foam spray"
				D.icon = 'icons/obj/chemical.dmi'
				D.icon_state = "chempuff"
				D.layer = EFFECTS_LAYER_BASE

				playsound(cam, 'sound/machines/mixer.ogg', 50, TRUE)

				logTheThing(LOG_COMBAT, holder.owner, "[key_name(holder.owner)] fires [src.name], creating metal foam at [log_loc(T)].")

				var/obj/foam = new reagent_capsule(get_turf(cam))
				foam.throw_at(target, 10, 1)

				SPAWN(1 SECOND)
					step_towards(D, get_step(D, D.dir))
					cam.visible_message(SPAN_ALERT("[cam] spews out a metalic foam!"))
					sleep(1 SECOND)
					D.dispose()
				return

		boutput(holder.owner, SPAN_ALERT("Unable to calculate valid shot from available camera."))
		return 1

/datum/targetable/ai/module/chems/metal_foam
	name = "Spray Metal Foam"
	desc = "Launches a small stream of metal foam from the camera."
	icon_state = "camera_foam"
	targeted = TRUE
	target_anything = 1
	reagent_capsule = /obj/item/thrown_reagents/metal_foam

/obj/item/thrown_reagents
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "ballwhite"
	var/list/reagent_list

	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		var/datum/effects/system/foam_spread/s = new()
		s.set_up(5, get_turf(hit_atom), reagent_list, 1) // Aborts if reagent list is null (even for metal foam), but I'm not gonna touch foam_spread.dm (Convair880).
		s.start()
		qdel(src)

/obj/item/thrown_reagents/metal_foam
	color = "#999"
	reagent_list = list("iron" = 3, "fluorosurfactant" = 1, "acid" = 1)

/datum/targetable/ai/module/camera_gun
	name = "Camera Lasers"
	desc = "Makes nearby cameras shoot lasers at the target. Somehow."
	targeted = TRUE
	target_anything = 1
	var/datum/projectile/P
	var/projectile_cd = 10 SECONDS
	var/charge_color = rgb(255,0,0)
	var/charge_time = 1.5 SECONDS

	onAttach(datum/abilityHolder/H)
		. = ..()
		var/datum/abilityHolder/silicon/ai/AIH = H
		if(istype(AIH))
			AIH.active_camera_gun = src

	cast(atom/target)
		if (..())
			return 1

		if(ispath(P))
			P = new P()

		var/camera_on_cd = FALSE
		var/turf/T = get_turf(target)

		var/obj/projectile/test_projectile = new
		test_projectile.proj_data = P

		for(var/obj/machinery/camera/cam in T.cameras)
			if(!isturf(cam.loc))
				continue

			if(istype(cam, /mob/living/silicon/hivebot/eyebot))
				if (issilicon(cam))
					var/mob/living/silicon/S = cam
					if(S?.cell.charge < P.cost)
						continue
			else if(!istype_exact(cam,/obj/machinery/camera))
				continue

			if(!can_shoot_to(cam, T, test_projectile, max_length=15))
				continue

			if(!ON_COOLDOWN(cam,"[src.type]", src.projectile_cd))
				cam.add_filter("charge_outline", 0, outline_filter(size=0, color=charge_color))
				animate(cam.get_filter("charge_outline"), size=0.5, time=charge_time)
				SPAWN(charge_time)
					logTheThing(LOG_COMBAT, holder.owner, "[key_name(holder.owner)] fires a camera projectile [src.name], targeting [key_name(target)] [log_loc(target)].")
					shoot_projectile_ST_pixel_spread(cam, P, target)
					if(P.cost > 1)
						if (issilicon(cam))
							var/mob/living/silicon/S = cam
							if (S.cell)
								S.cell.use(P.cost)
						else
							cam.use_power(P.cost / CELLRATE)
					cam.remove_filter("charge_outline")
				return
			else
				camera_on_cd = TRUE

		if(camera_on_cd)
			boutput(holder.owner, SPAN_ALERT("Available camera is still cooling down..."))
		else
			boutput(holder.owner, SPAN_ALERT("Unable to calculate valid shot from available camera."))
		return 1


/datum/targetable/ai/module/camera_gun/taser
	name = "Camera Taser"
	icon_state = "camera_taser"
	P = /datum/projectile/energy_bolt
	charge_color = rgb(217, 255, 0)

/datum/targetable/ai/module/camera_gun/laser
	name = "Camera Laser"
	icon_state = "camera_laser"
	P = /datum/projectile/laser/light/tracer



/datum/targetable/ai/module/teleport
	targeted = TRUE
	target_anything = 1

	castcheck(atom/target)
		. = ..()
		if(.)
			if(!get_first_teleporter())
				boutput(holder.owner, SPAN_ALERT("No valid telepad found on data network."))
				return FALSE
			else  if(target.z != Z_LEVEL_STATION)
				boutput(holder.owner, SPAN_ALERT("Module only calibrated for nearby station travel."))
				return FALSE

	doCooldown()
		var/since_last_cast = world.time - src.last_cast
		var/cd_penalty_chance = clamp(src.cooldown * 2 - (since_last_cast), 0, 10)
		..()
		if(prob(cd_penalty_chance))
			boutput(holder.owner, SPAN_ALERT("Expansion module registers an error that must be adjusted for."))
			src.last_cast += src.cooldown

	proc/get_first_teleporter()
		var/mob/living/silicon/ai/AI
		if(istype(holder.owner,/mob/living/silicon/ai))
			AI = holder.owner
		else if(istype(holder.owner, /mob/living/intangible/aieye))
			var/mob/living/intangible/aieye/Aeye = holder.owner
			AI = Aeye.mainframe

		if(istype(AI))
			var/datum/powernet/PN = AI.link.get_direct_powernet()
			for(var/obj/machinery/power/data_terminal/DT in PN.data_nodes)
				var/obj/machinery/networked/telepad/telepad = DT.master
				if(!istype(telepad) || telepad.status & (NOPOWER|BROKEN) || !telepad.link)
					continue
				else
					return telepad

	send
		name = "Telepad: Send"
		desc = "Send current telepad contents to the destination."
		icon_state = "tele_tx"

		cast(atom/target)
			if (..())
				return 1

			var/turf/T = get_turf(target)

			if (istype(T, /turf/space) )
				boutput(holder.owner, SPAN_ALERT("Module inhibits teleportation into space."))
				return 1
			else if (!checkTurfPassable(T))
				boutput(holder.owner, SPAN_ALERT("Module inhibits teleportation solid or poorly accessable areas."))
				return 1

			var/datum/gas_mixture/environment = T.return_air()
			var/env_pressure = MIXTURE_PRESSURE(environment)
			if(env_pressure <= 0.15*ONE_ATMOSPHERE)
				boutput(holder.owner, SPAN_ALERT("Module inhibits teleportation areas with insufficient atmosphere."))
				return

			var/obj/machinery/networked/telepad/telepad = get_first_teleporter()
			if(is_teleportation_allowed(T))
				if(prob(15))
					if(prob(10))
						boutput(holder.owner, SPAN_ALERT("Recalculating..."))
					sleep(randfloat(0.5 SECONDS, 2.5 SECONDS))
				telepad.send(T)
			else
				boutput(holder.owner, SPAN_ALERT("Interference inhibits teleportation."))

	receive
		name = "Telepad: Receive"
		desc = "Send the contents of the target to the current telepad."
		icon_state = "tele_rx"
		cast(atom/target)
			if (..())
				return 1

			var/turf/T = get_turf(target)
			var/obj/machinery/networked/telepad/telepad = get_first_teleporter()
			if(is_teleportation_allowed(T))
				if(prob(85))
					if(prob(10))
						boutput(holder.owner, SPAN_ALERT("Recalculating..."))
					sleep(randfloat(0.5 SECONDS, 2.5 SECONDS))
				telepad.receive(T)
			else
				boutput(holder.owner, SPAN_ALERT("Interference inhibits teleportation."))

/datum/targetable/ai/module/nanite_repair
	name = "Nanite Repair"
	icon_state = "nanites"
	desc = "Send out targeted nanites to repair a silicon being or a camera."
	targeted = TRUE
	cooldown = 15 SECONDS

	// This might be a lot better as a homing projectile coming from a camera...
	cast(atom/target)
		if (..())
			return 1

		if(issilicon(target))
			var/mob/living/silicon/S = target
			var/nanite_overlay = S.SafeGetOverlayImage("nanite_heal",'icons/mob/critter/robotic/nanites.dmi', "nanites")
			S.UpdateOverlays(nanite_overlay, "nanite_heal")
			SPAWN(3 SECONDS)
				S.HealDamage("All", 6, 6)
				S.UpdateOverlays(null,"nanite_heal")
		else if(istype_exact(target,/obj/machinery/camera)) // sweet you got eyes on that camera
			var/obj/machinery/camera/C
			var/nanite_overlay = C.SafeGetOverlayImage("nanite_heal",'icons/mob/critter/robotic/nanites.dmi', "nanites")
			C.UpdateOverlays(nanite_overlay, "nanite_heal")
			C.set_camera_status(TRUE)
			C.icon_state = "camera"

			SPAWN(5 SECONDS)
				C.audible_message("[C] makes a soft clicking sound.")
				C.UpdateOverlays(null, "nanite_heal")

		else
			boutput(holder.owner, SPAN_ALERT("[target] is not a silicon entity."))
			return 1

/datum/targetable/ai/module/camera_repair
	name = "Repair Cameras"
	desc = "Send out nanites to attempt to repair cameras."
	icon_state = "camera_repair"
	cooldown = 120 SECONDS

	cast(atom/target)
		var/obj/machinery/camera/C
		var/list/obj/machinery/camera/cameras_to_repair = list()

		. = ..()
		for(C in camnets[CAMERA_NETWORK_STATION]) // TODO: get list of all cameras AI can see through?
			if(!C.camera_status && istype_exact(C,/obj/machinery/camera))
				cameras_to_repair |= C

		boutput(holder.owner, SPAN_ALERT("Initiating repair routine..."))
		if(length(cameras_to_repair))
			SPAWN(rand(10 SECONDS, 20 SECONDS))
				var/repaired = 0
				for(C in cameras_to_repair)
					var/nanite_overlay = C.SafeGetOverlayImage("nanite_heal",'icons/mob/critter/robotic/nanites.dmi', "nanites")
					C.UpdateOverlays(nanite_overlay, "nanite_heal")
					C.set_camera_status(TRUE)
					C.icon_state = "camera"

					SPAWN(5 SECONDS)
						C.audible_message("[C] makes a soft clicking sound.")
						C.UpdateOverlays(null, "nanite_heal")

					if(prob(10 + (repaired*5))) // Not all will be healed
						break

					repaired++

		else
			SPAWN(rand(15 SECONDS, 35 SECONDS))
				boutput(holder.owner, SPAN_ALERT("No damaged cameras detected."))

/datum/targetable/ai/module/sec_huds
	name = "Security Lookup Scan"
	desc = "Check someone's security records."
	targeted = TRUE
	target_anything = FALSE
	icon_state = "sec"

	disposing()
		get_image_group(CLIENT_IMAGE_GROUP_ARREST_ICONS).remove_mob(holder.owner)
		var/mob/living/silicon/ai/AI = holder.owner
		if(istype(AI) && AI.eyecam)
			get_image_group(CLIENT_IMAGE_GROUP_ARREST_ICONS).remove_mob(AI.eyecam)

		. = ..()

	onAttach(datum/abilityHolder/H)
		. = ..()
		get_image_group(CLIENT_IMAGE_GROUP_ARREST_ICONS).add_mob(H.owner)
		var/mob/living/silicon/ai/AI = holder.owner
		if(istype(AI) && AI.eyecam)
			get_image_group(CLIENT_IMAGE_GROUP_ARREST_ICONS).add_mob(AI.eyecam)

	cast(atom/target)
		if (..())
			return 1

		var/obj/item/aiModule/ability_expansion/security_vision/expansion = get_law_module()

		var/found = FALSE
		var/t1 = "[target.name]"
		t1 = adminscrub(t1)
		expansion.sec_comp.active_record_general = null
		expansion.sec_comp.active_record_security = null
		t1 = lowertext(t1)
		for (var/datum/db_record/R as anything in data_core.general.records)
			if ((lowertext(R["name"]) == t1 || t1 == lowertext(R["dna"]) || t1 == lowertext(R["id"])))
				expansion.sec_comp.active_record_general = R
		if (!expansion.sec_comp.active_record_general)
			expansion.sec_comp.temp = "Could not locate record [t1]."
		else
			for (var/datum/db_record/E as anything in data_core.security.records)
				if ((E["name"] == expansion.sec_comp.active_record_general["name"] || E["id"] == expansion.sec_comp.active_record_general["id"]))
					expansion.sec_comp.active_record_security = E
					expansion.sec_comp.temp = null
					found = TRUE
					break
			expansion.sec_comp.screen = 4 //SECREC_VIEW_RECORD

		if(found)
			expansion.sec_comp.Attackhand(holder.owner)
		else
			boutput(holder.owner, "Could not locate record for [t1]")

/datum/targetable/ai/module/prodocs
	name = "Camera Scan"
	desc = "Scan basic vitals on someone."
	targeted = TRUE
	target_anything = FALSE
	icon_state = "prodoc"

	disposing()
		get_image_group(CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS).remove_mob(holder.owner)
		var/mob/living/silicon/ai/AI = holder.owner
		if(istype(AI) && AI.eyecam)
			get_image_group(CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS).remove_mob(AI.eyecam)
		. = ..()

	onAttach(datum/abilityHolder/H)
		. = ..()
		get_image_group(CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS).add_mob(H.owner)
		var/mob/living/silicon/ai/AI = holder.owner
		if(istype(AI) && AI.eyecam)
			get_image_group(CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS).add_mob(AI.eyecam)

	cast(atom/target)
		if (..())
			return 1
		boutput(holder.owner, scan_health(target, disease_detection=FALSE, visible=TRUE))

/datum/targetable/ai/module/flash
	name = "Camera Flash"
	desc = "Supercharge the camera light to produce a flash like effect."
	targeted = TRUE
	target_anything = TRUE
	icon_state = "flash"
	var/flash_range = 5
	var/turboflash
	cooldown = 15 SECONDS

	cast(atom/target)
		if (..())
			return 1

		var/obj/machinery/camera/C
		var/turf/T = get_turf(target)
		var/range = flash_range
		var/dist
		for(var/obj/machinery/camera/cam in T.cameras)
			dist = GET_DIST(cam, target)
			if(dist <= range)
				C = cam

		if(C)
			logTheThing(LOG_COMBAT, holder.owner, "[key_name(holder.owner)] activates AI [src.name], targeting [log_loc(target)].")
			playsound(C, 'sound/weapons/flash.ogg', 100, TRUE)
			C.visible_message("[C] emits a sudden flash.")
			for (var/atom/A in oviewers((flash_range), get_turf(C)))
				var/mob/living/M
				if (istype(A, /obj/vehicle))
					var/obj/vehicle/V = A
					if (V.rider && V.rider_visible)
						M = V.rider
				else if (ismob(A))
					M = A
				if (M)
					if (src.turboflash)
						M.apply_flash(35, 0, 0, 25)
					else
						dist = clamp(dist,1,4)
						M.apply_flash(20, knockdown = 2, uncloak_prob = 100, stamina_damage = (35 / dist), disorient_time = 3)
		else
			boutput(holder.owner, "Target is outside of camera range!")

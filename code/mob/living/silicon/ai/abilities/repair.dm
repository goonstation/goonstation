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

					SPAWN(5 SECONDS)
						C.audible_message("[C] makes a soft clicking sound.")
						C.UpdateOverlays(null, "nanite_heal")

					if(prob(10 + (repaired*5))) // Not all will be healed
						break

					repaired++

		else
			SPAWN(rand(15 SECONDS, 35 SECONDS))
				boutput(holder.owner, SPAN_ALERT("No damaged cameras detected."))

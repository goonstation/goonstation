/datum/targetable/ai/program/scan_atmos
	name = "Remote Atmospheric Scan"
	desc = "Scan a location for realtime analysis of atmospheric contents."
	targeted = TRUE
	target_anything = TRUE
	icon_state = "scan_atmos"

	cast(atom/target)
		. = ..()
		if (.)
			return .
		boutput(src.holder.owner, global.scan_atmospheric(get_turf(target)))

/datum/targetable/ai/program/scan_health
	name = "Remote Vitals Scan"
	desc = "Scan basic vitals on someone."
	targeted = TRUE
	target_anything = FALSE
	icon_state = "scan_health"

	cast(atom/target)
		. = ..()
		if (.)
			return .
		boutput(src.holder.owner, global.scan_health(target, disease_detection=FALSE, visible=TRUE))

/datum/targetable/ai/program/scan_plant
	name = "Remote Plant Scan"
	desc = "Scan a plant to learn more about it."
	targeted = TRUE
	target_anything = TRUE
	icon_state = "scan_plant"

	cast(atom/target)
		. = ..()
		if (.)
			return .
		boutput(src.holder.owner, global.scan_plant(target, src.holder.owner))

/datum/targetable/ai/program/scan_reagent
	name = "Remote Fluid Scan"
	desc = "Scan a fluid on the ground to see its composition."
	targeted = TRUE
	target_anything = TRUE
	icon_state = "scan_reagent"

	cast(atom/target)
		. = ..()
		if (.)
			return .

		var/turf/T = get_turf(target)
		var/data = ""

		if (CHECK_LIQUID_CLICK(target))
			var/obj/fluid/liquid = T.active_liquid
			var/obj/fluid/airborne/gas = T.active_airborne_liquid
			if (liquid)
				data += "<br>[scan_reagents(liquid)]"
			if (gas)
				data += "<br>[scan_reagents(gas)]"

		if (data)
			boutput(src.holder.owner, data)
		else
			boutput(src.holder.owner, "No reagents detected on [T]")

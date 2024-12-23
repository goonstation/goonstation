/datum/random_event/minor/illegal_trinkets
	name = "Illegal Trinkets"
	centcom_headline = "Security Review Notice"
	centcom_message = "The NanoTrasen Logistics Screening Team has confirmed the possibility of stolen, smuggled, or counterfeit items aboard."
	weight = 10
	var/list/obj/item/criminal_items = list()

	is_event_available(ignore_time_lock = 0)
		. = ..()
		src.criminal_items = list()
		if (.)
			for_by_tcl(H, /mob/living/carbon/human)
				if (isdead(H)) continue
				if (isnpc(H)) continue
				if (isvirtual(H)) continue
				if (inafterlife(H)) continue
				if (istype(H.loc, /obj/cryotron)) continue
				var/datum/deref = H?.trinket?.deref()
				if (istype(deref, /obj/item))
					var/obj/item/trinket = H.trinket.deref()
					if (
						findtext(trinket.name, "stolen") \
						|| findtext(trinket.name, "smuggled") \
						|| findtext(trinket.name, "counterfeit") \
						|| findtext(trinket.name, "ex's")  \
						|| findtext(trinket.name, "shameful") \
					 )
						src.criminal_items += trinket

			if (!length(src.criminal_items))
				return FALSE

			return TRUE

	event_effect(source)
		. = ..()

		for(var/obj/item/trinket in src.criminal_items)
			trinket.AddComponent(/datum/component/contraband, 3, 0) // set off item scans, but not mob scans

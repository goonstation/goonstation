// If this behavior is desired on clownshoes only, it makes more sense to have clownshoes register for the signal directly,
// this component is mostly included as an example

/datum/component/wearertargeting/tripsalot
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	signals = list(COMSIG_MOVABLE_MOVED)
	mobtype = /mob/living/carbon/human
	proctype = .proc/tripalot
	// valid_slots is provided by the AddComponent argument


/datum/component/wearertargeting/tripsalot/proc/tripalot(mob/living/carbon/human/H, last_turf, direct)
	if (prob(0.5) && !H.lying)
		if (!GET_COOLDOWN(H, "clown_trip"))
			if (H.slip())
				ON_COOLDOWN(H, "clown_trip", 6 SECONDS)
				if(istype(H.head, /obj/item/clothing/head))
					if(istype(H.head, /obj/item/clothing/head/helmet))
						boutput(H, "<span class='alert'>You stumble and fall to the ground. Thankfully, that helmet protected you.</span>")
					else
						boutput(H, "<span class='alert'>You stumble and fall to the ground. Thankfully, that hat protected you.</span>")
				else
					boutput(H, "<span class='alert'>You stumble and hit your head.</span>")
					H.stuttering = max(H.stuttering, 4)

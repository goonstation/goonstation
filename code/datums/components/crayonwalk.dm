
/datum/component/wearertargeting/crayonwalk // stonepillar's crayon project
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	signals = list(COMSIG_MOVABLE_MOVED)
	mobtype = /mob/living/carbon/human
	proctype = .proc/crayonwalk

/datum/component/wearertargeting/crayonwalk/proc/crayonwalk(mob/living/carbon/human/H, last_turf, direct)
	if (!H.lying && istype(src.parent, /obj/item/clothing/shoes/clown_shoes))
		var/obj/item/clothing/shoes/clown_shoes/S = src.parent
		if (length(S.crayons) && !(locate(/obj/decal/cleanable/writing) in last_turf))
			var/obj/item/pen/crayon/crayon = pick(S.crayons)
			if(length(crayon.symbol_setting))
				if(prob(10))
					var/list/params = list()
					params["icon-x"] = 16
					params["icon-y"] = 16
					crayon.write_on_turf(last_turf, H, params)
			else
				S.crayons.Remove(crayon)
				crayon.set_loc(last_turf)
				boutput(H, "<span class='alert'>Plonk! \The [crayon] fell out of your shoes!</span>")

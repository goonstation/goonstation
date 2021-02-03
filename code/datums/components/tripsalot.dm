// If this behavior is desired on clownshoes only, it makes more sense to have clownshoes register for the signal directly,
// this component is mostly included as an example

/datum/component/wearertargeting/tripsalot
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	signals = list(COMSIG_MOVABLE_MOVED)
	mobtype = /mob/living/carbon/human
	proctype = .proc/tripalot
	// valid_slots is provided by the AddComponent argument


/datum/component/wearertargeting/tripsalot/proc/tripalot(mob/living/carbon/human/H, last_turf, direct)
	if (prob(1) && prob(50) && !H.lying)
		if(istype(H.head, /obj/item/clothing/head))
			if(H.head.type == /obj/item/clothing/head/helmet)
				boutput(H, "<span class='alert'>You stumble and fall to the ground. Your oddly shaped head fits poorly in this helmet!</span>")
				H.setStatus("paralysis", max(rand(50,100), H.getStatusDuration("paralysis")))
				random_brute_damage(H, 15)
			else if(istype(H.head, /obj/item/clothing/head/helmet))//for all non sec helmets
				boutput(H, "<span class='alert'>You stumble and fall to the ground. Thankfully, that helmet protected you.</span>")
				H.changeStatus("weakened", 3 SECONDS)
			else if(prob(70))
				boutput(H, "<span class='alert'>You stumble and fall to the ground. Thankfully, that hat protected you.</span>")
				H.changeStatus("weakened", 3 SECONDS)
			else
				boutput(H, "<span class='alert'>You stumble and hit your head.</span>")
				H.changeStatus("weakened", 3 SECONDS)
		else
			boutput(H, "<span class='alert'>You stumble and hit your head.</span>")
			H.changeStatus("weakened", 5 SECONDS)
			H.stuttering = max(rand(0,3), H.stuttering)

/datum/component/wearertargeting/crayonwalk // stonepillar's crayon project
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	signals = list(COMSIG_MOVABLE_MOVED)
	mobtype = /mob/living/carbon/human
	proctype = .proc/crayonwalk

/datum/component/wearertargeting/crayonwalk/proc/crayonwalk(mob/living/carbon/human/H, last_turf, direct)
	if (!H.lying && H.shoes.type == /obj/item/clothing/shoes/clown_shoes)
		var/obj/item/clothing/shoes/clown_shoes/S = H.shoes
		if (length(S.crayons))
			var/obj/item/pen/crayon/crayon = pick(S.crayons)
			if(length(crayon.symbol_setting))
				var/list/params = list()
				params["icon-x"] = 16
				params["ixon-y"] = 16
				crayon.write_on_turf(last_turf, H, params)
			else
				S.crayons.Remove(crayon)
				crayon.set_loc(last_turf)
				boutput(H, "<span class='alert'>Plonk! \The [crayon] fell out of your shoes!</span>")
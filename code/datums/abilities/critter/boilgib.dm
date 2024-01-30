// ----------------------------------
// Grow into a bigger form of critter
// ----------------------------------
/datum/targetable/critter/boilgib
	name = "Blood Boil"
	desc = "Expend all of your energy to self-destruct and spray boiling changeling blood on nearby targets."
	cooldown = 0
	start_on_cooldown = FALSE
	icon_state = "blood_boil"

	cast(atom/target)
		if (..())
			return 1
		var/mob/ow = holder.owner

		if(ow.client)
			if(tgui_alert(ow, "This will destroy your body to scald all nearby targets! Are you sure?", "Blood boil", list("Yes","No")) != "Yes")
				return

		for (var/turf/splat in view(2,ow.loc))
			if (prob(50))
				var/obj/decal/cleanable/blood/B = make_cleanable(/obj/decal/cleanable/blood,splat)
				B.sample_reagent = "bloodc"

		ow.visible_message(SPAN_ALERT("<B>[holder.owner] boils and bursts open violently!</B>"))

		var/dmg = 20
		//Increase the power of the boilgib if we have collected DNA!
		if (istype(holder.owner, /mob/living/critter/changeling/handspider))
			var/mob/living/critter/changeling/handspider/H = holder.owner
			dmg += H.absorbed_dna * 3.3
		for (var/mob/M in view(3,ow.loc))
			if(iscarbon(M))
				if (ishuman(M))
					var/mob/living/carbon/human/H = M
					if(istype(H.wear_suit, /obj/item/clothing/suit/hazard/bio_suit) && istype(H.head, /obj/item/clothing/head/bio_hood))
						boutput(M, SPAN_NOTICE("You are sprayed with blood, but your biosuit protects you!"))
						continue
				M.emote("scream")
				M.TakeDamage("chest", 0, dmg, 0, DAMAGE_BURN)
				if (M.reagents)
					M.reagents.add_reagent("bloodc", dmg, null, T0C)
				boutput(M, SPAN_ALERT("You are sprayed with sizzling hot blood!"))
		ow.gib()

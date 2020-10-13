/datum/random_event/major/spookycostumes
	name = "Spooktober Curse"
	centcom_headline = "Oh No!"
	centcom_message = {"Unfortunately, our station has crashed into a space witch. Beware of curses."}
	var/list/eligible_mobs = list()
	event_effect()
		..()
		eligible_mobs = list()

		for (var/mob/living/carbon/human/H in mobs)
			if (isdead(H))
				continue
			if (!H.bioHolder)
				continue
			if(H.w_uniform || H.wear_mask || H.head || H.wear_suit )
				eligible_mobs += H


		if (!eligible_mobs.len)
			message_admins("spooky random event could not find enough mobs to proceed")
			return


		sleep(5 SECONDS)

		for (var/mob/living/carbon/human/H in eligible_mobs)

			if ((H.head && findtext(H.head.name, "abomination")) || (H.w_uniform && findtext(H.w_uniform.name, "abomination")))
				H.set_mutantrace(/datum/mutantrace/abomination/admin/)
				boutput(H, "<span class='alert'><font  size='[1]'>for some reason, your costume feels a lot more rubbery</font></span>")
				eligible_mobs -= H

				return
			if (H.wear_suit && findtext(H.wear_suit.name,"hotdog"))
				var/obj/item/reagent_containers/food/snacks/hotdog/D = new /obj/item/reagent_containers/food/snacks/hotdog
				D.loc = get_turf(H)
				D.bun = 1
				D.update_icon()
				var/atom/movable/overlay/gibs/animation = null
				animation = new(H.loc)
				animation.master = H
				flick("implode", animation)
				boutput(H, "<span class='alert'><font  size='[10]'>NOOOOOOOOOOOO I DONT WANNA BE A WEENIE AAAAAAAAAAAAAAAAAAAA</font></span>")
				H.set_loc(D)
				H.bioHolder.AddEffect("telepathy",magical = 1)
				for (var/datum/targetable/A in H.abilityHolder.abilities)
					if(istype(A,/datum/targetable/geneticsAbility/telepathy))
						A.cooldown = 0
				if(!H.bioHolder.AddEffect("mute",magical = 1))
					boutput(H, "<span class='alert'><font  size='[5]'>something broke</font></span>")
				eligible_mobs -= H
				return
			if (H.wear_mask && findtext(H.wear_mask.name, "clown"))
				H.reagents.add_reagent("rainbow fluid", 300)
				eligible_mobs -= H
				return
			if ( H.wear_id && H.w_uniform && H.head && H.bioHolder.HasOneOfTheseEffects("lizard") && findtext(H.wear_id.name, "Discount Godzilla") && findtext(H.w_uniform.name,"green") && findtext(H.head.desc,"green"))

				H.reagents.add_reagent("bubs", INFINITY)
				for(var/reagent in H.reagents.reagent_list)
					if(reagent == "bubs")
						var/datum/reagent/R = H.reagents.reagent_list[reagent]
						R.depletion_rate = 0
				H.bioHolder.AddEffect("hulk",magical = 1)
				eligible_mobs -= H
				return
			else
				eligible_mobs -= H



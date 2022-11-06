/datum/targetable/brain_slug/exit_host
	name = "Exit host"
	desc = "Leave behind this worthless body."
	icon_state = "exit_host"
	cooldown = 8 SECONDS
	targeted = 0

	cast()
		if (holder.owner.reagents)
			var/volume_passed = holder.owner.reagents.get_reagent_amount("synaptizine") //Some counterplay to avoid the slug just ditching the body the second it is caught out
			if (volume_passed)
				holder.owner.visible_message("<span class='notice'>[holder.owner] contorts for an instant then straightens back up, visibly pained.'</span>",\
											"<span class='alert'>You try to exit this host but you can't concentrate enough with this poison in you!</span>")
				holder.owner.emote("scream")
				return FALSE
		if (istype(holder.owner, /mob/living/critter/brain_slug))
			var/mob/living/critter/brain_slug/the_slug = holder.owner
			if (istype(the_slug.loc,/mob/))
				var/mob/containing_mob = the_slug.loc
				the_slug.set_loc(get_turf(containing_mob))
				if (ishuman(containing_mob))
					var/mob/living/carbon/human/old_host = containing_mob
					old_host.slug = null
				if (istype(containing_mob, /mob/living/critter/small_animal))
					var/mob/living/critter/small_animal/old_host = containing_mob
					old_host.slug = null
				containing_mob.remove_ability_holder(/datum/abilityHolder/brain_slug)
				return FALSE
			else
				boutput(the_slug, "<span class='notice'>You aren't in a host!</span>")
				return TRUE
		var/choice = tgui_alert(holder.owner, "Are you sure you wish to exit this body?", "Exit body", list("Yes", "No"))
		if (!choice || choice == "No")
			return TRUE
		if (istype(holder.owner, /mob/living/critter/small_animal))
			var/mob/living/critter/small_animal/caster = holder.owner
			if (!caster.slug)
				boutput(holder.owner, "<span class='notice'>You have no parasite to expel... uh.</span>")
				return TRUE
			//Drop the slug on the floor and give it back its mind.
			caster.mind.transfer_to(caster.slug)
			caster.slug.changeStatus("slowed", 5 SECONDS, 2)
			caster.slug.set_loc(get_turf(caster))
			//Dont immediately infest something again.
			var/datum/targetable/ability = caster.slug.abilityHolder.getAbility(/datum/targetable/brain_slug/infest_host)
			ability.doCooldown()
			caster.remove_ability_holder(/datum/abilityHolder/brain_slug)
			caster.slug = null
			spawn(5 SECONDS)	//It doesnt have much of a brain anymore
				caster?.death()
		else if (ishuman(holder.owner))
			var/mob/living/carbon/human/human_host = holder.owner
			if (!human_host.slug)
				boutput(holder.owner, "<span class='notice'>You have no parasite to expel... uh.</span>")
				return TRUE
			human_host.make_jittery(1000)
			human_host.emote("scream")
			human_host.setStatus("stunned", 5 SECONDS)
			spawn(3 SECONDS)
				if (!human_host || !human_host.slug) return
				//Drop the slug on the floor and control it again
				human_host.mind?.transfer_to(human_host.slug)
				human_host.slug.changeStatus("slowed", 5 SECONDS, 2)
				human_host.slug.set_loc(get_turf(human_host))
				//Dont immediately infest something again.
				var/datum/targetable/ability = human_host.slug.abilityHolder.getAbility(/datum/targetable/brain_slug/infest_host)
				ability.doCooldown()
				if (human_host.organHolder.head) //sanity check in case you somehow lost your head but didnt die yet.
					var/obj/head = human_host.organHolder.drop_organ("head")
					qdel(head)
					make_cleanable( /obj/decal/cleanable/blood/gibs,human_host.loc)
					playsound(human_host.loc, 'sound/impact_sounds/Flesh_Break_2.ogg', 50)
					gibs(human_host.loc, headbits = 0)
					human_host.visible_message("<span class='alert'>[human_host]'s head suddenly explodes in a shower of gore! Some horrific space slug jumps out of the horrible mess.</span>", "<span class='alert'>You leave [human_host]'s head in a delightfully horrific manner.</span>")
				//Cleanup
				human_host.slug = null
				human_host.remove_ability_holder(/datum/abilityHolder/brain_slug)
				human_host.death()
		else
			boutput(holder.owner, "<span class='notice'>Something weird happened. Consider making a bug report.</span>")
			return TRUE

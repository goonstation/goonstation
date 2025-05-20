/datum/targetable/spell/golem
	name = "Summon Golem"
	desc = "Summons a Golem made of the reagent you currently hold."
	icon_state = "golem"
	targeted = FALSE
	cooldown = 75 SECONDS
	requires_robes = TRUE
	requires_being_on_turf = TRUE
	offensive = TRUE
	cooldown_staff = TRUE
	voice_grim = 'sound/voice/wizard/GolemGrim.ogg'
	voice_fem = 'sound/voice/wizard/GolemFem.ogg'
	voice_other = 'sound/voice/wizard/GolemLoud.ogg'
	maptext_colors = list("#fcdf74", "#d75015")

	cast()
		if(!holder)
			return
		var/obj/item/AnItem = null //temp item holder for processing
		var/datum/reagents/TheReagents = null //reagent holder

		//get reagent container if there is one, and check to see it has some reagents
		if (holder.owner.r_hand != null)
			AnItem = holder.owner.r_hand
			if(istype(AnItem, /obj/item/reagent_containers/))
				if(AnItem.reagents.total_volume)
					TheReagents = AnItem.reagents
			else
				AnItem = null



		if (holder.owner.l_hand != null && !AnItem)
			AnItem = holder.owner.l_hand
			if(istype(AnItem, /obj/item/reagent_containers/))
				if(AnItem.reagents.total_volume)
					TheReagents = AnItem.reagents
			else
				AnItem = null


		if(!AnItem)
			boutput(holder.owner, SPAN_ALERT("You must be holding a container in your hand."))
			return 1 // No cooldown when it fails.

		if(!TheReagents)
			boutput(holder.owner, SPAN_ALERT("You have no material to convert into a golem."))
			return 1


		if(!istype(get_area(holder.owner), /area/sim/gunsim))
			holder.owner.say("CLAE MASHON", flags = SAYFLAG_IGNORE_STAMINA, message_params = list("maptext_css_values" = src.maptext_style, "maptext_animation_colours" = src.maptext_colors))
		..()

		var/mob/living/critter/golem/the_golem
		if (istype(AnItem, /obj/item/reagent_containers/food/snacks/ingredient/egg/bee))
			the_golem = new /obj/critter/domestic_bee(get_turf(holder.owner))
			the_golem.name = "Bee Golem"
			the_golem.desc = "A greater domestic space bee that has been created with magic, but is otherwise completely identical to any other member of its species."
		else
			the_golem = new /mob/living/critter/golem/(get_turf(holder.owner))
			the_golem.CustomizeGolem(TheReagents)

		qdel(TheReagents)
		qdel(AnItem)
		boutput(holder.owner, SPAN_NOTICE("You conjure up [the_golem]!"))
		logTheThing(LOG_COMBAT, holder.owner, "created a [constructTarget(the_golem,"combat")] at [log_loc(holder.owner)].")
		holder.owner.visible_message(SPAN_ALERT("[holder.owner] conjures up [the_golem]!"))
		playsound(holder.owner.loc, 'sound/effects/mag_golem.ogg', 25, 1, -1)

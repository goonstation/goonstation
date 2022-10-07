/datum/targetable/spell/golem
	name = "Summon Golem"
	desc = "Summons a Golem made of the reagent you currently hold."
	icon_state = "golem"
	targeted = 0
	cooldown = 500
	requires_robes = 1
	requires_being_on_turf = TRUE
	offensive = 1
	cooldown_staff = 1
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
			boutput(holder.owner, "<span class='alert'>You must be holding a container in your hand.</span>")
			return 1 // No cooldown when it fails.

		if(!TheReagents)
			boutput(holder.owner, "<span class='alert'>You have no material to convert into a golem.</span>")
			return 1


		if(!istype(get_area(holder.owner), /area/sim/gunsim))
			holder.owner.say("CLAE MASHON", FALSE, maptext_style, maptext_colors)
		..()

		var/obj/critter/golem/TheGolem
		if (istype(AnItem, /obj/item/reagent_containers/food/snacks/ingredient/egg/bee))
			TheGolem = new /obj/critter/domestic_bee(get_turf(holder.owner))
			TheGolem.name = "Bee Golem"
			TheGolem.desc = "A greater domestic space bee that has been created with magic, but is otherwise completely identical to any other member of its species."
		else
			TheGolem = new /obj/critter/golem(get_turf(holder.owner))
			TheGolem.CustomizeGolem(TheReagents)

		qdel(TheReagents)
		qdel(AnItem)
		boutput(holder.owner, "<span class='notice'>You conjure up [TheGolem]!</span>")
		logTheThing(LOG_COMBAT, holder.owner, "created a [constructTarget(TheGolem,"combat")] at [log_loc(holder.owner)].")
		holder.owner.visible_message("<span class='alert'>[holder.owner] conjures up [TheGolem]!</span>")
		playsound(holder.owner.loc, 'sound/effects/mag_golem.ogg', 25, 1, -1)

/datum/random_event/minor/gimmick_flood
	name = "Random Flood"
	disabled = !ASS_JAM
	weight = 30
	customization_available = 1
	var/reagent_type = null
	var/amount = null
	var/turf/target = null

	admin_call(var/source)
		if (..())
			return

		if (alert(usr, "Random reagent?", "Random reagent?", "Yes", "No") == "No")
			var/list/L = list()
			var/searchFor = input(usr, "Look for a part of the reagent name (or leave blank for all)", "Add reagent") as null|text
			if(searchFor)
				for(var/R in concrete_typesof(/datum/reagent))
					if(findtext("[R]", searchFor)) L += R
			else
				L = concrete_typesof(/datum/reagent)

			if(L.len == 1)
				reagent_type = L[1]
			else if(L.len > 1)
				reagent_type = input(usr,"Select Reagent:","Reagents",null) as null|anything in L
			else
				usr.show_text("No reagents matching that name", "red")
				return

		amount = input(usr,"Amount:","Amount",2000) as null|num

		if (alert(usr, "Target location:", "Target location:", "Random", "My turf") == "My turf")
			src.target = get_turf(usr)

		src.event_effect(source)
		return

	event_effect()
		..()

		if(isnull(src.reagent_type))
			reagent_type = pick(concrete_typesof(/datum/reagent))

		var/datum/reagent/reagent = new reagent_type()

		if(isnull(src.target))
			if(prob(60) || !by_type[/obj/machinery/drainage] || !by_type[/obj/machinery/drainage].len)
				src.target = pick(get_area_turfs(/area/station)) // don't @ me
				target.visible_message("<span class='alert'><b>A rift to a [reagent.name] dimension suddenly warps into existence!</b></span>")
			else
				var/obj/machinery/drainage/drain = pick(by_type[/obj/machinery/drainage])
				drain.clogged = 60 // about 3 minutes
				drain.update_icon()
				src.target = get_turf(drain)
				target.visible_message("<span class='alert'><b>\The [drain] overflows with [reagent.name]!</b></span>")

		if(!amount)
			amount = pick(50, 100, 200, 500, 1000, 2000, 5000)

		src.target.fluid_react_single(reagent.id, amount)


		playsound(target,"sound/effects/teleport.ogg",50,1)

		message_admins("Random flood event triggered on ([showCoords(target.x, target.y, target.z)]) with [amount] [reagent.name].")

		var/obj/decal/teleport_swirl/swirl = unpool(/obj/decal/teleport_swirl)
		swirl.set_loc(target)
		SPAWN_DBG(1.5 SECONDS)
			pool(swirl)

		src.target = initial(src.target)
		src.amount = initial(src.amount)
		src.reagent_type = initial(src.reagent_type)

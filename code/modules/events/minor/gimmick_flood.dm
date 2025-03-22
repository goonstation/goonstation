/datum/random_event/minor/gimmick_flood
	name = "Random Flood"
	disabled = 1 // disabled for now, this would be a good player-triggerable event. -warc
	weight = 30
	customization_available = 1
	var/reagent_type = null
	var/amount = null
	var/turf/target = null

	admin_call(var/source)
		if (..())
			return

		if (alert(usr, "Random reagent?", "Random reagent?", "Yes", "No") == "No")
			src.reagent_type = pick_reagent(src)?.type
			if (!src.reagent_type)
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
			if(prob(60) || !by_type[/obj/machinery/drainage] || !length(by_type[/obj/machinery/drainage]))
				src.target = pick(get_area_turfs(/area/station)) // don't @ me
				target.visible_message(SPAN_ALERT("<b>A rift to a [reagent.name] dimension suddenly warps into existence!</b>"))
			else
				var/obj/machinery/drainage/drain = pick(by_type[/obj/machinery/drainage])
				drain.clogged = 60 // about 3 minutes
				drain.UpdateIcon()
				src.target = get_turf(drain)
				target.visible_message(SPAN_ALERT("<b>\The [drain] overflows with [reagent.name]!</b>"))

		if(!amount)
			amount = pick(50, 100, 200, 500, 1000, 2000, 5000)

		src.target.fluid_react_single(reagent.id, amount)


		playsound(target, 'sound/effects/teleport.ogg', 50,TRUE)

		message_admins("Random flood event triggered on ([log_loc(target)]) with [amount] [reagent.name].")

		var/obj/decal/teleport_swirl/swirl = new /obj/decal/teleport_swirl
		swirl.set_loc(target)
		SPAWN(1.5 SECONDS)
			qdel(swirl)

		src.target = initial(src.target)
		src.amount = initial(src.amount)
		src.reagent_type = initial(src.reagent_type)

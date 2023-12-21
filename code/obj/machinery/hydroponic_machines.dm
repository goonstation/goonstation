// Machines created specifically to interact with plantpots, this contains the following machines:
//
// UV Grow Lamps
// Botanical Mister
//

TYPEINFO(/obj/machinery/hydro_growlamp)
	mats = 6

#define ACTIVE_POWER_USAGE 100
/obj/machinery/hydro_growlamp
	name = "\improper UV Grow Lamp"
	desc = "A special lamp that emits ultraviolet light to help plants grow quicker."
	icon = 'icons/obj/hydroponics/machines_hydroponics.dmi'
	icon_state = "growlamp0" // sprites by Clarks
	density = 1
	anchored = UNANCHORED
	var/active = 0
	var/datum/light/light

/obj/machinery/hydro_growlamp/New()
	..()
	light = new /datum/light/point
	light.attach(src)
	light.set_brightness(1)
	light.set_height(1)
	light.set_color(0.7, 0.2, 1)
	if(src.active)
		light.enable()
	else
		light.disable()


/obj/machinery/hydro_growlamp/process(mult)
	..()
	if(!src.active || !powered())
		return
	for (var/atom/A in view(4,src))
		if (istype(A, /obj/machinery/plantpot))
			var/obj/machinery/plantpot/P = A
			if(!P.current || P.dead)
				continue
			P.growth += 2
			if(istype(P.plantgenes,/datum/plantgenes/))
				var/datum/plantgenes/DNA = P.plantgenes
				if(HYPCheckCommut(DNA,/datum/plant_gene_strain/photosynthesis))
					P.growth += 4
		else if (ismob(A))
			var/mob/M = A
			if (M.bodytemperature < M.base_body_temp)
				M.bodytemperature += 15 * mult
	use_power(ACTIVE_POWER_USAGE)

/obj/machinery/hydro_growlamp/attack_hand(var/mob/user)
	src.add_fingerprint(user)
	src.active = !src.active
	user.visible_message("<b>[user]</b> switches [src.name] [src.active ? "on" : "off"].")
	src.icon_state = "growlamp[src.active]"
	if(src.active && !HAS_FLAG(status, (NOPOWER|BROKEN)))
		light.enable()
	else
		light.disable()

/obj/machinery/hydro_growlamp/power_change()
	. = ..()
	if(HAS_FLAG(status, NOPOWER))
		light.disable()
	else if(src.active)
		light.enable()


/obj/machinery/hydro_growlamp/attackby(obj/item/W, mob/user)
	if(isscrewingtool(W) || iswrenchingtool(W))
		if(!src.anchored)
			user.visible_message("<b>[user]</b> secures the [src] to the floor!")
		else
			user.visible_message("<b>[user]</b> unbolts the [src] from the floor!")
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
		src.anchored = !src.anchored

#undef ACTIVE_POWER_USAGE
TYPEINFO(/obj/machinery/hydro_mister)
	mats = 6

/obj/machinery/hydro_mister
	name = "\improper Botanical Mister"
	desc = "A device that constantly sprays small amounts of chemical onto nearby plants."
	icon = 'icons/obj/large/32x48.dmi'
	icon_state = "hydro_mister0"
	flags = FPRINT | FLUID_SUBMERGE | TGUI_INTERACTIVE | ACCEPTS_MOUSEDROP_REAGENTS | OPENCONTAINER
	density = 1
	anchored = UNANCHORED
	var/active = 0
	var/mode = 1
	var/emagged = FALSE
	var/mist_range = 4

/obj/machinery/hydro_mister/New()
	if (prob(1))
		name = pick ("Botanical Missus", "Botanical Miss") //in-joke for ESL folk
	..()
	src.create_reagents(5000)
	reagents.add_reagent("water", 1000)

/obj/machinery/hydro_mister/get_desc()
	var/complete_description = "<br>It's [!src.active ? "off" : (!src.mode ? "on low" : "on high")]. It's about [round(src.reagents.total_volume / src.reagents.maximum_volume * 100, 1)]% full."
	if (src.emagged)
		complete_description += " It is humming with an oddly disturbing sound."
	var/reag_list = ""
	for(var/current_id in src.reagents.reagent_list)
		var/datum/reagent/current_reagent = src.reagents.reagent_list[current_id]
		reag_list += "[reag_list ? ", " : " "][current_reagent.name]"
	complete_description += " It seems to contain [reag_list]."
	return complete_description

/obj/machinery/hydro_mister/process()
	..()
	if(src.active)
		for (var/obj/potential_target in view(mist_range,src))
			if(isnull(potential_target.reagents) || istype(potential_target, /obj/machinery/hydro_mister))
				//we never pour chems in stuff without reagents or other botanical misters
				continue
			if(!(istype(potential_target, /obj/machinery/plantpot) || src.emagged && potential_target.is_open_container(TRUE)))
				//if we are not emagged, we never transfer in non-plantpots
				//if emagged, we only transfer into open containers
				continue
			if(istype(potential_target, /obj/machinery/plantpot) && potential_target?.reagents.get_reagent_amount("water") >= 195)
				//we never transfer in plantpots with too much water in them
				continue
			// if we don't got enough chems, let's rather not continue
			if(src.reagents.total_volume < 10)
				break
			//Now we sorted all cases out and can fill them with our chemicals
			var/particles/sprinkle/sprinkles = new
			sprinkles.spawning = src.mode ? 3 : 2
			sprinkles.color = src.reagents.get_average_rgb()
			potential_target.UpdateParticles(sprinkles, "mister_sprinkles")
			SPAWN(0.6 SECONDS)
				sprinkles.spawning = FALSE
				sleep(1 SECOND)
				potential_target.ClearSpecificParticles("mister_sprinkles")
			src.reagents.trans_to(potential_target, 1 + (mode * 4))


		if(src.reagents.total_volume < 10)
			src.visible_message("\The [src] sputters and runs out of liquid.")
			src.active = 0
			src.mode = 0

/obj/machinery/hydro_mister/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (src.emagged)
		return 0
	if (user)
		user.show_text("The [src] gives out an oddly disturbing sound.", "red")
	src.emagged = TRUE
	src.mist_range = 5 // place one in chemistry and make the nerds suffer
	return 1

/obj/machinery/hydro_mister/attackby(obj/item/W, mob/user)
	if(isscrewingtool(W) || iswrenchingtool(W))
		if(!src.anchored)
			user.visible_message("<b>[user]</b> secures the [src] to the floor!")
		else
			user.visible_message("<b>[user]</b> unbolts the [src] from the floor!")
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
		src.anchored = !src.anchored
	if(istype(W, /obj/item/reagent_containers/glass/) && W.is_open_container(FALSE))
		// Not just watering cans - any kind of glass can be used to pour stuff in.
		if(!W.reagents.total_volume)
			boutput(user, SPAN_ALERT("There is nothing in [W] to pour!"))
			return
		else
			user.visible_message(SPAN_NOTICE("[user] pours [W:amount_per_transfer_from_this] units of [W]'s contents into [src]."))
			playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)
			W.reagents.trans_to(src, W:amount_per_transfer_from_this)
			if(!W.reagents.total_volume) boutput(user, SPAN_ALERT("<b>[W] is now empty.</b>"))


/obj/machinery/hydro_mister/attack_hand(var/mob/user)
	src.add_fingerprint(user)
	if(!src.active)
		src.active = 1
		src.mode = 0
		src.icon_state = "hydro_mister1"
		user.visible_message("<b>[user]</b> switches [src.name] on to low power mode.")
		src.visible_message("\The [src] starts to hum, emitting a fine mist.")
	else
		if(!src.mode)
			src.mode = 1
			src.icon_state = "hydro_mister2"
			user.visible_message("<b>[user]</b> switches [src.name] to high power mode.")
			src.visible_message("\The [src] starts to <em>really</em> emit a fine mist!")
		else
			src.active = 0
			src.mode = 0
			src.icon_state = "hydro_mister0"
			user.visible_message("<b>[user]</b> switches [src.name] off.")
			src.visible_message("\The [src] goes quiet.")

	playsound(src, 'sound/misc/lightswitch.ogg', 50, TRUE)

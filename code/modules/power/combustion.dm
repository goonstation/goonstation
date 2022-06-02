/obj/machinery/power/combustion_generator
	name = "Portable Generator"
	desc = "A portable combustion generator that burns fuel from a fuel tank"
	icon_state = "furnace"
	density = 1
	anchored = 0

	var/obj/item/reagent_containers/food/drinks/fueltank/fuel_tank // power scales with volatility

	var/obj/item/tank/inlet_tank

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/tank))
			if (src.inlet_tank)
				user.show_text("There appears to be a tank loaded already.", "red")
				return
			if (!check_tank_oxygen(W))
				user.show_text("The tank doesn't contain any oxygen.", "red")
				return
			src.visible_message("<span class='notice'>[user] loads [W] into the [src].</span>")
			user.u_equip(W)
			W.set_loc(src)
			src.inlet_tank = W
			src.UpdateIcon()

	proc/check_tank_oxygen(obj/item/tank/T)
		if (!src || !T || !T.air_contents)
			return
		if (T.air_contents.oxygen <= 0)
			return
		return 1


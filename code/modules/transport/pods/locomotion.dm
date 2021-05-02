/////Decides what movement controller the ship uses (These are for vehicle/TANK type only)
/obj/item/shipcomponent/locomotion
	name = "Locomotion"
	desc = "Y'all shouldn't be seeing this."
	power_used = 0
	system = "Locomotion"
	icon = 'icons/obj/machinery/8dirvehicles.dmi'
	icon_state = "treads"

	var/appearanceString = "minisub_treads"
	var/movement_controller_type = "treads"

	activate()
		..()
		if (src.active == 1 && ship)
			var/path = text2path("/datum/movement_controller/tank/[movement_controller_type]")
			ship.movement_controller = new path(ship)

/obj/item/shipcomponent/locomotion/treads
	name = "Treads"
	desc = "Dependable!"
	//power_used = 40
	appearanceString = "treads"
	icon_state = "treads"
	movement_controller_type = "treads"

/obj/item/shipcomponent/locomotion/wheels
	name = "Wheels"
	desc = "Faster than treads, but you can only turn while moving."
	//power_used = 30
	appearanceString = "wheels"
	icon_state = "wheels"
	movement_controller_type = "wheels"

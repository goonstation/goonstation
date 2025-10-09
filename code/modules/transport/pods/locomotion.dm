/////Decides what movement controller the ship uses (These are for vehicle/TANK type only)
/obj/item/shipcomponent/locomotion
	name = "Locomotion"
	desc = "Y'all shouldn't be seeing this."
	power_used = 0
	system = "Locomotion"
	icon = 'icons/obj/machines/8dirvehicles.dmi'
	icon_state = "treads"

	var/appearanceString = "minisub_treads"
	var/movement_controller_type = "treads"

	can_install(var/mob/user, var/obj/machinery/vehicle/vehicle)
		if(istype(vehicle, /obj/machinery/vehicle/tank))
			return TRUE
		return FALSE

	get_install_slot()
		return POD_PART_LOCOMOTION

	activate()
		..()
		if (src.active == 1 && ship)
			var/path = text2path("/datum/movement_controller/tank/[movement_controller_type]")
			ship.movement_controller = new path(ship)

	ship_install()
		..()
		if(istype(src.ship, /obj/machinery/vehicle/tank))
			var/obj/machinery/vehicle/tank/tank = src.ship
			var/image/loco_image = image('icons/obj/machines/8dirvehicles.dmi', "[tank.body_type]_[src.appearanceString]")
			loco_image.appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA
			loco_image.color = src.color
			loco_image.alpha = src.alpha
			loco_image.filters = src.filters.Copy()
			tank.UpdateOverlays(loco_image, "locomotion")
		src.activate() // Locomotion should always be active

	ship_uninstall()
		. = ..()
		src.ship.UpdateOverlays(null, "locomotion")

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

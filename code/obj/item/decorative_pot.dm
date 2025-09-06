TYPEINFO(/obj/decorative_pot)
	mats = list("any" = 1)
/obj/decorative_pot
		name = "plant pot"
		desc = "A decorative plant pot, sans the Hydroponic Tray's fancy hypergrowth tech."
		icon = 'icons/obj/hydroponics/machines_hydroponics.dmi'
		icon_state = "plantpot"
		anchored = UNANCHORED
		density = 1
		var/holding_plant = FALSE

		attackby(obj/item/weapon, mob/user)
				if((iswrenchingtool(weapon)) || isscrewingtool(weapon))
						if(!src.anchored)
								user.visible_message("<b>[user]</b> secures the [src] to the floor!")
								playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
								src.anchored = ANCHORED
						else
								user.visible_message("<b>[user]</b> unbolts the [src] from the floor!")
								playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
								src.anchored = UNANCHORED
						return
				if(istype(weapon,/obj/item/seed))
						boutput(user, "It's an empty pot, there's nowhere to plant the seed! Maybe you need to use a trowel and place an existing plant into it?")
				else
						..()

		/// Inserts a new plant into the pot, overriding any previous.
		proc/insert_plant(var/image/plant_image, var/image/plant_overlay_image, var/datum/plantgenes/genes, var/grow_level)
				src.holding_plant = TRUE
				if (plant_image)
						plant_image.pixel_x = 2
						src.UpdateOverlays(plant_image,"plant")
				if (plant_overlay_image)
						plant_overlay_image.pixel_x = 2
						src.UpdateOverlays(plant_overlay_image, "plantoverlay")
				genes.mutation?.HYPpotted_proc_M(src, grow_level)

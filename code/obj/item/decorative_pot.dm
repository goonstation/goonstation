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
				else if(istype(weapon,/obj/item/gardentrowel))
						var/obj/item/gardentrowel/trowel = weapon
						if(!trowel.holding_plant)
								return
						if (src.holding_plant)
								// This probably introduces more bugs than it fixes.
								src.ClearAllOverlays()
						src.holding_plant = TRUE
						src.UpdateOverlays(trowel.create_plant_image(),"plant")
						src.UpdateOverlays(trowel.create_plant_overlay_image(), "plantoverlay")
						trowel.genes.mutation?.HYPpotted_proc_M(src, trowel.grow_level)
						trowel.empty_trowel()
						playsound(src, 'sound/effects/shovel2.ogg', 50, TRUE, 0.3)
						return
				if(istype(weapon,/obj/item/seed))
						boutput(user, "It's an empty pot, there's nowhere to plant the seed! Maybe you need to use a trowel and place an existing plant into it?")
				else
						..()

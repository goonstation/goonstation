/obj/decorative_pot
		name = "plant pot"
		desc = "A decorative plant pot, sans the Hydroponic Tray's fancy hypergrowth tech."
		icon = 'icons/obj/hydroponics/machines_hydroponics.dmi'
		icon_state = "plantpot"
		anchored = 0
		density = 1
		mats = 2

		CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
				return 0
		attackby(obj/item/weapon as obj,mob/user as mob)
				if((iswrenchingtool(weapon)) || isscrewingtool(weapon))
						if(!src.anchored)
								user.visible_message("<b>[user]</b> secures the [src] to the floor!")
								playsound(src.loc, "sound/items/Screwdriver.ogg", 100, 1)
								src.anchored = 1
						else
								user.visible_message("<b>[user]</b> unbolts the [src] from the floor!")
								playsound(src.loc, "sound/items/Screwdriver.ogg", 100, 1)
								src.anchored = 0
						return
				else if(istype(weapon,/obj/item/gardentrowel))
						var/obj/item/gardentrowel/t = weapon
						if(!t.plantyboi)
								return
						src.UpdateOverlays(t.plantyboi,"plant")
						t.plantyboi = null
						t.icon_state = "trowel"
						return
				if(istype(weapon,/obj/item/seed))
						user.visible_message("It's an empty pot, there's nowhere to plant the seed! Maybe you need to use a trowel and place an existing plant into it?")
				else
						..()

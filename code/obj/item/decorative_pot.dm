TYPEINFO(/obj/decorative_pot)
	mats = list("any" = 1)
/obj/decorative_pot
		name = "plant pot"
		desc = "A decorative plant pot, sans the Hydroponic Tray's fancy hypergrowth tech."
		icon = 'icons/obj/hydroponics/machines_hydroponics.dmi'
		icon_state = "plantpot"
		anchored = UNANCHORED
		density = 1

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
						var/obj/item/gardentrowel/t = weapon
						if(!t.plantyboi)
								return
						src.UpdateOverlays(t.plantyboi,"plant")
						src.UpdateOverlays(t.plantyboi_plantoverlay, "plantoverlay")
						t.plantyboi = null
						t.plantyboi_plantoverlay = null
						t.icon_state = "trowel"
						playsound(src, 'sound/effects/shovel2.ogg', 50, TRUE, 0.3)
						t.genes.mutation?.HYPpotted_proc_M(src, t.grow_level)
						qdel(t.genes)
						t.genes = null
						return
				if(istype(weapon,/obj/item/seed))
						boutput(user, "It's an empty pot, there's nowhere to plant the seed! Maybe you need to use a trowel and place an existing plant into it?")
				else
						..()

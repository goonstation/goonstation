//ass jam thing: spacial disassociator

//transits people in an area to a parallel void version
//requires a Z2 area of radius one larger than the zone radius, with a disassociator anchor at the center
//walls should be illuminated dark-void

/obj/landmark/disassociator_anchor
	name = "spatial disassociator anchor"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x3"
	anchored = 1.0

/obj/spatial_disassociator
	name = "spatial disassociator"
	desc = "Some sort of elaborate device. The air near it shimmers strangely."
	icon = 'icons/obj/junk.dmi'
	icon_state = "disassociator"
	anchored = 0
	density = 1
	var/zoneradius = 6
	var/field_time = 250
	var/obj/anchorpoint

	attack_hand(mob/user as mob)
		anchorpoint = (locate(/obj/landmark/disassociator_anchor) in landmarks)

		if(src.anchored == 0)
			src.visible_message("<span style=\"color:red\"><b>[src]</b> activates!</span>")
			playsound(src,"sound/machines/spatial_disassociator.ogg",80,1)
			src.anchored = 1
			for(var/turf/T in circular_range(src,zoneradius))
				new /obj/spatial_disassociation(T,field_time)
				var/interx = src.x - T.x
				var/intery = src.y - T.y
				var/turf/peachspac = locate(anchorpoint.x-interx,anchorpoint.y-intery,anchorpoint.z)
				if(T.icon == 'icons/turf/floors.dmi' || T.icon == 'icons/turf/carpet.dmi')
					peachspac.density = 0
					peachspac.opacity = 0
					peachspac.name = "void"
					peachspac.icon_state = "void"
				else
					peachspac.density = 1
					peachspac.opacity = 1
					peachspac.name = "dense void"
					peachspac.icon_state = "darkvoid"
				for(var/mob/M in T)
					M.set_loc(peachspac)
					SPAWN_DBG(field_time)
						var/delta_x = anchorpoint.x - M.x
						var/delta_y = anchorpoint.y - M.y
						var/exiteering = locate(src.x-delta_x,src.y-delta_y,src.z)
						M.set_loc(exiteering)
			SPAWN_DBG(field_time)
				if (src)
					src.anchored = 0
					src.visible_message("<span style=\"color:red\"><b>[src]</b> deactivates!</span>")
		return

/obj/spatial_disassociation
	name = "spatial disassociation"
	desc = "Oh no"
	icon = 'icons/turf/floors.dmi'
	icon_state = "void"
	anchored = 1
	density = 1
	opacity = 0
	mouse_opacity = 1
	layer = NOLIGHT_EFFECTS_LAYER_BASE

	New(var/loc,var/duration)
		..()
		SPAWN_DBG(duration)
			qdel(src)



/datum/artifact/darkness_field
	associated_object = /obj/artifact/darkness_field
	rarity_class = 2
	max_triggers = 3
	validtypes = list("wizard","eldritch","precursor")
	react_xray = list(15,90,90,11,"NONE")



/obj/particle/chemical_reaction
	icon = 'icons/effects/chemistry_effects.dmi'
	plane = PLANE_OVERLAY_EFFECTS


/obj/particle/chemical_shine
	icon = 'icons/effects/chemistry_effects.dmi'
	icon_state = "shine"
	plane = PLANE_OVERLAY_EFFECTS


/obj/particle/cryo_sparkle
	icon = 'icons/effects/chemistry_effects.dmi'
	icon_state = "cryo-1"
	plane = PLANE_OVERLAY_EFFECTS

/obj/particle/cryo_sparkle/New()
	icon_state = pick("cryo-1", "cryo-2", "cryo-3", "cryo-4") //slightly different timings on these to give a less static look
	. = ..()


/obj/particle/fire_puff
	icon = 'icons/effects/chemistry_effects.dmi'
	icon_state = "flame-1"
	plane = PLANE_OVERLAY_EFFECTS

/obj/particle/fire_puff/New()
	icon_state = pick("flame-1", "flame-2", "flame-3", "flame-4")
	. = ..()


/obj/particle/heat_swirl
	icon = 'icons/effects/chemistry_effects.dmi'
	icon_state = "heat-1"
	plane = PLANE_OVERLAY_EFFECTS

/obj/particle/heat_swirl/New()
	icon_state = pick("heat-1", "heat-2", "heat-3", "heat-4")
	. = ..()


ADD_TO_NAMESPACE(ANIMATE)(proc/chemistry_particle(datum/reagents/holder, datum/chemical_reaction/reaction))
	if(!istype(holder.my_atom, /obj) || !holder.my_atom.loc)
		return
	var/obj/holder_object = holder.my_atom

	var/obj/particle/chemical_reaction/chemical_reaction = new /obj/particle/chemical_reaction
	var/y_offset = 0

	if(!reaction.reaction_icon_color)
		chemical_reaction.color = holder.get_average_rgb()
	else
		chemical_reaction.color = reaction.reaction_icon_color

	y_offset = holder_object.get_chemical_effect_position()
	chemical_reaction.set_loc(holder_object.loc)
	chemical_reaction.icon_state = pick(reaction.reaction_icon_state)
	chemical_reaction.pixel_x = holder_object.pixel_x
	chemical_reaction.pixel_y = holder_object.pixel_y + y_offset

	SPAWN(2 SECONDS)
		qdel(chemical_reaction)

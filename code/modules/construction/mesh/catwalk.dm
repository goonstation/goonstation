

TYPEINFO(/obj/mesh/catwalk)
TYPEINFO_NEW(/obj/mesh/catwalk)
	. = ..()
	connects_to_obj = typecacheof(list(/obj/mesh/catwalk, /obj/machinery/door))
/obj/mesh/catwalk
	name = "catwalk surface"
	icon = 'icons/obj/catwalk.dmi'
	icon_state = "C15-0"
	layer = CATWALK_LAYER
	plane = PLANE_FLOOR
	event_handler_flags = IMMUNE_MINERAL_MAGNET
	default_material = "steel"
	uses_default_material_appearance = FALSE
	mat_changename = FALSE

	HELP_MESSAGE_OVERRIDE("You can use <b>wirecutters</b> to quickly dismantle it. \
	You can also attack it with other items on <span class='harm'>harm</span> intent.")

	amount_of_rods_when_destroyed = 1
	icon_state_prefix = "C"// Short for "Catwalk"

/obj/mesh/catwalk/New()
	. = ..()
	APPLY_ATOM_PROPERTY(src, PROP_ATOM_DO_LIQUID_CLICKS, src) // fuck this object

/obj/mesh/catwalk/attackby(obj/item/I, mob/user)
	if (issnippingtool(I))
		src.damage_slashing(src.health_max)
		src.visible_message(SPAN_ALERT("<b>[user]</b> cuts apart the [src] with [I]."))
		playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
		return
	if (istype(I, /obj/item/cable_coil))
		src.loc.Attackby(user.equipped(), user)
		return
	if (istype(I,/obj/item/mop))
		I.AfterAttack(get_turf(src), user)
		return
	if(user.a_intent != "harm") // Don't do anything if you're not on harm intent, act like a normal floor.
		return
	..()

/obj/mesh/catwalk/special_update_icon(special_icon_state)
	if(special_icon_state == "cut")
		src.UpdateIcon()
		return // no special sprites for cut catwalks
	src.icon_state = "[src.icon_state_prefix][src.get_icon_direction()]-[special_icon_state]"

/obj/mesh/catwalk/get_icon_direction()
	return src.get_icon_connectdir()

/obj/mesh/catwalk/jen // ^^ no i made my own because i am epic
	name = "maintenance catwalk"
	icon_state = "M0-0"
	desc = "This looks marginally more safe than the ones outside, at least..."
	icon_state_prefix = "M" // Short for "Maintenance"

/obj/mesh/catwalk/jen/attackby(obj/item/I, mob/user)
	if(issnippingtool(I))
		..()
		return
	if(isturf(src.loc))
		src.loc.Attackby(user.equipped(), user)

/obj/mesh/catwalk/dubious
	name = "rusty catwalk"
	desc = "This one looks even less safe than usual."
	event_handler_flags = USE_FLUID_ENTER | IMMUNE_MINERAL_MAGNET
	///How far are we along to collapsing
	var/collapse_counter = 0

/obj/mesh/catwalk/dubious/New()
	src.health = rand(5, 10)
	..()
	src.UpdateIcon()

/obj/mesh/catwalk/dubious/Crossed(atom/movable/AM)
	..()
	if (isliving(AM) && !isintangible(AM))
		src.collapse_counter++
		SPAWN (1 SECOND)
			src.collapse_timer()
			if(src.collapse_counter)
				playsound(src.loc, 'sound/effects/creaking_metal1.ogg', 25, 1)

/obj/mesh/catwalk/dubious/proc/collapse_timer()
	var/still_collapsing = FALSE
	for (var/mob/M in src.loc)
		src.collapse_counter++
		still_collapsing = TRUE

	if (!still_collapsing)
		src.collapse_counter--

	if (src.collapse_counter >= 5)
		playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 50, 1)
		src.visible_message("[src] collapses!", "[src] thuds loudly!")
		qdel(src)

	if(src.collapse_counter)
		SPAWN(1 SECOND)
			src.collapse_timer()

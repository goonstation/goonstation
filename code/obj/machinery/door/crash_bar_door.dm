
TYPEINFO(/obj/machinery/door/crash_bar)
	mat_appearances_to_ignore = list("steel")
/obj/machinery/door/crash_bar
	name = "door"
	icon = 'icons/obj/doors/door_crash.dmi'
	desc = "A door with a crash bar on one side, which requires no access to open."
	icon_state = "door1"
	opacity = 0
	visible = FALSE
	panel_open = FALSE
	operating = 0
	flags = FLUID_DENSE
	layer = EFFECTS_LAYER_UNDER_1
	anchored = ANCHORED
	autoclose = TRUE
	material_amt = MATERIAL::AMOUNT::SHEET * 6
	default_material = "steel"
	deconstruct_flags = DECON_WRENCH | DECON_CROWBAR | DECON_SCREWDRIVER | DECON_WIRECUTTERS

/obj/machinery/door/gas_cross()
	return TRUE

/obj/machinery/door/crash_bar/allowed(mob/M)
	if (get_dir(M, src) & src.dir)
		return 1
	if (!density)
		return 1
	return ..()

/obj/machinery/door/crash_bar/Bumped(atom/movable/AM)
	if (get_dir(AM, src) & src.dir)
		if (isitem(AM))
			if (astype(AM, /obj/item).w_class >= W_CLASS_NORMAL)
				return src.bumpopen(AM)
		else
			return src.bumpopen(AM)
	..()

/obj/machinery/door/crash_bar/open()
	if(src.locked) return
	playsound(src, 'sound/machines/door_open.ogg', 50, TRUE)
	. = ..()

/obj/machinery/door/crash_bar/close()
	playsound(src, 'sound/machines/door_close.ogg', 50, TRUE)
	. = ..()

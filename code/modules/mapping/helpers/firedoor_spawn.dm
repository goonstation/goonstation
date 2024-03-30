/obj/mapping_helper/firedoor_spawn
	name = "firedoor spawn"
	desc = "Place this over a door to spawn a firedoor underneath. Sets direction, too!"
	icon = 'icons/obj/doors/Doorfire.dmi'
	icon_state = "f_spawn"

/obj/mapping_helper/firedoor_spawn/setup()
	for (var/obj/machinery/door/D in src.loc)
		var/obj/machinery/door/firedoor/pyro/P = new/obj/machinery/door/firedoor/pyro(src.loc)
		P.set_dir(D.dir)
		P.layer = D.layer + 0.01
		#ifdef UPSCALED_MAP
		P.bound_height = 64
		P.bound_width = 64
		P.transform = list(2, 0, 16, 0, 2, 16)
		#endif
		break

/obj/mapping_helper/algae
	name = "bioluminescent algae"
	icon = 'icons/obj/sealab_objects.dmi'
	icon_state = "algae"

/obj/mapping_helper/algae/setup()
	var/obj/window/auto/window = locate() in get_turf(src)
	global.algae_controller().algae_wall(window || get_turf(src), force = TRUE)

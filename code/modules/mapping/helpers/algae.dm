/obj/mapping_helper/algae
	name = "bioluminescent algae"
	icon = 'icons/obj/sealab_objects.dmi'
	icon_state = "algae"

	setup()
		algae_controller().algae_wall(get_turf(src), force = TRUE)

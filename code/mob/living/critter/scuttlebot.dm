/mob/living/critter/small_animal
	name = "critter"
	real_name = "critter"
	desc = "you shouldn't be seeing this!"
	density = 0
	custom_gib_handler = /proc/gibs
	hand_count = 1
	can_help = 1
	can_throw = 1
	can_grab = 1
	can_disarm = 1
	butcherable = 1
	name_the_meat = 1
	max_skins = 1
	var/health_brute = 20 // moved up from birds since more than just they can use this, really
	var/health_brute_vuln = 1
	var/health_burn = 20
	var/health_burn_vuln = 1

	var/fur_color = 0
	var/eye_color = 0

	var/is_pet = null // null = autodetect



	New(loc)
		if(isnull(src.is_pet))
			src.is_pet = (copytext(src.name, 1, 2) in uppercase_letters)
		if(in_centcom(loc) || current_state >= GAME_STATE_PLAYING)
			src.is_pet = 0
		if(src.is_pet)
			START_TRACKING_CAT(TR_CAT_PETS)
		..()

		src.add_stam_mod_max("small_animal", -(STAMINA_MAX*0.5))

	disposing()
		if(src.is_pet)
			STOP_TRACKING_CAT(TR_CAT_PETS)
		..()

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)
		add_health_holder(/datum/healthHolder/toxin)
		add_health_holder(/datum/healthHolder/brain)

	Cross(atom/mover)
		if (!src.density && istype(mover, /obj/projectile))
			return prob(50)
		else
			return ..()

	death(var/gibbed)
		if (!gibbed)
			src.unequip_all()
		..()

	canRideMailchutes()
		return src.fits_under_table

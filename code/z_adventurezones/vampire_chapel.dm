/area/vampchapel
	name = "Cathedral of Blood"
	icon_state = "red"
	force_fullbright = 1
	sound_environment = 5
	may_eat_here_in_restricted_z = 1
	allowed_restricted_z = TRUE


/obj/fakeobject/deadsecurity
	name = "dead body"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "seccorpse1"

	New()
		..()
		src.icon_state = "seccorpse[rand(1,7)]"



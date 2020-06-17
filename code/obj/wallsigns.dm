/obj/securearea
	desc = "A warning sign which reads 'SECURE AREA'"
	name = "SECURE AREA"
	icon = 'icons/obj/decals/wallsigns.dmi'
	icon_state = "securearea"
	anchored = 1.0
	opacity = 0
	density = 0
	layer = EFFECTS_LAYER_BASE
	plane = PLANE_NOSHADOW_BELOW

/obj/joeq
	desc = "Here lies Joe Q. Loved by all. He was a terrorist. R.I.P."
	name = "Joe Q. Memorial Plaque"
	icon = 'icons/obj/decals/wallsigns.dmi'
	icon_state = "rip"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/fudad
	desc = "In memory of Arthur \"F. U. Dad\" Muggins, the bravest, toughest Vice Cop SS13 has ever known. Loved by all. R.I.P."
	name = "Arthur Muggins Memorial Plaque"
	icon = 'icons/obj/decals/wallsigns.dmi'
	icon_state = "rip"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/juggleplaque
	desc = "In loving and terrified memory of those who discovered the dark secret of Jugglemancy. \"E. Shirtface, Juggles the Clown, E. Klein, A.F. McGee,  J. Flarearms.\""
	name = "Funny-Looking Memorial Plaque"
	icon = 'icons/obj/decals/wallsigns.dmi'
	icon_state = "rip"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/cairngorm_stats
	name = "scoreboard of sorts"
	icon = 'icons/obj/decals/wallsigns.dmi'
	icon_state = "rip"
	anchored = 1.0
	opacity = 0
	density = 0

	New()
		..()
		var/wins = world.load_intra_round_value("nukie_win")
		var/losses = world.load_intra_round_value("nukie_loss")
		if(isnull(wins))
			wins = 0
		if(isnull(losses))
			losses = 0
		src.desc = "Successful missions: [wins]<br>\nUnsuccessful missions: [losses]"

	attack_hand(mob/user)
		examine(user)
		. = ..()

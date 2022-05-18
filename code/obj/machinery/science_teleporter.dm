/obj/decal/residual_energy
	name = "residual energy"
	desc = "faintly glowing residual energy."
	anchored = 1
	density = 0
	opacity = 0
	icon = 'icons/effects/effects.dmi'
	icon_state = "residual"

/obj/decal/teleport_swirl
	name = "swirling energy"
	anchored = 1
	density = 0
	opacity = 0
	layer = EFFECTS_LAYER_BASE
	icon = 'icons/effects/effects.dmi'
	icon_state = "portswirl"

	out
		icon_state = "portswirl_out"

	error //invalid coordinates
		icon_state = "portswirl_error"

/datum/teleporter_bookmark
	var/x = 0
	var/y = 0
	var/z = 0
	var/name = "BLANK"

var/XMULTIPLY = 1
var/XSUBTRACT = 0
var/YMULTIPLY = 1
var/YSUBTRACT = 0
var/ZMULTIPLY = 1
var/ZSUBTRACT = 0

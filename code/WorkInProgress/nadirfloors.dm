DEFINE_FLOORS(r_floor,
	name = "reinforced floor";\
	icon = 'icons/turf/floors.dmi';\
	icon_state = "rfloor";\
	step_material = "step_plating";\
	step_priority = STEP_PRIORITY_MED)

DEFINE_FLOORS(r_floor/dark,
	icon_state = "rfloor_d")

DEFINE_FLOORS(r_floor/purple,
	icon_state = "rfloor_purp_side")

DEFINE_FLOORS(r_floor/purple/corner,
	icon_state = "rfloor_purp_corner")

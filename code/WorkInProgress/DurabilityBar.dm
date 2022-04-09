/obj/overlay/durability_bar
	name = "durability bar"
	icon = 'icons/ui/durabar.dmi'
	icon_state = "durabar-0"
	invisibility = INVIS_ALWAYS
	plane = PLANE_HUD
	layer = HUD_LAYER_3
	appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	var/start_health = null
	var/current_health = null

	New()
		..()

	proc/update_durability(var/upd_health,var/init_health)
		if(init_health)
			src.start_health = init_health
		if(!src.start_health)
			return
		var/barmod = ceil((current_health/start_health)*20)
		src.icon_state = "durabar-[barmod]"

	proc/hide_bar()
		invisibility = INVIS_ALWAYS

	proc/show_bar()
		invisibility = INVIS_NONE

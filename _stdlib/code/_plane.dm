#define PLANE_FLOOR -10
#define PLANE_NOSHADOW_BELOW -1
#define PLANE_DEFAULT 0
#define PLANE_NOSHADOW_ABOVE 1
#define PLANE_HIDDENGAME 2
#define PLANE_LIGHTING 10
#define PLANE_SELFILLUM 20
#define PLANE_FLOCKVISION 25
#define PLANE_HUD 30
#define PLANE_SCREEN_OVERLAYS 40

/obj/screen/plane_parent
	name = ""
	icon = null
	screen_loc = "1,1"

	// hey you know what would be really cool? if these could be overlays on the same object so we could animate them sanely
	// haha fuck you of course mouse_opacity on overlays is never gonna work
	// fucking christ lummox
	New(plane, appearance_flags = 0, blend_mode = BLEND_DEFAULT, color, mouse_opacity = 1, name = "unnamed_plane")
		src.name = name
		src.plane = plane
		src.appearance_flags = PLANE_MASTER | appearance_flags
		src.blend_mode = blend_mode
		src.color = color
		src.mouse_opacity = mouse_opacity
		src.render_target = name

	proc/add_depth_shadow()
		src.filters += filter(type="drop_shadow", x=2, y=-2, color=rgb(4, 8, 16, 150), size=5, offset=1)

client
	var/list/plane_parents = list()

	New()
		plane_parents += new /obj/screen/plane_parent(PLANE_FLOOR, name = "floor_plane")
		plane_parents += new /obj/screen/plane_parent(PLANE_DEFAULT, name = "game_plane")
		plane_parents += new /obj/screen/plane_parent(PLANE_LIGHTING, appearance_flags = NO_CLIENT_COLOR, blend_mode = BLEND_MULTIPLY, mouse_opacity = 0, name = "lighting_plane")
		plane_parents += new /obj/screen/plane_parent(PLANE_SELFILLUM, appearance_flags = NO_CLIENT_COLOR, blend_mode = BLEND_ADD, mouse_opacity = 0, name = "selfillum_plane")
		plane_parents += new /obj/screen/plane_parent(PLANE_FLOCKVISION, appearance_flags = NO_CLIENT_COLOR, blend_mode = BLEND_OVERLAY, mouse_opacity = 0, name = "flockvision_plane")
		plane_parents += new /obj/screen/plane_parent(PLANE_HUD, appearance_flags = NO_CLIENT_COLOR, name = "hud_plane")
		plane_parents += new /obj/screen/plane_parent(PLANE_SCREEN_OVERLAYS, appearance_flags = NO_CLIENT_COLOR, mouse_opacity = 0, name = "screen_overlays_plane")

		var/obj/screen/plane_parent/P = new /obj/screen/plane_parent(PLANE_HIDDENGAME, name = "hidden_game_plane")
		P.render_target = "*[P.render_target]"
		plane_parents += P

		SPAWN_DBG(5 SECONDS) //Because everything needs to wait!
			apply_depth_filter()
		..()

	proc/apply_depth_filter()
		var/shadows_checked = winget( src, "menu.set_shadow", "is-checked" ) == "true"
		for (var/obj/screen/plane_parent/P in plane_parents)
			if (P.name == "game_plane")
				if (shadows_checked)
					P.add_depth_shadow()
				else
					P.filters = null
				break

	proc/setup_special_screens()
		for (var/atom in plane_parents)
			var/atom/A = atom
			screen += A

	proc/get_plane(var/plane)
		for (var/atom/A in plane_parents)
			if(A.plane == plane) return A
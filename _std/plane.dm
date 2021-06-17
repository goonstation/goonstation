#define PLANE_UNDERFLOOR -120 // that's where floorcluwnes live
#define PLANE_SPACE -115
#define PLANE_FLOOR -110
#define PLANE_WALL -105
#define PLANE_NOSHADOW_BELOW -101
#define PLANE_DEFAULT -100
#define PLANE_NOSHADOW_ABOVE -99
#define PLANE_HIDDENGAME -98
#define PLANE_LIGHTING -90
#define PLANE_SELFILLUM -80
#define PLANE_BLACKNESS 0 // black tiles outisde of your vision render here
#define PLANE_MASTER_GAME 10
#define PLANE_FLOCKVISION 22
#define PLANE_OVERLAY_EFFECTS 25
#define PLANE_HUD 30
#define PLANE_SCREEN_OVERLAYS 40

/atom/movable/screen/plane_parent
	name = ""
	icon = null
	screen_loc = "1,1"
	var/is_screen

	// hey you know what would be really cool? if these could be overlays on the same object so we could animate them sanely
	// haha fuck you of course mouse_opacity on overlays is never gonna work
	// fucking christ lummox
	New(plane, appearance_flags = 0, blend_mode = BLEND_DEFAULT, color, mouse_opacity = 1, name = "unnamed_plane", is_screen = 0)
		src.name = name
		src.plane = plane
		src.appearance_flags = PLANE_MASTER | appearance_flags
		src.blend_mode = blend_mode
		src.color = color
		src.mouse_opacity = mouse_opacity
#ifdef COOL_PLANE_STUFF
		if(is_screen)
			src.render_target = "[name]"
		else
			src.render_target = "*[name]"
#else
		src.render_target = "[name]"
#endif
		src.is_screen = is_screen
		..()

	proc/add_depth_shadow()
		src.filters += filter(type="drop_shadow", x=2, y=-2, color=rgb(4, 8, 16, 150), size=4, offset=1)


/atom/movable/screen/plane_display
	plane = PLANE_MASTER_GAME

	New(atom/movable/screen/plane_parent/pl)
		if(pl)
			src.name = pl.name
			src.render_source = pl.render_target
			src.appearance_flags = pl.appearance_flags | PASS_MOUSE
			src.blend_mode = pl.blend_mode
			src.mouse_opacity = pl.mouse_opacity
		..()

/atom/movable/screen/plane_display/master
	screen_loc = "NORTH-0,1"
	var/keep_together_requests = 0

	proc/request_keep_together()
		src.keep_together_requests++
		src.appearance_flags |= KEEP_TOGETHER

	proc/release_keep_together()
		src.keep_together_requests--
		if(!src.keep_together_requests)
			src.appearance_flags &= ~KEEP_TOGETHER

client
	var/list/plane_parents = list()
	var/list/plane_displays = list()
	var/atom/movable/screen/plane_display/master/game_display

	New()
		Z_LOG_DEBUG("Cient/New", "[src.ckey] - Adding plane_parents")
		plane_parents += new /atom/movable/screen/plane_parent(PLANE_UNDERFLOOR, name = "underfloor_plane")
		plane_parents += new /atom/movable/screen/plane_parent(PLANE_SPACE, name = "space_plane")
		plane_parents += new /atom/movable/screen/plane_parent(PLANE_FLOOR, name = "floor_plane")
		plane_parents += new /atom/movable/screen/plane_parent(PLANE_WALL, name = "wall_plane")
		plane_parents += new /atom/movable/screen/plane_parent(PLANE_NOSHADOW_BELOW, name = "noshadow_below_plane")
		plane_parents += new /atom/movable/screen/plane_parent(PLANE_DEFAULT, name = "game_plane")
		plane_parents += new /atom/movable/screen/plane_parent(PLANE_NOSHADOW_ABOVE, name = "noshadow_above_plane")
		plane_parents += new /atom/movable/screen/plane_parent(PLANE_LIGHTING, appearance_flags = NO_CLIENT_COLOR, blend_mode = BLEND_MULTIPLY, mouse_opacity = 0, name = "lighting_plane")
		plane_parents += new /atom/movable/screen/plane_parent(PLANE_SELFILLUM, appearance_flags = NO_CLIENT_COLOR, blend_mode = BLEND_ADD, mouse_opacity = 0, name = "selfillum_plane")
		plane_parents += new /atom/movable/screen/plane_parent(PLANE_BLACKNESS, appearance_flags = NO_CLIENT_COLOR, mouse_opacity = 0, name = "blackness_plane")
		plane_parents += new /atom/movable/screen/plane_parent(PLANE_FLOCKVISION, appearance_flags = NO_CLIENT_COLOR, blend_mode = BLEND_OVERLAY, mouse_opacity = 0, name = "flockvision_plane")
		plane_parents += new /atom/movable/screen/plane_parent(PLANE_OVERLAY_EFFECTS, mouse_opacity = 0, name = "overlay_effects_plane", is_screen = 1)
		plane_parents += new /atom/movable/screen/plane_parent(PLANE_HUD, appearance_flags = NO_CLIENT_COLOR, name = "hud_plane", is_screen = 1)
		plane_parents += new /atom/movable/screen/plane_parent(PLANE_SCREEN_OVERLAYS, appearance_flags = NO_CLIENT_COLOR, mouse_opacity = 0, name = "screen_overlays_plane", is_screen = 1)

#ifdef COOL_PLANE_STUFF
		game_display = new
		src.screen += game_display

		for(var/atom/movable/screen/plane_parent/pl as anything in src.plane_parents)
			var/atom/movable/screen/plane_display/display = new(pl)
			plane_displays += display
			if(!pl.is_screen)
				game_display.vis_contents += display
#endif

		var/atom/movable/screen/plane_parent/P = new /atom/movable/screen/plane_parent(PLANE_HIDDENGAME, name = "hidden_game_plane")
		plane_parents += P

		SPAWN_DBG(5 SECONDS) //Because everything needs to wait!
			apply_depth_filter()
		..()

	proc/apply_depth_filter()
		var/shadows_checked = winget( src, "menu.set_shadow", "is-checked" ) == "true"
		for (var/atom/movable/screen/plane_parent/P in plane_parents)
			if (P.name == "game_plane" || P.name == "wall_plane")
				if (shadows_checked)
					P.add_depth_shadow()
				else
					P.filters = null

	proc/setup_special_screens()
		for (var/atom/A as anything in plane_parents)
			screen += A

	proc/get_plane(var/plane)
		for (var/atom/A as anything in plane_parents)
			if(A.plane == plane) return A

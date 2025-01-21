/// Maximum pixel distance from 0 that a bullet hole can appear at
#define MAX_OFFSET 14

TYPEINFO(/datum/component/bullet_holes)
	initialization_args = list(
		ARG_INFO("max_holes", DATA_INPUT_NUM, "The maximum number of holes that can appear on this object", 10),
		ARG_INFO("req_damage", DATA_INPUT_NUM, "The minimum damage required for a projectile to leave a decal (for armored things)", 0)
	)


/// A component which makes bullet holes appear on a thing when it gets shot
/datum/component/bullet_holes
	/// The maximum number of bullet impact decals this object can have at once
	var/max_holes = 10
	/// Minimum projectile DAMAGE (not power) required to leave a bullet hole
	var/req_damage = 0
	/// List of individual impact decals
	var/list/impact_images
	/// Image which holds all of the impact decals (as overlays) to display them
	var/image/impact_image_base
	/// Used to track where in the list we insert the impact decals
	var/decal_num = 0
	/// Limit the number of redraws to prevent lag
	var/recent_redraws = 0

/datum/component/bullet_holes/Initialize(max_holes, req_damage)
	. = ..()
	if (!isatom(src.parent))
		return COMPONENT_INCOMPATIBLE
	src.max_holes = max_holes
	src.req_damage = req_damage

	src.impact_images = new/list(max_holes)

	src.impact_image_base = image('icons/obj/projectiles.dmi', "blank")
	src.impact_image_base.blend_mode = BLEND_INSET_OVERLAY // so the holes don't go over the edge of things

	RegisterSignal(parent, COMSIG_ATOM_HITBY_PROJ, PROC_REF(handle_impact))
	RegisterSignal(parent, COMSIG_UPDATE_ICON, PROC_REF(redraw_impacts)) // just in case
	RegisterSignal(parent, COMSIG_TURF_REPLACED, PROC_REF(RemoveComponent))

/datum/component/bullet_holes/UnregisterFromParent()
	impact_image_base = null
	impact_images.Cut()
	UnregisterSignal(parent, COMSIG_ATOM_HITBY_PROJ)
	UnregisterSignal(parent, COMSIG_UPDATE_ICON)
	UnregisterSignal(parent, COMSIG_TURF_REPLACED)
	. = ..()


/datum/component/bullet_holes/proc/handle_impact(rendering_on, obj/projectile/shot)
	var/datum/projectile/shotdata = shot.proj_data

	// Apply offset based on dir. The side we want to put holes on is opposite the dir of the bullet
	// i.e. left facing bullet hits right side of wall
	var/impact_side_dir = opposite_dir_to(shot.dir) // which edge of this object are we drawing the decals on
	var/impact_decal = TRUE

	var/impact_target_height = 0 //! how 'high' on the wall we're hitting. in pixels from the outermost border
	var/impact_random_cap = 0 //! how much we can safely move an impact up/down
	var/max_sane_spread = 15 //! the spread value that caps how crazy the impact pattern is
	var/impact_normal = 0 //! the way 'outwards' from the wall
	switch(impact_side_dir)
		if(WEST)
			impact_target_height = 6
			impact_random_cap = 5
			impact_normal = 180
		if (EAST)
			impact_target_height = 6
			impact_random_cap = 5
			impact_normal = 0
		if (NORTH)
			impact_decal = FALSE
			impact_target_height = 4
			impact_random_cap = 3
			impact_normal = 90
		if (SOUTH)
			impact_target_height = 11
			impact_random_cap = 8 // front face has a lot of room for impacts
			impact_normal = 270

	var/spread_peak = sqrt(shot.spread/max_sane_spread) * impact_random_cap
	// as covered earlier - this is how 'high' up the wall the bullet hits. as if you were aiming for head/body shots.
	var/impact_final_height = impact_target_height + rand(-spread_peak, spread_peak)

	var/turf/parent_turf = get_turf(src.parent)
	//distance from centre of wall to bullet's location
	var/x_distance = (shot.orig_turf.x*32 + shot.wx) - parent_turf.x*32
	var/y_distance = (shot.orig_turf.y*32 + shot.wy) - parent_turf.y*32

	var/shot_angle = arctan(shot.xo, shot.yo)
	//distance from chosen 'height' of wall, to bullet location.
	var/distance = (x_distance * cos(impact_normal))+(y_distance*sin(impact_normal)) - (16-impact_final_height)
	//final offsets for the impact decal
	var/impact_offset_x = (cos(shot_angle)  * distance)
	var/impact_offset_y = (sin(shot_angle)  * distance)

	// Add the offsets to the impact's position. abs(sin(impact_normal)) strips the y component of the offset if we're hitting a horizontal wall, and vice versa for cos
	var/image/impact = image('icons/obj/projectiles.dmi', shot.proj_data.impact_image_state)
	impact.pixel_x += (impact_offset_x + x_distance)*abs(sin(impact_normal)) + (16-impact_final_height)*cos(impact_normal)
	impact.pixel_y += (impact_offset_y + y_distance)*abs(cos(impact_normal)) + (16-impact_final_height)*sin(impact_normal)

	shotdata.spawn_impact_particles(src.parent, shot, impact.pixel_x, impact.pixel_y)

	if (!shotdata.impact_image_state)
		return
	// Don't add an impact decal if projectile DAMAGE (not power) is insufficient
	if (shotdata.ks_ratio * shotdata.get_power(shot, src.parent) < src.req_damage) // TODO figure out how and when power is calculated/stored for proj objects. Shit's confusing
		return

	// Rotate the decal randomly for variety
	impact.transform = turn(impact.transform, rand(360, 1))

	// Add bullet hole to list, then increment index to insert at. Modulo ensures that we don't go out of bounds and replace from the head of the list first.
	if (impact_decal)
		src.impact_images[(decal_num++ % max_holes) + 1] = impact
		src.redraw_impacts()

/datum/component/bullet_holes/proc/redraw_impacts()

	if (recent_redraws > 10)
		return
	recent_redraws++
	SPAWN(1 SECOND)
		recent_redraws--


	var/atom/A = src.parent
	src.impact_image_base.overlays = null
	for (var/image/impact_image in src.impact_images)
		src.impact_image_base.overlays += impact_image
	A.AddOverlays(src.impact_image_base, "projectiles")

#undef MAX_OFFSET

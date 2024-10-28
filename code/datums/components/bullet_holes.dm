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
	if (!shotdata.impact_image_state)
		return
	// Don't add an impact decal if projectile DAMAGE (not power) is insufficient
	if (shotdata.ks_ratio * shotdata.get_power(shot, src.parent) < src.req_damage) // TODO figure out how and when power is calculated/stored for proj objects. Shit's confusing
		return

	var/image/impact = image('icons/obj/projectiles.dmi', shot.proj_data.impact_image_state)
	// Rotate the decal randomly for variety
	impact.transform = turn(impact.transform, rand(360, 1))

	// Apply offset based on dir. The side we want to put holes on is opposite the dir of the bullet
	// i.e. left facing bullet hits right side of wall
	var/impact_side_dir = opposite_dir_to(shot.dir) // which edge of this object are we drawing the decals on
	impact.pixel_x += impact_side_dir & WEST ?  rand(0, -MAX_OFFSET) : (impact_side_dir & EAST ? rand(MAX_OFFSET) : rand(-MAX_OFFSET, MAX_OFFSET))
	impact.pixel_y += impact_side_dir & SOUTH ?  rand(0, -MAX_OFFSET) : (impact_side_dir & NORTH ? rand(MAX_OFFSET) : rand(-MAX_OFFSET, MAX_OFFSET))

	// Add bullet hole to list, then increment index to insert at. Modulo ensures that we don't go out of bounds and replace from the head of the list first.
	src.impact_images[(decal_num++ % max_holes) + 1] = impact
	src.redraw_impacts()

/datum/component/bullet_holes/proc/redraw_impacts()
	var/atom/atom_parent = src.parent
	if (ON_COOLDOWN(atom_parent, "bullet hole render", 0.2 SECONDS))
		return

	var/atom/A = src.parent
	src.impact_image_base.overlays = null
	for (var/image/impact_image in src.impact_images)
		src.impact_image_base.overlays += impact_image
	A.AddOverlays(src.impact_image_base, "projectiles")

#undef MAX_OFFSET

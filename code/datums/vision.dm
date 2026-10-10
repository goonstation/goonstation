/datum/vision_modifier
	/// relative weight of the vision modifier, affects mostly centerlight icon and color calculations
	var/weight = 1
	/// bitfield of SEE_TURFS etc., applies onto mob.sight
	var/sight = SEE_BLACKNESS
	/// bitfield of SEE_TURFS etc., applies negatively onto mob.sight
	var/negative_sight = 0
	/// how far the mob can see in the dark, greatest applies onto mob.see_in_dark
	var/see_in_dark = 0
	/// a bonus/malus applied onto see_in_dark
	var/see_in_dark_bonus = 0
	/// Invisibility sense, greatest applies onto mob.see_invisible
	var/see_invisible = INVIS_NONE
	/// byond infravision
	var/see_infrared = 0
	///centerlight icon
	var/centerlight_icon
	///centerlight icon color
	var/centerlight_color
	///whether this vision only works in unrestricted Z levels
	var/z_restricted = FALSE

/// When the vision is first applied onto the mob
/datum/vision_modifier/proc/on_apply(mob/user, source)
	return

/// When the last source is removed and the vision itself goes away
/datum/vision_modifier/proc/on_remove(mob/user, source)
	return

/// X-ray vision, also for dead people
/datum/vision_modifier/xray
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS
	see_in_dark = SEE_DARK_FULL
	z_restricted = TRUE
	see_invisible = INVIS_MESON

/datum/vision_modifier/xray/on_apply(mob/user, source)
	APPLY_ATOM_PROPERTY(user, PROP_MOB_XRAYVISION, source)

/datum/vision_modifier/xray/on_remove(mob/user, source)
	REMOVE_ATOM_PROPERTY(user, PROP_MOB_XRAYVISION, source)

/// weak X-ray vision
/datum/vision_modifier/xray/weak
	sight = SEE_TURFS
	see_invisible = INVIS_NONE

/// Thermalvision
/datum/vision_modifier/thermal
	see_in_dark_bonus = 4
	see_invisible = INVIS_CLOAK
	centerlight_icon = "thermal"
	centerlight_color = rgb(0.5 * 255, 0.5 * 255, 0.5 * 255)

/// Mk2 thermalvision, also gives byond infravision (see mobs through walls)
/datum/vision_modifier/thermal/mk2
	see_infrared = 1

/datum/vision_modifier/thermal/mk2/on_apply(mob/user, source)
	get_image_group(CLIENT_IMAGE_GROUP_MOB_OVERLAY).add_mob(user)

/datum/vision_modifier/thermal/mk2/on_remove(mob/user, source)
	get_image_group(CLIENT_IMAGE_GROUP_MOB_OVERLAY).remove_mob(user)

/datum/vision_modifier/nightvision
	centerlight_icon = "nightvision"
	centerlight_color = rgb(0.5 * 255, 0.5 * 255, 0.5 * 255)

/datum/vision_modifier/blob_overmind
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
	see_invisible = INVIS_SPOOKY
	see_in_dark = SEE_DARK_FULL
	centerlight_icon = "thermal"
	centerlight_color = rgb(0.5 * 255, 0.5 * 255, 0.5 * 255)

/datum/vision_modifier/blob_overmind_tutorial
	negative_sight = SEE_TURFS | SEE_MOBS | SEE_OBJS


// Could perhaps be combined with above
/datum/vision_modifier/flock_tutorial
	sight = SEE_SELF | SEE_BLACKNESS
	negative_sight = SEE_TURFS | SEE_MOBS | SEE_OBJS

/datum/vision_modifier/nightvision/weak
	centerlight_icon = "thermal"

/datum/vision_modifier/meson
	z_restricted = TRUE
	sight = SEE_TURFS
	negative_sight = SEE_BLACKNESS
	see_invisible = INVIS_MESON
	see_in_dark_bonus = 1
	centerlight_icon = "nightvision"
	centerlight_color = rgb(0.5 * 255, 0.5 * 255, 0.5 * 255)

/datum/vision_modifier/meson/on_apply(mob/user, source)
	get_image_group(CLIENT_IMAGE_GROUP_MECHCOMP).add_mob(user)
	get_image_group(CLIENT_IMAGE_GROUP_GEOLOGICAL_ANOMALIES).add_mob(user)

/datum/vision_modifier/meson/on_remove(mob/user, source)
	get_image_group(CLIENT_IMAGE_GROUP_MECHCOMP).remove_mob(user)
	get_image_group(CLIENT_IMAGE_GROUP_GEOLOGICAL_ANOMALIES).remove_mob(user)

/// Infravision, for some reason this is not the same as byond infravision (see_infrared = 1)
/datum/vision_modifier/infra
	see_invisible = INVIS_INFRA

/datum/vision_modifier/adventure
	see_invisible = INVIS_ADVENTURE
	z_restricted = TRUE

/datum/vision_modifier/construction
	see_invisible = INVIS_CONSTRUCTION

/datum/vision_modifier/construction/glasses
	see_invisible = INVIS_CONSTRUCTION
	see_in_dark_bonus = 1

/datum/vision_modifier/robot
	see_invisible = INVIS_CLOAK
	negative_sight = SEE_OBJS

/// Z-restricted component of AI vision
/datum/vision_modifier/ai_zrestricted
	z_restricted = TRUE
	sight = SEE_TURFS | SEE_OBJS | SEE_MOBS

/// unrestricted component of AI vision. Mostly always around.
/datum/vision_modifier/ai
	see_in_dark = SEE_DARK_FULL
	see_invisible = INVIS_CLOAK

/// AI cameras have a slightly different one
/datum/vision_modifier/ai_camera
	sight = SEE_SELF
	see_invisible = INVIS_AI_EYE
	see_in_dark = SEE_DARK_FULL

/// vision for AI mainframes and hivebots
/datum/vision_modifier/hivebot
	see_invisible = INVIS_CLOAK

/// flock vision
/datum/vision_modifier/flock // /mob/living/critter/flock
	see_invisible = INVIS_FLOCK

/datum/vision_modifier/intangible_flock // /mob/living/intangible/flock
	see_invisible = INVIS_FLOCK
	see_in_dark = SEE_DARK_FULL

/// flubber mutantrace vision
/datum/vision_modifier/flubber
	see_in_dark = SEE_DARK_FULL

/datum/vision_modifier/zombie
	sight = SEE_MOBS
	see_in_dark = SEE_DARK_FULL
	see_invisible = INVIS_NONE

/datum/vision_modifier/grey
	sight = SEE_MOBS
	see_in_dark = SEE_DARK_FULL
	see_invisible = INVIS_CLOAK

/datum/vision_modifier/werewolf
	sight = SEE_MOBS
	see_in_dark = SEE_DARK_FULL
	see_invisible = INVIS_CLOAK

/datum/vision_modifier/hunter
	see_in_dark = SEE_DARK_FULL

/datum/vision_modifier/lizard
	see_in_dark = SEE_DARK_HUMAN + 1
	see_invisible = INVIS_INFRA

/datum/vision_modifier/roach
	see_in_dark = SEE_DARK_HUMAN + 1
	see_invisible = INVIS_INFRA

/datum/vision_modifier/cat
	see_in_dark = SEE_DARK_HUMAN + 1
	see_invisible = INVIS_INFRA

/datum/vision_modifier/krampus
	sight = SEE_MOBS
	see_in_dark = SEE_DARK_FULL
	see_invisible = INVIS_INFRA

/datum/vision_modifier/hastur // /mob/living/critter/hastur
	sight = SEE_MOBS
	see_in_dark = SEE_DARK_FULL
	see_invisible = INVIS_INFRA

/datum/vision_modifier/wraith
	sight = SEE_SELF
	see_in_dark = SEE_DARK_FULL

/datum/vision_modifier/wraith_incorporeal // Wraiths lose see_invisible when corporeal
	see_invisible = INVIS_SPOOKY

/// this is just xray+nightvision
/datum/vision_modifier/xray/kudzu
	centerlight_icon = "nightvision"
	centerlight_color = rgb(0.5 * 255, 0.5 * 255, 0.5 * 255)

/datum/vision_modifier/new_player
	sight = SEE_TURFS

/datum/vision_modifier/observer
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
	see_invisible = INVIS_SPOOKY
	see_in_dark = SEE_DARK_FULL

/// NOT observer ghost vision. Grants ability to see ghosts.
/datum/vision_modifier/ghost
	see_in_dark = 1
	see_invisible = INVIS_GHOST

/datum/vision_modifier/adminview
	see_in_dark = 10

/datum/vision_modifier/buildmode
	see_in_dark = 10
	see_invisible = INVIS_ADVENTURE

/datum/vision_modifier/ship_sensor
	see_in_dark = SEE_DARK_HUMAN + 3
	see_invisible = INVIS_CLOAK

/datum/vision_modifier/ship_sensor/ecto
	see_invisible = INVIS_GHOST

/datum/vision_modifier/ship_sensor/mining
	sight = SEE_TURFS
	negative_sight = SEE_BLACKNESS
	centerlight_icon = "thermal"
	centerlight_color = "#9bdb9b"

/datum/vision_modifier/art_curser_displaced_soul // /mob/living/intangible/art_curser_displaced_soul
	negative_sight = SEE_BLACKNESS
	see_in_dark = SEE_DARK_HUMAN

/datum/vision_modifier/movable_area_controller // /obj/movable_area_controller
	see_in_dark = 12

/datum/vision_modifier/ghostdrone_deluxe
	see_in_dark = SEE_DARK_FULL

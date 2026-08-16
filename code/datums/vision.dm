/var/vision_instances = build_vision_instances()

/proc/build_vision_instances()
	. = list()
	for(var/type in (typesof(/datum/vision)-/datum/vision))
		.[type] = new type

/datum/vision
	/// relative weight of the vision modifier, affects mostly centerlight icon and color calculations
	var/weight = 1
	/// bitfield of SEE_TURFS etc., applies onto mob.sight
	var/sight = SEE_BLACKNESS
	/// bitfield of SEE_TURFS etc., applies negatively onto mob.sight
	var/neg_sight = 0
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
/datum/vision/proc/on_apply(mob/user, source)
	return

/// When the last source is removed and the vision itself goes away
/datum/vision/proc/on_remove(mob/user, source)
	return

/// X-ray vision, also for dead people
/datum/vision/xray
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS
	see_in_dark = SEE_DARK_FULL
	z_restricted = TRUE
	see_invisible = INVIS_MESON

/datum/vision/xray/on_apply(mob/user, source)
	APPLY_ATOM_PROPERTY(user, PROP_MOB_XRAYVISION, source)

/datum/vision/xray/on_remove(mob/user, source)
	REMOVE_ATOM_PROPERTY(user, PROP_MOB_XRAYVISION, source)

/// weak X-ray vision
/datum/vision/xray/weak
	sight = SEE_TURFS
	see_invisible = INVIS_NONE

/// Thermalvision
/datum/vision/thermal
	see_in_dark_bonus = 4
	see_invisible = INVIS_CLOAK
	centerlight_icon = "thermal"
	centerlight_color = rgb(0.5 * 255, 0.5 * 255, 0.5 * 255)

/// Mk2 thermalvision, also gives byond infravision (see mobs through walls)
/datum/vision/thermal/mk2
	see_infrared = 1

/datum/vision/thermal/mk2/on_apply(mob/user, source)
	get_image_group(CLIENT_IMAGE_GROUP_MOB_OVERLAY).add_mob(user)

/datum/vision/thermal/mk2/on_remove(mob/user, source)
	get_image_group(CLIENT_IMAGE_GROUP_MOB_OVERLAY).remove_mob(user)

/datum/vision/nightvision
	centerlight_icon = "nightvision"
	centerlight_color = rgb(0.5 * 255, 0.5 * 255, 0.5 * 255)

/datum/vision/blob_overmind
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
	see_invisible = INVIS_SPOOKY
	see_in_dark = SEE_DARK_FULL
	centerlight_icon = "thermal"
	centerlight_color = rgb(0.5 * 255, 0.5 * 255, 0.5 * 255)

/datum/vision/nightvision/weak
	centerlight_icon = "thermal"

/datum/vision/meson
	z_restricted = TRUE
	sight = SEE_TURFS
	neg_sight = SEE_BLACKNESS
	see_invisible = INVIS_MESON
	see_in_dark_bonus = 1
	centerlight_icon = "nightvision"
	centerlight_color = rgb(0.5 * 255, 0.5 * 255, 0.5 * 255)

/datum/vision/meson/on_apply(mob/user, source)
	get_image_group(CLIENT_IMAGE_GROUP_MECHCOMP).add_mob(user)

/datum/vision/meson/on_remove(mob/user, source)
	get_image_group(CLIENT_IMAGE_GROUP_MECHCOMP).remove_mob(user)

/// Infravision, for some reason this is not the same as byond infravision (see_infrared = 1)
/datum/vision/infra
	see_invisible = INVIS_INFRA

/datum/vision/adventure
	see_invisible = INVIS_ADVENTURE
	z_restricted = TRUE

/datum/vision/construction
	see_invisible = INVIS_CONSTRUCTION

/datum/vision/construction/glasses
	see_invisible = INVIS_CONSTRUCTION
	see_in_dark_bonus = 1

/datum/vision/robot
	see_invisible = INVIS_CLOAK
	neg_sight = SEE_OBJS

/// Z-restricted component of AI vision
/datum/vision/ai_zrestricted
	z_restricted = TRUE
	sight = SEE_TURFS | SEE_OBJS | SEE_MOBS

/// unrestricted component of AI vision. Always around.
/datum/vision/ai
	see_in_dark = SEE_DARK_FULL
	see_invisible = INVIS_CLOAK

/// AI cameras have a slightly different one
/datum/vision/ai_camera
	sight = SEE_SELF
	see_invisible = INVIS_AI_EYE
	see_in_dark = SEE_DARK_FULL

/// vision for AI mainframes and hivebots
/datum/vision/hivebot
	see_invisible = INVIS_CLOAK

/// flock vision
/datum/vision/flock // /mob/living/critter/flock
	see_invisible = INVIS_FLOCK

/datum/vision/intangible_flock // /mob/living/intangible/flock
	see_invisible = INVIS_FLOCK
	see_in_dark = SEE_DARK_FULL

/// flubber mutantrace vision
/datum/vision/flubber
	see_in_dark = SEE_DARK_FULL

/datum/vision/zombie
	sight = SEE_MOBS
	see_in_dark = SEE_DARK_FULL
	see_invisible = INVIS_NONE

/datum/vision/grey
	sight = SEE_MOBS
	see_in_dark = SEE_DARK_FULL
	see_invisible = INVIS_CLOAK

/datum/vision/werewolf
	sight = SEE_MOBS
	see_in_dark = SEE_DARK_FULL
	see_invisible = INVIS_CLOAK

/datum/vision/hunter
	see_in_dark = SEE_DARK_FULL

/datum/vision/lizard
	see_in_dark = SEE_DARK_HUMAN + 1
	see_invisible = INVIS_INFRA

/datum/vision/roach
	see_in_dark = SEE_DARK_HUMAN + 1
	see_invisible = INVIS_INFRA

/datum/vision/cat
	see_in_dark = SEE_DARK_HUMAN + 1
	see_invisible = INVIS_INFRA

/datum/vision/krampus
	sight = SEE_MOBS
	see_in_dark = SEE_DARK_FULL
	see_invisible = INVIS_INFRA

/datum/vision/hastur // /mob/living/critter/hastur
	sight = SEE_MOBS
	see_in_dark = SEE_DARK_FULL
	see_invisible = INVIS_INFRA

/datum/vision/wraith
	sight = SEE_SELF
	see_in_dark = SEE_DARK_FULL

/datum/vision/wraith_incorporeal // Wraiths lose see_invisible when corporeal
	see_invisible = INVIS_SPOOKY

/// this is just xray+nightvision
/datum/vision/xray/kudzu
	centerlight_icon = "nightvision"
	centerlight_color = rgb(0.5 * 255, 0.5 * 255, 0.5 * 255)

/datum/vision/new_player
	sight = SEE_TURFS

/datum/vision/observer
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
	see_invisible = INVIS_SPOOKY
	see_in_dark = SEE_DARK_FULL

/// NOT observer ghost vision. Grants ability to see ghosts.
/datum/vision/ghost
	see_in_dark = 1
	see_invisible = INVIS_GHOST

/datum/vision/adminview
	see_in_dark = 10

/datum/vision/buildmode
	see_in_dark = 10
	see_invisible = INVIS_ADVENTURE

/datum/vision/ship_sensor
	see_in_dark = SEE_DARK_HUMAN + 3
	see_invisible = INVIS_CLOAK

/datum/vision/ship_sensor/ecto
	see_invisible = INVIS_GHOST

/datum/vision/ship_sensor/mining
	sight = SEE_TURFS
	neg_sight = SEE_BLACKNESS
	centerlight_icon = "thermal"
	centerlight_color = "#9bdb9b"

/datum/vision/art_curser_displaced_soul // /mob/living/intangible/art_curser_displaced_soul
	neg_sight = SEE_BLACKNESS
	see_in_dark = SEE_DARK_HUMAN

/datum/vision/movable_area_controller // /obj/movable_area_controller
	see_in_dark = 12

/datum/vision/ghostdrone_deluxe
	see_in_dark = SEE_DARK_FULL

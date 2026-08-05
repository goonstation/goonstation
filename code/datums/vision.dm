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

/// vision for AI mainframes and hivebots
/datum/vision/aibot
	see_invisible = INVIS_CLOAK

/// flock vision
/datum/vision/flock
	see_invisible = INVIS_FLOCK

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

/// this is just xray+nightvision
/datum/vision/xray/kudzu
	centerlight_icon = "nightvision"
	centerlight_color = rgb(0.5 * 255, 0.5 * 255, 0.5 * 255)

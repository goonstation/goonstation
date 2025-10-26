TYPEINFO(/obj/decal/cleanable/vampire_ritual_circle)
	start_listen_effects = list(LISTEN_EFFECT_VAMPIRE_RITUAL_CIRCLE)
	start_listen_inputs = list(LISTEN_INPUT_OUTLOUD)

/obj/decal/cleanable/vampire_ritual_circle
	name = "\improper Ritual Circle"
	desc = "A bizzare looking mass of lines and circles is drawn onto the floor here."
	icon = 'icons/effects/ritual_circle.dmi'
	icon_state = "ritual_circle"
	bound_width = 96
	bound_height = 96
	pixel_x = -32
	pixel_y = -32
	anchored = ANCHORED
	density = FALSE
	opacity = FALSE
	plane = PLANE_FLOOR
	layer = DECAL_LAYER
	can_fluid_absorb = FALSE

	var/list/atom/movable/sacrificial_circle/sacrificial_circles = null
	var/list/atom/movable/sacrificial_circle/sacrificial_circles_by_item = null
	var/datum/vampire_ritual/current_ritual = null

/obj/decal/cleanable/vampire_ritual_circle/New()
	. = ..()

	src.sacrificial_circles = list(
		new /atom/movable/sacrificial_circle/no_1(src),
		new /atom/movable/sacrificial_circle/no_2(src),
		new /atom/movable/sacrificial_circle/no_3(src),
		new /atom/movable/sacrificial_circle/no_4(src),
		new /atom/movable/sacrificial_circle/no_5(src),
	)
	src.sacrificial_circles_by_item = list()

	START_TRACKING

/obj/decal/cleanable/vampire_ritual_circle/disposing()
	STOP_TRACKING

	if (src.current_ritual)
		global.VampireRitualManager.StopRitual(src.current_ritual)

	for (var/atom/movable/sacrificial_circle/circle as anything in src.sacrificial_circles)
		qdel(circle)

	src.sacrificial_circles = null
	src.sacrificial_circles_by_item = null

	. = ..()

/obj/decal/cleanable/vampire_ritual_circle/proc/start_ritual_fire()
	var/image/fire_image = image('icons/effects/ritual_circle.dmi', icon_state = "ritual_fire")
	src.AddOverlays(fire_image, "ritual_fire")

	fire_image.plane = PLANE_LIGHTING
	fire_image.blend_mode = BLEND_ADD
	fire_image.layer = LIGHTING_LAYER_BASE
	fire_image.color = list(
		0.33, 0.33, 0.33,
		0.33, 0.33, 0.33,
		0.33, 0.33, 0.33,
	)
	src.AddOverlays(fire_image, "ritual_fire_lighting")

	playsound(src.loc, 'sound/effects/flameswoosh.ogg', 50)

/obj/decal/cleanable/vampire_ritual_circle/proc/end_ritual_fire()
	src.UpdateOverlays(null, "ritual_fire")
	src.UpdateOverlays(null, "ritual_fire_lighting")

	playsound(src.loc, 'sound/impact_sounds/burn_sizzle.ogg', 50)

/obj/decal/cleanable/vampire_ritual_circle/proc/qdel_ritual_item(obj/item/I)
	src.sacrificial_circles_by_item[I]?.unset_held_item()
	qdel(I)





/atom/movable/sacrificial_circle
	name = "\improper Sacrificial Circle"
	desc = "A smaller subcircle within the ritual circle; it looks like something is meant to be placed inside it."
	anchored = ANCHORED
	density = FALSE
	opacity = FALSE
	plane = PLANE_FLOOR
	layer = DECAL_LAYER + 0.01
	var/obj/decal/cleanable/vampire_ritual_circle/parent = null
	var/obj/item/held_item = null
	var/dir_from_centre = null

/atom/movable/sacrificial_circle/New(obj/decal/cleanable/vampire_ritual_circle/parent)
	. = ..()

	var/icon/new_icon = icon('icons/effects/ritual_circle_32x32.dmi', "sacrificial_circle_mask")
	new_icon.ChangeOpacity(0.01)
	src.icon = new_icon

	src.parent = parent
	src.set_loc(get_step(src.parent, src.dir_from_centre))

/atom/movable/sacrificial_circle/disposing()
	src.unset_held_item()
	src.parent = null
	. = ..()

/atom/movable/sacrificial_circle/attackby(obj/item/I, mob/user)
	if (!istype(I) || istype(I, /obj/item/grab) || src.held_item)
		return

	if (src.parent.current_ritual)
		boutput(user, SPAN_ALERT("You can't place an item on a sacrificial circle during a ritual."))
		return

	user.drop_item(I)
	src.set_held_item(I)

/atom/movable/sacrificial_circle/attack_hand(mob/user)
	if (!src.held_item)
		return

	if (src.parent.current_ritual)
		boutput(user, SPAN_ALERT("You can't remove an item from a sacrificial circle during a ritual."))
		return

	var/atom/movable/AM = src.held_item
	src.unset_held_item()
	user.put_in_hand_or_drop(AM)

/atom/movable/sacrificial_circle/proc/set_held_item(obj/item/I)
	if (src.held_item)
		return

	src.held_item = I
	src.parent.sacrificial_circles_by_item[src.held_item] = src

	src.held_item.set_loc(src)
	src.vis_contents += src.held_item
	src.held_item.vis_flags |= VIS_INHERIT_ID
	src.held_item.pixel_x = 0
	src.held_item.pixel_y = 0

/atom/movable/sacrificial_circle/proc/unset_held_item()
	if (!src.held_item)
		return

	src.held_item.set_loc(get_turf(src))
	src.vis_contents -= src.held_item
	src.held_item.vis_flags &= ~VIS_INHERIT_ID

	src.parent.sacrificial_circles_by_item -= src.held_item
	src.held_item = null

/atom/movable/sacrificial_circle/no_1
	dir_from_centre = EAST
	pixel_x = 5
	pixel_y = 12

/atom/movable/sacrificial_circle/no_2
	dir_from_centre = EAST
	pixel_x = 4
	pixel_y = -14

/atom/movable/sacrificial_circle/no_3
	dir_from_centre = SOUTH
	pixel_x = 3
	pixel_y = -6

/atom/movable/sacrificial_circle/no_4
	dir_from_centre = WEST
	pixel_x = -6
	pixel_y = -11

/atom/movable/sacrificial_circle/no_5
	dir_from_centre = NORTHWEST
	pixel_x = 9
	pixel_y = 0

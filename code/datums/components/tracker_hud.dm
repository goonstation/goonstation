/datum/component/tracker_hud
	var/atom/target = null
	var/atom/movable/hudarrow = null
	var/color = "#67cd22"
	var/active = FALSE

/datum/component/tracker_hud/Initialize(atom/target, color)
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE || !target)
		return COMPONENT_INCOMPATIBLE
	var/mob/mob_parent = src.parent
	if(!istype(mob_parent) || !mob_parent.get_hud())
		return COMPONENT_INCOMPATIBLE
	src.target = target
	src.color = color || src.color

/datum/component/tracker_hud/RegisterWithParent()
	. = ..()
	var/mob/mob_parent = src.parent
	var/datum/hud/hud = mob_parent.get_hud()
	if (!src.hudarrow)
		src.hudarrow = hud.create_screen("pinpointer", "Pinpointer", 'icons/obj/items/pinpointers.dmi', "hudarrow", "CENTER, CENTER")
		src.hudarrow.mouse_opacity = 0
		src.hudarrow.appearance_flags = 0 // PIXEL_SCALE ommitted on purpose (?)
		src.hudarrow.alpha = 127
		src.hudarrow.color = color
	else
		hud.add_object(src.hudarrow)

	src.hudarrow.transform = src.get_arrow_transform()

	var/datum/controller/process/tracker_hud/controller = locate() in processScheduler.processes
	controller.processing_components |= src

/datum/component/tracker_hud/UnregisterFromParent()
	. = ..()
	var/mob/mob_parent = src.parent
	var/datum/hud/hud = mob_parent.get_hud()
	hud.remove_object(src.hudarrow)

	var/datum/controller/process/tracker_hud/controller = locate() in processScheduler.processes
	controller.processing_components -= src

/datum/component/tracker_hud/proc/get_arrow_transform()
	var/dist = GET_DIST(src.parent, src.target)
	var/ang = get_angle(get_turf(src.parent), get_turf(src.target))
	var/hudarrow_dist = 16 + 32 / (1 + 3 ** (3 - dist / 10))
	var/matrix/M = matrix()
	var/hudarrow_scale = 0.6 + 0.4 / (1 + 3 ** (3 - dist / 10))
	M = M.Scale(hudarrow_scale, hudarrow_scale)
	M = M.Turn(ang)
	if(dist == 0)
		hudarrow_dist += 9
		M.Turn(180) // point at yourself :)
	M = M.Translate(hudarrow_dist * sin(ang), hudarrow_dist * cos(ang))
	return M

/datum/component/tracker_hud/proc/process()
	if (QDELETED(src.target))
		src.hudarrow.alpha = 0
		return
	if (isatom(src.parent))
		var/turf/target_turf = get_turf(src.target)
		var/turf/parent_turf = get_turf(src.parent)
		if (target_turf.z != parent_turf.z)
			src.hudarrow.alpha = 0
			return
	src.hudarrow.alpha = 127
	animate(hudarrow, transform=src.get_arrow_transform(), time=0.5 SECONDS, flags=ANIMATION_PARALLEL)

/datum/component/tracker_hud/proc/change_target(atom/new_target)
	src.target = new_target
	src.process()


/datum/component/tracker_hud/vampthrall
	color = "#ff0000ff" //red
	var/datum/player/master

/datum/component/tracker_hud/vampthrall/RegisterWithParent()
	. = ..()
	var/mob/living/carbon/human/vamp = src.target
	if (!istype(vamp))
		return
	src.master = vamp.client?.player

/datum/component/tracker_hud/vampthrall/process()
	if (!src.master) //something very broken
		src.RemoveComponent()
		return
	//you might be asking "what is this fucking mess", so we want to track a specific player's body but ONLY if they currently have vampire abilities
	//can't track the abilityHolder directly since it gets replaced with a copy on clone so we do this mess instead
	var/datum/abilityHolder/vampire/holder = src.master.client?.mob?.get_ability_holder(/datum/abilityHolder/vampire)
	src.target = holder?.owner
	..()

/datum/component/tracker_hud/flock
	dupe_mode = COMPONENT_DUPE_UNIQUE
	color = "#15ccb4"

/datum/component/tracker_hud/gang
	color = "#5a6edd"

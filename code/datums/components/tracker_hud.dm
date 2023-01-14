/datum/component/tracker_hud
	var/atom/target = null
	var/atom/movable/hudarrow = null
	var/color = "#67cd22"
	var/active = FALSE

/datum/component/tracker_hud/Initialize(atom/target, color)
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE || !target)
		return
	src.target = target
	src.color = color || src.color

/datum/component/tracker_hud/RegisterWithParent()
	. = ..()
	var/mob/user = src.parent
	if(!istype(user) || !hasvar(user, "hud")) // I'm so sorry
		return
	var/datum/hud/hud = user:hud
	if (!src.hudarrow)
		hudarrow = hud.create_screen("pinpointer", "Pinpointer", 'icons/obj/items/pinpointers.dmi', "hudarrow", "CENTER, CENTER")
		hudarrow.mouse_opacity = 0
		hudarrow.appearance_flags = 0
		hudarrow.alpha = 127
		hudarrow.color = color
	else
		hud.add_object(hudarrow)

	var/datum/controller/process/tracker_hud/controller = locate() in processScheduler.processes
	controller.processing_components |= src

/datum/component/tracker_hud/UnregisterFromParent()
	. = ..()
	var/datum/hud/hud = src.parent:hud
	hud.remove_object(src.hudarrow)

	var/datum/controller/process/tracker_hud/controller = locate() in processScheduler.processes
	controller.processing_components -= src

/datum/component/tracker_hud/proc/process()
	var/dist = GET_DIST(src.parent,target)
	var/ang = get_angle(get_turf(src.parent), get_turf(target))
	var/hudarrow_dist = 16 + 32 / (1 + 3 ** (3 - dist / 10))
	var/matrix/M = matrix()
	var/hudarrow_scale = 0.6 + 0.4 / (1 + 3 ** (3 - dist / 10))
	M = M.Scale(hudarrow_scale, hudarrow_scale)
	M = M.Turn(ang)
	if(dist == 0)
		hudarrow_dist += 9
		M.Turn(180) // point at yourself :)
	M = M.Translate(hudarrow_dist * sin(ang), hudarrow_dist * cos(ang))
	animate(hudarrow, transform=M, time=0.5 SECONDS, flags=ANIMATION_PARALLEL)

/datum/component/tracker_hud/proc/change_target(atom/new_target)
	src.target = new_target
	src.process()

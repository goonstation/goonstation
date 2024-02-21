/datum/targetable/flockmindAbility/droneControl
	cooldown = 0
	icon = null
	var/mob/living/critter/flock/drone/drone = null

/datum/targetable/flockmindAbility/droneControl/cast(atom/target, update_cursor = TRUE)
	//remove the selected outline component
	var/datum/component/flock_ping/selected/ping = drone.GetComponent(/datum/component/flock_ping/selected)
	ping.RemoveComponent()
	qdel(ping)

	if (target == src.drone)
		// ability is selected manually so it needs to be removed manually
		var/mob/living/intangible/flock/selector = holder.owner
		selector.targeting_ability = null
		if (update_cursor) // if there's a need, it may reset without this
			selector.update_cursor()

		src.drone.selected_by = null
		src.drone = null
		return
	//by default we try to convert the target
	var/task_type = /datum/aiTask/sequence/goalbased/flock/build/targetable
	//order is important here
	if (isflockvalidenemy(target))
		if (ismob(target) && is_incapacitated(target))
			task_type = /datum/aiTask/sequence/goalbased/flock/flockdrone_capture/targetable
		else
			task_type = /datum/aiTask/timed/targeted/flockdrone_shoot/targetable
	else if (istype(target, /obj/flock_structure/ghost))
		task_type = /datum/aiTask/sequence/goalbased/flock/deposit/targetable
	else if (istype(target, /obj/flock_structure))
		task_type = /datum/aiTask/sequence/goalbased/flock/repair/targetable
	else if (istype(target, /obj/flock_structure) || isfeathertile(target))
		task_type = /datum/aiTask/sequence/goalbased/flock/rally
	else if (istype(target, /mob/living/critter/flock))
		var/mob/living/critter/flock/mob = target
		if (isalive(mob))
			task_type = /datum/aiTask/sequence/goalbased/flock/repair/targetable
		else
			task_type = /datum/aiTask/sequence/goalbased/flock/butcher/targetable
	else if (isitem(target))
		task_type = /datum/aiTask/sequence/goalbased/flock/harvest/targetable

	if (!src.tutorial_check(FLOCK_ACTION_DRONE_ORDER, task_type))
		return

	var/datum/aiTask/task = drone.ai.get_instance(task_type, list(drone.ai, drone.ai.default_task))
	task.target = target
	drone.ai.priority_tasks += task
	if(drone.ai_paused)
		drone.wake_from_ai_pause()
	drone.ai.interrupt()

	var/mob/living/intangible/flock/selector = holder.owner
	selector.targeting_ability = null
	if (update_cursor)
		selector.update_cursor()

	src.drone.selected_by = null
	src.drone = null

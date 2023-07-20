/datum/aiHolder/capybara
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/capybara, list(src))

/datum/aiTask/prioritizer/critter/capybara/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/sitting, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(holder, src))

//--------------------------------------------------------------------------------------------------------------------------------------------------//
// have a little sit down


/datum/aiTask/timed/sitting
	name = "sitting"
	minimum_task_ticks = 5
	maximum_task_ticks = 10

/datum/aiTask/timed/sitting/evaluate()
	. = 0
	if(!GET_COOLDOWN(src.holder.owner, "capy_sit_down"))
		return 1

/datum/aiTask/timed/sitting/on_tick()
	ON_COOLDOWN(src.holder.owner, "capy_sit_down", 15 SECONDS)
	holder.stop_move()
	holder.owner.icon_state = "capybara-sit"

/datum/aiTask/timed/sitting/next_task()
	. = ..()
	if(.)
		holder.owner.icon_state = "capybara"

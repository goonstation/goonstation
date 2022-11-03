/datum/tutorial/stage/examine
	name = "Examining"
	prefab_name = "examine"
	desc = "Learn the most essential task of SS13: Examining objects"
	tasks = list(
		/datum/tutorial/task/examine/extinguisher
	)

ABSTRACT_TYPE(/datum/tutorial/task/examine)
/datum/tutorial/task/examine/extinguisher
	name = "Examine Extinguisher"

	started()
		boutput(stage.player.client, "Hi! welcome to da tutorial")
		boutput(stage.player.client, "examine the fire extinguisher in front of you")
		boutput(stage.player.client, "you can do this by alt-clicking it or right clicking and choosing examine on it")

	finish()
		boutput(stage.player.client, "congrats on examining, pretty handy right?")
		. = ..()

// lol this is so shitty but i'm not putting a signal on examine
/obj/item/extinguisher/examine(mob/user)
	. = ..()
	var/datum/tutorial/player_state/state = tutorial_manager.player_to_state[user.client.ckey]
	if (state.current_stage.current_task.type == /datum/tutorial/task/examine/extinguisher)
		state.current_stage.current_task.finish()

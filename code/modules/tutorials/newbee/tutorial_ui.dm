/datum/abilityHolder/newbee
	usesPoints = FALSE
	tabName = "Tutorial"
	var/datum/tutorial_base/regional/newbee/my_tutorial

	onAttach(mob/to_whom)
		. = ..()
		src.addAbility(/datum/targetable/newbee/exit)
		src.addAbility(/datum/targetable/newbee/previous)
		src.addAbility(/datum/targetable/newbee/next)

	onAbilityStat()
		. = ..()
		if (my_tutorial)
			. = list()
			.["Progress"] = "[floor(my_tutorial.current_step/length(my_tutorial.steps)*100)]%"

/datum/targetable/newbee
	icon = 'icons/mob/tutorial_ui.dmi'
	icon_state = "frame"
	targeted = 0
	do_logs = FALSE

/datum/targetable/newbee/exit
	name = "Exit Tutorial"
	desc = "Exit the tutorial and go to the main menu."
	icon_state = "exit"

	cast(atom/target)
		. = ..()
		var/confirm = tgui_alert(src.holder.owner, "Do you want to exit the tutorial?", "Leave Tutorial", list("Yes", "No"))
		if (confirm == "Yes")
			src.holder.owner.mind?.get_player()?.tutorial?.Finish()

/datum/targetable/newbee/previous
	name = "Previous Step"
	desc = "Go back one step in the tutorial."
	icon_state = "previous"

	cast(atom/target)
		. = ..()
		var/datum/tutorial_base/regional/newbee/tutorial = src.holder.owner.mind?.get_player()?.tutorial
		if (!istype(tutorial))
			return // ???
		if (tutorial.current_step <= 1)
			boutput(src.holder.owner, SPAN_ALERT("You're already at the first step!"))
			return
		var/datum/tutorialStep/newbee/current_step = tutorial.steps[tutorial.current_step]
		current_step.TearDown()
		tutorial.current_step -= 1
		var/datum/tutorialStep/newbee/previous_step = tutorial.steps[tutorial.current_step]
		previous_step.SetUp(TRUE)
		src.holder.owner.reagents.clear_reagents()
		src.holder.owner.stabilize()
		tutorial.ShowStep()

/datum/targetable/newbee/next
	name = "Next Step"
	desc = "Go forward one step in the tutorial."
	icon_state = "next"

	cast(atom/target)
		. = ..()
		src.holder.owner?.mind?.get_player()?.tutorial?.Advance(TRUE)
		src.holder.owner?.reagents.clear_reagents()
		src.holder.owner?.stabilize()

/datum/abilityHolder/newbee
	usesPoints = FALSE
	tabName = "Tutorial"
	abilities = list(
		/datum/targetable/newbee/exit,
		/datum/targetable/newbee/previous,
		/datum/targetable/newbee/next,
	)

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
			src.holder.owner.client?.tutorial?.Finish()

/datum/targetable/newbee/previous
	name = "Previous Step"
	desc = "Go back one step in the tutorial."
	icon_state = "previous"

	cast(atom/target)
		. = ..()
		var/datum/tutorial_base/regional/newbee/tutorial = src.holder.owner.client?.tutorial
		if (!istype(tutorial))
			return // ???
		if (tutorial.current_step <= 1)
			boutput(src.holder.owner, SPAN_ALERT("You're already at the first step!"))
			return
		var/datum/tutorialStep/newbee/current_step = tutorial.steps[tutorial.current_step]
		current_step.TearDown()
		tutorial.current_step -= 1
		var/datum/tutorialStep/newbee/previous_step = tutorial.steps[tutorial.current_step]
		tutorial.ShowStep()
		previous_step.SetUp(TRUE)

/datum/targetable/newbee/next
	name = "Next Step"
	desc = "Go forward one step in the tutorial."
	icon_state = "next"

	cast(atom/target)
		. = ..()
		src.holder.owner.client?.tutorial?.Advance(TRUE)

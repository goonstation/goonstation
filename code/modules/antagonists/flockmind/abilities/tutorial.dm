/datum/targetable/flockmindAbility/tutorial
	name = "Interactive Tutorial"
	desc = "Check out the interactive Flock tutorial to get started."
	icon_state = "question_mark"
	cooldown = 0 SECONDS
	targeted = FALSE

/datum/targetable/flockmindAbility/tutorial/cast(atom/target)
	if (..())
		return TRUE
	var/mob/living/intangible/flock/flockmind/flockmind = holder.owner
	if (istype(flockmind) && flockmind.tutorial)
		boutput(flockmind, "<span class='alert'>You're already in the tutorial!</span>")
		return TRUE
	flockmind.start_tutorial()

//yes this is copy pasted from blob, blob abilities are their own cursed thing so we have to reimplement
/datum/targetable/flockmindAbility/tutorial_exit
	name = "Exit Tutorial"
	desc = "Exit the Flock tutorial and re-enter the game."
	icon_state = "x"
	targeted = FALSE
	special_screen_loc = "SOUTH,EAST-1"
	cooldown = 0

	cast()
		if (..())
			return
		var/mob/living/intangible/flock/flockmind/flockmind = holder.owner
		if (!flockmind.tutorial)
			boutput(holder.get_controlling_mob(), "<span class='alert'>You're not in the tutorial!</span>")
			return
		if (tgui_alert(holder.get_controlling_mob(), "Exit tutorial?", "Confirm", list("Ok", "Cancel")) == "Ok")
			flockmind.tutorial.Finish()
			flockmind.tutorial = null

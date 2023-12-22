/* 	/		/		/		/		/		/		Ability Holder		/		/		/		/		/		/		/		/		*/

/datum/abilityHolder/pod_pilot
	usesPoints = FALSE
	tabName = "pod_pilot"

	New()
		..()
		add_all_abilities()

	proc/add_all_abilities()
		src.addAbility(/datum/targetable/pod_pilot/scoreboard)

//can't remember why I did this as an ability. Probably better to add directly like I did in kudzumen, but later... -kyle
//Wait, maybe I never used this. I can't remember, it's too late now to think and I'll just keep it in case I secretly had a good reason to do this.
/datum/targetable/pod_pilot
	icon = 'icons/mob/pod_pilot_abilities.dmi'
	icon_state = "template"
	preferred_holder_type = /datum/abilityHolder/pod_pilot
	can_cast_while_cuffed = TRUE

/datum/targetable/pod_pilot/scoreboard
	name = "scoreboard"
	desc = "How many scores do we have?"
	special_screen_loc = "NORTH,CENTER-2"

	onAttach(var/datum/abilityHolder/H)
		src.object.mouse_opacity = 0
		if (istype(ticker.mode, /datum/game_mode/pod_wars))
			var/datum/game_mode/pod_wars/mode = ticker.mode
			object.vis_contents += mode.board



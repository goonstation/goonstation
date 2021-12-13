
//silly incomplete thingyh

/*
/datum/yesno_dialog

	var/list/contextActions = null

	var/mob/user
	var/maptext = "<span class='ps2p ol vt c' style='color: #f00;'>Do you want to?</span>"
	var/charge.maptext_y = -5
	var/charge.maptext_width = 96
	var/charge.maptext_x = -9

	var/datum/contextLayout/contextLayout = null

	//you could enter some maptext stuff here and then have buttons auto expand
	INIT(var/mob/M, var/question)
		user = M
		contextLayout = new /datum/contextLayout/flexdefault(4, 32, 32)

		user.showContextActions(contextActions, src)

		..()

	disposing()
		..()


	//override these
	proc/accept
		qdel(src)

	proc/deny
		qdel(src)
*/

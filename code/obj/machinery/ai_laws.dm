//fix dme
//renames handled via robitics control
//remove killswitches, list GPS coords of all AIs instead
//rework traitor items
//freeze/unfreeze law changes on robotics console but allow the AI to hack into it and unfreeze borgs
//the only way to set a borg to that law set is to input id of law rack
//ids on AIs and cyborgs preset
//view ID of AI and borgs



/obj/item/aiModule/proc/install(var/obj/machinery/computer/aiupload/comp)
	if (comp.status & NOPOWER)
		boutput(usr, "The upload computer has no power!")
		return
	if (comp.status & BROKEN)
		boutput(usr, "The upload computer is broken!")
		return

	src.transmitInstructions(usr)
	boutput(usr, "Upload complete. The AI's laws have been modified.")
// Showing laws to everybody now handled by the AI itself, ok
// not anymore motherfucker

	for (var/mob/living/silicon/R in mobs)
		if (isghostdrone(R))
			continue
		R << sound('sound/misc/lawnotify.ogg', volume=100, wait=0)
		R.show_text("<h3>Law update detected.</h3>", "red")
		R.show_laws()
	for (var/mob/dead/aieye/E in mobs)
		E << sound('sound/misc/lawnotify.ogg', volume=100, wait=0)



/datum/ai_laws/proc/show_laws(var/who)
	var/list/L = who
	if (!istype(who, /list))
		L = list(who)

	for (var/W in L)
		if (src.zeroth)
			boutput(W, "0. [src.zeroth]")

		var/number = 1
		for (var/index = 1, index <= src.inherent.len, index++)
			var/law = src.inherent[index]

			if (length(law) > 0)
				boutput(W, "[number]. [law]")
				number++

		for (var/index = 1, index <= src.supplied.len, index++)
			var/law = src.supplied[index]
			if (length(law) > 0)
				boutput(W, "[number]. [law]")
				number++

/datum/ai_laws/proc/laws_sanity_check()
	if (!ticker.centralized_ai_laws)
		ticker.centralized_ai_laws = new /datum/ai_laws/asimov

/datum/ai_laws/proc/format_for_irc()
	var/list/laws = list()

	if (src.zeroth)
		laws["0"] = src.zeroth

	var/number = 1
	for (var/index = 1, index <= src.inherent.len, index++)
		var/law = src.inherent[index]

		if (length(law) > 0)
			laws["[number]"] = law
			number++

	for (var/index = 1, index <= src.supplied.len, index++)
		var/law = src.supplied[index]
		if (length(law) > 0)
			laws["[number]"] = law
			number++

	return laws

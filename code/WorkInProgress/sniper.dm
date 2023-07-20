// RANDOM SHIT I MAKE GOES HERE, STOLE KEELIN'S IDEA HEH

// Can specify an icon and name instead of a random human mob
/proc/fake_attackEx(var/mob/target, var/icon/I, var/state, var/fake_name)
	var/obj/fake_attacker/F = new(target.loc, target)

	F.name = fake_name
	//F.my_target = target

	var/image/O = image(icon = I, loc = F, icon_state = state)
	target << O

/obj/hallucination
	icon = null
	icon_state = null
	name = ""
	desc = ""
	density = 0
	anchored = ANCHORED
	opacity = 0

/*
/proc/start_hallucinating(var/mob/M)
	for(var/turf/T in world)
		if(prob(4) && istype(T))
			SPAWN(1 SECOND)
				explosion(src, T, 3, 1)
*/

/proc/corruptText(var/t, var/p)
	if(!t)
		return ""
	var/tmp = ""
	for(var/i = 1, i <= length(t), i++)
		if(prob(p))
			tmp += pick("{", "|", "}", "~", "€", "ƒ", "†", "‡", "‰", "¡", "¢", "£", "¤", "¥", "¦", "§", "©", "«", "¬", "®", "°", "±", "²", "³", "¶", "¿", "ø", "ÿ", "þ")
		else
			tmp += copytext(t, i, i+1)
	return tmp

/proc/mysql_sanitize(var/t)
	if(!t)
		return ""
	var/tmp = replacetext(t, "'", "\'")
	tmp = replacetext(tmp, "\\", "/")
	return tmp

/mob/proc/addicted_to_reagent(var/datum/reagent/reagent)
	if(!src.ailments || !length(src.ailments))
		return 0
	for(var/datum/ailment_data/addiction/A in src.ailments)
		if(istype(A) && reagent && (A.associated_reagent == reagent.name)) //ZeWaka: Fix for null.name
			return A // return the addiction ailment so we can reference it
	return 0

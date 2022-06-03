// Effects related to materials and gas production go here.
ABSTRACT_TYPE(/datum/microbioeffects/material)
/datum/microbioeffects/material
	name = "Material Effects"

/datum/microbioeffects/material/organicglass
	name = "Organic Glass"
	desc = "The microbes produce silicate, reinforcing and repairing glass structures."

	object_act(var/obj/O, var/datum/microbe/origin)				//integers good
		var/max_reinforce = 500
		if(istype(O,/obj/window))						//Convair880's silicate code used here
			var/obj/window/W = O
			if (W.health >= max_reinforce)
				return
			var/do_reinforce = W.health + origin.probability
			if ((W.health + do_reinforce) > max_reinforce)
				do_reinforce = max(0, (max_reinforce - W.health))
			W.health += do_reinforce
			W.health_max = W.health
			var/icon/I = icon(W.icon)
			I.ColorTone(rgb(165,242,243))
			W.icon = I

	may_react_to()
		return "The pathogen appears to produce a large volume of solids."

	react_to(var/R, var/zoom)
		if (R == "infernite" || R == "phlogiston")
			return "The flame of the hot reagents is oxidized by the gas."

//datum/microbioeffects/material/regenerativesteel
	//On Object:
		//check if istype("grille,wall,reinforcedwall")
		//getturf
		//increment health stat of steel obj.

//datum/microbioeffects/material/rcdregen
	//On Object:
		//check if its an RCD
		//if yes...
		//check if it has max ammo
		//if no...
		//roll (probability*10) to add 5 units of ammo.


//datum/microbioeffects/material/mininghelper
	//On Turf:
		//Check if its the tough rock
		//if it is...
		//qdel it after 3-5 seconds and drop any minerals it would have had

//datum/microbioeffects/material/weldingtool
	//On object:
		//Check if its a welding tool
		//If it is...
		//Disable the passive fuel drain when active!

/**
 *
 * Datum: allow cyborgs to have passive regen!
 * 		check issilicon:
 * 			if so, roll probability to mend
 * 			plus a probability for message
 * From the cyborg docking station code:
 * for (var/obj/item/parts/robot_parts/RP in R.contents)
					RP.ropart_mend_damage(usage,0)
 */

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



/**
 * Gas Production
 * Using the old fart symptoms, effects would replenish canisters/tanks with gas
 * On splash/apply microbe to tank
 * If tank/canister is overpressured, pass. Otherwise
 * Add probability # of moles to tank/canister
 */
/*
/datum/microbioeffects/tells/farts
	name = "Farts"
	desc = "The infected individual occasionally farts."

	var/cooldown = 200 // we just use the name of the symptom to keep track of different fart effects, so their cooldowns do not interfere
	var/doInfect = 1 // smoke farts were just too good

	proc/fart(var/mob/M, var/datum/pathogen/origin, var/voluntary)
		if(doInfect)
			src.infect_cloud(M, origin, origin.spread/5)
		if(voluntary)
			origin.effectdata[name] = TIME

	onemote(mob/M as mob, act, voluntary, param, datum/pathogen/P)
		// involuntary farts are free, but the others use the cooldown
		if(voluntary && TIME-P.effectdata[name] < cooldown)
			return
		if(act == "fart")
			fart(M, P, voluntary)

	mob_act(var/mob/M, var/datum/pathogen/origin)
		if (origin.in_remission)
			return
		if (prob(origin.stage))
			M.emote("fart")

	may_react_to()
		return "The pathogen appears to produce a large volume of gas."

*/
/*
/datum/microbioeffects/material/smokegas
	name = "Smoke Farts"
	desc = "The infected individual occasionally farts reagent smoke."
	cooldown = 600
	doInfect = 0 // the whole point is to not instantly infect a huge area, that's what got us into this mess >.>

	fart(var/mob/M, var/datum/microbe/origin, var/voluntary)
		if (M.reagents.total_volume)
			smoke_reaction(M.reagents, 1, get_turf(M))
			..()			// only trigger if we actually have chems, else no infection or cooldown

	may_react_to()
		return "The pathogen appears to produce a large volume of gas."

	react_to(var/R, var/zoom)
		var/datum/reagents/H = new /datum/reagents(5)
		H.add_reagent(R, 5)
		var/datum/reagent/RE = H.get_reagent(R)
		return "The [RE.name] violently explodes into a puff of smoke when coming into contact with the pathogen."

/datum/pathogeneffects/material/plasmagas
	name = "Plasma Generator"
	desc = "The germ appears to generate gaseous plasma."
	cooldown = 600

	mob_act(var/mob/M, var/datum/microbe/origin)
		var/turf/T = get_turf(M)
		var/datum/gas_mixture/gas = new /datum/gas_mixture
		gas.zero()
		gas.toxins = 3			//origin.stage * (voluntary ? 0.6 : 3) // only a fifth for voluntary farts
		gas.temperature = T20C
		gas.volume = R_IDEAL_GAS_EQUATION * T20C / 1000
		if (T)
			T.assume_air(gas)

	react_to(var/R, var/zoom)
		if (R == "infernite" || R == "phlogiston")
			return "The gas lights up in a puff of flame."

datum/microbioeffects/material/co2gas
	name = "CO2 Farts"
	desc = "The infected individual occasionally farts. Carbon dioxide."
	cooldown = 600

	fart(var/mob/M, var/datum/microbe/origin, var/voluntary)
		..()
		var/turf/T = get_turf(M)
		var/datum/gas_mixture/gas = new /datum/gas_mixture
		gas.zero()
		gas.carbon_dioxide = origin.stage * (voluntary ? 1.4 : 7) // only a fifth for voluntary farts
		gas.temperature = T20C
		gas.volume = R_IDEAL_GAS_EQUATION * T20C / 1000
		if (T)
			T.assume_air(gas)

	mob_act(var/mob/M, var/datum/pathogen/origin)
		if (origin.in_remission)
			return
		..()
		if (origin.stage > 2 && prob(origin.stage * 3))
			M.take_toxin_damage(1)
			M.take_oxygen_deprivation(4)

	react_to(var/R, var/zoom)
		if (R == "infernite" || R == "phlogiston")
			return "The flame of the hot reagents is snuffed by the gas."


datum/microbioeffects/malevolent/o2
	name = "O2 Farts"
	desc = "The infected individual occasionally farts. Pure oxygen."
	cooldown = 50
	// ahahahah this is so stupid
	// i have no idea what these numbers mean but i hope it's funny

	fart(var/mob/M, var/datum/pathogen/origin, var/voluntary)
		..()
		var/turf/T = get_turf(M)
		var/datum/gas_mixture/gas = new /datum/gas_mixture
		gas.zero()
		gas.oxygen = origin.stage * (voluntary ? 20 : 2) // ten times as much for voluntary farts
		gas.temperature = T20C
		gas.volume = R_IDEAL_GAS_EQUATION * T20C / 1000
		if (T)
			T.assume_air(gas)

	react_to(var/R, var/zoom)
		if (R == "infernite" || R == "phlogiston")
			return "The flame of the hot reagents is oxidized by the gas."
*/

// Effects related to materials and gas production go here.
/datum/microbioeffects/material
	name = "Material Effects"
/*
/*datum/pathogeneffects/material/smokegas
	name = "Smoke Farts"
	desc = "The infected individual occasionally farts reagent smoke."
	cooldown = 600
	doInfect = 0 // the whole point is to not instantly infect a huge area, that's what got us into this mess >.>

	fart(var/mob/M, var/datum/pathogen/origin, var/voluntary)
		if (M.reagents.total_volume)
			smoke_reaction(M.reagents, origin.stage, get_turf(M))
			..()			// only trigger if we actually have chems, else no infection or cooldown

	may_react_to()
		return "The pathogen appears to produce a large volume of gas."

	react_to(var/R, var/zoom)
		var/datum/reagents/H = new /datum/reagents(5)
		H.add_reagent(R, 5)
		var/datum/reagent/RE = H.get_reagent(R)
		return "The [RE.name] violently explodes into a puff of smoke when coming into contact with the pathogen."*/

datum/pathogeneffects/material/plasmagas
	name = "Plasma Generator"
	desc = "The germ appears to generate gaseous plasma."
	cooldown = 600

	mob_act(var/mob/M, var/datum/pathogen/origin)
		var/turf/T = get_turf(M)
		var/datum/gas_mixture/gas = new /datum/gas_mixture
		gas.zero()
		gas.toxins = origin.stage * (voluntary ? 0.6 : 3) // only a fifth for voluntary farts
		gas.temperature = T20C
		gas.volume = R_IDEAL_GAS_EQUATION * T20C / 1000
		if (T)
			T.assume_air(gas)

	react_to(var/R, var/zoom)
		if (R == "infernite" || R == "phlogiston")
			return "The gas lights up in a puff of flame."

datum/pathogeneffects/malevolent/farts/co2
	name = "CO2 Farts"
	desc = "The infected individual occasionally farts. Carbon dioxide."
	rarity = THREAT_TYPE4
	cooldown = 600

	fart(var/mob/M, var/datum/pathogen/origin, var/voluntary)
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


datum/pathogeneffects/malevolent/farts/o2
	name = "O2 Farts"
	desc = "The infected individual occasionally farts. Pure oxygen."
	rarity = THREAT_TYPE2
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

/datum/microbioeffects/material/organicglass
	name = "Organic Glass"
	desc = "The microbes produce silicate, reinforcing and repairing glass structures."

	object_act(var/obj/O, var/datum/microbe/origin)
		var/volume = 1
		if(istype(O,/obj/window))
			O.reagents.add_reagent("silicate", volume, null)

	onadd(var/datum/microbe/origin)
		origin.effectdata += "organicglass"

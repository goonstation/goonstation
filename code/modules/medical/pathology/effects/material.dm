// Effects related to materials and gas production go here.

datum/pathogeneffects/malevolent/farts
	name = "Farts"
	desc = "The infected individual occasionally farts."
	infect_type = INFECT_AREA
	spread = SPREAD_AIR
	rarity = THREAT_TYPE2
	var/cooldown = 200 // we just use the name of the symptom to keep track of different fart effects, so their cooldowns do not interfere
	var/doInfect = 1 // smoke farts were just too good

	proc/fart(var/mob/M, var/datum/pathogen/origin, var/voluntary)
		if(doInfect)
			src.infect_cloud(M, origin, origin.spread/5)
		if(voluntary)
			origin.symptom_data[name] = TIME

	onemote(mob/M as mob, act, voluntary, param, datum/pathogen/P)
		// involuntary farts are free, but the others use the cooldown
		if(voluntary && TIME-P.symptom_data[name] < cooldown)
			return
		if(act == "fart")
			fart(M, P, voluntary)

	disease_act(var/mob/M, var/datum/pathogen/origin)
		if (origin.in_remission)
			return
		if (prob(origin.stage))
			M.emote("fart")

	may_react_to()
		return "The pathogen appears to produce a large volume of gas."

datum/pathogeneffects/malevolent/farts/smoke
	name = "Smoke Farts"
	desc = "The infected individual occasionally farts reagent smoke."
	rarity = THREAT_TYPE3
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
		return "The [RE.name] violently explodes into a puff of smoke when coming into contact with the pathogen."

datum/pathogeneffects/malevolent/farts/plasma
	name = "Plasma Farts"
	desc = "The infected individual occasionally farts. Plasma."
	rarity = THREAT_TYPE4
	cooldown = 600

	fart(var/mob/M, var/datum/pathogen/origin, var/voluntary)
		..()
		var/turf/T = get_turf(M)
		var/datum/gas_mixture/gas = new /datum/gas_mixture
		gas.zero()
		gas.toxins = origin.stage * (voluntary ? 0.6 : 3) // only a fifth for voluntary farts
		gas.temperature = T20C
		gas.volume = R_IDEAL_GAS_EQUATION * T20C / 1000
		if (T)
			T.assume_air(gas)

	disease_act(var/mob/M, var/datum/pathogen/origin)
		if (origin.in_remission)
			return
		..()
		if (origin.stage > 2 && prob(origin.stage * 3))
			M.take_toxin_damage(1)
			M.take_oxygen_deprivation(4)

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

	disease_act(var/mob/M, var/datum/pathogen/origin)
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

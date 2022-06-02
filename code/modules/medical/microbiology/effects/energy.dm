// Effects related to energy and electricity go here
ABSTRACT_TYPE(/datum/microbioeffects/energy)
/datum/microbioeffects/energy
	name = "Energy Effects"

//datum/microbioeffects/toolcharger
	//On object:
		//Check if its an energy object (e-guns, tasers, batong, miner tools, antique gun, etc.)
		//If so...
		//Give it charging buffs

//I'm moving the gas producing effect here: I want to add these as machines like gas drills on other codebases
//for engineering to have a unique way to replenish gas canisters!

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





//The capacitor effects must be reevaluated now that arcfiends exist.

/*datum/pathogeneffects/malevolent/capacitor
	name = "Capacitor"
	desc = "The infected is involuntarily electrokinetic."
	rarity = THREAT_TYPE5
	var/static/capacity = 1e7
	proc/electrocute(var/mob/V as mob, var/shock_load)
		V.shock(src, shock_load, "chest", 1, 0.5)

		elecflash(V,power = 2)

	proc/discharge(var/mob/M as mob, var/datum/pathogen/origin)
		var/load = origin.effectdata["capacitor"]
		if (load == 0)
			return
		elecflash(M,power = 2)
		if (load > 4e6)
			M.visible_message("<span class='alert'>[M] releases a burst of lightning into the air!</span>", "<span class='alert'>You discharge your energy into the air. It leaves your skin burned to a fine crisp.</span>", "<span class='alert'>You hear a burst of electricity.</span>")
			M.TakeDamage("chest", 0, 30)
			M.changeStatus("stunned", 1 SECOND)
			for (var/mob/V in orange(4, M))
				electrocute(V, load / 10)
		else if (load > 1e6)
			M.visible_message("<span class='alert'>[M] releases a burst of lightning into the air!</span>", "<span class='alert'>You discharge your energy into the air. It leaves your skin burned to a fine crisp.</span>", "<span class='alert'>You hear a burst of electricity.</span>")
			M.TakeDamage("chest", 0, 20)
			M.changeStatus("stunned", 7 SECONDS)
			for (var/mob/V in orange(4, M))
				electrocute(V, load / 10)
		else if (load > 50000)
			M.visible_message("<span class='alert'>[M] releases a considerable amount of electricity into the air!</span>", "<span class='alert'>You discharge your energy into the air. It leaves your skin burned heavily.</span>", "<span class='alert'>You hear a burst of electricity.</span>")
			M.TakeDamage("chest", 0, 15)
			M.changeStatus("stunned", 4 SECONDS)
			for (var/mob/V in orange(3, M))
				electrocute(V, load / 10)
		else if (load > 20000)
			M.visible_message("<span class='alert'>[M] releases a bolt of lightning into the air!</span>", "<span class='alert'>You discharge your energy into the air. It leaves your skin burned lightly.</span>", "<span class='alert'>You hear a burst of electricity.</span>")
			M.TakeDamage("chest", 0, 10)
			M.changeStatus("stunned", 2 SECONDS)
			for (var/mob/V in orange(2, M))
				electrocute(V, load / 10)
		else if (load > 5000)
			M.changeStatus("stunned", 1 SECOND)
			M.visible_message("<span class='alert'>[M] releases a few sparks into the air.</span>", "<span class='alert'>You discharge your energy into the air.</span>", "<span class='alert'>You hear a burst of electricity.</span>")
			for (var/mob/V in orange(1, M))
				electrocute(V, load / 10)
		else if (load > 0)
			M.show_message("<span class='notice'>You feel discharged.</span>")
		origin.effectdata["capacitor"] = 0

	proc/load_check(var/mob/M as mob, var/datum/pathogen/origin)
		var/load = origin.effectdata["capacitor"]
		if (load > capacity)
			M.show_message("<span class='alert'>You burst into several, shocking pieces.</span>")
			src.infect_cloud(M, origin, origin.spread)
			explosion(M, M.loc,1,2,3,4)
		else if (load > capacity * 0.9)
			M.show_message("<span class='alert'>You are severely overcharged. It feels like the voltage could burst your body at any moment.</span>")
		else if (load > capacity * 0.8)
			M.show_message("<span class='alert'>You are beginning to feel overcharged.</span>")

	onadd(var/datum/pathogen/origin)
		origin.effectdata["capacitor"] = 0

	onshocked(var/mob/M as mob, var/datum/shockparam/ret, var/datum/pathogen/origin)
		var/amt = ret.amt
		var/wattage = ret.wattage
		if (wattage > 45000)
			origin.effectdata["capacitor"] += wattage
			amt /= 2
			ret.skipsupp = 1
			M.show_message("<span class='notice'>You absorb a portion of the electric shock!</span>")
		else
			amt = 0
			ret.skipsupp = 1
			M.show_message("<span class='notice'>You absorb the electric shock!</span>")
		load_check(M, origin)
		return ret

	ondisarm(var/mob/M as mob, var/mob/V as mob, isPushDown, var/datum/pathogen/origin)
		var/load = origin.effectdata["capacitor"]
		if (load > 1e6 && isPushDown)
			if (prob(25))
				M.visible_message("<span class='alert'>[M]'s hands are glowing in a blue color.</span>", "<span class='notice'>You discharge yourself onto your opponent with your hands!</span>", "<span class='alert'>You hear someone getting defibrillated.</span>")
				electrocute(V, load / 10)
				if (prob(50))
					M.show_message("<span class='alert'>Your shock jumps back onto you!</span>")
					electrocute(M, load / 10)
				origin.effectdata["capacitor"] = 0
		return 1

	onpunch(var/mob/M as mob, var/mob/V as mob, zone, var/datum/pathogen/origin)
		var/load = origin.effectdata["capacitor"]
		if (load > 2e6)
			if (prob(25))
				M.visible_message("<span class='alert'>[M]'s fists are covered in electric arcs.</span>", "<span class='notice'>You supercharge your punch.</span>", "<span class='alert'>You hear a huge electric crackle.</span>")
				electrocute(V, load / 10)
				if (prob(50))
					M.show_message("<span class='alert'>Your shock jumps back onto you!</span>")
					electrocute(M, load / 10)
				origin.effectdata["capacitor"] /= 2
		else if (load > 500000)
			if (prob(20))
				M.visible_message("<span class='alert'>[M]'s fists spark electric arcs.</span>", "<span class='notice'>You overcharge your punch.</span>", "<span class='alert'>You hear a large electric crackle.</span>")
				electrocute(V, load / 10)
				if (prob(50))
					M.show_message("<span class='alert'>Your shock jumps back onto you!</span>")
					electrocute(M, load / 10)
				origin.effectdata["capacitor"] /= 2
		else if (load > 200000)
			if (prob(15))
				M.visible_message("<span class='alert'>[M]'s fists throw sparks.</span>", "<span class='notice'>You charge your punch.</span>", "<span class='alert'>You hear an electric crackle.</span>")
				electrocute(V, load / 10)
				if (prob(50))
					M.show_message("<span class='alert'>Your shock jumps back onto you!</span>")
					electrocute(M, load / 10)
				origin.effectdata["capacitor"] /= 2
		return 1

	onpunched(var/mob/M as mob, var/mob/A as mob, zone, var/datum/pathogen/origin)
		var/load = origin.effectdata["capacitor"]
		if (load > 5000)
			if (prob(25))
				M.visible_message("<span class='alert'>[M] loses control and discharges his energy!</span>", "<span class='alert'>You flinch and discharge.</span>", "<span class='alert'>You hear someone getting shocked.</span>")
				discharge(M, origin)
		return 1

	mob_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (origin.in_remission)
			return
		var/load = origin.effectdata["capacitor"]
		switch (origin.stage)
			if (1)
				if (prob(9))
					var/obj/cable/C = locate() in range(3, M)
					var/datum/powernet/PN
					if (C)
						PN = C.get_powernet()
					if (C && PN.avail > 0)
						elecflash(C,power = 2)
						M.visible_message("<span class='alert'>A spark jumps from the power cable at [M].</span>", "<span class='alert'>A spark jumps at you from a nearby cable.</span>", "<span class='alert'>You hear something spark.</span>")

			if (2)
				if (prob(9))
					var/obj/cable/C = locate() in range(3, M)
					var/datum/powernet/PN
					if (C)
						PN = C.get_powernet()
					if (C && PN.avail > 0)
						elecflash(C,power = 2)
						M.visible_message("<span class='alert'>A spark jumps from the power cable at [M].</span>", "<span class='alert'>A spark jumps at you from a nearby cable.</span>", "<span class='alert'>You hear something spark.</span>")
						var/amt = max(250000, PN.avail)
						PN.newload -= amt
						origin.effectdata["capacitor"] += amt
						if (amt > 2500 && load > 5000)
							M.show_message("<span class='notice'>You feel energized.</span>")
						load_check(M, origin)
				else if (prob(6))
					if (load > 0)
						discharge(M, origin)

			if (3)
				if (prob(10))
					var/obj/cable/C = locate() in range(4, M)
					var/datum/powernet/PN
					if (C)
						PN = C.get_powernet()
					if (C && PN.avail > 0)
						elecflash(C,power = 2)
						M.visible_message("<span class='alert'>A bolt of electricity jumps at [M].</span>", "<span class='alert'>A bolt of electricity jumps at you from a nearby cable. It burns!</span>", "<span class='alert'>You hear something spark.</span>")
						M.TakeDamage("chest", 0, 3)
						var/amt = max(1e6, PN.avail)
						PN.newload -= amt
						origin.effectdata["capacitor"] += amt
						if (amt > 5000 && load > 5000)
							M.show_message("<span class='notice'>You feel energized.</span>")
						load_check(M, origin)
				else if (prob(6))
					if (load > 0)
						discharge(M, origin)

			if (4)
				if (prob(15))
					var/obj/machinery/power/smes/S = locate() in range(4, M)
					if (S?.charge > 0) // Look for active SMES first
						elecflash(S,power = 2)
						M.visible_message("<span class='alert'>A burst of lightning jumps at [M] from [S].</span>", "<span class='alert'>A burst of lightning jumps at you from [S]. It burns!</span>", "<span class='alert'>You hear something spark.</span>")
						M.TakeDamage("chest", 0, 15)
						var/amt = S.charge
						S.charge -= amt
						origin.effectdata["capacitor"] += amt
						if (amt > 5000 && load > 5000)
							M.show_message("<span class='notice'>You feel energized.</span>")
						load_check(M, origin)
					else
						var/obj/machinery/power/apc/A = locate() in view(4, M)
						if (A?.cell?.charge > 0)
							elecflash(A,power = 2)
							M.visible_message("<span class='alert'>A burst of lightning jumps at [M] from [A].</span>", "<span class='alert'>A burst of lightning jumps at you from [A]. It burns!</span>", "<span class='alert'>You hear something spark.</span>")
							M.TakeDamage("chest", 0, 5)
							var/amt  = A.cell.charge / 6
							A.cell.charge -= amt
							origin.effectdata["capacitor"] += amt * 50
							if (amt > 5000 && load > 5000)
								M.show_message("<span class='notice'>You feel energized.</span>")
							load_check(M, origin, origin)
						else
							var/obj/cable/C = locate() in range(4, M)
							var/datum/powernet/PN
							if (C)
								PN = C.get_powernet()
							if (C && PN.avail > 0)
								elecflash(C,power = 2)
								M.visible_message("<span class='alert'>A burst of lightning jumps at [M].</span>", "<span class='alert'>A burst of lightning jumps at you from a nearby cable. It burns!</span>", "<span class='alert'>You hear something spark.</span>")
								M.TakeDamage("chest", 0, 5)
								var/amt = max(3e6, PN.avail)
								PN.newload -= amt
								origin.effectdata["capacitor"] += amt * 2
								if (amt > 5000 && load > 5000)
									M.show_message("<span class='notice'>You feel energized.</span>")
								load_check(M, origin)
				else if (prob(6))
					if (load > 0)
						discharge(M, origin)
			if (5)
				if (prob(15))
					var/obj/machinery/power/smes/S = locate() in range(4, M)
					if (S?.charge > 0) // Look for active SMES first
						elecflash(S,power = 2)
						M.visible_message("<span class='alert'>A burst of lightning jumps at [M] from [S].</span>", "<span class='alert'>A burst of lightning jumps at you from [S]. It burns!</span>", "<span class='alert'>You hear something spark.</span>")
						M.TakeDamage("chest", 0, 15)
						var/amt = S.charge
						S.charge -= amt
						origin.effectdata["capacitor"] += amt
						if (amt > 5000 && load > 5000)
							M.show_message("<span class='notice'>You feel energized.</span>")
						load_check(M, origin)
					else
						var/obj/machinery/power/apc/A = locate() in view(4, M)
						if (A?.cell?.charge > 0)
							elecflash(A,power = 2)
							M.visible_message("<span class='alert'>A burst of lightning jumps at [M] from [A].</span>", "<span class='alert'>A burst of lightning jumps at you from [A]. It burns!</span>", "<span class='alert'>You hear something spark.</span>")
							M.TakeDamage("chest", 0, 5)
							var/amt = A.cell.charge / 5 // apcs have a weirdly low capacity.
							A.cell.charge -= amt
							origin.effectdata["capacitor"] += amt * 50
							if (amt > 5000 && load > 5000)
								M.show_message("<span class='notice'>You feel energized.</span>")
							load_check(M, origin)
						else // Then a power cable if not found
							var/obj/cable/C = locate() in range(4, M)
							var/datum/powernet/PN
							if (C)
								PN = C.get_powernet()
							if (C && PN.avail > 0)
								elecflash(C,power = 2)
								M.visible_message("<span class='alert'>A burst of lightning jumps at [M].</span>", "<span class='alert'>A burst of lightning jumps at you from a nearby cable. It burns!</span>", "<span class='alert'>You hear something spark.</span>")
								M.TakeDamage("chest", 0, 5)
								var/amt = PN.avail
								PN.newload += amt
								origin.effectdata["capacitor"] += amt * 3
								if (amt > 5000 && load > 5000)
									M.show_message("<span class='notice'>You feel energized.</span>")
								load_check(M, origin)
				else if (prob(1))
					if (load > 0)
						discharge(M, origin)

	may_react_to()
		return "The culture appears to have an irregular lack of liquids, but a very high amount of hydrogen and oxygen."

	react_to(var/R, var/zoom)
		if (R == "water")
			if (zoom)
				return "The water inside the petri dish appears to be breaking down into hydrogen and oxygen."
			else
				return "The water near the pathogen is rapidly disappearing."
		if (R == "voltagen")
			return "Bits of pathogen violently explode when coming into contact with the voltagen."
		else return null

datum/pathogeneffects/malevolent/capacitor/unlimited
	name = "Unlimited Capacitor"

	load_check(var/mob/M as mob, var/datum/pathogen/origin)
		return null

	react_to(var/R, var/zoom)
		if (R == "voltagen")
			return "The pathogen appears to have the ability to infinitely absorb the voltagen."
*/

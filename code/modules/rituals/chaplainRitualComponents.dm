//Hello, welcome to my rambling notes to myself. Please enjoy.

//!! MAKE SURE YOU CHECK FOR APPLYAOE AND DO NOT APPLY AOE IF IT IS 1.
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!^ ^^^ ^^^^

//TBI: Dice component (RNG), other object based hidden components.
//Nicer corruption handling
//Sanctified spells?
//Electricity component (batteries?)
//Corrupted life = necromancy, ressurect, unstable.

//memento, scriptorum component, core, memorizes unknown components to chalk. found on pens.
//add var that determines whether we can memorize component with above.

//sprite component, sprite spells, follow people around.
//dimension component, does dimension and space stuff, found on hand teleporter.

//Make air displace water ?????
//Ritual self sacrifice - auto activate ritual on success
//more visible effects on critters, more dramatic changes. can do. full tile overlays, distinct effects
//permanent enchantment on critters

//Organ sacrifice
//Rune filter removal not working ??

/datum/ritualComponent

	//AOE is passed along into the sprites spells instead of being used in the summoning
	//Logic for these is a bit backwards, we summon a normal sprite by default and modify components then change that into different types in their modify procs.
	anima
		id = "anima"
		name = "Anima"
		icon_symbol = "anima"
		desc = "The sigil of souls. Sprites created by this sigil maybe overload unpredictably when more than one sigil is used to modify them."
		ritualFlags = RITUAL_FLAG_CREATE

		flag_create(var/datum/ritualVars/V, var/atom/loc, var/applyaoe=1)
			var/list/created = list()
			ritualEffect(aloc = get_turf(loc), istate = "summonsprite", duration = 50, aoe = 0)
			var/obj/ritual_sprite/I = new/obj/ritual_sprite(get_turf(loc))
			created.Add(I)
			return created

	aer
		id = "aer"
		name = "Aer"
		icon_symbol = "aer"
		desc = "The sigil of air."
		ritualFlags = RITUAL_FLAG_CREATE | RITUAL_FLAG_MODIFY

		showEffect(var/atom/location, var/datum/ritualVars/ritVars, var/applyaoe = 1)
			if(ritVars.aoe && !applyaoe)
				return ritualEffect(aloc = get_turf(location), istate = "rit-air-aoe", duration = 50, aoe = ritVars.aoe)
			else
				return ritualEffect(aloc = get_turf(location), istate = "air", duration = 50, aoe = 0)

		flag_modify(var/datum/ritualVars/V, var/atom/A, var/applyaoe=1)
			showEffect(A, V, applyaoe)
			var/list/targetsplusaoe = list()

			if(V.aoe && applyaoe)
				for(var/atom/X in view(V.aoe, A))
					if(X.type == A.type)
						targetsplusaoe += A
			else
				targetsplusaoe += A

			for(var/atom/T in targetsplusaoe) //Air enchant makes air
				if(istype(T, /obj/item))
					SPAWN(0)
						T:setProperty("stamcost", min(round(V.strength/6),1))
						SPAWN(max(200*V.strength, 30))
							if(T)
								T:setProperty("stamcost", 0)
						animate_float(T)
				else if(isobj(T))
					SPAWN(0)
						T.setStatus("airrit", (istype(T, /obj/critter) ? null : 120*V.strength))
				else if(ismob(T))
					SPAWN(0)
						var/mob/M = T
						M.losebreath = max(M.losebreath-round(V.strength), 0)
						if(hasvar(M, "oxyloss"))
							M:oxyloss = max(M:oxyloss-round(V.strength*1.5), 0)
						M.emote("cough")
						M.setStatus("airrit", 120*V.strength)
				else if(isturf(T))
					SPAWN(0) flag_create(V, T, 0)
			return A

		flag_create(var/datum/ritualVars/V, var/atom/loc, var/applyaoe=1)
			showEffect(loc, V, applyaoe)
			if(V.aoe <= 0 || !applyaoe)
				var/turf/T = get_turf(loc)
				for(var/obj/fluid/F in T)
					F.removed(0)
				ritualEffect(T, "air")
				var/datum/gas_mixture/GM = T.return_air()
				var/amount = (clamp(V.strength**1.5, 1, CELL_VOLUME/18))  //FUCK IF I KNOW WHAT GOES HERE FUCK
				if (istype(GM))
					GM.oxygen += amount
					loc.assume_air(GM)
			else
				var/energy_counter = 1

				for(var/turf/T in view(V.aoe, loc))
					if (V.energy <= 0) break
					V.energy-= energy_counter
					energy_counter++
					ritualEffect(get_turf(T), "air")
					for(var/obj/fluid/F in T)
						F.removed(0)
					var/datum/gas_mixture/GM = T.return_air()
					var/amount = (clamp(V.strength**1.5, 1, CELL_VOLUME/25)) //FUCK IF I KNOW WHAT GOES HERE FUCK. Also weaker version for AOE.
					if (istype(GM))
						GM.oxygen += amount
						T.assume_air(GM)
			return list()

	terra
		id = "terra"
		name = "Terra"
		icon_symbol = "terra"
		desc = "The sigil of earth."
		ritualFlags = RITUAL_FLAG_CREATE | RITUAL_FLAG_MODIFY

		showEffect(var/atom/location, var/datum/ritualVars/ritVars, var/applyaoe = 1)
			if(ritVars.aoe && !applyaoe)
				return ritualEffect(aloc = get_turf(location), istate = "rit-earth-aoe", duration = 50, aoe = ritVars.aoe)
			else
				return ritualEffect(aloc = get_turf(location), istate = "earth", duration = 50, aoe = 0)

		flag_modify(var/datum/ritualVars/V, var/atom/A, var/applyaoe=1)
			showEffect(A, V, applyaoe)
			var/list/possibleMaterials = list()
			switch(V.strength)
				if(0 to 5)
					possibleMaterials = list("rock", "steel", "mauxite", "copper", "pharosium", "glass")
				if(6 to 10)
					possibleMaterials = list("cobryl", "bohrum", "molitz", "claretine", "bone", "bamboo","wendigohide")
				if(10 to 20)
					possibleMaterials = list("electrum", "cerenkite", "syreline", "gold", "uqill", "miracle", "erebite", "telecrystal")
				if(21 to INFINITY)
					possibleMaterials = list("starstone", "kingwendigohide", "carbonfibre", "ectofibre", "iridiumalloy")
			if(ismob(A))
				SPAWN(0)
					A.changeStatus("stonerit", 120*V.strength)
			else if(isobj(A))
				SPAWN(0)
					A.setMaterial(getMaterial(pick(possibleMaterials)))
					A.changeStatus("stonerit", (istype(A, /obj/critter) ? null : 120*V.strength))
			else if(isturf(A))
				SPAWN(0) A.setMaterial(getMaterial(pick(possibleMaterials)))
			return A

		flag_create(var/datum/ritualVars/V, var/atom/loc, var/applyaoe=1)
			var/list/created = list()
			showEffect(loc, V, applyaoe)
			if(V.aoe <= 0 || !applyaoe)
				var/spawnType = /obj/item/raw_material/rock
				ritualEffect(get_turf(loc), "earth")
				switch(V.strength)
					if(1 to 3)
						spawnType = pick(/obj/item/raw_material/rock,/obj/item/raw_material/char,/obj/item/raw_material/mauxite, /obj/item/raw_material/molitz)
					if(4 to 7)
						spawnType = pick(/obj/item/raw_material/pharosium,/obj/item/raw_material/plasmastone,/obj/item/raw_material/cerenkite)
					if(8 to 14)
						spawnType = pick(/obj/item/raw_material/gemstone,/obj/item/raw_material/uqill,/obj/item/raw_material/erebite,/obj/item/raw_material/syreline,/obj/item/raw_material/cobryl)
					if(15 to 29)
						spawnType = pick(/obj/item/raw_material/miracle,/obj/item/raw_material/martian,/obj/item/raw_material/eldritch,/obj/item/raw_material/telecrystal)
					if(30 to INFINITY)
						spawnType = pick(/obj/item/raw_material/starstone, /obj/item/material_piece/iridiumalloy, /obj/item/material_piece/cloth/carbon)

				for(var/i=0, i<rand(5,15)+round(V.strength/10), i++)
					var/obj/item/I = new spawnType
					I.set_loc(loc)
					created.Add(I)
			else
				var/energy_counter = 1
				for(var/turf/T in view(V.aoe, loc))
					if (V.energy <= 0) break
					V.energy-= energy_counter
					energy_counter++
					var/spawnType = /turf/simulated/wall/auto/asteroid
					switch(V.strength)
						if(1 to 6)
							spawnType = /turf/simulated/wall/auto/asteroid/dark
						if(7 to INFINITY)
							spawnType = /turf/simulated/wall/auto/asteroid/geode
					// created.Add(new spawnType(T))
					created.Add(T.ReplaceWith(spawnType, FALSE, TRUE, FALSE))

			return created

	aqua
		id = "aqua"
		name = "Aqua"
		icon_symbol = "aqua"
		desc = "The sigil of water."
		ritualFlags = RITUAL_FLAG_CREATE | RITUAL_FLAG_MODIFY

		showEffect(var/atom/location, var/datum/ritualVars/ritVars, var/applyaoe = 1)
			if(ritVars.aoe && !applyaoe)
				return ritualEffect(aloc = get_turf(location), istate = "rit-water-aoe", duration = 50, aoe = ritVars.aoe)
			else
				return ritualEffect(aloc = get_turf(location), istate = "water", duration = 50, aoe = 0)

		flag_modify(var/datum/ritualVars/V, var/atom/A, var/applyaoe=1)
			showEffect(A, V, applyaoe)
			if(ismob(A))
				SPAWN(0) A.delStatus("burning")
			else if(isobj(A))
				SPAWN(0) A.temperature_expose(null, TCMB, CELL_VOLUME)
			else if(isturf(A))
				SPAWN(0) flag_create(V, A)
			return A

		flag_create(var/datum/ritualVars/V, var/atom/loc, var/applyaoe=1)
			showEffect(loc, V, applyaoe)
			if(V.aoe <= 0 || !applyaoe)
				var/amount = 50 + (round(V.strength**1.5) * 100)
				var/datum/reagents/R = new /datum/reagents(amount)
				R.add_reagent("water", amount)
				var/turf/T = get_turf(loc)
				if (istype(T))
					R.reaction(T,TOUCH)
					R.clear_reagents()
			else
				var/energy_counter = 1
				for(var/turf/T in view(V.aoe, loc))
					if (V.energy <= 0) break
					V.energy-= energy_counter
					energy_counter++

					var/amount = 50 + (round(V.strength**1.055) * 100)
					var/datum/reagents/R = new /datum/reagents(amount)
					R.add_reagent("water", amount)
					var/turf/TU = get_turf(T)
					if (istype(TU))
						R.reaction(TU,TOUCH)
						R.clear_reagents()
			return list()

	ignis
		id = "ignis"
		name = "Ignis"
		icon_symbol = "ignis"
		desc = "The sigil of fire."
		ritualFlags = RITUAL_FLAG_CREATE | RITUAL_FLAG_MODIFY

		showEffect(var/atom/location, var/datum/ritualVars/ritVars, var/applyaoe = 1)
			if(ritVars.aoe && !applyaoe)
				return ritualEffect(aloc = get_turf(location), istate = "rit-fire-aoe", duration = 50, aoe = ritVars.aoe)
			else
				return ritualEffect(aloc = get_turf(location), istate = "fire", duration = 50, aoe = 0)

		flag_modify(var/datum/ritualVars/V, var/atom/A, var/applyaoe=1)
			showEffect(A, V, applyaoe)
			if(V.corrupted > 0)
				A.changeStatus("burning", 120*V.strength, BURNING_LV3)
			else
				if(ismob(A))
					SPAWN(0) A.changeStatus("firerit", 120*V.strength)
				else if(isobj(A))
					SPAWN(0)
						A.changeStatus("firerit", 120*V.strength)
						A.temperature_expose(null, PLASMA_MINIMUM_BURN_TEMPERATURE+500, CELL_VOLUME)
				else if(isturf(A))
					SPAWN(0) A:hotspot_expose(PLASMA_MINIMUM_BURN_TEMPERATURE+200, CELL_VOLUME)
			return A

		flag_create(var/datum/ritualVars/V, var/atom/loc, var/applyaoe=1)
			showEffect(loc, V, applyaoe)
			if(V.aoe <= 0 || !applyaoe)
				SPAWN(0) fireflash(loc, 1, 1)
			else
				SPAWN(0) fireflash(loc, V.aoe, 1)
			return list()

	obscurum
		id = "obscurum"
		name = "Obscurum"
		icon_symbol = "obscurum"
		desc = "The sigil of darkness."
		ritualFlags = RITUAL_FLAG_CREATE | RITUAL_FLAG_MODIFY

		showEffect(var/atom/location, var/datum/ritualVars/ritVars, var/applyaoe = 1)
			if(ritVars.aoe && !applyaoe)
				return ritualEffect(aloc = get_turf(location), istate = "rit-dark-aoe", duration = 50, aoe = ritVars.aoe)
			else
				return ritualEffect(aloc = get_turf(location), istate = "darkness", duration = 50, aoe = 0)

		flag_modify(var/datum/ritualVars/V, var/atom/A, var/applyaoe=1)
			showEffect(A, V, applyaoe)
			if(ismob(A))
				SPAWN(0) A.changeStatus("cloaked", max(200*V.strength, 30))
			else if(isobj(A))
				SPAWN(0) A.changeStatus("cloaked", max(200*V.strength, 30))
			else if(isturf(A))
				SPAWN(0) animate_fade_to_color_fill(A,"#111111",30)
				SPAWN(max(100*V.strength, 30))
					if(A)
						animate_fade_to_color_fill(A,"#FFFFFF",30)
			return A

		flag_create(var/datum/ritualVars/V, var/atom/loc, var/applyaoe=1)
			showEffect(loc, V, applyaoe)
			var/list/created = list()
			if(V.aoe <= 0 || !applyaoe)
				if(V.corrupted > 0)
					created.Add(new/obj/chaplainStuff/darkness/evil(get_turf(loc),max(200*V.strength, 30)))
				else
					created.Add(new/obj/chaplainStuff/darkness(get_turf(loc),max(200*V.strength, 30)))
			else
				var/energy_counter = 0
				for(var/turf/T in view(V.aoe, loc))
					if (V.energy <= 0) break
					V.energy-= energy_counter
					energy_counter++

					if(V.corrupted > 0)
						created.Add(new/obj/chaplainStuff/darkness/evil(T,max(150*V.strength, 30)))
					else
						created.Add(new/obj/chaplainStuff/darkness(T,max(150*V.strength, 30)))
			return created

	motus
		id = "motus"
		name = "Motus"
		icon_symbol = "motus"
		desc = "The sigil of movement."
		ritualFlags = RITUAL_FLAG_MODIFY

		flag_modify(var/datum/ritualVars/V, var/atom/A, var/applyaoe=1)
			if(isobj(A))
				SPAWN(0) A:throw_at(pick(oview(10,A)-oview(2,A)), 20, 2)
			else if (ismob(A))
				SPAWN(0)
					if(V.corrupted > 0)
						A.changeStatus("slowed", max(200*V.strength, 30))
					else
						A.changeStatus("hastened", max(200*V.strength, 30))
			else if (isturf(A))
				A:wet += 2
				SPAWN(max(20*V.strength, 20))
					if(A) A:wet -= 2
			return A

	apis
		id = "apis"
		name = "Apis"
		icon_symbol = "apis"
		desc = "The sigil of BEES."
		ritualFlags = RITUAL_FLAG_CREATE | RITUAL_FLAG_MODIFY

		showEffect(var/atom/location, var/datum/ritualVars/ritVars, var/applyaoe = 1)
			if(ritVars.aoe && !applyaoe)
				return ritualEffect(aloc = get_turf(location), istate = "rit-bee-aoe", duration = 50, aoe = ritVars.aoe)
			else
				return ritualEffect(aloc = get_turf(location), istate = "bee", duration = 50, aoe = 0)

		flag_modify(var/datum/ritualVars/V, var/atom/A, var/applyaoe=1)
			showEffect(A, V, applyaoe)
			if(ismob(A))
				SPAWN(0)
					for(var/obj/item/I in A)
						I.setMaterial(getMaterial("beewool"))
					if(istype(A,/mob/living/carbon/human))
						A:update_clothing()
			else if(isobj(A))
				SPAWN(0) A.setMaterial(getMaterial("beewool"))
			else if(isturf(A))
				SPAWN(0) A.setMaterial(getMaterial("beewool"))
			return A

		flag_create(var/datum/ritualVars/V, var/atom/loc, var/applyaoe=1)
			showEffect(loc, V, applyaoe)
			var/list/created = list()
			if(V.aoe <= 0 || !applyaoe)
				var/spawnType = /obj/critter/domestic_bee_larva
				if(V.corrupted > 0)
					switch(V.strength)
						if(1 to 19)
							spawnType = /obj/critter/domestic_bee/zombee
						if(20 to INFINITY)
							spawnType = /obj/critter/domestic_bee/zombee/lich
				else
					switch(V.strength)
						if(1 to 2)
							spawnType = /obj/critter/domestic_bee_larva
						if(3 to 5)
							spawnType = /obj/critter/domestic_bee/small
						if(6 to 17)
							spawnType = /obj/critter/domestic_bee
						if(18 to INFINITY)
							spawnType = /obj/critter/domestic_bee/fancy
				created.Add(new spawnType(loc))
			else
				var/energy_counter = 1
				var/spawnType = /obj/critter/domestic_bee/small
				for(var/turf/T in view(V.aoe, loc))
					if (V.energy <= 0) break
					V.energy-= energy_counter
					energy_counter++

					created.Add(new spawnType(T))
			return created

	sanguis
		id = "sanguis"
		name = "Sanguis"
		icon_symbol = "sanguis"
		desc = "The sigil of blood. Consumes blood on itself to provide power. Use sacrifical dagger on blood on this sigil to store power."
		ritualFlags = RITUAL_FLAG_ENERGY | RITUAL_FLAG_CONSUME
		var/maxPower = 5
		var/storedPower = 0

		flag_consume()
			var/list/destroy = list()
			var/power = 0

			if(owner)
				var/turf/T = get_turf(owner)
				for(var/obj/O in T)
					// if(istype(O,/obj/decal/cleanable/blood))
					// 	var/obj/decal/cleanable/blood/B = O
					// 	power += 2
					// 	destroy += B

					if(istype(O,/obj/fluid))
						var/obj/fluid/B = O
						if (B.group.master_reagent_id == "blood")
							power += 2
							destroy += B

				if(destroy.len)
					for(var/obj/fluid/B in destroy)
						destroy -= B
						B.removed(0)
					for(var/obj/O in destroy)
						qdel(O)

					ritualEffect(aloc = T, istate = "sacrifice", duration = 50, aoe = 0)

				storedPower += min(power,maxPower)
				return

		flag_power(var/datum/ritualVars/V, var/consume=1)
			V.energy += storedPower
			if(consume) storedPower = 0
			return V

	exalto
		id = "exalto"
		name = "Exalto"
		icon_symbol = "exalto"
		desc = "The sigil of power. Provides 1 strength if it's the only one of it's kind."
		ritualFlags = RITUAL_FLAG_STRENGTH

		flag_strength(var/datum/ritualVars/V, var/consume=1)
			if(ownerAnchor)
				var/list/powerComps = ownerAnchor.getFlagged(RITUAL_FLAG_STRENGTH, list(src))
				for(var/datum/ritualComponent/C in powerComps)
					if(C.id == "exalto" && C != src) return V
				V.strength += 1
			return V

	sanctus
		id = "sanctus"
		name = "Sanctus"
		icon_symbol = "sanctus"
		desc = "Holy sigil. Lowers the corruption level of the ritual."
		ritualFlags = RITUAL_FLAG_MODIFY | RITUAL_FLAG_HOLY
		selectable = 0

		flag_corruption(var/datum/ritualVars/V)
			V.corrupted -= 1
			return V

		flag_modify(var/datum/ritualVars/V, var/atom/A, var/applyaoe=1)
			if(isobj(A))
				if(istype(A, /obj/item/ritualChalk))
					var/obj/item/ritualChalk/C = A
					if(!C.blessed)
						C.cursed = 0
						C.blessed = 1
						C.add_filter("sanctus_drop_shadow", 0, drop_shadow_filter(x=0, y=0, offset=0, size=5, color="#f2e8a7"))
						C.addButton(new src.type())
						C.remove_prefixes(2)
						C.name_prefix("sanctified")
						C.UpdateName()
			return A

	corruptus
		id = "corruptus"
		name = "Corruptus"
		icon_symbol = "corruptus"
		desc = "The sigil of corruption. Corrupts rituals, reversing or changing effects."
		ritualFlags = RITUAL_FLAG_MODIFY | RITUAL_FLAG_UNHOLY
		selectable = 0

		flag_corruption(var/datum/ritualVars/V)
			V.corrupted += 1
			return V

		flag_modify(var/datum/ritualVars/V, var/atom/A, var/applyaoe=1)
			if(istype(A, /obj/item/ritualChalk))
				var/obj/item/ritualChalk/C = A
				if(!C.cursed)
					C.cursed = 1
					C.blessed = 0
					C.add_filter("corruptus_drop_shadow", 0, drop_shadow_filter(x=0, y=0, offset=0, size=5, color="#b023fc"))
					C.addButton(new src.type())
					C.remove_prefixes(2)
					C.name_prefix("cursed")
					C.UpdateName()
			return A

	sacrificum
		id = "sacrificum"
		name = "Sacrificum"
		icon_symbol = "sacrificum"
		desc = "The sigil of sacrifice. Provides power/strength for money, people, limbs or spirit shards sacrificed. Use sacrifical dagger on things on this sigil to store power."
		ritualFlags = RITUAL_FLAG_ENERGY | RITUAL_FLAG_STRENGTH | RITUAL_FLAG_CONSUME
		var/maxPower = 10
		var/maxObjects = 3
		var/storedPower = 0
		var/storedStrength = 0
		var/corrupted = 0

		flag_consume()
			var/list/destroy = list()
			var/power = 0
			var/strength = 0
			var/count = 0

			if(owner)
				var/turf/T = get_turf(owner)
				for(var/mob/M in T)
					if(++count > maxObjects) break
					if(!M.lying  || !M.stat) continue		//nixed !M.hasStatus("resting") from this if, that can only be applied by pressing the rest key.
					if (M.bioHolder && M.bioHolder.HasOneOfTheseEffects("husk","sacrificed"))	continue

					if(M.client)
						power += 12 //Things without clients give much less.
						strength += 12
						if(prob(50))
							corrupted = max(corrupted, 1)
					else
						power += 3
						strength += 3
						if(prob(5))
							corrupted = max(corrupted, 1)
					destroy += M

				for(var/obj/O in T)
					if(istype(O,/obj/item/currency/spacecash))
						if(++count > maxObjects) break
						power += round(O:amount / 2000) //Money is power. Specifically energy for magic rituals. Not strength.
						destroy += O

					if(istype(O,/obj/item/parts/human_parts))
						if(++count > maxObjects) break
						var/obj/item/parts/human_parts/part = O
						if(part.kind_of_limb & (LIMB_PLANT | LIMB_ROBOT)) continue //Can't sacrifice robot or syntharms
						power += 1
						strength += 1
						destroy += O

					if(istype(O,/obj/item/organ))
						if(++count > maxObjects) break
						var/obj/item/organ/organ = O
						if (organ.robotic || organ.synthetic || organ.broken) continue	//Can't sacrifice robotic, synth, or broken
						power += 1
						strength += 1
						destroy += O

					if(istype(O,/obj/item/spiritshard))
						if(++count > maxObjects) break
						var/obj/item/spiritshard/S = O
						strength += S.storedStrength
						power += S.storedPower
						destroy += O
						if(S.corrupted)
							corrupted += 1

					if(istype(O,/obj/critter))
						if(++count > maxObjects) break
						var/obj/critter/C = O
						if (!C.alive)
							power += C.aggressive ? 3:1
							strength += C.aggressive ? 3:1
							destroy += O


				if(destroy.len)
					for(var/mob/M in destroy)
						if (!M.bioHolder)
							M.bioHolder = new /datum/bioHolder (M)

						M.bioHolder.AddEffect("sacrificed")
						// M.vaporize(0, 1)		//Old functionality, but we may want to use this if some mobs meet certain conditions so I'll leave it here if I come back -Kyle
					for(var/obj/O in destroy)
						for(var/mob/M in O)
							M.set_loc(O.loc)
						qdel(O)

					storedPower += power
					storedStrength += strength

					ritualEffect(aloc = get_turf(owner), istate = "sacrifice", duration = 50, aoe = 0)
			return

		flag_power(var/datum/ritualVars/V, var/consume=1)
			V.energy += storedPower
			if(consume)
				storedPower = 0
				if(corrupted > 0)
					V.corrupted += corrupted
			return V

		flag_strength(var/datum/ritualVars/V, var/consume=1)
			V.strength += storedStrength
			if(consume) storedStrength = 0
			return V

	spatium
		id = "spatium"
		name = "Spatium"
		icon_symbol = "spatium"
		desc = "The sigil of space. Can be used to increase the area of effect of rituals based on ritual strength at the cost of 5 energy."
		ritualFlags = RITUAL_FLAG_RANGE | RITUAL_FLAG_ENERGY

		flag_strength(var/datum/ritualVars/V)
			V.energy -= 5
			return V

		flag_range(var/datum/ritualVars/V)
			var/range = 1
			if(ownerAnchor && ownerAnchor.owner)
				range = max(round(sqrt(V.strength * 0.5)),1)
			V.aoe += range
			return V


	extendo
		id = "extendo"
		name = "Extendo"
		icon_symbol = "extendo"
		desc = "The sigil of reach. Can be used to increase the targeting range of rituals for 2 energy."
		ritualFlags = RITUAL_FLAG_RANGE | RITUAL_FLAG_ENERGY

		flag_strength(var/datum/ritualVars/V)
			V.energy -= 2
			return V

		flag_range(var/datum/ritualVars/V)
			var/range = 1
			if(ownerAnchor && ownerAnchor.owner)
				range = max(round(V.strength / 2),1) //maybe cap this somewhere, I'm not sure if this will be a problem tho
			V.range = range
			return V

	persisto
		id = "persisto"
		name = "Persisto"
		icon_symbol = "persisto"
		desc = "The sigil of persistence. Prevents sigils from disappearing but costs 3 energy."
		ritualFlags = RITUAL_FLAG_PERSIST | RITUAL_FLAG_ENERGY

		flag_power(var/datum/ritualVars/V)
			V.energy -= 3
			return V

	hominem
		id = "hominem"
		name = "Hominem"
		icon_symbol = "hominem"
		desc = "The sigil of humans. Can be used to target nearby humans. If blood or bodyparts are placed on top, the owner will be targeted, if within range. Costs 1 energy. Targeting a specific person costs 5 additional energy."
		ritualFlags = RITUAL_FLAG_CREATE | RITUAL_FLAG_SELECT | RITUAL_FLAG_ENERGY

		flag_power(var/datum/ritualVars/V)
			V.energy -= 1
			return V

		flag_create(var/datum/ritualVars/V, var/atom/loc, var/applyaoe=1)
			var/list/created = list()
			//Gotta look at this again. This is a strange way of handling AOE that is unlike other handlings of it..
			//Might be preferrable actually
			var/energy_counter = 1
			for(var/turf/T in view(V.aoe, loc))
				if (V.energy <= 0) break
				V.energy-= energy_counter
				energy_counter++

				if(V.aoe <= 0 || !applyaoe)
					if(V.corrupted > 0)
						var/mob/living/critter/zombie/Z = new/mob/living/critter/zombie(T)		//zombie strength dependant on ritual strength.
						Z.friends += V.invoker
						var/datum/healthHolder/holder = Z.healthlist["brute"]
						holder?.maximum_value = V.strength+8
						holder?.value = V.strength+8
						//sorry this got broken with mobcritterization but now they have scary zombie arms too so giving them damage scaling is probably over the top anyway
						// Z.punch_damage_max = round(6+V.strength/2)
						// Z.punch_damage_min = round(Z.punch_damage_max/3)
						created.Add(Z)
					else
						var/mob/living/carbon/human/H
						var/const/min_str = 15
						if (V.strength > min_str)
							H = new/mob/living/carbon/human/normal(T)
							if (V.strength > min_str+15)
								H.take_toxin_damage(rand(50, 75))
								random_brute_damage(H, rand(50,75), 0)

							else
								H.bioHolder.AddEffect("sacrificed")
								H.take_toxin_damage(250)
								random_brute_damage(H, 150, 0)
							created.Add(H)
							H.set_body_icon_dirty()

						else if (V.strength > 5)
							gibs(T)



				else
					created.Add(T.ReplaceWith(/turf/simulated/floor/martian, FALSE, TRUE, FALSE))
			return created

		flag_select(var/datum/ritualVars/V)
			var/targetMax = max(round(V.strength / 5),1)
			var/list/targets = list()
			var/count = 0

			var/turf/T = get_turf(owner)
			var/mob/specificTarget = null

			//boutput(world, "1 [T]")

			for(var/obj/O in T)
				if(istype(O,/obj/decal/cleanable/blood))
					var/obj/decal/cleanable/blood/B = O
					for(var/mob/living/carbon/human/H in mobs)
						if(B.blood_DNA == H.bioHolder.Uid)
							specificTarget = H
							break

				if(istype(O,/obj/fluid))
					var/obj/fluid/B = O
					if (B.group.master_reagent_id == "blood")
						for(var/mob/living/carbon/human/H in mobs)
							if(B.blood_DNA == H.bioHolder.Uid)
								specificTarget = H
								break

				if(istype(O,/obj/item/parts/human_parts))
					var/obj/item/parts/human_parts/P = O
					if(P.original_holder)
						specificTarget = P.original_holder
						break

				if(istype(O,/obj/item/organ))
					var/obj/item/organ/P = O
					if(P.donor)
						specificTarget = P.donor
						break

				//boutput(world, "2")
			//boutput(world, "3 [specificTarget]")

			if(specificTarget)
				V.energy -= 5
				V.targets = list(specificTarget)
				//boutput(world, "4")
			else
				for(var/mob/M in view(RITUAL_BASE_RANGE+V.range, owner))
					//boutput(world, "5")
					if(ishuman(M))
						//boutput(world, "5a")
						targets += M
						count++
						if(count >= targetMax) break
				V.targets = targets
			return V

	objectum
		id = "objectum"
		name = "Objectum"
		icon_symbol = "objectum"
		desc = "The sigil of objects. Can be used to target objects on the sigil or nearby objects if additional range is added. Costs 1 energy."
		ritualFlags = RITUAL_FLAG_SELECT | RITUAL_FLAG_ENERGY

		flag_power(var/datum/ritualVars/V)
			V.energy -= 1
			return V

		flag_select(var/datum/ritualVars/V)
			var/targetMax = max(round(V.strength / 5),1)
			var/list/targets = list()
			var/count = 0
			for(var/obj/M in view(0+V.range, owner))
				if(isobj(M))
					if(istype(M, /obj/overlay)) continue
					if(istype(M, /obj/decal)) continue
					if(istype(M, /obj/effects)) continue
					if(M.invisibility) continue
					targets += M
					count++
					if(count >= targetMax) break

			V.targets = targets
			return V

	conditum
		id = "conditum"
		name = "Conditum"
		icon_symbol = "conditum"
		desc = "When used as the core of a ritual, this will store all excess power and strength in a spirit shard."
		ritualFlags = RITUAL_FLAG_CORE | RITUAL_FLAG_ENERGY | RITUAL_FLAG_STRENGTH

		//Remove any sort of baseline power to prevent infinite shards.
		flag_power(var/datum/ritualVars/V, var/consume=1)
			V.energy -= (1 + (V.chaplainBoosted * 2))
			return V

		flag_strength(var/datum/ritualVars/V, var/consume=1)
			V.strength -= (1 + (V.chaplainBoosted * 2))
			var/list/powerComps = ownerAnchor.getFlagged(RITUAL_FLAG_STRENGTH, list(src))
			for(var/datum/ritualComponent/C in powerComps)
				if(C.id == "exalto")
					V.strength -= 1
					break
			return V

		flag_core(var/datum/ritualVars/V)
			if(owner)
				if(!V.energy && !V.strength)
					return 0

				var/list/mods = ownerAnchor.getFlagged(RITUAL_FLAG_MODIFY, (list(src) + V.used + V.coreAdjacent))
				if (islist(mods))
					var/shards_to_create = 1
					var/datum/ritualComponent/motus = null
					for(var/datum/ritualComponent/C in mods)
						if (istype(C, /datum/ritualComponent/motus))		//bit of a hack with actual type check here, But for now I want this to be single use only.	-Kyle
							shards_to_create++
							motus = C

					if (shards_to_create > 1)
						V.energy = round(V.energy/(shards_to_create))
						V.strength = round(V.strength/(shards_to_create))

					V.strength = round(V.strength*0.99)

					for(var/i = 0; i < shards_to_create; i++)
						var/obj/item/spiritshard/S = new/obj/item/spiritshard(get_turf(owner),V)
						if (motus)
							motus.flag_modify(V, S, 0)

			return 1

	sano
		id = "sano"
		name = "Sano"
		icon_symbol = "sano"
		desc = "The sigil of healing."
		ritualFlags = RITUAL_FLAG_CORE | RITUAL_FLAG_MODIFY

		showEffect(var/atom/location, var/datum/ritualVars/ritVars, var/applyaoe = 1)
			if(ritVars.aoe && !applyaoe)
				return ritualEffect(aloc = get_turf(location), istate = "rit-heal-aoe", duration = 50, aoe = ritVars.aoe)
			else
				return ritualEffect(aloc = get_turf(location), istate = "heal", duration = 50, aoe = 0)

		flag_modify(var/datum/ritualVars/V, var/atom/A, var/applyaoe=1)
			showEffect(A, V, applyaoe)
			if (ismob(A) && V.corrupted <= 0)
				SPAWN(0) A.changeStatus("ritual_hot", max(200*V.strength, 30))
			else if (ismob(A) && V.corrupted > 0)
				SPAWN(0) A.changeStatus("ritual_dot", max(200*V.strength, 30))
			return A

		flag_core(var/datum/ritualVars/V)
			if(ownerAnchor)
				if(V.aoe <= 0)
					if(length(V.targets) <= 0) V.targets.Add(get_turf(ownerAnchor.owner))
					for(var/atom/A in V.targets)
						for(var/mob/M in view(V.aoe, A))
							showEffect(M, V, 0)
							if(ismob(M))
								var/mob/tMob = M
								if(V.corrupted > 0)
									tMob.TakeDamage("All", round(V.strength/3)+V.strength, round(V.strength/3)+V.strength, round(V.strength/3)+V.strength, DAMAGE_BLUNT)
								else
									tMob.HealDamage("All", round(V.strength/3)+V.strength, round(V.strength/3)+V.strength, round(V.strength/3)+V.strength)
				else
					if(length(V.targets) <= 0) V.targets.Add(get_turf(ownerAnchor.owner))
					for(var/atom/A in V.targets)
						showEffect(A, V, 1)
						for(var/mob/M in view(V.aoe, A))
							if (V.corrupted <= 0)
								SPAWN(0) M.changeStatus("ritual_hot", max(70*V.strength, 30))
							else if (V.corrupted > 0)
								SPAWN(0) M.changeStatus("ritual_dot", max(70*V.strength, 30))
			return 1

	mutatio
		id = "mutatio"
		name = "Mutatio"
		icon_symbol = "mutatio"
		desc = "The sigil of change."
		ritualFlags = RITUAL_FLAG_CORE | RITUAL_FLAG_MODIFY

		flag_core(var/datum/ritualVars/V)
			if(ownerAnchor)
				if(length(V.targets) <= 0) V.targets.Add(get_turf(ownerAnchor.owner))
				var/list/modify = ownerAnchor.getAdjacentFlagged(RITUAL_FLAG_MODIFY)
				for(var/atom/M in V.targets)
					for(var/datum/ritualComponent/C in modify)
						C.flag_modify(V, M, 1)
			return 1

	evoco
		id = "evoco"
		name = "Evoco"
		icon_symbol = "evoco"
		desc = "The sigil of summoning. Costs 1 energy."
		ritualFlags = RITUAL_FLAG_CORE | RITUAL_FLAG_ENERGY

		flag_power(var/datum/ritualVars/V)
			V.energy -= 1
			return V

		flag_core(var/datum/ritualVars/V)
			if(ownerAnchor)
				if(length(V.targets) <= 0) V.targets.Add(get_turf(ownerAnchor.owner))
				var/list/spawnedThings = list()
				var/list/creators = getAdjacentFlagged(RITUAL_FLAG_CREATE, V.used)
				var/datum/ritualComponent/creator = null

				if(creators.len)
					creator = creators[1]
					for(var/atom/M in V.targets)
						spawnedThings.Add(creator.flag_create(V,M))
				else
					for(var/atom/M in V.targets)
						spawnedThings.Add(make_cleanable(/obj/decal/cleanable/generic,M))

				var/list/modcreate = ownerAnchor.getFlagged(RITUAL_FLAG_MODIFY, (list(src, creator) + V.used + V.coreAdjacent))
				for(var/atom/movable/M in spawnedThings)
					for(var/datum/ritualComponent/C in modcreate)
						C.flag_modify(V, M, 0)
						V.strength = max(1,V.strength-1)
			return 1

	portus
		id = "portus"
		name = "Portus"
		icon_symbol = "portus"
		desc = "The sigil of travel and transportation. Costs 2 energy."
		ritualFlags = RITUAL_FLAG_CORE | RITUAL_FLAG_ENERGY// | RITUAL_FLAG_SECRET

		flag_power(var/datum/ritualVars/V)
			V.energy -= 2
			return V

		flag_core(var/datum/ritualVars/V)
			if(ownerAnchor)

				var/turf/dest = null
				//I'll do this for testing, not sure if I want to keep it this way though
				if(length(V.targets) <= 0)
					var/turf/T = get_turf(ownerAnchor.owner)
					V.targets = T.contents

					dest = T 			//initially set dest to the anchor turf
				if (owner)
					if (V.strength <= 0)
						return	//This should never happen, but it would runtime in dist calculation if it did.

					var/dir = owner.dir
					//picked this function because it's whacky and increases slowly with strength and levels off. at 6 strength you can move 1 tile. at 30, you move
					var/dist = clamp(round((log(V.strength)**2)*2-6), 0, 100)
					for (var/i = 0; i < dist; i++)
						dest = get_step(dest, dir)

				var/area/initial_a = get_area(ownerAnchor.owner)
				var/area/dest_a = get_area(dest)
				if (initial_a?.teleport_blocked || dest_a?.teleport_blocked)
					for (var/mob/M in V.targets)
						if (M.client)
							boutput(M, SPAN_ALERT("Some higher force prevents the teleport..."))
					return 0 //break, just so we don't waste time doing the for loop if it's teleblocked. shame do_teleport doesn't return a success/fail result

				var/count = 0
				var/max_to_move = min(100, V.strength*1.5)
				for (var/atom/movable/A in V.targets)
					if (count > max_to_move) break
					if (!A.anchored)
						do_teleport(A, dest, 2, 1, 0)

			return 1


///////////////////////////////////////////////////////////////////////////////////

/datum/chemical_reaction
	var/name = null
	var/id = null
	var/result = null
	///Used for complex reactions to show what they actually produce at the end (chem request console needs this)
	///Can be a list or a single string ID
	var/eventual_result = null
	var/list/required_reagents = new/list()
	var/list/inhibitors = list()
	var/instant = 1
	///If TRUE, a separate instance of the reaction will be created for the duration of the active reaction, otherwise a singleton will be used
	///Only makes sense for non-instant reactions
	var/stateful = FALSE
#ifdef CHEM_REACTION_PRIORITIES
	/// lower priorities happen last
	/// higher priorities happen first
	var/priority = 10
#endif

	/// Will not react if below this
	var/min_temperature = -INFINITY
	/// Will not react if above this
	var/max_temperature = INFINITY

	/// units produced per second
	var/reaction_speed = 5
	/// if TRUE, the reaction scales with volume, with the reaction_speed being the minimum speed the mixture reacts at
	var/reaction_volume_dependant = TRUE
	/// The reaction speed will scale lineary, with reaction_volume_for_double being the amount of reacting chems in the mixture needed for the reaction to take place at double speed.
	/// this means double that would result in triple the reaction speed
	var/reaction_volume_for_double = 100
	var/base_reaction_temp = T20C
	var/reaction_temp_divider = 10

	/// Logs the contents of the reagent holder's container in addition to the reaction itself.
	/// Used for foam and smoke (Convair880).
	var/special_log_handling = 0

	var/result_amount = 0
	var/mix_phrase = "The solution begins to bubble."
	var/mix_sound = 'sound/effects/bubbles.ogg'
	/// Is the result a drink?
	var/drinkrecipe = FALSE
	/// If set to 1, the recipe will consume ALL of its components instead of just proportional parts.
	var/consume_all = 0

	var/temperature_change = 0 ///added to the temperature on reaction, can be negative to remove heat

	var/list/reaction_icon_state = list("reaction_bubble-1", "reaction_bubble-2")  //which icon in chemical.dmi to use for reaction animations. picked randomly from list each time
	var/reaction_icon_color = null //default = color of reagent mix in holder

	///should this reaction show up in anything player-facing that lists reactions. For secret repo chems, misc precursors, and for 'non-standard' reactions (stuff like voltagen arc, foam reacting with water, etc)
	var/hidden = FALSE

	/// Called when something reacts or every tick while it is reacting
	proc/on_reaction(var/datum/reagents/holder, var/created_volume)
		return

	/// Special conditions unique to the reaction
	proc/does_react(var/datum/reagents/holder)
		return 1

	/// Called when a non-instant reaction ends, not called for instant reactions
	proc/on_end_reaction(var/datum/reagents/holder)
		return

	/// Called when a holder filled with a current (non-instant) reaction experiences physical shock
	proc/physical_shock(force, var/datum/reagents/holder)
		return

	/// this gets the total volume of the reaction mixture, according to the required chemical list
	/// this proc does not take factors into account, so you can increase the reaction speed of a reaction, like in real life, by adding one reagent in excess
	/// although this has some inaccuracies in comparison to real chemical reaction, i refrain from introducing accurate reaction kinetics for performance and my sanity reasons
	/// this gets inaccurate results in recipes which have one or more reagents checked in other procs, so there this proc has to be modified
	proc/get_total_reaction_volume(var/datum/reagents/holder)
		var/result = 0
		for(var/checked_reagent in src.required_reagents)
			result += holder.get_reagent_amount(checked_reagent)
		return result

	/// proc to calculate the rate with which the reaction does work with. To modify a reaction speed, either modify this or the reaction_speed variable
	proc/get_reaction_speed_multiplicator(var/datum/reagents/holder)
		var/result = 1 //returns at least 1, so reaction_speed is the lowest reaction speed, else reactions would never really stop (like in real life, heh)
		if (src.reaction_volume_dependant)
			result += src.get_volume_reaction_speed_factor(holder)
		return result

	/// this factor scaled lineary from 0 upwards, increasing by 1 for each reaction_volume_for_double in the reaction
	/// we need this factor seperatly because there are some reactions which have akward scaling for different chemicals, like e.g. the oil or diethyl ether recipe
	proc/get_volume_reaction_speed_factor(var/datum/reagents/holder)
		return round(src.get_total_reaction_volume(holder) / src.reaction_volume_for_double, 0.01)

	//I recommend you set the result amount to the total volume of all components.

	// the following three recipes should stop most of the nonsense with pyrosium lagging things to shit, hopefully??
	// if not yell at me to code better - haine


	//// EXAMPLE STATEFUL REACTION

	// countium
	// 	name = "Countium"
	// 	id = "countium"
	// 	instant = FALSE
	// 	stateful = TRUE
	// 	var/count = 0
	// 	reaction_speed = 1
	// 	required_reagents = list("water" = 1, "oxygen" = 1)
	// 	result_amount = 1

	// 	on_reaction(var/datum/reagents/holder, var/created_volume)
	// 		src.count++
	// 		boutput(world, "Countium counts: [src.count]")

	Lumen
		name = "Lumen"
		id = "lumen"
		required_reagents = list("radium" = 1, "omega_mutagen" = 1, "hydrogen" = 1, "helium" = 1, "luminol" = 1)
		mix_phrase = "The chemicals coalesce and begin to grow rather brightly!"
		mix_sound = 'sound/voice/heavenly.ogg'
		result_amount = 3
		result = "lumen"
		hidden = TRUE

	no_lumen_new_smoke
		name = "no lumen new smoke"
		id = "no_lumen_new_smoke"
		instant = 1
		required_reagents = list("lumen" = 1, "chlorine" = 1, "sugar" = 1, "hydrogen" = 1, "platinum" = 1)
		mix_phrase = "The mixture dissipates in a flash of intense light!"
		hidden = TRUE

		on_reaction(var/datum/reagents/holder, var/created_volume) //flash and sparks
			if (holder)
				holder.del_reagent("lumen")
				holder.del_reagent("chlorine")
				holder.del_reagent("sugar")
				holder.del_reagent("hydrogen")
				holder.del_reagent("platinum")
			var/location = get_turf(holder.my_atom)
			playsound(location, 'sound/weapons/flashbang.ogg', 25, TRUE)
			elecflash(location)
			for (var/mob/living/M in all_viewers(5, location))
				if (issilicon(M) || isintangible(M))
					continue

				var/dist = GET_DIST(M, location)
				M.apply_flash(60, 0, (3 - dist), 0, ((5 - dist) * 2), (2 - dist))

			for (var/mob/living/silicon/M in all_viewers(world.view, location))
				var/checkdist = GET_DIST(M, location)

				M.apply_flash(30, max(2 * (3 - checkdist), 0), max(2 * (5 - checkdist), 0))
			return

	no_lumen_new_smoke2
		name = "no lumen new smoke2"
		id = "no_lumen_new_smoke2"
		instant = 1
		required_reagents = list("lumen" = 1, "propellant" = 1)
		mix_phrase = "The mixture dissipates in a flash of intense light!"
		hidden = TRUE

		on_reaction(var/datum/reagents/holder, var/created_volume) //flash and sparks
			if (holder)
				holder.del_reagent("lumen")
				holder.del_reagent("propellant")
			var/location = get_turf(holder.my_atom)
			playsound(location, 'sound/weapons/flashbang.ogg', 25, TRUE)
			elecflash(location)
			for (var/mob/living/M in all_viewers(5, location))
				if (issilicon(M) || isintangible(M))
					continue

				var/dist = GET_DIST(M, location)
				M.apply_flash(60, 0, (3 - dist), 0, ((5 - dist) * 2), (2 - dist))

			for (var/mob/living/silicon/M in all_viewers(world.view, location))
				var/checkdist = GET_DIST(M, location)

				M.apply_flash(30, max(2 * (3 - checkdist), 0), max(2 * (5 - checkdist), 0))
			return

	no_lumen_smoke //still super laggy, maybe if someone has better ideas to optimise it we can bring this back?
		name = "no lumen smoke"
		id = "no_lumen_smoke"
		instant = 1
		required_reagents = list("lumen" = 1, "sugar" = 1, "phosphorus" = 1, "potassium" = 1)
		mix_phrase = "The mixture dissipates in a flash of intense light!"
		hidden = TRUE

		on_reaction(var/datum/reagents/holder, var/created_volume) //flash and sparks
			if (holder)
				holder.del_reagent("lumen")
				holder.del_reagent("sugar")
				holder.del_reagent("phosphorus")
				holder.del_reagent("potassium")
			var/location = get_turf(holder.my_atom)
			playsound(location, 'sound/weapons/flashbang.ogg', 25, TRUE)
			elecflash(location)
			for (var/mob/living/M in all_viewers(5, location))
				if (issilicon(M) || isintangible(M))
					continue

				var/dist = GET_DIST(M, location)
				M.apply_flash(60, 0, (3 - dist), 0, ((5 - dist) * 2), (2 - dist))

			for (var/mob/living/silicon/M in all_viewers(world.view, location))
				var/checkdist = GET_DIST(M, location)

				M.apply_flash(30, max(2 * (3 - checkdist), 0), max(2 * (5 - checkdist), 0))
			return

	no_lumen_smoke2 //what i said above, too laggy
		name = "no lumen smoke 2"
		id = "no_lumen_smoke2"
		instant = 1
		required_reagents = list("lumen" = 1, "smokepowder" = 1)
		mix_phrase = "The mixture dissipates in a flash of intense light!"
		hidden = TRUE

		on_reaction(var/datum/reagents/holder, var/created_volume) //flash and sparks
			if (holder)
				holder.del_reagent("lumen")
				holder.del_reagent("smokepowder")
			var/location = get_turf(holder.my_atom)
			playsound(location, 'sound/weapons/flashbang.ogg', 25, TRUE)
			elecflash(location)
			for (var/mob/living/M in all_viewers(5, location))
				if (issilicon(M) || isintangible(M))
					continue

				var/dist = GET_DIST(M, location)
				M.apply_flash(60, 0, (3 - dist), 0, ((5 - dist) * 2), (2 - dist))

			for (var/mob/living/silicon/M in all_viewers(world.view, location))
				var/checkdist = GET_DIST(M, location)

				M.apply_flash(30, max(2 * (3 - checkdist), 0), max(2 * (5 - checkdist), 0))
			return

	no_lumen_foam //maybe not as laggy but still laggy
		name = "no lumen foam"
		id = "no_lumen_foam"
		instant = 1
		required_reagents = list("lumen" = 1, "fluorosurfactant" = 1, "water" = 1)
		mix_phrase = "The mixture dissipates in an intense flash of light!"
		hidden = TRUE
		on_reaction(var/datum/reagents/holder, var/created_volume)
			if (holder)
				holder.del_reagent("lumen")
				holder.del_reagent("fluorosurfactant")
				holder.del_reagent("water")
			var/location = get_turf(holder.my_atom)
			playsound(location, 'sound/weapons/flashbang.ogg', 25, TRUE)
			elecflash(location)
			for (var/mob/living/M in all_viewers(5, location))
				if (issilicon(M) || isintangible(M))
					continue

				var/dist = GET_DIST(M, location)
				M.apply_flash(60, 0, (3 - dist), 0, ((5 - dist) * 2), (2 - dist))

			for (var/mob/living/silicon/M in all_viewers(world.view, location))
				var/checkdist = GET_DIST(M, location)

				M.apply_flash(30, max(2 * (3 - checkdist), 0), max(2 * (5 - checkdist), 0))
			return

	no_pyrosium_foam
		name = "no pyrosium foam"
		id = "no_pyrosium_foam"
		instant = 1
		required_reagents = list("pyrosium" = 1, "fluorosurfactant" = 1, "water" = 1)
		mix_phrase = "The mixture burns away into nothing!"
		hidden = TRUE
		on_reaction(var/datum/reagents/holder, var/created_volume)
			if (holder)
				holder.del_reagent("pyrosium")
				holder.del_reagent("fluorosurfactant")
				holder.del_reagent("water")
			return

/*		The smoke reaction now deletes pyrosium (thalmerite) to prevent it from spreading everywhere without blocking delayed smoke reactions - IM

	no_pyrosium_smoke
		name = "no pyrosium smoke"
		id = "no_pyrosium_smoke"
		instant = 1
		required_reagents = list("thalmerite" = 1, "sugar" = 1, "phosphorus" = 1, "potassium" = 1)
		mix_phrase = "The mixture burns away into nothing!"
		on_reaction(var/datum/reagents/holder, var/created_volume)
			if (holder)
				holder.del_reagent("thalmerite")
				holder.del_reagent("sugar")
				holder.del_reagent("phosphorus")
				holder.del_reagent("potassium")
			return

	no_pyrosium_smoke2
		name = "no pyrosium smoke 2"
		id = "no_pyrosium_smoke2"
		instant = 1
		required_reagents = list("thalmerite" = 1, "smokepowder" = 1)
		mix_phrase = "The mixture burns away into nothing!"
		on_reaction(var/datum/reagents/holder, var/created_volume)
			if (holder)
				holder.del_reagent("thalmerite")
				holder.del_reagent("smokepowder")
			return*/

	// also no more fermid foams, fu nerds tOt

	no_fermid_foam
		name = "no fermid foam"
		id = "no_fermid_foam"
		instant = 1
		required_reagents = list("ants" = 1, "mutagen" = 1, "aranesp" = 1, "booster_enzyme" = 1, "fluorosurfactant" = 1, "water" = 1)
		mix_phrase = "A single fermid leg reaches out of the container. It flips you off. Somehow."
		mix_sound = 'sound/musical_instruments/Trombone_Failiure.ogg'
		hidden = TRUE
		on_reaction(var/datum/reagents/holder, var/created_volume)
			if (holder)
				holder.del_reagent("ants")
				holder.del_reagent("mutagen")
				holder.del_reagent("aranesp")
				holder.del_reagent("booster_enzyme")
				holder.del_reagent("fluorosurfactant")
				holder.del_reagent("water")
			return

	booster_enzyme
		name = "Booster Enzyme"
		id = "booster_enzyme"
		result = "booster_enzyme"
		required_reagents = list("diethylamine" = 1, "ethanol" = 1, "sulfur" = 1, "carbon" = 1, "hydrogen" = 1, "oxygen" = 1, "strange_reagent" = 1)
		min_temperature = T0C + 100
		result_amount = 4
		mix_phrase = "The solution shows signs of life, forming shapes!"
		hidden = TRUE

	denatured_enzyme
		name = "Denatured Enzyme"
		id = "denatured_enzyme"
		result = "denatured_enzyme"
		required_reagents = list("booster_enzyme" = 1)
		min_temperature = T0C + 150
		result_amount = 1
		mix_phrase = "The solution burns, leaving behind a lifeless mass!"
		hidden = TRUE

	water_holy
		name = "Holy Water"
		id = "water_holy"
		result = "water_holy"
		required_reagents = list("water" = 1, "mercury" = 1, "wine" = 1)
		result_amount = 3
		mix_phrase = "The water somehow seems purified. Or maybe defiled."

	steam_boiling
		name = "Steam Boiling"
		id = "steam_boiling"
		required_reagents = list("water" = 0) //removed in on_reaction()
		min_temperature = T100C
		mix_phrase = "The solution begins to boil."
		instant = FALSE
		result_amount = 1
		reaction_icon_state = list("reaction_smoke-1", "reaction_smoke-2")
		reaction_icon_color = "#ffffff"

		on_reaction(datum/reagents/holder, created_volume)
			var/amount_to_boil = created_volume * (holder.total_temperature - T100C)/(4 * src.reaction_speed) //for every degree above 100°C, boil .25 extra water per reaction but...
			if(amount_to_boil > holder.get_reagent_amount("water") || (holder.total_temperature > T100C + 100)) //...if there's enough heat to boil all the water or the temp is 100 over 100°C...
				amount_to_boil = holder.get_reagent_amount("water") //...boil away everything.
			holder.remove_reagent("water", amount_to_boil)
			if (holder.my_atom && holder.my_atom.is_open_container() || istype(holder,/datum/reagents/fluid_group))
				var/steam_cloud_chance = (amount_to_boil*2) + 25 //more steam clouds the more you boil per reaction, small amounts if it's slow
				holder.temperature_reagents(holder.total_temperature - (amount_to_boil * 2), change_min = 1) //boiling steam into air removes some heat
				var/list/covered = holder.covered_turf()
				if (covered.len < 5)
					for(var/turf/t in covered)
						if(prob(steam_cloud_chance))
							var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
							smoke.set_up(1, 0, t)
							smoke.start()
			else
				holder.add_reagent("steam", amount_to_boil, temp_new = holder.total_temperature, chemical_reaction = TRUE, chem_reaction_priority = 1)

	steam_condensation
		name = "Steam Condensation"
		id = "steam_condensation"
		result = "water"
		required_reagents = list("steam" = 1)
		max_temperature = T100C
		mix_phrase = "Clear liquid begins to condense in the solution."
		instant = FALSE
		result_amount = 1
		reaction_speed = 10

	steam_open_container //you can't hold it in a beaker without a lid
		name = "Steam Open Container"
		id = "steam_open_container"
		required_reagents = list("steam" = 1)
		mix_phrase = "White gas pours out of the solution."
		hidden = TRUE
		result_amount = 1
		reaction_icon_state = list("reaction_smoke-1", "reaction_smoke-2")
		reaction_icon_color = "#ffffff"

		does_react(var/datum/reagents/holder)
			if (!length(holder.covered_turf())) //don't react until the fluid group is set up
				return FALSE
			return holder.my_atom && holder.my_atom.is_open_container() || istype(holder,/datum/reagents/fluid_group)

		on_reaction(datum/reagents/holder, created_volume)
			var/list/covered = holder.covered_turf()
			if (covered.len < 5)
				for(var/turf/t in covered)
					var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
					smoke.set_up(1, 0, t)
					smoke.start()

	calomel
		name = "Calomel"
		id = "calomel"
		result = "calomel"
		required_reagents = list("mercury" = 1, "chlorine" = 1)
		min_temperature = T0C + 100
		result_amount = 1
		mix_phrase = "Stinging vapors rise from the solution."

	/*tricalomel
		name = "Pentetic Acid"
		id = "tricalomel"
		result = "tricalomel"
		required_reagents = list("ethanol" = 1, "diethylamine" = 1, "ammonia" = 1, "cyanide" = 1)
		result_amount = 3
		mix_phrase = "The mixture bubbles slightly before settling down."*/

	synthflesh
		name = "Synthetic Flesh"
		id = "synthflesh"
		eventual_result = "synthflesh"
		required_reagents = list("blood" = 0, "styptic_powder" = 0) //removed in on_reaction
		result_amount = 1
		instant = FALSE
		reaction_volume_dependant = FALSE
		mix_phrase = "The mixture begins to undulate."
		stateful = TRUE
		var/count = 0

		does_react(var/datum/reagents/holder)
			if(holder.get_reagent_amount("blood") >= 10 && holder.get_reagent_amount("styptic_powder") >= 20)
				return TRUE
			else
				return FALSE

		on_reaction(var/datum/reagents/holder, var/created_volume)

			if(count < 15) //the delayed count is to give people time to pour in all the reagents they want to use
				count += 1
			else
				if(holder.get_reagent_amount("styptic_powder") < 40 || holder.get_reagent_amount("carbon") >= 10) //you can use carbon to force the reaction to make a bunch of tiny pustules if you want
					var/obj/item/reagent_containers/synthflesh_pustule/small/pustule = new /obj/item/reagent_containers/synthflesh_pustule/small
					pustule.set_loc(get_turf(holder.my_atom))
					holder.remove_reagent("carbon", 10)
					holder.remove_reagent("styptic_powder", 20)
					holder.remove_reagent("blood", 10)

				else if(holder.get_reagent_amount("styptic_powder") < 80)
					var/obj/item/reagent_containers/synthflesh_pustule/pustule = new /obj/item/reagent_containers/synthflesh_pustule/
					pustule.set_loc(get_turf(holder.my_atom))
					var/extra_blood_in_pustule = holder.get_reagent_amount("styptic_powder") + holder.get_reagent_amount("blood") - 40 //add excess blood/styptic to the pustule as blood
					pustule.reagents.add_reagent("blood", extra_blood_in_pustule)
					holder.remove_reagent("styptic_powder", holder.get_reagent_amount("styptic_powder"))
					holder.remove_reagent("blood", holder.get_reagent_amount("blood"))

				else
					var/obj/item/reagent_containers/synthflesh_pustule/large/pustule = new /obj/item/reagent_containers/synthflesh_pustule/large
					pustule.set_loc(get_turf(holder.my_atom))
					var/extra_blood_in_pustule = holder.get_reagent_amount("styptic_powder") + holder.get_reagent_amount("blood") - 80
					pustule.reagents.add_reagent("blood", extra_blood_in_pustule)
					holder.remove_reagent("styptic_powder", holder.get_reagent_amount("styptic_powder"))
					holder.remove_reagent("blood", holder.get_reagent_amount("blood"))
				playsound(get_turf(holder.my_atom), 'sound/impact_sounds/Slimy_Hit_4.ogg', 25, 1)

	meat_slurry
		name = "Meat Slurry"
		id = "meat_slurry"
		result = "meat_slurry"
		required_reagents = list("blood" = 1, "cornstarch" = 1)
		result_amount = 2
		mix_phrase = "The mixture congeals into a bloody mass."
		mix_sound = 'sound/impact_sounds/Slimy_Hit_4.ogg'

	beff
		name = "Beff"
		id = "beff"
		result = "beff"
		required_reagents = list("meat_slurry" = 1, "badgrease" = 2, "plasma" = 1)
		result_amount = 4
		mix_phrase = "The mixture solidifies, taking a crystalline appearance."
		mix_sound = 'sound/impact_sounds/Slimy_Hit_4.ogg'

	enriched_msg
		name = "Enriched MSG"
		id = "enriched_msg"
		result = "enriched_msg"
		required_reagents = list("msg" = 1, "milk" = 1, "salt" = 1, "chickensoup" = 1, "sugar" = 1,\
		"cheese" = 1,/* "anima" = 1, */"grease" = 1, "water_holy" = 1, "pepperoni" = 1, "beff" = 1,\
		"juice_tomato" = 1, "ectocooler" = 1)
		//min_temperature = T0C + 400 // commenting out for now so you can actually make this, maybe
		result_amount = 12
		mix_phrase = "The mixture reduces into a fine crystalline powder and an unbelievably delicious smell wafts upwards."
		hidden = TRUE

/*		argine
		name = "Argine"
		id = "argine"
		result = "argine"
		max_temperature = 25
		required_reagents = list("ethanol" = 1, "silicon" = 1, "water" = 1)
		result_amount = 3 */

	infernite
		name = "Chlorine Triflouride"
		id = "infernite"
		result = "infernite"
		min_temperature = T0C + 150
		required_reagents = list("chlorine" = 1, "fluorine" = 3)
		result_amount = 2
		mix_phrase = "The mixture gives off significant heat."

		on_reaction(var/datum/reagents/holder, var/created_volume)
			var/turf/location = 0
			if (holder?.my_atom)
				location = get_turf(holder.my_atom)
				fireflash(location, 1, 7000, chemfire = CHEM_FIRE_RED)
			else
				var/amt = max(1, (holder.covered_cache.len * (created_volume / holder.covered_cache_volume)))
				for (var/i = 0, i < amt && holder.covered_cache.len, i++)
					location = pick(holder.covered_cache)
					holder.covered_cache -= location
					fireflash(location, 1/amt, 7000/amt, chemfire = CHEM_FIRE_RED)

			return

	/*foof
		name = "FOOF"
		id = "foof"
		result = "foof"
		min_temperature = 600
		required_reagents = list("oxygen" = 1, "flourine" = 1, "stabiliser" = 1)
		result_amount = 1
		mix_phrase = "The mixture violently erupts and seethes with fire."

		on_reaction(var/datum/reagents/holder, var/created_volume)
			fireflash(holder.my_atom, 3)
			return*/


	pyrosium
		name = "Pyrosium"
		id = "pyrosium"
		result = "pyrosium"
		required_reagents = list("plasma" = 1, "radium" = 1, "phosphorus" = 1)
		result_amount = 3
		mix_phrase = "The resultant gel begins to emit significant heat."


	aranesp
		name = "Aranesp"
		id = "aranesp"
		result = "aranesp"
		required_reagents = list("nickel" = 0, "cryoxadone" = 1, "insulin" = 1)
		result_amount = 2
		instant = 0
		reaction_speed = 0.25
		max_temperature = T0C
		reaction_icon_state = list("reaction_puff-1", "reaction_puff-2")
		mix_phrase = "The solution emits a fine mist as it slowly begins to change colour."

		on_reaction(var/datum/reagents/holder, var/created_volume)
			//It calculates as if created_volume of the liquid with a 50K higher temperature was added.
			holder.temperature_reagents(max(holder.total_temperature + 50, 1), exposed_volume = created_volume*100, exposed_heat_capacity = holder.composite_heat_capacity, change_min = 1)

	aranesp_goes_tar
		name = "Aranesp_goes_tar"
		id = "aranesp_goes_tar"
		result = "gvomit"
		required_reagents = list("nickel" = 0, "cryoxadone" = 1, "insulin" = 1)
		result_amount = 1
		min_temperature = T0C
		mix_phrase = "The solution coagulates into a nasty green-blackish tar."
		mix_sound = 'sound/impact_sounds/Slimy_Hit_4.ogg'

		on_reaction(var/datum/reagents/holder, var/created_volume)
			holder.add_reagent("carbon", created_volume,,holder.total_temperature, chemical_reaction = TRUE, chem_reaction_priority = 2)

	soriumstable
		name = "Stable Sorium"
		id = "soriumstable"
		result = "sorium"
		required_reagents = list("mercury" = 1, "carbon" = 1, "nitrogen" = 1,"oxygen" = 1, "stabiliser" = 1)
		result_amount = 4
		mix_phrase = "The mixture pops and crackles before settling down."

	ldmatterstable
		name = "Stable Liquid Dark Matter"
		id = "ldmatterstable"
		result = "ldmatter"
		required_reagents = list("plasma" = 1, "radium" = 1, "carbon" = 1, "stabiliser" = 1)
		result_amount = 4
		mix_phrase = "The mix begins to glow a dim purple."

	sorium
		name = "Sorium"
		id = "sorium"
		required_reagents = list("mercury" = 1, "carbon" = 1, "nitrogen" = 1,"oxygen" = 1)
		inhibitors = list("stabiliser")
		instant = 1
		mix_phrase = "The mixture explodes with a big bang."
		hidden = TRUE
		on_reaction(var/datum/reagents/holder, var/created_volume)
			sorium_reaction(holder, created_volume, id)
			return

	ldmatter
		name = "Liquid Dark Matter"
		id = "ldmatter"
		required_reagents = list("plasma" = 1, "radium" = 1, "carbon" = 1)
		inhibitors = list("stabiliser")
		instant = 1
		mix_phrase = "The mixture implodes suddenly."
		hidden = TRUE
#ifdef CHEM_REACTION_PRIORITIES
		priority = 20
#endif
		on_reaction(var/datum/reagents/holder, var/created_volume)
			ldmatter_reaction(holder, created_volume)
			return

	smelling_salts
		name = "Ammonium Bicarbonate"
		id = "ammoniumbicarbonate"
		required_reagents = list("ammonia" = 1, "carbon" = 1, "oxygen" = 1)
		result = "smelling_salt"
		min_temperature = T0C + 100
		instant = 1
		result_amount = 3
		mix_phrase = "The mixture produces an aromatic fume."

/*
	merculite
		name = "Merculite"
		id = "merculite"
		result = "laffo"
		min_temperature = 303
		required_reagents = list("phlogiston" = 1, "thermite" = 1, "fuel" = 1)
		result_amount = 1 */

	fishoil_pyrolysis
		name = "fish oil pyrolysis"
		id = "fishoil_pyrolysis"
		result = "potash"
		required_reagents = list("fishoil" = 1)
		min_temperature = T0C + 150
		result_amount = 0.2
		instant = 0
		reaction_speed = 0.4
		mix_phrase = "The oil starts to bubble and turn into a black tar."

		on_reaction(var/datum/reagents/holder, var/created_volume)
			if(holder?.my_atom?.is_open_container())
				//there goes your precious oil
				reaction_icon_state = list("reaction_fire-1", "reaction_fire-2")
				holder.add_reagent("ash", 0.8 * created_volume * 5,,holder.total_temperature, chemical_reaction = TRUE, chem_reaction_priority = 2)
			else
				reaction_icon_state = list("reaction_bubble-1", "reaction_bubble-2")
				//the reaction creates 0,8u of oil for 1u of fish oil at 165°C, linarly declining in the area of 150°C to 180°C down to 0,2u
				var/amount_of_oil_produced = round(0.2 + 0.6 * max(0, 1 - (abs(holder.total_temperature - (T0C + 165)) / 15)), 0.01)
				holder.add_reagent("oil", amount_of_oil_produced * created_volume * 5,,holder.total_temperature, chemical_reaction = TRUE, chem_reaction_priority = 2)
				if(amount_of_oil_produced < 0.8)
					// the rest chars into ash
					holder.add_reagent("ash", (0.8 - amount_of_oil_produced) * created_volume * 5,,holder.total_temperature, chemical_reaction = TRUE, chem_reaction_priority = 3)



	ash
		name = "Ash"
		id = "ash"
		result = "ash"
		required_reagents = list("paper" = 1)
		min_temperature = T0C + 150
		result_amount = 1
		mix_phrase = "The paper chars, seperating into a silky black powder."

	milk
		name = "Milk"
		id = "milk"
		result = "milk"
		required_reagents = list("milk_powder" = 1, "water" = 1)
		result_amount = 1
		max_temperature = T0C + 100
		mix_phrase = "The powder dissolves, turning the solution milky."

	powder_milk
		name = "Milk powder"
		id = "milk_powder"
		result = "milk_powder"
		required_reagents = list("milk" = 1)
		inhibitors = list("water")
		result_amount = 1
		min_temperature = T0C + 100
		mix_phrase = "The water boils away, leaving behind a white condensed powder."
		on_reaction(datum/reagents/holder, created_volume)
			. = ..()
			var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
			smoke.set_up(1, 0, get_turf(src))
			smoke.start()

	super_milk
		name = "Super Milk"
		id = "super_milk"
		result = "super_milk"
		required_reagents = list("milk" = 1, "milk_powder" = 1)
		result_amount = 1
		mix_phrase = "The mixture concentrates."

	bilk
		name = "Bilk"
		id = "bilk"
		result = "bilk"
		required_reagents = list("milk" = 1, "beer" = 1)
		result_amount = 2
		mix_phrase = "The mixture turns an offensive brown colour and begins fizzing."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	chocolate_milk
		name = "Chocolate Milk"
		id = "chocolate milk"
		result = "chocolate_milk"
		required_reagents = list("milk" = 1, "chocolate" = 1)
		result_amount = 2
		mix_phrase = "The mixture turns a nice brown color."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	strawberry_milk
		name = "Strawberry Milk"
		id = "strawberry milk"
		result = "strawberry_milk"
		required_reagents = list("milk" = 1, "juice_strawberry" = 1)
		result_amount = 2
		mix_phrase = "The mixture turns a nice pink color."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	banana_milk
		name = "Banana Milk"
		id = "banana milk"
		result = "banana_milk"
		required_reagents = list("milk" = 1, "juice_banana" = 1)
		result_amount = 2
		mix_phrase = "The mixture turns a nice light yellow color."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	blue_milk
		name = "Blue Milk"
		id = "blue milk"
		result = "blue_milk"
		required_reagents = list("milk" = 1, "juice_blueberry" = 1)
		result_amount = 2
		mix_phrase = "The mixture turns a pale blue color."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	milk_punch
		name = "Milk Punch"
		id = "milk_punch"
		result = "milk_punch"
		required_reagents = list("simplesyrup" = 1, "juice_lime" = 1, "juice_apple" = 1, "ginger_ale" = 1, "juice_pineapple" = 1, "milk" = 1)
		result_amount = 6
		mix_phrase = "You wonder why you made this drink at all."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	milk_punch/milk_punch2
		id = "milk_punch2"
		required_reagents = list("fruit_punch" = 5, "milk" = 1)
		result_amount = 6

	fruit_punch
		name = "Fruit Punch"
		id = "fruit punch"
		result = "fruit_punch"
		required_reagents = list("simplesyrup" = 1, "juice_apple" = 1, "juice_lime" = 1, "ginger_ale" = 1, "juice_pineapple" = 1)
		result_amount = 5
		mix_phrase = "You are reminded of family picnics and school functions as the syrup mixes with the juices."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	fizzy_banana
		name = "Fizzy Banana"
		id = "fizzy_banana"
		result = "fizzy_banana"
		required_reagents = list("simplesyrup" = 1, "juice_banana" = 1, "coconut_milk" = 1, "juice_lime" = 1, "tonic" = 1)
		result_amount = 5
		mix_phrase = "You think of tropical beaches and blue oceans as the syrup mixes with the juices."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	lipolicide // COGWERKS REPLACEMENT NOTES: FEN-PHEN? EPHEDRINE?
		name = "Lipolicide"
		id = "lipolicide"
		result = "lipolicide"
		required_reagents = list("ephedrine"=1,"diethylamine"=1,"mercury"=1)
		result_amount = 2
		mix_phrase = "A vague smell similar to tofu rises from the mixture."

	cheese
		name = "Cheese"
		id = "cheese"
		result = "cheese"
		required_reagents = list("milk" = 1, "vomit" = 1)
		result_amount = 1
		mix_phrase = "The mixture curdles up."
		on_reaction(var/datum/reagents/holder)
			var/location = get_turf(holder.my_atom)
			for(var/mob/M in all_viewers(8, location))
				boutput(M, SPAN_NOTICE("A faint cheesy smell drifts through the air..."))
			return

	cheese2
		name = "Cheese"
		id = "cheese2"
		result = "cheese"
		required_reagents = list("milk" = 1, "acetic_acid" = 0)
		result_amount = 1
		mix_phrase = "The mixture curdles up."
		on_reaction(var/datum/reagents/holder)
			var/location = get_turf(holder.my_atom)
			for(var/mob/M in all_viewers(8, location))
				boutput(M, SPAN_NOTICE("A faint cheesy smell drifts through the air..."))
			return

	gcheese
		name = "Weird Cheese"
		id = "gcheese"
		result = "gcheese"
		required_reagents = list("milk" = 1, "gvomit" = 1)
		result_amount = 1
		mix_phrase = "The disgusting mixture sloughs together horribly, emitting a foul stench."
		mix_sound = 'sound/voice/farts/diarrhea.ogg'
		on_reaction(var/datum/reagents/holder)
			var/location = get_turf(holder.my_atom)
			for(var/mob/M in all_viewers(8, location))
				boutput(M, SPAN_ALERT("A horrible smell assaults your nose! What in space is it?"))
			return

	yoghurt
		name = "Yoghurt"
		id = "yoghurt"
		result = "yoghurt"
		required_reagents = list("milk" = 1, "yuck" = 1)
		result_amount = 2
		mix_phrase = "The mixture curdles up slightly."
		mix_sound = 'sound/effects/splort.ogg'

	lemonade
		name = "Lemonade"
		id = "lemonade"
		result = "lemonade"
		required_reagents = list("juice_lemon" = 3, "sugar" = 1)
		result_amount = 4
		mix_phrase = "The sugar dissolves into the lemon juice."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	limeade
		name = "Limeade"
		id = "limeade"
		result = "limeade"
		required_reagents = list("juice_lime" = 3, "sugar" = 1)
		result_amount = 4
		mix_phrase = "The sugar dissolves into the lime juice."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	halfandhalf
		name = "Half and Half"
		id = "halfandhalf"
		result = "halfandhalf"
		required_reagents = list("lemonade" = 1, "tea" = 1)
		result_amount = 2
		mix_phrase = "The tea and lemonade combine without much fuss."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	halfandhalf/halfandhalf2
		id = "halfandhalf2"
		required_reagents = list("juice_lemon" = 1, "sweet_tea" = 1)
		result_amount = 2

	halfandhalf/halfandhalf3
		id = "halfandhalf3"
		required_reagents = list("lemonade" = 1, "sweet_tea" = 1)
		result_amount = 2

	laurapalmer
		name = "Laura Palmer"
		id = "laurapalmer"
		result = "laurapalmer"
		required_reagents = list("lemonade" = 1, "coffee" = 1)
		result_amount = 2
		mix_phrase = "The coffee and lemonade mix together. Damn fine."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	laurapalmer/fresh
		id = "laurapalmer_fresh"
		required_reagents = list("lemonade" = 1, "coffee_fresh" = 1)

	eggnog
		name = "Eggnog"
		id = "eggnog"
		result = "eggnog"
		required_reagents = list("egg" = 1, "milk" = 1, "sugar" = 1)
		result_amount = 3
		mix_phrase = "The eggs nog together. Pretend that \"nog\" is a verb."
		drinkrecipe = TRUE

	honey_tea
		name = "honey tea"
		id = "honey_tea"
		result = "honey_tea"
		required_reagents = list("honey" = 1, "tea" = 1)
		result_amount = 2
		mix_phrase = "The tea somehow smells even nicer than before."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	mint_tea
		name = "mint tea"
		id = "mint_tea"
		result = "mint_tea"
		required_reagents = list("mint" = 1, "tea" = 1)
		result_amount = 2
		mix_phrase = "The tea somehow smells even more refreshing than before."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	sun_tea
		name = "sun tea"
		id = "sun_tea"
		result = "sun_tea"
		required_reagents = list("tea" = 3, "juice_orange" = 1, "sugar" = 1)
		result_amount = 5
		mix_phrase = "The tea takes on a sweet, summery smell."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	sweet_tea
		name = "Sweet Tea"
		id = "sweet_tea"
		result = "sweet_tea"
		required_reagents = list("sugar" = 1, "tea" = 1)
		inhibitors = list("juice_orange" = 1)
		result_amount = 2
		mix_phrase = "The tea sweetens. Visually. Somehow."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	kombucha
		name = "Kombucha"
		id = "kombucha"
		result = "kombucha"
		required_reagents = list("sweet_tea" = 3, "beer" = 1, "antihol" = 1)
		result_amount = 3
		mix_phrase = "The tea fizzes lightly, giving off a soft vinegar scent."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE
		min_temperature = T0C + 16
		max_temperature = T0C + 29
		instant = FALSE
		reaction_speed = 0.333 // about 100u after 5 minutes

	catamount
		name = "catamount"
		id = "catamount"
		result = "catamount"
		required_reagents = list("juice_orange" = 1, "grenadine" = 1, "ginger_ale" = 4, "ice" = 2)
		result_amount = 8
		mix_sound = 'sound/voice/animal/cat.ogg'
		drinkrecipe = TRUE

	pine_ginger
		name = "pine-ginger"
		id = "pine_ginger"
		result = "pine_ginger"
		required_reagents = list("juice_pineapple" = 2, "ice" = 1, "ginger_ale" = 1)
		result_amount = 4
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	sail_boat
		name = "sail boat"
		id = "sail_boat"
		result = "sail_boat"
		required_reagents = list("juice_lime" = 1, "ginger_ale" = 4, "ice" = 1)
		result_amount = 6
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	shirley_temple
		name = "shirley temple"
		id = "shirley_temple"
		result = "shirley_temple"
		required_reagents = list("juice_lime" = 1, "juice_lemon" = 1, "ginger_ale" = 1, "grenadine" = 1)
		result_amount = 4
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	vermont_breeze
		name = "vermont breeze"
		id = "vermont_breeze"
		result = "vermont_breeze"
		required_reagents = list("lemonade" = 4, "grenadine" = 1, "tonic" = 1)
		result_amount = 6
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	cafe_gele
		name = "cafe gele"
		id = "cafe_gele"
		result = "cafe_gele"
		required_reagents = list("coffee" = 6, "vanilla" = 1, "sugar" = 1)
		result_amount = 8
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	cafe_gele/fresh
		id = "cafe_gele_fresh"
		required_reagents = list("coffee_fresh" = 6, "vanilla" = 1, "sugar" = 1)

	sodawater
		name = "soda water"
		id = "sodawater"
		result = "sodawater"
		required_reagents = list("carbon" = 1, "oxygen" = 1, "water" = 1)
		result_amount = 2
		mix_phrase = "The water becomes soda water, club soda, sparkling water, mineral water, or possibly seltzer."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	simplesyrup
		name = "simple syrup"
		id = "simplesyrup"
		result = "simplesyrup"
		required_reagents = list("sugar" = 1, "water" = 1)
		min_temperature = T0C + 80
		result_amount = 2
		mix_phrase = "The sugar and water congeal in the heat into a gloopy syrup."
		mix_sound = 'sound/impact_sounds/slimy_hit_3.ogg'
		drinkrecipe = TRUE

	cocktail_wellerman
		name = "Wellerman"
		id = "wellerman"
		result = "wellerman"
		required_reagents = list("sweet_tea" = 2, "rum" = 1)
		result_amount = 3
		mix_phrase = "Soon may the Wellerman come. To bring us sugar and tea and rum."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	cocktail_hardpunch
		name = "Hard Punch"
		id = "hard_punch"
		result = "hard_punch"
		required_reagents = list("simplesyrup" = 1, "sangria" = 1, "juice_apple" = 1, "ginger_ale" = 1, "juice_pineapple" = 1)
		result_amount = 5
		mix_phrase = "This drink is so disgustingly sweet you start to get a headache from smelling it."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	cocktail_kalimotxo
		name = "Kalimotxo"
		id = "kalimotxo"
		result = "kalimotxo"
		required_reagents = list("cola" = 1, "wine" = 1)
		result_amount = 2
		mix_phrase = "The drink mixes together in an oddly Basque way."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	cocktail_derby
		name = "Derby"
		id = "derby"
		result = "derby"
		required_reagents = list("gin" = 1, "bitters" = 1, "mint" = 1)
		result_amount = 3
		mix_phrase = "The drink becomes kind of generically named."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	cocktail_horsesneck
		name = "Horse's Neck"
		id = "horsesneck"
		result = "horsesneck"
		required_reagents = list("bourbon" = 1, "bitters" = 1, "ginger_ale" = 1)
		result_amount = 3
		mix_phrase = "The drink horses around."
		mix_sound = 'sound/voice/horse.ogg'
		drinkrecipe = TRUE

	cocktail_rose
		name = "Rose"
		id = "rose"
		result = "rose"
		required_reagents = list("vermouth" = 1, "juice_cherry" = 1, "juice_strawberry" = 1)
		result_amount = 3
		mix_phrase = "A rose by any other name would probably have a lower alcohol content."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	cocktail_seabreeze
		name = "Sea Breeze"
		id = "seabreeze"
		result = "seabreeze"
		required_reagents = list("vodka" = 1, "juice_cran" = 1, "juice_grapefruit" = 1)
		result_amount = 3
		mix_phrase = "The drink reminds you of the Oshan breeze."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	cocktail_brassmonkey
		name = "Brass Monkey"
		id = "brassmonkey"
		result = "brassmonkey"
		required_reagents = list("rum" = 1, "vodka" = 1, "juice_orange" = 1)
		result_amount = 3
		mix_phrase = "The drink screeches!"
		mix_sound = 'sound/voice/screams/monkey_scream.ogg'
		drinkrecipe = TRUE

	cocktail_hotbutteredrum
		name = "Hot Buttered Rum"
		id = "hotbutteredrum"
		result = "hotbutteredrum"
		required_reagents = list("rum" = 1, "cider" = 1, "butter" = 1)
		result_amount = 3
		mix_phrase = "The drink becomes highly indulgent."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	cocktail_fluffycritter
		name = "Fluffy Critter"
		id = "fluffycritter"
		result = "fluffycritter"
		required_reagents = list("rum" = 1, "juice_lime" = 1, "lemonade" = 1, "juice_strawberry" = 1)
		result_amount = 4
		mix_phrase = "The drink coos. Aww."
		mix_sound = 'sound/voice/babynoise.ogg'
		drinkrecipe = TRUE

	cocktail_michelada
		name = "Michelada"
		id = "michelada"
		result = "michelada"
		required_reagents = list("beer" = 1, "juice_tomato" = 1, "capsaicin" = 1)
		result_amount = 3
		mix_phrase = "A tiny mariachi pops out of the container and doots at you before disappearing into the drink."
		mix_sound = 'sound/musical_instruments/Bikehorn_2.ogg'
		drinkrecipe = TRUE

	cocktail_gunfire
		name = "Gunfire"
		id = "gunfire"
		result = "gunfire"
		required_reagents = list("tea" = 1, "rum" = 1)
		result_amount = 2
		mix_phrase = "The drink makes an unconvincing gunshot noise."
		mix_sound = 'sound/vox/shoot.ogg'
		drinkrecipe = TRUE

	cocktail_espressomartini
		name = "Espresso Martini"
		id = "espressomartini"
		result = "espressomartini"
		required_reagents = list("vodka" = 1, "chocolate" = 1, "sugar" = 1, "espresso" = 1)
		result_amount = 4
		mix_phrase = "James Bond would use his License To Kill."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	cocktail_nicotini
		name = "Nicotini"
		id = "nicotini"
		result = "nicotini"
		required_reagents = list("martini" = 1, "nicotine" = 1)
		result_amount = 2
		mix_phrase = "The drink fizzes and turns a bland violet color. James Bond is crying."

	cocktail_radler
		name = "Radler"
		id = "radler"
		result = "radler"
		required_reagents = list("beer" = 1, "lemonade" = 1)
		result_amount = 2
		mix_phrase = "The combination of the beer and lemonade makes you want to go cycling, for some reason."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	cocktail_threemileislandicedtea
		name = "Three Mile Island Iced Tea"
		id = "threemileislandicedtea"
		result = "threemileislandicedtea"
		required_reagents = list("vodka" = 1, "gin" = 1, "tequila" = 1, "cola" = 1, "curacao" = 1)
		result_amount = 5
		mix_phrase = "You swear you hear the sound of a nuclear bomb being pushed through an airlock."
		mix_sound = 'sound/machines/decompress.ogg'
		drinkrecipe = TRUE

	cocktail_citrus
		name = "Triple Citrus"
		id = "cocktail_citrus"
		result = "cocktail_citrus"
		required_reagents = list("juice_orange" = 1, "juice_lemon" = 1, "juice_lime" = 1)
		result_amount = 3
		mix_phrase = "The citrus juices begin to blend together."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	cocktail_triple
		name = "Triple Triple"
		id = "cocktail_triple"
		result = "cocktail_triple"
		required_reagents = list("cocktail_citrus" = 1, "triplemeth" = 1, "triplepissed" = 1)
		result_amount = 1 //this is pretty much a hellpoison.
		mix_phrase = "The mixture can't seem to control itself and settle down!"
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE
		hidden = TRUE

	cocktail_beach
		name = "Bliss on the Beach"
		id = "beach"
		result = "beach"
		required_reagents = list("vodka" = 1, "juice_cran" = 1, "juice_orange" = 1)
		result_amount = 3
		mix_phrase = "You die a little inside after making that."
		mix_sound = 'sound/voice/farts/poo2.ogg'

	cocktail_beach/beach2
		id = "beach2"
		required_reagents = list("screwdriver" = 2, "juice_cran" = 1)
		result_amount = 2

	cocktail_screwdriver
		name = "Screwdriver"
		id = "screwdriver"
		result = "screwdriver"
		required_reagents = list("vodka" = 1, "juice_orange" = 1)
		result_amount = 2
		mix_phrase = "The vodka and orange juice mix together nicely."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	cocktail_bloodymary
		name = "Bloody Mary"
		id = "bloody_mary"
		result = "bloody_mary"
		required_reagents = list("vodka" = 1, "juice_tomato" = 1)
		result_amount = 2
		mix_phrase = "The vodka and tomato juice mix together nicely."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	cocktail_bloodyscary
		name = "Bloody Scary"
		id = "bloody_scary"
		result = "bloody_scary"
		required_reagents = list("vodka" = 1, "bloodc" = 1)
		result_amount = 2
		mix_phrase = "The blood feverishly tries to escape the burn of the vodka, but eventually succumbs."
		mix_sound = 'sound/impact_sounds/Flesh_Break_1.ogg'
		drinkrecipe = TRUE

	cocktail_snakebite
		name = "Snakebite"
		id = "snakebite"
		result = "snakebite"
		required_reagents = list("cider" = 1, "beer" = 1)
		result_amount = 2
		mix_phrase = "The beer and cider mix into an appetizing drink."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	cocktail_caipirinha
		name = "Pineapple Caipirinha"
		id = "caipirinha"
		result = "caipirinha"
		required_reagents = list("vodka" = 2, "sugar" = 1,"ice" = 1, "juice_pineapple" = 2)
		result_amount = 5
		mix_phrase = "The vodka and pineapple juice mix together into a yellowish drink."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	cocktail_piscosour
		name = "Pisco Sour"
		id = "piscosour"
		result = "piscosour"
		required_reagents = list("egg" = 1, "simplesyrup" = 1, "bitters"= 1, "juice_lime" = 1, "white_wine" = 1)
		result_amount = 5
		mix_phrase = "The egg white foams and floats atop the lime-colored drink."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	cocktail_diesel
		name = "Diesel"
		id = "diesel"
		result = "diesel"
		required_reagents = list("snakebite" = 1, "juice_cran" = 1)
		result_amount = 2
		mix_phrase = "The addition of the juice makes the drink even more appetizing and somehow even stronger."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	cocktail_suicider
		name = "Suicider"
		id = "suicider"
		result = "suicider"
		required_reagents = list("cider" = 1, "vodka" = 1, "epinephrine" = 1, "fuel" = 1)
		result_amount = 4
		mix_phrase = "The drinks and chemicals mix together, emitting a potent smell."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	cocktail_boorbon
		name = "BOOrbon"
		id = "boorbon"
		result = "boorbon"
		required_reagents = list("bourbon" = 1, "ectoplasm" = 1)
		result_amount = 2
		mix_phrase = "The bourbon and ectoplasm mix together, forming a HORRIFYING BLEND."
		mix_sound = 'sound/effects/ghostlaugh.ogg'
		drinkrecipe = TRUE

	cocktail_grog
		name = "Grog"
		id = "grog"
		result = "grog"
		required_reagents = list("fuel" = 1, "teporone" = 1, "sugar" = 1, "acid" = 1, "rum" = 1, "acetone" = 1, "bloody_scary" = 1, "gvomit" = 1, "lube" = 1, "pacid" = 1, "pepperoni" = 1)
		//Replaced cleaner (propylene glycol) with teporone (antifreeze) and juice_tomato with bloody_scary for red dye.
		result_amount = 10
		mix_phrase = "The substance mixes together, emitting a rank piratey odor and seemingly dissolving some of the container..."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE
		hidden = TRUE

	cocktail_beepskybeer
		name = "Beepskybräu Security Schwarzbier"
		id = "beepskybeer"
		result = "beepskybeer"
		required_reagents = list("beer" = 1, "nanites" = 1)
		result_amount = 2
		mix_phrase = "The beer is filled briefly by thousands of brilliant, tiny electrical arcs before growing calm and dark."
		mix_sound = 'sound/effects/sparks6.ogg'
		drinkrecipe = TRUE

	cocktail_whiskey_sour
		name = "Whiskey Sour"
		id = "whiskey_sour"
		result = "whiskey_sour"
		required_reagents = list("bourbon" = 1, "juice_lemon" = 1, "sugar" = 1)
		result_amount = 3
		mix_phrase = "The alcohol burn sneakily disguises itself in the sweet and sour mix."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_whiskey_sour/whiskey_sour2
		id = "whiskey_sour2"
		required_reagents = list("bourbon" = 1, "lemonade" = 2)
		result_amount = 2

	cocktail_daiquiri
		name = "Daiquiri"
		id = "daiquiri"
		result = "daiquiri"
		required_reagents = list("rum" = 1, "juice_lime" = 1, "sugar" = 1)
		result_amount = 3
		mix_phrase = "The rum pairs nicely with the sugar and lime."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_daiquiri/daiquiri2
		id = "daiquiri2"
		required_reagents = list("rum" = 1, "limeade" = 2)
		result_amount = 2

	cocktail_martini
		name = "Martini"
		id = "martini"
		result = "martini"
		required_reagents = list("gin" = 1, "vermouth" = 1)
		result_amount = 2
		mix_phrase = "James Bond would be proud."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_v_martini
		name = "Vodka Martini"
		id = "v_martini"
		result = "v_martini"
		required_reagents = list("vodka" = 1, "vermouth" = 1)
		result_amount = 2
		mix_phrase = "James Bond would be ashamed."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_appletini
		name = "Appletini"
		id = "appletini"
		result = "appletini"
		required_reagents = list("vodka" = 1, "cider" = 1, "juice_apple" = 1)
		result_amount = 3
		mix_phrase = "James Bond probably wouldn't know what this is."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_murdini
		name = "Murdini"
		id = "murdini"
		result = "murdini"
		required_reagents = list("martini" = 1, "juice_apple" = 1, "suicider" = 1)
		result_amount = 3
		mix_phrase = "The drink fizzes and smells strongly of apples and ethanol."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_mutini
		name = "Mutini"
		id = "mutini"
		result = "mutini"
		required_reagents = list("martini" = 1, "mutagen" = 4, "mutadone" = 1, "neurotoxin" = 1, "mannitol" = 1)
		result_amount = 4
		mix_phrase = "The martini gains a soft green glow."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		hidden = TRUE

	cocktail_manhattan
		name = "Manhattan"
		id = "manhattan"
		result = "manhattan"
		required_reagents = list("bourbon" = 1, "vermouth" = 1, "bitters" = 1)
		result_amount = 3
		mix_phrase = "The unmistakable smell of a power lunch wafts from the container."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	rum_and_cola
		name = "Rum and Cola"
		id = "rcola"
		result = "rcola"
		required_reagents = list("rum" = 1, "cola" = 1)
		result_amount = 2
		mix_phrase = "A sweet and bitter aroma fills the air."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_libre
		name = "Space-Cuba Libre"
		id = "libre"
		result = "libre"
		required_reagents = list("rcola" = 2, "juice_lime" = 1)
		result_amount = 3
		mix_phrase = "You shed a single patriotic tear as the drink comes together."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_ginfizz
		name = "Gin Fizz"
		id = "ginfizz"
		result = "ginfizz"
		required_reagents = list("gin" = 1, "juice_lemon" = 1, "tonic" = 1)
		result_amount = 3
		mix_phrase = "The mixed drink starts fizzing. Somehow."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_gimlet
		name = "Gimlet"
		id = "gimlet"
		result = "gimlet"
		required_reagents = list("gin" = 1, "juice_lime" = 1)
		result_amount = 2
		mix_phrase = "The gin attempts to hide its pine cone flavor in the lime juice."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_cosmo
		name = "Cosmopolitan"
		id = "cosmo"
		result = "cosmo"
		required_reagents = list("vodka" = 1, "juice_cran" = 1, "juice_lime" = 1)
		result_amount = 3
		mix_phrase = "The drink turns a bright pink."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_cosmo/cosmo2
		id = "cosmo2"
		required_reagents = list("v_gimlet" = 2, "juice_cran" = 1)
		result_amount = 3

	cocktail_blackbramble
		name = "Blackberry Bramble"
		id = "blackbramble"
		result = "blackbramble"
		required_reagents = list("gin" = 1, "juice_blackberry" = 1, "juice_lemon" = 1)
		result_amount = 3
		mix_phrase = "The blackberries turn almost purple as you muddle them into the gin and lemon."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_frenchmartini
		name = "French Martini"
		id = "frenchmartini"
		result = "frenchmartini"
		required_reagents = list("vodka" = 1, "juice_raspberry" = 1, "juice_pineapple" = 1)
		result_amount = 3
		mix_phrase = "Mon dieu, zis isn't even a martini."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_jazzberryhardlemonade
		name = "Jazzberry Hard Lemonade"
		id = "jazzlemon"
		result = "jazzlemon"
		required_reagents = list("lemonade" = 1, "juice_blueraspberry" = 1, "vodka" = 1)
		result_amount = 3
		mix_phrase = "The drink turns radically jazzalicious."
		mix_sound = 'sound/musical_instruments/saxbonk3.ogg'

	cocktail_v_gimlet
		name = "Vodka Gimlet"
		id = "v_gimlet"
		result = "v_gimlet"
		required_reagents = list("vodka" = 1, "juice_lime" = 1)
		result_amount = 2
		mix_phrase = "The drink comes together and swiftly infuriates cocktail nerds."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_b_russian
		name = "Black Russian"
		id = "b_russian"
		result = "b_russian"
		required_reagents = list("vodka" = 1, "coffee" = 1)
		result_amount = 2
		mix_phrase = "The drink turns a deep brown as the coffee settles in."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_b_russian/fresh
		id = "b_russian_fresh"
		required_reagents = list("vodka" = 1, "coffee_fresh" = 1)

	cocktail_b_russian/espresso
		id = "b_russian_espresso"
		required_reagents = list("vodka" = 1, "espresso" = 1)

	cocktail_w_russian
		name = "White Russian"
		id = "w_russian"
		result = "w_russian"
		required_reagents = list("vodka" = 1, "coffee" = 1, "milk" = 1)
		result_amount = 3
		mix_phrase = "The drink abides."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_w_russian/fresh
		id = "w_russian_fresh"
		required_reagents = list("vodka" = 1, "coffee_fresh" = 1)

	cocktail_w_russian/w_russian2
		id = "w_russian2"
		required_reagents = list("b_russian" = 2, "milk" = 1)
		result_amount = 3

	cocktail_irishcoffee
		name = "Irish Coffee"
		id = "irishcoffee"
		result = "irishcoffee"
		required_reagents = list("coffee" = 1, "bourbon" = 1, "milk" = 1, "sugar" = 1)
		result_amount = 4
		mix_phrase = "The drink turns a rich brown and smells like a hangover."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_irishcoffee/fresh
		id = "irishcoffee_fresh"
		required_reagents = list("coffee_fresh" = 1, "bourbon" = 1, "milk" = 1, "sugar" = 1)

	cocktail_dbreath
		name = "Dragon's Breath"
		id = "dbreath"
		result = "dbreath"
		required_reagents = list("bourbon" = 1, "phlogiston" = 1, "pyrosium" = 1, "fuel" = 1, "ghostchilijuice"= 1)
		result_amount = 1
		mix_phrase = "A tiny mushroom cloud erupts from the container. That's not worrying at all!"
		mix_sound = 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg'
		hidden = TRUE

	cocktail_gtonic
		name = "Gin and Tonic"
		id = "gtonic"
		result = "gtonic"
		required_reagents = list("gin" = 1, "tonic" = 1)
		result_amount = 2
		mix_phrase = "The tonic water and gin mix together perfectly."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_vtonic
		name = "Vodka Tonic"
		id = "vtonic"
		result = "vtonic"
		required_reagents = list("vodka" = 1, "tonic" = 1)
		result_amount = 2
		mix_phrase = "The tonic water and vodka mix together perfectly."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_sonic
		name = "Gin and Sonic"
		id = "sonic"
		result = "sonic"
		required_reagents = list("gtonic" = 1, "methamphetamine" = 1)
		result_amount = 2
		mix_phrase = "The drink turns electric blue and starts quivering violently."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_gpink
		name = "Pink Gin and Tonic"
		id = "gpink"
		result = "gpink"
		required_reagents = list("gtonic" = 1, "bitters" = 1)
		result_amount = 2
		mix_phrase = "The gin and tonic gets even more bitter. Way to go!"
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_eraser
		name = "Mind Eraser"
		id = "eraser"
		result = "eraser"
		required_reagents = list("vtonic" = 1, "coffee" = 1)
		result_amount = 2
		mix_phrase = "The coffee, tonic, and vodka separate into dangerously drinkable layers."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_eraser/fresh
		id = "eraser_fresh"
		required_reagents = list("vtonic" = 1, "coffee_fresh" = 1)

	cocktail_madmen
		name = "Old Fashioned"
		id = "madmen"
		result = "madmen"
		required_reagents = list("bourbon" = 1, "bitters" = 1, "water" = 1, "sugar" = 1)
		result_amount = 4
		mix_phrase = "The cocktail gets back to basics."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_planter
		name = "Planter's Punch"
		id = "planter"
		result = "planter"
		required_reagents = list("rum" = 1, "lemonade" = 1)
		result_amount = 2
		mix_phrase = "A nicely Jamaican smell wafts out of the container."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_maitai
		name = "Mai Tai"
		id = "maitai"
		result = "maitai"
		required_reagents = list("rum" = 1, "juice_lime" = 1, "juice_orange" = 1)
		result_amount = 4
		mix_phrase = "A little pink umbrella magically appears in the drink."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_lemondrop
		name = "Lemon Drop"
		id = "lemondrop"
		result = "lemondrop"
		required_reagents = list("simplesyrup" = 1, "juice_lemon" = 1, "juice_orange" = 1, "vodka" = 1)
		result_amount = 4
		mix_phrase = "The sweet and sour contents mix together nicely to make a pastel yellow drink."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_lemondrop/lemondrop2
		id = "lemondrop2"
		required_reagents = list("simplesyrup" = 1, "juice_lemon" = 1, "screwdriver" = 2)
		result_amount = 4

	cocktail_harlow
		name = "Jean Harlow"
		id = "harlow"
		result = "harlow"
		required_reagents = list("rum" = 1, "vermouth" = 1)
		result_amount = 2
		mix_phrase = "The ghosts of starlets past waft by."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_gchronic
		name = "Gin and Chronic"
		id = "gchronic"
		result = "gchronic"
		required_reagents = list("gtonic" = 1, "THC" = 1)
		result_amount = 2
		mix_phrase = "Dude. Dude. You're, like, a genius."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_margarita
		name = "Margarita"
		id = "margarita"
		result = "margarita"
		required_reagents = list("tequila" = 1, "juice_orange" = 1, "juice_lime" = 1)
		result_amount = 3
		mix_phrase = "The tequila and citrus pair together like old, alcoholic friends."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_tequini
		name = "Tequini"
		id = "tequini"
		result = "tequini"
		required_reagents = list("tequila" = 1, "vermouth" = 1)
		result_amount = 2
		mix_phrase = "James Bond would be deeply confused."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_pfire
		name = "Prairie Fire"
		id = "pfire"
		result = "pfire"
		required_reagents = list("tequila" = 1, "capsaicin" = 1)
		result_amount = 2
		mix_phrase = "The hot sauce and tequila mix to create a frat boy's worst nightmare."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_bull
		name = "Brave Bull"
		id = "bull"
		result = "bull"
		required_reagents = list("tequila" = 1, "coffee" = 1)
		result_amount = 2
		mix_phrase = "The coffee and tequila mix together. Liqueur? Who needs it?"
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_bull/fresh
		id = "bull_fresh"
		required_reagents = list("tequila" = 1, "coffee_fresh" = 1)

	cocktail_longisland_rcola
		name = "Long Island Iced Tea"
		id = "longisland_rcola"
		result = "longisland"
		required_reagents = list("tequila" = 1, "screwdriver" = 1, "gin" = 1, "juice_lemon" = 1, "rcola" = 1)
		result_amount = 6
		mix_phrase = "The frightening amount of liquor in the container balances out with the cola and sours."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_longisland
		name = "Long Island Iced Tea"
		id = "longisland"
		result = "longisland"
		required_reagents = list("tequila" = 1, "screwdriver" = 1, "rum" = 1, "gin" = 1, "juice_lemon" = 1, "cola" = 1)
		result_amount = 6
		mix_phrase = "The frightening amount of liquor in the container balances out with the cola and sours."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_lingtea
		name = "Ling Island Iced Tea"
		id = "lingtea"
		result = "lingtea"
		required_reagents = list("longisland" = 1, "neurotoxin" = 1)
		min_temperature = T0C + 100
		result_amount = 2
		mix_phrase = "The toxin upsets the delicate balance of alcohol and sours in this mix. Ew."

	cocktail_longbeach
		name = "Long Beach Iced Tea"
		id = "longbeach"
		result = "longbeach"
		required_reagents = list("tequila" = 1, "beach" = 1, "rum" = 1, "gin" = 1, "juice_lemon" = 1)
		result_amount = 5
		mix_phrase = "The frightening amount of liquor in the container balances out with the lemon juice and sours."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_hunchback
		name = "Hunchback"
		id = "hunchback"
		result = "hunchback"
		required_reagents = list("bourbon" = 1, "cola" = 1, "juice_tomato" = 1)
		result_amount = 3
		mix_phrase = "The chunks of tomato paste hang in the bourbon and cola as an emulsion. It looks as horrible as it sounds."
		mix_sound = 'sound/impact_sounds/Slimy_Hit_4.ogg'

	cocktail_pinacolada
		name = "Piña Colada"
		id = "pinacolada"
		result = "pinacolada"
		required_reagents = list("juice_pineapple" = 1, "rum" = 1, "coconut_milk" = 1)
		result_amount = 3
		mix_phrase = "The drink gives off the smell of a rainy beach."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_mimosa
		name = "Mimosa"
		id = "mimosa"
		result = "mimosa"
		required_reagents = list("juice_orange" = 1, "champagne" = 1)
		result_amount = 1
		mix_phrase = "The drink fizzes as the pulp settles to the top."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_french75
		name = "French 75"
		id = "french75"
		result = "french75"
		required_reagents = list("lemonade" = 1, "gin" = 1, "champagne" = 1)
		result_amount = 3
		mix_phrase = "The drink fizzes and turns a dark gold."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_tomcollins
		name = "Tom Collins"
		id = "tomcollins"
		result = "tomcollins"
		required_reagents = list("gin" = 1, "tonic" = 1, "lemonade" = 1)
		result_amount = 3
		mix_phrase = "And who was Tom Collins? An ever elusive mystery..."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_tomcollins/tomcollins2
		id = "tomcollins2"
		required_reagents = list("gtonic" = 2, "lemonade" = 1)
		result_amount = 3

	cocktail_sangria
		name = "Sangria"
		id = "sangria"
		result = "sangria"
		required_reagents = list("planter" = 2, "wine" = 1, "juice_orange" = 1)
		result_amount = 4
		mix_phrase = "The drink fizzes and turns a nice burgundy."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_sangria/sangria2
		id = "sangria2"
		required_reagents = list("wine" = 1, "juice_orange" = 1, "lemonade" = 1, "rum" = 1)
		result_amount = 4

	cocktail_peachschnapps
		name = "Peach Schnapps"
		id = "peachschnapps"
		result = "peachschnapps"
		required_reagents = list("vodka" = 1, "juice_peach" = 1)
		result_amount = 2
		mix_phrase = "The vodka and peach juice fizz into a pleasantly pink hue."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_bellini
		name = "Peach Bellini"
		id = "peachbellini"
		result = "peachbellini"
		required_reagents = list("white_wine" = 2, "juice_peach" = 1)
		result_amount = 3
		mix_phrase = "You contemplate Renaissance paintings as the peach purée suspends in the white wine."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_rossini
		name = "Rossini"
		id = "rossini"
		result = "rossini"
		required_reagents = list("white_wine" = 2, "juice_strawberry" = 1)
		result_amount = 3
		mix_phrase = "Faint opera music echoes from the glass."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_moscowmule
		name = "Moscow Mule"
		id = "moscowmule"
		result = "moscowmule"
		required_reagents = list("v_gimlet" = 2, "ginger_ale" = 1)
		result_amount = 3
		mix_phrase = "The ginger ale bubbles as it mixes with the vodka and lime juice."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_moscowmule/moscowmule2
		id = "moscowmule2"
		required_reagents = list("vodka" = 1, "ginger_ale" = 1, "juice_lime" = 1)

	cocktail_tequilasunrise
		name = "Tequila Sunrise"
		id = "tequilasunrise"
		result = "tequilasunrise"
		required_reagents = list("tequila" = 1, "juice_orange" = 1, "grenadine" = 1)
		result_amount = 3
		mix_phrase = "The drink fizzes into some liquid sunshine for the soul."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_paloma
		name = "Paloma"
		id = "paloma"
		result = "paloma"
		required_reagents = list("tequila" = 1, "juice_grapefruit" = 1, "juice_lime" = 1)
		result_amount = 3
		mix_phrase = "The drink gives off a deliciously summery scent."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_mintjulep
		name = "Mint Julep"
		id = "mintjulep"
		result = "mintjulep"
		required_reagents = list("mint" = 1, "bourbon" = 1, "sugar" = 1)
		result_amount = 3
		mix_phrase = "The drink fizzes into a pleasantly minty cocktail."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_mojito
		name = "Mojito"
		id = "mojito"
		result = "mojito"
		required_reagents = list("daiquiri" = 3, "mint" = 1)
		result_amount = 4
		mix_phrase = "The scent of summer wafts out of the container."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_mojito/mojito2
		id = "mojito2"
		required_reagents = list("mint" = 1, "lime" = 1, "rum" = 1, "sugar" = 1)
		result_amount = 4

	cocktail_cremedementhe
		name = "Créme de Menthe"
		id = "cremedementhe"
		result = "cremedementhe"
		required_reagents = list("mint" = 1, "vodka" = 1, "sugar" = 1)
		result_amount = 3
		mix_phrase = "The mint and sugar mix obligingly with the vodka."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_grasshopper
		name = "Grasshopper"
		id = "grasshopper"
		result = "grasshopper"
		required_reagents = list("cremedementhe" = 3, "chocolate" = 1, "vanilla" = 1)
		result_amount = 5
		mix_phrase = "The drink turns a pale frothy green."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_grasshopper/grasshopper2
		id = "grasshopper2"
		required_reagents = list("mint" = 1, "vodka" = 1, "sugar" = 1, "chocolate" = 1, "vanilla" = 1)
		result_amount = 5

	cocktail_freeze
		name = "Freeze"
		id = "freeze"
		result = "freeze"
		required_reagents = list("menthol" = 1, "cryostylane" = 1, "cryoxadone" = 1, "ether" = 1, "gin" = 1)
		result_amount = 1
		mix_phrase = "The drink turns a pale mint color and frost forms on its surface."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		hidden = TRUE

	cocktail_bluelagoon
		name = "Blue Lagoon"
		id = "bluelagoon"
		result = "bluelagoon"
		required_reagents = list("vodka" = 1, "curacao" = 1, "lemonade" = 1)
		result_amount = 3
		mix_phrase = "The drink swirls around pleasantly."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_bluehawaiian
		name = "Blue Hawaiian"
		id = "bluehawaiian"
		result = "bluehawaiian"
		required_reagents = list("pinacolada" = 3, "curacao" = 1, "ice" = 1)
		result_amount = 5
		mix_phrase = "The drink shimmers a bright blue."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_bluehawaiian/bluehawaiian2
		id = "bluehawaiian2"
		required_reagents = list("rum" = 1, "curacao" =1, "juice_pineapple" = 1, "coconut_milk" = 1, "ice" = 1)
		result_amount = 3

	cocktail_negroni
		name = "Negroni"
		id = "negroni"
		result = "negroni"
		required_reagents = list("gin" = 1, "vermouth" = 1, "bitters" = 1)
		result_amount = 3
		mix_phrase = "The drink turns a deep red and gives off a hit of sweetness."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	cocktail_negroni/negroni2
		id = "negroni2"
		required_reagents = list("martini" = 2, "bitters" = 1)
		result_amount = 3

	cocktail_necroni
		name = "Necroni"
		id = "necroni"
		result = "necroni"
		required_reagents = list("gin" = 1, "vermouth" = 1, "bitters" = 1, "ectoplasm" = 1)
		result_amount = 4
		mix_phrase = "The drink gives off a haunting stench! What did you make?"
		mix_sound = 'sound/effects/ghostbreath.ogg'

	cocktail_necroni/necroni2
		id = "necroni2"
		required_reagents = list("negroni" = 2, "ectoplasm" = 1)
		result_amount = 3

	cocktail_honky_tonic
		name = "Honky Tonic"
		id = "honky_tonic"
		result = "honky_tonic"
		required_reagents = list("tonic" = 1, "lube" = 1, "neurotoxin" = 1, "juice_banana" = 1)
		result_amount = 4
		mix_phrase = "The drink honks at you! What the fuck?"
		mix_sound = 'sound/misc/drinkfizz_honk.ogg'
		drinkrecipe = TRUE

	cocktail_dirty_banana
		name = "Dirty Banana"
		id = "dirty_banana"
		result = "dirty_banana"
		required_reagents = list("rum" = 1, "juice_banana" = 1, "chocolate" = 1, "milk" = 1)
		result_amount = 4
		mix_phrase = "It's creamy, fruity and surprisingly clean!"
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	cocktail_dirty_banana/banana
		id = "dirty_banana_banana"
		required_reagents = list("rum" = 1, "chocolate" = 1, "banana_milk" = 2)

	cocktail_dirty_banana/choco
		id = "dirty_banana_choco"
		required_reagents = list("rum" = 1, "juice_banana" = 1, "chocolate_milk" = 2)

	cocktail_sweet_surprise
		name = "Sweet Surprise"
		id = "sweet_surprise"
		result = "sweet_surprise"
		required_reagents = list("rum" = 1, "juice_banana" = 1, "coconut_milk" = 1)
		result_amount = 3
		mix_phrase = "The banana and coconut give off a tropical aroma when mixed."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	cocktail_sweet_dreams
		name = "Sweet Dreams"
		id = "sweet_dreams"
		result = "sweet_dreams"
		required_reagents = list("sweet_surprise" = 1, "capulettium" = 1)
		result_amount = 2
		mix_phrase = "The sweet smell is almost enough to make you fall asleep."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	cocktail_mulled_wine
		name = "Mulled Wine"
		id = "mulled_wine"
		result = "mulled_wine"
		required_reagents = list("wine" = 1, "cinnamon" = 1, "sugar" = 1)
		result_amount = 3
		mix_phrase = "You feel slightly warmer already."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	cocktail_spacemas_spirit
		name = "Spacemas Spirit"
		id = "spacemas_spirit"
		result = "spacemas_spirit"
		required_reagents = list("mulled_wine" = 1, "vodka" = 1)
		result_amount = 2
#ifdef XMAS
		mix_phrase = "You feel like giving gifts already."
#else
		mix_phrase = "It's not spacemas yet!."
#endif
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	cola
		name = "cola"
		id = "cola"
		result = "cola"
		required_reagents = list("sodawater" = 1, "sugar" = 1)
		result_amount = 2
		mix_phrase = "The mixture begins to fizz."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	hot_toddy
		name = "Hot Toddy"
		id = "hottoddy"
		result = "hottoddy"
		required_reagents = list("sweet_tea" = 1, "bourbon" = 1, "juice_lemon" = 1, "cinnamon" = 1)
		result_amount = 4
		mix_phrase = "The drink suddenly fills the room with a festive aroma."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	hot_toddy_halfnhalf
		name = "Hot Toddy"
		id = "hottoddy_halfnhalf"
		result = "hottoddy"
		required_reagents = list("halfandhalf" = 2, "bourbon" = 1)
		result_amount = 3
		mix_phrase = "The drink suddenly fills the room with a festive aroma."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	bees_knees
		name = "Bee's Knees"
		id = "beesknees"
		result = "beesknees"
		required_reagents = list("gin" = 1, "honey" = 1, "juice_lemon" = 1)
		result_amount = 3
		mix_phrase = "You hear a faint buzz from the solution and your knees slightly ache."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	spiced_rum
		name = "Spiced Rum"
		id = "spicedrum"
		result = "spicedrum"
		required_reagents = list("rum" = 1, "cinnamon" = 1)
		result_amount = 2
		mix_phrase = "The drink fills the room with the smell of cinnamon."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

		fake
			id = "spicedrumfake"
			result = "spicedrumfake"
			required_reagents = list("rum" = 1, "capsaicin" = 1)
			mix_phrase = "You feel like you might have misunderstood the recipe."

	romulale
		name = "Romulale"
		id = "romulale"
		result = "romulale"
		required_reagents =list("juice_blueberry" = 1, "juice_blueraspberry" = 1, "beer" = 2)
		result_amount = 4
		mix_phrase = "A strong smell comes from the solution."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	phil_collins
		name = "Phil Collins"
		id = "philcollins"
		result = "philcollins"
		required_reagents = list("vtonic" = 1, "lemonade" = 1)
		result_amount = 2
		mix_phrase = "You can feel it coming in the air tonight. Oh lord."
		mix_sound = 'sound/misc/PhilCollinsTom.ogg'
		drinkrecipe = TRUE

	duck_fart
		name = "Duck Fart"
		id = "duckfart"
		result = "duckfart"
		required_reagents = list("bourbon" = 1, "coffee" =1 , "milk" = 1)
		result_amount = 3
		mix_phrase = "You hear a faint quack from the solution along with a pungent stench."
		mix_sound = 'sound/voice/farts/fart3.ogg'
		drinkrecipe = TRUE

	duck_fart/fresh
		id = "duckfart_fresh"
		required_reagents = list("bourbon" = 1, "coffee_fresh" =1 , "milk" = 1)

	pink_lemonade
		name = "Pink lemonade"
		id = "pinklemonade"
		result = "pinklemonade"
		required_reagents = list("grenadine" = 1,"lemonade" = 1)
		result_amount = 2
		mix_phrase = "You watch the pink colour dance around the container and slowly combine with the lemonade."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		drinkrecipe = TRUE

	squeeze
		name = "Squeeze"
		id = "squeeze"
		result = "squeeze"
		required_reagents = list("bread" = 3, "fuel" = 2)
		result_amount = 2
		mix_phrase = "The fuel is filtered through the bread and makes something vaguely consumable."

	antihol
		name = "Antihol"
		id = "antihol"
		result = "antihol"
		required_reagents = list("ethanol" = 1, "charcoal" = 1)
		result_amount = 2
		mix_phrase = "A minty and refreshing smell drifts from the effervescent mixture."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	ectocooler
		name = "Ecto Cooler"
		id = "ectocooler"
		result = "ectocooler"
		required_reagents = list("juice_orange" = 1, "ectoplasm" = 1, "uranium" = 1)
		result_amount = 3
		mix_phrase = "The orange juice turns an unsettlingly vibrant shade of green."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	matchatea
		name = "Matcha Tea"
		id = "matchatea"
		result = "matchatea"
		required_reagents = list("matcha"=1, "water"= 1)
		result_amount = 2
		mix_phrase = "The matcha dissolves into the water, turning a darker green."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	tealquila
		name = "Tealquila Sunrise"
		id = "tealquila"
		result = "tealquila"
		required_reagents = list("tequilasunrise" = 1, "flockdrone_fluid" = 1)
		result_amount = 2
		mix_phrase = "The bright orange Sunrise neutralizes the gnesis, somehow becoming even more teal in the process."
		mix_sound = 'sound/misc/flockmind/flockmind_cast.ogg'

		//we don't react in bloodstream, gotta get the gnesis out first
		does_react(var/datum/reagents/holder)
			return !ismob(holder.my_atom)

		on_reaction(var/datum/reagents/holder, var/created_volume)
			if (holder.has_reagent("blood") || holder.has_reagent("bloodc")) //don't expose lings
				for(var/mob/M in all_viewers(null, get_turf(holder.my_atom)))
					boutput(M, SPAN_ALERT("The gnesis rapidly absorbs the remaining blood before becoming inert."))
				holder.del_reagent("blood")
				holder.del_reagent("bloodc")

	iced/coconutmilkespresso
		name = "Iced Coconut Milk Espresso"
		id = "icedcoconutmilkespresso"
		result = "icedcoconutmilkespresso"
		required_reagents = list("espresso" = 1, "ice" = 3, "coconut_milk" =2, "sugar" = 2)
		result_amount = 8
		mix_phrase = "The ice clinks against the container as you blend everything together."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	iced/pineapplematcha
		name = "Iced Pineapple Matcha"
		id = "icedpineapplematcha"
		result = "icedpineapplematcha"
		required_reagents = list("matcha" = 1, "juice_pineapple" = 1, "coconut_milk" = 2, "ice" = 1)
		result_amount = 5
		mix_phrase = "The milk mixes with the matcha in a soothing green."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	iced/thaiicedcoffee
		name = "Thai Iced Coffee"
		id = "thaiicedcoffee"
		result = "thaiicedcoffee"
		required_reagents = list("coffee" = 3, "sugar" = 1, "milk" = 1, "ice" = 1)
		result_amount = 6
		mix_phrase = "Everything mixes together nicely, releasing a sweet smell."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	iced/thaiicedcoffee/fresh
		id = "thaiicedcoffee_fresh"
		required_reagents = list("coffee_fresh" = 3, "sugar" = 1, "milk" = 1, "ice" = 1)

	pepperminthotchocolate
		name = "Peppermint Hot Chocolate"
		id = "pepperminthotchocolate"
		result = "pepperminthotchocolate"
		required_reagents = list("chocolate" = 2, "mint" = 1, "milk" = 1)
		result_amount = 4
		mix_phrase = "The mixture smells like a warm hug, or possibly toothpaste."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	pepperminthotchocolate/pepperminthotchocolate2
		id = "pepperminthotchocolate2"
		required_reagents =list("mint" = 1, "chocolate_milk" = 3)
		result_amount = 4

	mexicanhotchocolate
		name = "Mexican Hot Chocolate"
		id = "mexicanhotchocolate"
		result = "mexicanhotchocolate"
		required_reagents = list("capsaicin" = 1, "chocolate_milk"= 2)
		result_amount = 3
		mix_phrase = "A spicy smell drifts up from the chocolate."

	mexicanhotchocolate/cinnamon
		id = "mexicanhotchocolate_cinnamon"
		required_reagents = list("cinnamon" = 1, "chocolate_milk"= 2)
		result_amount = 3

	pumpkinspicelatte
		name = "Pumpkin Spice Latte"
		id = "pumpkinspicelatte"
		result = "pumpkinspicelatte"
		required_reagents = list("juice_pumpkin"=1, "milk"= 2, "espresso"=1, "cinnamon"=1)
		result_amount = 5
		mix_phrase = "The drink smells vaguely like artifical autumn."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	lavenderlatte
		name = "Lavender Latte"
		id = "lavender_latte"
		result = "lavender_latte"
		required_reagents = list("lavender_essence"=1, "milk"= 2, "espresso"=1)
		result_amount = 4
		mix_phrase = "A sweet floral scent drifts up from the pale foamy mixture."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	explosion_potassium // get in
		name = "Potassium Explosion"
		id = "explosion_potassium"
		required_reagents = list("water" = 1, "potassium" = 1)
		instant = 1
		mix_phrase = "The mixture explodes!"
		hidden = TRUE
		reaction_icon_state = list("reaction_explode-1", "reaction_explode-2")
		reaction_icon_color = "#ffffff"
		on_reaction(var/datum/reagents/holder, var/created_volume)
			if (holder.last_basic_explosion >= ticker.round_elapsed_ticks - 3)
				return
			holder.last_basic_explosion = ticker.round_elapsed_ticks
			var/atom/my_atom = holder.my_atom
			if (my_atom)
				var/turf/location = get_turf(my_atom)
				explosion(my_atom, location, -1,-1,0,1)
				fireflash(location, 0, chemfire = CHEM_FIRE_PURPLE)
				if(istype(holder.my_atom, /obj))
					var/obj/container = holder.my_atom
					container.shatter_chemically(projectiles = TRUE)
			else if (holder.covered_cache)
				var/amt = max(1, (holder.covered_cache.len * (created_volume / holder.covered_cache_volume)))
				for (var/i = 0, i < amt && holder.covered_cache.len, i++)
					var/turf/location = pick(holder.covered_cache)
					holder.covered_cache -= location
					explosion_new(my_atom, location, 2.25/amt)
					fireflash(location, 0, chemfire = CHEM_FIRE_PURPLE)

	explosion_barium // get in
		name = "Barium Explosion"
		id = "explosion_barium"
		required_reagents = list("water" = 1, "barium" = 1)
		instant = FALSE //delayed explosion, triggers when it's all done reacting.
		stateful = TRUE
		mix_phrase = "The mixture starts to bubble."
		hidden = TRUE
		reaction_speed = 1
		result_amount = 1
		var/total_volume_created = 0

		on_reaction(var/datum/reagents/holder, var/created_volume)
			if(prob(50))
				reaction_speed += 1
			total_volume_created += created_volume

		on_end_reaction(var/datum/reagents/holder)
			if (holder.last_basic_explosion >= ticker.round_elapsed_ticks - 3)
				return
			holder.last_basic_explosion = ticker.round_elapsed_ticks
			var/atom/my_atom = holder.my_atom

			var/turf/location = 0
			if (my_atom)
				location = get_turf(my_atom)
				explosion(my_atom, location, -1,-1,0,1)
				fireflash(location, 0, chemfire = CHEM_FIRE_YELLOW)
				if(istype(holder.my_atom, /obj))
					var/obj/container = holder.my_atom
					container.shatter_chemically(projectiles = TRUE)
			else
				var/amt = length(holder.covered_cache) * (total_volume_created / holder.covered_cache_volume)
				for (var/i = 0, i < amt && length(holder.covered_cache), i++)
					location = pick(holder.covered_cache)
					holder.covered_cache -= location
					explosion_new(my_atom, location, 2.25/amt)

	explosion_magnesium // get in
		name = "Magnesium Explosion"
		id = "explosion_magnesium"
		required_reagents = list("magnesium" = 1, "copper" = 1, "oxygen" = 1)
		instant = 1
		mix_phrase = "The mixture explodes!"
		hidden = TRUE
		on_reaction(var/datum/reagents/holder, var/created_volume)
			if (holder.last_basic_explosion >= ticker.round_elapsed_ticks - 3)
				return
			holder.last_basic_explosion = ticker.round_elapsed_ticks
			var/atom/my_atom = holder.my_atom

			var/turf/location = 0
			if (my_atom)
				location = get_turf(my_atom)
				explosion(my_atom, location, -1,-1,0,1)
				fireflash(location, 0, chemfire = CHEM_FIRE_WHITE)
				if(istype(holder.my_atom, /obj))
					var/obj/container = holder.my_atom
					container.shatter_chemically(projectiles = TRUE)
			else
				var/amt = max(1, (holder.covered_cache.len * (created_volume / holder.covered_cache_volume)))
				for (var/i = 0, i < amt && holder.covered_cache.len, i++)
					location = pick(holder.covered_cache)
					holder.covered_cache -= location
					explosion_new(my_atom, location, 2.25/amt)
					fireflash(location, 0, chemfire = CHEM_FIRE_WHITE)

	magnesium_chloride
		name = "Magnesium Chloride"
		id = "magnesium_chloride"
		required_reagents = list("magnesium" = 1, "clacid" = 2)
		result = "magnesium_chloride"
		mix_phrase = "The mixture settles into a white powder."
		result_amount = 1
		on_reaction(var/datum/reagents/holder, var/created_volume)
			holder.add_reagent("hydrogen", created_volume * 2, chemical_reaction = TRUE, chem_reaction_priority = 2)

	mg_nh3_cl
		name = "Magnesium-Ammonium Chloride"
		id = "mg_nh3_cl"
		required_reagents = list("magnesium_chloride" = 1, "ammonia" = 6)
		result = "mg_nh3_cl"
		result_amount = 1
		min_temperature = T20C + 10
		mix_phrase = "The mixture seems to combine."

	mg_nh3_cl_decomposition
		name = "Magnesium-Ammonium Chloride Decomposition"
		id = "mg_nh3_cl_decomposition"
		result = "magnesium_chloride"
		required_reagents = list("mg_nh3_cl" = 1)
		result_amount = 1
		min_temperature = T0C + 150
		hidden = TRUE
		on_reaction(var/datum/reagents/holder, var/created_volume)
			holder.add_reagent("ammonia", created_volume * 6, chemical_reaction = TRUE, chem_reaction_priority = 2)
		mix_phrase = "The mixture bubbles aggressively."

	silicate
		name = "Silicate"
		id = "silicate"
		result = "silicate"
		required_reagents = list("aluminium" = 1, "silicon" = 1, "oxygen" = 1)
		result_amount = 3
		mix_phrase = "The substance mixes into a clear, viscous liquid."

	graphene
		name = "Graphene"
		id = "graphene"
		result = "graphene"
		required_reagents = list("fuel" = 4, "iron" = 1, "silicon" = 1) //silicon dioxide -> silicon because this whole chain is too damn long
		min_temperature = T0C + 150
		result_amount = 2
		reaction_speed = 1
		instant = 0
		mix_phrase = "A small particulate forms into a tiny lattice."
		on_reaction(var/datum/reagents/holder, var/created_volume)
			holder.add_reagent("oxygen", created_volume, chemical_reaction = TRUE, chem_reaction_priority = 2)
			holder.add_reagent("salt", created_volume, chemical_reaction = TRUE, chem_reaction_priority = 3)

	graphene_compound
		name = "Graphene Hardening Compound"
		id = "graphene_compound"
		result = "graphene_compound"
		required_reagents = list("graphene" = 1, "spaceglue" = 9)
		result_amount = 10
		mix_phrase = "The substance turns dark with a beautiful faceted lattice pattern."

	oil
		name = "Oil"
		id = "oil"
		result = "oil"
		required_reagents = list("carbon" = 0, "hydrogen" = 0, "fuel" = 1)
		instant = FALSE
		reaction_speed = 0.05 //very very slow by default, but much faster with heat
		result_amount = 1
		mix_phrase = "An iridescent black chemical forms in the container."

		on_reaction(datum/reagents/holder, created_volume)
			if(holder.total_temperature > (T0C + 30)) //requires *some* outside heating to start reacting more quickly
				var/temperature_over_30C = holder.total_temperature - (T0C + 30)
				//more heat = exponentially more welding fuel used, clamped to 0.5u per reaction + however much oil is made
				var/excess_fuel_to_use = round(clamp(0.1 * (1.1 ** temperature_over_30C), 0, 0.5), 0.01)
				//because that excess does not scale with created_volume, we got to apply the volume-dependant speed factor seperatly from that
				excess_fuel_to_use *= 1 + src.get_volume_reaction_speed_factor(holder)
				holder.remove_reagent("fuel", excess_fuel_to_use)

		get_reaction_speed_multiplicator(var/datum/reagents/holder)
			. = ..()
			if (holder.total_temperature > (T0C + 30))
				//more heat = more oil more quickly, but with diminishing returns that never go over 1.5u per reaction
				// we need to account with the additional created volume for that baseline 0.05 reaction speed, thus a factor of 20
				var/temperature_over_30C = holder.total_temperature - (T0C + 30)
				. *= (1 + round((temperature_over_30C * 30)/(temperature_over_30C + 40), 0.01))

	hydrogen_carbon_dissolve //made to interact with oil so you have to keep it 'fueled', change to make a unique chem that fades away instead if this is broken/weird later
		name = "hydrogen_carbon_dissolving"
		id = "hydrogen_carbon_dissolving"
		required_reagents = list("carbon" = 1, "hydrogen" = 1)
		inhibitors = list("fuel", "magnesium_chloride" = 5) //keep welding fuel to keep cooking oil/plastic or magnesium chloride for better plasticmaking
		hidden = TRUE
		instant = FALSE
		reaction_speed = 2
		result_amount = 1
		mix_phrase = "The mixture begins to vibrate and dissolve quickly."

		on_reaction(var/datum/reagents/holder)
			holder.physical_shock(rand(2, 6))

		does_react(var/datum/reagents/holder)
			if (holder.has_reagent("oxygen") && holder.has_reagent("nitrogen")) //luminol!
				return FALSE
			else
				return TRUE

	polyethylene // behold as i mangle the Zeigler-Natta process (technically its using a Phillips catalyst but uh)
		name = "Polyethylene Plastic"
		id = "polyethylene"
		required_reagents = list("carbon" = 1, "hydrogen" = 2, "oil" = 1, "chromium" = 0)
		instant = FALSE
		stateful = TRUE
		hidden = TRUE
		result_amount = 1
		reaction_speed = 0.05
		mix_phrase = "The mixture slowly froths into granules of solid plastic."
		reaction_icon_state = list("reaction_puff-1", "reaction_puff-2")
		mix_sound = 'sound/misc/drinkfizz.ogg'
		reaction_icon_color = "#8c866d"
		var/count = 0

		on_reaction(datum/reagents/holder, created_volume)
			count += created_volume
			if (holder.has_reagent("silicon_dioxide")) // prevent catalyst ashing with a support
				holder.remove_reagent("silicon_dioxide", created_volume / 5)
			else
				holder.remove_reagent("chromium", 4 * created_volume) // super exaggerated catalytic ashing
			if (holder.has_reagent("magnesium_chloride"))
				holder.remove_reagent("magnesium_chloride", created_volume / 5)
			if (count >= 10)
				count -= 10
				var/location = get_turf(holder.my_atom) || pick(holder.covered_cache)
				for(var/mob/M in AIviewers(null, location))
					boutput(M, SPAN_NOTICE("The plastic clumps together in a messy sheet."))
				new /obj/item/material_piece/rubber/plastic(location)

		get_reaction_speed_multiplicator(var/datum/reagents/holder)
			. = ..()
			if (holder.has_reagent("magnesium_chloride"))
				. *= 5

	hemodissolve // denaturing hemolymph
		name = "Copper"
		id = "copper"
		result = "copper"
		mix_sound = 'sound/misc/drinkfizz.ogg'
		required_reagents = list("hemolymph" = 5, "cleaner" = 1,  "acetone" = 1)
		min_temperature = T0C + 30 // just a little bit of heat
		result_amount = 1
		mix_phrase = "The hemolymph bubbles as a black precipitate falls out of the solution, denaturing into basic components."
		hidden = TRUE
		on_reaction(var/datum/reagents/holder, created_volume)
			holder.add_reagent("meat_slurry", created_volume, chemical_reaction = TRUE, chem_reaction_priority = 2)// meat slurry, since animal tissue
			holder.add_reagent("saline", 2*created_volume, chemical_reaction = TRUE, chem_reaction_priority = 3)//  saline-glucose solution, since blood
			holder.add_reagent("spaceacillin", created_volume, chemical_reaction = TRUE, chem_reaction_priority = 4)//  spaceacillin, since hemolymph is used for bacterial tests IRL
			holder.add_reagent("denatured_enzyme", created_volume, chemical_reaction = TRUE, chem_reaction_priority = 5)// and just some random biological chemicals for good measure

	mutagen
		name = "Unstable mutagen"
		id = "mutagen"
		result = "mutagen"
		required_reagents = list("radium" = 1, "plasma" = 1, "chlorine" = 1)
		result_amount = 3
		mix_phrase = "The substance turns neon green and bubbles unnervingly."

	dna_mutagen
		name = "Stable mutagen"
		id = "dna_mutagen"
		result = "dna_mutagen"
		required_reagents = list("mutagen" = 1, "lithium" = 1, "acetone" = 1, "bromine" = 1)
		result_amount = 3
		mix_phrase = "The substance turns a drab green and begins to bubble."
	//  min_temperature = 170

	dna_mutagen/dna_mutagen2
		id = "dna_mutagen2"
		required_reagents = list("mutadone" = 3, "lithium" = 1)
		result_amount = 4

	cold_medicine
		name = "Robustissin"
		id = "cold_medicine"
		result = "cold_medicine"
		required_reagents = list("menthol" = 1, "morphine" = 1, "hydrogen" = 1, "acetone" = 1)
		result_amount = 4
		mix_phrase = "The chemicals fizz together and a strange grape scent rises from the container."

	cold_medicine/cold_medicine2
		id = "cold_medicine2"
		required_reagents = list("antihistamine" = 1, "oil" = 1, "salicylic_acid" = 1, "menthol" = 1)

	hemotoxin
		name = "Hemotoxin"
		id = "hemotoxin"
		result = "hemotoxin"
		required_reagents = list("heparin" = 1, "ether" = 3, "clacid" = 2)
		min_temperature = T0C + 75 // Reacts dangerously close to ether's combustion point
		result_amount = 2
		mix_phrase = "The mixture simmers and gives off a strong acidic smell."
		instant = FALSE
		reaction_speed = 1 // Reacts slowly, it's important to keep the temperature in check
		stateful = TRUE
		reaction_icon_color = "#6e2e25"

	cyanide
		name = "Cyanide"
		id = "cyanide"
		result = "cyanide"
		required_reagents = list("oil" = 1, "ammonia" = 2, "oxygen" = 2) // more or less the industrial route to cyanide
		min_temperature = T0C + 100
		result_amount = 1 // let's not make it too easy to mass produce
		mix_phrase = "The mixture gives off a faint scent of almonds."
		instant = FALSE
		reaction_speed = 5
		stateful = TRUE
		mix_sound = 'sound/misc/drinkfizz.ogg'
		reaction_icon_color = "#539147" //not realistically what the fumes would look like, but *looks* toxic!

		on_reaction(var/datum/reagents/holder, var/created_volume)
			var/location = get_turf(holder.my_atom)
			if(holder?.my_atom?.is_open_container())
				reaction_icon_state = list("reaction_smoke-1", "reaction_smoke-2")
				var/datum/reagents/smokeContents = new/datum/reagents/
				smokeContents.add_reagent("cyanide", created_volume / src.reaction_speed)
				smoke_reaction(smokeContents, 2, location, do_sfx = FALSE)
			else
				reaction_icon_state = list("reaction_bubble-1", "reaction_bubble-2")
				holder.add_reagent("cyanide", created_volume / src.reaction_speed) //you get to keep what would have been in the smoke

	cyanide_offgas
		name = "Cyanide Offgas"
		id = "cyanide_offgas"
		required_reagents = list("cyanide" = 0) //removed in on_reaction
		result_amount = 1
		mix_phrase = "The mixture slowly gives off fumes."
		mix_sound = null
		instant = FALSE
		reaction_speed = 1
		stateful = TRUE
		reaction_icon_color = "#539147"
		var/count = 0

		does_react(var/datum/reagents/holder)
			if (holder.my_atom && holder.my_atom.is_open_container() && holder.total_temperature > (30 + T0C)\
				|| (istype(holder,/datum/reagents/fluid_group) && !holder.is_airborne()))
				return TRUE
			else
				return FALSE

		on_reaction(var/datum/reagents/holder, var/created_volume) //assuming this is sodium cyanide so it also interacts with water and sulfuric acid
			if (QDELETED(holder.my_atom) && !length(holder.covered_cache)) //not sure how this is happening but god please stop runtiming
				return
			var/amount_to_smoke = created_volume
			if(holder.has_reagent("acid"))
				amount_to_smoke = 20 * created_volume
				count += 6
			amount_to_smoke = min(amount_to_smoke, holder.get_reagent_amount("cyanide"))
			if(count < 6)
				if(holder.has_reagent("water"))
					count += 2
				else
					count++
				reaction_icon_state = null
			else
				var/location = get_turf(holder.my_atom) || pick(holder.covered_cache)
				reaction_icon_state = list("reaction_smoke-1", "reaction_smoke-2")
				var/datum/reagents/smokeContents = new
				smokeContents.add_reagent("cyanide", amount_to_smoke)
				smoke_reaction(smokeContents, 1, location, do_sfx = FALSE)
				holder.remove_reagent("cyanide", amount_to_smoke)
				count = 0

	Saxitoxin // replacing Sarin - come back to this with new recipe
		name = "Saxitoxin"
		id = "saxitoxin"
		result = "saxitoxin"
		required_reagents = list("chlorine" = 1, "fuel" = 1, "oxygen" = 1, "phosphorus" = 1, "fluorine" = 1, "hydrogen" = 1, "acetone" = 1, "weedkiller" = 1)
		result_amount = 3 // it is super potent
		mix_phrase = "The mixture yields a colorless, odorless liquid."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		hidden = TRUE

		on_reaction(var/datum/reagents/holder, created_volume)
			var/location = get_turf(holder.my_atom)
			for(var/mob/M in all_viewers(null, location))
				boutput(M, SPAN_ALERT("The solution generates a strong vapor!"))
			if(holder?.my_atom?.is_open_container())
				// A slightly less stupid way of smoking contents. Maybe.
				var/datum/reagents/smokeContents = new/datum/reagents/
				smokeContents.add_reagent("saxitoxin", created_volume / 6)
				smoke_reaction(smokeContents, 2, location)
				return

	menthol
		name = "Menthol"
		id = "menthol"
		result = "menthol"
		required_reagents = list("mint" = 1, "ethanol" = 1)
		min_temperature = T0C + 50
		result_amount = 1
		mix_phrase = "Large white crystals precipitate out of the mixture."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	iron_oxide
		name = "Iron Oxide"
		id = "iron_oxide"
		result = "iron_oxide"
		required_reagents = list("iron" = 1, "oxygen" = 1, "acetic_acid" = 1, "salt" = 1)
		result_amount = 4
		mix_phrase = "The iron rapidly rusts."
		min_temperature = T0C + 100

	thermite
		name = "Thermite"
		id = "thermite"
		result = "thermite"
		required_reagents = list("aluminium" = 1, "iron_oxide" = 1)
		result_amount = 3
		mix_phrase = "The solution mixes into a reddish-brown powder."

/*		lexorin
		name = "Lexorin"
		id = "lexorin"
		result = "lexorin"
		required_reagents = list("plasma" = 1, "hydrogen" = 1, "nitrogen" = 1)
		result_amount = 3
		mix_phrase = "A faint yet nostril-burning scent drifts from the mixture."*/

	space_drugs
		name = "Space Drugs"
		id = "space_drugs"
		result = "space_drugs"
		required_reagents = list("mercury" = 1, "sugar" = 1, "lithium" = 1)
		result_amount = 3
		mix_phrase = "Slightly dizzying fumes drift from the solution."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	mdma //MDMA and space drugs are already super similar. It's not very close to real life recipes but fuck it, I want this to be a botany friendly space drugs method.
		name = "MDMA"
		id = "mdma"
		result = "space_drugs"
		required_reagents = list("safrole" = 1, "salbutamol" = 1, "nitrogen"=1, "water" = 1)
		mix_phrase = "A white particulate settles from the solution."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		result_amount = 1
		on_reaction(var/datum/reagents/holder, created_volume)
			//CHECK FOR RECURSIVE REACTIONS AND RESOLVE
			var/safrole = holder.get_reagent_amount("safrole")
			var/nitrogen = holder.get_reagent_amount("nitrogen")
			var/temp = 0

			temp = min(safrole,nitrogen,created_volume)
			holder.add_reagent("space_drugs",temp, chemical_reaction = TRUE)
			safrole -= temp
			holder.remove_reagent("safrole", temp)
			nitrogen -= temp
			holder.remove_reagent("nitrogen", temp)

			holder.add_reagent("salbutamol",created_volume, chemical_reaction = TRUE, chem_reaction_priority = 2)
			holder.add_reagent("water",created_volume, chemical_reaction = TRUE, chem_reaction_priority = 3)
			return

	lube
		name = "Space Lube"
		id = "lube"
		result = "lube"
		required_reagents = list("water" = 1, "silicon" = 1, "oxygen" = 1)
		result_amount = 3
		mix_phrase = "The substance turns a striking cyan and becomes oily."

	glue
		name = "Space Glue"
		id = "spaceglue"
		result = "spaceglue"
		required_reagents = list("plasma" = 1, "phenol" = 0.25, "oxygen" = 1, "hydrogen" = 1, "formaldehyde" = 1)
		result_amount = 4
		mix_phrase = "The substance turns a dull yellow and becomes thick and sticky."

	superlube
		name = "Organic Superlube"
		id = "superlube"
		result = "superlube"
		required_reagents = list("lube" = 1, "helium" = 1)
		result_amount = 1
		mix_phrase = "The substance begins to swirl organically."

	acid
		name = "Sulfuric Acid" // COGWERKS CHEM REVISION PROJECT: This could be Fluorosulfuric Acid instead
		id = "acid"
		result = "acid"
		required_reagents = list("sulfur" = 1, "oxygen" = 1) //water or steam required, see does_react()
		result_amount = 2
		mix_phrase = "The mixture gives off a sharp acidic tang."
		instant = FALSE
		reaction_speed = 3
		temperature_change = 4 //changes to 8 in closed containers
		stateful = TRUE

		on_reaction(var/datum/reagents/holder, created_volume)
			if(holder.has_reagent("water"))
				holder.remove_reagent("water", created_volume/2)
			else
				holder.remove_reagent("steam", created_volume) //if it gets above 100C, you can still use steam (in a closed container) at half efficiency
				holder.remove_reagent("sulfur", created_volume/2) //also uses these less efficiently; this should mean an even amount of water, sulfur and oxygen will always deplete evenly-ish
				holder.remove_reagent("oxygen", created_volume/2)

			var/location = get_turf(holder.my_atom)
			if (holder.my_atom && holder.my_atom.is_open_container() || istype(holder,/datum/reagents/fluid_group))
				temperature_change = 4
				var/smoke_to_create = clamp((holder.total_temperature - (T20C + 40)) * created_volume / 60 , 0, 5)//for every degree over 60C, make .05u of smoke (up to 5u)...
				if(smoke_to_create > 0)                                                        //...but if under 60C, don't make any
					var/datum/reagents/smokeContents = new/datum/reagents/
					smokeContents.add_reagent("acid", smoke_to_create)
					smoke_reaction(smokeContents, 2, location, do_sfx = FALSE)
			else
				temperature_change = 8 //closed container = more contained heat
				if(holder.total_temperature > T20C + 40)
					var/extra_product = ceil(clamp((holder.total_temperature - (T20C + 30)) / 10, 1, 15))
					var/extra_heat = clamp(extra_product + 10, 5, 10)
					if(holder.total_temperature > T100C + 50) //mixture gets too hot = beaker shattered + acid vapors leak out
						var/obj/container = holder.my_atom
						if(container.shatter_chemically())
							var/datum/reagents/smokeContents = new/datum/reagents/
							smokeContents.add_reagent("acid", 20)
							smoke_reaction(smokeContents, 2, location, do_sfx = FALSE)
						return
					holder.add_reagent("acid", extra_product, temp_new = holder.total_temperature, chemical_reaction = TRUE)
					holder.temperature_reagents(holder.total_temperature + extra_heat)

		does_react(var/datum/reagents/holder)
			if(holder.has_reagent("water") || holder.has_reagent("steam"))
				return TRUE

		get_total_reaction_volume(var/datum/reagents/holder)
			. = ..()
			. += holder.get_reagent_amount("water") + holder.get_reagent_amount("steam")

	clacid
		name = "Hydrochloric Acid"
		id = "clacid"
		result = "clacid"
		required_reagents = list("hydrogen" = 1, "chlorine" = 1, "water" = 1)
		result_amount = 3
		mix_phrase = "The mixture gives off a sharp acidic tang."

		on_reaction(var/datum/reagents/holder, created_volume)
			var/location = get_turf(holder.my_atom)
			for(var/mob/living/carbon/human/H in location)
				if(ishuman(H))
					if(!H.wear_mask)
						boutput(H, SPAN_ALERT("The acidic vapors burn you!"))
						H.TakeDamage("head", 0, created_volume, 0, DAMAGE_BURN) // WHY??
						H.emote("scream")
			return

	pacid
		name = "Fluorosulfuric Acid" // COGWERKS CHEM REVISION PROJECT: This could be Fluorosulfuric Acid instead
		id = "pacid"
		result = "pacid"
		required_reagents = list("acid" = 1, "fluorine" = 1, "hydrogen" = 1, "potassium" = 1) // tobba chem revision: change to SO3 + HF
		result_amount = 3
		min_temperature = T0C + 100
		mix_phrase = "The mixture deepens to a dark blue, and slowly begins to corrode its container."
		on_reaction(var/datum/reagents/holder, created_volume)
			var/location = get_turf(holder.my_atom)
			for(var/mob/living/carbon/human/H in location)
				if(ishuman(H))
					if(!H.wear_mask)
						boutput(H, SPAN_ALERT("Your face comes into contact with the acidic vapors!"))
						H.TakeDamage("head", 0, created_volume * 3, 0, DAMAGE_BURN) // IT'S ACID IT BURNS
						H.emote("scream")
						if(!H.disfigured)
							boutput(H, SPAN_ALERT("Your face has become disfigured!"))
							H.disfigured = TRUE
							H.UpdateName()
						H.changeStatus("knockdown", 8 SECONDS)
						H:unlock_medal("Red Hood", 1)
			return

	anti_rad // COGWERKS CHEM REVISION PROJECT: marked for revision. Potassium iodide? Prussian Blue?
		name = "Potassium Iodide"
		id = "anti_rad"
		result = "anti_rad"
		required_reagents = list("potassium" = 1, "iodine" = 1)
		result_amount = 2
		mix_phrase = "The solution settles calmly and emits gentle fumes."

	penteticacid // COGWERKS CHEM REVISION PROJECT: marked for revision. Pentetic Acid?
		name = "Pentetic Acid"
		id = "penteticacid"
		result = "penteticacid"
		required_reagents = list("photophosphide" = 1, "ammonia" = 3, "cyanide" = 1) //three parts ammonia because it's easy to make in 30u increments
		// (dichloroethane + ammonia) + formaldehyde (maybe that should be implemented?) + (sodium cyanide) yields EDTA which is almost DPTA
		result_amount = 6 //you get a lot for the pretty complicated precursors
		mix_phrase = "The substance becomes very still, emitting a curious haze."

	acetaldehyde
		name = "Acetaldehyde"
		id = "acetaldehyde"
		result = "acetaldehyde"
		required_reagents = list("chromium" = 1, "oxygen" = 1, "copper" = 1, "ethanol" = 1)
		result_amount = 3
		min_temperature = T0C + 275
		mix_phrase = "It smells like a bad hangover in here."

	acetic_acid
		name = "Acetic Acid"
		id = "acetic_acid"
		result = "acetic_acid"
		required_reagents = list("acetaldehyde" = 1, "oxygen" = 1, "nitrogen" = 4)
		result_amount = 3
		mix_phrase = "It smells like vinegar and a bad hangover in here."

	ether
		name = "Diethyl Ether"
		id = "ether"
		result = "ether"
		required_reagents = list("ethanol" = 1, "clacid" = 1, "oxygen" = 1)
		result_amount = 1
		instant = FALSE
		reaction_speed = 0.5 // Slow-ish by default
		stateful = TRUE
		mix_sound = 'sound/misc/drinkfizz.ogg'
		reaction_icon_color = "#c5d1d3"
		min_temperature = T0C + 30
		mix_phrase = "The mixture yields a pungent odor, which makes you tired."

		does_react(var/datum/reagents/holder) // Reaction will stop at equilibrium between ethanol and ether, can overshoot a bit if warm enough
			if(holder.get_reagent_amount("ether") < holder.get_reagent_amount("ethanol"))
				return TRUE
			else
				return FALSE

		on_reaction(var/datum/reagents/holder, var/created_volume)
			var/location = get_turf(holder.my_atom)
			//reacts faster than normally the hotter the reaction, careful with ether's burn temperature though
			var/ether_mix_speed = max((holder.total_temperature - (T0C + 30))/4, 1)
			//since this portion of the reaction does not consume acid/oxygen, we got to seperatly calculate the volume-depending-factor of this reaction
			ether_mix_speed *= 1 + src.get_volume_reaction_speed_factor(holder)
			holder.add_reagent("ether", ether_mix_speed, temp_new = holder.total_temperature, chemical_reaction = TRUE)
			holder.remove_reagent("ethanol", ether_mix_speed)
			if(holder?.my_atom?.is_open_container())
				reaction_icon_state = list("reaction_smoke-1", "reaction_smoke-2")
				var/datum/reagents/smokeContents = new/datum/reagents/
				smokeContents.add_reagent("ether", created_volume * 2)
				smoke_reaction(smokeContents, 2, location, do_sfx = FALSE)

			else
				reaction_icon_state = list("reaction_bubble-1", "reaction_bubble-2")
				holder.add_reagent("ether", created_volume * 2) // You get to keep what would have been in the smoke

	ether_offgas
		name = "Ether Offgas"
		id = "ether_offgas"
		required_reagents = list("ether" = 0) // Removed in on_reaction
		result_amount = 1
		mix_phrase = "The mixture slowly gives off fumes."
		mix_sound = null
		instant = FALSE
		reaction_speed = 1
		stateful = TRUE
		min_temperature = T0C + 30 // Generates vapor above room temperature
		reaction_icon_color = "#c5d1d3"
		var/count = 0
		var/amount_to_smoke = 1

		does_react(var/datum/reagents/holder)
			if (holder.my_atom && holder.my_atom.is_open_container() || (istype(holder,/datum/reagents/fluid_group) && !holder.is_airborne()))
				return TRUE
			else
				return FALSE

		on_reaction(var/datum/reagents/holder, var/created_volume)
			amount_to_smoke = created_volume
			if(count < 6)
				count++
				reaction_icon_state = null
			else
				var/location = get_turf(holder.my_atom)
				reaction_icon_state = list("reaction_smoke-1", "reaction_smoke-2")
				var/datum/reagents/smokeContents = new/datum/reagents/
				smokeContents.add_reagent("ether", amount_to_smoke)
				smoke_reaction(smokeContents, 1, location, do_sfx = FALSE)
				holder.remove_reagent("ether", amount_to_smoke)
				count = 0

	cyclopentanol
		name = "Cyclopentanol"
		id = "cyclopentanol"
		result = "cyclopentanol"
		min_temperature = T0C + 50
		required_reagents = list("acetic_acid" = 1, "ether" = 1, "barium" = 1, "hydrogen" = 1, "oxygen" = 1)
		result_amount = 3
		mix_phrase = "The mixture fizzles into a colorless liquid."

	kerosene
		name = "Kerosene"
		id = "kerosene"
		result = "kerosene"
		min_temperature = T0C + 550
		required_reagents = list("cyclopentanol" = 1, "oxygen" = 3, "acetone" = 1, "hydrogen" = 1, "aluminium" = 1, "nickel" = 1)
		result_amount = 3
		mix_phrase = "This pungent odor could probably melt steel."
		hidden = TRUE

	formaldehyde
		name = "Embalming fluid"
		id = "formaldehyde"
		result = "formaldehyde"
		required_reagents = list("ethanol" = 1, "oxygen" = 1, "silver" = 1)
		//ethanol as methanol, oxidized with a silver catalyst
		min_temperature = T0C + 150 // really more like 620 but fuck it
		result_amount = 2
		mix_phrase = "Ugh, it smells like the morgue in here."

	haloperidol // COGWERKS CHEM REVISION PROJECT: marked for revision - antipsychotic
		name = "Haloperidol"
		id = "haloperidol"
		result = "haloperidol"
		required_reagents = list("chlorine" = 1, "fluorine" = 1, "aluminium" = 1, "anti_rad" = 1, "oil" = 1)
		//min_temperature = 320
		result_amount = 4
		mix_phrase = "The chemicals mix into an odd pink slush."

	silver_sulfadiazine // COGWERKS CHEM REVISION PROJECT: marked for revision. maybe something like Silvadene?
		name = "silver sulfadiazine"
		id = "silver_sulfadiazine"
		eventual_result = "silver_sulfadiazine"
		required_reagents = list("chlorine" = 1, "ammonia" = 1) // more required in does_react(), multiple recipes possible...
		inhibitors = list("water") //an easily removable way to stop the reaction whenever you want
		stateful = TRUE
		instant = FALSE
		reaction_speed = 1
		result_amount = 1
		mix_phrase = "A strong and cloying odor begins to bubble from the mixture."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		var/amount_to_mix = 0 //how much it mixes at the end, depends on what you put in it during mixing
		var/mix_multiplier = 1
		var/cycles = 1 //how long has the reaction been going on for

		does_react(var/datum/reagents/holder)
			if(holder.has_reagent("silver_nitrate"))
				return TRUE
			if(holder.has_reagent("oxygen") && holder.has_reagent("silver") && holder.has_reagent("sulfur"))
				return TRUE
			else
				return FALSE

		on_reaction(var/datum/reagents/holder, var/created_volume)
			src.cycles++
			if(holder.has_reagent("oil")) //bonus multiplier for adding in an unnecessary chem
				mix_multiplier = 1.5
				holder.remove_reagent("oil", created_volume/2)
			else
				mix_multiplier = 1
			if(cycles >= 50 && cycles < 70) //after 50 cycles you get double the product, until...
				reaction_icon_state = list("reaction_sparkle-1", "reaction_sparkle-2")
				reaction_icon_color = "#f3e993"
				mix_multiplier *= 2
			if(cycles >= 70) //...after 70 it stops producing extra altogether (TO:DO add a visual effect to both stages later)
				reaction_icon_state = list("reaction_puff-1", "reaction_puff-2")
				reaction_icon_color = "#757575"
				mix_multiplier = 0
			if(holder.has_reagent("silver_nitrate"))
				amount_to_mix += (10 * created_volume * mix_multiplier) //you get a lot of extra for putting in the harder chem
				holder.remove_reagent("silver_nitrate", created_volume)
			else
				amount_to_mix += (5 * created_volume * mix_multiplier)
				holder.remove_reagent("oxygen", created_volume)
				holder.remove_reagent("silver", created_volume)
				holder.remove_reagent("sulfur", created_volume)

		on_end_reaction(var/datum/reagents/holder)
			holder.add_reagent("silver_sulfadiazine", amount_to_mix, temp_new = holder.total_temperature, chemical_reaction = TRUE)
			playsound(get_turf(holder.my_atom), 'sound/effects/bubbles.ogg', 25, 1)

	/*
	silver_sulfadiazine/silver_sulfadiazine2
		id = "silver_sulfadiazine2"
		required_reagents = list("silver" = 1, "sulfur" = 1, "oxygen" = 1, "weedkiller" = 3)
		result_amount = 5
	*/
	charcoal // antitoxin
		name = "Activated Charcoal"
		id = "charcoal"
		result = "charcoal"
		required_reagents = list("carbon" = 1, "ash" = 1)
		inhibitors = list("steam" = 2)
		min_temperature = T0C + 140 //irl this needs to be much, much hotter than this but this will be fine for the game, and less annoying to cool for medical use
		result_amount = 1
		instant = FALSE
		reaction_speed = 5
		temperature_change = -5
		mix_phrase = "The mixture yields a fine black powder."
		mix_sound = 'sound/misc/fuse.ogg'

		on_reaction(datum/reagents/holder, created_volume)
			holder.add_reagent("steam", created_volume)

	charcoal_steam //higher quality activated charcoal can be made irl with steam so this kinda fits
		name = "Steam Activated Charcoal"
		id = "charcoal_steam"
		result = "charcoal"
		required_reagents = list("carbon" = 1, "ash" = 1, "steam" = 2)
		result_amount = 4 //no 'quality' system, so instead you get more yield
		instant = FALSE
		reaction_speed = 10
		temperature_change = -10
		mix_phrase = "The mixture yields a fine black powder."
		mix_sound = 'sound/misc/fuse.ogg'

	teporone // COGWERKS CHEM REVISION PROJECT: marked for revision - magic drug
		name = "Teporone"
		id = "teporone"
		result = "teporone"
		required_reagents = list("silicon" = 1, "acetone" = 1, "plasma" = 1)
		result_amount = 2
		mix_phrase = "The mixture turns an odd lavender color."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	promethazine
		name = "Promethazine"
		id = "promethazine"
		result = "promethazine"
		required_reagents = list("oil" = 1, "ammonia" = 1, "sulfur" = 1, "cleaner" = 1)
		result_amount = 4
		mix_phrase = "The solution settles into a fine odorless powder."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	epinephrine
		name = "Epinephrine"
		id = "epinephrine"
		result = "epinephrine"
		required_reagents = list("phenol" = 1, "hydrogen" = 1, "oxygen" = 1, "chlorine" = 1, "acetone" = 1, "diethylamine" = 1)
		result_amount = 4
		mix_phrase = "Tiny white crystals precipitate out of the solution."
		mix_sound = 'sound/misc/drinkfizz.ogg'


	atropine // COGWERKS CHEM REVISION PROJECT: maybe atropine, and give it a useful function in medbay?
		name = "Atropine"
		id = "atropine"
		result = "atropine"
		required_reagents = list("ethanol" = 1, "diethylamine" = 1, "acetone" = 1, "phenol" = 1, "acid" = 1)
		result_amount = 4
		mix_phrase = "A horrid smell like something died drifts from the mixture."

	/*omnizine // COGWERKS CHEM REVISION PROJECT: magic bullshit drug, ought to involve plasma. far too easy to make right now
		name = "omnizine"
		id = "omnizine"
		result = "omnizine"
		required_reagents = list("epinephrine" = 1, "charcoal" = 1)
		result_amount = 2
		mix_phrase = "The mixture seems to slosh around on its own, fizzing violently."*/

	oculine
		name = "Oculine"
		id = "oculine"
		result = "oculine"
		required_reagents = list("atropine" = 1, "saline" = 1, "spaceacillin" = 1)
		result_amount = 4
		mix_phrase = "The mixture settles, becoming a milky white."

	mannitol // COGWERKS CHEM REVISION PROJECT: maybe this could be Mannitol, side effect: makes u pee?
		name = "Mannitol"
		id = "mannitol"
		result = "mannitol"
		required_reagents = list("sugar" = 1, "hydrogen" = 1, "water" = 1)
		//min_temperature = T0C + 150
		result_amount = 2
		mix_phrase = "The mixture bubbles slowly, making a slightly sweet odor."

	salbutamol_salicylic_acid // makes either based on input, not both at once though
		name = "Salbutamol Salicylic Acid"
		id = "salbutamol_salicylic_acid"
		required_reagents = list("sodium" = 0, "phenol" = 0, "carbon" = 0, "oxygen" = 0)
		result = null //this changes in on_reaction
		//technically it's either or, but for the purposes of the request console this makes both
		eventual_result = list("salbutamol", "salicylic_acid")
		result_amount = 4
		instant = FALSE
		reaction_volume_dependant = FALSE
		reaction_speed = 4
		temperature_change = 0 //this also changes
		stateful = TRUE
		mix_phrase = "The solution twirls and mixes together idley."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		reaction_icon_state = list("reaction_puff-1", "reaction_puff-2")
		reaction_icon_color = "#ffffff"
		var/was_physically_shocked = FALSE
		var/flash_cooldown = 0 //to prevent messups from spamming flashbang effects
		var/consecutive_shocks = 0 //for salb: gives you bonus for chains of physical shocks maintained
		var/highest_heat = 0 //for salicylic acid: gives you bonus as long as you keep gaining heat

		on_reaction(var/datum/reagents/holder, var/created_volume)
			if(flash_cooldown > 0)
				flash_cooldown--

			if(result == "salbutamol")
				reaction_icon_state = list("reaction_bubble-1", "reaction_bubble-2")
				reaction_icon_color = "#47cbff"
				if(holder.total_temperature >= T100C)
					reaction_icon_state = list("reaction_puff-1", "reaction_puff-2")
					reaction_icon_color = "#474747"
					for(var/reagent in required_reagents)
						holder.remove_reagent(reagent, 5)
					holder.remove_reagent("salbutamol", 5)
					if(flash_cooldown <= 0)
						for(var/mob/M in AIviewers(null, get_turf(holder.my_atom)))
							boutput(M, SPAN_ALERT("The reaction pops and fizzles abruptly!"))
						flashpowder_reaction(get_turf(holder.my_atom), 10)
						flash_cooldown = 5
				else if(was_physically_shocked) //else if... if you overheat the reaction, no bonus for you!
					was_physically_shocked = FALSE
					consecutive_shocks++
					var/amount_to_add = round(was_physically_shocked/3) //one extra unit per 3 times shocked
					holder.add_reagent("salbutamol", amount_to_add, temp_new = holder.total_temperature, chemical_reaction = TRUE)
					playsound(get_turf(holder.my_atom), 'sound/effects/bubbles_short.ogg', 50, 1)
				if(!was_physically_shocked)
					consecutive_shocks = 0

			else if(result == "salicylic_acid")
				reaction_icon_state = list("reaction_sparkle-1", "reaction_sparkle-2")
				reaction_icon_color = "#eb5c5c"
				if(was_physically_shocked)
					reaction_icon_state = list("reaction_puff-1", "reaction_puff-2")
					reaction_icon_color = "#474747"
					for(var/reagent in required_reagents)
						holder.remove_reagent(reagent, 5)
					holder.remove_reagent("salicylic_acid", 5)
					if(flash_cooldown <= 0)
						for(var/mob/M in AIviewers(null, get_turf(holder.my_atom)))
							boutput(M, SPAN_ALERT("The reaction pops and fizzles abruptly!"))
						flashpowder_reaction(get_turf(holder.my_atom), 10)
						flash_cooldown = 5
				else if(holder.total_temperature > highest_heat + 3) //you have to get at least three degrees hotter than before
					playsound(get_turf(holder.my_atom), 'sound/effects/bubbles_short.ogg', 50, 1)
					highest_heat = holder.total_temperature
					holder.add_reagent("salicylic_acid", 3, temp_new = holder.total_temperature, chemical_reaction = TRUE)

			else//neither salb or salicylic, so we're at the start of the reaction
				if(was_physically_shocked)
					was_physically_shocked = FALSE
					for(var/mob/M in AIviewers(null, get_turf(holder.my_atom)))
						boutput(M, SPAN_NOTICE("The solution begins to release warm cyan bubbles."))
					playsound(get_turf(holder.my_atom), 'sound/effects/bubbles_short.ogg', 50, 1)
					result = "salbutamol"
					temperature_change = 3
				if(holder.total_temperature > T100C)
					for(var/mob/M in AIviewers(null, get_turf(holder.my_atom)))
						boutput(M, SPAN_NOTICE("The mixture glistens with red sparkles."))
					playsound(get_turf(holder.my_atom), 'sound/effects/bubbles_short.ogg', 50, 1)
					result = "salicylic_acid"
					temperature_change = -3

			if (result) //manually remove reagents only if we're actually reacting
				for (var/reagent_id in src.required_reagents)
					holder.remove_reagent(reagent_id, 1)

		physical_shock(var/force, var/datum/reagents/holder)
			if(force > 3)
				was_physically_shocked = TRUE

	perfluorodecalin // COGWERKS CHEM REVISION PROJECT:marked for revision
		name = "Perfluorodecalin"
		id = "perfluorodecalin"
		result = "perfluorodecalin"
		required_reagents = list("hydrogen" = 1, "fluorine" = 1, "salicylic_acid" = 1)
		min_temperature = T0C + 100
		// hydrogenate napthalene, then fluorinate
		result_amount = 2 // lowered because the recipe is very easy
		mix_phrase = "The mixture rapidly turns into a dense pink liquid."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	photophosphide //photosensitive explosive : )
		name = "Photophosphide"
		id = "photophosphide"
		result = "photophosphide"
		required_reagents = list("plasma" = 1, "phosphorus" = 1, "iron" = 1, "diethylamine" = 1)
		result_amount = 1 //you only need low amounts anyways
		mix_phrase = "The mixture yields a dull purple powder."
		mix_sound = 'sound/misc/fuse.ogg'

	photophosphide_light_reaction //check for light, explode if light
		name = "Photophosphide Light Reaction"
		id = "photophosphide_light_reaction"
		required_reagents = list("photophosphide")
		result_amount = 1
		mix_phrase = null
		mix_sound = null
		reaction_icon_state = null
		hidden = TRUE
		instant = FALSE
		reaction_volume_dependant = FALSE
		stateful = TRUE
		var/is_currently_exploding = FALSE //so it doesn't explode multiple times during the slight activation delay

		on_reaction(var/datum/reagents/holder, var/created_volume)
			if(src.is_currently_exploding)
				return
			var/turf/T = get_turf(holder.my_atom)
			if (istype(T) && T.is_lit(0.1) && !istype(holder.my_atom.loc, /obj/disposalholder))
				var/obj/particle/chemical_shine/shine = new /obj/particle/chemical_shine
				is_currently_exploding = TRUE
				shine.set_loc(T)
				playsound(get_turf(holder.my_atom), 'sound/effects/sparks6.ogg', 50, 1) //this could be better with a bespoke sound eventually, didn't want to steal vampire glare sound but similar-ish?
				SPAWN(6 DECI SECONDS) //you get a slight moment to react/be surprised
					T = get_turf(holder.my_atom) //may have moved
					qdel(shine)
					holder.del_reagent("photophosphide")
					explosion(holder.my_atom, T, -1,-1,0,1)
					playsound(T, 'sound/effects/Explosion1.ogg', 50, 1)
					fireflash(T, 0, chemfire = CHEM_FIRE_RED)
					if(istype(holder.my_atom, /obj))
						var/obj/container = holder.my_atom
						container.shatter_chemically(projectiles = TRUE)

	photophosphide_decay //decays in low amounts
		name = "Photophosphide Decay"
		id = "photophosphide_decay"
		required_reagents = list("photophosphide" = 0)
		instant = FALSE
		result_amount = 1
		reaction_speed = 3
		mix_phrase = "The mixture begins to fade away quickly with dim flashes."

		does_react(var/datum/reagents/holder)
			if(holder.get_reagent_amount("photophosphide") < 10)
				return TRUE
			else
				return FALSE

		on_reaction(var/datum/reagents/holder, var/created_volume)
			holder.remove_reagent("photophosphide", created_volume)

	styptic_powder // COGWERKS CHEM REVISION PROJECT: no idea, probably a magic drug
		name = "Styptic Powder"
		id = "styptic_powder"
		eventual_result = "styptic_powder"
		required_reagents = list("aluminium" = 0, "oxygen" = 0, "hydrogen" = 0, "acid" = 0) //reagents removed at the very end of reaction
		result_amount = 1
		mix_phrase = "The solution slowly crackles and reacts."
		instant = FALSE
		reaction_volume_dependant = FALSE
		stateful = TRUE
		var/cycles = 0
		var/extra_to_make = 0
		var/was_physically_shocked = FALSE
		reaction_icon_state = list("reaction_bubble-1", "reaction_bubble-2")
		reaction_icon_color = "#f3a3c2"

		physical_shock(var/force, var/datum/reagents/holder)
			if(!was_physically_shocked && force > 3)
				was_physically_shocked = TRUE
				playsound(get_turf(holder.my_atom), 'sound/effects/bubbles_short.ogg', 50, 1)

		on_reaction(var/datum/reagents/holder, var/created_volume)
			src.cycles++
			reaction_icon_state = list("reaction_bubble-1", "reaction_bubble-2")
			if(was_physically_shocked)
				extra_to_make += 5
				was_physically_shocked = FALSE
				reaction_icon_state = list("reaction_sparkle-1", "reaction_sparkle-2")
			if(cycles >= 30) //not a super long time
				var/amount_to_mix = 0
				amount_to_mix += clamp(holder.get_reagent_amount("aluminium"), 0, 20)
				amount_to_mix += clamp(holder.get_reagent_amount("oxygen"), 0, 20)
				amount_to_mix += clamp(holder.get_reagent_amount("hydrogen"), 0, 20)
				amount_to_mix += holder.get_reagent_amount("acid")
				holder.remove_reagent("aluminium", holder.get_reagent_amount("aluminium"))
				holder.remove_reagent("oxygen", holder.get_reagent_amount("oxygen"))
				holder.remove_reagent("hydrogen", holder.get_reagent_amount("hydrogen"))
				holder.remove_reagent("acid", holder.get_reagent_amount("acid"))
				holder.add_reagent("styptic_powder", (amount_to_mix) + extra_to_make, temp_new = holder.total_temperature, chemical_reaction = TRUE)
				playsound(get_turf(holder.my_atom), 'sound/effects/bubbles.ogg', 25, 1)
				var/location = get_turf(holder.my_atom)
				for(var/mob/M in all_viewers(null, location))
					boutput(M, SPAN_NOTICE("The solution yields an astringent powder."))

	ephedrine
		name = "Ephedrine"
		id = "ephedrine"
		result = "ephedrine"
		required_reagents = list("sugar" = 1, "oil" = 1, "hydrogen" = 1, "diethylamine" = 1)
		result_amount = 3
		mix_phrase = "The solution fizzes and gives off toxic fumes."

	methamphetamine // COGWERKS CHEM REVISION PROJECT: some sort of potent stimulant, could combine with teporone?
		name = "Methamphetamine"
		id = "methamphetamine"
		result = "methamphetamine"
		required_reagents = list("ephedrine" = 1, "phosphorus" = 1, "hydrogen" = 1, "iodine" = 1) // tobba chem revision: change the hydrogen and iodine for hydroiodic acid
		min_temperature = T0C + 100
		result_amount = 3
		mix_phrase = "The solution fizzes and gives off toxic fumes."

		on_reaction(var/datum/reagents/holder, var/created_volume)
			var/location = get_turf(holder.my_atom)
			for(var/mob/M in all_viewers(null, location))
				boutput(M, SPAN_ALERT("The solution generates a strong vapor!"))
			var/list/mob/living/carbon/mobs_affected = list()
			for(var/mob/living/carbon/C in range(location, 1))
				if(!issmokeimmune(C))
					mobs_affected += C
			for(var/mob/living/carbon/C as anything in mobs_affected)
				C.emote("gasp")
				C.losebreath++
				C.reagents.add_reagent("toxin",((0.25 * created_volume) / length(mobs_affected)))
				C.reagents.add_reagent("neurotoxin",((0.5 * created_volume) / length(mobs_affected))) // ~HEH~
			return

	neurodepressant //obtained by breaking down neurotoxin with solvents and heat
		name = "neurodepressant"
		id = "neurodepressant"
		result = "neurodepressant"
		required_reagents = list("acid" = 1, "neurotoxin" = 2, "acetone" = 1)
		result_amount = 2
		min_temperature = T0C + 450
		mix_phrase = "The neurotoxin breaks down, bubbling violently."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	solipsizine
		name = "Solipsizine"
		id = "solipsizine"
		result = "solipsizine"
		required_reagents = list("neurodepressant" = 1, "LSD" = 1, "haloperidol" = 1)
		result_amount = 3

	mutadone // // COGWERKS CHEM REVISION PROJECT: magic bullshit drug, make it involve mutagen
		name = "Mutadone"
		id = "mutadone"
		result = "mutadone"
		required_reagents = list("mutagen" = 1, "acetone" = 1, "bromine" = 1)
		result_amount = 3
		mix_phrase = "A foul astringent liquid emerges from the reaction."

	cryoxadone
		name = "Cryoxadone" // leaving this name alone
		id = "cryoxadone"
		result = "cryoxadone"
		required_reagents = list("cryostylane" = 2, "water" = 2, "platinum" = 1)
		result_amount = 2
		instant = 0
		reaction_speed = 1
		max_temperature = T0C + 50
		mix_phrase = "The solution bubbles as frost precipitates from the sorrounding air."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		reaction_icon_state = list("reaction_ice-1", "reaction_ice-2")
		reaction_icon_color = "#24ccff"

		on_reaction(var/datum/reagents/holder, var/created_volume)
			//that factor of 100 in exposed_volume is apparently a relict of old chemistry code, but whatever. It calculates as if created_volume of the liquid with a 175K lower temperature was added.
			holder.temperature_reagents(max(holder.total_temperature - 175, 1), exposed_volume = created_volume*100, exposed_heat_capacity = holder.composite_heat_capacity, change_min = 1)


	cryostylane
		name = "Cryostylane"
		id = "cryostylane"
		result = "cryostylane"
		required_reagents = list("nitrogen" = 1, "plasma" = 1, "water" = 1) // had a conflict with ammonia recipe
		result_amount = 3
		mix_phrase = "A light layer of frost forms on top of the mixture."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		reaction_icon_state = list("reaction_sparkle-1", "reaction_sparkle-2")
		reaction_icon_color = "#57d8ff"

	spaceacillin
		name = "spaceacillin"
		id = "spaceacillin"
		result = "spaceacillin"
		required_reagents = list("space_fungus" = 1, "ethanol" = 1)
		result_amount = 2
		mix_phrase = "The solvent extracts an antibiotic compound from the fungus."

	mutagen2
		name = "Strange Toxin"
		id = "mutagen2"
		result = "mutagen"
		required_reagents = list("neurotoxin" = 1, "epinephrine" = 1)
		result_amount = 2
		mix_phrase = "An unpleasant, shifting green mass of liquid forms from the reaction."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	initropidril
		name = "initropidril"
		id = "initropidril"
		result = "initropidril"
		//required_reagents = list("crank" = 1, "histamine" = 1, "krokodil" = 1, "bathsalts" = 1, "atropine" = 1, "nicotine" = 1, "morphine" = 1)
		required_reagents = list("triplepissed" = 1, "histamine" = 1, "methamphetamine" = 1, "water_holy" = 1, "pacid" = 1, "neurotoxin" = 1, "stabiliser" = 1)
		result_amount = 4 // lowered slightly
		mix_phrase = "A sweet and sugary scent drifts from the unpleasant milky substance."
		hidden  = TRUE

/*
	initrobeedril_old
		name = "initrobeedril"
		id = "initrobeedril_old"
		result = "initrobeedril_old"
		required_reagents = list("initropidril" = 1, "bee" = 1, "honey" = 1, "dna_mutagen" = 1)
		result_amount = 5
		mix_phrase = "A sweet and sugary scent drifts from the golden substance."
*/
	royal_initrobeedril
		name = "royal initrobeedril"
		id = "royal_initrobeedril"
		result = "royal_initrobeedril"
		required_reagents = list("initropidril" = 1, "bee" = 1, "honey" = 1, "dna_mutagen" = 1, "royal_jelly" = 1)
		result_amount = 5
		min_temperature = T0C + 200
		mix_phrase = "A sweet and sugary scent drifts from the royal purple substance."
		hidden = TRUE

	initrobeedril
		name = "initrobeedril"
		id = "initrobeedril"
		result = "initrobeedril"
		required_reagents = list("initropidril" = 1, "bee" = 1, "honey" = 1, "dna_mutagen" = 1)
		result_amount = 5
		mix_phrase = "A sweet and sugary scent drifts from the golden substance."
		hidden = TRUE

	fake_initropidril
		name = "initropidril"
		id = "fake_initropidril"
		result = "fake_initropidril"
		required_reagents = list("triplepissed" = 1, "histamine" = 1, "methamphetamine" = 1, "water_holy" = 1, "pacid" = 1, "neurotoxin" = 1)
		//required_reagents = list("methamphetamine" = 1, "water_holy" = 1, "pacid" = 1, "neurotoxin" = 1, "formaldehyde" = 1)
		result_amount = 2
		inhibitors = list("stabiliser")
		mix_phrase = "A sweet and sugary scent drifts from the unpleasant milky substance."
		hidden = TRUE
		on_reaction(var/datum/reagents/holder)
			if(prob(90))		// high chance of not working to piss them off
				var/location = get_turf(holder.my_atom)
				for(var/mob/M in AIviewers(null, location))
					boutput(M, SPAN_ALERT("The solution bubbles rapidly but dissipates into nothing!"))
				holder.clear_reagents()
			return

	anti_fart
		name = "Simethicone"
		id = "anti_fart"
		result = "anti_fart"
		required_reagents = list("oxygen" = 1, "chlorine" = 1, "hydrogen" = 1, "silicon" = 1)
		result_amount = 3

	honk_fart
		name = "Honkfartium"
		id = "honk_fart"
		result = "honk_fart"
		required_reagents = list("anti_fart" = 1, "fartonium" = 1)
		min_temperature = T0C + 100
		result_amount = 1
		mix_sound = 'sound/misc/drinkfizz.ogg'
		mix_phrase = "The chemicals hiss and fizz briefly, followed by one big bubble that smells like a fart."

	flash_powder
		name = "Flash Powder"
		id = "flashpowder"
		result = "flashpowder"
		required_reagents = list("aluminium" = 1, "potassium" = 1, "sulfur" = 1, "chlorine" = 1, "stabiliser" = 1)
		result_amount = 1
		mix_phrase = "The chemicals hiss and fizz briefly before falling still."

	flash
		name = "Flash"
		id = "flash"
		required_reagents = list("aluminium" = 1, "potassium" = 1, "sulfur" = 1, "chlorine" = 1 )
		inhibitors = list("stabiliser")
		instant = 1
		mix_phrase = "The chemicals catch fire, burning brightly and violently!"
		mix_sound = 'sound/weapons/flashbang.ogg'
		hidden = TRUE

		on_reaction(var/datum/reagents/holder, var/created_volume)
			if (holder?.my_atom)
				flashpowder_reaction(get_turf(holder.my_atom), created_volume)
			else
				var/amt = max(1, (holder.covered_cache.len * (created_volume / holder.covered_cache_volume)))
				for (var/i = 0, i < amt && holder.covered_cache.len, i++)
					flashpowder_reaction(get_turf(pick(holder.covered_cache)), created_volume)

	sonic_powder
		name = "Hootingium"
		id = "sonicpowder"
		result = "sonicpowder"
		required_reagents = list("oxygen" = 1, "cola" = 1, "phosphorus" = 1, "stabiliser" = 1)
		result_amount = 1
		mix_phrase = "The mixture begins to bubble slighly!"

	sonic_boom //The "bang" part of "flashbang"
		name = "Hootingium"
		id = "sonic_boom"
		required_reagents = list("oxygen" = 1, "cola" = 1, "phosphorus" = 1)
		inhibitors = list("stabiliser")
		instant = 1
		mix_phrase = "The mixture begins to bubble furiously!"
		mix_sound = 'sound/weapons/flashbang.ogg'
		hidden = TRUE

		on_reaction(var/datum/reagents/holder, var/created_volume)
			var/hootmode = prob(5)
			var/turf/location = 0

			if (holder?.my_atom)
				location = get_turf(holder.my_atom)
				sonicpowder_reaction(location, created_volume, hootmode, FALSE)
			else
				var/amt = max(1, (holder.covered_cache.len * (created_volume / holder.covered_cache_volume)))
				var/sound_plays = 4
				created_volume /= amt
				for (var/i = 0, i < amt && holder.covered_cache.len, i++)
					location = pick(holder.covered_cache)
					holder.covered_cache -= location
					sonicpowder_reaction(location, created_volume, hootmode, sound_plays-- > 4)

	chlorine_azide  // death 2 chemists
		name = "Chlorine Azide"
		id = "chlorine_azide"
		result = null
		required_reagents = list("sodium" = 1, "ammonia" = 1, "nitrogen" = 1, "oxygen" = 1, "silver" = 1, "chlorine" = 1)
		instant = 1
		mix_phrase = "The substance violently detonates!"
		mix_sound = 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg'
		hidden = TRUE
		on_reaction(var/datum/reagents/holder, var/created_volume)
			var/atom/my_atom = holder.my_atom

			var/turf/location = 0
			if (my_atom)
				location = get_turf(my_atom)
				explosion(my_atom, location, 0, 1, 4, 5)
				if(istype(holder.my_atom, /obj))
					var/obj/container = holder.my_atom
					container.shatter_chemically(projectiles = TRUE)
			else
				var/amt = max(1, (holder.covered_cache.len * (created_volume / holder.covered_cache_volume)))
				for (var/i = 0, i < amt && holder.covered_cache.len, i++)
					location = pick(holder.covered_cache)
					holder.covered_cache -= location
					explosion_new(my_atom, location, 3.4/amt, 2/amt)
			return

	clf3_firefoam
		name = "CLF3 + FF Explosion"
		id = "clf3_firefoam"
		result = null
		required_reagents = list("infernite" = 1, "ff-foam" = 1)
		instant = 1
		mix_phrase = "The substance violently detonates!"
		mix_sound = 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg'
		hidden = TRUE
		on_reaction(var/datum/reagents/holder, var/created_volume)
			var/atom/my_atom = holder.my_atom

			var/turf/location = 0
			if (my_atom)
				location = get_turf(my_atom)
				explosion(my_atom, location, -1, 0, 2, 3)
				if(istype(holder.my_atom, /obj))
					var/obj/container = holder.my_atom
					container.shatter_chemically(projectiles = TRUE)
			else
				var/amt = max(1, (holder.covered_cache.len * (created_volume / holder.covered_cache_volume)))
				for (var/i = 0, i < amt && holder.covered_cache.len, i++)
					location = pick(holder.covered_cache)
					holder.covered_cache -= location
					explosion_new(my_atom, location, 2.25/amt, 0.8/amt)

			return

	anima //Consume max health on nearby people. also stamina. also requires alchemy circle and stone.
		name = "Anima"
		id = "anima"
		required_reagents = list("strange_reagent" = 1, "bloodc" = 1, "blood"=1, "ldmatter" = 1, "ectoplasm" = 1)
		instant = 1
		mix_phrase = null
		mix_sound = 'sound/effects/ghostbreath.ogg'
		hidden = TRUE

		on_reaction(var/datum/reagents/holder, var/created_volume)
			var/my_atom = holder.my_atom
			if(!my_atom) return
			var/turf/reaction_loc = get_turf(my_atom)
			if(!reaction_loc) return

			if( (locate(/obj/alchemy/circle) in range(3,reaction_loc)) )
				reaction_loc.visible_message(SPAN_ALERT("[bicon(my_atom)] The mixture turns into pure energy which promptly flows into the alchemy circle."))
				var/gathered = 0
				for(var/mob/living/M in view(5,reaction_loc))
					boutput(M, SPAN_ALERT("You feel a wracking pain as some of your life is ripped out.")) //Anima ravages the soul, but doesn't actually remove any part of it, so it's still saleable to Zoldorf
					gathered += round(M.max_health / 2)
					var/datum/statusEffect/maxhealth/decreased/current_status = M.hasStatus("maxhealth-")
					var/old_maxhealth_decrease = current_status ? current_status.change : 0
					M.setStatus("maxhealth-", null, old_maxhealth_decrease - round(M.max_health / 2))

					health_update_queue |= M
					if(hascall(M,"add_stam_mod_max"))
						M:add_stam_mod_max("anima_drain", -25)
				if(gathered >= 80)
					reaction_loc.visible_message(SPAN_ALERT("[bicon(my_atom)] As the alchemy circle rips the life out of everyone close to it, energies escape it and settle in the [my_atom]."))
					holder.add_reagent("anima",50, chemical_reaction = TRUE)
					if (!particleMaster.CheckSystemExists(/datum/particleSystem/swoosh, my_atom))
						particleMaster.SpawnSystem(new /datum/particleSystem/swoosh(my_atom))
				else
					reaction_loc.visible_message(SPAN_ALERT("[bicon(my_atom)] The alchemy circle briefly glows before fading back to normal. It seems like it couldn't gather enough energy."))
			else
				reaction_loc.visible_message(SPAN_ALERT("[bicon(my_atom)] The mixture turns into pure energy which quickly disperses. It needs to be channeled somehow."))
			return

	phlogiston
		name = "Phlogiston"
		id = "phlogiston"
		result = "phlogiston"
		required_reagents = list("phosphorus" = 1, "plasma" = 1, "acid" = 1, "stabiliser" = 1 )
		result_amount = 4
		mix_phrase = "The substance becomes sticky and extremely warm."
		reaction_icon_state = list("reaction_fire-1", "reaction_fire-2")
		reaction_icon_color = "#ffffff"

	firedust
		name = "Phlogiston Dust"
		id = "firedust"
		result = "firedust"
		required_reagents = list("phlogiston" = 1, "charcoal" = 1, "phosphorus" = 1, "sulfur" = 1)
		result_amount = 2
		mix_phrase = "The substance becomes a pile of burning dust."
		reaction_icon_state = list("reaction_fire-1", "reaction_fire-2")
		reaction_icon_color = "#ffffff"

	napalmfire //This MUST be above the smoke recipe. Trust me on that one. IT affects the internal order of the recipes.
		name = "Phlogiston Fire"
		id = "phlogiston"
		result = "phlogiston"
		required_reagents = list("phosphorus" = 1, "plasma" = 1, "acid" = 1 )
		inhibitors = list("stabiliser")
		instant = 1
		mix_phrase = "The substance erupts into wild flames."
		reaction_icon_state = list("reaction_explosion-1", "reaction_explosion-2")
		reaction_icon_color = "#ffffff"
		on_reaction(var/datum/reagents/holder, var/created_volume)
			var/turf/location = 0
			if (holder?.my_atom)
				location = get_turf(holder.my_atom)
				fireflash(location, clamp(round(created_volume/10), 2, 8), chemfire = CHEM_FIRE_RED) // This reaction didn't have an upper cap, uh-oh (Convair880).
			else
				var/amt = max(1, (holder.covered_cache.len * (created_volume / holder.covered_cache_volume)))
				for (var/i = 0, i < amt && holder.covered_cache.len, i++)
					location = pick(holder.covered_cache)
					holder.covered_cache -= location
					fireflash(location, clamp(round(created_volume/10), 2, 8)/amt, chemfire = CHEM_FIRE_RED)
			return

	napalm_goo
		name = "Napalm"
		id = "napalm_goo"
		result = "napalm_goo"
		required_reagents = list("fuel" = 1, "sugar" = 1, "ethanol" = 1)
		result_amount = 3
		mix_phrase = "The mixture congeals into a sticky gel."


	big_bang_precursor
		name = "stable bose-einstein macro-condensate"
		id = "big_bang_precursor"
		result = "big_bang_precursor"
		#ifdef SECRETS_ENABLED
			// It's secret now bucko
		#else
		required_reagents = list("ldmatter" = 1, "voltagen" = 12, "something" = 3, "sorium" = 1)
		result_amount = 1
		#endif
		hidden = TRUE
		mix_phrase = "The solution settles and congeals into a strange viscous fluid that seems to have the properties of both a liquid and a gas."
		max_temperature = 0


	aerosol  //aerosol's reaction when crossing the heat threshold
		name = "Aerosol"
		id   = "aerosolheat"
		required_reagents = list("propellant" = 1)
		result_amount = 1
		mix_phrase = "The mixture quickly turns into a pall of smoke!"
		hidden = TRUE
		min_temperature = T0C + 100

		does_react(var/datum/reagents/holder) //making sure it doesn't smoke itself while inside a closed container
			if (holder.my_atom && holder.my_atom.is_open_container() || istype(holder,/datum/reagents/fluid_group))
				return TRUE
			else
				return FALSE

		on_reaction(var/datum/reagents/holder, var/created_volume)
			if (holder)
				SPAWN(1 DECI SECOND)
					holder.smoke_start(created_volume,classic = 1)

	smokepowder
		name = "Smoke Powder"
		id = "smokepowder"
		result = "smokepowder"
		required_reagents = list("potassium" = 1, "sugar" = 1, "phosphorus" = 1, "stabiliser" = 1)
		result_amount = 3
		mix_phrase = "The mixture sets into a greyish powder!"
#ifdef CHEM_REACTION_PRIORITIES
		priority = 9
#endif

	smokeheat  //smoke powder's reaction when crossing the heat threshold
		name = "Smoke Heat"
		id   = "smokeheat"
		required_reagents = list("smokepowder" = 1)
		result_amount = 1
		mix_phrase = "The mixture quickly turns into a pall of smoke!"
		hidden = TRUE
		min_temperature = T0C + 25

		does_react(var/datum/reagents/holder) //making sure it doesn't smoke itself while inside a closed container
			if (holder.my_atom && holder.my_atom.is_open_container() || istype(holder,/datum/reagents/fluid_group))
				return TRUE
			else
				return FALSE

		on_reaction(var/datum/reagents/holder, var/created_volume)
			if (holder)
				holder.smoke_start(created_volume)

	smoke
		name = "Smoke"
		id = "smoke"
		required_reagents = list("potassium" = 1, "sugar" = 1, "phosphorus" = 1)
		inhibitors = list("stabiliser")
		instant = 1
		consume_all = 1
		result_amount = 3
		mix_phrase = "The mixture quickly turns into a pall of smoke!"
		hidden = TRUE
#ifdef CHEM_REACTION_PRIORITIES
		priority = 9
#endif
		does_react(var/datum/reagents/holder) //making sure it doesn't smoke itself while inside a closed container
			if (holder.my_atom && holder.my_atom.is_open_container() || istype(holder,/datum/reagents/fluid_group))
				return TRUE
			else
				return FALSE

		on_reaction(var/datum/reagents/holder, var/created_volume) //moved to a proc in Chemistry-Holder.dm so that the instant reaction and powder can use the same proc
			holder.del_reagent("smokepowder") //no
			if (holder)
				holder.smoke_start(created_volume)

	blackpowder // oh no
		name = "Black Powder"
		id = "blackpowder"
		result = "blackpowder"
		required_reagents = list("charcoal" = 1, "sulfur" = 1, "saltpetre" = 1)
		result_amount = 3
		mix_phrase = "The mixture yields a granular black powder."
		mix_sound = 'sound/misc/fuse.ogg'


	stabiliser
		name = "Stabilising Agent"
		id = "stabiliser"
		result = "stabiliser"
		required_reagents = list("iron" = 1, "hydrogen" = 1, "oxygen" = 1)
		result_amount = 2
		mix_phrase = "The mixture becomes a yellow liquid!"

	potash1
		name = "potash"
		id = "potash1"
		result = "potash"
		required_reagents = list("ash" = 1, "water" = 1)
		min_temperature = T0C + 80
		result_amount = 1
		mix_phrase = "A white crystalline residue forms as the water boils off."

	potash2
		name = "potash"
		id = "potash2"
		result = "potash"
		required_reagents = list("potassium" = 1, "chlorine" = 1, "acid" = 1)
		result_amount = 2
		mix_phrase = "The mixture yields a white crystalline compound."

	slow_saltpetre
		name = "slow saltpetre"
		id = "slow_saltpetre"
		result = "saltpetre"
		// fungus turns compost into ammonium
		// compost bacteria turns ammonium into nitrates
		// nitrates are extracted from "soil" with water
		// potash purifies nitrates into saltpetre
		required_reagents = list("nitrogen" = 1, "poo" = 1, "potash" = 1)
		result_amount = 1
		instant = 0 // Potash filtering takes time.
		reaction_speed = 1
		mix_phrase = "A putrid odor pours from the mixture as a white crystalline substance leaches into the water."
		mix_sound = 'sound/misc/fuse.ogg'

		on_reaction(var/datum/reagents/holder, var/created_volume)
			// water byproduct
			// some nitrification processes create additional water.
			holder.add_reagent("water", created_volume,,holder.total_temperature, chemical_reaction = TRUE, chem_reaction_priority = 2)
			// disgusting
			var/turf/location = pick(holder.covered_turf())
			location.fluid_react_single("miasma", created_volume, airborne = 1)

	lungrot
		name = "lungrot"
		id = "lungrot"
		result = "lungrot_bloom"
		// this reaction is a reference to salbutamol inhalers being a risk factor in getting oral thrush.
		// Of course in RL, this is harmless for most people (so please take your meds), but we're in spaaaaaaaaceeeee!
		required_reagents = list("salbutamol" = 0.1, "miasma" = 1)
		result_amount = 1
		instant = 0
		reaction_speed = 0.5
		//since we are talking about contraction of miasma on weakened lung tissue, make some common antibiotics prevent this
		inhibitors = list("cold_medicine")
		// no mixing sound or message. With lungrot decaying into miasma that would create a mass of message spam. And it should be kinda stealthy
		mix_phrase = null
		mix_sound = null

		does_react(var/datum/reagents/holder)
			//This reaction does only happen in carbon-based beings and for only as long as there is less than 15u lungrot in the person
			return holder.my_atom && iscarbon(holder.my_atom) && (holder.get_reagent_amount("lungrot_bloom") < 15)


	/*plant_nutrients_mutagenic
		name = "Mutriant Plant Formula"
		id = "plant_nutrients_muta"
		result = "plant_nutrients_muta"
		required_reagents = list("saltpetre" = 1, "anti_rad" = 1, "radium" = 1)
		result_amount = 3
		mix_phrase = "A strange odor comes from the resultant greenish goo."
		mix_sound = 'sound/impact_sounds/Slimy_Hit_4.ogg'

	plant_nutrients_quickgrow
		name = "Gro-Boost Plant Formula"
		id = "plant_nutrients_grow"
		result = "plant_nutrients_grow"
		required_reagents = list("saltpetre" = 1, "styptic_powder" = 1, "salbutamol" = 1)
		result_amount = 3
		mix_phrase = "The mixture smells earthy and yet strange."
		mix_sound = 'sound/impact_sounds/Slimy_Hit_4.ogg'

	plant_nutrients_cropyield
		name = "Top Crop Plant Formula"
		id = "plant_nutrients_crop"
		result = "plant_nutrients_crop"
		required_reagents = list("saltpetre" = 1, "charcoal" = 1, "antihol" = 1)
		result_amount = 3
		mix_phrase = "The substance dissolves into a thick silty soup."
		mix_sound = 'sound/impact_sounds/Slimy_Hit_4.ogg'

	plant_nutrients_potency
		name = "Powerplant Plant Formula"
		id = "plant_nutrients_potency"
		result = "plant_nutrients_potency"
		required_reagents = list("saltpetre" = 1, "silver_sulfadiazine" = 1, "methamphetamine" = 1)
		result_amount = 3
		mix_phrase = "A pungent and powerful earthy odor comes from the mixture."
		mix_sound = 'sound/impact_sounds/Slimy_Hit_4.ogg'

	plant_nutrients_balance
		name = "Fruitful Farming Plant Formula"
		id = "plant_nutrients_balance"
		result = "plant_nutrients_balance"
		required_reagents = list("saltpetre" = 1, "epinephrine" = 1, "teporone" = 1)
		result_amount = 3
		mix_phrase = "A calming, coffee-like scent comes from the dirt-like mixture."
		mix_sound = 'sound/impact_sounds/Slimy_Hit_4.ogg' */

	weedkiller
		name = "Atrazine"
		id = "weedkiller"
		result = "weedkiller"
		required_reagents = list("chlorine" = 1, "nitrogen" = 1, "hydrogen" = 1)
		result_amount = 3
		mix_phrase = "The mixture gives off a harsh odor."

	copper_nitrate
		name = "Copper Nitrate"
		id = "copper_nitrate"
		result = "copper_nitrate"
		required_reagents = list("copper" = 1, "nitrogen" = 1, "oxygen" = 3)
		result_amount = 1
		mix_phrase = "The mixture forms into a blue crystalline solid."

	nitrogen_dioxide
		name = "Nitrogen Dioxide"
		id = "nitrogen_dioxide"
		result = "nitrogen_dioxide"
		required_reagents = list("copper_nitrate" = 1)
		min_temperature = T0C + 180
		result_amount = 2
		mix_phrase = "The mixture gives off a biting odor."
		on_reaction(var/datum/reagents/holder, created_volume)
			holder.add_reagent("oxygen", created_volume,, holder.total_temperature, chemical_reaction = TRUE, chem_reaction_priority = 2)

	nitric_acid
		name = "Nitric Acid"
		id = "nitric_acid"
		result = "nitric_acid"
		required_reagents = list("water" = 1, "nitrogen_dioxide" = 3)
		result_amount = 2
		mix_phrase = "The mixture gives off a sharp acidic tang."
		on_reaction(var/datum/reagents/holder, created_volume)
			var/location = get_turf(holder.my_atom)
			for (var/mob/living/carbon/human/H in location)
				if (ishuman(H))
					if (!H.wear_mask)
						boutput(H, SPAN_ALERT("The acidic vapors burn you!"))
						H.TakeDamage("head", 0, created_volume, 0, DAMAGE_BURN) // why are the acids doing brute????
						H.emote("scream")
			return

	// Ag + 2 HNO3 + (heat) -> AgNO3 + H2O + NO2
	silver_nitrate
		name = "Silver Nitrate"
		id = "silver_nitrate"
		result = "silver_nitrate"
		required_reagents = list("silver" = 1, "nitric_acid" = 2)
		min_temperature = T0C + 100
		result_amount = 1
		mix_phrase = "The mixture bubbles and white crystals form."
		hidden = TRUE
		on_reaction(var/datum/reagents/holder, var/created_volume)
			holder.add_reagent("nitrogen_dioxide", created_volume, , holder.total_temperature, chem_reaction_priority = 2)
			holder.add_reagent("water", created_volume, , holder.total_temperature, chem_reaction_priority = 3)

	silver_fulminate
		name = "Silver Fulminate"
		id = "silver_fulminate"
		result = "silver_fulminate"
		required_reagents = list("silver_nitrate" = 1, "nitric_acid" = 1, "ethanol" = 1)
		min_temperature = T0C + 80
		result_amount = 1
		mix_phrase = "A shining powder precipitates from the mixture."
		on_reaction(var/datum/reagents/holder, var/created_volume)
			// creating more than a little at a time causes reaction
			if (created_volume >= rand(5, 10))
				var/datum/reagent/silver_fulminate/target_silver_fulminate = holder.get_reagent("silver_fulminate")
				target_silver_fulminate.explode()

	// 2 AgNO3 + Cu + (water solvent) -> Cu(NO3)2 + 2 Ag
	silver_nitrate_copper_nitrate_1
		name = "Silver Nitrate and Copper"
		id = "silver_nitrate_copper_nitrate"
		result = "copper_nitrate"
		required_reagents = list ("silver_nitrate" = 2, "copper" = 1, "water" = 1)
		result_amount = 1
		mix_phrase = "Silver hairlike strands of silver form in the mixture, and the mixture becomes more blue."
		hidden = TRUE
		on_reaction(var/datum/reagents/holder, var/created_volume)
			holder.add_reagent("silver", created_volume*2, , holder.total_temperature, chem_reaction_priority = 2)
			holder.add_reagent("water", created_volume, , holder.total_temperature, chem_reaction_priority = 3)

	// 2 AgNO3 + Cu + (ethanol solvent) -> Cu(NO3)2 + 2 Ag
	silver_nitrate_copper_nitrate_2
		name = "Silver Nitrate and Copper"
		id = "silver_nitrate_copper_nitrate"
		result = "copper_nitrate"
		required_reagents = list ("silver_nitrate" = 2, "copper" = 1, "ethanol" = 1)
		result_amount = 1
		mix_phrase = "Silver hairlike strands of silver form in the mixture, and the mixture becomes more blue."
		hidden = TRUE
		on_reaction(var/datum/reagents/holder, var/created_volume)
			holder.add_reagent("silver", created_volume*2, , holder.total_temperature, chem_reaction_priority = 2)
			holder.add_reagent("ethanol", created_volume, , holder.total_temperature, chem_reaction_priority = 3)

	// 2 AgNO3 + (heat) -> 2 Ag + O2 + 2 NO2
	silver_nitrate_decomposition
		name = "Silver Nitrate Decomposition"
		id = "silver_nitrate_decomposition"
		result = "silver"
		required_reagents = list("silver_nitrate" = 1)
		min_temperature = T0C + 300
		result_amount = 1
		mix_phrase = "Silver specks form in the mixture as it decomposes."
		hidden = TRUE
		on_reaction(var/datum/reagents/holder, var/created_volume)
			holder.add_reagent("nitrogen_dioxide", created_volume, , holder.total_temperature, chem_reaction_priority = 2)
			holder.add_reagent("oxygen", created_volume/2, , holder.total_temperature, chem_reaction_priority = 3)

	/*
	weedkiller/weedkiller2
		id = "weedkiller2"
		required_reagents = list("chlorine" = 1, "ammonia" = 2)
		result_amount = 3
	*/
// foam and foam precursor

	surfactant
		name = "Foam surfactant"
		id = "foam surfactant"
		result = "fluorosurfactant"
		required_reagents = list("fluorine" = 1, "carbon" = 1, "acid" = 1)
		result_amount = 3
		mix_phrase = "A head of foam results from the mixture's constant fizzing."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	firefoam
		name = "Firefighting foam"
		id = "ff-foam"
		result = "ff-foam"
		required_reagents = list("chlorine" = 1, "carbon" = 1, "nickel" = 1)
		result_amount = 2
		mix_phrase = "The mixture bubbles gently."
		mix_sound = 'sound/misc/drinkfizz.ogg'

		on_reaction(var/datum/reagents/holder, var/created_volume)
			// nickel is a catalyst and does not get used in the process
			holder.add_reagent("nickel", created_volume / 2,,holder.total_temperature, chemical_reaction = TRUE, chem_reaction_priority = 2)


	foam
		name = "Foam"
		id = "foam"
		required_reagents = list("fluorosurfactant" = 1, "water" = 1)
		result_amount = 2
		instant = 1
		special_log_handling = 1
		mix_phrase = "The mixture quickly and violently erupts into bubbles!"
		hidden = TRUE
		on_reaction(var/datum/reagents/holder, var/created_volume)
			if (holder.postfoam)
				return
			if(!holder?.my_atom?.is_open_container())
				if(holder.my_atom)
					for(var/mob/M in AIviewers(5, get_turf(holder.my_atom)))
						boutput(M, SPAN_NOTICE("With nowhere to go, the bubbles settle."))
					return
			var/turf/location = 0
			if (holder.my_atom && length(holder.covered_cache) <= 1)
				location = get_turf(holder.my_atom)
				for(var/mob/M in AIviewers(5, location))
					boutput(M, SPAN_ALERT("The solution violently bubbles!"))

				location = get_turf(holder.my_atom)

				for(var/mob/M in AIviewers(5, location))
					boutput(M, SPAN_ALERT("The solution spews out foam!"))

				var/datum/effects/system/foam_spread/s = new()
				s.set_up(created_volume, location, holder, 0)
				s.start()
				holder.clear_reagents()
			else
				var/amt = clamp(holder.covered_cache.len/100, 1, 10)
				for (var/i = 0, i < amt && holder.covered_cache.len, i++)
					location = pick(holder.covered_cache)
					holder.covered_cache -= location
					var/datum/effects/system/foam_spread/s = new()
					s.set_up(created_volume/holder.covered_cache.len, location, holder, 0, carry_volume = (created_volume / max(length(holder.covered_cache),1)))
					s.start()
				holder.clear_reagents()
			return

	metalfoam
		name = "Metal Foam"
		id = "metalfoam"
		required_reagents = list("aluminium" = 3, "fluorosurfactant" = 1, "acid" = 1)
		instant = 1
		result_amount = 5
		mix_phrase = "The metal begins to foam up!"
		hidden = TRUE

		on_reaction(var/datum/reagents/holder, var/created_volume)
			var/turf/location = 0
			if(!holder?.my_atom?.is_open_container())
				if(holder.my_atom)
					for(var/mob/M in AIviewers(5, get_turf(holder.my_atom)))
						boutput(M, SPAN_NOTICE("With nowhere to go, the metal settles."))
					return

			if (holder.my_atom && length(holder.covered_cache) <= 1)
				location = get_turf(holder.my_atom)
				for(var/mob/M in AIviewers(5, location))
					boutput(M, SPAN_ALERT("The solution spews out a metalic foam!"))

				var/datum/effects/system/foam_spread/s = new()
				s.set_up(created_volume/2, location, holder, 1)
				s.start()
			else
				var/amt = clamp(holder.covered_cache.len/100, 1, 10)
				for (var/i = 0, i < amt && holder.covered_cache.len, i++)
					location = pick(holder.covered_cache)
					holder.covered_cache -= location
					var/datum/effects/system/foam_spread/s = new()
					s.set_up(created_volume/holder.covered_cache.len, location, holder, 0, carry_volume = created_volume / holder.covered_cache.len)
					s.start()
				holder.clear_reagents()
			return

	ironfoam
		name = "Iron Foam"
		id = "ironlfoam"
		required_reagents = list("iron" = 3, "fluorosurfactant" = 1, "acid" = 1)
		instant = 1
		result_amount = 5
		mix_phrase = "The metal begins to foam up, becoming rigid and tough!"
		hidden = TRUE

		on_reaction(var/datum/reagents/holder, var/created_volume)
			var/turf/location = 0
			if(!holder?.my_atom?.is_open_container())
				if(holder.my_atom)
					for(var/mob/M in AIviewers(5, location))
						boutput(M, SPAN_NOTICE("With nowhere to go, the metal settles."))
					return

			if (holder?.my_atom)
				location = get_turf(holder.my_atom)
				for(var/mob/M in AIviewers(5, location))
					boutput(M, SPAN_ALERT("The solution spews out a metalic foam!"))

				var/datum/effects/system/foam_spread/s = new()
				s.set_up(created_volume/2, location, holder, 2)
				s.start()
			else
				var/amt = clamp((holder.covered_cache.len * (created_volume / holder.covered_cache_volume)), 1, 5)
				for (var/i = 0, i < amt && holder.covered_cache.len, i++)
					location = pick(holder.covered_cache)
					holder.covered_cache -= location
					var/datum/effects/system/foam_spread/s = new()
					s.set_up((created_volume/2)/amt, location, holder, 2)
					s.start()
			return

	luminol
		name = "luminol"
		id = "luminol"
		result = "luminol"
		required_reagents = list("oxygen" = 1, "hydrogen" = 1, "nitrogen" = 1, "carbon" = 1)
		result_amount = 3
		mix_phrase = "The solution seems to highlight stains in the container."

	// Synthesizing these three chemicals is pretty complex in real life, but fuck it, it's just a game!
	ammonia
		name = "Ammonia"
		id = "ammonia"
		result = "ammonia"
		required_reagents = list("hydrogen" = 3, "nitrogen" = 1)
		inhibitors = list("chlorine" = 1) //to prevent conflict with atrazine
		result_amount = 3
		mix_phrase = "The mixture bubbles, emitting an acrid reek."

	diethylamine // COGWERKS CHEM REVISION PROJECT: change this so cleaner involves ammonia, ethanol and water
		name = "Diethylamine"
		id = "diethylamine"
		result = "diethylamine"
		required_reagents = list("ammonia" = 1, "ethanol" = 1)
		min_temperature = T0C + 100
		result_amount = 2
		mix_phrase = "A horrible smell pours forth from the mixture."
		instant = FALSE
		reaction_speed = 1

		on_reaction(var/datum/reagents/holder, var/created_volume)
			holder.temperature_reagents(holder.total_temperature - created_volume*200, 400, change_min = 1)

	diethylamine_ignite
		name = "Diethylamine ignition"
		hidden = TRUE
		id = "diethylamine ignition"
		required_reagents = list("diethylamine" = 1)
		mix_phrase = "The mixture combusts!"
		min_temperature = T0C + 250

		on_reaction(var/datum/reagents/holder, var/created_volume)
			for (var/turf/T in holder.covered_turf())
				fireflash_melting(T, 1, 600, 50, chemfire = CHEM_FIRE_RED)

	LSD
		name = "Lysergic acid diethylamide"
		id = "LSD"
		result = "LSD"
		required_reagents = list("diethylamine" = 1, "space_fungus" = 1)
		min_temperature = T0C + 70
		result_amount = 3
		mix_phrase = "The mixture turns a rather unassuming color and settles."

	bathsalts // cogwerks' dumb first drug attempt, delete if bad
		name = "Bath Salts"
		id= "bathsalts"
		result = "bathsalts"
		required_reagents = list("msg" = 1, "yuck" = 1, "denatured_enzyme" = 1, "saltpetre" = 1, "cleaner" = 1, "mercury" = 1, "el_diablo" = 1)
		min_temperature = T0C + 100
		result_amount = 6
		mix_phrase = "Tiny cubic crystals precipitate out of the mixture. Huh."
		mix_sound = 'sound/misc/fuse.ogg'

	itching // cogwerks
		name = "Itching Powder"
		id = "itching"
		result = "itching"
		required_reagents = list("ammonia" = 1, "fuel" = 1, "space_fungus" = 1)
		result_amount = 4
		mix_phrase = "The mixture congeals and dries up, leaving behind an abrasive powder."
		mix_sound = 'sound/impact_sounds/Slimy_Hit_4.ogg'

	antihistamine // cogwerks - basic sedatives could fill this role, or just put it in the medbay vendor?
		name = "Diphenhydramine"
		id = "diphenhydramine"
		result = "antihistamine"
		//min_temperature = 320
		result_amount = 4
		required_reagents = list("oil" = 1, "carbon" = 1, "bromine" = 1, "diethylamine" = 1, "ethanol" = 1)
		// benzhydryl(benzene+carbon) bromide + 2-dimethylaminoethanol
		mix_phrase = "The mixture fizzes gently."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	sulfonal
		name = "Sulfonal"
		id = "sulfonal"
		result = "sulfonal"
		//min_temperature = 320
		result_amount = 2
		required_reagents = list("acetone" = 1, "diethylamine" = 1, "sulfur" = 1)
		mix_phrase = "The mixture gives off quite a stench."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	salt
		name = "Salt"
		id = "salt"
		result = "salt"
		required_reagents = list("chlorine" = 1, "sodium" = 1, "water" = 1)
		result_amount = 2
		mix_phrase = "The solution crystallizes with a brief flare of light."

	saline
		name = "Saline-Glucose Solution"
		id = "saline"
		result = "saline"
		required_reagents = list("salt" = 1, "water" = 1, "sugar" = 1)
		result_amount = 3

	heparin // anticoagulant
		name = "Heparin"
		id = "heparin"
		result = "heparin"
		required_reagents = list("sugar" = 1, "blood" = 1, "phenol" = 1, "acid" = 1)
		result_amount = 2

	proconvertin // coagulant
		name = "Proconvertin"
		id = "proconvertin"
		result = "proconvertin"
		required_reagents = list("blood" = 1, "dna_mutagen" = 1, "mannitol" = 1, "salt" = 1)
		result_amount = 2

	filgrastim // hematopoiesis stimulant
		name = "Filgrastim"
		id = "filgrastim"
		result = "filgrastim"
		required_reagents = list("blood" = 1, "dna_mutagen" = 1, "beff" = 1, "spaceacillin" = 1)
		result_amount = 2

	ecoli // hobo-chem recipe to disconnect E.Coli from pathology chems
		name = "contaminated food E.Coli"
		id = "contaminated food E.Coli"
		result = "e.coli"
		required_reagents = list("sewage" = 5, "cholesterol" = 4)
		result_amount = 1
		instant = 0 // bacteria needs some time to grow in this medium
		reaction_speed = 0.25
		mix_phrase = "An unbearable stench emancipates from the mixture as it slowly coagulates."
		mix_sound = 'sound/misc/fuse.ogg'

		on_reaction(var/datum/reagents/holder, var/created_volume)
			// sewage is a catalyst and does not get used in the process
			holder.add_reagent("sewage", created_volume * 5,,holder.total_temperature, chemical_reaction = TRUE, chem_reaction_priority = 2)
			// Byproduct is some nutrients from the decomposted egg and some bacterials toxins
			holder.add_reagent("poo", created_volume * 2,,holder.total_temperature, chemical_reaction = TRUE, chem_reaction_priority = 3)
			holder.add_reagent("toxin", created_volume,,holder.total_temperature, chemical_reaction = TRUE, chem_reaction_priority = 4)
			// the decomposition process create some unbearable stench
			var/turf/location = pick(holder.covered_turf())
			location.fluid_react_single("miasma", created_volume * 4, airborne = 1)


	ecoli/ecoli2
		name = "E.Coli 2"
		id = "E.Coli 2"
		result = "e.coli"
		required_reagents = list("sewage" = 5, "meat_slurry" = 4)

	ecoli/ecoli3
		name = "E.Coli 3"
		id = "E.Coli 3"
		result = "e.coli"
		required_reagents = list("sewage" = 5, "beff" = 4)


	catdrugs
		name = "Cat Drugs"
		id = "catdrugs"
		result = "catdrugs"
		min_temperature = T0C + 100
		result_amount = 3
		required_reagents = list("catonium" = 1, "psilocybin" = 1, "ammonia" = 1, "fuel" = 1)
		mix_phrase = "The mixture hisses oddly."
		mix_sound = 'sound/voice/animal/cat_hiss.ogg'

	crank // cogwerks - awful hobo drug that can be made by pissing in a bunch of vending machine stuff and then boiling it all with a welder
		name = "Crank"
		id = "crank"
		result = "crank"
		min_temperature = T0C + 100
		result_amount = 5
		instant = 1
		required_reagents = list("antihistamine" = 1, "ammonia" = 1, "lithium" = 1, "fuel" = 1, "acid" = 1)
		mix_phrase = "The mixture violently reacts, leaving behind a few crystalline shards."
		mix_sound = 'sound/impact_sounds/Crystal_Shatter_1.ogg'
		on_reaction(var/datum/reagents/holder, var/created_volume)
			var/atom/my_atom = holder.my_atom // if you heat this stuff in your hand, you'll die! heh!

			var/turf/location = 0
			if (my_atom)
				location = get_turf(my_atom)
				fireflash(holder.my_atom, 2, chemfire = CHEM_FIRE_RED)
				//okay I'm turning off the explosion here because it keeps deleting the reagents and I don't want to consider synchronous explosion code
				//feel free to turn back on if you think of a solution for it blowing up the reagent puddle
				// explosion(my_atom, get_turf(my_atom), -1, -1, 1, 2)
				if(istype(holder.my_atom, /obj))
					var/obj/container = holder.my_atom
					container.shatter_chemically(projectiles = TRUE)
			else
				var/amt = max(1, (holder.covered_cache.len * (created_volume / holder.covered_cache_volume)))
				for (var/i = 0, i < amt && holder.covered_cache.len, i++)
					location = pick(holder.covered_cache)
					holder.covered_cache -= location
					fireflash(location, 0, chemfire = CHEM_FIRE_RED)
					// explosion_new(my_atom, location, 2.25/amt)
			return

	krokodil
		name = "Krokodil"
		id = "krokodil"
		result = "krokodil"
		min_temperature = T0C + 100
		result_amount = 5
		required_reagents = list("morphine" = 1, "antihistamine" = 1, "cleaner" = 1, "phosphorus" = 1, "potassium" = 1, "fuel" = 1)
		mix_phrase = "The mixture dries into a pale blue powder."
		mix_sound = 'sound/misc/fuse.ogg'

/*	helldrug // the worst thing. if splashed on floor, create void turf. if ingested, replace mob with crunch critter and teleport user to hell
		name = "Cthonium"
		id = "cthonium"
		result = "cthonium"
		//min_temperature = 666
		result_amount = 2
		//required_reagents = list("el_diablo" = 1, "salts1" = 1,"mugwort" = 1, "catonium" = 1, "bloodc" = 1, "sulfur" = 1, "liquid spacetime" = 1, "strange_reagent" = 1)
		required_reagents = list("blood" = 1, "sulfur" = 1, "plasma" = 1)
		mix_phrase = "The mixture seems to have corrupted the very fabric of reality."
		mix_sound = 'airraid_loop.ogg'
		on_reaction(var/datum/reagents/holder, var/created_volume)
			bust_lights()
			creepify_station()
			return

	bleach
		name = "Bleach" // cogwerks WIP: could be useful for hobo chemistry, hair bleaching, stubborn stains, being a jerk and turning stuff white
		id = "bleach"
		result = "bleach"
		result_amount = 1
		required_reagents = list("sodium" = 1, "chlorine" = 1, "hydrogen" = 1)
		mix_phrase = "The mixture gives off a sharp odor much like bleach. Probably because it's bleach."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	chlorine // cogwerks, more hobo chemistry
		name = "Chlorine"
		id = "chlorine"
		result = "chlorine"
		required_reagents = list("ammonia" = 1, "bleach" = 1 )
		result_amount = 1
		mix_phrase = "The mixture starts bubbling violently!"
		mix_sound = 'sound/misc/fuse.ogg'

		on_reaction(var/datum/reagents/holder, var/created_volume)
			var/location = get_turf(holder.my_atom)
			for(var/mob/M in AIviewers(5, location))
				boutput(M, SPAN_ALERT("The solution boils up into a choking cloud!"))
			src.mustard_gas = new /datum/effects/system/mustard_gas_spread/
			src.mustard_gas.attach(src)
			src.mustard_gas.set_up(5, 0, usr.loc)
			return */

	space_cleaner // COGWERKS CHEM REVISION PROJECT: add ethanol to this recipe
		name = "Space cleaner"
		id = "cleaner"
		result = "cleaner"
		required_reagents = list("ammonia" = 1, "ethanol" = 1, "water" = 1)
		result_amount = 3
		//mix_phrase = "The mixture begins to emit a distinct smell of bleach." -AMMONIA IS NOT BLEACH!!!!!!!!!! - grumpwerks
		mix_phrase = "Ick, this stuff really stinks. Sure does make the container sparkle though!"

	strange_reagent
		id = "strange_reagent"
		result = "strange_reagent"
		required_reagents = list("omnizine" = 1, "mutagen" = 1, "water_holy" = 1)
		result_amount = 2
		mix_phrase = "The substance begins moving on its own somehow."

	carpet
		name = "Carpet"
		id = "carpet"
		result = "carpet"
		required_reagents = list("space_fungus" = 1, "blood" = 1)
		result_amount = 2
		mix_phrase = "The substance turns thick and stiff, yet soft."

	badgrease
		name = "Partially Hydrogenated Space-Soybean Oil"
		id = "badgrease"
		result = "badgrease"
		required_reagents = list("grease" = 1, "hydrogen" = 1)
		min_temperature = T0C + 250
		result_amount = 2
		mix_phrase = "The mixture emits a burnt, oily smell."

	cornsyrup
		name = "Corn Syrup"
		id = "cornsyrup"
		result = "cornsyrup"
		required_reagents = list("cornstarch" = 1, "acid" = 1)
		min_temperature = T0C + 100
		result_amount = 2
		mix_phrase = "The mixture forms a viscous, clear fluid!"

	VHFCS
		name = "Very-High-Fructose Corn Syrup"
		id = "VHFCS"
		result = "VHFCS"
		required_reagents = list("cornsyrup" = 1, "denatured_enzyme" = 0)
		result_amount = 1
		mix_phrase = "The mixture emits a sickly-sweet smell."

	gravy
		name = "Gravy"
		id = "gravy"
		result = "gravy"
		required_reagents = list("porktonium" = 1, "milk" = 1, "cornstarch" = 1)
		result_amount = 3
		min_temperature = T0C + 100
		mix_phrase = "The substance thickens and takes on a meaty odor."

	pepperoni
		name = "Pepperoni"
		id = "pepperoni"
		result = "pepperoni"
		required_reagents = list("beff" = 1, "synthflesh" = 1, "saltpetre" = 1)
		result_amount = 2
		mix_phrase = "The beff and the synthflesh combine to form a smoky red log."
		mix_sound = 'sound/impact_sounds/Slimy_Hit_4.ogg'

	acetone_phenol //my stupid interpretation of the cumene process
		name = "Acetone-phenol production"
		id = "acetone-phenol"
		result = "acetone"
		eventual_result = list("acetone", "phenol")
		required_reagents = list("oil" = 1, "fuel" = 3, "chlorine" = 0.1) //oil and welding fuel for benzene and propylene, then chlorine for the radical initiator
		result_amount = 2
		mix_phrase = "The smell of paint thinner assaults you as the solution bubbles."
		instant = FALSE
		reaction_speed = 1

		on_reaction(datum/reagents/holder, created_volume) // TODO: actual byproduct/multi-output handling
			holder.add_reagent("phenol", created_volume, temp_new = holder.total_temperature, chemical_reaction = TRUE, chem_reaction_priority = 2)

	espresso //makin' caffeine by dehydrating coffee
		name = "Coffee concentration"
		id = "espresso"
		result = "espresso"
		eventual_result = "espresso"
		required_reagents = list("coffee" = 2, "sodium_sulfate" = 0.1) //sodium sulfate as an approximate drying agent
		result_amount = 1
		max_temperature = T0C + 30 //sodium sulfate fails at 30c (A.K.A. 'you want to to make the caffeine in another thing')
		mix_phrase = "A gross precipitate forms as the water is absorbed."
		instant = FALSE
		reaction_speed = 0.5
		var/shock_ticks = 0

		physical_shock(var/force, var/datum/reagents/holder)
			if(force > 3)
				shock_ticks = 5
				playsound(get_turf(holder.my_atom), 'sound/effects/bubbles_short.ogg', 50, 1)

		on_reaction(datum/reagents/holder, created_volume)
			reaction_icon_state = list("reaction_bubble-1", "reaction_bubble-2")
			if(shock_ticks > 0)
				reaction_speed = 1
				shock_ticks--
				reaction_icon_state = list("reaction_sparkle-1", "reaction_sparkle-2")
			else
				reaction_speed = 0.5

			//precipitate gross stuff, it's easy to MAKE a caffeine machine, but you want to clear out your equipment from time to time...
			if (prob(50))
				holder.add_reagent("sewage", created_volume*0.2, temp_new = holder.total_temperature, chemical_reaction = FALSE) //RAW coffee
			else
				holder.add_reagent("yuck", created_volume*0.2, temp_new = holder.total_temperature, chemical_reaction = FALSE) //sulfate sludge

	espresso/fresh
		required_reagents = list("coffee_fresh" = 2, "sodium_sulfate" = 0.1)

	caffeine
		name = "Caffeine precipitation"
		id = "caffeine"
		result = "caffeine"
		eventual_result = "caffeine"
		required_reagents = list("espresso" = 2, "acetone" = 0.1) //acetone as a solvent. also means 'you need to have made a bit of acetone once'
		result_amount = 1
		min_temperature = T0C + 100
		mix_phrase = "White crystals form as the acetone evaporates."
		instant = FALSE
		reaction_speed = 0.5
		on_reaction(datum/reagents/holder, created_volume)
			holder.temperature_reagents(holder.total_temperature - created_volume*100, 400, change_min = 1)

	hairgrownium
		name = "Hairgrownium"
		id = "hairgrownium"
		result = "hairgrownium"
		required_reagents = list("synthflesh" = 1,"ephedrine" = 1,"carpet" = 1)
		result_amount = 3
		mix_phrase = "The liquid becomes slightly hairy."

	super_hairgrownium
		name = "Super Hairgrownium"
		id = "super_hairgrownium"
		result = "super_hairgrownium"
		required_reagents = list("hairgrownium" = 1, "methamphetamine" = 1, "iron" = 1)
		result_amount = 3
		mix_phrase = "The liquid becomes disgustingly furry and smells terrible."

	port
		name = "Port"
		id = "port"
		result = "port"
		required_reagents = list("wine" = 1, "sugar" = 1, "iron" = 1, "vodka" = 1)
		result_amount = 2
		mix_phrase = "The liquid darkens and emits a strong smell of alcohol."

	capulettium
		name = "Capulettium"
		id = "capulettium"
		result = "capulettium"
		required_reagents = list("neurotoxin" = 1, "chlorine" = 1, "hydrogen" = 1)
		result_amount = 1
		mix_phrase = "The smell of death wafts from the solution."

	capulettium_plus
		name = "Capulettium Plus"
		id = "capulettium_plus"
		result = "capulettium_plus"
		required_reagents = list("capulettium" = 1, "ephedrine" = 1, "methamphetamine" = 1)
		result_amount = 3
		mix_phrase = "The solution begins to slosh about violently by itself."

	something
		name = "Something"
		id = "something"
		result = "something"
		required_reagents = list("sorium" = 1, "ldmatter" = 1)
		result_amount = 2
		mix_phrase = "The solution swirls violently and forms...something."
		hidden = TRUE

	voltagen
		name = "Voltagen"
		id = "voltagen"
		result = "voltagen"
		required_reagents = list("ldmatter" = 1, "plasma" = 5, "uranium" = 1, "oil" = 1, "stabiliser" = 1)
		result_amount = 5
		mix_phrase = "The solution settles into a liquid form of electricity."
		mix_sound = 'sound/effects/elec_bigzap.ogg'
		hidden = TRUE

	energydrink
		name = "Energy Drink"
		id = "energydrink"
		result = "energydrink"
		required_reagents = list("voltagen" = 1, "coffee" = 1, "cola" = 3)
		result_amount = 5
		mix_phrase = "The solution emits a tutti frutti stench."
		hidden = TRUE

	energydrink/fresh
		id = "energydrink_fresh"
		required_reagents = list("voltagen" = 1, "coffee_fresh" = 1, "cola" = 3)

	voltagen_arc
		name = "Voltagen Arc"
		id = "voltagen_arc"
		required_reagents = list("ldmatter" = 1, "plasma" = 5, "uranium" = 1, "oil" = 1)
		instant = 1
		inhibitors = list("stabiliser")
		mix_phrase = "The solution settles into a liquid form of electricity but violently destabilizes!"
		mix_sound = 'sound/effects/elec_bigzap.ogg'
		hidden = TRUE
		on_reaction(var/datum/reagents/holder, var/created_volume)
			var/mob/living/target = usr
			if (!istype(target))
				target = locate() in view(5)
			if (!istype(target))
				return

			if (holder?.my_atom)
				arcFlash(holder.my_atom, target, 500000)
			else
				arcFlash(pick(holder.covered_cache), target, 500000)

/*
	montaguone
		name = "Montaguone"
		id = "montaguone"
		result = "montaguone"
		required_reagents = list("omnizine" = 1, "styptic_powder" = 1, "salbutamol" = 1)
		result_amount = 1
		mix_phrase = "The smell of spring drifts from the solution."

	montaguone_extra
		name = "Montaguone Extra"
		id = "montaguone_extra"
		result = "montaguone_extra"
		required_reagents = list("montaguone" = 1, "silver_sulfadiazine" = 1, "charcoal" = 1)
		result_amount = 3
		mix_phrase = "The solution starts to glow white slightly."
*/

	fermid
		name = "Fermid"
		id = "fermid"
		required_reagents = list("ants" = 1, "mutagen" = 1, "aranesp" = 1, "booster_enzyme" = 1 )
		instant = 1
		min_temperature = T0C //no multiple fermids through a single container by abusing the aranesp reaction
		mix_phrase = "The ants begin to rapidly mutate!"
		var/static/reaction_count = 0

		on_reaction(var/datum/reagents/holder, var/created_volume)
			CRITTER_REACTION_CHECK(reaction_count)
			if (holder?.my_atom)
				new /mob/living/critter/fermid(get_turf(holder.my_atom))
			else
				new /mob/living/critter/fermid(pick(holder.covered_cache))
			return

	life
		name = "Life"
		id = "life"
		result = "life"
		required_reagents = list("synthflesh" = 5, "blood" = 2, "strange_reagent" = 1)
		result_amount = 8
		min_temperature = T0C + 100
		mix_phrase = "The substance begins to wriggle disgustingly and climbs out of its container!"
		hidden = TRUE
		var/static/reaction_count = 0

		on_reaction(var/datum/reagents/holder, var/created_volume)
			CRITTER_REACTION_CHECK(reaction_count)
			var/result = 0
			var/roll = rand(1,100)
			if(roll + created_volume > 100) result = rand(95,100)
			else result = roll + created_volume

			var/turf/location = holder.my_atom ? get_turf(holder.my_atom) : pick(holder.covered_cache.len)
			switch(result)
				if(0) return
				if(1 to 70)
					new /mob/living/carbon/cube/meat(location)
				if(71 to 94)
					var/critter = pick(
					/mob/living/critter/small_animal/cockroach,
					/mob/living/critter/small_animal/pig,
					/mob/living/critter/small_animal/cat,
					/mob/living/critter/small_animal/mouse,
					/mob/living/critter/small_animal/wasp,
					/mob/living/critter/small_animal/bird/owl,
					/mob/living/critter/small_animal/bird/goose,
					/mob/living/critter/small_animal/bird/goose/swan,
					/obj/critter/domestic_bee,
					/mob/living/critter/small_animal/walrus,
					/mob/living/critter/small_animal/seal)
					new critter(location)
				if(95 to 97)
					if (location.density)
						new /mob/living/carbon/cube/meat(location)
					else
						var/human = /mob/living/carbon/human/normal
						new human(location)
				if(98 to 100)
					if (location.density)
						new /mob/living/carbon/cube/meat(location)
					else
						new /mob/living/carbon/human/npc(location)

			holder.remove_reagent("life",created_volume + 1) //+1 to prevent any of those weird errors where you get 5.423E-09 of something or whatever.
			return

	ageinium
		name = "Ageinium"
		id = "ageinium"
		result = "ageinium"
		required_reagents = list("acetone" = 1, "chocolate" = 1, "tea" = 1, "nicotine" = 1, "formaldehyde" = 1)
		result_amount = 3
		min_temperature = T0C + 117 // world's oldest person!
		mix_phrase = "The bubbling mixture gives off a scent of perfume, hard candy, and death."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		hidden = TRUE

	//Hello, here are some fake werewolf serum precursors
	werewolf_serum_fake1
		name = "Werewolf Serum Precursor Alpha"
		id = "werewolf_part1"
		result = "werewolf_part1"
		required_reagents = list("wolfsbane" = 1, "grog" = 1, "denatured_enzyme" = 0, "super_hairgrownium" = 1)
		result_amount = 4
		mix_phrase = "The substance burbles distressingly and takes a metallic shine."
		hidden = TRUE


	werewolf_serum_fake2
		name = "Werewolf Serum Precursor Beta"
		id = "werewolf_part2"
		result = "werewolf_part2"
		required_reagents = list("tongueofdog" = 1, "dna_mutagen" = 1, "omega_mutagen" = 1)
		result_amount = 3
		mix_phrase = "The substance flashes brilliantly, but quickly subsides."
		hidden = TRUE

	werewolf_serum_fake3
		name = "Werewolf Serum Precursor Gamma"
		id = "werewolf_part3"
		result = "werewolf_part3"
		required_reagents = list("werewolf_part1" = 1, "werewolf_part2" = 1)
		result_amount = 2
		min_temperature = T0C + 150
		hidden = TRUE

	werewolf_serum_fake4
		name = "Imperfect Werewolf Serum"
		id = "werewolf_part4"
		//result = "werewolf_part4"
		result = "lemonade"
		required_reagents = list("werewolf_part3" = 1, "tea" = 1)
		result_amount = 2
		mix_phrase = "The substance gives off a putrid stench!"
		hidden = TRUE

	werewolf_serum
		name = "Werewolf Serum"
		id = "werewolf_serum"
		result = "werewolf_serum"
		required_reagents = list("werewolf_part4" = 1, "badgrease" = 1, "stabiliser" = 1)
		result_amount = 3
		mix_phrase = "The substance bubbles and gives off an almost lupine howl."
		var/static/list/full_moon_days_2053 = list("Jan 04", "Feb 03", "Mar 04", "Apr 03", "May 02", "Jun 01", "Jul 01", "Jul 30", "Aug 29", "Sep 27", "Oct 27", "Nov 25", "Dec 25")
		hidden = TRUE

		does_react(var/datum/reagents/holder)
			return time2text(world.realtime, "MMM DD") in full_moon_days_2053 //just doesn't react unless it's a full moon

	vampire_serum
		name = "Vampire Serum Omega"
		id = "vampire_serum"
		result =  "vampire_serum"
		required_reagents = list("bloodc" = 1, "water_holy" = 1, "werewolf_serum" = 1)
		result_amount = 3
		mix_phrase = "The substance gives off a coppery stink."
		hidden = TRUE

		//Super hairgrownium + Tongue of dog + Stable mutagen + Grog + Glowing Slurry + Aconitum

	hootagen_unstable
		name = "unstable hootagen"
		id = "hootagen_unstable"
		result = "hootagen_unstable"
		required_reagents = list("sonicpowder" = 1, "egg" = 1, "bloodc" = 1, "strange_reagent" = 1, "sorium" = 1, "dna_mutagen" = 3)
		result_amount = 1
		// has to be <50C, as changeling blood boils off at that
		min_temperature = T0C + 45
		mix_phrase = "The reagents combine with an audible ho0t."
		mix_sound = 'sound/voice/animal/hoot.ogg'
		hidden = TRUE

	hootagen_stable
		name = "stable hootagen"
		id = "hootagen_stable"
		result = "hootagen_stable"
		required_reagents = list("sonicpowder" = 1, "egg" = 1, "bloodc" = 1, "strange_reagent" = 1, "sorium" = 1, "dna_mutagen" = 3)
		result_amount = 3
		mix_phrase = "The reagents combine with an audible hoot."
		mix_sound = 'sound/voice/animal/hoot.ogg'
		hidden = TRUE

	colors
		name = "colorful reagent"
		id = "colors"
		result = "colors"
		required_reagents = list("plasma" = 1, "radium" = 1, "stabiliser" = 1, "space_drugs" = 1, "cryoxadone" = 1, "cocktail_citrus" = 1)
		result_amount = 6
		mix_phrase = "The substance flashes multiple colors and emits the smell of a pocket protector."

	fliptonium
		name = "fliptonium"
		id = "fliptonium"
		result = "fliptonium"
		required_reagents = list("sonic" = 1, "ldmatter" = 1, "chocolate" = 1, "ephedrine" = 1)
		result_amount = 4
		mix_phrase = "The mixture swirls around excitedly!"

	glowing_fliptonium
		name = "glowing fliptonium"
		id = "glowing_fliptonium"
		result = "glowing_fliptonium"
		required_reagents = list("fliptonium" = 1, "anima" = 1, "uranium" = 1, "space_drugs" = 1/*, "lumen" = 1*/) // Lumen reagent was removed.
		result_amount = 1
		mix_phrase = "The mixture swirls around and begins to glow strangely!"
		hidden = TRUE

	diluted_fliptonium
		name = "diluted fliptonium"
		id = "diluted_fliptonium"
		result = "diluted_fliptonium"
		required_reagents = list("fliptonium" = 1, "water" = 2)
		result_amount = 3
		mix_phrase = "The mixture swirls around in a kinda lackluster way. You feel pretty unimpressed."

	fartonium
		name = "fartonium"
		id = "fartonium"
		result = "fartonium"
		required_reagents = list("egg" = 1, "refried_beans" = 1, "yuck" = 1, "fakecheese" = 1)
		result_amount = 2
		mix_phrase = "The substance makes a little 'toot' noise and starts to smell pretty bad."
		mix_sound = 'sound/voice/farts/poo2.ogg'

	flaptonium
		name = "flaptonium"
		id = "flaptonium"
		result = null //"flaptonium"
		required_reagents = list("egg" = 1, "colors" = 1, "chickensoup" = 1, "strange_reagent" = 1, "blood" = 1)
		instant = 1
		min_temperature = T0C + 100
		mix_phrase = "The substance turns an airy sky-blue and foams up into a new shape." // heh get it, get it, birds, sky, airy??? heh im the master of humor
		mix_sound = 'sound/voice/burp.ogg'
		var/static/reaction_count = 0

		on_reaction(var/datum/reagents/holder, var/created_volume)
			CRITTER_REACTION_CHECK(reaction_count)
			var/turf/T = holder.my_atom ? get_turf(holder.my_atom) : pick(holder.covered_cache.len)
			if (prob(1) && !already_a_dominic)
				new /obj/critter/parrot/eclectus/dominic(T)
			else
				new /obj/critter/parrot/random(T)

			holder.remove_reagent("egg")
			holder.remove_reagent("colors")
			holder.remove_reagent("chickensoup")
			holder.remove_reagent("strange_reagent")
			holder.remove_reagent("blood")
			return

	feather_fluid
		name = "feather fluid"
		id = "feather_fluid"
		result = "feather_fluid"
		required_reagents = list("egg" = 1, "colors" = 1, "chickensoup" = 1, "strange_reagent" = 1, "blood" = 1, "sonicpowder" = 1, "eraser" = 1)
		result_amount = 1
		mix_phrase = "The solution makes a little 'chirp' noise and settles."
		hidden = TRUE

	mewtini
		name = "Mewtini"
		id = "mewtini"
		result = "mewtini"
		required_reagents = list("catdrugs" = 1, "mutini" = 1, "milk" =1, "catonium" = 1)
		result_amount = 2
		mix_phrase = "You hear a soft purring coming from the container."
		mix_sound = 'sound/misc/drinkfizz.ogg'

	glitter
		name = "glitter"
		id = "glitter"
		result = "glitter"
		required_reagents = list("itching" = 1, "colors" = 1, "paper" = 1, "silver" = 1)
		result_amount = 4
		mix_phrase = "The mixture becomes far more fabulous!"

	sparkles
		name = "harmless glitter"
		id = "sparkles"
		result = "sparkles"
		required_reagents = list("colors" = 1, "paper" = 1, "platinum" = 1)
		mix_phrase = "The mixture becomes far more fabulous- safely."

	rotting
		name = "rotting"
		id = "rotting"
		result = "rotting"
		required_reagents = list("yuck" = 1, "denatured_enzyme" = 1, "something" = 1, "poo" = 1)
		result_amount = 3
		mix_phrase = "The substance gives off a terrible stench. Are those maggots?"
		hidden = TRUE

	love
		name = "pure love"
		id = "love"
		result = "love"
		required_reagents = list("hugs" = 1, "chocolate" = 1)
		result_amount = 2
		mix_phrase = "The substance gives off a lovely scent!"

	/* It's me. I'm the new merculite.
	nitrogen_triiodide
		name = "Nitrogen Triiodide"
		id = "nitrogentriiodide"
		result = "nitrotri_wet"
		required_reagents = list("lube" = 1, "iodine" = 2, "silver" = 1, "fluorine" = 1, "cryostylane" = 1) //, "perfluorodecalin" = 1, "oil" = 1, "chlorine" = 1)
		max_temperature = T0C - 30 // -30 degrees celsius
		min_temperature = 200 //Will not react below 200 K

		/*
		Boron nitride: lube because boron nitride is a lubricant
		Iodine, silver and fluorine for I_2 + AgF -> IF + AgI
		Trichlorofluoromethane = cryostylane because it's a refrigerating agent
		Fallback:
		Trichlorofluoromethane  = perfluorodecalin, oil and chlorine
			In case nerds are being too nerdy.
		*/
		result_amount = 3
		mix_phrase = "The solution settles into a viscous paste."
	*/

	nitro_tri_explosion //This will just straight-up explode
		name = "NI3 Explosion"
		id = "nitrotri_explosion"
		result = "nitrotri_parent"
		required_reagents = list("nitrotri_dry" = 1)
		result_amount = 1
		mix_phrase = null
		mix_sound = null
		hidden = TRUE

	madness_toxin
		name = "Rajaijah"
		id = "madness_toxin"
		result = "madness_toxin"
		required_reagents = list("prions" = 1, "methamphetamine" = 1, "mercury" = 1, "haloperidol" = 1, "sulfonal" = 1, "plasma" = 1, "LSD" = 1)
		//max_temperature = T0C - 100
		result_amount = 8
		mix_phrase = "The mixture forms a clear greenish liquid, emitting a nauseating smell reminiscent of chlorophyll and rubbing alcohol."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		hidden = TRUE

	strychnine
		name = "Strychnine"
		id = "strychnine"
		result = "strychnine"
		required_reagents = list("cyanide" = 1, "phenol" = 1, "pacid" = 1, "acetic_acid" = 1, "aluminium" = 1, "iodine" = 1, "nickel" = 1)
		result_amount = 6
		mix_phrase = "The mixture congeals into an off-white crystalline powder."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		hidden = TRUE

	spiders // can also be made by eating unstable mutagen and ants and dancing - see human.dm
		name = "spiders"
		id = "spiders"
		result = "spiders"
		required_reagents = list("hugs" = 1, "ants" = 1)
		result_amount = 2
		mix_phrase = "The ants arachnify. What?"

	pyrosium_heat
		name = "pyrosium heating"
		id = "pyrosium_heat"
		required_reagents = list("pyrosium" = 1, "oxygen" = 0)
		result_amount = 1
		reaction_speed = 1
		reaction_temp_divider = 25
		instant = 0 //This one should actually not be instant
		mix_phrase = "The mixture starts to rapidly fizzle and heat up."
		hidden = TRUE
		stateful = TRUE
		var/count = 0

		on_reaction(var/datum/reagents/holder, var/created_volume)
			count += created_volume
			holder.temperature_reagents(holder.total_temperature + created_volume*200, 400, change_min = 1)

		on_end_reaction(var/datum/reagents/holder)
			holder.remove_reagent("oxygen", count)

	pyrosium_area_heat
		name = "pyrosium area heating"
		id = "pyrosium_area_heat"
		required_reagents = list("pyrosium" = 1, "magnesium" = 0)
		result_amount = 1
		reaction_speed = 1
		instant = FALSE
		reaction_volume_dependant = FALSE
		mix_phrase = "The mixture gives off very hot air."
		hidden = TRUE
		stateful = TRUE
		var/count = 0

		on_reaction(var/datum/reagents/holder)
			count++
			for(var/turf/T in range(1, get_turf(holder.my_atom)))
				for(var/mob/mob in T)
					if(!mob.is_heat_resistant())
						mob.bodytemperature += 10
				T.hotspot_expose(1000, 100, holder.my_atom)
				var/obj/particle/heat_swirl/swirl = new /obj/particle/heat_swirl
				swirl.set_loc(T)
				SPAWN(2 SECONDS)
					qdel(swirl)

		on_end_reaction(var/datum/reagents/holder)
			holder.remove_reagent("magnesium", count)

	cryostylane_cold
		name = "cryostylane chilling"
		id = "cryostylane_cold"
		required_reagents = list("cryostylane" = 1, "oxygen" = 0)
		result_amount = 1
		reaction_speed = 1
		reaction_temp_divider = 15
		instant = 0 //This one should actually not be instant
		mix_phrase = "The mixture begins to rapidly freeze."
		hidden = TRUE
		stateful = TRUE
		var/count = 0

		on_reaction(var/datum/reagents/holder, var/created_volume)
			count += created_volume
			holder.temperature_reagents(holder.total_temperature - created_volume*200, 400, change_min = 1)

		on_end_reaction(var/datum/reagents/holder)
			holder.remove_reagent("oxygen", count)

	cryostylane_area_cooling
		name = "cryostylane area cooling"
		id = "cryoxadone_area_cooling"
		required_reagents = list("cryostylane"= 1, "iodine" = 0)
		result_amount = 1
		instant = FALSE
		reaction_volume_dependant = FALSE
		reaction_speed = 1
		temperature_change = -5
		mix_phrase = "The solution gives off cold fumes."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		reaction_icon_state = list("reaction_sparkle-1", "reaction_sparkle-2")
		reaction_icon_color = "#8e38ff"
		hidden = TRUE
		stateful = TRUE
		var/count = 0

		on_reaction(var/datum/reagents/holder)
			count++
			for(var/turf/T in range(1, get_turf(holder.my_atom)))
				for(var/mob/mob in T)
					if(!mob.is_cold_resistant() || ischangeling(mob))
						mob.bodytemperature -= 10
				T.hotspot_expose(0, 100, holder.my_atom)
				var/obj/particle/cryo_sparkle/sparkle = new /obj/particle/cryo_sparkle
				sparkle.set_loc(T)
				SPAWN(2 SECONDS)
					qdel(sparkle)

		on_end_reaction(var/datum/reagents/holder)
			holder.remove_reagent("iodine", count)

	reversium
		name = "Reversium"
		id = "reversium"
		result = "reversium"
		required_reagents = list("fliptonium" = 1, "hugs" = 1, "dna_mutagen" = 1, "mutagen" = 1)
		//max_temperature = T0C - 100
		result_amount = 1
		mix_phrase = ".ylegnarts dnuora lriws ot snigeb erutxim ehT"
		mix_sound = 'sound/misc/drinkfizz.ogg'
		hidden = TRUE

	capsizin
		name = "capsizin"
		id = "capsizin"
		result = "capsizin"
		required_reagents = list("reversium" = 1, "capsaicin" = 4)
		result_amount = 5
		mix_phrase = "The solution begins to capsize. What does that even mean?"
		mix_sound = 'sound/misc/drinkfizz.ogg'
		hidden = TRUE

	transparium
		name = "transparium"
		id = "transparium"
		result = "transparium"
		required_reagents = list("oculine" = 1, "juice_carrot" = 1, "luminol" = 1, "silicate" = 1, "vtonic" = 1)
		result_amount = 1
		mix_phrase = "The solution fizzes and begins losing color."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		hidden = TRUE

	diluted_transparium
		name = "diluted transparium"
		id = "diluted_transparium"
		result = "diluted_transparium"
		required_reagents = list("transparium" = 1, "water" = 2)
		result_amount = 3
		mix_phrase = "The solution gains a slight blue hue."
		hidden = TRUE

	expresso
		name = "expresso"
		id = "expresso"
		result = "expresso"
		required_reagents = list("espresso" = 1, "methamphetamine" = 3)
		result_amount = 3
		mix_phrase = "Irregardless and for all intense and purposes, the coffee becomes stupider."

	mimicillium
		name = "Mimicillium"
		id = "badmanjuice"
		result = "badmanjuice"
		required_reagents = list("transparium" = 1, "glitter" = 1, "port" = 1, "cholesterol" = 1 )
		result_amount = 2.5
		mix_phrase = "The mixture swirls and bubbles becoming blue, you can hear faint music emanating from the it."
		mix_sound = 'sound/misc/drinkfizz.ogg'
		hidden = TRUE

	bubsium
		name = "Bubsium"
		id = "bubs"
		result = "bubs"
		required_reagents = list("bee" = 2, "cholesterol" = 1, "pepperoni" = 1, "bourbon" = 1)
		result_amount = 3
		mix_phrase = "The mixture turns yellowish and emits a loud grumping sound"
		mix_sound = 'sound/misc/drinkfizz.ogg'
		hidden = TRUE

	flubber
		name = "Liquified Space Rubber"
		id = "flubber"
		result = "flubber"
		required_reagents = list("rubber" = 2, "george_melonium" = 1, "sorium" = 1, "superlube" = 1, "radium" = 1)
		result_amount = 5
		mix_phrase = "The mixture congeals and starts to vibrate <b>powerfully!</b>"
		mix_sound = 'sound/misc/boing/6.ogg'
		hidden = TRUE

	calcium_carbonate //CaCl2 + Na2CO3 -> CaCO3 + 2NaCl
		name = "calcium carbonate"
		id = "calcium_carbonate"
		result = "calcium_carbonate"
		required_reagents = list("calcium" = 1, "chlorine" = 2, "sodium" = 2, "carbon" = 1, "oxygen" = 3)
		result_amount = 1
		mix_phrase = "A white solid precipitates out of the solution."
		mix_sound = 'sound/misc/fuse.ogg'

		on_reaction(var/datum/reagents/holder, created_volume)
			holder.add_reagent("salt", created_volume * 2,,holder.total_temperature, chemical_reaction = TRUE, chem_reaction_priority = 2)

	gypsum //H2SO4 + CaCO3 -> CaSO4 + H2O + CO2
		name = "calcium sulfate"
		id = "gypsum"
		result = "gypsum"
		required_reagents = list("acid" = 1, "calcium_carbonate" = 1)
		result_amount = 1
		mix_phrase = "The mixture bubbles fervently."

		on_reaction(var/datum/reagents/holder, created_volume)
			holder.add_reagent("water", created_volume,,holder.total_temperature, chemical_reaction = TRUE, chem_reaction_priority = 2)

	chalk //"pastels also contain clays and oils for binding, and strong pigments" some website i found
		name = "chalk"
		id = "chalk"
		result = "chalk"
		required_reagents = list("gypsum" = 4, "oil" = 1)
		result_amount = 5
		mix_phrase = "The paste seems sticky. Maybe this'll let pigments bind to it easier?"

	green_goop
		name = "Strange Green Goop"
		id = "green_goop"
		result = "green_goop"
		required_reagents = list("ash" = 1, "ectoplasm" = 1, "salt" = 1)
		result_amount = 3
		mix_phrase = "A strange green goopy liquid forms in the container."

	sakuride
		name = "sakuride"
		id = "sakuride"
		result = "sakuride"
		required_reagents = list("love" = 1,"tea" = 1, "colors" = 1)
		result_amount = 3
		mix_phrase = "The substance emits the sweet scent of cherryblossoms!"

	lime //CaCO3 -> CaO + CO2
		name = "calcium oxide"
		id = "lime"
		result = "lime"
		required_reagents = list("calcium_carbonate" = 1)
		result_amount = 1
		min_temperature = T0C + 600 //actually synthesises at 825c/1090k but that wont work so lets put it down to an achievable num
		mix_phrase = "The white powder settles into little clusters of powder."
		mix_sound = 'sound/misc/fuse.ogg'

	silicon_dioxide //Na2Si3O7 + H2SO4 -> 3SiO2 + Na2SO4 + H2O
		name = "silicon dioxide"
		id = "silicon_dioxide"
		result = "silicon_dioxide"
		required_reagents = list("sodium" = 2, "silicon" = 3, "oxygen" = 7, "acid" = 1)
		result_amount = 3
		mix_phrase = "The white flakes turn into a white powder."
		on_reaction(var/datum/reagents/holder, created_volume)
			holder.add_reagent("water", created_volume / 3,,holder.total_temperature, chemical_reaction = TRUE, chem_reaction_priority = 2)
			holder.add_reagent("sodium_sulfate", created_volume / 3,,holder.total_temperature, chemical_reaction = TRUE, chem_reaction_priority = 3)

	perfect_cement //lime, alumina, magnesia, iron (iii) oxide, calcium sulfate, sulfur trioxide
		name = "perfect cement"
		id = "perfect_cement"
		result = "perfect_cement"
		required_reagents = list("lime" = 1, "magnesium" = 1, "thermite" = 1, "gypsum" = 1, "oxygen" = 4, "sulfur" = 1) //thermite as iron (iii) oxide + alumina
		result_amount = 9 //18
		mix_phrase = "The mixture of particles settles together with so much ease that it seems like it has been waiting for this moment for a long time."
		mix_sound = 'sound/misc/fuse.ogg'

	good_cement //lime, alumina, magnesia, iron (iii) oxide, calcium sulfate
		name = "good cement"
		id = "good_cement"
		result = "good_cement"
		required_reagents = list("lime" = 1, "magnesium" = 1, "thermite" = 1, "gypsum" = 1, "oxygen" = 1) //thermite as iron (iii) oxide + alumina
		result_amount = 5 //14
		mix_phrase = "The mixture of particles settles together with ease."
		mix_sound = 'sound/misc/fuse.ogg'
		inhibitors = list("sulfur" = 1)

	okay_cement //lime, alumina, magnesia, iron (iii) oxide
		name = "okay cement"
		id = "okay_cement"
		result = "okay_cement"
		required_reagents = list("lime" = 1, "magnesium" = 1, "thermite" = 1, "oxygen" = 1) //thermite as iron (iii) oxide + alumina
		result_amount = 4 //13
		mix_phrase = "The mixture of particles settles together complacently."
		mix_sound = 'sound/misc/fuse.ogg'
		inhibitors = list("gypsum" = 1)

	poor_cement //lime, alumina, iron (iii) oxide
		name = "poor cement"
		id = "poor_cement"
		result = "poor_cement"
		required_reagents = list("lime" = 1, "thermite" = 1) //thermite as iron (iii) oxide + alumina
		result_amount = 2 //
		mix_phrase = "The mixture of particles settles together... barely."
		mix_sound = 'sound/misc/fuse.ogg'
		inhibitors = list("magnesium" = 1)

	perfect_concrete
		name = "perfect concrete"
		id = "perfect_concrete"
		result = "perfect_concrete"
		mix_phrase = "The mixture comes together smoothly... you feel like you've witnessed something great."
		required_reagents = list("perfect_cement" = 1, "silicon_dioxide" = 5, "water" = 1)
		result_amount = 7

	good_concrete
		name = "good concrete"
		id = "good_concrete"
		result = "good_concrete"
		mix_phrase = "The mixture comes together smoothly."
		required_reagents = list("good_cement" = 1, "silicon_dioxide" = 5, "water" = 1)
		result_amount = 7

	okay_concrete
		name = "okay concrete"
		id = "okay_concrete"
		result = "okay_concrete"
		mix_phrase = "The mixture comes together."
		required_reagents = list("okay_cement" = 1, "silicon_dioxide" = 5, "water" = 1)
		result_amount = 7

	poor_concrete
		name = "poor concrete"
		id = "poor concrete"
		result = "poor_concrete"
		mix_phrase = "The mixture comes together slowly. It doesn't seem like it wants to be here."
		required_reagents = list("poor_cement" = 1, "silicon_dioxide" = 5, "water" = 1)
		result_amount = 7

	triplepissed
		name = "Triple Pissed"
		id = "triple_pissed"
		result = "triplepissed"
		required_reagents = list("bathsalts" = 1, "beff" = 1, "capsaicin" = 1)
		mix_phrase = "The mixture starts to froth and glows a furious red!"
		result_amount = 3
		hidden = TRUE

	mirabilis
		name = "Mirabilis"
		id = "mirabilis"
		result = "mirabilis"
		required_reagents = list("flockdrone_fluid" = 1, "port" = 1, "oculine" = 1)
		mix_phrase = "The mixture emits a sudden whine of static and forms into swirling, many faceted shapes that hurt to look at."
		result_amount = 2
		mix_sound = 'sound/effects/radio_sweep1.ogg'

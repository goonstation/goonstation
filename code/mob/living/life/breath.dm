
/datum/lifeprocess/breath
	var/breathtimer = 0
	var/breathstate = 0

	//consider these temporary...hopefully
	proc/update_oxy(var/on)
		if (human_owner)
			human_owner.hud.update_oxy_indicator(on)
		if (critter_owner)
			critter_owner.hud.set_suffocating(on)

	proc/update_toxy(var/on)
		if (human_owner)
			human_owner.hud.update_tox_indicator(on)
		if (critter_owner)
			critter_owner.hud.update_tox_indicator(on)

	process(var/datum/gas_mixture/environment)
		if(isdead(owner))
			return ..()

		//special (read: stupid) manual breathing stuff. weird numbers are so that messages don't pop up at the same time as manual blinking ones every time
		if (manualbreathing && human_owner)
			breathtimer++
			switch(breathtimer)
				if (0 to 15)
					breathe(environment)
				if (34)
					boutput(owner, "<span class='alert'>You need to breathe!</span>")
				if (35 to 51)
					if (prob(5)) owner.emote("gasp")
				if (52)
					boutput(owner, "<span class='alert'>Your lungs start to hurt. You really need to breathe!</span>")
				if (53 to 61)
					update_oxy(1)
					owner.take_oxygen_deprivation(breathtimer/12)
				if (62)
					update_oxy(1)
					boutput(owner, "<span class='alert'>Your lungs are burning and the need to take a breath is almost unbearable!</span>")
					owner.take_oxygen_deprivation(10)
				if (63 to INFINITY)
					update_oxy(1)
					owner.take_oxygen_deprivation(breathtimer/6)
		else // plain old automatic breathing
			breathe(environment)

		if (istype(owner.loc, /obj/))
			var/obj/location_as_object = owner.loc
			location_as_object.handle_internal_lifeform(owner, 0)
		..()

	proc/breathe(datum/gas_mixture/environment)
		var/mult = get_multiplier()

		var/atom/underwater = 0
		if (isturf(owner.loc))
			var/turf/T = owner.loc
			if (istype(T, /turf/space/fluid))
				underwater = T
			else if (T.active_liquid)
				var/obj/fluid/F = T.active_liquid

				var/depth_to_breathe_from = depth_levels.len
				if (owner.lying)
					depth_to_breathe_from = depth_levels.len-1

				if (F.amt >= depth_levels[depth_to_breathe_from])
					underwater = F
					if (owner.is_submerged != 4)
						owner.show_submerged_image(4)

			else if (T.active_airborne_liquid)
				if (!(human_owner?.wear_mask && (human_owner?.wear_mask.c_flags & BLOCKSMOKE || (human_owner?.wear_mask.c_flags & MASKINTERNALS && human_owner?.internal))))
					//underwater = T.active_airborne_liquid
					var/obj/fluid/F = T.active_airborne_liquid
					F.force_mob_to_ingest(owner)
				else
					if (!owner.clothing_protects_from_chems())
						var/obj/fluid/airborne/F = T.active_airborne_liquid
						F.just_do_the_apply_thing(owner, hasmask = 1)

		else if (istype(owner.loc, /mob/living/object))
			return // no breathing inside possessed objects
		else if (istype(owner.loc, /obj/machinery/atmospherics/unary/cryo_cell))
			return

		//if (istype(loc, /obj/machinery/clonepod)) return

		if (owner.reagents)
			if (owner.reagents.has_reagent("lexorin") || HAS_MOB_PROPERTY(owner, PROP_REBREATHING)) return

		// Changelings generally can't take OXY/LOSEBREATH damage...except when they do.
		// And because they're excluded from the breathing procs, said damage didn't heal
		// on its own, making them essentially mute and perpetually gasping for air.
		// Didn't seem like a feature to me (Convair880).
		// If you have the breathless effect, same deal - you'd never heal oxy damage
		// If your mutant race doesn't need oxygen from breathing, ya no losebreath
		// so, now you do
		if (ischangeling(owner) || (owner.bioHolder && owner.bioHolder.HasEffect("breathless") || (human_owner?.mutantrace && !human_owner?.mutantrace.needs_oxy)))
			if (owner.losebreath)
				owner.losebreath = 0
			if (owner.get_oxygen_deprivation())
				owner.take_oxygen_deprivation(-50 * mult)
			return

		if (underwater)
			if (human_owner?.mutantrace && human_owner?.mutantrace.aquatic)
				return
			if (prob(25) && owner.losebreath > 0)
				boutput(owner, "<span class='alert'>You are drowning!</span>")

		var/datum/air_group/breath = null
		// HACK NEED CHANGING LATER
		//if (src.oxymax == 0 || (breathtimer > 15))
		if (breathtimer > 15)
			owner.losebreath += (0.7 * mult)

		if (owner.grabbed_by && owner.grabbed_by.len)
			breath = get_breath_grabbed_by(BREATH_VOLUME)

		if (!breath)
			if (owner.losebreath>0) //Suffocating so do not take a breath
				owner.losebreath -= (1.3 * mult)
				owner.losebreath = max(owner.losebreath,0)
				if (prob(75)) //High chance of gasping for air
					if (underwater)
						owner.emote("gurgle")
					else
						owner.emote("gasp")
				if (isobj(owner.loc))
					var/obj/location_as_object = owner.loc
					location_as_object.handle_internal_lifeform(owner, 0)
				if (owner.losebreath <= 0)
					boutput(owner, "<span class='notice'>You catch your breath.</span>")
			else
				//First, check for air from internal atmosphere (using an air tank and mask generally)
				breath = get_breath_from_internal(BREATH_VOLUME)

				//No breath from internal atmosphere so get breath from location
				if (!breath)
					if (isobj(owner.loc))
						var/obj/location_as_object = owner.loc
						breath = location_as_object.handle_internal_lifeform(owner, BREATH_VOLUME)
					else if (isturf(owner.loc))
						var/breath_moles = (TOTAL_MOLES(environment)*BREATH_PERCENTAGE)

						breath = owner.loc.remove_air(breath_moles)

				else //Still give containing object the chance to interact
					underwater = 0 // internals override underwater state
					if (isobj(owner.loc))
						var/obj/location_as_object = owner.loc
						location_as_object.handle_internal_lifeform(owner, 0)

		handle_breath(breath, underwater, mult = mult)

		if (breath)
			owner.loc.assume_air(breath)


	proc/get_breath_grabbed_by(volume_needed)
		.= null
		for(var/obj/item/grab/force_mask/G in owner.grabbed_by)
			.= G.get_breath(volume_needed)
			if (.)
				break

	proc/get_breath_from_internal(volume_needed)
		if (human_owner?.internal)
			if (!owner.contents.Find(human_owner.internal))
				human_owner?.internal = null
			if (!human_owner?.wear_mask || !(human_owner?.wear_mask.c_flags & MASKINTERNALS) )
				human_owner?.internal = null
			if (human_owner?.internal)
				if (human_owner?.internals)
					human_owner?.internals.icon_state = "internal1"
				for (var/obj/ability_button/tank_valve_toggle/T in human_owner?.internal.ability_buttons)
					T.icon_state = "airon"
				return human_owner?.internal.remove_air_volume(volume_needed)
			else
				if (human_owner?.internals)
					human_owner?.internals.icon_state = "internal0"

		return null

	proc/handle_breath(datum/gas_mixture/breath, var/atom/underwater = 0, var/mult = 1) //'underwater' really applies for any reagent that gets deep enough. but what ever
		if (owner.nodamage) return
		var/area/A = get_area(owner)
		if( A && A.sanctuary )
			return
		// Looks like we're in space
		// or with recent atmos changes, in a room that's had a hole in it for any amount of time, so now we check src.loc
		if (underwater || !breath || (TOTAL_MOLES(breath) == 0))
			if (istype(owner.loc, /turf/space))
				owner.take_oxygen_deprivation(6 * mult)
			else
				owner.take_oxygen_deprivation(3 * mult)
			update_oxy(1)

			//consume some reagents if we drowning
			if (underwater && (owner.get_oxygen_deprivation() > 40 || underwater.type == /obj/fluid/airborne))
				if (istype(underwater,/obj/fluid))
					var/obj/fluid/F = underwater
					F.force_mob_to_ingest(owner)// * mult
				else if (istype(underwater, /turf/space/fluid))
					var/turf/space/fluid/F = underwater
					F.force_mob_to_ingest(owner)// * mult


			return 0

		if (owner.health < 0 || (human_owner?.organHolder && human_owner?.organHolder.get_working_lung_amt() == 0)) //We aren't breathing.
			return 0

		var/has_cyberlungs = (human_owner?.organHolder && (human_owner.organHolder.left_lung && human_owner.organHolder.right_lung) && (human_owner.organHolder.left_lung.robotic && human_owner.organHolder.right_lung.robotic)) //gotta prevent null pointers...
		var/safe_oxygen_min = 17 // Minimum safe partial pressure of O2, in kPa
		//var/safe_oxygen_max = 140 // Maximum safe partial pressure of O2, in kPa (Not used for now)
		var/safe_co2_max = 9 // Yes it's an arbitrary value who cares?
		var/safe_toxins_max = 0.4
		var/SA_para_min = 1
		var/SA_sleep_min = 5
		var/oxygen_used = 0
		var/breath_pressure = (TOTAL_MOLES(breath)*R_IDEAL_GAS_EQUATION*breath.temperature)/BREATH_VOLUME
		var/fart_smell_min = 0.69 // don't ask ~warc
		var/fart_vomit_min = 6.9
		var/fart_choke_min = 16.9

		//Partial pressure of the O2 in our breath
		var/O2_pp = (breath.oxygen/TOTAL_MOLES(breath))*breath_pressure
		// Same, but for the toxins
		var/Toxins_pp = (breath.toxins/TOTAL_MOLES(breath))*breath_pressure
		// And CO2, lets say a PP of more than 10 will be bad (It's a little less really, but eh, being passed out all round aint no fun)
		var/CO2_pp = (breath.carbon_dioxide/TOTAL_MOLES(breath))*breath_pressure


		//change safe gas levels for cyberlungs
		if (has_cyberlungs)
			safe_oxygen_min = 9
			safe_co2_max = 18
			safe_toxins_max = 5		//making it a lot higher than regular, because even doubling the regular value is pitifully low. This is still reasonably low, but it might be noticable

		if (O2_pp < safe_oxygen_min) 			// Too little oxygen
			if (prob(20))
				if (underwater)
					owner.emote("gurgle")
				else
					owner.emote("gasp")
			if (O2_pp > 0)
				var/ratio = round(safe_oxygen_min/(O2_pp + 0.1))
				owner.take_oxygen_deprivation(min(5*ratio, 5)) // Don't fuck them up too fast (space only does 7 after all!)
				oxygen_used = breath.oxygen*ratio/6
			else
				owner.take_oxygen_deprivation(3 * mult)
			update_oxy(1)
		else 									// We're in safe limits
			//if (breath.oxygen/TOTAL_MOLES(breath) >= 0.95) //high oxygen concentration. lets slightly heal oxy damage because it feels right
			//	take_oxygen_deprivation(-6 * mult)

			owner.take_oxygen_deprivation(-6 * mult)
			oxygen_used = breath.oxygen/6
			update_oxy(0)

		breath.oxygen -= oxygen_used
		breath.carbon_dioxide += oxygen_used

		if (CO2_pp > safe_co2_max)
			if (!owner.co2overloadtime) // If it's the first breath with too much CO2 in it, lets start a counter, then have them pass out after 12s or so.
				owner.co2overloadtime = world.time
			else if (world.time - owner.co2overloadtime > 120)
				owner.changeStatus("paralysis", (4 * mult) SECONDS)
				owner.take_oxygen_deprivation(1.8 * mult) // Lets hurt em a little, let them know we mean business
				if (world.time - owner.co2overloadtime > 300) // They've been in here 30s now, lets start to kill them for their own good!
					owner.take_oxygen_deprivation(7 * mult)
			if (prob(20)) // Lets give them some chance to know somethings not right though I guess.
				owner.emote("cough")
		else
			owner.co2overloadtime = 0

		if (Toxins_pp > safe_toxins_max) // Too much toxins
			var/ratio = breath.toxins/safe_toxins_max
			owner.take_toxin_damage(min(ratio * 125,20) * mult)
			update_toxy(1)
		else
			update_toxy(0)

		if (length(breath.trace_gases))	// If there's some other shit in the air lets deal with it here.
			for (var/datum/gas/sleeping_agent/SA in breath.trace_gases)
				var/SA_pp = (SA.moles/TOTAL_MOLES(breath))*breath_pressure
				if (SA_pp > SA_para_min) // Enough to make us paralysed for a bit
					owner.changeStatus("paralysis", 5 SECONDS)
					if (SA_pp > SA_sleep_min) // Enough to make us sleep as well
						owner.sleeping = max(owner.sleeping, 2)
				else if (SA_pp > 0.01)	// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
					if (prob(20))
						owner.emote(pick("giggle", "laugh"))

		var/FARD_pp = (breath.farts/TOTAL_MOLES(breath))*breath_pressure
		if (prob(15) && (FARD_pp > fart_smell_min))
			boutput(owner, "<span class='alert'>Smells like someone [pick("died","soiled themselves","let one rip","made a bad fart","peeled a dozen eggs")] in here!</span>")
			if ((FARD_pp > fart_vomit_min) && prob(50))
				owner.visible_message("<span class='notice'>[owner] vomits from the [pick("stink","stench","awful odor")]!!</span>")
				owner.vomit()
		if (FARD_pp > fart_choke_min)
			owner.take_oxygen_deprivation(6.9 * mult)
			if (prob(20))
				owner.emote("cough")
				if (prob(30))
					boutput(owner, "<span class='alert'>Oh god it's so bad you could choke to death in here!</span>")


			//cyber lungs beat radiation. Is there anything they can't do?
			if (!has_cyberlungs)
				for (var/datum/gas/rad_particles/RV in breath.trace_gases)
					owner.changeStatus("radiation", RV.moles, 2 SECONDS)

		if (human_owner)
			if (breath.temperature > min(human_owner.organHolder.left_lung ? human_owner.organHolder.left_lung.temp_tolerance : INFINITY, human_owner.organHolder.right_lung ? human_owner.organHolder.right_lung.temp_tolerance : INFINITY) && !human_owner.is_heat_resistant()) // Hot air hurts :(
				//checks the temperature threshold for each lung, ignoring missing ones. the case of having no lungs is handled in handle_breath.
				var/lung_burn_left = min(max(breath.temperature - human_owner.organHolder.left_lung?.temp_tolerance, 0) / 3, 10)
				var/lung_burn_right = min(max(breath.temperature - human_owner.organHolder.right_lung?.temp_tolerance, 0) / 3, 10)
				if (breath.temperature > (human_owner.organHolder.left_lung ? human_owner.organHolder.left_lung.temp_tolerance : INFINITY))
					human_owner.TakeDamage("chest", 0, (lung_burn_left / 2) + 3, 0, DAMAGE_BURN)
					if(prob(20))
						boutput(human_owner, "<span class='alert'>This air is searing hot!</span>")
						if (prob(80))
							human_owner.organHolder.damage_organ(0, lung_burn_left + 6, 0, "left_lung")
				if (breath.temperature > (human_owner.organHolder.right_lung ? human_owner.organHolder.right_lung.temp_tolerance : INFINITY))
					human_owner.TakeDamage("chest", 0, (lung_burn_right / 2) + 3, 0, DAMAGE_BURN)
					if(prob(20))
						boutput(human_owner, "<span class='alert'>This air is searing hot!</span>")
						if (prob(80))
							human_owner.organHolder.damage_organ(0, lung_burn_right + 6, 0, "right_lung")

				human_owner.hud.update_fire_indicator(1)
				if (prob(4))
					boutput(human_owner, "<span class='alert'>Your lungs hurt like hell! This can't be good!</span>")
					//src.contract_disease(new/datum/ailment/disability/cough, 1, 0) // cogwerks ailment project - lung damage from fire

			else
				human_owner.hud.update_fire_indicator(0)


		//Temporary fixes to the alerts.

		return 1


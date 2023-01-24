// Stuff for O.Chem
// Fossil fuels, volatile organics, fats and fucky solvents can go here

ABSTRACT_TYPE(/datum/reagent/organic)

/datum/reagent/organic
	name = "crude organic fluid"
	id = "organic"
	description = "An unknown soup of organic chemicals with an oily sheen."
	taste = "earthy"
	fluid_r = 20
	fluid_g = 50
	fluid_b = 0
	transparency = 220
	value = 3
	viscosity = 0.8
	hunger_value = -0.1
	thirst_value = -0.1
	random_chem_blacklisted = 1 //this is pobably temporarily 1 just so I can work out the details
	can_crack = 1


	petroleum // the crude black milk of mother natures chapped tit
		name = "petroleum"
		id = "petroleum"
		description = "A yellowish-black liquid found in geological formations beneath the Earth's surface."
		taste = "acrid"
		fluid_r = 15
		fluid_g = 10
		fluid_b = 0
		transparency = 220
		viscosity = 0.9
		hunger_value = -0.1
		thirst_value = -0.1

		crack(var/amount = 1)
			if(!holder)
				return
			holder.remove_reagent(id,amount)
			if(holder.has_reagent("oxygen"))
				holder.remove_reagent("oxygen",amount)
				return
			if(holder.total_temperature >= (T0C+1000))
				holder.add_reagent("ethylene",(amount*4/3))
				return
			if(holder.total_temperature >= (T0C+600))
				holder.add_reagent("fuel",(amount))
				holder.add_reagent("bitumen",(amount/2))
				return

	bitumen
		name = "bitumen"
		id = "bitumen"
		description = "A dark, viscous oil rich in sulfur."
		taste = "brimstone"
		transparency = 250
		fluid_r = 5
		fluid_g = 0
		fluid_b = 10

		crack(var/amount = 1)
			if(!holder)
				return
			if(holder.total_temperature <= (T0C+1500))
				return
			holder.remove_reagent(id,amount)
			if(holder.has_reagent("oxygen"))
				holder.remove_reagent("oxygen",amount)
				return
			if(holder.has_reagent("hydrogen"))
				holder.remove_reagent("hydrogen",amount*2)
				holder.add_reagent("badgrease",(amount))
				return
			else
				holder.add_reagent("fuel",(amount/2))
				holder.add_reagent("potash",(amount/2)) //replace this with pitch tar, and then pitch tar to ash.
				return

	ethylene
		name = "ethylene"
		id = "ethylene"
		description = "A colorless flammable gas."
		taste = "sweet, musky"
		transparency = 5
		fluid_r = 255
		fluid_g = 255
		fluid_b = 255

		crack(var/amount = 1)
			if(!holder)
				return
			if(volume<amount)
				amount = volume
			if(holder.has_reagent("oxygen"))
				holder.remove_reagent("oxygen",amount)
				holder.remove_reagent(id,amount)
				return
			if(holder.has_reagent("hydrogen"))
				holder.remove_reagent(id,amount)
				holder.remove_reagent("hydrogen",amount*2)
				holder.add_reagent("ethanol",(amount))
				return

	hambrein // an extract of hamburgris
		name = "hambrein"
		id = "hambrein"
		description = "A colorless, odorless alcohol derrived from hamburgris."
		taste = "neutral"
		fluid_r = 230
		fluid_g = 230
		fluid_b = 230
		transparency = 50
		viscosity = 0.3
		depletion_rate = 0.2

		on_mob_life(var/mob/M, var/mult = 1)
			if(!M) M = holder.my_atom
			if(prob(45))
				M.HealDamage("All", 1 * mult, 0)
			if(M.bodytemperature < M.base_body_temp)
				M.bodytemperature = min(M.base_body_temp, M.bodytemperature+(5 * mult))
			..()
			if(prob(25))
				holder.add_reagent(pick("hambrinol","hambroxide"), depletion_rate * mult)
			return


	hambrinol // an oxidative product of hambrein
		name = "hambrinol"
		id = "hambrinol"
		description = "A powerfully musky aromatic compound."
		taste = "musky"
		fluid_r = 230
		fluid_g = 215
		fluid_b = 150
		transparency = 50
		viscosity = 0.4
		depletion_rate = 0.05

		on_mob_life(var/mob/M, var/mult = 1)
			if(!M) M = holder.my_atom
			//make critters around this dork attack the dork. that's how it do.
			..()


	hambroxide // another oxidative product of hambrein
		name = "hambroxide"
		id = "hambroxide"
		description = "An overwhelmingly meaty aromatic compound."
		taste = "hambery"
		fluid_r = 230
		fluid_g = 230
		fluid_b = 230
		transparency = 100
		viscosity = 0.3
		depletion_rate = 0.05
		overdose = 2 //very small overdose threshold, but really it just makes you puke it all up
		var/other_purgative = "hambrinol"

		do_overdose(severity, mob/M, mult)
			boutput(M, "<span class='alert'>You feel overwhelmed by the powerful fragrance.</span>")
			M.setStatusMin("stunned", 2 SECONDS)
			M.setStatusMin("weakened", 2 SECONDS)
			if(prob(25*severity))
				var/amount = holder.get_reagent_amount(src.id)
				var/other_amount = holder.get_reagent_amount(src.other_purgative)
				for(var/mob/O in viewers(M, null))
					O.show_message(text("<span class='alert'>[] vomits on the floor profusely!</span>", M), 1)
				playsound(M.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
				var/obj/decal/cleanable/C = make_cleanable(/obj/decal/cleanable/vomit,M.loc)
				C.reagents.add_reagent("[src.id]", amount)
				C.reagents.add_reagent("[other_purgative]", other_amount)
				holder.remove_reagent("[src.id]", amount)
				holder.remove_reagent("[other_purgative]", other_amount)
			..()

		on_mob_life(var/mob/M, var/mult = 1)
			if(!M) M = holder.my_atom

			..()

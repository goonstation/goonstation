ABSTRACT_TYPE(/datum/plant/artifact)
/datum/plant/artifact
	name = "Unknown"
	plant_icon = 'icons/obj/hydroponics/plants_alien.dmi'
	cantscan = 0
	vending = 0

// non-harvestables

/datum/plant/artifact/pukeplant
	name = "Puker"
	growthmode = "weed"
	override_icon_state = "Puker"
	unique_seed = /obj/item/seed/alien/pukeplant
	nothirst = 1
	starthealth = 80
	growtime = 60
	harvtime = 140
	harvestable = 0
	endurance = 40
	special_proc = 1

	HYPspecial_proc(var/obj/machinery/plantpot/POT)
		..()
		if (.) return
		if (POT.get_current_growth_stage() >= HYP_GROWTH_HARVESTABLE && prob(20))
			POT.visible_message(SPAN_ALERT("<b>[POT.name]</b> vomits profusely!"))
			playsound(POT, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, TRUE)
			if(!locate(/obj/decal/cleanable/vomit) in get_turf(POT)) make_cleanable( /obj/decal/cleanable/vomit,get_turf(POT))

/datum/plant/artifact/peeker
	name = "Peeker"
	growthmode = "weed"
	override_icon_state = "Peeker"
	unique_seed = /obj/item/seed/alien/peeker
	nothirst = 1
	starthealth = 120
	growtime = 20
	harvtime = 100
	harvestable = 0
	endurance = 60
	special_proc = 1
	var/focused = null
	var/focus_level = 0

	proc/stare_extreme(var/mob/living/M, var/obj/machinery/plantpot/POT)
		if(!M || !(M in view(7,POT)) || !isalive(M))
			src.focus_level--
			if(src.focus_level < 0)
				src.focused = null
				src.focus_level = 0
			return 0
		var/how = pick("intently", "directly", "fixedly", "unflinchingly", "directly", "unwaveringly", "petrifyingly", "longingly", "determinedly", "hungrily", "grodily")
		POT.visible_message(SPAN_ALERT("<b>[POT.name]</b> stares [how] at [src.focused]."))
		if(focus_level <= 1)
			M.do_disorient(10, knockdown = 0.7 SECONDS, stunned = 0, unconscious = 0, disorient = 0.7 SECONDS, remove_stamina_below_zero = 0)
		else if(focus_level <= 2)
			M.do_disorient(30, knockdown = 1.5 SECONDS, stunned = 0, unconscious = 0, disorient = 1.5 SECONDS, remove_stamina_below_zero = 0)
			M.take_brain_damage(5)
			boutput(M, SPAN_ALERT("You feel a headache."))
		else if(focus_level <= 3)
			M.do_disorient(30, knockdown = 2 SECONDS, stunned = 0, unconscious = 0, disorient = 2 SECONDS, remove_stamina_below_zero = 0)
			M.take_brain_damage(7)
			M.TakeDamage("head", 5, 0)
			boutput(M, SPAN_ALERT("Your head is pounding with extreme pain."))
		else if(focus_level <= 4)
			M.do_disorient(50, knockdown = 2.5 SECONDS, stunned = 0, unconscious = 0.5 SECONDS, disorient = 2.5 SECONDS, remove_stamina_below_zero = 0)
			M.take_brain_damage(7)
			blood_slash(M, 3)
			M.TakeDamage("head", 10, 0)
			boutput(M, SPAN_ALERT("The gaze seems to almost burrow into your skull. You feel like your head is going to split open."))
		else if(focus_level <= 5)
			M.do_disorient(80, knockdown = 3 SECONDS, stunned = 0, unconscious = 1 SECONDS, disorient = 3 SECONDS, remove_stamina_below_zero = 0)
			blood_slash(M, 5)
			M.TakeDamage("head", 15, 0)
			boutput(M, SPAN_ALERT("The intensity of the plant's gaze makes you feel like your head is going to <i>literally</i> split open."))
		else if(focus_level <= 6)
			boutput(M, "<span style=\"color:red;font-size:3em\">Run.</span>")
		else
			logTheThing(LOG_COMBAT, M, "was gibbed by [src] ([src.type]) at [log_loc(M)].")
			if (M.organHolder)
				var/obj/brain = M.organHolder.drop_organ("brain")
				brain?.throw_at(get_edge_cheap(get_turf(M), pick(cardinal)), 16, 3)
				var/obj/head = M.organHolder.drop_organ("head")
				if(head)
					qdel(head)
				else
					M.gib()
			else if(istype(M, /mob/living/silicon/robot))
				var/mob/living/silicon/robot/R = M
				R.eject_brain(fling = TRUE)
				R.update_appearance()
				R.TakeDamage("head", 420, 0)
			else
				M.gib()
			M.visible_message(SPAN_ALERT("<b>[M]'s head explodes!</b>"))
			src.focused = null
			src.focus_level = 1
			return 1
		src.focus_level++
		return 1

	HYPspecial_proc(var/obj/machinery/plantpot/POT)
		..()
		if (.) return
		var/datum/plantgenes/DNA = POT.plantgenes

		var/pr = 20
		if(src.focused)
			pr += 10

		if (POT.get_current_growth_stage() >= HYP_GROWTH_MATURED && prob(pr))
			if(focused)
				if(stare_extreme(focused, POT))
					return

			var/extreme_start = prob(max(0, DNA?.get_effective_value("potency") / 30))
			var/list/stuffnearby = list()
			for (var/mob/living/X in view(7,POT)) stuffnearby.Add(X)
			if(!extreme_start)
				for (var/obj/item/X in view(7,POT)) stuffnearby.Add(X)
			if (length(stuffnearby) >= 1)
				var/thing = pick(stuffnearby)
				POT.visible_message(SPAN_ALERT("<b>[POT.name]</b> stares at [thing]."))
				if(extreme_start)
					src.focused = thing
					src.focus_level = 1

// harvestables

/datum/plant/artifact/dripper
	name = "Dripper"
	override_icon_state = "Dripper"
	crop = /obj/item/reagent_containers/food/snacks/plant/purplegoop
	unique_seed = /obj/item/seed/alien/dripper
	starthealth = 4
	growtime = 15
	harvtime = 45
	cropsize = 3
	harvests = 6
	endurance = 0
	mutations = list(/datum/plantmutation/dripper/leaker)
	assoc_reagents = list("plasma")

/datum/plant/artifact/rocks
	name = "Rock"
	override_icon_state = "Rocks"
	crop = /obj/item/raw_material/rock
	unique_seed = /obj/item/seed/alien/rocks
	starthealth = 80
	growtime = 220
	harvtime = 500
	cropsize = 3
	harvests = 8
	endurance = 40
	force_seed_on_harvest = 1
	mutations = list(/datum/plantmutation/rocks/syreline,/datum/plantmutation/rocks/bohrum,/datum/plantmutation/rocks/mauxite,/datum/plantmutation/rocks/uqill)

/datum/plant/artifact/litelotus
	name = "Light Lotus"
	override_icon_state = "Litelotus"
	crop = /obj/item/reagent_containers/food/snacks/plant/glowfruit
	unique_seed = /obj/item/seed/alien/litelotus
	starthealth = 30
	growtime = 300
	harvtime = 400
	cropsize = 1
	harvests = 1
	endurance = 20
	assoc_reagents = list("luminol")
	special_proc = 1

	HYPspecial_proc(obj/machinery/plantpot/POT)
		. = ..()
		if (.)
			return
		if (POT.get_current_growth_stage() < HYP_GROWTH_HARVESTABLE)
			return

		for (var/obj/machinery/plantpot/otherPot in oview(1, POT))
			if(!otherPot.current || otherPot.dead)
				continue
			var/datum/plant/other_growing = otherPot.current
			if (other_growing.simplegrowth || !otherPot.current_tick)
				otherPot.growth += 2
			else
				var/datum/plantgrowth_tick/manipulated_tick = otherPot.current_tick
				manipulated_tick.growth_rate += 2
				if(istype(otherPot.plantgenes,/datum/plantgenes/))
					var/datum/plantgenes/other_DNA = otherPot.plantgenes
					if(HYPCheckCommut(other_DNA,/datum/plant_gene_strain/photosynthesis))
						manipulated_tick.growth_rate += 4

/datum/plant/artifact/plasma
	name = "Plasma"
	override_icon_state = "Plasma"
	crop = /obj/critter/spore
	unique_seed = /obj/item/seed/alien/plasma
	starthealth = 20
	growtime = 180
	harvtime = 220
	cropsize = 2
	harvests = 1
	endurance = 10

/datum/plant/artifact/goldfish
	name = "Goldfish"
	override_icon_state = "Goldfish"
	crop = /obj/item/reagent_containers/food/snacks/goldfish_cracker
	unique_seed = /obj/item/seed/alien/goldfish
	starthealth = 40
	growtime = 80
	harvtime = 120
	cropsize = 4
	harvests = 6
	endurance = 30

/datum/plant/artifact/cat
	name = "Synthetic Cat"
	override_icon_state = "Cat"
	crop = /mob/living/critter/small_animal/cat/synth
	unique_seed = /obj/item/seed/alien/cat
	starthealth = 90 // 9 lives
	growtime = 100
	harvtime = 150
	endurance = 30
	special_proc = 1
	attacked_proc = 1
	harvestable = 0

	HYPspecial_proc(var/obj/machinery/plantpot/POT)
		..()
		if (.) return
		var/datum/plant/P = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes

		if (POT.get_current_growth_stage() >= HYP_GROWTH_MATURED && prob(16))
			playsound(POT,'sound/voice/animal/cat.ogg',30,TRUE,-1)
			POT.visible_message(SPAN_ALERT("<b>[POT.name]</b> meows!"))

		if (POT.growth > P.HYPget_growth_to_harvestable(DNA) + 10)
			var/mob/living/critter/small_animal/cat/synth/C = new(get_turf(POT))
			C.health = POT.health
			POT.visible_message(SPAN_NOTICE("The synthcat climbs out of the tray!"))
			POT.HYPdestroyplant()
			return

	HYPattacked_proc(var/obj/machinery/plantpot/POT,var/mob/user)
		..()
		if (.) return
		var/datum/plant/P = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes

		if (POT.growth < P.HYPget_growth_to_matured(DNA) + 10) return 0

		playsound(POT,'sound/voice/animal/cat_hiss.ogg',30,TRUE,-1)
		POT.visible_message(SPAN_ALERT("<b>[POT.name]</b> hisses!"))

/datum/plant/artifact/creeper
	name = "Creeper"
	unique_seed = /obj/item/seed/alien/creeper
	seedcolor = "#CC00FF"
	cropsize = 1
	nothirst = 1
	starthealth = 30
	growtime = 30
	harvtime = 100
	harvestable = 0
	endurance = 40
	isgrass = 1
	special_proc = 1
	genome = 8
	force_seed_on_harvest = -1
	stop_size_scaling = TRUE
	mutations = list(/datum/plantmutation/creeper/tumbling)
	//stabilizer is the bad commut for the plant here, toxic the good one
	commuts = list(/datum/plant_gene_strain/stabilizer, /datum/plant_gene_strain/invasive)

	HYPspecial_proc(var/obj/machinery/plantpot/POT)
		..()
		if (.) return
		var/damage_to_other_plants = 20 // the amount of damage the plant deals to other plants
		var/chance_to_damage = 33 // the chance per tick to damage plants or spread per tick.
		var/health_treshold_for_spreading = 50 // percentage amount of starting health of the plant needed to be able to spread

		var/datum/plant/current_planttype = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes
		// If the creeper got the invasive growth gene strain, we make it more capable of spreading
		if (HYPCheckCommut(DNA, /datum/plant_gene_strain/invasive))
			damage_to_other_plants += 5
			chance_to_damage += 17
			health_treshold_for_spreading -= 15
		// We check for the health treshold and if we have grown sufficiently
		if (POT.get_current_growth_stage() >= HYP_GROWTH_MATURED && POT.health > round(current_planttype.starthealth * health_treshold_for_spreading / 100) && prob(chance_to_damage))
			for (var/obj/machinery/plantpot/checked_plantpot in range(1,POT))
				var/datum/plant/growing = checked_plantpot.current
				// We don't try to destroy other creepers and cannot attack crystals
				if (!checked_plantpot.dead && growing && !istype(growing,/datum/plant/crystal) && !istype(growing, current_planttype))
					checked_plantpot.HYPdamageplant("physical", damage_to_other_plants, 1)
				else if (checked_plantpot.dead)
					checked_plantpot.HYPdestroyplant()
				//Seedless prevents the creeper to replant itself
				else if (!growing && !HYPCheckCommut(DNA, /datum/plant_gene_strain/seedless))
					//we create a new seed now
					var/obj/item/seed/temporary_seed = HYPgenerateseedcopy(DNA, current_planttype, POT.generation)
					//we now devolve the seed to not make tumbler spread like wildfire
					var/datum/plantgenes/New_DNA = temporary_seed.plantgenes
					New_DNA.mutation = null
					// now we are able to plant the seed
					checked_plantpot.HYPnewplant(temporary_seed)
					spawn(0.5 SECONDS)
						qdel(temporary_seed)
					break

// Weird Shit

/datum/plant/maneater
	name = "Man-Eating Plant"
	plant_icon = 'icons/obj/hydroponics/plants_alien.dmi'
	sprite = "Maneater"
	growthmode = "carnivore"
	unique_seed = /obj/item/seed/maneater
	genome = 12
	starthealth = 40
	growtime = 40
	harvtime = 250
	harvestable = 0
	endurance = 10
	special_proc = 1
	attacked_proc = 1
	vending = 0
	innate_commuts = list(/datum/plant_gene_strain/overpowering_genome, /datum/plant_gene_strain/temporary_splice_stabilizer, /datum/plant_gene_strain/reagent_blacklist)

	HYPspecial_proc(var/obj/machinery/plantpot/POT)
		..()
		if (.) return
		var/datum/plant/current_plant = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes
		if (POT.get_current_growth_stage() >= HYP_GROWTH_MATURED && prob(4))
			var/MEspeech = pick("Feed me!", "I'm hungryyyy...", "Give me blood!", "I'm starving!", "What's for dinner?")
			for(var/mob/M in hearers(POT, null)) M.show_message("<B>Man-Eating Plant</B> gurgles, \"[MEspeech]\"")
		if (POT.get_current_growth_stage() >= HYP_GROWTH_HARVESTABLE)
			var/mob/living/critter/plant/maneater/new_maneater = new(get_turf(POT))
			//Quality with the maneater is simulated a bit differently. It's calulated out of the endurance and potency-stat only
			var/simulated_quality = (rand(-5, 5) + DNA?.get_effective_value("potency") / 6 + DNA?.get_effective_value("endurance") / 9)
			var/simulated_quality_status = null
			if (HYPCheckCommut(DNA,/datum/plant_gene_strain/unstable) && prob(33))
				simulated_quality_status = "malformed"
				simulated_quality = rand(10,-10)
			else
				switch(simulated_quality)
					if(20 to INFINITY)
						if(prob(min(100, simulated_quality - 15)))
							simulated_quality_status = "jumbo"
							simulated_quality *= 2
					if(-9999 to -11)
						simulated_quality_status = "rotten"
						simulated_quality += -20
			new_maneater.name = HYPgenerate_produce_name(new_maneater, POT, current_plant, simulated_quality, simulated_quality_status, FALSE)
			new_maneater.HYPsetup_DNA(DNA, POT, current_plant, simulated_quality_status)
			POT.visible_message(SPAN_NOTICE("The man-eating plant climbs out of the tray!"))
			POT.HYPdestroyplant()
			return

	HYPattacked_proc(var/obj/machinery/plantpot/POT,var/mob/user)
		..()
		if (.) return
		if (POT.get_current_growth_stage() < HYP_GROWTH_MATURED) return 0

		var/MEspeech = pick("Hands off, asshole!","The hell d'you think you're doin'?!","You dick!","Bite me, motherfucker!")
		for(var/mob/O in hearers(POT, null))
			O.show_message("<B>Man-Eating Plant</B> gurgles, \"[MEspeech]\"", 1)
		boutput(user, SPAN_ALERT("The plant angrily bites you!"))
		random_brute_damage(user, 9,1)
		return 1

	proc/feed_maneater(var/obj/machinery/plantpot/POT, var/mob/user, var/mob/living/carbon/victim)
		var/datum/plantgenes/DNA = POT.plantgenes
		if(POT && victim && victim.loc == user.loc && victim)
			user.visible_message(SPAN_ALERT("[POT.name] grabs [victim] and devours them ravenously!"))
			logTheThing(LOG_COMBAT, user, "feeds [constructTarget(victim,"combat")] to a man-eater at [log_loc(POT)].")
			message_admins("[key_name(user)] feeds [key_name(victim, 1)] ([isdead(victim) ? "dead" : "alive"]) to a man-eater at [log_loc(POT)].")
			if(victim.hasStatus("handcuffed"))
				victim.handcuffs.drop_handcuffs(victim) //handcuffs have special handling for zipties and such, remove them properly first
			victim.unequip_all()
			if(victim.mind)
				victim.ghostize()
				qdel(victim)
			else
				qdel(victim)
			playsound(POT.loc, 'sound/items/eatfood.ogg', 30, 1, -2)
			POT.reagents.add_reagent("blood", 120)
			DNA.endurance += rand(30, 40) //since tray chemistry makes no differnce if you put a dip of blood or feed a human, we give some endurance and health as a reward (Lord_Earthfire)
			POT.health += rand(20, 30)
			SPAWN(2.5 SECONDS)
				if(POT)
					playsound(POT.loc, pick('sound/voice/burp_alien.ogg'), 50, 0)
			return
		else
			user.show_text("You were interrupted!", "red")
			return



/datum/plant/crystal
	name = "Crystal"
	plant_icon = 'icons/obj/hydroponics/plants_alien.dmi'
	sprite = "Crystal"
	starthealth = 50
	growtime = 300
	harvtime = 600
	harvestable = 1
	endurance = 100
	vending = 0
	crop = /obj/item/raw_material/shard/plasmacrystal

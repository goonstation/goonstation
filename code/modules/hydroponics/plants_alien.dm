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
		var/datum/plant/P = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes

		if (POT.growth > (P.harvtime + DNA.harvtime) && prob(20))
			POT.visible_message("<span class='alert'><b>[POT.name]</b> vomits profusely!</span>")
			playsound(POT, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
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
		POT.visible_message("<span class='alert'><b>[POT.name]</b> stares [how] at [src.focused].</span>")
		if(focus_level <= 1)
			M.do_disorient(10, weakened = 0.7 SECONDS, stunned = 0, paralysis = 0, disorient = 0.7 SECONDS, remove_stamina_below_zero = 0)
		else if(focus_level <= 2)
			M.do_disorient(30, weakened = 1.5 SECONDS, stunned = 0, paralysis = 0, disorient = 1.5 SECONDS, remove_stamina_below_zero = 0)
			M.take_brain_damage(5)
			boutput(M, "<span class='alert'>You feel a headache.</span>")
		else if(focus_level <= 3)
			M.do_disorient(30, weakened = 2 SECONDS, stunned = 0, paralysis = 0, disorient = 2 SECONDS, remove_stamina_below_zero = 0)
			M.take_brain_damage(7)
			M.TakeDamage("head", 5, 0)
			boutput(M, "<span class='alert'>Your head is pounding with extreme pain.</span>")
		else if(focus_level <= 4)
			M.do_disorient(50, weakened = 2.5 SECONDS, stunned = 0, paralysis = 0.5 SECONDS, disorient = 2.5 SECONDS, remove_stamina_below_zero = 0)
			M.take_brain_damage(7)
			blood_slash(M, 3)
			M.TakeDamage("head", 10, 0)
			boutput(M, "<span class='alert'>The gaze seems to almost burrow into your skull. You feel like your head is going to split open.</span>")
		else if(focus_level <= 5)
			M.do_disorient(80, weakened = 3 SECONDS, stunned = 0, paralysis = 1 SECONDS, disorient = 3 SECONDS, remove_stamina_below_zero = 0)
			blood_slash(M, 5)
			M.TakeDamage("head", 15, 0)
			boutput(M, "<span class='alert'>The intensity of the plant's gaze makes you feel like your head is going to <i>literally</i> split open.</span>")
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
			M.visible_message("<span class='alert'><b>[M]'s head explodes!</b></span>")
			src.focused = null
			src.focus_level = 1
			return 1
		src.focus_level++
		return 1

	HYPspecial_proc(var/obj/machinery/plantpot/POT)
		..()
		if (.) return
		var/datum/plant/P = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes

		var/pr = 20
		if(src.focused)
			pr += 10

		if (POT.growth > (P.growtime + DNA.growtime) && prob(pr))
			if(focused)
				if(stare_extreme(focused, POT))
					return

			var/extreme_start = prob(max(0, DNA.potency / 30))
			var/list/stuffnearby = list()
			for (var/mob/living/X in view(7,POT)) stuffnearby.Add(X)
			if(!extreme_start)
				for (var/obj/item/X in view(7,POT)) stuffnearby.Add(X)
			if (stuffnearby.len >= 1)
				var/thing = pick(stuffnearby)
				POT.visible_message("<span class='alert'><b>[POT.name]</b> stares at [thing].</span>")
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
		var/datum/plant/P = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes
		if (POT.growth < (P.harvtime + DNA.harvtime))
			return

		for (var/obj/machinery/plantpot/otherPot in oview(1, POT))
			if(!otherPot.current || otherPot.dead)
				continue
			otherPot.growth += 2
			if(istype(otherPot.plantgenes,/datum/plantgenes/))
				var/datum/plantgenes/otherDNA = otherPot.plantgenes
				if(HYPCheckCommut(otherDNA,/datum/plant_gene_strain/photosynthesis))
					otherPot.growth += 4

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

		if (POT.growth > (P.growtime + DNA.growtime) && prob(16))
			playsound(POT,'sound/voice/animal/cat.ogg',30,1,-1)
			POT.visible_message("<span class='alert'><b>[POT.name]</b> meows!</span>")

		if (POT.growth > (P.harvtime + DNA.harvtime + 10))
			var/mob/living/critter/small_animal/cat/synth/C = new(get_turf(POT))
			C.health = POT.health
			POT.visible_message("<span class='notice'>The synthcat climbs out of the tray!</span>")
			POT.HYPdestroyplant()
			return

	HYPattacked_proc(var/obj/machinery/plantpot/POT,var/mob/user)
		..()
		if (.) return
		var/datum/plant/P = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes

		if (POT.growth < (P.growtime + DNA.growtime)) return 0

		playsound(POT,'sound/voice/animal/cat_hiss.ogg',30,1,-1)
		POT.visible_message("<span class='alert'><b>[POT.name]</b> hisses!</span>")

// Weird Shit

/datum/plant/maneater
	name = "Man-Eating"
	plant_icon = 'icons/obj/hydroponics/plants_alien.dmi'
	sprite = "Maneater"
	growthmode = "carnivore"
	unique_seed = /obj/item/seed/maneater
	starthealth = 40
	growtime = 30
	harvtime = 200
	harvestable = 0
	endurance = 10
	special_proc = 1
	attacked_proc = 1
	vending = 0

	HYPspecial_proc(var/obj/machinery/plantpot/POT)
		..()
		if (.) return
		var/datum/plant/P = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes
		if (POT.growth > (P.growtime + DNA.growtime) && prob(4))
			var/MEspeech = pick("Feed me!", "I'm hungryyyy...", "Give me blood!", "I'm starving!", "What's for dinner?")
			for(var/mob/M in hearers(POT, null)) M.show_message("<B>Man-Eating Plant</B> gurgles, \"[MEspeech]\"")
		if (POT.growth > (P.harvtime + DNA.harvtime))
			var/obj/critter/maneater/ME = new(get_turf(POT))
			ME.health = POT.health * 3
			ME.friends = ME.friends | POT.contributors
			POT.visible_message("<span class='notice'>The man-eating plant climbs out of the tray!</span>")
			POT.HYPdestroyplant()
			return

	HYPattacked_proc(var/obj/machinery/plantpot/POT,var/mob/user)
		..()
		if (.) return
		var/datum/plant/P = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes

		if (POT.growth < (P.growtime + DNA.growtime)) return 0

		var/MEspeech = pick("Hands off, asshole!","The hell d'you think you're doin'?!","You dick!","Bite me, motherfucker!")
		for(var/mob/O in hearers(POT, null))
			O.show_message("<B>Man-Eating Plant</B> gurgles, \"[MEspeech]\"", 1)
		boutput(user, "<span class='alert'>The plant angrily bites you!</span>")
		random_brute_damage(user, 9,1)
		return 1

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

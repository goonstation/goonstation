ABSTRACT_TYPE(/datum/plant/weed)
/datum/plant/weed
	plant_icon = 'icons/obj/hydroponics/plants_weed.dmi'
	growthmode = "weed"
	category = "Miscellaneous"

/datum/plant/weed/fungus
	name = "Fungus"
	seedcolor = "#224400"
	crop = /obj/item/reagent_containers/food/snacks/mushroom
	nothirst = 1
	starthealth = 20
	growtime = 30
	harvtime = 250
	harvests = 10
	endurance = 40
	cropsize = 3
	force_seed_on_harvest = 1
	vending = 2
	genome = 30
	assoc_reagents = list("space_fungus")
	mutations = list(/datum/plantmutation/fungus/amanita,/datum/plantmutation/fungus/psilocybin,/datum/plantmutation/fungus/cloak)

/datum/plant/weed/lasher
	name = "Lasher"
	seedcolor = "#00FFFF"
	cropsize = 3
	nothirst = 1
	starthealth = 45
	growtime = 50
	harvtime = 100
	harvestable = 0
	endurance = 50
	isgrass = 1
	special_proc = 1
	attacked_proc = 1
	harvested_proc = 1
	vending = 2
	genome = 5
	mutations = list(/datum/plantmutation/lasher/berries)

	HYPspecial_proc(var/obj/machinery/plantpot/POT)
		..()
		if (.) return
		var/datum/plant/P = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes

		if (POT.growth > (P.growtime + DNA.growtime) && prob(33))
			for (var/mob/living/M in range(1,POT))
				if (POT.health > P.starthealth / 2)
					random_brute_damage(M, 8, 1)//slight bump to damage to account for everyone having 1 armor from jumpsuit, further bump to damage to make blooming lasher more difficult to cultivate
					if (prob(20)) M.changeStatus("weakened", 3 SECONDS)

				if (POT.health <= P.starthealth / 2) POT.visible_message("<span class='alert'><b>[POT.name]</b> weakly slaps [M] with a vine!</span>")
				else POT.visible_message("<span class='alert'><b>[POT.name]</b> slashes [M] with thorny vines!</span>")

	HYPattacked_proc(var/obj/machinery/plantpot/POT,var/mob/user,var/obj/item/W)
		..()
		if (.) return
		var/datum/plant/P = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes

		if (POT.growth < (P.growtime + DNA.growtime)) return 0
		// It's not big enough to be violent yet, so nothing happens

		POT.visible_message("<span class='alert'><b>[POT.name]</b> violently retaliates against [user.name]!</span>")
		random_brute_damage(user, 10, 1)//see above
		if (W && prob(50))
			boutput(user, "<span class='alert'>The lasher grabs and smashes your [W]!</span>")
			W.dropped(user)
			qdel(W)
		return 1

	HYPharvested_proc(var/obj/machinery/plantpot/POT,var/mob/user)
		..()
		if (.) return
		if (POT.health > src.starthealth / 2)
			boutput(user, "<span class='alert'>The lasher flails at you violently! You might need to weaken it first...</span>")
			return 1
		else
			HYPaddCommut(POT.current, POT.plantgenes, /datum/plant_gene_strain/reagent_adder/lasher)
			return 0

/datum/plant/weed/creeper
	name = "Creeper"
	unique_seed = /obj/item/seed/creeper
	seedcolor = "#CC00FF"
	nothirst = 1
	starthealth = 30
	growtime = 30
	harvtime = 100
	harvestable = 0
	endurance = 40
	isgrass = 1
	special_proc = 1
	vending = 2
	genome = 8

	HYPspecial_proc(var/obj/machinery/plantpot/POT)
		..()
		if (.) return
		var/datum/plant/P = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes

		if (POT.growth > (P.growtime + DNA.growtime) && POT.health > P.starthealth / 2 && prob(33))
			for (var/obj/machinery/plantpot/C in range(1,POT))
				var/datum/plant/growing = C.current
				if (!C.dead && C.current && !istype(growing,/datum/plant/crystal) && !istype(growing,/datum/plant/weed/creeper)) C.health -= 10
				else if (C.dead) C.HYPdestroyplant()
				else if (!C.current)
					var/obj/item/seed/creeper/WS = new(src)
					C.HYPnewplant(WS)
					spawn(0.5 SECONDS)
						qdel(WS)
					break

/datum/plant/weed/radweed
	name = "Radweed"
	seedcolor = "#55CC55"
	nothirst = 1
	starthealth = 40
	growtime = 140
	harvtime = 200
	harvestable = 0
	endurance = 80
	special_proc = 1
	vending = 2
	genome = 40
	assoc_reagents = list("radium")
	mutations = list(/datum/plantmutation/radweed/redweed,/datum/plantmutation/radweed/safeweed)

	HYPspecial_proc(var/obj/machinery/plantpot/POT)
		..()
		if (.) return
		var/datum/plant/P = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes

		if (POT.growth > (P.harvtime + DNA?.get_effective_value("harvtime")) && prob(10))
			var/obj/overlay/B = new /obj/overlay( get_turf(POT) )
			B.icon = 'icons/effects/hydroponics.dmi'
			B.icon_state = "radpulse"
			B.name = "radioactive pulse"
			B.anchored = 1
			B.set_density(0)
			B.layer = 5 // TODO What layer should this be on?
			SPAWN(2 SECONDS)
				qdel(B)
				B=null
			var/radstrength = 5
			var/radrange = 1
			switch (POT.health)
				if (21 to 129)
					radstrength = 15
				if (130 to 159)
					radstrength = 25
					radrange = 2
				if (160 to INFINITY)
					radstrength = 50
					radrange = 3
			for (var/mob/living/carbon/M in view(radrange,POT))
				if(!ON_COOLDOWN(M, "radweed_pulse", 2 SECONDS))
					M.take_radiation_dose(radstrength/30 SIEVERTS)
			for (var/obj/machinery/plantpot/C in range(radrange,POT))
				var/datum/plant/growing = C.current
				if (POT.health <= P.starthealth / 2) break
				if (istype(growing,/datum/plant/weed/radweed)) continue
				if (growing) C.HYPmutateplant(radrange * 2)
				if (growing) C.HYPdamageplant("radiation",rand(0,radrange * 2))

/datum/plant/weed/slurrypod
	name = "Slurrypod"
	seedcolor = "#004400"
	crop = /obj/item/reagent_containers/food/snacks/plant/slurryfruit
	nothirst = 1
	starthealth = 25
	growtime = 30
	harvtime = 60
	harvests = 1
	cropsize = 3
	endurance = 30
	special_proc = 1
	vending = 2
	genome = 45
	var/exploding = 0
	assoc_reagents = list("toxic_slurry")
	mutations = list(/datum/plantmutation/slurrypod/omega)

	HYPinfusionP(var/obj/item/seed/S,var/reagent)
		..()
		var/datum/plantgenes/DNA = S.plantgenes
		switch(reagent)
			if ("toxic_slurry","gvomit","gcheese")
				DNA.endurance += rand(4,8)
				S.seeddamage = 0
			if ("charcoal")
				S.seeddamage = 100

	HYPspecial_proc(var/obj/machinery/plantpot/POT)
		..()
		if (.) return
		var/datum/plant/P = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes

		if (POT.growth >= (P.harvtime + DNA?.get_effective_value("harvtime") + 50) && prob(10) && !src.exploding)
			src.exploding = 1
			POT.visible_message("<span class='alert'><b>[POT]</b> begins to bubble and expand!</span>")
			playsound(POT, 'sound/effects/bubbles.ogg', 50, 1)

			SPAWN(5 SECONDS)
				POT.visible_message("<span class='alert'><b>[POT]</b> bursts, sending toxic goop everywhere!</span>")
				playsound(POT, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)

				for (var/mob/living/carbon/human/M in view(3,POT))
					if(istype(M.wear_suit, /obj/item/clothing/suit/bio_suit) && istype(M.head, /obj/item/clothing/head/bio_hood))
						boutput(M, "<span class='notice'>You are splashed by toxic goop, but your biosuit protects you!</span>")
						continue
					boutput(M, "<span class='alert'>You are splashed by toxic goop!</span>")
					M.reagents.add_reagent("toxic_slurry", rand(5,20))
				for (var/obj/machinery/plantpot/C in view(3,POT)) C.reagents.add_reagent("toxic_slurry", rand(5,10))

				POT.HYPdestroyplant()
				return

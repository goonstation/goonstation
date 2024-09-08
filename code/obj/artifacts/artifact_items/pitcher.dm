/obj/item/reagent_containers/food/drinks/drinkingglass/artifact
	name = "artifact pitcher"
	icon = 'icons/obj/artifacts/artifactsitem.dmi'
	desc = "You have no idea what this thing is!"
	artifact = 1
	mat_changename = 0
	can_recycle = 0

	New(var/loc, var/forceartiorigin)
		..()
		var/datum/artifact/pitcher/AS = new /datum/artifact/pitcher(src)
		if (forceartiorigin)
			AS.validtypes = list("[forceartiorigin]")
		src.artifact = AS
		SPAWN(0)
			src.ArtifactSetup()

		src.RemoveComponentsOfType(/datum/component/reagent_overlay)

		if (prob(15))
			src.reagents.inert = TRUE

		gulp_size = rand(2, 10) * 5 //How fast will you drink from this? Who knows!
		var/capacity = rand(5,20)
		capacity *= 100
		src.reagents.maximum_volume = capacity
		//Fun stuff
		if (prob(7))
			reagents.add_reagent("dbreath", 30)
		if (prob(7))
			reagents.add_reagent("freeze", 30)
		if(prob(15))
			reagents.add_reagent("hairgrownium", 30)
		if (prob(10))
			reagents.add_reagent("super_hairgrownium", 20)
		if(prob(5))
			reagents.add_reagent("unstable_omega_hairgrownium", 10)
		if(prob(5))
			reagents.add_reagent("stable_omega_hairgrownium", 10)
		if(prob(7))
			reagents.add_reagent("reversium", 15)
		if (prob(12))
			reagents.add_reagent("strange_reagent", 20)
		if (prob(10))
			reagents.add_reagent("booster_enzyme", 30)
		if (prob(10))
			reagents.add_reagent("hugs", 25)
		if (prob(10))
			reagents.add_reagent("love", 25)
		if (prob(10))
			reagents.add_reagent("colors", 40)
		if (prob(7))
			reagents.add_reagent("fliptonium", 50)
		if (prob(3))
			reagents.add_reagent("glowing_fliptonium", 3)
		if (prob(10))
			reagents.add_reagent("fartonium", 30)
		if (prob(10))
			reagents.add_reagent("glitter", 30)
		if (prob(10))
			reagents.add_reagent("voltagen", 50)
		if (prob(5))
			reagents.add_reagent("rainbow fluid", 30)
		if (prob(1))
			reagents.add_reagent("vampire_serum", 5)
		if (prob(3))
			reagents.add_reagent("painbow fluid", 10)
		if (prob(1))
			reagents.add_reagent("werewolf_serum", 2)
		if (prob(3))
			reagents.add_reagent("liquid spacetime", 25)
		if (prob(3))
			reagents.add_reagent("rat_spit", 5)
		if (prob(1))
			reagents.add_reagent("rat_venom", 5)
		if (prob(3))
			reagents.add_reagent("loose_screws", 25)
		if (prob(1))
			reagents.add_reagent("spidereggs", 5)
		if (prob(10))
			reagents.add_reagent("bathsalts", 25)
		if (prob(10))
			reagents.add_reagent("crank", 35)
		if (prob(10))
			reagents.add_reagent("sonic", 40)
		if (prob(5))
			reagents.add_reagent("cocktail_triple", 20)
		if (prob(13))
			reagents.add_reagent("catdrugs", 30)
		if (prob(10))
			reagents.add_reagent("amanitin", 20)
		if (prob(5))
			reagents.add_reagent("argine", 15)
		if (prob(10))
			reagents.add_reagent("firedust", 40)
		if (prob(10))
			reagents.add_reagent("beepskybeer", 100)
		if (prob(5))
			reagents.add_reagent("moonshine", 20)
		if (prob(5))
			reagents.add_reagent("grog", 15)
		if (prob(15))
			reagents.add_reagent("ectocooler", 35)
		if (prob(15))
			reagents.add_reagent("energydrink", 35)
		if (prob(3))
			reagents.add_reagent("enriched_msg", 15)
		if (prob(15))
			reagents.add_reagent("omnizine", 50)
		if (prob(15))
			reagents.add_reagent("mutagen", 30)
		if (prob(5))
			reagents.add_reagent("hyper_vomitium", 10)
		if (prob(10))
			reagents.add_reagent("omega_mutagen", 30)
		if (prob(5))
			reagents.add_reagent("madness_toxin", 10)
		if (prob(20))
			reagents.add_reagent("mutini", 50)
		if(prob(3))
			reagents.add_reagent("feather_fluid", 20)
		if(prob(3))
			reagents.add_reagent("bee", 10)
		if(prob(15))
			reagents.add_reagent("port", 30)
		#ifdef SECRETS_ENABLED
		if(prob(7))
			reagents.add_reagent("bombini", 15)
		#endif
		if(prob(3))
			reagents.add_reagent("medusa", 10)

		//Filler stuff - Alcohol dispenser list, plus some extras
		var/static/list/fillerDrinks =  list("beer", "cider", "gin", "wine", "champagne", \
								"rum", "vodka", "bourbon", "vermouth", "tequila", \
								"bitters", "tonic", "mead", "cocktail_citrus", "tea", \
								"coffee", "sodawater", "sugar")
		var fillerAmt = rand(3, 6)
		for(var/i in 1 to fillerAmt)
			reagents.add_reagent(pick(fillerDrinks), 50)

	attackby(obj/item/W, mob/user)
		if (src.Artifact_attackby(W,user))
			..()

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		. = ..()
		if(.) // successfully made person drink
			src.ArtifactFaultUsed(target)

	examine()
		return list(desc)

	UpdateName()
		src.name = "[name_prefix(null, 1)][src.real_name][name_suffix(null, 1)]"

	update_icon()

		return //Can't be activated, so the icon should never change

	smash()
		return //Prevents pitcher from smashing into glass

	//Annoyingly duplicated code to override pitcher's explosion behavior (smashing)
	ex_act(severity)
		switch(severity)
			if(1)
				src.ArtifactStimulus("force", 200)
				src.ArtifactStimulus("heat", 500)
			if(2)
				src.ArtifactStimulus("force", 75)
				src.ArtifactStimulus("heat", 450)
			if(3)
				src.ArtifactStimulus("force", 25)
				src.ArtifactStimulus("heat", 380)
		return

	//Bastard child of artifact destuction behavior and drinkingglass smash behavior
	ArtifactDestroyed()
		var/turf/T = get_turf(src)
		if(!T)
			qdel(src)
			return
		src.reagents?.reaction(T)
		if (src.in_glass)
			src.in_glass.set_loc(T)
			src.in_glass = null
		if (src.wedge)
			src.wedge.set_loc(T)
			src.wedge = null
		..()

/datum/artifact/pitcher
	associated_object = /obj/item/reagent_containers/food/drinks/drinkingglass/artifact
	type_name = "Pitcher"
	type_size = ARTIFACT_SIZE_MEDIUM
	rarity_weight = 350
	validtypes = list("martian","wizard","eldritch")
	min_triggers = 0
	max_triggers = 0
	no_activation = TRUE
	react_xray = list(2,85,12,8,"HOLLOW")


	New()
		..()
		src.react_heat[2] = "HIGH INTERNAL CONVECTION"

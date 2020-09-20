/obj/item/reagent_containers/food/drinks/drinkingglass/pitcher/artifact
	name = "artifact pitcher"
	icon = 'icons/obj/artifacts/artifactsitem.dmi'
	desc = "You have no idea what this thing is!"
	artifact = 1
	module_research_no_diminish = 1
	mat_changename = 0

	New(var/loc, var/forceartitype)
		..()
		var/datum/artifact/pitcher/AS = new /datum/artifact/pitcher(src)
		if (forceartitype)
			AS.validtypes = list("[forceartitype]")
		src.artifact = AS
		SPAWN_DBG(0)
			src.ArtifactSetup()

		gulp_size = rand(2, 10) * 5 //How fast will you drink from this? Who knows!
		var/capacity = rand(5,20)
		capacity *= 100
		var/usedCapacity = 0
		src.reagents.maximum_volume = capacity //TODO: Should this be initial_capacity?
		if (prob(7))
			reagents.add_reagent("dbreath", 30)
			usedCapacity += 30
		if (prob(7))
			reagents.add_reagent("freeze", 30)
			usedCapacity += 30
		if (prob(3))
			reagents.add_reagent("stimulants", 20)
			usedCapacity += 20
		if (prob(10))
			reagents.add_reagent("super_hairgrownium", 25)
			usedCapacity += 25
		if (prob(12))
			reagents.add_reagent("strange_reagent", 20)
			usedCapacity += 20
		if (prob(10))
			reagents.add_reagent("booster_enzyme", 30)
			usedCapacity += 30
		if (prob(10))
			reagents.add_reagent("hugs", 25)
			usedCapacity += 25
		if (prob(10))
			reagents.add_reagent("love", 25)
			usedCapacity += 25
		if (prob(10))
			reagents.add_reagent("colors", 40)
			usedCapacity += 40
		if (prob(7))
			reagents.add_reagent("fliptonium", 50)
			usedCapacity += 50
		if (prob(3))
			reagents.add_reagent("glowing_fliptonium", 3)
			usedCapacity += 3
		if (prob(10))
			reagents.add_reagent("fartonium", 30)
			usedCapacity += 30
		if (prob(10))
			reagents.add_reagent("glitter", 30)
			usedCapacity += 30
		if (prob(10))
			reagents.add_reagent("voltagen", 50)
			usedCapacity += 50
		if (prob(5))
			reagents.add_reagent("rainbow fluid", 30)
			usedCapacity += 30
		if (prob(1))
			reagents.add_reagent("vampire_serum", 5)
			usedCapacity += 5
		if (prob(3))
			reagents.add_reagent("painbow fluid", 10)
			usedCapacity += 10
		if (prob(1))
			reagents.add_reagent("werewolf_serum", 2)
			usedCapacity += 2
		/* Removed pending patho rework, in case this becomes functional again
		if (prob(2))
			reagents.add_reagent("liquid plasma", 15)
			usedCapacity += 15
			*/
		if (prob(3))
			reagents.add_reagent("liquid spacetime", 25)
			usedCapacity += 25
		if (prob(1))
			reagents.add_reagent("fuzz", 5)
			usedCapacity += 5
		if (prob(3))
			reagents.add_reagent("loose_screws", 25)
			usedCapacity += 25
		if (prob(1))
			reagents.add_reagent("spidereggs", 5)
			usedCapacity += 5
		if (prob(10))
			reagents.add_reagent("bathsalts", 25)
			usedCapacity += 25
		if (prob(10))
			reagents.add_reagent("crank", 35)
			usedCapacity += 35
		if (prob(10))
			reagents.add_reagent("sonic", 40)
			usedCapacity += 40
		if (prob(13))
			reagents.add_reagent("catdrugs", 30)
			usedCapacity += 30
		if (prob(10))
			reagents.add_reagent("amatin", 20)
			usedCapacity += 20
		if (prob(5))
			reagents.add_reagent("argine", 15)
			usedCapacity += 15
		if (prob(10))
			reagents.add_reagent("firedust", 40)
			usedCapacity += 40
		if (prob(10))
			reagents.add_reagent("beepskybeer", 100)
			usedCapacity += 100
		if (prob(5))
			reagents.add_reagent("moonshine", 20)
			usedCapacity += 20
		if (prob(5))
			reagents.add_reagent("grog", 15)
			usedCapacity += 15
		if (prob(15))
			reagents.add_reagent("ectocooler", 35)
			usedCapacity += 35
		if (prob(15))
			reagents.add_reagent("energydrink", 35)
			usedCapacity += 35
		if (prob(3))
			reagents.add_reagent("enriched_msg", 15)
			usedCapacity += 15
		if (prob(15))
			reagents.add_reagent("omnizine", 50)
			usedCapacity += 50
		if (prob(10))
			reagents.add_reagent("omega_mutagen", 30)
			usedCapacity += 30
		if (prob(5))
			reagents.add_reagent("madness_toxin", 10)
			usedCapacity += 10
		if (prob(20))
			reagents.add_reagent("mutini", 50)
			usedCapacity += 50
		if(prob(3))
			reagents.add_reagent("feather_fluid", 20)
			usedCapacity += 20
		if(prob(3))
			reagents.add_reagent("bee", 10)
			usedCapacity += 10
		reagents.add_reagent("vodka", max((capacity-usedCapacity) / 2, 0))
		reagents.add_reagent("cocktail_citrus", max((capacity-usedCapacity) / 2, 0))
		// replace with random bar stuff - triple citrus, vodka, ciroc, sugar, milk, beer, etc
		//TODO: Add final reagents to replace saltpetre

	attackby(obj/item/W as obj, mob/user as mob)
		if (src.Artifact_attackby(W,user))
			..()

	examine()
		return list(desc)

	UpdateName()
		src.name = "[name_prefix(null, 1)][src.real_name][name_suffix(null, 1)]"

/datum/artifact/pitcher
	associated_object = /obj/item/reagent_containers/food/drinks/drinkingglass/pitcher/artifact
	rarity_class = 2
	validtypes = list("martian","wizard","eldritch")
	min_triggers = 0
	max_triggers = 0
	react_xray = list(2,85,12,8,"HOLLOW")
	module_research = list("medicine" = 5, "science" = 5, "miniaturization" = 15)
	module_research_insight = 3


	New()
		..()
		src.react_heat[2] = "HIGH INTERNAL CONVECTION"

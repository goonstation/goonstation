/obj/item/reagent_containers/glass/wateringcan/artifact
	name = "artifact watering can"
	icon = 'icons/obj/artifacts/artifactsitem.dmi'
	desc = "You have no idea what this thing is!"
	artifact = 1
	module_research_no_diminish = 1
	mat_changename = 0
	mat_changedesc = 0

	New(var/loc, var/forceartiorigin)
		..()
		var/datum/artifact/watercan/AS = new /datum/artifact/watercan(src)
		if (forceartiorigin)
			AS.validtypes = list("[forceartiorigin]")
		src.artifact = AS
		SPAWN_DBG(0)
			src.ArtifactSetup()

		var/capacity = rand(5,20)
		capacity *= 100
		var/usedCapacity = 0
		src.reagents.maximum_volume = capacity
		if (prob(10))
			reagents.add_reagent("uranium", 30)
			usedCapacity += 30
		if (prob(15))
			reagents.add_reagent("aranesp", 30)
			usedCapacity += 30
		if (prob(3))
			reagents.add_reagent("stimulants", 20)
			usedCapacity += 20
		if (prob(10))
			reagents.add_reagent("super_hairgrownium", 25)
			usedCapacity += 25
		if (prob(4))
			reagents.add_reagent("anima", 5)
			usedCapacity += 5
		if (prob(12))
			reagents.add_reagent("strange_reagent", 20)
			usedCapacity += 20
		if (prob(10))
			reagents.add_reagent("booster_enzyme", 30)
			usedCapacity += 30
		if (prob(5))
			reagents.add_reagent("werewolf_part4", 20) // Georgegibs are BACK
			usedCapacity += 20
		if (prob(10))
			reagents.add_reagent("spiders", 50)
			usedCapacity += 50
		if (prob(10))
			reagents.add_reagent("hugs", 25)
			usedCapacity += 25
		if (prob(10))
			reagents.add_reagent("love", 25)
			usedCapacity += 25
		if (prob(10))
			reagents.add_reagent("colors", 40)
			usedCapacity += 40
		if (prob(10))
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
		if (prob(15))
			reagents.add_reagent("voltagen", 50)
			usedCapacity += 50
		if (prob(3))
			reagents.add_reagent("rainbow fluid", 30) // honk
			usedCapacity += 30
		if (prob(1))
			reagents.add_reagent("vampire_serum", 5)
			usedCapacity += 5
		if (prob(2))
			reagents.add_reagent("painbow fluid", 10) // HUNKE
			usedCapacity += 10
		if (prob(1))
			reagents.add_reagent("werewolf_serum", 2) // awoo
			usedCapacity += 2
		if (prob(2))
			reagents.add_reagent("liquid plasma", 15)
			usedCapacity += 15
		if (prob(3))
			reagents.add_reagent("liquid spacetime", 25)
			usedCapacity += 25
		if (prob(1))
			reagents.add_reagent("fuzz", 5) // THE MOST DANGEROUS
			usedCapacity += 5
		if (prob(3))
			reagents.add_reagent("loose_screws", 25)
			usedCapacity += 25
		if (prob(2))
			reagents.add_reagent("spidereggs", 8)
			usedCapacity += 8
		if (prob(5))
			reagents.add_reagent("bathsalts", 25)
			usedCapacity += 25
		if (prob(5))
			reagents.add_reagent("crank", 35)
			usedCapacity += 35
		if (prob(5))
			reagents.add_reagent("triplemeth", 40)
			usedCapacity += 40
		if (prob(13))
			reagents.add_reagent("catdrugs", 45)
			usedCapacity += 45
		if (prob(5))
			reagents.add_reagent("foof", 10)
			usedCapacity += 10
		if (prob(5))
			reagents.add_reagent("argine", 30) // don't get cold
			usedCapacity += 30
		if (prob(10))
			reagents.add_reagent("blackpowder", 310) // don't get hot
			usedCapacity += 310
		if (prob(10))
			reagents.add_reagent("beepskybeer", 100) // drunk driving is a crime
			usedCapacity += 100
		if (prob(5))
			reagents.add_reagent("moonshine", 20)
			usedCapacity += 20
		if (prob(5))
			reagents.add_reagent("grog", 15)
			usedCapacity += 15
		if (prob(10))
			reagents.add_reagent("ectocooler", 35)
			usedCapacity += 35
		if (prob(10))
			reagents.add_reagent("energydrink", 35)
			usedCapacity += 35
		if (prob(3))
			reagents.add_reagent("enriched_msg", 25)
			usedCapacity += 25
		if (prob(15))
			reagents.add_reagent("omnizine", 50)
			usedCapacity += 50
		if (prob(10))
			reagents.add_reagent("omega_mutagen", 30)
			usedCapacity += 30
		if (prob(3))
			reagents.add_reagent("madness_toxin", 10)
			usedCapacity += 10
		reagents.add_reagent("saltpetre", max((capacity-usedCapacity) / 2, 0))
		//reagents.add_reagent("water", max((capacity-usedCapacity) / 2, 0)) // Was diluting the fliptonium, can't have that

	attackby(obj/item/W as obj, mob/user as mob)
		if (src.Artifact_attackby(W,user))
			..()

	examine()
		return list(desc)

	UpdateName()
		src.name = "[name_prefix(null, 1)][src.real_name][name_suffix(null, 1)]"

/datum/artifact/watercan
	associated_object = /obj/item/reagent_containers/glass/wateringcan/artifact
	rarity_class = 2 // modified from 1 as part of art tweak
	validtypes = list("martian","wizard","precursor")
	min_triggers = 0
	max_triggers = 0
	react_xray = list(2,90,15,11,"HOLLOW")
	module_research = list("medicine" = 5, "science" = 5, "miniaturization" = 15)
	module_research_insight = 3


	New()
		..()
		src.react_heat[2] = "HIGH INTERNAL CONVECTION"

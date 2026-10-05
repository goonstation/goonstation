ABSTRACT_TYPE(/obj/item/fossil)
/obj/item/fossil
	name = "fossil"
	desc = "An imprint of some long-dead space creature."
	icon = 'icons/obj/items/materials/fossil.dmi'
	var/sprite_count = 2 // Number of sprites availible to choose from

	New()
		. = ..()
		src.icon_state = "fossil_[rand(1,src.sprite_count)]$$[src.default_material]"

	afterattack(var/atom/A, var/mob/user)
		if(istype(A, /obj/machinery/computer/genetics))
			var/obj/machinery/computer/genetics/genetics_computer = A
			genResearch.researchMaterial += 100
			for(var/chromosome_type in concrete_typesof(/datum/dna_chromosome))
				var/datum/dna_chromosome/C = new chromosome_type(src)
				genetics_computer.saved_chromosomes += C
				C = new chromosome_type(src)
				genetics_computer.saved_chromosomes += C
			user.drop_item()
			playsound(genetics_computer, 'sound/machines/scan2.ogg', 125, TRUE)
			boutput(user,SPAN_SUCCESS("[src] submitted for 100 research material and some chromosomes."))
			qdel(src)

/obj/item/fossil/stone
	name = "fossil"
	default_material = "rock"
	sprite_count = 8

/obj/item/fossil/ice
	name = "frozen fossil"
	desc = "Some strange creature encased in ice. Probably best to keep it that way."
	default_material = "ice"
	sprite_count = 5

/obj/item/fossil/batiline
	name = "batiline fossil"
	desc = "An imprint of some long-dead space creature. Possibly poisoned by the toxic metals in the ore, or otherwise used it as protection against the radiation of space."
	default_material = "batiline"
	sprite_count = 3

/obj/item/fossil/cerenkite
	name = "cerenkite fossil"
	desc = "An imprint of some long-dead space creature. Best be careful with it before you're added to the exibit too."
	default_material = "cerenkite"
	sprite_count = 3

/obj/item/fossil/cobryl
	name = "cobryl fossil"
	default_material = "cobryl"
	sprite_count = 3

/obj/item/fossil/koshmarite
	name = "koshmarite fossil"
	desc = "A koshmarite imprint of some creature. Probably best to assume it's haunted until proven otherwise."
	default_material = "koshmarite"
	sprite_count = 3

/obj/item/fossil/mauxite
	name = "mauxite fossil"
	default_material = "mauxite"
	sprite_count = 3

/obj/item/fossil/molitz
	name = "molitz fossil"
	default_material = "molitz"
	sprite_count = 3

/obj/item/fossil/pharosium
	name = "pharosium fossil"
	desc = "An imprint of some long-dead space creature. Hard to tell whether it was originally organic or silicon."
	default_material = "pharosium"
	sprite_count = 3

/obj/item/fossil/plasmastone
	name = "plasmastone fossil"
	desc = "Some strange creature entombed in solid plasma. At least you think it's a tomb."
	default_material = "plasmastone"
	sprite_count = 3

/obj/item/fossil/syreline
	name = "syreline fossil"
	desc = "An imprint of some long-dead space creature. All this time and still looking fabulous."
	// "A syreline imprint of an ancient creature. It is very difficult to research these specimens
	// due to the supply being entirely bought up by billionaire collectors."
	default_material = "syreline"
	sprite_count = 3

/obj/item/fossil/uqill
	name = "uqill fossil"
	desc = "A remnents of some kind of ancient lifeform. It's unlear if this is the thing itself or just some tool that it left behind."
	default_material = "uqill"

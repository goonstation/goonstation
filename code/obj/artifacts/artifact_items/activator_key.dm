/obj/item/artifact/activator_key
	// can activate any artifact simply by smacking it. very very rare
	name = "artifact activator key"
	associated_datum = /datum/artifact/activator_key
	var/universal = 1 // normally it only activates its own type, but sometimes it can do all
	var/activator = 1 // can also be a DEactivator key sometimes!
	module_research_no_diminish = 1

	New(var/loc, var/forceartiorigin)
		..()
		/*if (prob(10))
			src.universal = 1
		if (prob(10))
			src.activator = 0*/

/datum/artifact/activator_key
	associated_object = /obj/item/artifact/activator_key
	rarity_class = 4
	validtypes = list("ancient","martian","wizard","eldritch","precursor")
	automatic_activation = 1
	react_xray = list(12,80,95,8,"COMPLEX")
	examine_hint = "It kinda looks like it's supposed to be inserted into something."
	module_research = list("tools" = 20)
	module_research_insight = 5

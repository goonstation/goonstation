#define SWIFTNESS "swiftness"
#define FORTUNE 2
#define SPACEFARING 3
#define ELEMENTS 4
#define STRENGTH 5
#define PROTECTION 6

/*
-Random cold protection (from space) from 25% - 75% - the artifact feels somewhat cold
-Random set of heat + cold protection from 0% - 25% each - feels hot and cold in different spots
-Random incoming brute, burn, tox reduction from 0 - 10% each - holding it makes you feel safe somehow
-Random max health increase from 0 - 50 - you get a sense of power from it
-Random amounts of money appearing in your inventory between 0 - 200 credits. does not add it if your inventory is full. - holding it makes you feel lucky somehow
-Random movement speed increase from 0 - 5% - you feel drafts of air surrounding this artifact/you feel air moving quickly around this artifact
*/

/obj/item/artifact/talisman
	name = "artifact talisman"
	associated_datum = /datum/artifact/talisman
	var/associated_effect
	// swiftness vars
	var/swiftness_mod
	// fortune vars
	var/money_amt
	// spacefaring vars
	var/space_prot
	// elements vars
	var/heat_prot
	var/cold_prot
	// strength vars
	var/extra_hp
	// protection vars
	var/brute_prot
	var/burn_prot
	var/tox_prot

	attack_self(mob/user)
		. = ..()
		if (!src.artifact.activated)
			return
		var/msg
		switch(src.associated_effect)
			if (SWIFTNESS)
				msg = "You feel air drafts around [src]."
			if (FORTUNE)
				msg = "You feel lucky somehow."
			if (SPACEFARING)
				msg = "[src] feels VERY cold!!!"
			if (ELEMENTS)
				msg = "[src] feels warm and cold in different spots. [prob(99) ? null : "Sort of like that honk-pocket you once had..."]"
			if (STRENGTH)
				msg = "Holding [src] makes you feel strong."
			if (PROTECTION)
				msg = "You feel safe holding [src]."

		boutput(user, SPAN_NOTICE(msg))

	equipped(mob/user)
		..()
		src.add_effect_to_user(user)

	unequipped(mob/user)
		src.remove_effect_from_user(user)
		..()

	//pick_up_by(mob/M)
	//	..()
	//	if (src.loc == M)
	//		src.add_effect_to_user(M)

	proc/add_effect_to_user(mob/user)
		switch(src.associated_effect)
			if (SWIFTNESS)
				APPLY_MOVEMENT_MODIFIER(user, /datum/movement_modifier/artifact_talisman_swiftness, src)
			if (FORTUNE)
			if (SPACEFARING)
			if (ELEMENTS)
				APPLY_ATOM_PROPERTY(current_user, PROP_MOB_COLDPROT, src, 100)
			if (STRENGTH)
				user.changeStatus("talisman_extra_hp", null, src.extra_hp)
			if (PROTECTION)

	proc/remove_effect_from_user(mob/user)
		switch(src.associated_effect)
			if (SWIFTNESS)
				REMOVE_MOVEMENT_MODIFIER(user, /datum/movement_modifier/artifact_talisman_swiftness, src)
			if (FORTUNE)

			if (SPACEFARING)
			if (ELEMENTS)
			if (STRENGTH)
				user.delStatus("talisman_extra_hp")
			if (PROTECTION)

	proc/select_effect()
		APPLY_ATOM_PROPERTY(current_user, PROP_MOB_COLDPROT, src, 100)
		src.associated_effect = pick(list(SWIFTNESS, FORTUNE, SPACEFARING, ELEMENTS, STRENGTH, PROTECTION))
		switch(src.associated_effect)
			if (SWIFTNESS)
				src.swiftness_mod = rand(1, 5) / 100
			if (FORTUNE)
				src.money_amt = rand(100, 500)
			if (SPACEFARING)
				src.space_prot = rand(25, 75)
			if (ELEMENTS)
				src.heat_prot = rand(1, 25)
				src.cold_prot = rand(1, 25)
			if (STRENGTH)
				src.extra_hp = rand(10, 50)
			if (PROTECTION)
				src.brute_prot = rand(1, 10)
				src.burn_prot = rand(1, 10)
				src.tox_prot = rand(1, 10)



/datum/artifact/talisman
	associated_object = /obj/item/artifact/talisman
	type_name = "Talisman"
	type_size = ARTIFACT_SIZE_MEDIUM
	//rarity_weight = 200
	validtypes = list("wizard", "precursor")
	//react_xray = list(8,80,60,11,"COMPLEX")

	effect_activate(obj/O)
		. = ..()
		if (!.)
			return
		var/obj/item/artifact/talisman/art = O
		if (!art.associated_effect)
			art.select_effect()

#undef SWIFTNESS
#undef FORTUNE
#undef SPACEFARING
#undef ELEMENTS
#undef STRENGTH
#undef PROTECTION

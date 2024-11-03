#define SWIFTNESS 1
#define FORTUNE 2
#define SPACEFARING 3
#define ELEMENTS 4
#define STRENGTH 5
#define PROTECTION 6

/obj/item/artifact/talisman
	name = "artifact talisman"
	icon = 'icons/obj/artifacts/artifactsitemS.dmi'
	associated_datum = /datum/artifact/talisman
	w_class = W_CLASS_SMALL
	var/associated_effect
	var/mob/living/carbon/human/active_user
	/// talisman fault/glimmer effect tied to this artifact
	var/datum/statusEffect/talisman_held/talisman_effect

	// swiftness vars
	var/swiftness_mod = 0
	// fortune vars
	var/datum/statusEffect/talisman_fortune/fortune_effect
	// spacefaring vars
	var/space_prot = 0
	// elements vars
	var/heat_prot = 0
	var/cold_prot = 0
	// strength vars
	var/extra_hp = 0
	var/datum/statusEffect/maxhealth/talisman_artifact/extra_hp_effect
	// protection vars
	var/brute_prot = 0
	var/burn_prot = 0
	var/tox_prot = 0

	attack_self(mob/user)
		. = ..()
		if (!src.artifact.activated)
			return
		var/msg
		switch(src.associated_effect)
			if (SWIFTNESS)
				msg = "You feel drafts of air..."
			if (FORTUNE)
				msg = "You feel lucky somehow."
			if (SPACEFARING)
				msg = "[src] feels ice cold."
			if (ELEMENTS)
				msg = "[src] feels warm and cold in different spots.[prob(99) ? null : " Sort of like that honk-pocket you once had..."]"
			if (STRENGTH)
				msg = "Holding [src] makes you feel strong."
			if (PROTECTION)
				msg = "You feel safe holding [src]."

		boutput(user, SPAN_NOTICE(msg))

	set_loc(newloc, storage_check)
		..()
		src.refresh_user()

	parent_storage_loc_changed()
		src.refresh_user()

	emp_act()
		if (src.artifact.activated)
			src.ArtifactDeactivated()
			playsound(get_turf(src), 'sound/effects/shielddown2.ogg', 75, TRUE)

	proc/refresh_user()
		if (QDELETED(src) || !src.artifact.activated)
			return

		var/atom/A = src.get_holder()

		if (src.active_user && A == src.active_user)
			return
		if (src.active_user)
			src.remove_effect_from_user()
		if (ishuman(A))
			src.add_effect_to_user(A)

	proc/add_effect_to_user(mob/user)
		switch(src.associated_effect)
			if (SWIFTNESS)
				APPLY_ATOM_PROPERTY(user, PROP_MOB_TALISMAN_SWIFTNESS, src, src.swiftness_mod)
				APPLY_MOVEMENT_MODIFIER(user, /datum/movement_modifier/artifact_talisman_swiftness, src)
			if (FORTUNE)
				src.fortune_effect = user.setStatus("art_talisman_fortune", null)
			if (SPACEFARING)
				APPLY_ATOM_PROPERTY(user, PROP_MOB_COLDPROT, src, src.space_prot)
			if (ELEMENTS)
				APPLY_ATOM_PROPERTY(user, PROP_MOB_HEATPROT, src, src.heat_prot)
				APPLY_ATOM_PROPERTY(user, PROP_MOB_COLDPROT, src, src.cold_prot)
			if (STRENGTH)
				src.extra_hp_effect = user.setStatus("talisman_extra_hp", null, src.extra_hp)
			if (PROTECTION)
				if (src.brute_prot)
					APPLY_ATOM_PROPERTY(user, PROP_MOB_TALISMAN_BRUTE_REDUCTION, src, src.brute_prot)
				if (src.burn_prot)
					APPLY_ATOM_PROPERTY(user, PROP_MOB_TALISMAN_BURN_REDUCTION, src, src.burn_prot)
				if (src.tox_prot)
					APPLY_ATOM_PROPERTY(user, PROP_MOB_TALISMAN_TOX_REDUCTION, src, src.tox_prot)

		src.active_user = user
		src.talisman_effect = user.setStatus("art_talisman_held", null, src)

	proc/remove_effect_from_user()
		if (!src.active_user)
			return

		switch(src.associated_effect)
			if (SWIFTNESS)
				REMOVE_ATOM_PROPERTY(src.active_user, PROP_MOB_TALISMAN_SWIFTNESS, src)
				REMOVE_MOVEMENT_MODIFIER(src.active_user, /datum/movement_modifier/artifact_talisman_swiftness, src)
			if (FORTUNE)
				src.active_user.delStatus(src.fortune_effect)
				src.fortune_effect = null
			if (SPACEFARING)
				REMOVE_ATOM_PROPERTY(src.active_user, PROP_MOB_COLDPROT, src)
			if (ELEMENTS)
				REMOVE_ATOM_PROPERTY(src.active_user, PROP_MOB_HEATPROT, src)
				REMOVE_ATOM_PROPERTY(src.active_user, PROP_MOB_COLDPROT, src)
			if (STRENGTH)
				src.active_user.delStatus(src.extra_hp_effect)
				src.extra_hp_effect = null
			if (PROTECTION)
				if (src.brute_prot)
					REMOVE_ATOM_PROPERTY(src.active_user, PROP_MOB_TALISMAN_BRUTE_REDUCTION, src)
				if (src.burn_prot)
					REMOVE_ATOM_PROPERTY(src.active_user, PROP_MOB_TALISMAN_BURN_REDUCTION, src)
				if (src.tox_prot)
					REMOVE_ATOM_PROPERTY(src.active_user, PROP_MOB_TALISMAN_TOX_REDUCTION, src)

		src.active_user.delStatus(src.talisman_effect)
		src.talisman_effect = null
		src.active_user = null

	proc/select_effect()
		src.associated_effect = pick(list(SWIFTNESS, FORTUNE, SPACEFARING, ELEMENTS, STRENGTH, PROTECTION))
		switch(src.associated_effect)
			if (SWIFTNESS)
				src.swiftness_mod = rand(5, 15) / 100
			if (SPACEFARING)
				src.space_prot = rand(25, 75)
			if (ELEMENTS)
				src.heat_prot = rand(1, 25)
				src.cold_prot = rand(1, 25)
			if (STRENGTH)
				src.extra_hp = rand(10, 50)
			if (PROTECTION)
				if (prob(75))
					var/rand_num = rand(1, 3)
					switch(rand_num)
						if (1)
							src.brute_prot = rand(1, 10)
						if (2)
							src.burn_prot = rand(1, 10)
						if (3)
							src.tox_prot = rand(1, 10)
				else
					src.brute_prot = rand(1, 6)
					src.burn_prot = rand(1, 6)
					src.tox_prot = rand(1, 6)

	proc/get_holder()
		var/atom/A = src.loc
		while (A && !isturf(A) && !ishuman(A))
			A = A.loc
		return A

/datum/artifact/talisman
	associated_object = /obj/item/artifact/talisman
	type_name = "Talisman"
	type_size = ARTIFACT_SIZE_TINY
	rarity_weight = 275
	validtypes = list("wizard", "precursor")
	validtriggers = list(/datum/artifact_trigger/force, /datum/artifact_trigger/electric, /datum/artifact_trigger/heat,
		/datum/artifact_trigger/radiation, /datum/artifact_trigger/carbon_touch, /datum/artifact_trigger/silicon_touch, /datum/artifact_trigger/data)
	react_xray = list(30, 25, 97, 95, "ANOMALOUS")
	examine_hint = "It seems magical somehow."

	effect_activate(obj/O)
		. = ..()
		if (.)
			return
		var/obj/item/artifact/talisman/art = O
		if (!art.associated_effect)
			art.select_effect()

		var/mob/living/carbon/human/H = art.get_holder()
		if (istype(H))
			art.add_effect_to_user(H)

	effect_deactivate(obj/O)
		. = ..()
		if (.)
			return

		var/obj/item/artifact/talisman/art = O
		var/mob/living/carbon/human/H = art.active_user
		if (istype(H))
			art.remove_effect_from_user()

#undef SWIFTNESS
#undef FORTUNE
#undef SPACEFARING
#undef ELEMENTS
#undef STRENGTH
#undef PROTECTION

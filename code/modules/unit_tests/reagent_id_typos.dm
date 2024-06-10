/datum/unit_test/reagent_id_typos
	var/static/list/reagent_vars = list(
		list(/datum/ailment/disease, "associated_reagent"),
		list(/datum/ailment, "reagentcure"),
		list(/obj/item/reagent_containers, "initial_reagents"),
		list(/datum/chemical_reaction, "result"),
		list(/datum/chemical_reaction, "required_reagents"),
		list(/datum/chemical_reaction, "inhibitors"),
		list(/datum/projectile, "reagent_payload"),
		list(/datum/plantmutation, "assoc_reagents"),
		list(/datum/plant, "assoc_reagents"),
		list(/obj/item/plant, "brew_result"),
		list(/obj/item/reagent_containers/food, "brew_result"),
		list(/datum/teg_transformation, "required_reagents")
	)

/datum/unit_test/reagent_id_typos/proc/check_reagent_id_value(value, where)
	if (istext(value))
		if(!(value in reagents_cache))
			Fail("[where] invalid reagent id '[value]'")
	else if (islist(value))
		for (var/element in value)
			if (!(element in reagents_cache))
				Fail("[where] invalid reagent id '[element]'")
	else if (isnull(value))
		return
	else
		Fail("[where] reagent id of incorrect type: [value]")

/datum/unit_test/reagent_id_typos/Run()
	if (length(reagents_cache) <= 0)
		build_reagent_cache()

	for (var/list/reagent_test_pair in reagent_vars)
		var/type = reagent_test_pair[1]
		var/var_to_check = reagent_test_pair[2]
		for (var/subtype in concrete_typesof(type, cache=FALSE))
			var/datum/subtype_instance = new subtype
			if (!hasvar(subtype_instance, var_to_check))
				Fail("Reagent type [subtype] does not have var [var_to_check]. Broken test?")
				continue
			var/reagent_id_value = subtype_instance.vars[var_to_check]
			check_reagent_id_value(reagent_id_value, "[subtype].[var_to_check]")

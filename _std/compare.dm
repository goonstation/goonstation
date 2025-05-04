
/* Note about this file:
 * A portion of this code was written by Carnie over at /tg/, back in 2014.
 * We are using the code under the terms of our license, as Carnie can't be
 * contacted, and with this code being algorithims, any original work would
 * be almost identical. The tg project maintainers have also given their OK.
 */

/proc/cmp_numeric_dsc(a,b)
	return b - a

/proc/cmp_numeric_asc(a,b)
	return a - b

/proc/cmp_text_asc(a,b)
	return sorttext(b,a)

/proc/cmp_text_dsc(a,b)
	return sorttext(a,b)

/proc/cmp_name_asc(atom/a, atom/b)
	return sorttext(b.name, a.name)

/proc/cmp_name_dsc(atom/a, atom/b)
	return sorttext(a.name, b.name)

/proc/cmp_ckey_asc(client/a, client/b)
	return sorttext(b.ckey, a.ckey)

/proc/cmp_ckey_dsc(client/a, client/b)
	return sorttext(a.ckey, b.ckey)

// Datum cmp with vars is always slower than a specialist cmp proc, use your judgement.
/proc/cmp_datum_numeric_asc(datum/a, datum/b, variable)
	return cmp_numeric_asc(a.vars[variable], b.vars[variable])

/proc/cmp_datum_numeric_dsc(datum/a, datum/b, variable)
	return cmp_numeric_dsc(a.vars[variable], b.vars[variable])

/proc/cmp_datum_text_asc(datum/a, datum/b, variable)
	return sorttext(b.vars[variable], a.vars[variable])

/proc/cmp_datum_text_dsc(datum/a, datum/b, variable)
	return sorttext(a.vars[variable], b.vars[variable])

/proc/compareArtifactTypes(datum/artifact/A1, datum/artifact/A2)
	if(A1.type_size == A2.type_size)
		return sorttext(A2.type_name, A1.type_name)
	return A1.type_size - A2.type_size

#ifdef CHEM_REACTION_PRIORITIES
/proc/cmp_chemical_reaction_priotity(datum/chemical_reaction/a, datum/chemical_reaction/b)
	return a.priority > b.priority
#endif

/proc/cmp_job_order_priority(datum/job/a, datum/job/b)
	return cmp_numeric_asc(a.order_priority, b.order_priority)

/proc/cmp_gang_score_desc(datum/gang/a, datum/gang/b)
	return cmp_numeric_dsc(a.score_total, b.score_total)

/proc/cmp_recipe_priority(datum/cookingrecipe/a, datum/cookingrecipe/b)
	return cmp_numeric_asc(a.ingredients.len + a.priority, b.ingredients.len + b.priority)

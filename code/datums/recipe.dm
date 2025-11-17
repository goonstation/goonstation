/**
 * A generic structure for recipes, which interfaces with a list of atoms and matches them against an internal list of ingredients. Also responsible
 * for instantiating the output object.
 *
 * the most performance-critical responsibility of the recipe is the pattern-matching, due to its usage in loops. Everything else can/should be
 * abstracted away as needed.
 *
 * For example, you might want to have a recipe that works with stacks of items. In that case, it would be unwise to add the logic into the base
 * can_cook_recipe proc, since that would bloat the performance for every other recipe. It would be encouraged to create a recipe subclass for that
 * override behaviour. On the other hand, if you instead wanted a group of recipes that had some shared behaviour such as all results being turned
 * blue after instantiation, it would be better to implement that in a cooking_instructions child or some other abstracted subsystem, so the behaviour
 * can be shared regardless of the pattern of ingredients.
 *
 * Other examples of patterns that would warrant a non-unique recipe subclass would be handling items with complex components, states, or working with
 * reagent containers when their contents matter to the recipe.
 *
 * The basic usage of this is to first find a recipe that matches the list of ingredients you have, with can_cook_recipe(), and then use the same
 * list to instantiate the output using get_output(). For machine-specific interactions, implement a bespoke recipe_instruction for that machine.
*/
ABSTRACT_TYPE(/datum/recipe)
/datum/recipe
	VAR_PROTECTED/list/ingredients /// An associative list of [paths = amounts] representing the required ingredients for this recipe
	VAR_PROTECTED/output = null /// what you get from this recipe. This can be a path, a list of paths, or an associative list of [paths = amounts]
	var/category = "Unsorted" /// category for sorting, use null to hide
	VAR_PROTECTED/list/variants = null
	VAR_PROTECTED/variant_quantity = 1
	VAR_PROTECTED/wildcard_quantity = 0 /// How many ingredients beyond those explicitly in the ingredients list are allowed for this recipe
	VAR_PROTECTED/recipe_length = 0 /// How many explicit ingredients are in this recipe. This is calculated automatically.
	VAR_PROTECTED/list/recipe_instructions /// A list of instructions for specific machines that may use this recipe

	New()
		if (ingredients)
			for(var/type in ingredients)
				recipe_length += ingredients[type]
		..()

	/// Can the given list of items be used to make this recipe?
	proc/can_cook_recipe(list/item_list, var/wildcard_override = null)
		var/wildcards = wildcard_override == null ? src.wildcard_quantity : wildcard_override
		var/item_quant = length(item_list)
		if (item_quant < src.recipe_length || item_quant > src.recipe_length + wildcards)
			return FALSE

		for (var/obj/type as anything in src.ingredients)
			var/count_needed = src.ingredients[type]
			var/count_found = 0
			for(var/obj/item/I in item_list)
				if(istype(I, type) && ++count_found >= count_needed)
					break
			if(count_found < count_needed)
				return FALSE

		return TRUE


	/// Attempts to instantiates a copy of the intended output based on the given list of input and puts it in the 'output' list provided.
	/// Returns true or false based on success with the given input.
	/// When overriding this, 'source' and 'user' should only be used for optional extraneous effects, such as sfx, and should be expected to
	/// often be null. For machine-specific actions or data, use bespoke recipe_instructions instead.
	proc/try_get_output(list/input, list/output, atom/source = null, mob/user = null )
		if (!islist(input))
			stack_trace("Recipe aborting. Input of type list required, received '[string_type_of_anything(input)]' instead.")
			return FALSE
		if (!islist(output))
			stack_trace("Recipe aborting. Output of type list required, received '[string_type_of_anything(output)]' instead.")
			return FALSE
		. = get_output(input, output, source, user)
		output_post_process(input, output, source, user)


	proc/get_output(list/input_list, list/output_list, atom/source = null, mob/user = null)
		PROTECTED_PROC(TRUE)
		var/output_paths = get_variant(input_list)
		. = FALSE
		if(islist(output_paths))
			for(var/path in output_paths)
				var/amount = output_paths[path]
				if(isnum(amount))
					for(var/i = 1, i <= amount, i++)
						output_list += new path
						. = TRUE
				else if(ispath(path))
					output_list += new path
					. = TRUE
		else if(ispath(output_paths))
			output_list += new output_paths
			. = TRUE
		if (!.)
			// By default, a failure here likely means the recipe has been set up wrong. This isn't necessarily true if this proc gets overriden.
			stack_trace("Recipe of type [string_type_of_anything(src)] failed with input: [english_list(input_list)].")

	/// called after get_output(), performs any post-instantiation changes to every item in the 'output' list.
	proc/output_post_process(list/input, list/output, atom/source = null, mob/user = null)
		PROTECTED_PROC(TRUE)
		return

	proc/get_variant(list/item_list)
		PROTECTED_PROC(TRUE)
		for(var/specialIngredient in src.variants)
			var/count_needed = src.variant_quantity
			var/count_found = 0
			for(var/obj/item/I in item_list)
				if(istype(I, specialIngredient) && ++count_found >= count_needed)
					var/variant = src.variants[specialIngredient]
					return variant
		return output

	/// Finds the specific instructions for the relevant machine, if any appropriate ones exist for the recipe
	/// For a list of IDs, check defines\recipe.dm
	proc/get_recipe_instructions(var/id)
		if (isnull(src.recipe_instructions))
			return null
		// lazily instantiate the instructions if they haven't been set up
		if (ispath(src.recipe_instructions[1]))
			var/list/instantiated_instructions = list()
			for(var/instruction_path in src.recipe_instructions)
				var/datum/recipe_instructions/inst_instruction = new instruction_path()
				instantiated_instructions[inst_instruction.get_id()] = inst_instruction
			recipe_instructions = instantiated_instructions

		return src.recipe_instructions[id]


	/// Removes any excess items that aren't explicitly used in the recipe from a given list of ingredients,
	/// and moves them to the 'extras' list if it is provided.
	/// Wildcards are assumed to be the first x items in the list that aren't explicitly used by ingredients.
	/// This isn't a ridiculously efficient method, it's not recommended to use this in heavy loops.
	proc/separate_ingredients(list/seperatable_ingredients, list/extras = null, wildcard_override = null)
		if (!seperatable_ingredients || length(seperatable_ingredients) < 1)
			return
		var/wildcards = wildcard_override == null ? src.wildcard_quantity : wildcard_override
		if (length(seperatable_ingredients) <= src.recipe_length + wildcards)
			return

		var/list/remaining = seperatable_ingredients.Copy()
		var/list/used_for_recipe = list()

		for (var/obj/required_type as anything in src.ingredients)
			var/needed_count = src.ingredients[required_type]
			var/found_count = 0

			for (var/obj/I in remaining)
				if (istype(I, required_type) && found_count < needed_count)
					used_for_recipe += I
					found_count++

			for (var/obj/used in used_for_recipe)
				remaining -= used
			used_for_recipe.len = 0

		for(var/i = 1, i <= wildcards, i++)
			if (length(remaining) < 1)
				break
			if (extras)
				extras += remaining[1]
			remaining.Cut(1, 2)

		for (var/obj/item/unused in remaining)
			seperatable_ingredients -= unused
			if (extras)
				extras += unused

	/// returns whether the given type exists within the recipe's ingredients list
	proc/type_in_ingredients(var/atom/type)
		return istypes(type, src.ingredients)

	proc/render()
		var/list/icons = list()
		for (var/obj/item/type as anything in src.ingredients)
			icons += bicon(type, 2)
		. = jointext(icons, "<span style='font-size: 300%'> + </span>")
		. += "<span style='font-size: 300%'> = </span>[bicon(src.get_mascot(), 2)]"

	/// Returns a list of associative lists representing the displayable data for each atom used in the recipe and their amounts
	proc/get_ingredients_data()
		RETURN_TYPE(/list)
		var/list/out = list()
		for(var/atom/item_path as anything in src.ingredients)
			var/amount = src.ingredients[item_path]
			var/list/item = list(
				"name" = initial(item_path.name),
				"icon" = initial(item_path.icon),
				"icon_state" = initial(item_path.icon_state),
				"amount" = amount
			)
			out += list(item)
		return out

	/// Returns an associative list representing the displayable data for the mascot, the single atom that represents the output for this recipe
	proc/get_mascot_data(list/item_list)
		var/atom/mascot = src.get_mascot(item_list)
		var/amount = islist(src.output) ? src.output[mascot] : 1
		var/list/item = list(
		"name" = initial(mascot.name),
		"icon" = initial(mascot.icon),
		"icon_state" = initial(mascot.icon_state),
		"amount" = amount
		)
		return item

	/// Returns a single atom path that represents the output for this recipe. By default this will be the first-found path in the ingredient list.
	/// Although note that associated lists are not necessarily ordered the same as they're added.
	proc/get_mascot(list/item_list)
		var/recipe_output
		if (item_list)
			recipe_output = get_variant(item_list)
		else
			recipe_output = src.output

		if(islist(recipe_output) && length(recipe_output) > 0)
			for(var/key in recipe_output)
				return key
		return recipe_output


/// recipe instructions are the machine-specific portions of a recipe. They might include cooking times, or special interactions such as
/// forcing breakage.
ABSTRACT_TYPE(/datum/recipe_instructions)
/datum/recipe_instructions

	proc/get_id()
		return null

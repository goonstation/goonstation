/*
 * Parent types
 * - /datum/robot/module_tool_creator
 * - /datum/robot/module_tool_creator/item_type
 * - /datum/robot/module_tool_creator/item_type/amount
 * - /datum/robot/module_tool_creator/item_type/random
 * - /datum/robot/module_tool_creator/item_types
 * - /datum/robot/module_tool_creator/recursive
 *
 * Can have specific child classes created with correct var overrides (see other files),
 * or be instantiated with var overrides if no custom behavior is needed, e.g.:
 * - new /datum/robot/module_tool_creator/item_type{item_type = /obj/item/extinguisher}
 * - new /datum/robot/module_tool_creator/item_type/amount{item_type = /obj/item/sheet/steel, amount = 50}
 */

/**
 * Stub parent.
 *
 * Allows for a tool (or lists of tools) to be created and configured properly.
 *
 * Configuration includes correctly setting them up for inclusion in a robot module.
 *
 * Configuration can include other processing, e.g. random generation.
 */
/datum/robot/module_tool_creator
	var/name = null

/**
 * Instantiates contents and adds to a specific module.
 *
 * * M {[/obj/item/robot_module]}
 *
 * * return {(/obj/item|/list</obj/item>)} result - Added contents
 */
/datum/robot/module_tool_creator/proc/apply_to_module(obj/item/robot_module/M)
	return M.add_contents(src.instantiate(M))

/**
 * Stub, used to instantiate tool(s).
 * Ensure `setup` is called when defining behavior.
 *
 * * proxy_loc {[/atom]} - Location to create contents
 *
 * * return {(/obj/item|/list</obj/item>)} result
 */
/datum/robot/module_tool_creator/proc/instantiate(atom/proxy_loc)
	return

/**
 * Stub proc.
 * Used to alter/configure instantiated tool(s).
 *
 * * contents {(/obj/item|/list</obj/item>)} - Instantiated contents
 * * proxy_loc {[/atom]} - Location used in `instantiate`, in case needed
 *
 * * return {(/obj/item|/list</obj/item>)} result - Altered/configured instantiated item(s) (may not be same instance(s) as argument)
 */
/datum/robot/module_tool_creator/proc/setup(contents, atom/proxy_loc)
	return contents

/**
 * Stub parent.
 *
 * Allows for simple instantiation of a single [/obj/item] from a type.
 *
 * @property {type</obj/item>} item_type
 */
/datum/robot/module_tool_creator/item_type
	var/item_type = null

/**
 * Instantiates single [/obj/item] from type.
 *
 * * proxy_loc {[/atom]} - Location to create contents
 *
 * * return {[/obj/item]} result
 */
/datum/robot/module_tool_creator/item_type/instantiate(atom/proxy_loc)
	var/obj/item/I = null
	if (ispath(src.item_type, /obj/item))
		I = new src.item_type(proxy_loc)
	return src.setup(I, proxy_loc)

/**
 * Stub parent.
 *
 * Allows simple instantiation of a single [/obj/item] from a type that uses the `amount` var.
 *
 * You may need to extend the `setup` proc for e.g. custom icon state behavior.
 *
 * @property {number} amount=1
 */
/datum/robot/module_tool_creator/item_type/amount
	var/amount = 1

/**
 * * contents {[/obj/item]} - Instantiated contents
 * * proxy_loc {[/atom]} - Location used in `instantiate`
 *
 * * return {[/obj/item]} result
 */
/datum/robot/module_tool_creator/item_type/amount/setup(obj/item/contents, atom/proxy_loc)
	if (!isnull(contents))
		contents.amount = src.amount
	return contents

/**
 * Stub parent.
 *
 * Allows instantiation of a single [/obj/item] type picked from a list of types.
 *
 * @property {/list<type</obj/item>>} item_types
 */
/datum/robot/module_tool_creator/item_type/random
	var/list/item_types = null

/**
 * Instantiates random ]/obj/item] type picked from `item_types`
 *
 * Side effect of setting `item_type` when called
 *
 * * proxy_loc {[/atom]} - Location to create contents
 *
 * * return {[/obj/item]} result
 */
/datum/robot/module_tool_creator/item_type/random/instantiate(atom/proxy_loc)
	if (!isnull(src.item_types))
		// seeds `item_type` with picked type to use in regular instantiation
		src.item_type = pick(src.item_types)
		return ..()

/**
 * Stub parent.
 *
 * Allows simple instantiation of multiple [/obj/item] instances from a list of types.
 *
 * @property {/list<path</obj/item>>} item_types
 */
/datum/robot/module_tool_creator/item_types
	var/list/item_types = null

/**
 * Instantiates list of [/obj/item] instances from list of types.
 *
 * * proxy_loc [/atom] - Location to create contents
 *
 * * return {/list</obj/item>} result
 */
/datum/robot/module_tool_creator/item_types/instantiate(atom/proxy_loc)
	var/list/L = null
	if (!isnull(src.item_types))
		L = new /list
		for (var/item_type in src.item_types)
			if (ispath(item_type, /obj/item))
				var/obj/item/I = new item_type(proxy_loc)
				L += I
	return src.setup(L, proxy_loc)

/*
 * Versatile recursive definition.
 * @typedef (
 *   type</obj/item>|
 *   type</datum/robot/module_tool_creator>|
 *   /datum/robot/module_tool_creator|
 *   /list</datum/robot/module_tool_creator/recursive/definition>
 * ) /datum/robot/module_tool_creator/recursive/definition
 */

/**
 * Stub parent.
 *
 * Allows instantiations of potentially multiple /obj/item instances via multiple methods.
 *
 * N.B. If possible, use a simpler type due to more complexity in here.
 *
 * @property {/list</datum/robot/module_tool_creator/recursive/definition>} definitions
 */
/datum/robot/module_tool_creator/recursive
	var/list/definitions = null

/**
 * Instantiates list of [/obj/item] instances via multiple methods.
 *
 * * proxy_loc {[/atom]} - Location to create contents
 * * proxy_definition {[/datum/robot/module_tool_creator/recursive/definition]}
 *
 * * return {/list</obj/item>} result
 */
/datum/robot/module_tool_creator/recursive/proc/instantiate_recursive(atom/proxy_loc, proxy_definition)
	if (isnull(proxy_definition))
		return
	if (ispath(proxy_definition, /obj/item))
		return new proxy_definition(proxy_loc)
	if (ispath(proxy_definition, /datum/robot/module_tool_creator))
		var/datum/robot/module_tool_creator/MTC = new proxy_definition
		return MTC.instantiate(proxy_loc)
	if (istype(proxy_definition, /datum/robot/module_tool_creator))
		var/datum/robot/module_tool_creator/MTC = proxy_definition
		return MTC.instantiate(proxy_loc)
	if (islist(proxy_definition))
		var/list/definitions = proxy_definition
		var/list/L = new /list
		for (var/definition in definitions)
			var/R = src.instantiate_recursive(proxy_loc, definition)
			if (!isnull(R))
				L += R
		return L
	return

/**
 * Instantiates list of /obj/item instances via multiple methods.
 *
 * * proxy_loc {/atom} - Location to create contents
 *
 * * return {/list</obj/item>} result
 */
/datum/robot/module_tool_creator/recursive/instantiate(atom/proxy_loc)
	var/R = src.instantiate_recursive(proxy_loc, src.definitions)
	return src.setup(R, proxy_loc)

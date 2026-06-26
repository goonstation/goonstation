//------------ How To Use Namespaces ------------//
/*

CREATE_NAMESPACE(TEST)

// Non-constant variable example.
ADD_TO_NAMESPACE(TEST)(var/example_var = new /atom/movable)
// Constant variable example. Can be statically accessed with `::`. See `test_var` below for a usecase.
ADD_TO_NAMESPACE(TEST)(var/const/example_constant = (1 << 3))
// Proc example.
ADD_TO_NAMESPACE(TEST)(proc/example_proc())
	return "example value"

/datum/test_datum
	var/test_var = TEST::example_constant

/datum/test_datum/proc/test_proc()
	message_admins(TEST.example_var)
	message_admins(TEST.example_proc())

*/


/**
 *	Declare a new namespace. If one argument is passed, a global namespace is created. If more than one argument is passed, a nested namespace is created. \
 *	E.g.
 *	- `CREATE_NAMESPACE(ANIMATE)`			: creates a global `ANIMATE` namespace.
 *	- `CREATE_NAMESPACE(ANIMATE, MOB)`		: creates a nested `MOB` namespace inside of `ANIMATE`.
 *	- `CREATE_NAMESPACE(ANIMATE, MOB, BEE)`	: creates a nested `BEE` namespace inside of `ANIMATE.MOB`.
 */
#define CREATE_NAMESPACE(_NAMES...) _NS_DEFINE(##_NAMES, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0)

#define _NS_DEFINE(a, b, c, d, e, f, g, h, i, j, ...) _NS_DEFINE_##j(a, b, c, d, e, f, g, h, i)
#define _NS_DEFINE_0(a, b, c, d, e, f, g, h, i)
#define _NS_DEFINE_1(a, b, c, d, e, f, g, h, i) var/datum/namespace/##a/##a = /datum/namespace/##a
#define _NS_DEFINE_2(a, b, c, d, e, f, g, h, i) ADD_TO_NAMESPACE(a)(var/##ADD_TO_NAMESPACE(a, b)(##b = _NS_PATH(a, b)))
#define _NS_DEFINE_3(a, b, c, d, e, f, g, h, i) ADD_TO_NAMESPACE(a, b)(var/##ADD_TO_NAMESPACE(a, b, c)(##c = _NS_PATH(a, b, c)))
#define _NS_DEFINE_4(a, b, c, d, e, f, g, h, i) ADD_TO_NAMESPACE(a, b, c)(var/##ADD_TO_NAMESPACE(a, b, c, d)(##d = _NS_PATH(a, b, c, d)))
#define _NS_DEFINE_5(a, b, c, d, e, f, g, h, i) ADD_TO_NAMESPACE(a, b, c, d)(var/##ADD_TO_NAMESPACE(a, b, c, d, e)(##e = _NS_PATH(a, b, c, d, e)))
#define _NS_DEFINE_6(a, b, c, d, e, f, g, h, i) ADD_TO_NAMESPACE(a, b, c, d, e)(var/##ADD_TO_NAMESPACE(a, b, c, d, e, f)(##f = _NS_PATH(a, b, c, d, e, f)))
#define _NS_DEFINE_7(a, b, c, d, e, f, g, h, i) ADD_TO_NAMESPACE(a, b, c, d, e, f)(var/##ADD_TO_NAMESPACE(a, b, c, d, e, f, g)(##g = _NS_PATH(a, b, c, d, e, f, g)))
#define _NS_DEFINE_8(a, b, c, d, e, f, g, h, i) ADD_TO_NAMESPACE(a, b, c, d, e, f, g)(var/##ADD_TO_NAMESPACE(a, b, c, d, e, f, g, h)(##h = _NS_PATH(a, b, c, d, e, f, g, h)))
#define _NS_DEFINE_9(a, b, c, d, e, f, g, h, i) ADD_TO_NAMESPACE(a, b, c, d, e, f, g, h)(var/##ADD_TO_NAMESPACE(a, b, c, d, e, f, g, h, i)(##i = _NS_PATH(a, b, c, d, e, f, g, h, i)))


/**
 *	Add a statement to the end of a namespace. \
 *	E.g.
 *	- `ADD_TO_NAMESPACE(ANIMATE)(var/example_var = null)`		: adds an `example_var` variable to `ANIMATE` and initialises it to `null`.
 *	- `ADD_TO_NAMESPACE(ANIMATE, MOB)(var/example_var = null)`	: adds an `example_var` variable to `ANIMATE.MOB` and initialises it to `null`.
 *	- `ADD_TO_NAMESPACE(ANIMATE)(proc/example_proc())`			: adds an `example_proc` proc to `ANIMATE`. Indented code following the macro will be treated as the body of the proc.
 *	- `ADD_TO_NAMESPACE(ANIMATE, MOB)(proc/example_proc())`		: adds an `example_proc` proc to `ANIMATE.MOB`. Indented code following the macro will be treated as the body of the proc.
 */
#define ADD_TO_NAMESPACE(_NAMES...) _NS_PATH_I(##_NAMES)

// The namespace path for a concatenated namespace name.
#define _NS_PATH(_ARGS...) _NS_PATH_CONCAT(__NS_PATH, ##_ARGS, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0)
#define __NS_PATH(_NAME) /datum/namespace/##_NAME

// The namespace path for a concatenated namespace name, with a capturing identity macro appended to the terminating forward slash.
#define _NS_PATH_I(_ARGS...) _NS_PATH_CONCAT(__NS_PATH_I, ##_ARGS, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0)
#define __NS_PATH_I(_NAME) datum/namespace/##_NAME/##IDENTITY

#define _NS_PATH_CONCAT(X, a, b, c, d, e, f, g, h, i, j, ...) _NS_PATH_CONCAT_##j(X, a, b, c, d, e, f, g, h, i)
#define _NS_PATH_CONCAT_0(X, a, b, c, d, e, f, g, h, i)
#define _NS_PATH_CONCAT_1(X, a, b, c, d, e, f, g, h, i) X(a)
#define _NS_PATH_CONCAT_2(X, a, b, c, d, e, f, g, h, i) X(a##__##b)
#define _NS_PATH_CONCAT_3(X, a, b, c, d, e, f, g, h, i) X(a##__##b##__##c)
#define _NS_PATH_CONCAT_4(X, a, b, c, d, e, f, g, h, i) X(a##__##b##__##c##__##d)
#define _NS_PATH_CONCAT_5(X, a, b, c, d, e, f, g, h, i) X(a##__##b##__##c##__##d##__##e)
#define _NS_PATH_CONCAT_6(X, a, b, c, d, e, f, g, h, i) X(a##__##b##__##c##__##d##__##e##__##f)
#define _NS_PATH_CONCAT_7(X, a, b, c, d, e, f, g, h, i) X(a##__##b##__##c##__##d##__##e##__##f##__##g)
#define _NS_PATH_CONCAT_8(X, a, b, c, d, e, f, g, h, i) X(a##__##b##__##c##__##d##__##e##__##f##__##g##__##h)
#define _NS_PATH_CONCAT_9(X, a, b, c, d, e, f, g, h, i) X(a##__##b##__##c##__##d##__##e##__##f##__##g##__##h##__##i)


/// A list of all global namespaces.
var/list/datum/namespace/global_namespaces = null
/// A list of all variable names present on the parent `/datum/namespace` type.
var/alist/namespace_parent_vars = null

/// Initialise all global namespaces by looping through global variables, determining which are namespaces, then instantiating them.
/proc/initialise_namespaces()
	global.namespace_parent_vars = alist()
	var/datum/namespace/blank_namespace = new()
	for (var/variable_name as anything in blank_namespace.vars)
		global.namespace_parent_vars[variable_name] = TRUE

	qdel(blank_namespace)

	global.global_namespaces = list()
	for (var/variable_name as anything in global.vars)
		var/namespace_path = global.vars[variable_name]
		if (!ispath(namespace_path, /datum/namespace))
			continue

		var/datum/namespace/global_namespace = new namespace_path(variable_name)
		global.vars[variable_name] = global_namespace
		global.global_namespaces += global_namespace

	global.sortList(global.global_namespaces, GLOBAL_PROC_REF(cmp_namespaces))

/// Compare the names of two namespaces.
/proc/cmp_namespaces(datum/namespace/a, datum/namespace/b)
	return sorttext(b._namespace_name, a._namespace_name)


/datum/namespace
	/// The name of this namespace, that is, the name of the variable that references this namespace.
	var/_namespace_name = null
	/// An associative list of proc references to procs defined on this namespace and its nested namespaces, indexed by proc name.
	var/list/_namespace_procs = null
	/// A list of the values of the constant variables defined on this namespace.
	var/list/_namespace_constants = null
	/// A list of this namespace's nested namespaces.
	var/list/datum/namespace/_nested_namespaces = null

/datum/namespace/New(_namespace_name)
	src._namespace_name = _namespace_name
	src._nested_namespaces = list()

	// Initialise any nested namespaces.
	for (var/variable_name as anything in src.vars)
		if ((variable_name == "type") || (variable_name == "parent_type"))
			continue

		var/namespace_path = src.vars[variable_name]
		if (!ispath(namespace_path, /datum/namespace))
			continue

		var/datum/namespace/nested_namespace = new namespace_path(variable_name)
		src.vars[variable_name] = nested_namespace
		src._nested_namespaces += nested_namespace

	global.sortList(src._nested_namespaces, GLOBAL_PROC_REF(cmp_namespaces))

	. = ..()

/// Returns an associative list of proc references to procs defined on this namespace and its nested namespaces, indexed by proc name.
/datum/namespace/proc/_get_namespace_procs(prefix_name = FALSE)
	RETURN_TYPE(/list)

	if (!length(src._namespace_procs))
		src._namespace_procs = global.get_singleton(/datum/proc_ownership_cache).procs_by_type[src.type] || list()
		src._namespace_procs -= list("(init)", "New", "_get_namespace_procs", "_get_namespace_constants")
		global.sortList(src._namespace_procs, GLOBAL_PROC_REF(cmp_text_asc))

		for (var/datum/namespace/nested_namespace as anything in src._nested_namespaces)
			src._namespace_procs += nested_namespace._get_namespace_procs(TRUE)

	if (prefix_name)
		var/list/procs = list()
		for (var/proc_name as anything in src._namespace_procs)
			procs["[src._namespace_name].[proc_name]"] = src._namespace_procs[proc_name]

		return procs

	return src._namespace_procs

/// Returns a list of the values of the constant variables defined on this namespace and its nested namespaces.
/datum/namespace/proc/_get_namespace_constants()
	RETURN_TYPE(/list)

	if (!length(src._namespace_constants))
		src._namespace_constants = list()
		for (var/variable_name as anything in src.vars)
			if (issaved(src.vars[variable_name]) || global.namespace_parent_vars[variable_name])
				continue

			src._namespace_constants += src.vars[variable_name]

		for (var/datum/namespace/nested_namespace as anything in src._nested_namespaces)
			src._namespace_constants += nested_namespace._get_namespace_constants()

	return src._namespace_constants

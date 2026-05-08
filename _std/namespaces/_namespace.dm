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
#define __NS_PATH_I(_NAME) /datum/namespace/##_NAME/##IDENTITY

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


/// Initialise all global namespaces by looping through global variables, determining which are namespaces, then instantiating them.
/proc/initialise_namespaces()
	for (var/variable_name as anything in global.vars)
		var/namespace_path = global.vars[variable_name]
		if (!ispath(namespace_path, /datum/namespace))
			continue

		global.vars[variable_name] = new namespace_path(variable_name)


/datum/namespace
	/// The name of this namespace, that is, the name of the variable that references this namespace.
	var/_namespace_name = null
	/// An associative list of proc references to procs defined on this namespace and its nested namespaces, indexed by proc name.
	var/list/_namespace_procs = null

/datum/namespace/New(_namespace_name)
	src._namespace_name = _namespace_name

	// Initialise any nested namespaces.
	for (var/variable_name as anything in src.vars)
		if ((variable_name == "type") || (variable_name == "parent_type"))
			continue

		var/namespace_path = src.vars[variable_name]
		if (!ispath(namespace_path, /datum/namespace))
			continue

		src.vars[variable_name] = new namespace_path(variable_name)

	. = ..()

/// Returns an associative list of proc references to procs defined on this namespace and its nested namespaces, indexed by proc name.
/datum/namespace/proc/_get_namespace_procs()
	RETURN_TYPE(/list)

	if (length(src._namespace_procs))
		return src._namespace_procs

	src._namespace_procs = global.get_singleton(/datum/proc_ownership_cache).procs_by_type[src.type] || list()
	src._namespace_procs -= list("(init)", "New", "_get_namespace_procs")

	for (var/variable_name as anything in src.vars)
		var/datum/namespace/nested_namespace = src.vars[variable_name]
		if (!istype(nested_namespace))
			continue

		var/list/nested_namespace_procs = nested_namespace._get_namespace_procs()
		for (var/proc_name as anything in nested_namespace_procs)
			src._namespace_procs["[nested_namespace._namespace_name]: [proc_name]"] = nested_namespace_procs[proc_name]

	return src._namespace_procs

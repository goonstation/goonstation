
/**
 * Type used to sanely access vars on a proc.
 * Example:
 * ```
 * var/procpath/some_proc = /proc/foo
 * world.log << some_proc.name
 * ```
 *
 * Do not instantiate this type directly, it's just an interface for procs.
 * Instead of istype(proc, /procpath), use isproc(proc). (defined in address.dm)
 */
/procpath
	var/name //! defined by using `set name = "foo"` in the proc
	var/desc //! defined by using `set desc = "foo"` in the proc
	var/category //! defined by using `set category = "foo"` in the proc
	var/invisibility //! defined by using `set invisibility = 1` in the proc
	// note: hidden, instant and popup_menu look like they should be accessible like this but this is not the case

	New()
		..()
		CRASH("New() called on /procpath")

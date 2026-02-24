/datum/map_correctness_check/xmas_tree
	check_name = "Missing/Duplicate Xmas Trees"
	check_prefabs = FALSE

/datum/map_correctness_check/xmas_tree/run_check()
	var/tree_num = length(by_type[/obj/xmastree])
	if (tree_num == 1)
		return

	. = list()
	. += "There should be exactly 1 xmas tree, but there are [tree_num]!"
	for_by_tcl(tree, /obj/xmastree)
		. += src.format_position(tree)

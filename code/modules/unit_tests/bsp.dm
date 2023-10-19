/datum/unit_test/bsp
	var/datum/xor_rand_generator/R

/datum/unit_test/bsp/Run()
		var/datum/bsp_tree/tree
		tree = new(width=world.maxx, height=world.maxy, min_width=7, min_height=7)
		check_allocation(tree)
		tree = new(x=5, width=300, y=5, height=300, min_width=30, min_height=30)
		check_allocation(tree)

/datum/unit_test/bsp/proc/check_allocation(datum/bsp_tree/T)
	var/x
	var/y
	var/datum/bsp_node/root
	var/list/grid = new/list(root.x+root.width+1,root.y+root.height+1)
	var/list/leaves = new/list()
	for(var/datum/bsp_node/node in T.leaves)
		TEST_ASSERT(node.width >= T.min_width, "Test node meets width requirement.")
		TEST_ASSERT(node.height >= T.min_height, "Test node meets height requirement.")
		for(x in root.x to root.x+root.width)
			for(y in root.y to root.y+root.height)
				TEST_ASSERT(grid[x][y] == null, "Test leaf contents are mutually exclusive.([x],[y])")
				grid[x][y] = TRUE

		if(node == node.parent.left)
			TEST_ASSERT(T.are_nodes_adjacent(node.parent.left,node.parent.right), "Test balanced leaves are adjacent.")

	leaves = T.get_leaves(root)
	TEST_ASSERT(length(T.leaves ^ leaves)==0, "Test iterated list of leaves matches what is generated on creation.")

	for(x in 1 to root.x+root.width+1)
		for(y in 1 to root.y+root.height+1)
			if(x < root.x && grid[x][y])
				TEST_ASSERT(grid[x][y] == null, "Test area beyond requested region are ignored.([x],[y])")
			else if(y < root.y && grid[x][y])
				TEST_ASSERT(grid[x][y] == null, "Test area beyond requested region are ignored.([x],[y])")
			else if(x > root.x+root.width && grid[x][y])
				TEST_ASSERT(grid[x][y] == null, "Test area beyond requested region are ignored.([x],[y])")
			else if(y > root.y+root.height && grid[x][y])
				TEST_ASSERT(grid[x][y] == null, "Test area beyond requested region are ignored.([x],[y])")
			else if(!grid[x][y])
				TEST_ASSERT(grid[x][y] == TRUE, "Test area in requested region is set.([x],[y])")

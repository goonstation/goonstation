#define NODENET_SUBNET_MAX 30

/datum/node_subnetwork
	var
		list/nodes = list()
		list/datum/node_subnetwork/buddies = list()
		datum/node_network/master
		dirty = 0

	proc
		test_merge(datum/node_subnetwork/other)
			if (nodes.len + other.nodes.len <= NODENET_SUBNET_MAX) // if we can; merge
				nodes += other.nodes
				buddies |= other.buddies
				other.master.subnetworks -= other
				for (var/atom/node3 in other.nodes)
					node3:subnetwork = src
			else
				other.buddies += src // otherwise just put it in the buddy list

		check_split()
			var/list/found = list(src.nodes[1])
			var/list/buddies = list()
			for (var/P = 1; P <= found.len; P++)
				var/atom/node = found[P]
				for (var/dir in node:connect_dirs)
					if (dir == 0) continue
					for (var/atom/A in get_step(node, dir))
						if (hasvar(A, "network") && A:network == master && (turn(dir, 180) in A:connect_dirs))
							if (A:subnetwork == src)
								found |= A
							else
								buddies |= A:subnetwork
				for (var/atom/A in get_turf(node))
					if (hasvar(A, "network") && A:network == master)
						var/list/dirs = node:connect_dirs & A:connect_dirs
						if (dirs.len)
							if (A:subnetwork == src)
								found |= A
							else
								buddies |= A:subnetwork
			if (found.len == nodes.len) // not split
				if (src.buddies.len != buddies.len)
					src.buddies = buddies
					return 1 // however, the buddy list has changed
				return 0 // not split
			// otherwise; its time to split
			var/list/oldnodes = src.nodes
			src.nodes = found
			src.buddies = buddies
			oldnodes -= found
			while (oldnodes.len > 0)
				var/datum/node_subnetwork/newnet = new
				newnet.nodes = list(oldnodes[1])
				master.subnetworks += newnet
				for (var/P = 1; P <= newnet.nodes.len; P++)
					var/atom/node = newnet.nodes[P]
					node:subnetwork = newnet
					for (var/dir in node:connect_dirs)
						if (dir == 0) continue
						for (var/atom/A in get_step(node, dir))
							if (hasvar(A, "network") && A:network == master && (turn(dir, 180) in A:connect_dirs))
								if (A:subnetwork == src)
									newnet.nodes |= A
								else
									newnet.buddies |= A:subnetwork
					for (var/atom/A in get_turf(node))
						if (A != node && hasvar(A, "network") && A:network == master)
							var/list/dirs = node:connect_dirs & A:connect_dirs
							if (dirs.len)
								if (A:subnetwork == src)
									newnet.nodes |= A
								else
									newnet.buddies |= A:subnetwork
				oldnodes -= newnet.nodes
			return 1

var/list/datum/node_network/node_networks = list()
/datum/node_network
	var
		list/datum/node_subnetwork/subnetworks = list()
		dirty = 0

	New(initial)
		node_networks += src
		if (initial)
			var/datum/node_subnetwork/initial_subnet = new
			initial_subnet.master = src
			initial:network = src
			initial:subnetwork = initial_subnet
			initial_subnet.nodes += initial
			subnetworks += initial_subnet

	disposing()
		node_networks -= src

	proc
		merge(datum/node_network/other, atom/by, atom/byother)
			var/datum/node_subnetwork/subnet = by:subnetwork
			var/datum/node_subnetwork/subnet_other = byother:subnetwork
			for (var/datum/node_subnetwork/merge_subnet)
				for (var/atom/node in merge_subnet.nodes)
					node:network = src
					node:network_changed()
			subnet.test_merge(subnet_other)
			qdel(other)

		connect(atom/node, atom/by, list/atom/others)
			var/datum/node_subnetwork/subnet = by:subnetwork
			if (subnet.nodes.len >= NODENET_SUBNET_MAX)
				var/datum/node_subnetwork/new_subnet = new
				new_subnet.master = src
				subnet.buddies += new_subnet
				subnetworks += new_subnet
				subnet = new_subnet
			subnet.nodes += node
			node:network = src
			node:subnetwork = subnet
			for (var/atom/node2 in others)
				var/datum/node_network/other_network = node2:network
				if (other_network != src)
					merge(other_network, node, node2)
				else
					var/datum/node_subnetwork/other_subnet = node2:subnetwork
					if (other_subnet == subnet)
						continue
					subnet.test_merge(other_subnet)

		disconnect(atom/node)
			var/datum/node_subnetwork/subnet = node:subnetwork
			subnet.nodes -= node
			node:network = null
			node:subnetwork = null
			subnet.dirty = 1
			src.dirty = 1

		update()
			if (!src.dirty)
				return
			var/check = 0
			for (var/datum/node_subnetwork/subnet in subnetworks)
				if (subnet.dirty)
					if (subnet.check_split())
						check = 1
					subnet.dirty = 0

			if (check)
				check_split()

		check_split()
			var/list/datum/node_subnetwork/found = list(subnetworks[1])
			for (var/P = 1; P <= found.len; P++)
				var/datum/node_subnetwork/subnet = found[P]
				for (var/datum/node_subnetwork/other in subnet.buddies)
					found |= subnet.buddies
			if (found.len == subnetworks.len)
				return
			var/list/datum/node_subnetwork/old_subnets = subnetworks
			subnetworks = found
			old_subnets -= subnetworks
			while (old_subnets.len > 0)
				var/datum/node_network/new_network = new
				new_network.subnetworks = list(old_subnets[1])
				for (var/P = 1; P <= new_network.subnetworks.len; P++)
					var/datum/node_subnetwork/subnet = new_network.subnetworks[P]
					for (var/atom/A in subnet.nodes)
						A:network = new_network
						A:network_changed()
					for (var/datum/node_subnetwork/other in subnet.buddies)
						new_network.subnetworks |= subnet.buddies
				old_subnets -= new_network.subnetworks

/atom/proc
	connect_nodenet(type)
		if (src:network)
			return
		var/list/targets = list()
		for (var/dir in src:connect_dirs)
			for (var/atom/A in get_step(src, dir))
				if (hasvar(A, "network") && istype(A:network, type) && (turn(dir, 180) in A:connect_dirs))
					targets += A
		for (var/atom/A in get_turf(src))
			if (hasvar(A, "network") && istype(A:network, type))
				var/list/dirs = src:connect_dirs & A:connect_dirs
				if (dirs.len)
					targets += A
		if (!targets.len)
			new type(src)
		else
			var/atom/I = targets[1]
			targets.Cut(1, 2)
			var/datum/node_network/network = I:network
			network.connect(src, I, targets)

	disconnect_nodenet()
		var/datum/node_network/network = src:network
		if (network)
			network.disconnect(src)

/datum/node_network/power
	var
		voltage
		current

	update()
		..()
		var/load = rand(50, 200)
		var/load_inverse = 1/load
		var/total_current = (10000/50) + (230/100)
		var/total_inverse_resistance = (1/50 + 1/100 + load_inverse)
		voltage = total_current/total_inverse_resistance
		//boutput(world, "voltage: [voltage] current: [voltage*load_inverse] load: [load]")

/obj/newcable
	var
		datum/node_network/power/network
		subnetwork
		dir1 = NORTH
		dir2 = SOUTH
		connect_dirs = list()

	name = "power cable"
	icon = 'icons/obj/power_cond.dmi'
	icon_state = "1-2"

	disposing()
		src.disconnect_nodenet()

	New(loc, ndir1, ndir2)
		..()
		if (ndir1 || ndir2)
			dir1 = ndir1
			dir2 = ndir2
		setup()

	proc
		setup()
			connect_dirs = list(dir1, dir2)
			src.connect_nodenet(/datum/node_network/power)
			icon_state = "[dir1]-[dir2]"

		network_changed()

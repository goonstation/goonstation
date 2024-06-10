
#define PARENT(x) data[x][1]
#define RANK(x) data[x][2]

/**
 * Union-find data structure.
 *
 * This is a data structure that keeps track of a set of elements partitioned
 * into a number of disjoint (non-overlapping) subsets. It provides near-constant-time
 * operations (bounded by the inverse Ackermann function) to add new sets, to merge
 * existing sets, and to determine whether elements are in the same set.
 */
/datum/unionfind
	VAR_PRIVATE/list/data

	/// Creates a new union-find data structure with the given number of elements.
	/// The elements will be numbers from 1 to size.
	New(size)
		..()
		data = list()
		for (var/i in 1 to size)
			data += list(list(i, 0))

	/// Finds the representative of the set that the given element is in.
	proc/Find(a)
		while (PARENT(a) != a)
			PARENT(a) = PARENT(PARENT(a))
			a = PARENT(a)
		return a

	/// Merges the sets that the given elements are in.
	proc/Union(a, b)
		a = Find(a)
		b = Find(b)
		if (a == b)
			return
		if (RANK(a) < RANK(b))
			PARENT(a) = b
		else
			PARENT(b) = a
			if (RANK(a) == RANK(b))
				RANK(a) += 1

	/// Returns whether the given elements are in the same set.
	proc/InSameSet(a, b)
		return Find(a) == Find(b)

#undef PARENT
#undef RANK

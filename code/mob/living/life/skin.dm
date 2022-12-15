
/datum/lifeprocess/skin
	process(var/datum/gas_mixture/environment)
		if (owner.skin_process && length(owner.skin_process))

			var/mult = get_multiplier()
			//patches become wasteful with >2 patches applied
			//gives patches a way to heal quickly if you slap on a whole bunch, but at the cost of flinging chems into nothingness

			var/use_volume = 0.5 * mult //amount applied via touch
			var/waste_volume = use_volume * max(length(owner.skin_process) * 0.75, 1) //amount that gets removed from the patch. Half of this gets transferred into the body

			for (var/atom/movable/A as anything in owner.skin_process)

				if (A.loc != owner)
					owner.skin_process -= A
					continue

				if (A.reagents?.total_volume)
					A.reagents.reaction(owner, TOUCH, react_volume = use_volume, paramslist = (A.reagents.total_volume == A.reagents.maximum_volume) ? 0 : list("silent", "nopenetrate", "ignore_chemprot"))
					A.reagents.trans_to(owner, waste_volume/2)
					A.reagents.remove_any(waste_volume/2)
				else
					if (A.disposed)
						stack_trace("Disposed patch [identify_object(A)] was in mob [identify_object(owner)]'s skin process. Removing.")
						A.set_loc(null)
					else
						qdel(A)
		..()

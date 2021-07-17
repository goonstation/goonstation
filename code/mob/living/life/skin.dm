
/datum/lifeprocess/skin
	//handle_skinstuff((life_time_passed / tick_spacing))
	process(var/datum/gas_mixture/environment)
		if (owner.skin_process && length(owner.skin_process))

			var/mult = get_multiplier()
			//patches become wasteful with >2 patches applied
			//gives patches a way to heal quickly if you slap on a whole bunch, but at the cost of flinging chems into nothingness

			var/use_volume = 0.5 * mult //amount applied via touch
			var/waste_volume = use_volume * min(length(owner.skin_process) * 0.75, 1) //amount that gets removed from the patch. Half of this gets transferred into the body

			for (var/atom/A as anything in owner.skin_process)

				if (A.loc != owner)
					owner.skin_process -= A
					continue

				if (A.reagents && A.reagents.total_volume)
					A.reagents.reaction(owner, TOUCH, react_volume = use_volume, paramslist = (A.reagents.total_volume == A.reagents.maximum_volume) ? 0 : list("silent", "nopenetrate"))
					A.reagents.trans_to(owner, waste_volume/2)
					A.reagents.remove_any(waste_volume/2)
				else
					if (A.reagents.total_volume <= 0)
						owner.skin_process -= A //disposing will do this too but whatever
						qdel(A)
		..()

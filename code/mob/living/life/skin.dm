
/datum/lifeprocess/skin
	//handle_skinstuff((life_time_passed / tick_spacing))
	process(var/datum/gas_mixture/environment)
		if (owner.skin_process && owner.skin_process.len)

			var/mult = get_multiplier()
			//you absorb shit faster if you have lots of patches stacked
			//gives patches a way to heal quickly if you slap on a whole bunch, also makes long heals over time less viable

			var/multi_process_mult = owner.skin_process.len > 1 ? (owner.skin_process.len * 1.5) : 1
			var/use_volume = 0.35 * mult * multi_process_mult

			for (var/atom/A as() in owner.skin_process)

				if (A.loc != owner)
					owner.skin_process -= A
					continue

				if (A.reagents && A.reagents.total_volume)
					A.reagents.reaction(owner, TOUCH, react_volume = use_volume, paramslist = (A.reagents.total_volume == A.reagents.maximum_volume) ? 0 : list("silent", "nopenetrate"))
					A.reagents.trans_to(owner, use_volume/2)
					A.reagents.remove_any(use_volume/2)
				else
					if (A.reagents.total_volume <= 0)
						owner.skin_process -= A //disposing will do this too but whatever
						qdel(A)
		..()

#define STATE_DEAD 0
#define STATE_DEPLOYING 1
#define STATE_EXPANDING 2
#define STATE_DO_LIPIDS 3
#define STATE_FORTIFYING 4
#define STATE_UNDER_ATTACK 5

/mob/living/intangible/blob_overmind/ai
	var/static/next_id = 1
	var/ai_id
	var/state = 0
	var/calm_state = 0
	var/force_state = 0
	var/mob/living/attacker
	var/list/attackers = list()

	var/counter = 4
	var/refresh_lists = 0
	var/datum/blob_ability/deploy = null
	var/datum/blob_ability/attack = null
	var/datum/blob_ability/spread = null
	var/datum/blob_ability/lipid = null
	var/datum/blob_ability/mito = null
	var/datum/blob_ability/wall = null
	var/datum/blob_ability/absorb = null
	var/datum/blob_upgrade/spread_up = null
	var/datum/blob_upgrade/gen_up = null
	var/datum/blob_upgrade/fireres_up = null

	var/turf/last_spread = null
	var/turf/last_lost = null
	var/list/extreme = list()
	var/list/open = list()
	var/list/open_medium = list()
	var/list/open_low = list()
	var/lipid_count = 0
	var/turf/destroying = null
	var/turf/fortifying = null
	var/turf/protecting = null
	var/destroy_level = 0
	var/list/consider_destroy = list(/obj/reagent_dispensers = 1, /obj/table = 1, /obj/machinery/computer3 = 1, /obj/machinery/computer = 1, /obj/storage/secure/closet = 1, /obj/storage/closet = 1, /obj/machinery/door/airlock = 2, /obj/window = 2, /obj/grille = 2)

	var/list/closed = list()

	New()
		ai_id = src.next_id
		src.next_id++
		state = STATE_DEPLOYING
		..()
		name = "Blob AI #[ai_id]"
		real_name = name
		deploy = locate(/datum/blob_ability/plant_nucleus) in abilities

	proc/priority(var/obj/O)
		if (!O.density)
			return 0
		for (var/t in consider_destroy)
			if (istype(O, t))
				return consider_destroy[t]
		return 3

	proc/is_bottleneck(var/turf/T)
		var/turf/N = locate(T.x, T.y + 1, T.z)
		var/turf/S = locate(T.x, T.y - 1, T.z)
		var/turf/E = locate(T.x + 1, T.y, T.z)
		var/turf/W = locate(T.x - 1, T.y, T.z)
		var/NV = evaluate_no_add(N)
		var/SV = evaluate_no_add(S)
		var/EV = evaluate_no_add(E)
		var/WV = evaluate_no_add(W)
		if (N)
			if (locate(/obj/machinery/door) in N)
				return 100
		if (S)
			if (locate(/obj/machinery/door) in S)
				return 100
		if (E)
			if (locate(/obj/machinery/door) in E)
				return 100
		if (W)
			if (locate(/obj/machinery/door) in W)
				return 100
		if (NV > 1 && SV > 1)
			return 100
		if (EV > 1 && WV > 1)
			return 100
		if (NV > 0 && SV > 0)
			return 50
		if (EV > 0 && WV > 0)
			return 50
		if (NV > 0)
			var/turf/SS = locate(T.x, T.y - 2, T.z)
			if (evaluate_no_add(SS) > 0)
				return 25
		if (SV > 0)
			var/turf/NN = locate(T.x, T.y + 2, T.z)
			if (evaluate_no_add(NN) > 0)
				return 25
		if (EV > 0)
			var/turf/WW = locate(T.x - 2, T.y, T.z)
			if (evaluate_no_add(WW) > 0)
				return 25
		if (WV > 0)
			var/turf/EE = locate(T.x + 2, T.y, T.z)
			if (evaluate_no_add(EE) > 0)
				return 25
		return 0


	proc/update_lists(var/turf/ST)
		if (ST in open)
			open -= ST
		var/turf/N = locate(ST.x, ST.y + 1, ST.z)
		var/turf/S = locate(ST.x, ST.y - 1, ST.z)
		var/turf/E = locate(ST.x + 1, ST.y, ST.z)
		var/turf/W = locate(ST.x - 1, ST.y, ST.z)
		if (N)
			evaluate(N)
		if (S)
			evaluate(S)
		if (E)
			evaluate(E)
		if (W)
			evaluate(W)

	proc/get_nearby_convertable_blob(var/turf/T)
		for (var/obj/blob/B in orange(1, T))
			if (B.type == /obj/blob)
				return B
		return null

	proc/evaluate_no_add(var/turf/C)
		if (!C)
			return -2
		if (locate(/obj/blob/wall) in C)
			return 3
		if (locate(/obj/blob) in C)
			return -1
		if (!has_adjacent_blob(C))
			return -1
		var/cl
		if (C.density || istype(C, /turf/space))
			cl = 3
		else
			cl = 0
			for (var/obj/O in C)
				var/prior = priority(O)
				if (prior > cl)
					cl = prior
				if (cl == 3)
					break
		return cl

	proc/evaluate(var/turf/C)
		var/cl = evaluate_no_add(C)
		switch (cl)
			if (0)
				open += C
			if (1)
				open_medium += C
			if (2)
				open_low += C
			if (3)
				closed += C

	proc/has_adjacent_blob(var/turf/T)
		var/turf/N = locate(T.x, T.y + 1, T.z)
		var/turf/S = locate(T.x, T.y - 1, T.z)
		var/turf/E = locate(T.x + 1, T.y, T.z)
		var/turf/W = locate(T.x - 1, T.y, T.z)
		if (N)
			if (locate(/obj/blob) in N)
				return 1
		if (S)
			if (locate(/obj/blob) in S)
				return 1
		if (E)
			if (locate(/obj/blob) in E)
				return 1
		if (W)
			if (locate(/obj/blob) in W)
				return 1
		return 0

	proc/pick_deployment_location()
		var/turf/T = get_turf(src)
		if (T.density || istype(T, /turf/space) || prob(50))
			var/nx = T.x + round(rand(-2, 2) + ((150 - T.x) / 37.5))
			var/ny = T.y + round(rand(-2, 2) + ((150 - T.y) / 37.5))
			var/turf/Q = locate(nx, ny, T.z)
			if (Q)
				return Q
		return T

	proc/check_viability(var/turf/start)
		var/list/closed = list()
		var/list/open = list(start)
		var/viability = 0
		while (open.len)
			var/turf/T = open[1]
			viability++
			if (viability >= 100)
				return 1
			open.Cut(1,2)
			closed += T
			var/turf/N = locate(T.x, T.y + 1, T.z)
			var/turf/S = locate(T.x, T.y - 1, T.z)
			var/turf/W = locate(T.x - 1, T.y, T.z)
			var/turf/E = locate(T.x + 1, T.y, T.z)
			if (N)
				if (!istype(N, /turf/space) && !N.density && !(N in closed) && !(N in open))
					open += N
			if (S)
				if (!istype(S, /turf/space) && !S.density && !(S in closed) && !(S in open))
					open += S
			if (W)
				if (!istype(W, /turf/space) && !W.density && !(W in closed) && !(W in open))
					open += W
			if (E)
				if (!istype(E, /turf/space) && !E.density && !(E in closed) && !(E in open))
					open += E
		return 0

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1
		if (client)
			return
		if (!blobs.len && state != 1)
			return
		if (refresh_lists > 50 && state > 1)
			logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Refreshing lists.")
			refresh_lists = 0
			var/list/all = open + open_low + open_medium + closed
			open.len = 0
			closed.len = 0
			open_low.len = 0
			open_medium.len = 0
			for (var/turf/C in all)
				evaluate(C)
			for (var/turf/T in range(30, src))
				if (!(T in all))
					evaluate(T)

		if (state > 1)
			if (fireres_up)
				if (fireres_up.check_requirements())
					fireres_up.take_upgrade()
					fireres_up = null
					logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Took fire resistance upgrade.")

			if (absorb)
				for (var/mob/living/carbon/human/H in range(33, src))
					if (!isturf(H.loc))
						continue
					if (isdead(H))
						continue
					if (H.decomp_stage >= 4)
						continue
					if (!(locate(/obj/blob) in H.loc))
						var/turf/T = get_turf(H)
						if (has_adjacent_blob(T) && prob(15))
							attack_now(T)
							if (T.can_blob_spread_here())
								spread_to(T, 0)
							logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Can't absorb [H] (no blob on tile), attacking instead at [log_loc(H)].")
						continue
					if (prob(118 - 3 * get_dist(src, H)))
						absorb.onUse(H.loc)
						logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Absorbing [H].")

		switch (state)
			if (STATE_DEAD)
				return
			if (STATE_DEPLOYING)
				counter--
				if (counter <= 0)
					var/turf/T = pick_deployment_location()
					if (!T)
						T = get_turf(pick_landmark(LANDMARK_OBSERVER)) // contingency
					set_loc(T)
					if (!deploy)
						logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Invalid state for [src]: Cannot find deploy ability in state DEPLOYING.")
						state = 0
						return
					color = random_color()
					my_material.color = color
					initial_material.color = color
					if (istype(T, /turf/space))
						return // Do not deploy on space.
					if (!check_viability(T))
						return
					deploy.onUse(T)
					if (deploy in abilities)
						logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Deploy failed.")
						return
					state = STATE_EXPANDING
					last_spread = T
					update_lists(T)
					spread = locate(/datum/blob_ability/spread) in abilities
					attack = locate(/datum/blob_ability/attack) in abilities
					lipid = locate(/datum/blob_ability/build/ribosome) in abilities
					mito = locate(/datum/blob_ability/build/mitochondria) in abilities
					wall = locate(/datum/blob_ability/build/wall) in abilities
					absorb = locate(/datum/blob_ability/absorb) in abilities
					spread_up = locate(/datum/blob_upgrade/quick_spread) in available_upgrades
					gen_up = locate(/datum/blob_upgrade/extra_genrate) in available_upgrades
					fireres_up = locate(/datum/blob_upgrade/fire_resist) in available_upgrades
					logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Deployed blob to ([T.x], [T.y], [T.z]).")
					counter = 0
			if (STATE_EXPANDING)
				refresh_lists++
				if (blobs.len > 15 && prob(blobs.len / (lipid_count + 1)))
					state = STATE_DO_LIPIDS
				if (!(gen_up in available_upgrades))
					gen_up = null
				if (!(spread_up in available_upgrades))
					spread_up = null
				if (gen_up)
					if (gen_up.check_requirements())
						gen_up.take_upgrade()
						logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Took generation rate upgrade while expanding.")
				if (spread_up)
					if (spread_up.check_requirements())
						spread_up.take_upgrade()
						logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Took spread upgrade while expanding.")
				var/turf/ST = null
				if (destroying && !has_adjacent_blob(destroying))
					destroying = null
				if (open.len && !destroying)
					if (bio_points < spread.bio_point_cost)
						return
					for (var/turf/Q in range(5, last_spread))
						if (Q in open)
							if (Q.can_blob_spread_here())
								ST = Q
								break
							else
								open -= Q
								evaluate(Q)
						else if (!(Q in open_medium) && !(Q in open_low) && !(Q in closed))
							evaluate(Q)
							if (Q in open)
								ST = Q
					if (!ST)
						do
							if (!open.len)
								break
							var/turf/Q = pick(open)
							if (Q.can_blob_spread_here())
								ST = Q
								break
							else
								open -= Q
								evaluate(Q)
						while (!ST)
				if (ST && !destroying)
					if (!spread)
						logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Invalid state for [src]: Cannot find spread ability in state EXPANDING.")
					spread_to(ST, 1)
					return
				if ((open_medium.len && !destroying) || (destroying && destroy_level == 1))
					if (bio_points < attack.bio_point_cost)
						return
					ST = null
					if (destroying)
						ST = destroying
					else
						do
							if (ST)
								evaluate(ST)
								ST = null
							if (!open_medium.len)
								break
							ST = pick(open_medium)
							open_medium -= ST
						while (evaluate_no_add(ST) != 1)
					if (ST)
						destroying = ST
						destroy_level = 1
						set_loc(ST)
						attack.onUse(ST)
						logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Attacking tile at [showCoords(ST.x, ST.y, ST.z)].")
						var/new_score = evaluate_no_add(ST)
						if (new_score != 1)
							switch (new_score)
								if (0)
									open += ST
								if (2)
									open_low += ST
								if (3)
									closed += ST
							destroying = null
						return
					else if (destroying)
						destroying = null
				if (open_low.len || destroying)
					if (bio_points < attack.bio_point_cost)
						return
					ST = null
					if (destroying)
						ST = destroying
					else
						do
							if (ST)
								evaluate(ST)
								ST = null
							if (!open_low.len)
								break
							ST = pick(open_low)
							open_low -= ST
						while (evaluate_no_add(ST) != 2)
					if (ST)
						destroying = ST
						destroy_level = 2
						set_loc(ST)
						attack.onUse(ST)
						logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Attacking tile at [showCoords(ST.x, ST.y, ST.z)].")
						var/new_score = evaluate_no_add(ST)
						if (new_score != 2)
							switch (new_score)
								if (0)
									open += ST
								if (1)
									open_medium += ST
								if (3)
									closed += ST
							destroying = null
						return
					else if (destroying)
						destroying = null
				if (force_state)
					state = force_state
					force_state = 0
			if (STATE_DO_LIPIDS)
				if (bio_points < lipid.bio_point_cost)
					return
				var/obj/blob/A
				if (!A)
					for (var/i = 0, i < 20, i++)
						var/obj/blob/C = pick(blobs)
						if (C.type == /obj/blob)
							A = C
							break
				if (!A)
					state = STATE_EXPANDING
					logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Failed to find suitable lipid candidate in 20 attempts.")
					return
				var/turf/T = get_turf(A)
				set_loc(T)
				lipid.onUse(T)
				var/obj/blob/lipid/L = locate() in T
				if (L)
					lipid_count++
				logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Creating lipid at [showCoords(T.x, T.y, T.z)].")
				state = STATE_EXPANDING
			if (STATE_FORTIFYING)
				if (!fortifying)
					state = STATE_EXPANDING
					return
				var/obj/blob/TF = locate() in fortifying
				if (!TF)
					state = STATE_EXPANDING
					return
				if (TF.type == /obj/blob)
					create_wall_if_possible(fortifying)
					return
				else if (TF.type == /obj/blob/wall)
					var/obj/blob/C = get_nearby_convertable_blob(fortifying)
					if (!C)
						state = STATE_EXPANDING
						return
					if (bio_points < mito.bio_point_cost)
						if (prob(20))
							state = STATE_EXPANDING
						return
					var/turf/T = get_turf(C)
					if (get_gen_rate() < 4)
						state = STATE_EXPANDING
					else if (create_mitochondria_if_possible(T) || prob(40))
						state = STATE_EXPANDING
				else
					state = STATE_EXPANDING
					return
			if (STATE_UNDER_ATTACK)
				var/attacks = rand(1,4)
				var/attack_used = 0
				var/mob/nearest = null
				var/n_dist = 5000
				if (attacker)
					if (!isturf(attacker.loc) || !has_adjacent_blob(attacker.loc) || attacker.stat || isintangible(attacker))
						attacker = null
				if (!attacker)
					if (attackers.len)
						for (var/mob/living/M in attackers)
							if (isintangible(M))
								attackers -= M
								continue
							if (isdead(M))
								attackers -= M
								continue
							if (isturf(M.loc))
								if (has_adjacent_blob(M.loc))
									attacker = M
									break
								else
									attackers -= M
									var/dist = get_dist(M, src)
									if (n_dist > dist)
										n_dist = dist
										nearest = M
					if (nearest)
						attackers += nearest
					if (!attacker)
						for (var/mob/living/M in range(30, src))
							if (isintangible(M))
								continue
							if (isdead(M))
								continue
							if (isturf(M.loc))
								if (has_adjacent_blob(M.loc))
									attacker = M
									break
				if (!attacker)
					counter++
					if (counter >= 5)
						attacker = null
						attackers.len = 0
						if (calm_state > 1)
							state = calm_state
						else
							state = STATE_EXPANDING
						counter = 0
						return
				if (attacker)
					var/turf/AT = get_turf(attacker)
					var/spreaded = 0
					if (!(locate(/obj/blob) in AT) && AT.can_blob_spread_here())
						spreaded = 1
						spread_to(AT, 0)
					for (var/obj/reagent_dispensers/fueltank/FU in view(attacker))
						if (has_adjacent_blob(FU.loc))
							attack_used++
							attack_now(FU.loc, attack_used)
							logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Attacking fuel tank at [showCoords(FU.x, FU.y, FU.z)] in response to attack force.")
					if (has_adjacent_blob(AT))
						attack_now(AT, attack_used)
						logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Hitting [attacker] at [showCoords(attacker.loc.x, attacker.loc.y, attacker.loc.z)] [attacks - attack_used] times.")
					var/obj/blob/B = get_nearby_convertable_blob(attacker.loc)
					if (B)
						create_wall_if_possible(get_turf(B))
					if (!spreaded)
						for (var/turf/T in range(2, attacker))
							if (T.can_blob_spread_here())
								spread_to(T, 0)
								logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Spreading near [attacker] to [showCoords(T.x, T.y, T.z)] in response to attack force.")
								break
				else if (!attacker)
					var/obj/blob/F = null
					//var/preferred = 0
					for (var/obj/blob/B in range(10, nearest))
						if (B.type == /obj/blob)
							var/obj/blob/adj_blob = locate(/obj/blob) in get_step_towards(B, nearest)
							if (!adj_blob)
								continue
							if (adj_blob.type == /obj/blob)
								continue
							F = B
							/*if (adj_blob.type == /obj/blob/wall)
								preferred = 1
							else
								preferred = 0*/
							break
					if (F)
						var/turf/T = get_turf(F)
						create_mitochondria_if_possible(T)
					for (var/turf/T in range(5, nearest))
						if (T.can_blob_spread_here())
							spread_to(T, 0)
							logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Spreading near nearest [nearest] to [showCoords(T.x, T.y, T.z)] in response to attack force.")
							break

	proc/attack_now(var/turf/T)
		attack.last_used = 0 // cheat, to compensate for the loop's tick rate
		set_loc(T)
		attack.onUse(T)

	proc/spread_to(var/turf/ST, var/is_calm)
		set_loc(ST)
		spread.onUse(ST)
		if (locate(/obj/blob) in ST)
			open -= ST
			if (is_calm)
				last_spread = ST
			logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Spreading to [showCoords(ST.x, ST.y, ST.z)].")
		else
			return
		update_lists(ST)
		if (!is_calm)
			return
		if (locate(/obj/machinery/power/apc) in ST)
			destroying = ST
			destroy_level = 1
		if (prob(is_bottleneck(ST)))
			if (destroying)
				force_state = STATE_FORTIFYING
			else
				state = STATE_FORTIFYING
			fortifying = ST

	proc/create_mitochondria_if_possible(var/turf/T)
		if (bio_points >= mito.bio_point_cost && mito.last_used <= world.time)
			set_loc(T)
			mito.onUse(T)
			logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Creating mitochondria at [showCoords(T.x, T.y, T.z)].")
			return 1
		return 0

	proc/create_wall_if_possible(var/turf/T)
		if (bio_points >= wall.bio_point_cost && wall.last_used <= world.time)
			set_loc(T)
			wall.onUse(T)
			logTheThing("debug", src, null, "<b>Marquesas/AI Blob:</b> Creating wall at [showCoords(T.x, T.y, T.z)].")
			return 1
		return 0

	onBlobHit(var/obj/blob/B, var/mob/M)
		if (!prob(max(1, min(100, (2000 - 100 * get_dist(B, src)) / 13))))
			return
		if (!(M in attackers))
			attackers += M
		if (!attacker)
			attacker = M
		if (state != STATE_UNDER_ATTACK)
			calm_state = state
			state = STATE_UNDER_ATTACK
		counter = 0

	onBlobDeath(var/obj/blob/B, var/mob/M)
		if (!prob(max(1, min(100, (2000 - 100 * get_dist(B, src)) / 13))))
			return
		attacker = M
		if (istype(B, /obj/blob/lipid))
			if (lipid_count > 0)
				lipid_count--
		if (state != STATE_UNDER_ATTACK)
			calm_state = state
			state = STATE_UNDER_ATTACK
		counter = 0

#undef STATE_UNDER_ATTACK
#undef STATE_FORTIFYING
#undef STATE_DO_LIPIDS
#undef STATE_EXPANDING
#undef STATE_DEPLOYING
#undef STATE_DEAD

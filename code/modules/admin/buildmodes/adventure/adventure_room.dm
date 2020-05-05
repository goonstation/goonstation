/datum/adventure_submode/turf/room
	var/floortype = null
	var/walltype = null
	var/static/list/rooms = list("Ancient", "Cave", "Hive", "Martian", "Shuttle", "Shielded", "Void", "Wizard")

	name = "Room"

	proc/reset_lum(var/turf/at)
		at.RL_Reset()

	click_left(var/atom/object, location, control, params)
		if(!floortype || !walltype)
			return
		if (!A)
			A = get_turf(object)
			A.overlays += marker
			return
		else
			var/turf/B = get_turf(object)
			if (A.z != B.z)
				boutput(usr, "<span style=\"color:red\">The two corners must be on the same Z!</span>")
				return

			var/tz = A.z
			var/minx = min(A.x, B.x)
			var/miny = min(A.y, B.y)
			var/maxx = max(A.x, B.x)
			var/maxy = max(A.y, B.y)


			if (minx >= maxx - 1 || miny >= maxy - 1)
				for(var/turf/T in block(A, B))
					var/atom/at = new walltype(T)
					at.dir = holder.dir
					blink(get_turf(at))
					new /area/adventure(at)
					reset_lum(at)
			else
				var/tx
				var/ty
				var/turf/adj
				var/turf/adj2
				var/turf/adj3
				var/turf/adj4
				var/turf/C
				// iterate edges
				for (ty = miny + 1, ty <= maxy - 1, ty++)
					// west edge
					tx = minx
					adj = locate(tx - 1, ty, tz)
					if (!adj || adj.density || istype(adj, /turf/space))
						C = new walltype(locate(tx, ty, tz))
					else
						C = new floortype(locate(tx, ty, tz))
					C.dir = WEST
					blink(C)
					new /area/adventure(C)
					reset_lum(C)

					// east edge
					tx = maxx
					adj = locate(tx + 1, ty, tz)
					if (!adj || adj.density || istype(adj, /turf/space))
						C = new walltype(locate(tx, ty, tz))
					else
						C = new floortype(locate(tx, ty, tz))
					C.dir = EAST
					blink(C)
					new /area/adventure(C)
					reset_lum(C)

				for (tx = minx + 1, tx <= maxx - 1, tx++)
					// south edge
					ty = miny
					adj = locate(tx, ty - 1, A.z)
					if (!adj || adj.density || istype(adj, /turf/space))
						C = new walltype(locate(tx, ty, tz))
					else
						C = new floortype(locate(tx, ty, tz))
					C.dir = SOUTH
					blink(C)
					new /area/adventure(C)
					reset_lum(C)

					// north edge
					ty = maxy
					adj = locate(tx, ty + 1, A.z)
					if (!adj || adj.density || istype(adj, /turf/space))
						C = new walltype(locate(tx, ty, tz))
					else
						C = new floortype(locate(tx, ty, tz))
					C.dir = NORTH
					blink(C)
					new /area/adventure(C)
					reset_lum(C)

				// SW
				tx = minx
				ty = miny
				adj = locate(tx + 1, ty, tz)
				adj2 = locate(tx, ty + 1, tz)
				if ((adj && !adj.density) || (adj2 && !adj2.density))
					adj3 = locate(tx - 1, ty, tz)
					adj4 = locate(tx, ty - 1, tz)
					if (!adj3 || !adj4 || istype(adj3, /turf/space) || istype(adj4, /turf/space) || adj3.density || adj4.density)
						C = new walltype(locate(tx, ty, tz))
					else
						C = new floortype(locate(tx, ty, tz))
				else
					C = new walltype(locate(tx, ty, tz))
				C.dir = SOUTHWEST
				blink(C)
				new /area/adventure(C)
				reset_lum(C)

				// SE
				tx = maxx
				ty = miny
				adj = locate(tx - 1, ty, tz)
				adj2 = locate(tx, ty + 1, tz)
				if ((adj && !adj.density) || (adj2 && !adj2.density))
					adj3 = locate(tx + 1, ty, tz)
					adj4 = locate(tx, ty - 1, tz)
					if (!adj3 || !adj4 || istype(adj3, /turf/space) || istype(adj4, /turf/space) || adj3.density || adj4.density)
						C = new walltype(locate(tx, ty, tz))
					else
						C = new floortype(locate(tx, ty, tz))
				else
					C = new walltype(locate(tx, ty, tz))
				C.dir = SOUTHEAST
				blink(C)
				new /area/adventure(C)
				reset_lum(C)

				// NW
				tx = minx
				ty = maxy
				adj = locate(tx + 1, ty, tz)
				adj2 = locate(tx, ty - 1, tz)
				if ((adj && !adj.density) || (adj2 && !adj2.density))
					adj3 = locate(tx - 1, ty, tz)
					adj4 = locate(tx, ty + 1, tz)
					if (!adj3 || !adj4 || istype(adj3, /turf/space) || istype(adj4, /turf/space) || adj3.density || adj4.density)
						C = new walltype(locate(tx, ty, tz))
					else
						C = new floortype(locate(tx, ty, tz))
				else
					C = new walltype(locate(tx, ty, tz))
				C.dir = NORTHWEST
				blink(C)
				new /area/adventure(C)
				reset_lum(C)

				// NE
				tx = maxx
				ty = maxy
				adj = locate(tx - 1, ty, tz)
				adj2 = locate(tx, ty - 1, tz)
				if ((adj && !adj.density) || (adj2 && !adj2.density))
					adj3 = locate(tx + 1, ty, tz)
					adj4 = locate(tx, ty + 1, tz)
					if (!adj3 || !adj4 || istype(adj3, /turf/space) || istype(adj4, /turf/space) || adj3.density || adj4.density)
						C = new walltype(locate(tx, ty, tz))
					else
						C = new floortype(locate(tx, ty, tz))
				else
					C = new walltype(locate(tx, ty, tz))
				C.dir = NORTHEAST
				blink(C)
				new /area/adventure(C)
				reset_lum(C)

				var/turf/Q = locate(minx + 1, miny + 1, tz)
				B = locate(maxx - 1, maxy - 1, tz)

				for(var/turf/T in block(Q, B))
					C = new floortype(T)
					C.dir = holder.dir
					blink(C)
					new /area/adventure(C)
					reset_lum(C)

			if (A)
				A.overlays -= marker
				A = null

	selected()
		var/kind = input(usr, "What kind of room?", "Room type", "Ancient") in src.rooms
		var/turfname = "[kind] floor"
		var/wallname = "[kind] wall"
		floortype = turfs[turfname]
		walltype = turfs[wallname]
		boutput(usr, "<span style=\"color:blue\">Now building [kind] rooms in wide area spawn mode.</span>")

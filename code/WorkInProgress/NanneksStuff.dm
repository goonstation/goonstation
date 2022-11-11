/area/projection

	name = "projection"

	icon_state = "proj"
	requires_power = 0

	var/id = 0
	var/obj/point_to_projection/pointer = null

/area/point_to_projection

	name = "pointer"

	icon_state = "pointer"
	requires_power = 0

	var/id = 0
	var/obj/projection/proj = null

	var/projection_enabled = 1


	New()
		..()
		for(var/area/projection/P in world)
			LAGCHECK(LAG_LOW)
			if(P.id == src.id)
				src.proj = P
				P.pointer = src

				src.setup_lists(P)
				break

	proc/make_icon_with_turf(var/turf/the_turf as turf)

		var/icon/I = icon('icons/misc/old_or_unused.dmi',"blank")

		var/icon/turficon = build_composite_icon(the_turf)

		I.Blend(turficon,ICON_OVERLAY)

		var/itemnumber = 0
		for(var/atom/A in the_turf)
			if(A.invisibility) continue
			if(ismob(A))
				var/icon/X = build_composite_icon(A)
				I.Blend(X,ICON_OVERLAY)
				qdel(X)

			else
				if(itemnumber < 5)
					var/icon/X = build_composite_icon(A)
					I.Blend(X,ICON_OVERLAY)
					qdel(X)

		return I

	proc/setup_lists(var/area/projection/A)
		//Takes: Area of projection
		//Returns: Nothing.
		//Notes: Attempts to project the contents of one area to another.
		//       Movement based on lower left corner. Tiles that do not fit
		//		 into the new area will not be projected.

		if(!A || !src) return 0

	//This first part here is to do with making sure the areas are the same size

		var/list/turfs_pointer = get_area_turfs(src.type)
		var/list/turfs_proj = get_area_turfs(A.type)

		var/src_min_x = 0
		var/src_min_y = 0

		for (var/turf/T in turfs_pointer)
			if(T.x < src_min_x || !src_min_x) src_min_x	= T.x
			if(T.y < src_min_y || !src_min_y) src_min_y	= T.y

		var/trg_min_x = 0
		var/trg_min_y = 0

		for (var/turf/T in turfs_proj)
			if(T.x < trg_min_x || !trg_min_x) trg_min_x	= T.x
			if(T.y < trg_min_y || !trg_min_y) trg_min_y	= T.y

	//Now we make refined lists (i.e. if the areas are not the same size these will be smaller than either
	//of the lists above)

		var/list/refined_pointer = new/list()
		for(var/turf/T in turfs_pointer)
			refined_pointer += T
			refined_pointer[T] = new/datum/coords
			var/datum/coords/C = refined_pointer[T]
			C.x_pos = (T.x - src_min_x)
			C.y_pos = (T.y - src_min_y)

		var/list/refined_proj = new/list()
		for(var/turf/T in turfs_proj)
			refined_proj += T
			refined_proj[T] = new/datum/coords
			var/datum/coords/C = refined_proj[T]
			C.x_pos = (T.x - trg_min_x)
			C.y_pos = (T.y - trg_min_y)

		project(refined_pointer, refined_proj)

	proc/project(var/list/refined_pointer, var/list/refined_proj)

		while(src.projection_enabled)

			for (var/turf/T in refined_pointer)
				var/datum/coords/C_pointer = refined_pointer[T]

				for (var/turf/B in refined_proj)
					var/datum/coords/C_proj = refined_proj[B]

					if(C_pointer.x_pos == C_proj.x_pos && C_pointer.y_pos == C_proj.y_pos)

						B.icon = make_icon_with_turf(T)

			sleep(0.5 SECONDS)




/*


This works

*/




/obj/projection

	anchored = 1
	opacity = 0

	name = "projection"

	icon = 'icons/misc/old_or_unused.dmi'
	icon_state = "blank"

	var/id = 0
	var/obj/point_to_projection/pointer = null

	proc/build_composite_icon(var/atom/C)
		var/icon/composite = icon(C.icon, C.icon_state, C.dir, 1)
		for(var/image/I as anything in C.overlays)
			composite.Blend(icon(I.icon, I.icon_state, I.dir, 1), ICON_OVERLAY)
		return composite

	proc/make_icon_with_turf(var/turf/the_turf as turf)

		var/icon/I = icon('icons/misc/old_or_unused.dmi',"blank")

		var/icon/turficon = build_composite_icon(the_turf)

		I.Blend(turficon,ICON_OVERLAY)

		var/itemnumber = 0
		for(var/atom/A in the_turf)
			if(A.invisibility) continue
			if(ismob(A))
				var/icon/X = build_composite_icon(A)
				I.Blend(X,ICON_OVERLAY)
				qdel(X)

			else
				if(itemnumber < 5)
					var/icon/X = build_composite_icon(A)
					I.Blend(X,ICON_OVERLAY)
					qdel(X)

		return I


	proc/Life()
		if(src.pointer)

			var/turf/the_turf = get_turf(src.pointer)

			src.icon = make_icon_with_turf(the_turf)

			SPAWN(0.5 SECONDS) src.Life()

		else
			logTheThing(LOG_ADMIN, null, "[src]/(%coords([src.x], [src.y], [src.z])%) not defined properly with ID = [src.id] and PTP = [src.pointer]")
			logTheThing(LOG_DIARY, "[src]/(%coords([src.x], [src.y], [src.z])%) not defined properly with ID = [src.id] and PTP = [src.pointer]", "admin")


/obj/point_to_projection

	anchored = 1
	opacity = 0

	name = "pointer"

	icon = 'icons/misc/old_or_unused.dmi'
	icon_state = "blank"

	var/id = 0
	var/obj/projection/proj = null

	New()
		for(var/obj/projection/P in world)
			LAGCHECK(LAG_LOW)
			if(P.id == src.id)
				src.proj = P
				P.pointer = src
				P.Life()
				break

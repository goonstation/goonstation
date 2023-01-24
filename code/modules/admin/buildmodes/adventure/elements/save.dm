#define ADV_SAVE_VERSION_LATEST 2

// Log for versions:
// v1: Initial version

// v2: Turfs now save data comparable to /objs. Moved x.y.TURF to x.y.TURF.data. Now versioned.
// Backwards compatibility: v1 savefiles are missing the version key. Loader considers all files with missing version keys to be v1.
// Backwards compatibility: v1 saves are missing the "x.y.TURF.* keys. Loader accounts for this."
// Backwards compatibility: v1 saves define turf type in x.y.TURF, v2 saves define turf type in x.y.TURF.type. Loader is aware.

/datum/puzzlewizard/save
	name = "EXPERIMENTAL: Save design"
	var/savename
	var/selection
	var/turf/A
	var/saving = 0

	initialize()
		selection = new /obj/adventurepuzzle/marker
		//savename = input("Save file name", "Save file name", "save") as text
		boutput(usr, "<span class='notice'>Use left clicks to mark two corners of the rectangular area to save. Saving will take a significant amount of time, and you should not modify the area until the saving is completed.</span>")

	disposing()
		if (A)
			A.overlays -= selection
		if (selection)
			qdel(selection)
		..()

	build_click(var/mob/user, var/datum/buildmode_holder/holder, var/list/pa, var/atom/object)
		if ("left" in pa)
			var/turf/T = get_turf(object)
			if ("ctrl" in pa)
				finished = 1
				return
			if (T)
				if (!A)
					A = T
					boutput(user, "<span class='notice'>Corner #1 set.</span>")
				else
					if (A.z != T.z)
						boutput(user, "<span class='alert'>Z-level mismatch.</span>")
						return
					if (saving)
						boutput(user, "<span class='alert'>Already saving.</span>")
						return
					var/fname = "adventure/ADV_SAVE_[user.client.ckey]_[world.time]"
					if (fexists(fname))
						fdel(fname)
					saving = 1
					var/turf/AS = A
					var/turf/B = T
					var/datum/puzzlewizard/save/this = src
					A = null
					boutput(user, "<span class='notice'>Corner #2 set. Now beginning saving. Modifying the area may have unexpected results. DO NOT LOG OUT OR CHANGE MOB UNTIL THE SAVING IS FINISHED.</span>")
					AS.overlays -= selection
					var/datum/sandbox/sandbox = new /datum/sandbox()
					sandbox.context["max_x"] = max(AS.x, B.x)
					sandbox.context["min_x"] = min(AS.x, B.x)
					sandbox.context["max_y"] = max(AS.y, B.y)
					sandbox.context["min_y"] = min(AS.y, B.y)
					sandbox.context["z"] = AS.z
					SPAWN(0)
						user.client.Export()
						var/savefile/F = new /savefile(fname)
						// fuck you
						F.dir.len = 0
						// and fuck you too
						F.eof = -1
						// and ESPECIALLY YOU.
						F << null
						var/w = abs(AS.x - B.x) + 1
						var/h = abs(AS.y - B.y) + 1
						var/mx = min(AS.x, B.x)
						var/my = min(AS.y, B.y)
						message_admins("[key_name(user)] initiated saving an adventure (size: [w]x[h], estimated saving duration: [w*h/30] seconds).")
						F["w"] << w
						F["h"] << h
						F["version"] << ADV_SAVE_VERSION_LATEST
						var/workgroup_size = 10
						var/workgroup_curr = 0
						for (var/turf/Q in block(AS, B))
							var/dx = Q.x - mx
							var/dy = Q.y - my
							var/base = "[dx].[dy]"
							F["[base].TURF.tag"] << "ser:\ref[Q]"
							Q.serialize(F, "[base].TURF", sandbox)
							var/objc = 0
							for (var/obj/O in Q)
								if (!istype(O, /obj/overlay) && !istype(O, /atom/movable/screen))
									O:serialize(F, "[base].OBJ.[objc]", sandbox)
									objc++
							F["[base].OBJC"] << objc
							blink(Q)
							workgroup_curr++
							if (workgroup_curr >= workgroup_size)
								workgroup_curr = 0
								sleep(0.1 SECONDS)
						if (user?.client)
							if (fexists("adventure/adventure_save_[user.client.ckey].dat"))
								fdel("adventure/adventure_save_[user.client.ckey].dat")
							var/target = file("adventure/adventure_save_[user.client.ckey].dat")
							F.ExportText("/", target)
							boutput(user, "<span class='notice'>Saving finished.</span>")
							user << ftp(target)
							if (fexists(fname))
								fdel(fname)
						if (this)
							this.saving = 0
							this.A = null
						del F

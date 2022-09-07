/datum/puzzlewizard/load
	name = "EXPERIMENTAL: Load saved design"
	var/savename
	var/pasting = 0

	initialize()
		//savename = input("Save file name", "Save file name", "save") as text
		boutput(usr, "<span class='notice'>Left click the bottom left corner of the area to fill with the saved structure. </span>")

	build_click(var/mob/user, var/datum/buildmode_holder/holder, var/list/pa, var/atom/object)
		if ("left" in pa)
			var/turf/T = get_turf(object)
			if ("ctrl" in pa)
				finished = 1
				return
			if (T)
				if (fexists("adventure/ADV_LOAD_[user.client.ckey]"))
					fdel("adventure/ADV_LOAD_[user.client.ckey]")
				if (pasting)
					boutput(user, "<span class='alert'>Already loading.</span>")
					return
				pasting = 1
				var/datum/puzzlewizard/load/this = src
				src = null
				var/target = input("Select the saved adventure zone to load.", "Saved zone upload", null) as null|file

				// fuck you you fucking useless piece of goddamn shit go away fuck you fuck shit bollocks
				// fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck
				// fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck
				// fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck
				// fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck
				// fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck
				// fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck
				// fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck
				// fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck
				// fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck
				// fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck
				// fuck fuck fuck fuck fuck fuck fuck fuck duck fuck fuck fuck fuck fuck fuck fuck fuck fuck
				// fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck
				// fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck
				// fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck
				// fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck
				// fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck
				// fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck
				// fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck
				// fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck
				// fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck fuck
				if (!target)
					pasting = 0
					return
				var/savefile/F = new /savefile("adventure/ADV_LOAD_[user.client.ckey]")
				// fuck you
				F.dir.len = 0
				// and fuck you too
				F.eof = -1
				// and ESPECIALLY YOU.
				F << null
				F.ImportText("/", file2text(target))
				if (!F)
					boutput(user, "<span class='alert'>Import failed.</span>")
					pasting = 0
					return
				var/basex = T.x
				var/basey = T.y
				var/w
				var/h
				var/cz = T.z
				var/paster = user.client.ckey
				F["w"] >> w
				F["h"] >> h
				var/version
				F["version"] >> version
				if (!version)
					version = 1
				if (!w || !h)
					boutput(user, "<span class='alert'>Size error: [w]x[h]</span>")
					return
				if (T.z == 0)
					boutput(user, "<span class='alert'>Spatial error: cannot paste onto Z 0 (how the actual fuck did you manage to get this error???)</span>")
					return
				if (!locate(basex + w, basey + h, T.z))
					boutput(user, "<span class='alert'>Spatial error: the pasted area ([w]x[h]) will not fit on the map.</span>")
				if (alert("This action will paste an area of [w]x[h]. Are you sure you wish to proceed?",, "Yes", "No") == "No")
					this.pasting = 0
					boutput(user, "<span class='alert'>Aborting paste.</span>")
					return
				message_admins("[key_name(user)] initiated loading an adventure (size: [w]x[h], estimated pasting duration: [w*h/10] seconds).")
				boutput(user, "<span class='notice'>Beginning paste. DO NOT TOUCH THE AFFECTED AREA. Or do. Something might go wrong. I don't know. Who cares.</span>")
				var/datum/sandbox/sandbox = new /datum/sandbox()
				sandbox.context["version"] = version
				SPAWN(0)
					var/workgroup_size = 10
					var/workgroup_curr = 0
					var/list/PP = list()
					for (var/cy = basey, cy < basey + h, cy++)
						var/rely = cy - basey
						for (var/cx = basex, cx < basex + w, cx++)
							var/relx = cx - basex
							var/base = "[relx].[rely]"
							var/ttype
							var/turf/Q

							var/correct_path = 1
							if (version < 2)
								F["[base].TURF"] >> ttype
								if (ispath(ttype))
									Q = locate(cx, cy, cz)
									Q.ReplaceWith(ttype, keep_old_material=0, force=1)
									F["[base].TURF.dir"] >> Q.dir
								else
									correct_path = 0
									boutput(user, "<span class='alert'>Error: Invalid turf type [F.ExportText("[base].TURF")] in [base].TURF</span>")
							else
								F["[base].TURF.type"] >> ttype
								if (ispath(ttype))
									Q = locate(cx, cy, cz)
									Q.ReplaceWith(ttype, keep_old_material=0, force=1)
									Q.deserialize(F, "[base].TURF", sandbox)
								else
									correct_path = 0
									boutput(user, "<span class='alert'>Error: Invalid turf type [F.ExportText("[base].TURF.type")] in [base].TURF.type</span>")
							if (correct_path)
								F["[base].TURF.tag"] >> Q.tag
								if (!Q.dir)
									Q.set_dir(SOUTH)
								new /area/adventure(Q)
								blink(Q)
							workgroup_curr++
							if (workgroup_curr >= workgroup_size)
								workgroup_curr = 0
								sleep(0.1 SECONDS)
					for (var/cy = basey, cy < basey + h, cy++)
						var/rely = cy - basey
						for (var/cx = basex, cx < basex + w, cx++)
							var/relx = cx - basex
							var/base = "[relx].[rely]"
							var/turf/Q = locate(cx, cy, cz)
							var/objc
							F["[base].OBJC"] >> objc
							for (var/objid = 0, objid < objc, objid++)
								var/objt
								var/obj/O
								F["[base].OBJ.[objid].type"] >> objt
								if (ispath(objt))
									O = new objt(Q)
									O.flags |= ISADVENTURE
									var/result = O:deserialize(F, "[base].OBJ.[objid]", sandbox)
									if (!istype(O, /obj/critter))
										if (result & DESERIALIZE_NEED_POSTPROCESS)
											PP += O
								else
									boutput(user, "<span class='alert'>Error: Invalid object type [F.ExportText("[base].OBJ.[objid].type")] in [base].OBJ.[objid].type</span>")
							blink(Q)
							workgroup_curr++
							if (workgroup_curr >= workgroup_size)
								workgroup_curr = 0
								sleep(0.1 SECONDS)
					for (var/obj/O in PP)
						O:deserialize_postprocess()
					if (this)
						this.pasting = 0
					if (user?.client)
						boutput(user, "<span class='notice'>Pasting finished. Fixing lights.</span>")
						if (fexists("ADV_LOAD_[user.client.ckey]"))
							fdel("ADV_LOAD_[user.client.ckey]")
					message_admins("Adventure/loader: loading initiated by [paster] is finalizing.")
					del F

					//Post-processing loop
					for (var/turf/R in block(locate(basex, basey, cz), locate(basex + w - 1, basey + h - 1, cz)))
						R.RL_Reset()
						R.tag = null
						blink(R)
						for (var/atom/A in R.contents)
							A.tag = null
						workgroup_curr++
						if (workgroup_curr >= workgroup_size)
							workgroup_curr = 0
							sleep(0.1 SECONDS)
					message_admins("Adventure/loader: loading initiated by [paster] is complete.")

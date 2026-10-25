
// STARTER ABILITIES

/datum/blob_ability/plant_nucleus
	name = "Deploy"
	icon_state = "blob-spawn"
	desc = "This will place the first blob on your current tile. You can only do this once. Once placed, a small amount of blob tiles will spawn around it."
	targeted = 0
	cooldown_time = 10

	/// check whether turf is acceptable to deploy on
	proc/checkValidity(var/turf/T)
		if (!T)
			T = get_turf(owner)

		if (istype(T,/turf/space/))
			boutput(owner, SPAN_ALERT("You can't start in space!"))
			return FALSE

		if (!(isadmin(owner) || owner.admin_override)) //admins can spawn wherever. So can AI blobs if we tell them to.
			if (!istype(T.loc, /area/station/) && !istype(T.loc, /area/tutorial/blob/))
				boutput(owner, SPAN_ALERT("You need to start on the [station_or_ship()]!"))
				return FALSE

			if(IS_ARRIVALS(T.loc))
				boutput(owner, SPAN_ALERT("You can't start inside arrivals!"))
				return FALSE

			if (istype(T,/turf/unsimulated/))
				boutput(owner, SPAN_ALERT("This kind of tile cannot support a blob."))
				return FALSE

			if (T.density)
				boutput(owner, SPAN_ALERT("You can't start inside a wall!"))
				return FALSE

			for (var/atom/O in T.contents)
				if (O.density)
					boutput(owner, SPAN_ALERT("That tile is blocked by [O]."))
					return FALSE

			for (var/mob/M in viewers(T, 7))
				if (isrobot(M) || ishuman(M))
					if (!isdead(M))
						boutput(owner, SPAN_ALERT("You are being watched."))
						return FALSE

		return TRUE

	onUse(var/turf/T)
		if (..())
			return

		if(!checkValidity(T))
			return

		if (owner && owner.client)
			if (tgui_alert(owner,"Would you like to deploy your nucleus?","Deploy Nucleus?",list("Yes","No")) != "Yes")
				return TRUE

		if(!checkValidity(T))
			return

		if(!T)
			T = get_turf(owner)
		if (!tutorial_check("deploy", T))
			return FALSE

		var/turf/startTurf = get_turf(owner)
		var/obj/blob/nucleus/C = new /obj/blob/nucleus(startTurf)
		logTheThing(LOG_GAMEMODE, owner, "plants their start nucleus at [log_loc(startTurf)].")
		GHOST.MESSAGE.send("<b>A Blob</b> has just deployed at [GHOST.MESSAGE.format_loc(startTurf)].")
		C.layer++
		owner.total_placed++
		C.setOvermind(owner)
		C.Life()
		owner.started = 1
		owner.add_ability(/datum/blob_ability/spread)
		owner.add_ability(/datum/blob_ability/attack)
		owner.add_ability(/datum/blob_ability/consume)
		owner.add_ability(/datum/blob_ability/repair)
		owner.add_ability(/datum/blob_ability/absorb)
		owner.add_ability(/datum/blob_ability/promote)
		owner.add_ability(/datum/blob_ability/build/ribosome)
		owner.add_ability(/datum/blob_ability/build/lipid)
		owner.add_ability(/datum/blob_ability/build/mitochondria)
		owner.add_ability(/datum/blob_ability/build/wall)
		owner.add_ability(/datum/blob_ability/build/firewall)
		owner.add_ability(/datum/blob_ability/upgrade)
		for (var/X in childrentypesof(/datum/blob_upgrade))
			owner.add_upgrade(X, 1)

		if (!owner.tutorial)
			//do a little "blobsplosion"
			var/amount = rand(20, 30)
			src.auto_spread(startTurf, maxRange = 3, maxTurfs = amount)
		owner.playsound_local(owner.loc, 'sound/voice/blob/blobdeploy.ogg', 50, 1)
		owner.remove_ability(/datum/blob_ability/set_color)
		owner.remove_ability(/datum/blob_ability/tutorial)
		owner.remove_ability(/datum/blob_ability/plant_nucleus)

/datum/blob_ability/set_color
	name = "Set Color"
	desc = "Choose what color you want your blob to be. This will be removed when you start the blob."
	icon_state = "blob-color"
	targeted = 0

	onUse()
		if (..())
			return
		owner.color = input("Select your Color","Blob") as color
		owner.organ_color = owner.color
		owner.my_material.match_to_blob(owner)

/datum/blob_ability/tutorial
	name = "Interactive Tutorial"
	desc = "Check out the interactive blob tutorial to get started with blobs."
	icon_state = "blob-tutorial"
	targeted = 0

	onUse()
		if (..())
			return
		if (owner.tutorial)
			boutput(owner, SPAN_ALERT("You're already in the tutorial!"))
			return
		owner.start_tutorial()

/datum/blob_ability/tutorial_exit
	name = "Exit Tutorial"
	desc = "Exit the blob tutorial and re-enter the game."
	icon_state = "blob-exit"
	targeted = 0
	special_screen_loc = "SOUTH,EAST-1"

	onUse()
		if (..())
			return
		if (!owner.tutorial)
			boutput(owner, SPAN_ALERT("You're not in the tutorial!"))
			return
		owner.tutorial.Finish()
		owner.tutorial = null

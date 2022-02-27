

client/proc/show_admin_lag_hacks()
	set name = "Lag Reduction"
	set desc = "A few janky commands that can smooth the game during an Emergency."
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	ADMIN_ONLY
	src.holder.show_laghacks(src.mob)

/datum/admins/proc/show_laghacks(mob/user)


	var/HTML = {"
	<html><head><title>Admin Lag Reductions</title></head><body>
	<b><a href='?src=\ref[src];action=lightweight_doors'>Remove Light+Cam processing when doors open or close</a></b> (May jank up lights slightly)<br><br>
	<b><a href='?src=\ref[src];action=lightweight_mobs'>Slow Life() Processing</a></b> (Extremely safe - Life() compensates for the change automatically)<br><br>
	<b><a href='?src=\ref[src];action=slow_atmos'>Slow atmos processing</a></b> (May jank up the TEG/Hellburns)<br><br>
	<b><a href='?src=\ref[src];action=slow_fluids'>Slow fluid processing</a></b> (Safe, just feels weird)<br><br>
	<b><a href='?src=\ref[src];action=special_sea_fullbright'>Stop Sea Light processing on Z1</a></b> (Safe, makes the Z1 ocean a little ugly)<br><br>
	<b><a href='?src=\ref[src];action=slow_ticklag'>Adjust ticklag bounds</a></b> (Manually adjust ticklag dilation upper and lower bounds! Compensate for lag, or go super smooth at lowpop!)<br><br>
	<b><a href='?src=\ref[src];action=disable_deletions'>Disable Deletion Queue</a></b> (Garbage Collection will still run, but this stops hard deletions from happening.)<br><br>
	<b><a href='?src=\ref[src];action=disable_ingame_logs'>Disable Ingame Logs</a></b> (Reduce the shitty logthething() lag! Make the admins angry! You can still access logs fine using the web version etc)
	</body></html>
	"}
	user.Browse(HTML,"window=alaghacks;size=400x390")


//fluid_commands.dm
//client/proc/special_fullbright()


client/proc/lightweight_doors()
	set name = "Force Doors Ignore Cameras and Lighting"
	set desc = "Helps when server load is heavy. Creates really ugly dark spots, try not to use this often."
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set hidden = 1
	ADMIN_ONLY

	message_admins("[key_name(src)] is removing light/camera interactions from doors...")
	SPAWN(0)
		for(var/obj/machinery/door/D in by_type[/obj/machinery/door])
			D.ignore_light_or_cam_opacity = 1
			LAGCHECK(LAG_REALTIME)
		message_admins("[key_name(src)] removed light/camera interactions from doors with Lag Reduction panel.")


client/proc/lightweight_mobs()
	set name = "Override Life() tick spacing"
	set desc = "Reduces (or increases if you're feeling spicy) load of Life(). Extremely safe - Life() compensates for the change automatically :)"
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set hidden = 1
	ADMIN_ONLY

	if (processScheduler.hasProcess("Mob"))
		var/datum/controller/process/mobs/M = processScheduler.nameToProcessMap["Mob"]
		if(isnum_safe(M.schedule_override))
			M.schedule_override = null
			M.nextpopcheck = 0 //force recheck
			message_admins("[key_name(src)] un-overrode Mob process interval with Lag Reduction panel.")
		else
			M.schedule_override = clamp((input("Enter life tick duration (2s to 10s):","Num", M.schedule_interval/10) as num) * 10, 20, 100)
			M.schedule_interval = M.schedule_override
			message_admins("[key_name(src)] overrode Mob process interval (to [M.schedule_override]) with Lag Reduction panel.")


client/proc/slow_fluids()
	set name = "Slow Fluid Processing"
	set desc = "Higher schedulde interval."
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set hidden = 1
	ADMIN_ONLY

	if (processScheduler.hasProcess("Fluid_Groups"))
		var/datum/controller/process/fluid_group/P = processScheduler.nameToProcessMap["Fluid_Groups"]
		P.max_schedule_interval = 90

	if (processScheduler.hasProcess("Fluid_Turfs"))
		var/datum/controller/process/P = processScheduler.nameToProcessMap["Fluid_Turfs"]
		P.schedule_interval = 100

	message_admins("[key_name(src)] slowed the schedule interval of Fluids with Lag Reduction panel.")

client/proc/slow_atmos()
	set name = "Slow Atmos Processing"
	set desc = "Higher schedulde interval. May fuck the TEG."
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set hidden = 1
	ADMIN_ONLY

	if (processScheduler.hasProcess("Atmos"))
		var/datum/controller/process/P = processScheduler.nameToProcessMap["Atmos"]
#ifdef UNDERWATER_MAP
		P.schedule_interval = 120
#else
		P.schedule_interval = 50
#endif

	message_admins("[key_name(src)] slowed the schedule interval of Atmos with Lag Reduction panel.")

client/proc/slow_ticklag()
	set name = "Change Ticklag Bounds"
	set desc = "Change max/min ticklag bounds for smoother experience during super-highpop or especially bad rounds. Lower = smooth, Higher = For lag"
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set hidden = 1
	ADMIN_ONLY

	//var/prev = world.tick_lag
	//world.tick_lag = OVERLOADED_WORLD_TICKLAG

	ticker.timeDilationLowerBound = input("Enter lower bound:","Num", ticker.timeDilationLowerBound) as num
	ticker.timeDilationUpperBound = input("Enter upper bound:","Num", ticker.timeDilationUpperBound) as num

	message_admins("[key_name(src)] changed world Tick Lag bounds to MIN:[ticker.timeDilationLowerBound]  MAX:[ticker.timeDilationUpperBound]  with Lag Reduction panel.")

client/proc/disable_deletions()
	set name = "Disable Deletion Queue"
	set desc = "Disable delete queue (only GC'd items will truly be gone when deleted)"
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set hidden = 1
	ADMIN_ONLY

	if (processScheduler.hasProcess("DeleteQueue"))
		var/datum/controller/process/P = processScheduler.nameToProcessMap["DeleteQueue"]
		P.disable()

	message_admins("[key_name(src)] disabled delete queue with Lag Reduction panel!")


client/proc/disable_ingame_logs()
	set name = "Disable Ingame Logs"
	set desc = "Reduce the shitty logthething() lag! Make the admins angry! (You can still access logs fine using the web version etc)"
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set hidden = 1
	ADMIN_ONLY

	if (disable_log_lists)
		disable_log_lists = 0
		message_admins("[key_name(src)] un-disabled ingame logs with Lag Producing panel!")
	else
		disable_log_lists = 1
		message_admins("[key_name(src)] disabled ingame logs with Lag Reduction panel!")



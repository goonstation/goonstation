/obj/item/artifact/forcewall_wand
	name = "artifact forcewall wand"
	icon = 'icons/obj/artifacts/artifactsitem.dmi'
	artifact = 1
	associated_datum = /datum/artifact/wallwand

	afterattack(atom/target, mob/user , flag)
		if (!src.ArtifactSanityCheck())
			return
		var/datum/artifact/A = src.artifact
		if (A.activated && target.loc != user)
			user.lastattacked = src
			var/turf/T = get_turf(target)
			A.effect_click_tile(src,user,T)
			src.ArtifactFaultUsed(user)

/datum/artifact/wallwand
	associated_object = /obj/item/artifact/forcewall_wand
	type_name = "Forcefield Wand"
	type_size = ARTIFACT_SIZE_MEDIUM
	rarity_weight = 350
	validtypes = list("ancient","wizard","eldritch","precursor")
	react_xray = list(10,60,92,11,"COMPLEX")
	var/wall_duration = 5
	var/wall_size = 1
	var/icon_state = "shieldsparkles"
	var/sound/wand_sound = 'sound/effects/mag_forcewall.ogg'
	examine_hint = "It seems to have a handle you're supposed to hold it by."

	New()
		..()
		src.wall_duration = rand(3,30)
		src.wall_size = rand(1,4)
		if(prob(10))
			src.wall_size += rand(3,6)
		if(prob(5))
			src.wall_duration *= rand(2,5)
		src.icon_state = pick("shieldsparkles","empdisable","greenglow","enshield","energyorb","forcewall","meteor_shield")
		src.wand_sound = pick('sound/effects/mag_forcewall.ogg','sound/effects/mag_golem.ogg','sound/effects/mag_iceburstlaunch.ogg','sound/effects/bamf.ogg','sound/weapons/ACgun2.ogg')

	effect_click_tile(var/obj/O,var/mob/living/user,var/turf/T)
		if (..())
			return
		if (!T)
			return
		var/wallloc
		playsound(user.loc, wand_sound, 50, 1, -1)
		if (user.dir == NORTH || user.dir == SOUTH)
			for(wallloc = T.x - (src.wall_size - 1),wallloc < T.x + src.wall_size,wallloc++)
				var/obj/forcefield/wand/FW = new /obj/forcefield/wand(locate(wallloc,T.y,T.z),src.wall_duration,src.icon_state)
				FW.icon_state = src.icon_state
		else
			for(wallloc = T.y - (src.wall_size - 1),wallloc < T.y + src.wall_size,wallloc++)
				var/obj/forcefield/wand/FW = new /obj/forcefield/wand(locate(T.x,wallloc,T.z),src.wall_duration,src.icon_state)
				FW.icon_state = src.icon_state

/obj/forcefield/wand
	name = "force field"
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldsparkles"
	desc = "Some kind of strange energy barrier. You can't get past it."
	var/obj/artifact/forcefield_generator/source = null

	New(var/loc,var/duration,var/wallsprite,var/obj/artifact/forcefield_generator/S = null)
		..()
		icon_state = wallsprite
		source = S
		if (duration > 0)
			SPAWN(duration * 10)
				qdel(src)

	Bumped(AM)
		. = ..()
		if(source && ismob(AM))
			source.ArtifactFaultUsed(AM, src)

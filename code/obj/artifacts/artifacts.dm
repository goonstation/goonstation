/obj/artifact
	// a totally inert piece of shit that does nothing (alien art)
	// might as well use it as the category header for non-machinery artifacts just to be efficient
	name = "artifact large art piece"
	icon = 'icons/obj/artifacts/artifacts.dmi'
	icon_state = "wizard-1" // it's technically pointless to set this but it makes it easier to find in the dreammaker tree
	opacity = 0
	density = 1
	anchored = 0
	artifact = 1
	mat_changename = 0
	mat_changedesc = 0
	var/associated_datum = /datum/artifact/art

	New(var/loc, var/forceartiorigin)
		..()
		var/datum/artifact/AS = new src.associated_datum(src)
		if (forceartiorigin) AS.validtypes = list("[forceartiorigin]")
		src.artifact = AS

		SPAWN_DBG(0)
			src.ArtifactSetup()

	disposing()
		artifact_controls.artifacts -= src
		..()

	UpdateName()
		src.name = "[name_prefix(null, 1)][src.real_name][name_suffix(null, 1)]"

	attack_hand(mob/user as mob)
		user.lastattacked = src
		src.ArtifactTouched(user)
		return

	attack_ai(mob/user as mob)
		return attack_hand(user)

	attackby(obj/item/W as obj, mob/user as mob)
		user.lastattacked = src
		if (src.Artifact_attackby(W,user))
			..()

	meteorhit(obj/O as obj)
		src.ArtifactStimulus("force", 60)
		..()

	examine()
		. = list("You have no idea what this thing is!")
		if (!src.ArtifactSanityCheck())
			return
		var/datum/artifact/A = src.artifact
		if (istext(A.examine_hint))
			. += A.examine_hint

	ex_act(severity)
		switch(severity)
			if(1.0)
				src.ArtifactStimulus("force", 200)
				src.ArtifactStimulus("heat", 500)
			if(2.0)
				src.ArtifactStimulus("force", 75)
				src.ArtifactStimulus("heat", 450)
			if(3.0)
				src.ArtifactStimulus("force", 25)
				src.ArtifactStimulus("heat", 380)
		return

	reagent_act(reagent_id,volume)
		if (..())
			return
		src.Artifact_reagent_act(reagent_id, volume)
		return

	emp_act()
		src.Artifact_emp_act()

	blob_act(var/power)
		src.Artifact_blob_act(power)

	bullet_act(var/obj/projectile/P)
		if(src.material) src.material.triggerOnBullet(src, src, P)

		switch (P.proj_data.damage_type)
			if(D_KINETIC,D_PIERCING,D_SLASHING)
				for (var/obj/machinery/networked/test_apparatus/impact_pad/I in src.loc.contents)
					I.impactpad_senseforce_shot(src, P)
				src.ArtifactStimulus("force", P.power)
			if(D_ENERGY)
				src.ArtifactStimulus("elec", P.power * 10)
			if(D_BURNING)
				src.ArtifactStimulus("heat", 310 + (P.power * 5))
			if(D_RADIOACTIVE)
				src.ArtifactStimulus("radiate", P.power)
		..()

	hitby(atom/movable/M, datum/thrown_thing/thr)
		if (isitem(M))
			var/obj/item/ITM = M
			for (var/obj/machinery/networked/test_apparatus/impact_pad/I in src.loc.contents)
				I.impactpad_senseforce(src, ITM)
		..()

	mob_flip_inside(mob/user)
		. = ..()
		src.ArtifactTakeDamage(rand(5,20))
		boutput(user, "<span class='alert'>It seems to be a bit more damaged!</span>")

/obj/machinery/artifact
	name = "artifact large art piece"
	icon = 'icons/obj/artifacts/artifacts.dmi'
	icon_state = "wizard-1" // it's technically pointless to set this but it makes it easier to find in the dreammaker tree
	opacity = 0
	density = 1
	anchored = 0
	artifact = 1
	mat_changename = 0
	mat_changedesc = 0
	var/associated_datum = /datum/artifact/art

	New(var/loc, var/forceartiorigin)
		..()
		var/datum/artifact/AS = new src.associated_datum(src)
		if (forceartiorigin)
			AS.validtypes = list("[forceartiorigin]")
		src.artifact = AS

		SPAWN_DBG(0)
			src.ArtifactSetup()

	disposing()
		artifact_controls.artifacts -= src
		..()

	examine()
		. = list("You have no idea what this thing is!")
		if (!src.ArtifactSanityCheck())
			return
		var/datum/artifact/A = src.artifact
		if (istext(A.examine_hint))
			. += A.examine_hint

	UpdateName()
		src.name = "[name_prefix(null, 1)][src.real_name][name_suffix(null, 1)]"

	process()
		..()
		if (!src.ArtifactSanityCheck())
			return
		var/datum/artifact/A = src.artifact

		if (A.activated)
			A.effect_process(src)

	attack_hand(mob/user as mob)
		src.ArtifactTouched(user)
		return

	attack_ai(mob/user as mob)
		return attack_hand(user)

	attackby(obj/item/W as obj, mob/user as mob)
		if (src.Artifact_attackby(W,user))
			..()

	meteorhit(obj/O as obj)
		src.ArtifactStimulus("force", 60)
		..()

	ex_act(severity)
		switch(severity)
			if(1.0)
				src.ArtifactStimulus("force", 200)
				src.ArtifactStimulus("heat", 500)
			if(2.0)
				src.ArtifactStimulus("force", 75)
				src.ArtifactStimulus("heat", 450)
			if(3.0)
				src.ArtifactStimulus("force", 25)
				src.ArtifactStimulus("heat", 380)
		return

	reagent_act(reagent_id,volume)
		if (..())
			return
		src.Artifact_reagent_act(reagent_id, volume)
		return

	emp_act()
		src.Artifact_emp_act()

	blob_act(var/power)
		src.Artifact_blob_act(power)

	bullet_act(var/obj/projectile/P)
		switch (P.proj_data.damage_type)
			if(D_KINETIC,D_PIERCING,D_SLASHING)
				src.ArtifactStimulus("force", P.power)
				if (istype(src.loc,/turf/))
					for (var/obj/machinery/networked/test_apparatus/impact_pad/I in src.loc.contents)
						I.impactpad_senseforce_shot(src, P)
			if(D_ENERGY)
				src.ArtifactStimulus("elec", P.power * 10)
			if(D_BURNING)
				src.ArtifactStimulus("heat", 310 + (P.power * 5))
			if(D_RADIOACTIVE)
				src.ArtifactStimulus("radiate", P.power)
		..()

	hitby(atom/movable/M, datum/thrown_thing/thr)
		if (isitem(M))
			var/obj/item/ITM = M
			for (var/obj/machinery/networked/test_apparatus/impact_pad/I in src.loc.contents)
				I.impactpad_senseforce(src, ITM)
		..()

/obj/item/artifact
	name = "artifact small art piece"
	icon = 'icons/obj/artifacts/artifactsitem.dmi'
	icon_state = "wizard-1"
	artifact = 1
	mat_changename = 0
	mat_changedesc = 0
	var/associated_datum = /datum/artifact/art

	New(var/loc, var/forceartiorigin)
		..()
		var/datum/artifact/AS = new src.associated_datum(src)
		if (forceartiorigin)
			AS.validtypes = list("[forceartiorigin]")
		src.artifact = AS

		SPAWN_DBG(0)
			src.ArtifactSetup()

	disposing()
		artifact_controls.artifacts -= src
		..()

	examine()
		. = list("You have no idea what this thing is!")
		if (!src.ArtifactSanityCheck())
			return
		var/datum/artifact/A = src.artifact
		if (istext(A.examine_hint))
			. += A.examine_hint

	UpdateName()
		src.name = "[name_prefix(null, 1)][src.real_name][name_suffix(null, 1)]"

	attackby(obj/item/W as obj, mob/user as mob)
		if (src.Artifact_attackby(W,user))
			..()

//ex_act is handled by the item parent

	emp_act()
		src.Artifact_emp_act()

	reagent_act(reagent_id,volume)
		if (..())
			return
		src.Artifact_reagent_act(reagent_id, volume)
		return

	hitby(atom/movable/M, datum/thrown_thing/thr)
		if (isitem(M))
			var/obj/item/ITM = M
			for (var/obj/machinery/networked/test_apparatus/impact_pad/I in src.loc.contents)
				I.impactpad_senseforce(src, ITM)
		..()

/obj/artifact_spawner
	// pretty much entirely for debugging/gimmick use
	New(var/loc,var/forceartiorigin = null,var/cinematic = 0)
		..()
		var/turf/T = get_turf(src)
		if (cinematic)
			T.visible_message("<span class='alert'><b>An artifact suddenly warps into existence!</b></span>")
			playsound(T,"sound/effects/teleport.ogg",50,1)
			var/obj/decal/teleport_swirl/swirl = unpool(/obj/decal/teleport_swirl)
			swirl.set_loc(T)
			SPAWN_DBG(1.5 SECONDS)
				pool(swirl)
		Artifact_Spawn(T,forceartiorigin)
		qdel(src)
		return

/obj/artifact_type_spawner
	var/list/types = list()

	New(var/loc)
		..()
		Artifact_Spawn(src.loc, forceartitype = pick(src.types))
		qdel(src)
		return

/obj/artifact_type_spawner/vurdalak

	New(var/loc)
		src.types = concrete_typesof(/datum/artifact)
		..()

// I removed mining artifacts from this list because they are kinda not in the game right now
/obj/artifact_type_spawner/gragg
	types = list(
		/datum/artifact/activator_key,
		/datum/artifact/wallwand,
		/datum/artifact/melee,
		/datum/artifact/telewand,
		/datum/artifact/energygun,
		/datum/artifact/watercan,
		/datum/artifact/pitcher
		)

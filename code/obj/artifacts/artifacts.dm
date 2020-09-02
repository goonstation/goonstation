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

	New(var/loc, var/forceartitype)
		..()
		var/datum/artifact/AS = new src.associated_datum(src)
		if (forceartitype) AS.validtypes = list("[forceartitype]")
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
		if (!src.ArtifactSanityCheck())
			return
		var/datum/artifact/A = src.artifact
		src.ArtifactStimulus(reagent_id, volume)
		switch(reagent_id)
			if("radium","porktonium")
				src.ArtifactStimulus("radiate", round(volume / 10))
			if("polonium","strange_reagent")
				src.ArtifactStimulus("radiate", round(volume / 5))
			if("uranium")
				src.ArtifactStimulus("radiate", round(volume / 2))
			if("dna_mutagen","mutagen","omega_mutagen")
				if (A.artitype.name == "martian")
					ArtifactDevelopFault(80)
			if("phlogiston","dbreath","el_diablo","thermite","thalmerite","argine")
				src.ArtifactStimulus("heat", 310 + (volume * 5))
			if("infernite","kerosene","ghostchilijuice")
				src.ArtifactStimulus("heat", 310 + (volume * 10))
			if("napalm_goo","foof","ghostchilijuice")
				src.ArtifactStimulus("heat", 310 + (volume * 15))
			if("cryostylane")
				src.ArtifactStimulus("heat", 310 - (volume * 10))
			if("acid","acetic_acid")
				src.ArtifactTakeDamage(volume * 2)
			if("pacid","clacid","nitric_acid")
				src.ArtifactTakeDamage(volume * 10)
			if("george_melonium")
				var/random_stimulus = pick("heat","force","radiate","elec")
				var/random_strength = 0
				switch(random_stimulus)
					if ("heat")
						random_strength = rand(200,400)
					if ("elec")
						random_strength = rand(5,5000)
					if ("force")
						random_strength = rand(3,30)
					if ("radiate")
						random_strength = rand(1,10)
				src.ArtifactStimulus(random_stimulus,random_strength)
		return

	emp_act()
		src.ArtifactStimulus("elec", 800)
		src.ArtifactStimulus("radiate", 3)

	blob_act(var/power)
		src.ArtifactStimulus("force", power)
		src.ArtifactStimulus("carbtouch", 1)

	bullet_act(var/obj/projectile/P)
		if(src.material) src.material.triggerOnBullet(src, src, P)

		switch (P.proj_data.damage_type)
			if(D_KINETIC,D_PIERCING,D_SLASHING)
				src.ArtifactStimulus("force", P.power)
				for (var/obj/machinery/networked/test_apparatus/impact_pad/I in src.loc.contents)
					I.impactpad_senseforce_shot(src, P)
			if(D_ENERGY)
				src.ArtifactStimulus("elec", P.power * 10)
			if(D_BURNING)
				src.ArtifactStimulus("heat", 310 + (P.power * 5))
			if(D_RADIOACTIVE)
				src.ArtifactStimulus("radiate", P.power)
		..()

	hitby(M as mob|obj)
		if (isitem(M))
			var/obj/item/ITM = M
			src.ArtifactStimulus("force", ITM.throwforce)
			for (var/obj/machinery/networked/test_apparatus/impact_pad/I in src.loc.contents)
				I.impactpad_senseforce(src, ITM)
		..()

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

	New(var/loc, var/forceartitype)
		..()
		var/datum/artifact/AS = new src.associated_datum(src)
		if (forceartitype)
			AS.validtypes = list("[forceartitype]")
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
		if (!src.ArtifactSanityCheck())
			return
		var/datum/artifact/A = src.artifact
		src.ArtifactStimulus(reagent_id, volume)
		switch(reagent_id)
			if("radium","porktonium")
				src.ArtifactStimulus("radiate", round(volume / 10))
			if("polonium","strange_reagent")
				src.ArtifactStimulus("radiate", round(volume / 5))
			if("uranium")
				src.ArtifactStimulus("radiate", round(volume / 2))
			if("dna_mutagen","mutagen","omega_mutagen")
				if (A.artitype.name == "martian")
					ArtifactDevelopFault(80)
			if("phlogiston","dbreath","el_diablo")
				src.ArtifactStimulus("heat", 310 + (volume * 5))
			if("infernite","foof","ghostchilijuice")
				src.ArtifactStimulus("heat", 310 + (volume * 10))
			if("cryostylane")
				src.ArtifactStimulus("heat", 310 - (volume * 10))
			if("acid")
				src.ArtifactTakeDamage(volume * 2)
			if("pacid")
				src.ArtifactTakeDamage(volume * 10)
			if("george_melonium")
				var/random_stimulus = pick("heat","force","radiate","elec")
				var/random_strength = 0
				switch(random_stimulus)
					if ("heat")
						random_strength = rand(200,400)
					if ("elec")
						random_strength = rand(5,5000)
					if ("force")
						random_strength = rand(3,30)
					if ("radiate")
						random_strength = rand(1,10)
				src.ArtifactStimulus(random_stimulus,random_strength)
		return

	emp_act()
		src.ArtifactStimulus("elec", 800)
		src.ArtifactStimulus("radiate", 3)

	blob_act(var/power)
		src.ArtifactStimulus("force", power)
		src.ArtifactStimulus("carbtouch", 1)

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
				src.ArtifactStimulus("heat", P.power * 5)
			if(D_RADIOACTIVE)
				src.ArtifactStimulus("radiate", P.power)
		..()

	hitby(M as mob|obj)
		if (isitem(M))
			var/obj/item/ITM = M
			src.ArtifactStimulus("force", ITM.throwforce)
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

	New(var/loc, var/forceartitype)
		var/datum/artifact/AS = new src.associated_datum(src)
		if (forceartitype)
			AS.validtypes = list("[forceartitype]")
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

	hitby(M as mob|obj)
		if (isitem(M))
			var/obj/item/ITM = M
			src.ArtifactStimulus("force", ITM.throwforce)
			for (var/obj/machinery/networked/test_apparatus/impact_pad/I in src.loc.contents)
				I.impactpad_senseforce(src, ITM)
		..()

/obj/artifact_spawner
	// pretty much entirely for debugging/gimmick use
	New(var/loc,var/forceartitype = null,var/cinematic = 0)
		var/turf/T = get_turf(src)
		if (cinematic)
			T.visible_message("<span class='alert'><b>An artifact suddenly warps into existence!</b></span>")
			playsound(T,"sound/effects/teleport.ogg",50,1)
			var/obj/decal/teleport_swirl/swirl = unpool(/obj/decal/teleport_swirl)
			swirl.set_loc(T)
			SPAWN_DBG(1.5 SECONDS)
				pool(swirl)
		Artifact_Spawn(T,forceartitype)
		qdel(src)
		return

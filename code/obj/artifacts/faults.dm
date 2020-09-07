// FAULTS

/datum/artifact_fault
	// these are booby traps, self-defense mechanisms, hardware faults or just other nasty shit that can fuck you up when you
	// use the artifact for anything
	var/trigger_prob = 0
	var/tmp/datum/artifact/holder = null
	var/halt_loop = 0

	proc/deploy(var/obj/O,var/mob/living/user)
		if (!O || !user)
			return 1
		return 0

/datum/artifact_fault/burn
	// sets the victim on fire
	trigger_prob = 8
	var/burn_amount = 40

	deploy(var/obj/O,var/mob/living/user)
		if (..())
			return
		var/turf/T = get_turf(user)
		T.visible_message("<span class='alert'>The [O.name] suddenly bursts into flames!</span>")
		user.update_burning(40)
		playsound(T, "sound/effects/bamf.ogg", 100, 1)

/datum/artifact_fault/irradiate
	// irradiates the victim
	trigger_prob = 8
	var/rads_amount = 20

	deploy(var/obj/O,var/mob/living/user)
		if (..())
			return
		boutput(user, "<span class='alert'>You feel strange.</span>")
		user.changeStatus("radiation", (src.rads_amount)*10, 3)

/datum/artifact_fault/shutdown
	// deactivates the artifact
	trigger_prob = 10
	halt_loop = 1

	deploy(var/obj/O,var/mob/living/user)
		if (..())
			return
		var/turf/T = get_turf(O)
		T.visible_message("<span class='alert'>The [O.name] suddenly deactivates!</span>")
		playsound(T, "sound/effects/shielddown2.ogg", 100, 1)
		O.ArtifactDeactivated()

/datum/artifact_fault/warp
	// warps the user off somewhere random
	trigger_prob = 15

	deploy(var/obj/O,var/mob/living/user)
		if (..())
			return
		var/turf/T = get_turf(O)
		T.visible_message("<span class='alert'>The [O.name] warps [user.name] away!</span>")
		playsound(T, "sound/effects/mag_warp.ogg", 100, 1)
		user.set_loc(pick(wormholeturfs))

/datum/artifact_fault/murder
	// gibs the user
	trigger_prob = 1
	halt_loop = 1

	deploy(var/obj/O,var/mob/living/user)
		if (..())
			return
		if (isitem(src))
			var/obj/item/I = src
			if (I.loc == user)
				user.u_equip(I)
				I.dropped()
		var/turf/T = get_turf(O)
		T.visible_message("<span class='alert'><b>The [O.name] utterly annihilates [user.name]!</b></span>")
		playsound(T, "sound/effects/elec_bigzap.ogg", 100, 1)
		user.elecgib()

/datum/artifact_fault/explode
	// causes an explosion and destroys the artifact
	trigger_prob = 1
	halt_loop = 1

	deploy(var/obj/O,var/mob/living/user)
		if (..())
			return
		var/turf/T = get_turf(O)
		T.visible_message("<span class='alert'>The [O.name] suddenly explodes!</span>")
		if (isitem(src))
			var/obj/item/I = src
			user.u_equip(I)
			I.dropped()
		explosion(O, T, 1, 2, 4, 8)
		O.ArtifactDestroyed()

/datum/artifact_fault/zap
	// electrocutes the user
	trigger_prob = 6

	deploy(var/obj/O,var/mob/living/user)
		if (..())
			return
		var/turf/T = get_turf(O)
		T.visible_message("<span class='alert'><b>[user.name]</b> is shocked by a surge of energy from [O.name]!</span>")
		var/datum/effects/system/spark_spread/s = unpool(/datum/effects/system/spark_spread)
		s.set_up(4, 1, user)
		s.start()
		elecflash(user,power = 6, exclude_center = 0)
		user.stuttering += 30

/datum/artifact_fault/messager
	trigger_prob = 30
	var/text_style = null
	var/list/messages = list()

	deploy(var/obj/O,var/mob/living/user)
		if (..())
			return
		if (messages.len < 1)
			return
		switch(text_style)
			if ("small")
				boutput(user, "<small>[pick(messages)]</small>")
			if ("big")
				boutput(user, "<big>[pick(messages)]</big>")
			if ("red")
				boutput(user, "<span class='alert'>[pick(messages)]</span>")
			if ("blue")
				boutput(user, "<span class='notice'>[pick(messages)]</span>")
			else
				boutput(user, "[pick(messages)]")

/datum/artifact_fault/messager/creepy_whispers
	text_style = "small"
	messages = list("its your fault","theyre going to get you","no escape","youre going to die here","no hope",
	"die","stop","give up","no","theyre watching you","theres nothing you can do","you have failed","run","i see you",
	"surrender","its hopeless","you are in hell","its all lies","hate","there is only despair","your heart will stop",
	"they will all forget you","they have abandoned you","please stop","no one will mourn you")

/datum/artifact_fault/poison
	trigger_prob = 8
	var/poison_type = "toxin"
	var/poison_amount = 10

	deploy(var/obj/O,var/mob/living/user)
		if (..())
			return
		boutput(user, "<span class='alert'>The [O.name] stings you!</span>")
		if (user.reagents)
			user.reagents.add_reagent(poison_type,poison_amount)

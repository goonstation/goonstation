/*/obj/artifact/curser
	name = "artifact curser"
	associated_datum = /datum/artifact/curser

	New(var/loc, var/forceartiorigin)
		..()

	ArtifactActivated(var/mob/living/user as mob)
		var/datum/artifact/A = src.artifact
		if (A.activated)
			return
		A.activated = 1
		playsound(src.loc, A.activ_sound, 100, 1)
		src.overlays += A.fx_image
		src.visible_message("<b>[src] seems like it has something inside it...</b>") //Left on purpose, I want to make people thing its the container artifact.

/datum/artifact/curser
	associated_object = /obj/artifact/curser
	type_name = "Curser"
	rarity_weight = 0
	validtypes = list("eldritch")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,
	/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch,/datum/artifact_trigger/silicon_touch)
	activ_text = "deposits its contents on the ground."
	deact_text = "ceases functioning."
	react_xray = list(7,50,40,11,"HOLLOW")

	New()
		..()
		src.react_heat[2] = "HIGH INTERNAL CONVECTION"

	effect_touch(var/obj/O,var/mob/living/user)
		var/range = rand(90,160)
		if (..())
			return
		for(var/mob/N in viewers(O, null))
			N.flash(3 SECONDS)
			if(N.client)
				shake_camera(N, 6, 4)
				O.visible_message("<span class='alert'><b>With a blinding light [O] vanishes, releasing the curse that was locked inside it.</b></span>")
		if (range > 0)
			var/turf/T = get_turf(O)
			for (var/mob/living/carbon/human/M in range(range,T))
				if (M == user)
					continue
				playsound(M, 'sound/effects/blood.ogg', 80, 1)
				boutput(M, "<span class='alert'>You have been cursed by an eldritch artifact!</span>")
				M.changeStatus("bloodcurse",(rand(900,2000)))
				artifact_controls.artifacts -= src
				qdel(O)*/

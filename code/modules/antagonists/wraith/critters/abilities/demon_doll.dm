/datum/targetable/critter/demon_doll
	name = "???"
	desc = "You shouldn't be seeing this."
	var/border_icon = 'icons/mob/wraith_ui.dmi'
	var/border_state = "trickster_frame"

	onAttach(datum/abilityHolder/holder)
		..()

		var/atom/movable/screen/ability/topBar/B = src.object
		B.UpdateOverlays(image(border_icon, border_state), "mob_type")

/datum/targetable/critter/demon_doll/devious_song
	name = "Devious Song"
	desc = "Mutter a magical chant that places a random rune trap below you"
	icon_state = "song_devious"
	cooldown = 40 SECONDS
	targeted = 0
	var/max_traps = 3
	var/traps_laid = 0
	var/list/trap_types = list(
		"Madness",
		"Burning",
		"Teleporting",
		"Illusions",
		"EMP",
		"Blinding",
		"Sleepyness",
		"Slipperiness"
	)

	cast()
		if (..())
			return CAST_ATTEMPT_FAIL_CAST_FAILURE

		var/area/A = get_area(src.holder.owner)
		var/turf/T = get_turf(src.holder.owner)
		if (isrestrictedz(src.holder.owner.z) || A.sanctuary || !isturf(T) || !istype(T, /turf/simulated/floor))
			boutput(src.holder.owner, SPAN_ALERT("A strange force prevents you from doing that!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		for (var/obj/machinery/wraith/runetrap/R in range(T, 3))
			boutput(src.holder.owner, SPAN_ALERT("That is too close to another trap to the [dir2text(get_dir(R, src.holder.owner))]."))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		if (src.traps_laid >= src.max_traps)
			boutput(src.holder.owner, SPAN_ALERT("You already have too many traps!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN

		var/chosen_trap = pick(src.trap_types)
		switch(chosen_trap)
			if("Madness")
				chosen_trap = /obj/machinery/wraith/runetrap/madness
			if("Burning")
				chosen_trap = /obj/machinery/wraith/runetrap/fire
			if("Teleporting")
				chosen_trap = /obj/machinery/wraith/runetrap/teleport
			if("Illusions")
				chosen_trap = /obj/machinery/wraith/runetrap/terror
			if("EMP")
				chosen_trap = /obj/machinery/wraith/runetrap/emp
			if("Blinding")
				chosen_trap = /obj/machinery/wraith/runetrap/stunning
			if("Sleepyness")
				chosen_trap = /obj/machinery/wraith/runetrap/sleepyness
			if("Slipperiness")
				chosen_trap = /obj/machinery/wraith/runetrap/slipping

		new chosen_trap(T, src.holder.owner, src.holder.owner)
		src.traps_laid++

/datum/targetable/critter/demon_doll/shrieking_song
	name = "Shrieking Song"
	desc = "Let loose an anguished cry that shatters lights and disrupts victims."
	icon_state = "song_shrieking"
	cooldown = 30 SECONDS
	targeted = 0

	cast()
		if (..())
			return CAST_ATTEMPT_FAIL_CAST_FAILURE

		playsound(src.holder.owner.loc, 'sound/voice/creepyshriek.ogg', 60, 1, channel=VOLUME_CHANNEL_EMOTE)
		sonic_attack_environmental_effect(usr, 5, list("light"))
		for (var/mob/living/HH in hearers(src.holder.owner, null))
			if (HH == src.holder.owner)
				continue
			HH.apply_sonic_stun(0, 0, 30, 0, 5, 4, 6)

/datum/targetable/critter/demon_doll/fearful_song
	name = "Fearful Song"
	desc = "Fire a cursed trap tune that richochets in the dark, hitting lights will break them and give you another bounce."
	cooldown = 30 SECONDS
	targeted = 1
	target_anything = 1
	var/current_projectile

	New()
		. = ..()
		src.current_projectile = new/datum/projectile/musical_note

	cast(atom/target)
		if (..())
			return CAST_ATTEMPT_FAIL_CAST_FAILURE
		var/obj/projectile/note = shoot_projectile_ST_pixel_spread(src.holder.owner, src.current_projectile, target)
		if (!note)
			return
		src.holder.owner.visible_message(SPAN_ALERT("<b>[src.holder.owner] throws its voice!</b>"))


/datum/projectile/musical_note
	name = "musical note"
	icon_state = "note1"
	has_impact_particles = TRUE
	projectile_speed = 24
	is_magical = TRUE
	window_pass = 0
	dissipation_delay = 50
	var/max_bounces = 4
	var/broke_lamp = FALSE

	on_launch(obj/projectile/P)
		SPAWN(0 SECONDS)
			src.broke_lamp = FALSE

	on_hit(atom/hit, dirflag, obj/projectile/proj)
		if (ismob(hit))
			return
		var/turf/proj_loc = get_turf(proj)

		for (var/obj/machinery/light/fixture in view(1, proj))
			if (fixture.current_lamp.light_status == LIGHT_OK || fixture.current_lamp.light_status == LIGHT_BURNED)
				src.broke_lamp = TRUE
			fixture.broken(explode_rigged=TRUE)

		if (src.broke_lamp)
			proj.reflectcount--
		else if (proj_loc.is_lit())
			proj.reflectcount++

		if (proj.reflectcount >= src.max_bounces)
			proj.die()
		else
			shot_volume = 0
			shoot_reflected_bounce(proj, hit, src.max_bounces, PROJ_RAPID_HEADON_BOUNCE)
			shot_volume = 100

		return









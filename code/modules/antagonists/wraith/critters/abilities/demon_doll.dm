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

		var/chosen_trap = pick(concrete_typesof(/obj/machinery/wraith/runetrap/))
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

		playsound(src.holder.owner, "sound/voice/wraith/wraithspook[rand(1, 2)].ogg", 60, 1, channel=VOLUME_CHANNEL_EMOTE)
		sonic_attack_environmental_effect(usr, 5, list("light"))
		for (var/mob/living/HH in hearers(src.holder.owner, null))
			if (HH == src.holder.owner)
				continue
			HH.apply_sonic_stun(0, 0, 30, 0, 5, 4, 6)

/datum/targetable/critter/demon_doll/bouncy_song
	name = "Bouncy Song"
	desc = "Throw your voice, knocking people back after a bounce and laying a trap after two. Bounces more in the dark and when hitting lights!"
	cooldown = 1 SECONDS
	targeted = 1
	target_anything = 1
	var/muzzle_flash = "muzzle_flash_launch"
	var/current_projectile

	New()
		. = ..()
		src.current_projectile = new/datum/projectile/musical_note

	cast(atom/target)
		if (..())
			return CAST_ATTEMPT_FAIL_CAST_FAILURE
		var/obj/projectile/note = shoot_projectile_ST_pixel_spread(src.holder.owner, src.current_projectile, target)
		muzzle_flash_attack_particle(src.holder.owner, src.holder.owner.loc, target, src.muzzle_flash)
		note.special_data["owner"] = src.holder.owner
		if (!note)
			return
		src.holder.owner.visible_message(SPAN_ALERT("<b>[src.holder.owner] throws its voice!</b>"))


/datum/projectile/musical_note
	name = "musical note"
	icon_state = "note1"
	has_impact_particles = TRUE
	energy_particles_override = TRUE
	projectile_speed = 24
	is_magical = TRUE
	window_pass = 0
	dissipation_delay = 50
	damage = 10
	stun = 12
	damage_type = D_ENERGY
	shot_sound = null
	var/max_bounces = 4
	var/broke_lamp = FALSE

	on_launch(obj/projectile/P)
		..()
		var/chime_pitch = 0
		if (P.reflectcount <= 0)
			src.icon_state = "note1"
		else if (P.reflectcount == 1)
			src.icon_state = "note2"
		else if (P.reflectcount >= 2)
			src.icon_state = "note3"

		if (P.reflectcount > 12)
			chime_pitch = 12
		else
			chime_pitch = P.reflectcount

		playsound(P, "sound/musical_instruments/WeirdChime_[chime_pitch].ogg", 60, channel=VOLUME_CHANNEL_EMOTE)
		SPAWN(0 SECONDS)
			src.broke_lamp = FALSE

	on_hit(atom/hit, dirflag, obj/projectile/proj)
		if (ismob(hit))
			src.powered_shot(hit, proj, dirflag)
			return
		var/turf/proj_loc = get_turf(proj)

		for (var/obj/machinery/light/fixture in view(1, proj))
			if (fixture.current_lamp.light_status == LIGHT_OK || fixture.current_lamp.light_status == LIGHT_BURNED)
				src.broke_lamp = TRUE
			fixture.broken(explode_rigged=TRUE)

		var/bonus_bounces = 0
		if (src.broke_lamp)
			bonus_bounces++
		else if (proj_loc.is_lit())
			bonus_bounces--

		if (proj.reflectcount >= (bonus_bounces + src.max_bounces))
			proj.die()
		else
			shot_volume = 0
			shoot_reflected_bounce(proj, hit, (bonus_bounces + src.max_bounces), PROJ_RAPID_HEADON_BOUNCE)
			shot_volume = 100
		return

	proc/powered_shot(var/mob/hit, var/obj/projectile/proj, var/dir)
		if (proj.reflectcount < 1 || !isliving(hit))
			return

		var/mob/living/carbon/human/victim = hit
		var/turf/target = get_edge_target_turf(victim, dir)
		victim.do_disorient(15, knockdown = 40)
		victim.throw_at(target, 5, 3, throw_type = THROW_GUNIMPACT)

		if (proj.reflectcount < 2)
			return

		var/chosen_trap = pick(concrete_typesof(/obj/machinery/wraith/runetrap/))
		var/projowner = proj.special_data["owner"]
		var/obj/machinery/wraith/runetrap/trap = new chosen_trap(hit.loc, projowner)
		trap.arming_time = 1 SECONDS // reward double bounce hits, is funny
		trap.free_trap = TRUE

		playsound(hit, "sound/voice/wraith/wraithspook[rand(1, 2)].ogg", 60, 1, channel=VOLUME_CHANNEL_EMOTE)
		sonic_attack_environmental_effect(hit, 3, list("light"))
		for (var/mob/living/HH in hearers(hit, null))
			if (HH == hit)
				continue
			HH.apply_sonic_stun(0, 0, 20, 0, 3, 4, 6)












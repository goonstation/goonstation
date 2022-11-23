/obj/brain_slug/anchor_setter
	name = "Sticky goo"
	icon = 'icons/mob/brainslug.dmi'
	icon_state = "anchor"
	desc = "A glob of sticky goo. Why are you staring at it? RUN!"
	density = 0
	var/mob/living/caster = null

	throw_impact(atom/A, datum/thrown_thing/thr)
		..()
		new/obj/brain_slug/elastic_anchor(src.loc, caster)
		qdel(src)

/obj/brain_slug/elastic_anchor
	name = "elastic_anchor"
	icon = 'icons/mob/brainslug.dmi'
	icon_state = "anchor"
	desc = "A pile of sticky goo, restraining movement."
	anchored = 1
	density = 0
	_health = 7
	var/stretch_range = 4
	var/break_range = 10
	var/active = TRUE
	var/max_range = null
	var/lifetime = 15 SECONDS
	var/list/line_list = list()

	New(var/atom/A, var/mob/living/caster)
		START_TRACKING
		for (var/mob/living/M in viewers(3, src))
			if (M != caster && !istype(M, /mob/living/critter/brain_slug) && !istype(M, /mob/living/critter/adult_brain_slug))
				var/atom/movable/slime_line = new /atom/movable(src.loc)
				line_list += slime_line
				work(M, slime_line)
		SPAWN (lifetime)
			qdel(src)
		..()

	disposing()
		STOP_TRACKING
		active = FALSE
		for (var/atom/movable/A in line_list)
			qdel(A)
		..()

	proc/work(var/mob/living/the_mob, atom/movable/stretch_line)
		set waitfor = FALSE
		var/recent_throw = TIME - 2 SECONDS
		//stretch_line = new /atom/movable(src.loc)
		stretch_line.mouse_opacity = 0
		stretch_line.appearance_flags = 0
		stretch_line.alpha = 0
		stretch_line.color = stretch_line
		stretch_line.icon = 'icons/mob/brainslug.dmi'
		stretch_line.icon_state = "elastic_link"
		animate(stretch_line, alpha=127, time=1 SECOND)
		while(active)
			if(src.qdeled)
				qdel(stretch_line)
				the_mob = null
				break
			if(!active || !the_mob)
				qdel(stretch_line)
				qdel(src)
			var/turf/ST = get_turf(src)
			var/turf/T = get_turf(the_mob)
			var/dist = GET_DIST(src,the_mob)
			if (!ST || !T || ST.z != T.z || !isnull(max_range) && dist > max_range)
				qdel(src)
			//Did they teleport or something?
			if (dist > break_range)
				qdel(src)
			if ((dist > stretch_range) && ((recent_throw + 2 SECONDS) < TIME))
				the_mob.force_laydown_standup()
				the_mob.setStatus("stunned", 2 SECONDS)
				the_mob.throw_at(src, dist, 1)
				var/the_sound = pick('sound/misc/boing/1.ogg', 'sound/misc/boing/2.ogg', 'sound/misc/boing/3.ogg', 'sound/misc/boing/4.ogg', 'sound/misc/boing/5.ogg', 'sound/misc/boing/6.ogg')
				playsound(src.loc, the_sound, 80, 1, 1, 1.2)
				recent_throw = TIME
			src.set_dir(get_dir(src,the_mob))
			if(stretch_line)
				var/ang = get_angle(get_turf(src), get_turf(the_mob))
				var/stretch_line_dist = 8 + 40 / (1 + 3 ** (3 - dist / 10))
				var/matrix/M = matrix()
				var/stretch_line_scale = (0.9 * dist) + (dist * 0.1 / (1 + 3 ** (3 - dist / 10)))
				M = M.Scale(1, stretch_line_scale * 2)
				M = M.Turn(ang)
				M = M.Translate(stretch_line_dist * sin(ang), stretch_line_dist * cos(ang))
				animate(stretch_line, transform=M, time=0.2 SECONDS, flags=ANIMATION_PARALLEL)

			sleep(0.2 SECONDS)

	attackby(obj/item/P, mob/living/user)
		src._health -= 1
		attack_particle(user,src)
		user.lastattacked = src
		hit_twitch(src)
		user.visible_message("<span class='notice'>[user] Hacks away at the goo!</span>")
		playsound(src.loc, pick('sound/impact_sounds/Slimy_Hit_1.ogg', 'sound/impact_sounds/Slimy_Hit_2.ogg'), 50, 1)
		if(src._health <= 0)
			qdel(src)

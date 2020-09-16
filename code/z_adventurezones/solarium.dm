//moved all solarium stuff here - ZeWaka
/* -----------------------------------------------------------------------------*\
CONTENTS:
  SOLARIUM AREA
  THE SUN
\*----------------------------------------------------------------------------- */
////////////////////// cogwerks - solar lounge
//keys are in keys.dm

/area/solarium
	name = "Solarium"
	icon_state = "yellow"
	force_fullbright = 0
	sound_environment = 5
	may_eat_here_in_restricted_z = 1
	skip_sims = 1
	sims_score = 100
	sound_group = "solarium"

// it's about time this was an object I think
var/global/the_sun = null
/obj/the_sun
	name = "Sol"
	desc = "It's goddamn bright. Should you even be looking at this?"
	icon = 'icons/effects/160x160.dmi'
	icon_state = "sun"
	layer = EFFECTS_LAYER_UNDER_4
	luminosity = 5
	var/datum/light/light

	New()
		..()
		light = new /datum/light/point
		light.attach(src, 2.5, 2.5)
		light.set_brightness(4)
		light.set_height(3)
		light.set_color(0.9, 0.5, 0.3)
		light.enable()
		SPAWN_DBG (10)
			if (!the_sun)
				the_sun = src

	disposing()
		if (the_sun == src)
			the_sun = null
		..()

	disposing()
		if (the_sun == src)
			the_sun = null
		..()

	attackby(obj/item/O as obj, mob/user as mob)
		if (istype(O, /obj/item/clothing/mask/cigarette))
			if (!O:on)
				O:light(user, "<span class='alert'><b>[user]</b> lights [O] on [src] and casually takes a drag from it. Wow.</span>")
				if (!user.is_heat_resistant())
					SPAWN_DBG (10)
						user.visible_message("<span class='alert'><b>[user]</b> burns away into ash! It's almost as though being that close to a star wasn't a great idea!</span>",\
						"<span class='alert'><b>You burn away into ash! It's almost as though being that close to a star wasn't a great idea!</b></span>")
						user.firegib()
				else
					user.unlock_medal("Helios", 1)

var/global/server_kicked_over = 0
var/global/it_is_okay_to_do_the_endgame_thing = 0
var/global/was_eaten = 0
var/global/derelict_mode = 0
//congrats you won
/obj/the_server_ingame_whoa
	name = "server rack"
	desc = "This looks kinda important.  You can barely hear farting and honking coming from a speaker inside.  Weird."
	icon = 'icons/obj/networked.dmi'
	icon_state = "server"
	anchored = 1
	density = 1

	New()
		..()

		if (!it_is_okay_to_do_the_endgame_thing)
			del src
			return

		if (world.name)
			name = world.name

	attackby(obj/item/O as obj, mob/user as mob)
		..()
		if (server_kicked_over && istype(O, /obj/item/clothing/mask/cigarette))
			if (!O:on)
				O:light(user, "<span class='alert'>[user] lights the [O] with [src]. That's pretty meta.</span>")
				user.unlock_medal("Nero", 1)

		if (!O || !O.force)
			return

		src.breakdown()

	bullet_act(var/obj/projectile/P)
		if (P && P.proj_data.ks_ratio > 0)
			src.breakdown()

	proc/eaten(var/mob/living/carbon/human/that_asshole)
		if (server_kicked_over)
			boutput(that_asshole, "<span class='alert'>Frankly, it doesn't look as tasty when it's broken. You have no appetite for that.</span>")
			return
		src.visible_message("<span class='alert'><b>[that_asshole] devours the server!<br>OH GOD WHAT</b></span>")
		src.set_loc(null)
		world.save_intra_round_value("somebody_ate_the_fucking_thing", 1)
		breakdown()
		SPAWN_DBG(5 SECONDS)
			boutput(that_asshole, "<span class='alert'><b>IT BURNS!</b></span>")

	proc/breakdown()
		if (server_kicked_over)
			return

		server_kicked_over = 1
		sleep(1 SECOND)
		src.icon_state = "serverf"
		src.visible_message("<span class='alert'><b>[src] bursts into flames!</b><br>UHHHHHHHH</span>")
		SPAWN_DBG(0)
			var/area/the_solarium = get_area(src)
			for (var/mob/living/M in the_solarium)
				if (isdead(M))
					continue

				M.unlock_medal("Newton's Crew", 1)
			world.save_intra_round_value("solarium_complete", 1)
			//var/obj/overlay/the_sun = locate("the_sun")
			//if (istype(the_sun))
			if (the_sun)
				qdel(the_sun)
			for (var/turf/space/space in world)
				LAGCHECK(LAG_LOW)
				space.icon_state = "howlingsun"
				space.icon = 'icons/misc/worlds.dmi'
			world << sound('sound/machines/lavamoon_plantalarm.ogg')
			SPAWN_DBG(1 DECI SECOND)
				for(var/mob/living/carbon/human/H in mobs)
					H.flash(3 SECONDS)
					shake_camera(H, 210, 16)
					SPAWN_DBG(rand(1,10))
						// H.bodytemperature = 1000
						H.update_burning(10)
					SPAWN_DBG(rand(50,90))
						H.emote("scream")
			creepify_station() // creep as heck
			sleep(12.5 SECONDS)
			var/datum/hud/cinematic/cinematic = new
			for (var/client/C in clients)
				cinematic.add_client(C)
			cinematic.play("sadbuddy")
			sleep(1 SECOND)
			boutput(world, "<tt>BUG: CPU0 on fire!</tt>")
			logTheThing("diary", null, null, "The server would have restarted, if I hadn't removed the line of code that does that. Instead, we play through.", "game")
			
			SPAWN_DBG(5 SECONDS)
				for (var/client/C in clients)
					cinematic.remove_client(C)


			// sleep(15 SECONDS)
			// Reboot_server()

proc/voidify_world()
	var/turf/unsimulated/wall/the_ss13_screen = locate("the_ss13_screen")
	if(istype(the_ss13_screen))
		// change this when someone finds a widescreen sprite for disaster
		var/image/broken_logo = new/image('icons/misc/fullscreen.dmi', "title_broken")
		broken_logo.pixel_x = -the_ss13_screen.pixel_x
		the_ss13_screen.overlays += broken_logo

		/*the_ss13_screen.icon = 'icons/misc/fullscreen.dmi'
		the_ss13_screen.icon_state = "title_broken"
		the_ss13_screen.pixel_x = 0*/
	SPAWN_DBG(3 SECONDS)
		for (var/turf/space/space in world)
			LAGCHECK(LAG_LOW)
			if(was_eaten)
				if (space.icon_state != "acid_floor")
					space.icon_state = "acid_floor"
					space.icon = 'icons/misc/meatland.dmi'
					space.name = "stomach acid"
					if (space.z == 1)
						new /obj/stomachacid(space)
			else
				if(space.icon_state != "darkvoid")
					space.icon_state = "darkvoid"
					space.icon = 'icons/turf/floors.dmi'
					space.name = "void"
		//var/obj/overlay/the_sun = locate("the_sun")
		//if (istype(the_sun))
		if (the_sun)
			var/obj/Sun = the_sun
			Sun.icon_state = "sun_red"
			Sun.desc = "Uhhh...."
			Sun.blend_mode = 2 // heh
		//var/obj/critter/the_automaton = locate("the_automaton")
		//if (istype(the_automaton))
		if (the_automaton)
			var/obj/critter/Automaton = the_automaton
			Automaton.aggressive = 1
			Automaton.atkcarbon = 1
			Automaton.atksilicon = 1
		world << sound('sound/ambience/industrial/Precursor_Drone1.ogg')
	return

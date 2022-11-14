//CONTENTS:
//Halloween spooky thing spawn landmark
//Reader's death plaque.
//Spooky tombstone.
//Mind switching gizmo
//The spooky data of Dr. Horace Jam
//Old outpost data.
//Haunted camera.
//Haunted television.


//void crunch turfs moved to keelins stuff
//Decals that float moved to timeship.dm
//moved obsidiancrown and hemera stuff to hemera.dm
//paint machine to paint.dm
//cubicle walls to window.dm - what-the-fuck-am-i-doing
//broken rcd and void_break to rcd.dm
//pressurizer to pressurizer.dm
//wally and ill man to timeship.dm
//helldrone to helldrone.dm in critter
//timeship audio tapes to timeship.dm
//haunted closet to closets.dm
//evil bot to evilbot.dm
//A decal that glows after spawning to decal.dm
// the critters are now in the critter files because NOT EVERYTHING NEEDS TO BE IN HERE OKAY
// also /obj/item/storage/nerd_kit/New() is in storage.dm with /obj/item/storage/nerd_kit instead of RANDOMLY FLOATING AROUND IN HERE WHAT IS WRONG WITH YOU PEOPLE
//deathbutton to deathbutton.dm

#ifdef HALLOWEEN
#define EPHEMERAL_HALLOWEEN EPHEMERAL_SHOWN
#else
#define EPHEMERAL_HALLOWEEN EPHEMERAL_HIDDEN
#endif

/*
 *	DEATH PLAQUE
 */

/obj/joeq/spooky
	name = "Memorial Plaque"

	examine(mob/user)
		boutput(user, "Here lies [user.real_name]. Loved by all. R.I.P.")

/*
 *	Spooky TOMBSTONE.  It is a tombstone.
 */

/obj/tombstone
	name = "tombstone"
	//desc = "Here lies Tango N. Vectif, killed by a circus bear.  RIP." // changing for spawnability
	desc = "Rest in peace."
	icon = 'icons/misc/halloween.dmi'
	icon_state = "tombstone"
	anchored = 1
	density = 1
	var/robbed = 0
	var/special = null //The path of whatever special loot is robbed from this grave.

	memorial
		name = "memorial marker"
		desc = "Rest in peace."
		icon = 'icons/misc/halloween.dmi'
		icon_state = "memorial"

/*
 *	Some sort of bizarre mind gizmo!
 */

/obj/submachine/mind_switcher
	name = "Jukebox"
	desc = "A classic 20th century jukebox. Ayyy!"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "jukebox"
	anchored = 1
	density = 1
	var/last_switch = 0
	var/list/to_transfer = list() //List of mobs waiting to be shuffled back.
	var/teleport_next_switch = 0 //Should we hop somewhere else next switch?

	attack_ai(mob/user as mob)
		if(BOUNDS_DIST(src, user) == 0)
			return attack_hand(user)
		else
			boutput(user, "This jukebox is too old to be controlled remotely.")
		return

	attack_hand(mob/user)
		//This dude is no Fonz
		if (user.a_intent == "harm")
			user.visible_message("<span class='combat'><b>[user]</b> punches the [src]!</span>","You punch the [src].  Your hand hurts.")
			playsound(src.loc, pick(sounds_punch), 100, 1)
			user.TakeDamage(user.hand == LEFT_HAND ? "l_arm" : "r_arm", 0, rand(1, 4))
			return
		else
			src.visible_message("<b>[user]</b> thumps the [src]!  Ayy!")
			if(last_switch && ((last_switch + 1200) >= world.time))
				boutput(user, "Nothing happens.  What a ripoff!")
				return
			else
				last_switch = world.time
				src.mindswap()

		return

	proc/mindswap()
		src.visible_message("<span class='alert'>The [src] activates!</span>")
		playsound(src.loc, 'sound/effects/ghost2.ogg', 100, 1)

		var/list/transfer_targets = list()
		for(var/mob/living/M in view(6))
			if(M.loc == src) continue //Don't add the jerk trapped souls.
			if(M.key) //Okay cool, we have a player to transfer.
				var/mob/living/holder = new
				holder.set_loc(src)
				if(M.mind)
					M.mind.transfer_to(holder)
				else
					holder.key = M.key

				holder.name = "Trapped Soul"
				holder.real_name = holder.name
				to_transfer.Add(holder)

			if(!isdead(M) && M.loc != src) //No transferring to dead dudes.
				transfer_targets.Add(M)

			M.changeStatus("weakened", 3 SECONDS)

		if(!src.to_transfer.len || src.to_transfer.len == 1)
			src.visible_message("The [src] buzzes.")
			src.last_switch = 0
			if(src.teleport_next_switch)
				teleport_next_switch = 0
				src.telehop()
			return

		for(var/mob/living/M in src.to_transfer)
			if(!transfer_targets.len) //Welp, sucks for you dudes!
				src.visible_message("The [src] whirrs.  A small cry comes from within.")
				src.last_switch = max(0,src.last_switch - 60) //Reduce the wait a bit.

				if(src.teleport_next_switch)
					teleport_next_switch = 0
					src.telehop()

				return

			var/mob/living/new_body = pick(transfer_targets)
			if(!new_body || new_body.key || new_body.stat) //Oh no, it's been claimed/killed!
				continue

			if(M.client)
				new_body.lastKnownIP = M.client.address
				new_body.computer_id = M.client.computer_id
				M.lastKnownIP = null
				M.computer_id = null

			if(M.mind)
				M.mind.transfer_to(new_body)
			else
				new_body.key = M.key

			transfer_targets.Remove(new_body)
			blink(new_body)

			to_transfer.Remove(M)
			qdel(M)

		if(src.teleport_next_switch)
			teleport_next_switch = 0
			src.telehop()

		return

	proc/telehop()
		var/turf/T = pick_landmark(LANDMARK_BLOBSTART)
		if(T)
			src.visible_message("<span class='alert'>[src] disappears!</span>")
			playsound(src.loc, 'sound/effects/singsuck.ogg', 100, 1)
			src.set_loc(T)
		return

	disposing()
		for(var/mob/M in src.to_transfer)
			M.gib(1)
		to_transfer = null
		..()

/*
 *	The Dr. Horace Jam mystery notes
 */

/obj/item/reagent_containers/glass/beaker/strange_reagent
	name = "beaker-'Property of H. Jam'"
	desc = "A beaker labled 'Property of H. Jam'.  Can hold up to 50 units."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "beaker0"
	item_state = "beaker"
	initial_volume = 50

	New()
		..()
		reagents.add_reagent("strange_reagent", 50)

/obj/item/storage/secure/ssafe/hjam
	name = "Gun Storage"
	desc = "For Emergency Use Only"
	configure_mode = 0
	code = "54321"
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL

	New()
		..()
/*
		new /obj/item/gun/fiveseven/hjam(src)
		new /obj/item/ammo/a57(src)
		new /obj/item/ammo/a57(src)
		new /obj/item/ammo/a57(src)

/obj/item/gun/fiveseven/hjam
	name = "SMRZ Six-seveN"
	desc = "A cheap Martian knock-off of a SM 0RZ Six-seveN. Uses 5.7mm rounds."
	weapon_lock = 0
*/
/obj/machinery/computer3/generic/hjam
	name = "Dr. Jam's Console"
	setup_starting_peripheral1 = /obj/item/peripheral/network/powernet_card
	setup_starting_peripheral2 = /obj/item/peripheral/printer
	setup_drive_type = /obj/item/disk/data/fixed_disk/hjam_rdrive

/obj/item/disk/data/fixed_disk/hjam_rdrive
	title = "HJam_HDD"

	New()
		..()
		//First off, create the directory for logging stuff
		var/datum/computer/folder/newfolder = new /datum/computer/folder(  )
		newfolder.name = "logs"
		src.root.add_file( newfolder )
		newfolder.add_file( new /datum/computer/file/record/c3help(src))
		newfolder.add_file( new /datum/computer/file/text/hjam_passlog(src))
		//This is the bin folder. For various programs I guess sure why not.
		newfolder = new /datum/computer/folder
		newfolder.name = "bin"
		src.root.add_file( newfolder )
		newfolder.add_file( new /datum/computer/file/terminal_program/writewizard(src))
		//new
		newfolder = new /datum/computer/folder
		newfolder.name = "research"
		src.root.add_file( newfolder )
		newfolder.add_file( new /datum/computer/file/text/hjam_rlog_1(src))
		newfolder.add_file( new /datum/computer/file/text/hjam_rlog_2(src))
		newfolder.add_file( new /datum/computer/file/text/hjam_rlog_3(src))

//Old outpost stuff
/obj/machinery/computer3/generic/outpost1
	name = "VR Research Console"
	setup_starting_peripheral1 = /obj/item/peripheral/network/powernet_card
	setup_starting_peripheral2 = /obj/item/peripheral/printer
	setup_drive_type = /obj/item/disk/data/fixed_disk/outpost_rdrive

/obj/item/disk/data/fixed_disk/outpost_rdrive
	title = "VR_HDD"

	New()
		..()
		//First off, create the directory for logging stuff
		var/datum/computer/folder/newfolder = new /datum/computer/folder(  )
		newfolder.name = "logs"
		src.root.add_file( newfolder )
		newfolder.add_file( new /datum/computer/file/record/c3help(src))
		//newfolder.add_file( new /datum/computer/file/text/hjam_passlog(src))
		//This is the bin folder. For various programs I guess sure why not.
		newfolder = new /datum/computer/folder
		newfolder.name = "bin"
		src.root.add_file( newfolder )
		newfolder.add_file( new /datum/computer/file/terminal_program/writewizard(src))

		src.root.add_file( new /datum/computer/file/text/outpost_rlog_1(src))
		src.root.add_file( new /datum/computer/file/text/outpost_rlog_2(src))
		//src.root.add_file( new /datum/computer/file/text/hjam_rlog_3(src))

//Haunted camera. Steals people's souls.
/obj/item/camera/haunted
	name = "rusty camera"
	pictures_left = -1 // halloween magic doesn't need photos
	steals_souls = TRUE

/obj/item/photo/haunted
	var/list/mob/old_bodies = list()

	attack_self(mob/user as mob)
		user.visible_message("<span class='combat'>[user] tears the photo to shreds!</span>","<span class='combat'>You tear the photo to shreds!</span>")
		qdel(src)
		return

	disposing()
		for(var/mob/living/M in src)
			if(M.mind && M.key)
				if(old_bodies[M.key] && !(old_bodies[M.key].disposed) && !(old_bodies[M.key].key))
					M.mind.transfer_to(old_bodies[M.key])
				else
					M.ghostize()
			qdel(M)
		. = ..()

	proc/add_soul(var/mob/victim)
		if(!(victim.mind) || !(victim.key))
			return

		old_bodies[victim.key] = victim
		var/mob/living/holder = new
		holder.set_loc(src)
		victim.mind.transfer_to(holder)
		holder.name = victim.name
		holder.real_name = victim.real_name

//Haunted television
/obj/haunted_television
	name = "Television"
	desc = "The television, that insidious beast, that Medusa which freezes a billion people to stone every night, staring fixedly, that Siren which called and sang and promised so much and gave, after all, so little."
	icon = 'icons/obj/computer.dmi'
	icon_state = "security_det"
	anchored = 1
	density = 1

	attack_hand(mob/user)
		boutput(user, "<span class='combat'>The knobs are fixed in place.  Might as well sit back and watch, I guess?</span>")

	examine(mob/user)
		. = list()
		if (ishuman(user) && !user.stat)
			var/mob/living/carbon/human/M = user

			M.visible_message("<span class='combat'>[M] stares blankly into [src], [his_or_her(M)] eyes growing duller and duller...</span>","<span class='combat'>You stare deeply into [src].  You...can't look away.  It's mesmerizing.  Sights, sounds, colors, shapes.  They blur together into a phantasm of beauty and wonder.</span>")
			var/mob/living/carbon/holder = new
			holder.set_loc(src)
			if(M.mind)
				M.mind.transfer_to(holder)
			else
				holder.key = M.key

			holder.name = "Trapped Soul"
			holder.real_name = holder.name

			blink(M)

			//Some more cockatrice action
			var/obj/overlay/stoneman = new /obj/overlay(M.loc)
			M.set_loc(stoneman)
			stoneman.name = "statue of [M.name]"
			stoneman.desc = "A really dumb looking statue. Very well carved, though."
			stoneman.anchored = 0
			stoneman.set_density(1)
			stoneman.layer = MOB_LAYER

			var/icon/composite = icon(M.icon, M.icon_state, M.dir, 1)
			for (var/image/I as anything in M.overlays)
				composite.Blend(icon(I.icon, I.icon_state, I.dir, 1), ICON_OVERLAY)
			composite.ColorTone( rgb(188,188,188) )
			stoneman.icon = composite

			holder.set_loc(stoneman)
			stoneman.set_dir(get_dir(stoneman, src))

		else
			. += desc

/obj/item/toy/halloween2014spellbook
	name = "Book of Spells"
	desc = "An old spooky tome full of horrific eldritch magic. What insane mortal dares open it? Is it me?? Is it him??? Is it... yoooooooouuuuuu??????"
	icon = 'icons/obj/writing.dmi'
	icon_state = "sbook"
	var/uses = 1

	attack_self(var/mob/user as mob)
		var/list/choices = list("Y OWL GO SIP KEGS","FERAL TOFU GAPS","NULL MOSS NOOK","ONION SLUG CANDY","HOT SIGMA")
		var/pick = input("This old book looks like it could crumble away at any moment... which spell will you read?","Book of Spells") as null|anything in choices
		var/used = -1

		if (!src)
			return

		switch(pick)
			if("Y OWL GO SIP KEGS") // Anagram: SPOOKY WIGGLES
				for (var/atom/A in range(4,user))
					if (isarea(A))
						continue
					if (istype(A,/obj/particle/) || istype(A,/atom/movable/screen))
						continue
					if (ismob(A))
						var/mob/M = A
						M.show_text("Uh oh! Everything's going all wiggly! NOW YOU KNOW TRUE HOOOORROOOOR!!!!!","#8218A8")
					animate_wiggle_then_reset(A,5,50)
			if("FERAL TOFU GAPS") // Anagram: PLAGUE OF FARTS
				for (var/mob/living/carbon/C in range(4,user))
					if (C.reagents)
						C.reagents.add_reagent("egg",25)
						C.reagents.add_reagent("fartonium",25)
						user.show_text("You feel a spooky rumbling in your guts! Maybe you ate a ghoooooost?!","#8218A8")
					if (C.bioHolder)
						C.bioHolder.age += 125
						SPAWN(1 MINUTE)
							C.bioHolder.age -= 125
			if("NULL MOSS NOOK") // Anagram: SKULL MONSOON
				particleMaster.SpawnSystem(new /datum/particleSystem/skull_rain(get_turf(user)))
				user.show_text("You hear something rattling above you!","#8218A8")
			if("ONION SLUG CANDY") // Anagram: ANNOYING CLOUDS
				particleMaster.SpawnSystem(new /datum/particleSystem/spooky_mist(get_turf(user)))
				user.show_text("A cold and spooky wind begins to blow!","#8218A8")
				playsound(user, 'sound/ambience/nature/Wind_Cold2.ogg', 50, 1, 5)
			if("HOT SIGMA") // Anagram: IM A GHOST
				user.blend_mode = 2
				user.alpha = 150
				user.show_text("You feel extra spooky!","#8218A8")
				SPAWN(2 MINUTES)
					user.blend_mode = 0
					user.alpha = 255
			else
				boutput(user, "You decide to leave the book alone for now.")
				used = 0

		if (used)
			user.visible_message("<span class='combat'><b>[user.name]</b> reads a spell from the book!</span>")
			src.uses--
			if (uses == 0)
				boutput(user, "<span class='combat'>The book crumbles away into dust! How spooooooky!</span>")
				src.dropped(user)
				qdel(src)

		return

/datum/particleSystem/skull_rain
	New(var/atom/location = null)
		..(location, "skull_rain", 100)

	Run()
		if (state != 2 && ..())
			for(var/i, i < 50, i++)
				SpawnParticle()
				sleep(0.5)
			Die()

/datum/particleType/skull_rain
	name = "skull_rain"
	icon = 'icons/effects/particles.dmi'
	icon_state = "skull3"

	MatrixInit()
		first = matrix(rand(-60,60), MATRIX_ROTATE)
		second = matrix()

	Apply(var/obj/particle/par)
		if(..())
			par.alpha = 1
			par.color = "#FFFFFF"
			par.pixel_x = rand(-128,128)
			par.pixel_y = 320

			second.Turn(rand(-60,60))

			animate(par, transform = second, time = 20, pixel_y = rand(-128,128), alpha = 255, easing = BOUNCE_EASING)
			animate(time = 60, alpha = 1, easing = LINEAR_EASING)

/datum/particleSystem/spooky_mist
	New(var/atom/location = null)
		..(location, "spooky_mist", 300)

	Run()
		if (state != 2 && ..())
			for(var/i, i < 125, i++)
				SpawnParticle()
				sleep(0.3 SECONDS)
			Die()

/datum/particleType/spooky_mist
	name = "spooky_mist"
	icon = 'icons/effects/particles.dmi'
	icon_state = "mistcloud1"

	MatrixInit()
		first = matrix(15, MATRIX_SCALE)

	Apply(var/obj/particle/par)
		if(..())
			par.alpha = 60
			par.color = "#FFFFFF"
			par.pixel_x = 480
			par.pixel_y = rand(-240,240)
			par.transform = first

			//animate(par, time = 10, alpha = 60, easing = LINEAR_EASING)
			animate(par, time = 280, pixel_x = par.pixel_x * -1, easing = SINE_EASING)
			//animate(time = 10, alpha = 1, easing = LINEAR_EASING)

/obj/extremely_spooky_ghost // ooooooOOOOOOOOooooooooOOOOOOOoooooo
	name = "ghost"
	desc = "A decorative ghost, hanging from the ceiling. It's <b><u><i>pretty scary!!!!</i></u></b>"
	icon = 'icons/mob/ghost_drone.dmi'
	icon_state = "g_drone"
	anchored = 1
	density = 0
	pixel_y = 7
	var/trigger_sound = 'sound/effects/ExtremelyScaryGhostNoise.ogg'
	var/trigger_duration = 118 // should be about as long as the sound clip
	var/spam_flag = 0
	var/spam_timer = 150

	Crossed(atom/movable/AM)
		..()
		if (!src.spam_flag && AM) // something moved in our tile and we're ready to spook!!
			src.spam_flag = 1
			if (prob(66)) // our sensor isn't the best
				src.scare_some_people()
			SPAWN(src.spam_timer)
				if (src)
					src.spam_flag = 0

	proc/scare_some_people()
		src.spooky_shake()
		playsound(src, src.trigger_sound, 40, 0)
		src.visible_message("<span class='alert'><b>\The [src] comes to life and starts making an unearthly, haunting wail!</b></span>")
		for (var/mob/M in viewers(src))
			if (prob(66))
				var/msg = pick("<span class='alert'><b>You're [pick("hella","super","very","extremely","completely","totally")] [pick("scared","spooked","terrified")]![pick("","!","!!")]</b><span>",\
				"<span class='alert'><b>You've never felt so [pick("scared","spooked","terrified")]![pick("","!","!!")]</b><span>",\
				"Oh, it's just a decoration.[pick(""," You were kinda spooked for a moment there."," That's a relief!")]")
				M.show_text(msg)

	proc/spooky_shake()
		set waitfor = 0
		for (var/i=src.trigger_duration, i>0, i--)
			src.set_dir(pick(cardinal))
			src.pixel_x = rand(-3,3)
			sleep(0.1 SECONDS)

/obj/cauldron
	name = "cauldron"
	desc = "An empty cast-iron cauldron."
	icon = 'icons/misc/halloween.dmi'
	icon_state = "cauldron"
	anchored = 1
	density = 1

	candy
		name = "candy-filled cauldron"
		desc = "It's full of candy! Treats... or tricks?"
		icon_state = "cauldron-candy"

		attack_hand(mob/user)
			var/list/candytypes = concrete_typesof(/obj/item/reagent_containers/food/snacks/candy)
			var/newcandy_path = pick(candytypes)
			var/obj/item/reagent_containers/food/snacks/candy/newcandy = new newcandy_path
			user.put_in_hand_or_drop(newcandy)
			if (prob(5))
				newcandy.razor_blade = 1
			boutput(user, "You grab [newcandy] from the cauldron!")

	candy/halloween_only
		EPHEMERAL_HALLOWEEN

	jellybean
		name = "jellybean-filled cauldron"
		desc = "It's full of jellybeans! Wonder what's in these..."
		icon_state = "cauldron-jellybean"

		attack_hand(mob/user)
			var/obj/item/reagent_containers/food/snacks/candy/jellybean/everyflavor/B = new
			user.put_in_hand_or_drop(B)
			boutput(user, "You grab [B] from the cauldron!")

	jellybean/halloween_only
		EPHEMERAL_HALLOWEEN

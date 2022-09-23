// TODO make this mob/living/intangible. the fuck is it doing here?
/mob/living/seanceghost
	name = "Seance Ghost"
	desc = "Ominous hooded figure!"
	icon = 'icons/obj/zoldorf.dmi'
	icon_state = "seanceghost"
	layer = NOLIGHT_EFFECTS_LAYER_BASE
	density = 0
	canmove = 1
	blinded = 0
	anchored = 1
	alpha = 180
	event_handler_flags = IMMUNE_MANTA_PUSH | IMMUNE_SINGULARITY
	var/obj/machinery/playerzoldorf/homebooth
	var/mob/originalmob

	New(var/mob/M)
		..()

	is_spacefaring()
		return 1

	ex_act(severity)
		return

	meteorhit()
		return

	/*disposing()
		for(var/mob/zoldorf/z in src.contents)
			if(z.homebooth)
				z.set_loc(homebooth)
			else
				z.set_loc(src.loc)
				z.free()
		..()*/

	click(atom/target)
		src.examine_verb(target)

	Cross(atom/movable/mover)
		return 1

	say_understands(var/other)

		if (isAI(other))
			return 1

		if (ishuman(other))
			var/mob/living/carbon/human/H = other
			if (!H.mutantrace || !H.mutantrace.exclusive_language)
				return 1
			else
				return 0

		if (isrobot(other) || isshell(other))
			return 1
		return ..()

	Move(NewLoc, direct) //just a copy paste from ghost move
		if(!canmove) return

		if (NewLoc && isrestrictedz(src.z) && !restricted_z_allowed(src, NewLoc) && !(src.client && src.client.holder))
			var/OS = pick_landmark(LANDMARK_OBSERVER, locate(1, 1, 1))
			if (OS)
				src.set_loc(OS)
			else
				src.z = 1
			return

		if (!isturf(src.loc))
			src.set_loc(get_turf(src))
		if (NewLoc)
			set_dir(get_dir(loc, NewLoc))
			src.set_loc(NewLoc)
			return

		set_dir(direct)
		if((direct & NORTH) && src.y < world.maxy)
			src.y++
		if((direct & SOUTH) && src.y > 1)
			src.y--
		if((direct & EAST) && src.x < world.maxx)
			src.x++
		if((direct & WEST) && src.x > 1)
			src.x--

		return ..()

	is_active()
		return 0

	can_use_hands()
		return 0

	put_in_hand(obj/item/I, hand)
		return 0

	equipped()
		return 0

	say(var/message)
		message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
		if (dd_hasprefix(message, "*"))
			return src.emote(copytext(message, 2),1)

		logTheThing(LOG_DIARY, src, "[src.name] - [src.real_name]: [message]", "say")

		if (src.client && src.client.ismuted())
			boutput(src, "You are currently muted and may not speak.")
			return

	emote(var/act, var/voluntary)
		var/message
		switch (lowertext(act))
			if("flip")
				if(src.emote_check(voluntary, 100, 1, 0))
					message = "flips ominously!"
					if (prob(50))
						animate_spin(src, "R", 1, 0)
					else
						animate_spin(src, "L", 1, 0)
			if("fart")
				if(src.emote_check(voluntary, 100, 1, 0))
					message = "emits a chilling wind..."
			if("scream")
				if(src.emote_check(voluntary, 100, 1, 0))
					message = "produces a low hum..."
		if(message)
			src.visible_message("<span><b>[src.name]</b> [message]</span>")

	death(gibbed)
		. = ..()
		if(originalmob)
			if (src.client)
				src.removeOverlaysClient(src.client)
				client.mob = originalmob

			if (src.mind)
				mind.transfer_to(originalmob)

			originalmob.set_loc(src.loc)
		else
			var/mob/dead/observer/o = src.ghostize()
			if(o.client)
				o.apply_looks_of(o.client)
		qdel(src)

	/*verb/suicide()
		set hidden = 1
		var/confirm = alert("Are you sure you want to commit suicide? This will boot you back into your previous body.", "Confirm Suicide", "Yes", "No")
		if(confirm == "Yes")
			if(src.originalzoldorf)
				src.mind.transfer_to(originalzoldorf)
			else if(src.originalmob)
				src.gib(1)
			qdel(src)*/

/mob/proc/make_seance(var/mob/originalg as mob,var/mob/zoldorf/originalz as mob,var/list/deadpeople) //seance ghosts are temporary, so they needed some way to be automatically returned to their previous mob
	if(originalz) //theres different handling for if that previous mob was a zoldorf or not
		originalg = originalz
	if (src.mind || src.client)
		var/mob/living/seanceghost/Z = new/mob/living/seanceghost(src)

		var/turf/T = get_turf(src)
		if (!(T && isturf(T)) || ((isrestrictedz(T.z) || T.z != 1) && !(src.client && src.client.holder)))
			var/OS = pick_landmark(LANDMARK_OBSERVER, locate(1, 1, 1))
			if (OS)
				Z.set_loc(OS)
			else
				Z.z = 1
		else
			Z.set_loc(T)

		if (src.mind)
			src.mind.transfer_to(Z)
			if(deadpeople)
				Z.name = pick(deadpeople)
				Z.name += "?"
			else if(originalg.name)
				Z.name = originalg.name
				Z.name += "?"
			if(originalz)
				Z.homebooth = originalz.homebooth
			Z.real_name = originalg.real_name
			if(Z.abilityHolder)
				Z.abilityHolder.locked = 0
		else
			var/key = src.client.key
			if (src.client)
				src.client.mob = Z
			Z.originalmob = originalg
			Z.mind = new /datum/mind()
			Z.mind.ckey = ckey
			Z.mind.key = key
			Z.mind.current = Z
			ticker.minds += Z.mind

		return Z
	return null

/obj/item/paper/soulsell101
	name = "Selling Your Soul 101"
	desc = "informational pamphlet about selling your soul"
	icon_state = "paper"

	info = "<span><b>Selling Your Soul!</b></span><br><br><li>Permenantly reduces your max health</li><li>If you spend your whole sell it damns you to hell on death</li> \
	<li>Being soulless = ouchies</li>"

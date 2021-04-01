/*NOTE:

Put in power that will lay a facehugger egg but cost a lot of plasma, 250 or something?

Also perhaps only queens can do that?

*/






/mob/living/carbon/alien/humanoid/verb/invis()
	set name = "Invisibility (50)"
	set desc = "Makes you invisible for 30 seconds"
	set category = "Alien"

	if(src.stat)
		src << "You must be concious to do this"
		return
	if(src.toxloss >= 50)
		src.toxloss -= 50
		src.alien_invis = 1.0
		src << "\green You are now invisible"
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\green <B>[src] fades into the surroundings!</B>"), 1)
		spawn(300)
			src.alien_invis = 0.0
			src << "\green You are no longer invisible"
	else
		src << "\green Not enough plasma stored"
	return

/mob/living/carbon/alien/humanoid/verb/spit(mob/M as mob in oview())
	set name = "Spit (25)"
	set desc = "Spits acid at someone"
	set category = "Alien"

	if(src.stat)
		src << "You must be concious to do this"
		return
	if(src.toxloss >= 25)
		src.toxloss -= 25

		spawn(0)
			var/obj/overlay/A = new /obj/overlay( usr.loc )
			A.icon_state = "cbbolt"
			A.icon = 'projectiles.dmi'
			A.name = "acid"
			A.anchored = 0
			A.density = 0
			A.layer = 4
			var/i
			for(i=0, i<20, i++)
				var/obj/overlay/B = new /obj/overlay( A.loc )
				B.icon_state = "cbbolt"
				B.icon = 'projectiles.dmi'
				B.name = "acid"
				B.anchored = 1
				B.density = 0
				B.layer = 3
				spawn(5)
					del(B)
				step_to(A,M,0)
				if (get_dist(A,M) == 0)
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\green <B>[src] has spat at [M.name]!</B>"), 1)
					M.weakened += 5
					M.fireloss += 10
					del(A)
					return
				sleep(5)
			del(A)
	else
		src << "\green Not enough plasma stored"
	return

/mob/living/carbon/alien/humanoid/verb/plant()
	set name = "Plant Weeds (100)"
	set desc = "Plants some alien weeds"
	set category = "Alien"

	if(src.stat)
		src << "You must be concious to do this"
		return
	if(src.toxloss >= 100)
		src.toxloss -= 100
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\green <B>[src] has planted some alien weeds!</B>"), 1)
		var/obj/alien/weeds/W = new /obj/alien/weeds(src.loc)
		W.Life()

	else
		src << "\green Not enough plasma stored"
	return

/mob/living/carbon/alien/humanoid/verb/call_to()
	set name = "Call facehuggers (5)"
	set desc = "Makes all nearby facehuggers follow you."
	set category = "Alien"

	if(src.stat)
		src << "You must be concious to do this"
		return

	if(src.toxloss >= 5)
		src.toxloss -= 5
		for(var/obj/alien/facehugger/F in range(8,src))
			F.call_to(src)
		emote("roar")
	else
		src << "\green Not enough plasma stored"
	return

/mob/living/carbon/alien/humanoid/verb/whisp(mob/M as mob in oview())
	set name = "Whisper (10)"
	set desc = "Whisper to someone"
	set category = "Alien"

	if(src.stat)
		src << "You must be concious to do this"
		return

	var/msg = input("Message:", "Alien Whisper") as text
	if (!msg)
		return

	if(src.toxloss >= 10)
		src.toxloss -= 10
		log_say("AlienWhisper: [key_name(src)]->[M.key] : [msg]")

		M << "\green You hear a strange alien voice in your head... \italic [msg]"
		src << {"\green You said: "[msg]" to [M]"}
	else
		src << "\green Not enough plasma stored"
	return

/mob/living/carbon/alien/humanoid/verb/transfer_plasma(mob/living/carbon/alien/M as mob in oview())
	set name = "Transfer Plasma"
	set desc = "Transfer Plasma to another alien"
	set category = "Alien"

	if(!isalien(M))
		return

	if(src.stat)
		src << "You must be concious to do this."
		return

	if(!src.toxloss)
		src << "You don't have any plasma."
		return

	var/amount = input("Amount:", "Transfer Plasma to [M]") as num

	if (!amount)
		return

	if (get_dist(src,M) <= 1)
		if(src.toxloss >= amount)
			M.toxloss += amount
			src.toxloss -= amount
		else
			src << "You don't have enough plasma."
			return

		M << "\green [src] has transfered [amount] plasma to you."
		src << {"\green You have trasferred [amount] plasma to [M]"}

	else
		src << "\green You need to be closer."
	return
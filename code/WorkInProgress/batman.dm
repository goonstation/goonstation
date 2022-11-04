
// 4 arfur
// xoxo procitizen
/mob/living/carbon/human/batman
	New()
		..()
		SPAWN(0)
			if(src.bioHolder)
				src.bioHolder.age = 120
				src.bioHolder.AddEffect("nightvision", 0, 0, 0)
				src.bioHolder.AddEffect("strong", 0, 0, 0)
				src.bioHolder.AddEffect("cloak_of_darkness", 0, 0, 0)

			//src.mind = new
			src.gender = "male"
			src.real_name = "Batman"

			src.equip_new_if_possible(/obj/item/storage/backpack/, slot_back)
			src.equip_new_if_possible(/obj/item/clothing/shoes/swat, slot_shoes)
			src.equip_new_if_possible(/obj/item/clothing/under/misc/lawyer, slot_w_uniform)
			src.equip_new_if_possible(/obj/item/clothing/suit/armor/batman, slot_wear_suit)
			src.equip_new_if_possible(/obj/item/clothing/glasses/sunglasses/sechud, slot_glasses)
			src.equip_new_if_possible(/obj/item/clothing/gloves/yellow, slot_gloves)
			src.equip_new_if_possible(/obj/item/clothing/head/helmet/batman, slot_head)
			src.equip_new_if_possible(/obj/item/clothing/mask/batman, slot_wear_mask)
			src.equip_new_if_possible(/obj/item/storage/belt/security, slot_belt)
			src.equip_new_if_possible(/obj/item/device/radio/headset/command, slot_ears)
			src.equip_new_if_possible(/obj/item/card/id/syndicate, slot_wear_id)
			src.equip_new_if_possible(/obj/item/handcuffs/tape_roll, slot_l_store)
			src.equip_new_if_possible(/obj/item/tank/emergency_oxygen, slot_r_store)

			src.equip_new_if_possible(/obj/item/storage/box/tactical_kit, slot_in_backpack)
			src.equip_new_if_possible(/obj/item/storage/medical_pouch, slot_in_backpack)
			src.equip_new_if_possible(/obj/item/storage/belt/syndicate_medic_belt, slot_in_backpack)
			src.equip_new_if_possible(/obj/item/breaching_charge/thermite, slot_in_backpack)
			src.equip_new_if_possible(/obj/item/breaching_charge/thermite, slot_in_backpack)
			src.equip_new_if_possible(/obj/item/storage/box/flashbang_kit, slot_in_backpack)

			src.equip_new_if_possible(/obj/item/tool/omnitool, slot_in_belt)
			src.equip_new_if_possible(/obj/item/clothing/glasses/thermal, slot_in_belt)
			src.equip_new_if_possible(/obj/item/gun/energy/pickpocket, slot_in_belt)

			src.verbs += /mob/proc/batsmoke
			src.verbs += /mob/proc/batarang
			src.verbs += /mob/proc/batkick
			src.verbs += /mob/proc/batrevive
			src.verbs += /mob/proc/batattack
			src.verbs += /mob/proc/batspinkick
			src.verbs += /mob/proc/batspin
			src.verbs += /mob/proc/batdropkick

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1
		if (!src.stat && prob(5))
			src.say("I'm Batman.")

/*
/obj/item/clothing/suit/armor/batman/equipped(var/mob/user)
	user.verbs += /client/proc/batsmoke
	user.verbs += /client/proc/batarang
	user.verbs += /mob/proc/batkick
	user.verbs += /mob/proc/batrevive
	user.verbs += /mob/proc/batattack
	user.verbs += /mob/proc/batspinkick
	user.verbs += /mob/proc/batspin
	user.verbs += /mob/proc/batdropkick

/obj/item/clothing/suit/armor/batman/unequipped(var/mob/user)
	user.verbs -= /client/proc/batsmoke
	user.verbs -= /client/proc/batarang
	user.verbs -= /mob/proc/batkick
	user.verbs -= /mob/proc/batrevive
	user.verbs -= /mob/proc/batattack
	user.verbs -= /mob/proc/batspinkick
	user.verbs -= /mob/proc/batspin
	user.verbs -= /mob/proc/batdropkick
*/

/proc/batman_pow(atom/target_location)
	var/pow_type = pick(/obj/decal/batman_pow, /obj/decal/batman_pow/wham)
	var/obj/decal/batman_pow/pow = new pow_type(target_location)
	animate_portal_appear(pow)
	SPAWN(1 SECOND) qdel(pow)

/mob/proc/batsmoke()
	set category = "Batman"
	set name = "Batsmoke \[Support]"

	playsound(usr, 'sound/weapons/launcher.ogg', 70, 0, 0)
	usr.visible_message("<span class='alert'>[usr] drops a smoke bomb!</span>", "<span class='alert'>You drop a smoke bomb!</span>")

	var/datum/effects/system/bad_smoke_spread/smoke = new /datum/effects/system/bad_smoke_spread()
	smoke.set_up(10, 0, usr.loc)
	smoke.start()

/mob/proc/batarang(mob/T as mob in oview())
	set category = "Batman"
	set name = "Batarang \[Combat]"
	usr.visible_message("<span class='alert'>[usr] tosses a batarang at [T]!</span>", "<span class='alert'>You toss a batarang at [T]!</span>")
	playsound(usr, pick('sound/effects/sword_unsheath1.ogg','sound/effects/sword_unsheath2.ogg'), 70, 0, 0)
	var/obj/overlay/A = new /obj/overlay( usr.loc )
	A.icon_state = "batarang"
	A.icon = 'icons/effects/effects.dmi'
	A.name = "a batarang"
	A.anchored = 0
	A.set_density(0)
	var/i
	for(i=0, i<100, i++)
		step_to(A,T,0)
		if (GET_DIST(A,T) < 1)
			playsound(T, 'sound/impact_sounds/Blade_Small_Bloody.ogg', 70, 0, 0)
			random_brute_damage(T, 7)
			take_bleeding_damage(T, usr, 5, DAMAGE_STAB, 0)
			bleed(T, 3, 1)
			T.changeStatus("weakened", 7 SECONDS)
			T.changeStatus("stunned", 7 SECONDS)
			T.visible_message("<span class='alert'>[T] was struck by the batarang!</span>", "<span class='alert'>You were struck by a batarang!</span>")
			qdel(A)
		sleep(0.2 SECONDS)
	qdel(A)
	return

/mob/proc/batkick(mob/T as mob in oview(1))
	set category = "Batman"
	set name = "Bat Kick \[Combat]"
	set desc = "A powerful stunning kick, sending people flying across the room"

	if(T)
		var/turf/tturf = get_edge_target_turf(usr, get_dir(T, get_step_away(T, usr)))
		usr.visible_message("<span class='alert'><B>[usr] powerfully kicks [T]!</B></span>", "<span class='alert'><B>You kick [T]!</B></span>")
		usr.emote("flip")
		playsound(usr.loc, "swing_hit", 40, 1)
		batman_pow(T.loc)
		T.setStatus("weakened", T.getStatusDuration("weakened") + 4 SECONDS)
		T.setStatus("stunned", T.getStatusDuration("stunned") + 4 SECONDS)
		T.force_laydown_standup()
		if(tturf && isturf(tturf))
			T.throw_at(tturf, 3, 2)

/mob/proc/batrevive()
	set category = "Batman"
	set name = "Recover \[Support]"
	set desc = "Unstuns you"

	if(usr.hasStatus("weakened") || usr.hasStatus("stunned"))
		playsound(usr.loc, 'sound/effects/flip.ogg', 50, 1)
		usr.visible_message("<span class='alert'><B>[usr] suddenly recovers!</B></span>", "<span class='alert'><B>You suddenly recover!</B></span>")
		usr.delStatus("weakened")
		usr.delStatus("stunned")
		usr.emote("flip")

/obj/decal/batman_pow
	name = "POW!"
	anchored = 1
	density = 0
	opacity = 0
	mouse_opacity = 0
	layer = EFFECTS_LAYER_BASE
	icon = 'icons/effects/effects.dmi'
	icon_state = "batpow"

	wham
		icon_state = "batwham"

/mob/proc/batattack(mob/T as mob in oview(1))
	set category = "Batman"
	set name = "Bat Punch \[Combat]"
	set desc = "Attack, but Batman-like ok"

	if(usr.stat)
		boutput(usr, "<span class='alert'>Not when you're incapped!</span>")
		return
	usr.visible_message("<span class='alert'><B>[usr] bat-punches [T]!</B></span>", "<span class='alert'><B>You bat-punch [T]!</B></span>")
	playsound(usr.loc, "swing_hit", 40, 1)
	batman_pow(T.loc)
	var/zone = "chest"
	if(usr.zone_sel)
		zone = usr.zone_sel.selecting
	if ((zone in list( "eyes", "mouth" )))
		zone = "head"
	T.TakeDamage(zone, 4, 0)
	T.setStatus("weakened", T.getStatusDuration("weakened") + 3 SECONDS)
	T.setStatus("stunned", T.getStatusDuration("stunned") + 3 SECONDS)
	T.force_laydown_standup()
	var/turf/tturf = get_edge_target_turf(usr, get_dir(T, get_step_away(T, usr)))
	if(tturf && isturf(tturf))
		T.throw_at(tturf, 2, 2)

/mob/proc/batspinkick(mob/T as mob in oview(1))
	set category = "Batman"
	set name = "Batkick \[Finisher]"
	set desc = "A spinning kick that drops motherfuckers to the CURB"


	if(usr.stat)
		boutput(usr, "<span class='alert'>Not when you're incapped!</span>")
		return
	SPAWN(0)
		T.setStatus("stunned", 10 SECONDS)
		usr.visible_message("<span class='alert'><B>[usr] leaps into the air, shocking [T]!</B></span>", "<span class='alert'><B>You leap into the air, shocking [T]!</B></span>")
		for(var/i = 0, i < 5, i++)
			usr.pixel_y += 4
			sleep(0.1 SECONDS)
		usr.visible_message("<span class='alert'><B>[usr] begins kicking [T] in the face rapidly!</B></span>", "<span class='alert'><B>You begin kicking [T] in the face rapidly!</B></span>")
		for(var/i = 0, i < 5, i++)
			usr.pixel_y -= 4
			usr.set_dir(NORTH)
			T.TakeDamage("head", 1, 0)
			usr.visible_message("<span class='alert'><B>[usr] kicks [T] in the face!</B></span>", "<span class='alert'><B>You kick [T] in the face!</B></span>")
			playsound(T.loc, "swing_hit", 25, 1, -1)
			sleep(0.1 SECONDS)
			usr.set_dir(EAST)
			T.TakeDamage("head", 1, 0)
			usr.visible_message("<span class='alert'><B>[usr] kicks [T] in the face!</B></span>", "<span class='alert'><B>You kick [T] in the face!</B></span>")
			playsound(T.loc, "swing_hit", 25, 1, -1)
			sleep(0.1 SECONDS)
			usr.set_dir(SOUTH)
			T.TakeDamage("head", 1, 0)
			usr.visible_message("<span class='alert'><B>[usr] kicks [T] in the face!</B></span>", "<span class='alert'><B>You kick [T] in the face!</B></span>")
			playsound(T.loc, "swing_hit", 25, 1, -1)
			sleep(0.1 SECONDS)
			usr.set_dir(WEST)
			T.TakeDamage("head", 1, 0)
			usr.visible_message("<span class='alert'><B>[usr] kicks [T] in the face!</B></span>", "<span class='alert'><B>You kick [T] in the face!</B></span>")
			playsound(T.loc, "swing_hit", 25, 1, -1)
		usr.set_dir(get_dir(usr, T))
		usr.visible_message("<span class='alert'><B>[usr] stares deeply at [T]!</B></span>", "<span class='alert'><B>You stares deeply at [T]!</B></span>")
		sleep(0.8 SECONDS)
		usr.visible_message("<span class='alert'><B>[usr] unleashes a tremendous kick to the jaw towards [T]!</B></span>", "<span class='alert'><B>You unleash a tremendous kick to the jaw towards [T]!</B></span>")
		playsound(T.loc, "swing_hit", 25, 1, -1)
		batman_pow(T.loc)
		//flick("e_flash", T.flash)
		T.setStatus("weakened", T.getStatusDuration("weakened") + 6 SECONDS)
		step_away(T,usr,15)
		sleep(0.1 SECONDS)
		step_away(T,usr,15)
		sleep(0.1 SECONDS)
		step_away(T,usr,15)
		sleep(0.1 SECONDS)
		step_away(T,usr,15)
		sleep(0.1 SECONDS)
		step_away(T,usr,15)
		T.TakeDamage("head", 10, 0)
		for(var/i = 0, i < 5, i++)
			usr.pixel_y += 10
			sleep(0.1 SECONDS)
		usr.set_loc(T.loc)
		usr.setStatus("weakened", 10)
		for(var/i = 0, i < 5, i++)
			usr.pixel_y -= 8
			sleep(0.1 SECONDS)
		usr.pixel_y = 0
		usr.visible_message("<span class='alert'><B>[usr] elbow drops [T] into oblivion!</B></span>", "<span class='alert'><B>You elbow drop [T] into oblivion!</B></span>")
		batman_pow(T.loc)
		playsound(T.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 75, 1)
		random_brute_damage(T, 20)
		T.losebreath += 6
		T.setStatus("weakened", T.getStatusDuration("weakened") + 10 SECONDS)
		T.setStatus("stunned", T.getStatusDuration("stunned") + 10 SECONDS)
		T.force_laydown_standup()

/mob/proc/batspin(mob/T as mob in oview(1))
	set category = "Batman"
	set name = "Bat Spin \[Finisher]"
	set desc = "Grab someone and spin them around until they explode"

	SPAWN(0)
		usr.visible_message("<span class='alert'><B>[usr] grabs [T] tightly!</B></span>", "<span class='alert'><B>You grab [T] tightly!</B></span>")
		T.u_equip(l_hand)
		T.u_equip(r_hand)
		T.setStatus("stunned", T.getStatusDuration("stunned") + 15 SECONDS)
		T.force_laydown_standup()
		sleep(1 SECOND)
		usr.visible_message("<span class='alert'><B>[usr] starts spinning [T] around!</B></span>", "<span class='alert'><B>You start spinning [T] around!</B></span>")
		playsound(usr.loc, 'sound/effects/bionic_sound.ogg', 50)
		for(var/i = 0, i < 2, i++)
			T.set_dir(NORTH)
			sleep(0.5 SECONDS)
			T.set_dir(EAST)
			sleep(0.5 SECONDS)
			T.set_dir(SOUTH)
			sleep(0.5 SECONDS)
			T.set_dir(WEST)
			sleep(0.5 SECONDS)
		for(var/i = 0, i < 1, i++)
			T.set_dir(NORTH)
			sleep(0.2 SECONDS)
			T.set_dir(EAST)
			sleep(0.2 SECONDS)
			T.set_dir(SOUTH)
			sleep(0.2 SECONDS)
			T.set_dir(WEST)
			sleep(0.2 SECONDS)
		boutput(T, "<span class='alert'>YOU'RE GOING TOO FAST!!!</span>")
		for(var/i = 0, i < 10, i++)
			T.set_dir(NORTH)
			sleep(0.1 SECONDS)
			T.set_dir(EAST)
			sleep(0.1 SECONDS)
			T.set_dir(SOUTH)
			sleep(0.1 SECONDS)
			T.set_dir(WEST)
			sleep(0.1 SECONDS)
		playsound(usr.loc, 'sound/weapons/rocket.ogg', 50)
		usr.visible_message("<span class='alert'><B>[src] flings [T] with all of his might!</B></span>")
		T.force_laydown_standup()
		var/target_dir = get_dir(usr, T)
		sleep(0)
		if (T)
			walk(T, target_dir, 1)
			sleep(0.5 SECONDS)
			walk(T, 0)
			playsound(T.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 75, 1)
			random_brute_damage(T, 30)
			T.losebreath += 10
			T.setStatus("weakened", T.getStatusDuration("weakened") + 10 SECONDS)
			T.setStatus("stunned", T.getStatusDuration("stunned") + 10 SECONDS)
			T.visible_message("<span class='alert'><B>[T] lands very violently with a bone-crunching sound!</B></span>", "<span class='alert'><B>You land violently with a lot of pain!</B></span>")


/mob/proc/batdropkick(mob/T as mob in oview())
	set category = "Batman"
	set name = "Drop Kick \[Disabler]"
	set desc = "Fall to the ground, leap up and knock a dude out"

	usr.visible_message("<span class='alert'><B>[usr] drops to the ground, preparing for a jump</B>!</span>", "<span class='alert'><B>You drop to the ground, preparing for a jump</B>!</span>")
	playsound(usr.loc, 'sound/effects/bionic_sound.ogg', 50)
	usr.setStatus("weakened", 8 SECONDS)
	usr.force_laydown_standup()
	sleep(1.5 SECONDS)
	usr.visible_message("<span class='alert'><B>[usr] launches towards [T]</B>!</span>", "<span class='alert'><B>You launch towards [T]</B>!</span>")
	for(var/i=0, i<100, i++)
		step_to(usr,T,0)
		if (BOUNDS_DIST(usr, T) == 0)
			batman_pow(T.loc)
			T.setStatus("weakened", T.getStatusDuration("weakened") + 10 SECONDS)
			T.setStatus("stunned", T.getStatusDuration("stunned") + 10 SECONDS)
			usr.visible_message("<span class='alert'><B>[usr] flies at [T], slamming [him_or_her(usr)] in the head</B>!</span>", "<span class='alert'><B>You fly at [T], slamming [him_or_her(T)] in the head</B>!</span>")
			playsound(T.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 75, 1)
			random_brute_damage(T, 25)
			usr.delStatus("weakened")
			i=100
			var/turf/tturf = get_edge_target_turf(usr, get_dir(T, get_step_away(T, usr)))
			if(tturf && isturf(tturf))
				T.throw_at(tturf, 4, 2)
		sleep(0.1 SECONDS)

obj/item/batarang
	name = "Batarang"
	desc = "A metal boomerang in the shape of a bat, it looks sharp."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "batarang"

	force = 5
	contraband = 4

	throwforce = 8
	throw_range = 10
	throw_speed = 1
	throw_return = 1
	hitsound = 'sound/impact_sounds/Flesh_Stab_3.ogg'
	hit_type = DAMAGE_CUT


	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		..()
		if (ishuman(hit_atom))
			var/mob/living/carbon/human/H = hit_atom
			H.changeStatus("weakened", 1 SECONDS)
			H.force_laydown_standup()
			take_bleeding_damage(H, null, 10)
			playsound(src, hitsound, 60, 1)

		else
			return

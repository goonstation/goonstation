
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

			src.equip_new_if_possible(/obj/item/storage/backpack/, SLOT_BACK)
			src.equip_new_if_possible(/obj/item/clothing/shoes/swat, SLOT_SHOES)
			src.equip_new_if_possible(/obj/item/clothing/under/misc/lawyer, SLOT_W_UNIFORM)
			src.equip_new_if_possible(/obj/item/clothing/suit/armor/batman, SLOT_WEAR_SUIT)
			src.equip_new_if_possible(/obj/item/clothing/glasses/sunglasses/sechud, SLOT_GLASSES)
			src.equip_new_if_possible(/obj/item/clothing/gloves/yellow, SLOT_GLOVES)
			src.equip_new_if_possible(/obj/item/clothing/head/helmet/batman, SLOT_HEAD)
			src.equip_new_if_possible(/obj/item/clothing/mask/batman, SLOT_WEAR_MASK)
			src.equip_new_if_possible(/obj/item/storage/belt/security, SLOT_BELT)
			src.equip_new_if_possible(/obj/item/device/radio/headset/command, SLOT_EARS)
			src.equip_new_if_possible(/obj/item/card/id/syndicate, SLOT_WEAR_ID)
			src.equip_new_if_possible(/obj/item/handcuffs/tape_roll, SLOT_L_STORE)
			src.equip_new_if_possible(/obj/item/tank/emergency_oxygen, SLOT_R_STORE)

			src.equip_new_if_possible(/obj/item/storage/box/tactical_kit, SLOT_IN_BACKPACK)
			src.equip_new_if_possible(/obj/item/storage/medical_pouch, SLOT_IN_BACKPACK)
			src.equip_new_if_possible(/obj/item/storage/belt/syndicate_medic_belt, SLOT_IN_BACKPACK)
			src.equip_new_if_possible(/obj/item/breaching_charge/thermite, SLOT_IN_BACKPACK)
			src.equip_new_if_possible(/obj/item/breaching_charge/thermite, SLOT_IN_BACKPACK)
			src.equip_new_if_possible(/obj/item/storage/box/flashbang_kit, SLOT_IN_BACKPACK)

			src.equip_new_if_possible(/obj/item/tool/omnitool, SLOT_IN_BELT)
			src.equip_new_if_possible(/obj/item/clothing/glasses/thermal, SLOT_IN_BELT)
			src.equip_new_if_possible(/obj/item/gun/energy/pickpocket, SLOT_IN_BELT)

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

	playsound(usr, 'sound/weapons/launcher.ogg', 70, FALSE, 0)
	usr.visible_message(SPAN_ALERT("[usr] drops a smoke bomb!"), SPAN_ALERT("You drop a smoke bomb!"))

	var/datum/effects/system/bad_smoke_spread/smoke = new /datum/effects/system/bad_smoke_spread()
	smoke.set_up(10, 0, usr.loc)
	smoke.start()

/mob/proc/batarang(mob/T as mob in oview())
	set category = "Batman"
	set name = "Batarang \[Combat]"
	usr.visible_message(SPAN_ALERT("[usr] tosses a batarang at [T]!"), SPAN_ALERT("You toss a batarang at [T]!"))
	playsound(usr, pick('sound/effects/sword_unsheath1.ogg','sound/effects/sword_unsheath2.ogg'), 70, 0, 0)
	var/obj/overlay/A = new /obj/overlay( usr.loc )
	A.icon_state = "batarang"
	A.icon = 'icons/effects/effects.dmi'
	A.name = "a batarang"
	A.anchored = UNANCHORED
	A.set_density(0)
	var/i
	for(i=0, i<100, i++)
		step_to(A,T,0)
		if (GET_DIST(A,T) < 1)
			playsound(T, 'sound/impact_sounds/Blade_Small_Bloody.ogg', 70, FALSE, 0)
			random_brute_damage(T, 7)
			take_bleeding_damage(T, usr, 5, DAMAGE_STAB, 0)
			bleed(T, 3, 1)
			T.changeStatus("knockdown", 7 SECONDS)
			T.changeStatus("stunned", 7 SECONDS)
			T.visible_message(SPAN_ALERT("[T] was struck by the batarang!"), SPAN_ALERT("You were struck by a batarang!"))
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
		usr.visible_message(SPAN_ALERT("<B>[usr] powerfully kicks [T]!</B>"), SPAN_ALERT("<B>You kick [T]!</B>"))
		usr.emote("flip")
		playsound(usr.loc, "swing_hit", 40, 1)
		batman_pow(T.loc)
		T.setStatus("knockdown", T.getStatusDuration("knockdown") + 4 SECONDS)
		T.setStatus("stunned", T.getStatusDuration("stunned") + 4 SECONDS)
		T.force_laydown_standup()
		if(tturf && isturf(tturf))
			T.throw_at(tturf, 3, 2)

/mob/proc/batrevive()
	set category = "Batman"
	set name = "Recover \[Support]"
	set desc = "Unstuns you"

	if(usr.hasStatus("knockdown") || usr.hasStatus("stunned"))
		playsound(usr.loc, 'sound/effects/flip.ogg', 50, 1)
		usr.visible_message(SPAN_ALERT("<B>[usr] suddenly recovers!</B>"), SPAN_ALERT("<B>You suddenly recover!</B>"))
		usr.delStatus("knockdown")
		usr.delStatus("stunned")
		usr.emote("flip")

/obj/decal/batman_pow
	name = "POW!"
	anchored = ANCHORED
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
		boutput(usr, SPAN_ALERT("Not when you're incapped!"))
		return
	usr.visible_message(SPAN_ALERT("<B>[usr] bat-punches [T]!</B>"), SPAN_ALERT("<B>You bat-punch [T]!</B>"))
	playsound(usr.loc, "swing_hit", 40, 1)
	batman_pow(T.loc)
	var/zone = "chest"
	if(usr.zone_sel)
		zone = usr.zone_sel.selecting
	if ((zone in list( "eyes", "mouth" )))
		zone = "head"
	T.TakeDamage(zone, 4, 0)
	T.setStatus("knockdown", T.getStatusDuration("knockdown") + 3 SECONDS)
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
		boutput(usr, SPAN_ALERT("Not when you're incapped!"))
		return
	SPAWN(0)
		T.setStatus("stunned", 10 SECONDS)
		usr.visible_message(SPAN_ALERT("<B>[usr] leaps into the air, shocking [T]!</B>"), SPAN_ALERT("<B>You leap into the air, shocking [T]!</B>"))
		for(var/i = 0, i < 5, i++)
			usr.pixel_y += 4
			sleep(0.1 SECONDS)
		usr.visible_message(SPAN_ALERT("<B>[usr] begins kicking [T] in the face rapidly!</B>"), SPAN_ALERT("<B>You begin kicking [T] in the face rapidly!</B>"))
		for(var/i = 0, i < 5, i++)
			usr.pixel_y -= 4
			usr.set_dir(NORTH)
			T.TakeDamage("head", 1, 0)
			usr.visible_message(SPAN_ALERT("<B>[usr] kicks [T] in the face!</B>"), SPAN_ALERT("<B>You kick [T] in the face!</B>"))
			playsound(T.loc, "swing_hit", 25, 1, -1)
			sleep(0.1 SECONDS)
			usr.set_dir(EAST)
			T.TakeDamage("head", 1, 0)
			usr.visible_message(SPAN_ALERT("<B>[usr] kicks [T] in the face!</B>"), SPAN_ALERT("<B>You kick [T] in the face!</B>"))
			playsound(T.loc, "swing_hit", 25, 1, -1)
			sleep(0.1 SECONDS)
			usr.set_dir(SOUTH)
			T.TakeDamage("head", 1, 0)
			usr.visible_message(SPAN_ALERT("<B>[usr] kicks [T] in the face!</B>"), SPAN_ALERT("<B>You kick [T] in the face!</B>"))
			playsound(T.loc, "swing_hit", 25, 1, -1)
			sleep(0.1 SECONDS)
			usr.set_dir(WEST)
			T.TakeDamage("head", 1, 0)
			usr.visible_message(SPAN_ALERT("<B>[usr] kicks [T] in the face!</B>"), SPAN_ALERT("<B>You kick [T] in the face!</B>"))
			playsound(T.loc, "swing_hit", 25, 1, -1)
		usr.set_dir(get_dir(usr, T))
		usr.visible_message(SPAN_ALERT("<B>[usr] stares deeply at [T]!</B>"), SPAN_ALERT("<B>You stares deeply at [T]!</B>"))
		sleep(0.8 SECONDS)
		usr.visible_message(SPAN_ALERT("<B>[usr] unleashes a tremendous kick to the jaw towards [T]!</B>"), SPAN_ALERT("<B>You unleash a tremendous kick to the jaw towards [T]!</B>"))
		playsound(T.loc, "swing_hit", 25, 1, -1)
		batman_pow(T.loc)
		//flick("e_flash", T.flash)
		T.setStatus("knockdown", T.getStatusDuration("knockdown") + 6 SECONDS)
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
		usr.setStatus("knockdown", 10)
		for(var/i = 0, i < 5, i++)
			usr.pixel_y -= 8
			sleep(0.1 SECONDS)
		usr.pixel_y = 0
		usr.visible_message(SPAN_ALERT("<B>[usr] elbow drops [T] into oblivion!</B>"), SPAN_ALERT("<B>You elbow drop [T] into oblivion!</B>"))
		batman_pow(T.loc)
		playsound(T.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 75, 1)
		random_brute_damage(T, 20)
		T.losebreath += 6
		T.setStatus("knockdown", T.getStatusDuration("knockdown") + 10 SECONDS)
		T.setStatus("stunned", T.getStatusDuration("stunned") + 10 SECONDS)
		T.force_laydown_standup()

/mob/proc/batspin(mob/T as mob in oview(1))
	set category = "Batman"
	set name = "Bat Spin \[Finisher]"
	set desc = "Grab someone and spin them around until they explode"

	SPAWN(0)
		usr.visible_message(SPAN_ALERT("<B>[usr] grabs [T] tightly!</B>"), SPAN_ALERT("<B>You grab [T] tightly!</B>"))
		T.u_equip(l_hand)
		T.u_equip(r_hand)
		T.setStatus("stunned", T.getStatusDuration("stunned") + 15 SECONDS)
		T.force_laydown_standup()
		sleep(1 SECOND)
		usr.visible_message(SPAN_ALERT("<B>[usr] starts spinning [T] around!</B>"), SPAN_ALERT("<B>You start spinning [T] around!</B>"))
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
		boutput(T, SPAN_ALERT("YOU'RE GOING TOO FAST!!!"))
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
		usr.visible_message(SPAN_ALERT("<B>[src] flings [T] with all of his might!</B>"))
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
			T.setStatus("knockdown", T.getStatusDuration("knockdown") + 10 SECONDS)
			T.setStatus("stunned", T.getStatusDuration("stunned") + 10 SECONDS)
			T.visible_message(SPAN_ALERT("<B>[T] lands very violently with a bone-crunching sound!</B>"), SPAN_ALERT("<B>You land violently with a lot of pain!</B>"))


/mob/proc/batdropkick(mob/T as mob in oview())
	set category = "Batman"
	set name = "Drop Kick \[Disabler]"
	set desc = "Fall to the ground, leap up and knock a dude out"

	usr.visible_message(SPAN_ALERT("<B>[usr] drops to the ground, preparing for a jump</B>!"), SPAN_ALERT("<B>You drop to the ground, preparing for a jump</B>!"))
	playsound(usr.loc, 'sound/effects/bionic_sound.ogg', 50)
	usr.setStatus("knockdown", 8 SECONDS)
	usr.force_laydown_standup()
	sleep(1.5 SECONDS)
	usr.visible_message(SPAN_ALERT("<B>[usr] launches towards [T]</B>!"), SPAN_ALERT("<B>You launch towards [T]</B>!"))
	for(var/i=0, i<100, i++)
		step_to(usr,T,0)
		if (BOUNDS_DIST(usr, T) == 0)
			batman_pow(T.loc)
			T.setStatus("knockdown", T.getStatusDuration("knockdown") + 10 SECONDS)
			T.setStatus("stunned", T.getStatusDuration("stunned") + 10 SECONDS)
			usr.visible_message(SPAN_ALERT("<B>[usr] flies at [T], slamming [him_or_her(usr)] in the head</B>!"), SPAN_ALERT("<B>You fly at [T], slamming [him_or_her(T)] in the head</B>!"))
			playsound(T.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 75, 1)
			random_brute_damage(T, 25)
			usr.delStatus("knockdown")
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
			H.changeStatus("knockdown", 1 SECONDS)
			H.force_laydown_standup()
			take_bleeding_damage(H, null, 10)
			playsound(src, hitsound, 60, TRUE)

		else
			return

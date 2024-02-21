/client/proc/waldo_decoys()
	set category = "Spells"
	set name = "Summon Decoys"
	set desc = "Conjures up a distraction while you make a getaway."

	if(usr.stat)
		boutput(usr, "Not when you're incapacitated.")
		return

	usr.say("Now you see me, now you don't! Heh!")

	var/list/turfs = new/list()
	for(var/turf/T in orange(6))
		if(istype(T,/turf/space)) continue
		if(T.density) continue
		if(T.x>world.maxx-4 || T.x<4)	continue	//putting them at the edge is dumb
		if(T.y>world.maxy-4 || T.y<4)	continue
		turfs += T
	if(!turfs.len) turfs += pick(/turf in orange(6))
	var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
	smoke.set_up(10, 0, usr.loc)
	smoke.start()
	for(var/turf/T in range(1))
		SPAWN(0)
			new /mob/living/carbon/human/fake_waldo(T)
	var/turf/picked = pick(turfs)
	if(!isturf(picked)) return
	usr.set_loc(picked)
	usr.verbs -= /client/proc/waldo_decoys
	SPAWN(30 SECONDS)
		usr.verbs += /client/proc/waldo_decoys

/client/proc/mass_teleport()
	set category = "Spells"
	set name = "Mass Teleport"
	set desc = "Teleport yourself and your friends to an area of your choice."

	if(usr.stat)
		boutput(usr, "Not when you're incapacitated.")
		return
	if(!istype(usr:wear_suit, /obj/item/clothing/suit/wizrobe))
		boutput(usr, "You don't feel strong enough without a magical robe.")
		return
	if(!istype(usr:head, /obj/item/clothing/head/wizard))
		boutput(usr, "You don't feel strong enough without a magical hat.")
		return


	var/SPcool = 3000
	if (usr.wizard_spellpower(null)) SPcool = 600

	var/A
	usr.verbs -= /client/proc/mass_teleport
	SPAWN(SPcool)
		usr.verbs += /client/proc/mass_teleport

	var/list/theareas = new/list()
	for(var/area/AR in world)
		LAGCHECK(LAG_LOW)
		if(AR.name in theareas) continue
		var/turf/picked = pick(get_area_turfs(AR.type))
		if (picked.z == usr.z)
			theareas += AR.name
			theareas[AR.name] = AR

	A = input("Area to jump to", "BOOYEA", A) in theareas
	var/area/thearea = theareas[A]

	var/atom/movable/overlay/animation = null
	usr.buckled = usr.loc
	animation = new(usr.loc)
	animation.icon_state = "enshield"
	animation.icon = 'icons/effects/effects.dmi'
	animation.master = usr

	sleep(3 SECONDS)
	qdel(animation)
	usr.buckled = null
	if(!usr.stat)
		var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
		smoke.set_up(5, 0, usr.loc)
		smoke.attach(usr)
		smoke.start()
		var/list/L = list()
		for(var/turf/T in get_area_turfs(thearea.type))
			if(T.z != usr.z) continue
			if(!T.density)
				var/clear = 1
				for(var/obj/O in T)
					if(O.density)
						clear = 0
						break
				if(clear)
					L+=T

		var/list/mob/teleportees = list()
		for(var/mob/living/M in orange(usr, 4))
			if(!isdead(M) && M.mind && (M.mind.special_role in list("waldo", "odlaw", ROLE_WIZARD)))
				teleportees.Add(M)

		usr.set_loc(pick(L))
		var/list/turf/dest_turfs = list()
		for(var/turf/T in orange(usr, 1))
			if(T.density) continue
			dest_turfs.Add(T)
		for(var/mob/M in teleportees)
			M.set_loc(pick(dest_turfs))
		smoke.start()

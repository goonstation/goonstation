#define EVENT_ATTACHMENT_POINT_NONE 0
#define EVENT_ATTACHMENT_POINT_MELEE 1
#define EVENT_ATTACHMENT_POINT_ATTACKED 2

/proc/loadCustomCritterFromFile(var/target_name)
	var/target
	if (!isfile(target_name))
		target = file(target_name)
	else
		target = target_name
	if (!target)
		return null
	var/fname = "adventure/CRIT_LOAD_CUSTOMFILE"
	if (fexists(fname))
		fdel(fname)
	var/savefile/F = new /savefile(fname)
	F.dir.len = 0
	F.eof = -1
	boutput(F, null)
	F.ImportText("/", file2text(target))
	if (!F)
		boutput(usr, "<span class='alert'>Import failed.</span>")
	else
		var/datum/sandbox/S = new()
		var/obj/critter/custom/template = new()
		template.deserialize(F, "critter", S)
		template.is_template = 1
		if (fexists(fname))
			fdel(fname)
		return template

/obj/critter/custom
	name = "custom critter"
	desc = "custom critter"
	icon_state = "floateye"
	var/suspend_ai = 0
	var/melee = 1
	var/attack_power = 15
	var/attack_type = "brute"
	var/stun_prob = 20
	var/anger_text = "%src% charges at %target%!"
	chase_text = "%src% slams into %target%!"
	var/stun_text = "%src% knocks down %target%!"
	var/stun_fail_text = "%src% fails to knock down %target%!"
	var/attack_text = "%src% bashes %target%!"
	var/gib_corpses = 0

	var/sound/anger_sound
	var/sound/chase_sound
	var/sound/stun_sound
	var/sound/stun_fail_sound
	var/sound/attack_sound
	var/sound/death_sound
	var/sound/ambient_sound

	brutevuln = 1
	firevuln = 1
	var/explosivevuln = 1

	var/datum/critterDeath/on_death = null
	var/list/abil = list()
	var/datum/critterLootTable/loot_table = null

	var/dead_change_icon
	var/icon/dead_icon
	var/dead_icon_state

	New()
		..()
		loot_table = new()

	var/list/events = list()

	ex_act(severity)
		if (src.sleeping)
			sleeping = 0
			on_wake()

		switch(severity)
			if(1)
				src.health -= 200 * explosivevuln
				if (src.health <= 0)
					src.CritterDeath()
				return
			if(2)
				src.health -= 75 * explosivevuln
				if (src.health <= 0)
					src.CritterDeath()
				return
			else
				src.health -= 25 * explosivevuln
				if (src.health <= 0)
					src.CritterDeath()
				return

	process()
		if (suspend_ai)
			return
		..()
		if (is_template || !alive)
			return
		if (prob(25))
			play_optional_sound(ambient_sound)
		for (var/datum/critterAbility/A in abil)
			A.tick()
		if (on_death)
			on_death.tick()

	attackby(obj/item/W, mob/living/user)
		..()
		if (W.force || istype(W, /obj/item/artifact/melee_weapon))
			for (var/datum/critterEvent/E in events)
				if (E.attachment_point == EVENT_ATTACHMENT_POINT_ATTACKED)
					E.trigger()

	seek_target()
		src.anchored = initial(src.anchored)
		if (src.target)
			src.task = "chasing"
			return

		for (var/mob/living/C in hearers(src.seekrange,src))
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			if (iscarbon(C) && !src.atkcarbon) continue
			if (issilicon(C) && !src.atksilicon) continue
			if (C.health < 0) continue
			if (C in src.friends) continue
			if (ishuman(C))
				if (C.bioHolder?.HasEffect("revenant"))
					continue
			if (C.name == src.attacker) src.attack = 1
			if (iscarbon(C) && src.atkcarbon) src.attack = 1
			if (issilicon(C) && src.atksilicon) src.attack = 1

			if (src.attack)
				src.target = C
				src.oldtarget_name = C.name
				tokenized_message(anger_text, target)
				play_optional_sound(anger_sound)
				src.task = "chasing"
				on_grump()
				break
			else
				continue

	ChaseAttack(mob/M)
		if (!melee)
			return
		tokenized_message(chase_text, target)
		play_optional_sound(chase_sound)
		if (stun_prob)
			SPAWN(1 SECOND)
				if (BOUNDS_DIST(src, target) == 0)
					if (prob(stun_prob))
						M.changeStatus("stunned", 3 SECONDS)
						tokenized_message(stun_text, target)
						play_optional_sound(stun_sound)
					else
						tokenized_message(stun_fail_text, target)
						play_optional_sound(stun_fail_sound)

	proc/dodamage(var/mob/M, var/atype, var/damage)
		switch (atype)
			if ("brute")
				random_brute_damage(src.target, damage,1)
			if ("burn")
				random_burn_damage(src.target, damage)
			if ("toxin")
				M.take_toxin_damage(damage)
			if ("suffocation")
				M.take_oxygen_deprivation(damage)
			if ("radiation")
				M.take_radiation_dose(damage)

	CritterAttack(mob/N)
		if (!melee)
			return
		src.attacking = 1
		tokenized_message(attack_text, target)
		play_optional_sound(attack_sound)
		var/damage = max(rand(attack_power), rand(attack_power))
		var/mob/M = target
		dodamage(M, attack_type, damage)
		for (var/datum/critterEvent/E in events)
			if (E.attachment_point == EVENT_ATTACHMENT_POINT_MELEE)
				E.trigger()
		SPAWN(2.5 SECONDS)
			src.attacking = 0

	CritterDeath()
		if (!src.alive)
			return
		..()
		loot_table.drop()
		if (dead_change_icon)
			icon = dead_icon
			icon_state = dead_icon_state
		else // ughh, admins and their custom critters
			src.icon_state = replacetext(src.icon_state, "-dead", "") //can't assume it's going to have a dead state...
		play_optional_sound(death_sound)
		if (on_death)
			on_death.doOnDeath()

	clone()
		var/obj/critter/custom/C = ..()
		C.melee = melee
		C.attack_power = attack_power
		C.attack_type = attack_type
		C.stun_prob = stun_prob
		C.anger_text = anger_text
		C.chase_text = chase_text
		C.stun_text = stun_text
		C.stun_fail_text = stun_fail_text
		C.attack_text = attack_text
		C.gib_corpses = gib_corpses
		C.death_text = death_text
		C.explosivevuln = explosivevuln
		C.dead_icon = dead_icon
		C.dead_icon_state = dead_icon_state
		C.dead_change_icon = dead_change_icon
		C.anger_sound = anger_sound
		C.chase_sound = chase_sound
		C.stun_sound = stun_sound
		C.stun_fail_sound = stun_fail_sound
		C.attack_sound = attack_sound
		C.death_sound = death_sound
		C.ambient_sound = ambient_sound
		C.loot_table = loot_table.clone()
		C.loot_table.C = C
		if (on_death)
			C.on_death = on_death.clone()
			C.on_death.C = C

		C.abil.len = length(abil)
		for (var/i = 1, i <= abil.len, i++)
			var/datum/critterAbility/A = abil[i]
			if (istype(A))
				var/datum/critterAbility/B = A.clone()
				C.abil[i] = B
				B.attach(C)
				B.C = C
		return C

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].melee"] << melee
		F["[path].attack_power"] << attack_power
		F["[path].attack_type"] << attack_type
		F["[path].stun_prob"] << stun_prob
		F["[path].anger_text"] << anger_text
		F["[path].chase_text"] << chase_text
		F["[path].stun_text"] << stun_text
		F["[path].stun_fail_text"] << stun_fail_text
		F["[path].attack_text"] << attack_text
		F["[path].gib_corpses"] << gib_corpses
		F["[path].death_text"] << death_text
		F["[path].anger_sound"] << anger_sound
		F["[path].chase_sound"] << chase_sound
		F["[path].stun_sound"] << stun_sound
		F["[path].stun_fail_sound"] << stun_fail_sound
		F["[path].attack_sound"] << attack_sound
		F["[path].death_sound"] << death_sound
		F["[path].ambient_sound"] << ambient_sound
		F["[path].explosivevuln"] << explosivevuln
		F["[path].dead_change_icon"] << dead_change_icon
		icon_serializer(F, "[path].dead_icon", sandbox, dead_icon, dead_icon_state)
		loot_table.serialize(F, "[path].loot_table", sandbox)
		F["[path].abil.LEN"] << length(abil)
		if (on_death)
			F["[path].on_death.type"] << on_death.type
			on_death.serialize(F, "[path].on_death", sandbox)
		for (var/i = 1, i <= abil.len, i++)
			var/datum/critterAbility/A = abil[i]
			if (istype(A))
				F["[path].abil.[i].type"] << A.type
				A.serialize(F, "[path].abil.[i]", sandbox)

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].melee"] >> melee
		F["[path].attack_power"] >> attack_power
		F["[path].attack_type"] >> attack_type
		F["[path].stun_prob"] >> stun_prob
		F["[path].anger_text"] >> anger_text
		F["[path].chase_text"] >> chase_text
		F["[path].stun_text"] >> stun_text
		F["[path].stun_fail_text"] >> stun_fail_text
		F["[path].attack_text"] >> attack_text
		F["[path].gib_corpses"] >> gib_corpses
		F["[path].death_text"] >> death_text
		F["[path].explosivevuln"] >> explosivevuln
		F["[path].anger_sound"] >> anger_sound
		F["[path].chase_sound"] >> chase_sound
		F["[path].stun_sound"] >> stun_sound
		F["[path].stun_fail_sound"] >> stun_fail_sound
		F["[path].attack_sound"] >> attack_sound
		F["[path].death_sound"] >> death_sound
		F["[path].ambient_sound"] >> ambient_sound
		F["[path].dead_change_icon"] >> dead_change_icon
		var/datum/iconDeserializerData/IDS = icon_deserializer(F, "[path].dead_icon", sandbox, dead_icon, dead_icon_state)
		dead_icon = IDS.icon
		dead_icon_state = IDS.icon_state
		loot_table = new()
		loot_table.deserialize(F, "[path].loot_table", sandbox)
		loot_table.C = src
		var/odt
		F["[path].on_death.type"] >> odt
		if (odt)
			on_death = new odt()
			on_death.deserialize(F, "[path].on_death", sandbox)
			on_death.C = src
		var/abs
		F["[path].abil.LEN"] >> abs
		abil.len = abs
		for (var/i = 1, i <= abil.len, i++)
			var/T
			F["[path].abil.[i].type"] >> T
			if (T)
				var/datum/critterAbility/A = new T()
				if (istype(A))
					A.deserialize(F, "[path].abil.[i]", sandbox)
					A.attach(src)
					abil[i] = A
				else
					logTheThing(LOG_DEBUG, null, "<b>Marquesas/CritterCreator:</b> Cannot deserialize type [T].")

	proc/play_optional_sound(var/sound/sound)
		if (sound)
			playsound(src, sound, 50, 1)

	proc/addUntiedEvent(var/datum/critterEvent/E)
		events += E
		E.attachment_point = EVENT_ATTACHMENT_POINT_NONE

	proc/addAttackEvent(var/datum/critterEvent/E)
		events += E
		E.attachment_point = EVENT_ATTACHMENT_POINT_MELEE

/datum/critterCreatorHolder
	var/list/critterCreators = list()
	var/list/activeCritterTypes = list()

	proc/blank(var/mob/M)
		if (!M.client)
			boutput(M, "<span class='alert'>Hello.</span>")
			return 0
		// look I think it's okay if you maybe let non-admins access this sometimes
		/*if (!M.client.holder)
			boutput(M, "<span class='alert'>What are you doing here?</span>")
			return 0
		if (M.client.holder.level < LEVEL_PA)
			boutput(M, "<span class='alert'>You must be at least PA to use this.</span>")
			return 0*/
		var/key = M.ckey
		if (!(key in critterCreators))
			critterCreators += key
		critterCreators[key] = new /datum/critterCreator

	proc/getCreator(var/mob/M)
		var/key = M.ckey
		if (!(key in critterCreators))
			if (!blank(M))
				return null
		return critterCreators[key]

var/global/datum/critterCreatorHolder/critter_creator_controller = new()

/datum/critterLoot
	var/datum/critterLootTable/lootTable
	var/dropped = null
	var/amount = 1
	var/chance = 100

	proc/configuration(var/datum/critterCreator/configurer)
		. = configurer.clickable_link("lootamount", amount, "0", "\ref[src]")
		. += " "
		. += configurer.clickable_link("lootdropped", configurer.stripPath(dropped), "(null)", "\ref[src]")
		. += " ("
		. += configurer.clickable_link("lootchance", "[chance]%", "0%", "\ref[src]")
		. += ") "
		. += configurer.clickable_link("lootremove", "(remove)", "(remove)", "\ref[src]")

	proc/change_configuration(var/datum/critterCreator/configurer, var/which)
		switch (which)
			if ("amount")
				amount = configurer.getNum("dropped amount", amount)
			if ("dropped")
				var/filter = configurer.getText("enter part of the pathname of the dropped object", "")
				var/typename = get_one_match(filter, /obj/item)
				if (typename)
					dropped = typename
			if ("chance")
				chance = configurer.getNum("drop chance", chance)
			if ("remove")
				lootTable.loot -= src
				qdel(src)

	proc/clone()
		var/datum/critterLoot/L = new type()
		L.dropped = dropped
		L.amount = amount
		L.chance = chance
		return L

	proc/serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		F["[path].dropped"] << dropped
		F["[path].amount"] << amount
		F["[path].chance"] << chance

	proc/deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		F["[path].dropped"] >> dropped
		F["[path].amount"] >> amount
		F["[path].chance"] >> chance

	proc/drop(var/max = -1)
		if (!dropped)
			return 0
		if (amount < 1)
			return 0
		if (prob(chance))
			for (var/i = 1, i <= amount && (i <= max || max == -1), i++)
				new dropped(get_turf(lootTable.C))
			return amount
		return 0

/datum/critterLootTable
	var/maxDropped = 2
	var/list/loot = list()
	var/obj/critter/custom/C

	proc/configuration(var/datum/critterCreator/configurer)
		. = "<strong>Loot table dropping up to "
		. += configurer.clickable_link("loottable", "[maxDropped] [maxDropped == 1 ? "item" : "items"]", "0 items", "maxDropped")
		. += ":</strong><br/><ul>"
		for (var/i = 1, i <= loot.len, i++)
			var/datum/critterLoot/L = loot[i]
			. += "<li>"
			. += L.configuration(configurer)
			. += "</li>"
		. += "<li>"
		. += configurer.clickable_link("loottable", "(add new)", "(add new)", "addNew")
		. += "</ul>"

	proc/change_configuration(var/datum/critterCreator/configurer, var/which)
		switch (which)
			if ("maxDropped")
				maxDropped = configurer.getNum("maximum dropped amount", maxDropped)
			if ("addNew")
				var/datum/critterLoot/L = new()
				L.lootTable = src
				loot += L

	proc/clone()
		var/datum/critterLootTable/LT = new type()
		LT.maxDropped = maxDropped
		LT.loot.len = length(loot)
		for (var/i = 1, i <= loot.len, i++)
			var/datum/critterLoot/L = loot[i]
			var/datum/critterLoot/L2 = L.clone()
			L2.lootTable = LT
			LT.loot[i] = L2
		return LT

	proc/serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		F["[path].maxDropped"] << maxDropped
		F["[path].loot.LEN"] << length(loot)
		for (var/i = 1, i <= loot.len, i++)
			var/datum/critterLoot/L = loot[i]
			L.serialize(F, "[path].loot.[i]", sandbox)

	proc/deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		F["[path].maxDropped"] >> maxDropped
		var/lootc
		F["[path].loot.LEN"] >> lootc
		loot.len = lootc
		for (var/i = 1, i <= loot.len, i++)
			var/datum/critterLoot/L = new()
			L.deserialize(F, "[path].loot.[i]", sandbox)
			loot[i] = L
			L.lootTable = src

	proc/drop()
		var/CD = maxDropped
		for (var/datum/critterLoot/L in loot)
			CD -= L.drop(CD)
			if (CD <= 0)
				return

/datum/critterDeath
	var/name = "do nothing"
	var/obj/critter/custom/C

	proc/configuration(var/datum/critterCreator/configurer)
		return ""

	proc/change_configuration(var/datum/critterCreator/configurer, var/which)
		return

	proc/tick()
		return

	proc/clone()
		return new type()

	proc/serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		return

	proc/deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		return

	proc/doOnDeath()
		return

/datum/critterDeath/gib
	name = "gib"
	var/gibtype = 1

	configuration(var/datum/critterCreator/configurer)
		. = "<span class='attribute-name'>Gib type: </span>"
		. += configurer.clickable_link("deathconf", gibtype ? "organic" : "machine", "machine", "gibtype")

	change_configuration(var/datum/critterCreator/configurer, var/which)
		if (which == "gibtype")
			gibtype = !gibtype

	clone()
		var/datum/critterDeath/gib/D = ..()
		D.gibtype = gibtype
		return D

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		F["[path].gibtype"] << gibtype

	deserialize(var/savefile/F, path, var/datum/sandbox/sandbox)
		F["[path].gibtype"] >> gibtype

	doOnDeath()
		if (gibtype)
			gibs(C.loc, list())
		else
			robogibs(C.loc, list())
		qdel(C)

/datum/critterDeath/explode
	name = "explode"
	var/power = 5
	var/delay = 20

	configuration(var/datum/critterCreator/configurer)
		. = "<span class='attribute-name'>Creates an explosion of power </span>"
		. += configurer.clickable_link("deathconf", power, "0", "power")
		. += "<span class='attribute-name'> after a delay of </span>"
		. += configurer.clickable_link("deathconf", delay / 10, "0", "delay")
		. += " seconds."

	change_configuration(var/datum/critterCreator/configurer, var/which)
		switch(which)
			if ("power")
				power = configurer.getNum("explosion power", power)
			if ("delay")
				delay = configurer.getNum("explosion delay in 1/10th of seconds", delay)

	clone()
		var/datum/critterDeath/explode/D = ..()
		D.power = power
		D.delay = delay
		return D

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		F["[path].power"] << power
		F["[path].delay"] << delay

	deserialize(var/savefile/F, path, var/datum/sandbox/sandbox)
		F["[path].power"] >> power
		F["[path].delay"] >> delay

	doOnDeath()
		var/L = C.loc
		SPAWN(delay)
			explosion_new(C, L, power)
			qdel(C)

/datum/critterDeath/smoke
	name = "vaporize into smoke"
	var/reagent = "water"
	var/delay = 20

	configuration(var/datum/critterCreator/configurer)
		. = "<span class='attribute-name'>Becomes a puff of </span>"
		. += configurer.clickable_link("deathconf", reagent, "0", "reagent")
		. += "<span class='attribute-name'> after a delay of </span>"
		. += configurer.clickable_link("deathconf", delay / 10, "0", "delay")
		. += " seconds."

	change_configuration(var/datum/critterCreator/configurer, var/which)
		switch(which)
			if ("reagent")
				reagent = configurer.getText("smoked reagent", reagent)
			if ("delay")
				delay = configurer.getNum("explosion delay in 1/10th of seconds", delay)

	clone()
		var/datum/critterDeath/smoke/D = ..()
		D.reagent = reagent
		D.delay = delay
		return D

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		F["[path].reagent"] << reagent
		F["[path].delay"] << delay

	deserialize(var/savefile/F, path, var/datum/sandbox/sandbox)
		F["[path].reagent"] >> reagent
		F["[path].delay"] >> delay

	doOnDeath()
		var/L = C.loc
		SPAWN(delay)
			var/datum/reagents/holder = new()
			holder.my_atom = C
			holder.add_reagent(reagent, 50)
			smoke_reaction(holder, 4, L)
			qdel(C)

/datum/critterEvent
	var/name = "never"
	var/datum/critterAbility/attached
	var/abstract = 0
	var/configured = 0
	var/obj/critter/custom/C = null
	var/attachment_point = EVENT_ATTACHMENT_POINT_NONE

	proc/onAttach(var/obj/critter/custom/CR)
		C = CR
		C.addUntiedEvent(src)

	proc/varChanged(var/varname, var/oldvalue, var/newvalue)
		return

	proc/tick()
		return

	proc/change_configuration(var/datum/critterCreator/configurer, var/which)
		return

	proc/trigger()
		attached.use()

	proc/configuration(var/datum/critterCreator/configurer)
		return ""

	proc/clone()
		return new type()

	proc/serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		return

	proc/deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		return

/datum/critterEvent/always
	name = "when available"

	tick()
		..()
		trigger()

/datum/critterEvent/mobsInView
	name = "when there are living mobs in view"
	configured = 1
	abstract = 0
	var/atLeast = 1

	tick()
		..()
		var/count = 0
		for (var/mob/M in view(7, C))
			if (isliving(M))
				if (!isdead(M))
					count++
		if (count >= atLeast)
			trigger()

	configuration(var/datum/critterCreator/configurer)
		return "at least " + configurer.clickable_link("abilevent", atLeast, "0", "atLeast")

	change_configuration(var/datum/critterCreator/configurer, var/which)
		if (which == "atLeast")
			atLeast = configurer.getNum("mob count", atLeast)

	clone()
		var/datum/critterEvent/mobsInView/E = ..()
		E.atLeast = atLeast
		return E

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].atLeast"] << atLeast

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].atLeast"] >> atLeast

/datum/critterEvent/melee
	name = "when melee attacking"

	onAttach(var/obj/critter/custom/CR)
		C = CR
		C.addAttackEvent(src)

/datum/critterEvent/varCrossed
	var/matchVar = null     // the variable to listen to, for example health
	var/crossDirection = -1 // -1 : when crossing downwards, 1: when crossing upwards, 0: any direction
	var/threshold = 50      // the threshold the variable needs to cross in the chosen direction to trigger
	var/is_percentage = 1   // if 1, threshold is interpreted as a percentage value instead of an absolute one
	abstract = 1
	var/last_value = 0
	var/RT
	// 100% is the value of the variable at the time of attachment

	onAttach(var/obj/critter/custom/CR)
		if (!(matchVar in CR.vars))
			CRASH("Cannot attach event to [CR]: [matchVar] does not exist.")
		..()
		if (matchVar && is_percentage)
			var/mult = threshold / 100
			RT = C.vars[matchVar] * mult
			last_value = C.vars[matchVar]
		else
			RT = threshold

	varChanged(var/varname, var/oldvalue, var/newvalue)
		if (varname == matchVar)
			if (crossDirection >= 0 && oldvalue < RT && RT < newvalue)
				trigger()
			else if (crossDirection <= 0 && oldvalue > RT && RT > newvalue)
				trigger()

/datum/critterEvent/varCrossed/health
	name = "when health drops below percentage"
	abstract = 0
	matchVar = "health"
	crossDirection = -1
	threshold = 0
	is_percentage = 1
	configured = 1

	configuration(var/datum/critterCreator/configurer)
		return configurer.clickable_link("abilevent", threshold, "0", "threshold") + "%"

	change_configuration(var/datum/critterCreator/configurer, var/which)
		if (which == "threshold")
			threshold = configurer.getNum("threshold percentage", threshold)

	clone()
		var/datum/critterEvent/varCrossed/health/E = ..()
		E.threshold = threshold
		return E

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].threshold"] << threshold

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].threshold"] >> threshold

/datum/critterEvent/varIs
	var/matchVar = null     // the variable to listen to, for example health
	var/direction = -1      // -1 : below threshold, 1: greater than threshold, 0: equals threshold
	var/threshold = 50      // the threshold the variable needs to relate to in the chosen direction to trigger
	var/is_percentage = 1   // if 1, threshold is interpreted as a percentage value instead of an absolute one
	var/real_threshold
	abstract = 1
	// 100% is the value of the variable at the time of attachment

	onAttach(var/obj/critter/custom/CR)
		if (!(matchVar in CR.vars))
			CRASH("Cannot attach event to [CR]: [matchVar] does not exist.")
		..()
		if (matchVar && is_percentage)
			var/mult = threshold / 100
			real_threshold = C.vars[matchVar] * mult
		else if (matchVar)
			real_threshold = threshold

	tick()
		var/newvalue = C.vars[matchVar]
		if (direction > 0 && newvalue > real_threshold)
			trigger()
		else if (direction < 0 && newvalue < real_threshold)
			trigger()
		else if (direction == 0 && newvalue == real_threshold)
			trigger()

/datum/critterEvent/varRange
	var/matchVar = null     // the variable to listen to, for example health
	var/minimum = 20        // the variable must be greater than this
	var/maximum = 50        // the variable must be less than this
	var/is_percentage = 1   // if 1, threshold is interpreted as a percentage value instead of an absolute one
	var/RM
	var/RX
	abstract = 1
	// 100% is the value of the variable at the time of attachment

	onAttach(var/obj/critter/custom/CR)
		if (!(matchVar in CR.vars))
			CRASH("Cannot attach event to [CR]: [matchVar] does not exist.")
		..()
		if (matchVar && is_percentage)
			var/mult = minimum / 100
			RM = C.vars[matchVar] * mult
			mult = maximum / 100
			RX = C.vars[matchVar] * mult
		else
			RM = minimum
			RX = maximum

	tick()
		var/newvalue = C.vars[matchVar]
		if (RM <= newvalue && newvalue < RX)
			trigger()

/datum/critterEvent/varRange/health
	name = "when health is within percentage range"
	configured = 1

	change_configuration(var/datum/critterCreator/configurer, var/which)
		if (which == "minimum")
			minimum = configurer.getNum("minimum percentage", minimum)
		else if (which == "maximum")
			maximum = configurer.getNum("minimum percentage", maximum)

	configuration(var/datum/critterCreator/configurer)
		return configurer.clickable_link("abilevent", minimum, "0", "minimum") + "% - " + configurer.clickable_link("abilevent", maximum, "0", "maximum") + "%"

	clone()
		var/datum/critterEvent/varRange/health/E = ..()
		E.minimum = minimum
		E.maximum = maximum
		return E

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].minimum"] << minimum
		F["[path].maximum"] << maximum

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].minimum"] >> minimum
		F["[path].maximum"] >> maximum

/datum/critterEvent/varIs/healthLow
	name = "when health is below percentage"
	abstract = 0
	matchVar = "health"
	direction = -1
	threshold = 0
	is_percentage = 1
	configured = 1

	change_configuration(var/datum/critterCreator/configurer, var/which)
		if (which == "threshold")
			threshold = configurer.getNum("threshold percentage", threshold)

	configuration(var/datum/critterCreator/configurer)
		return configurer.clickable_link("abilevent", threshold, "0", "threshold") + "%"

	clone() // boy i sure do miss implicit copy constructors
		var/datum/critterEvent/varIs/healthLow/E = ..()
		E.threshold = threshold
		return E

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].threshold"] << threshold

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].threshold"] >> threshold

/datum/critterEvent/varIs/healthHigh
	name = "when health is above percentage"
	abstract = 0
	matchVar = "health"
	direction = -1
	threshold = 0
	is_percentage = 1
	configured = 1

	change_configuration(var/datum/critterCreator/configurer, var/which)
		if (which == "threshold")
			threshold = configurer.getNum("threshold percentage", threshold)

	configuration(var/datum/critterCreator/configurer)
		return configurer.clickable_link("abilevent", threshold, "0", "threshold") + "%"

	clone()
		var/datum/critterEvent/varIs/healthHigh/E = ..()
		E.threshold = threshold
		return E

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].threshold"] << threshold

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].threshold"] >> threshold

/datum/critterAbility
	var/name = "Ability"
	var/datum/critterEvent/event
	var/chance = 50
	var/cooldown = 20
	var/next_usable = 0
	var/abstract = 1
	var/obj/critter/custom/C
	var/static/list/events_cache = list()

	proc/serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		F["[path].chance"] << chance
		F["[path].cooldown"] << cooldown
		if (event)
			F["[path].event.type"] << event.type
			event.serialize(F, "[path].event", sandbox)

	proc/deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		F["[path].chance"] >> chance
		F["[path].cooldown"] >> cooldown
		var/ET
		F["[path].event.type"] >> ET
		if (ET)
			event = new ET()
			event.deserialize(F, "[path].event", sandbox)
			event.attached = src
		else
			logTheThing(LOG_DEBUG, "usr", "<b>Marquesas/CritterCreator: </b> Failed to deserialize event for ability.")

	proc/attach(var/obj/critter/custom/CR)
		C = CR
		if (event)
			event.onAttach(C)

	proc/tick()
		if (event)
			event.tick()

	proc/clone()
		var/datum/critterAbility/copy = new type()
		copy.chance = chance
		copy.cooldown = cooldown
		if (event)
			copy.event = event.clone()
			copy.event.attached = copy
		return copy

	proc/use()
		if (check_if_usable())
			if (use_ability())
				put_on_cooldown()

	proc/check_if_usable()
		if (!prob(chance))
			return 0
		if (next_usable > world.time)
			return 0
		return 1

	proc/put_on_cooldown()
		next_usable = world.time + cooldown

	proc/use_ability()
		return 0

	proc/build_events_cache()
		for (var/evtype in typesof(/datum/critterEvent))
			var/datum/critterEvent/ev = new evtype()
			if (ev.abstract)
				qdel(ev)
			else
				events_cache += ev

	proc/change_configuration(var/datum/critterCreator/configurer, var/which)
		switch(which)
			if ("event")
				if (!events_cache.len)
					build_events_cache()
				var/datum/critterEvent/ev = input("Which event?", "Event", null) in events_cache
				if (event)
					if (ev.type == event.type)
						return
					qdel(event)
				event = ev.clone()
				event.attached = src
			if ("chance")
				chance = configurer.getNum("ability usage chance", chance)
			if ("cooldown")
				cooldown = configurer.getNum("ability cooldown in 1/10th of seconds", cooldown)

	proc/configuration(var/datum/critterCreator/configurer)
		var/output = "<span class='attribute-name'>Ability: </span>"
		output += configurer.clickable_link("abilchange", src, "none")
		output += "<br><span class='attribute-name'>Use this ability </span>"
		output += configurer.clickable_link("abilconf", event, "never", "event")
		if (event)
			if (event.configured)
				output += " ([event.configuration(configurer)])"
		output += "<br><span class='attribute-name'>with a probability of </span>"
		output += configurer.clickable_link("abilconf", chance, "0", "chance")
		output += "%<br><span class='attribute-name'>and cooldown of </span>"
		output += configurer.clickable_link("abilconf", cooldown / 10, "0", "cooldown")
		output += " seconds.<br>"
		return output

/datum/critterAbility/criticalStrike
	name = "critical strike"
	var/bonus_damage = 5
	var/critical_text = "%src% critically hits %target%!"
	var/sound/critical_sound
	var/melee = 1
	abstract = 0

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].bonus_damage"] << bonus_damage
		F["[path].critical_text"] << critical_text
		F["[path].melee"] << melee
		F["[path].critical_sound"] << critical_sound

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].bonus_damage"] >> bonus_damage
		F["[path].critical_text"] >> critical_text
		F["[path].melee"] >> melee
		F["[path].critical_sound"] >> critical_sound

	use_ability()
		if (C.target && ismob(C.target))
			var/mob/M = C.target
			if (melee && GET_DIST(C, M) > C.attack_range)
				return 0
			C.tokenized_message(critical_text, M)
			C.play_optional_sound(critical_sound)
			M.TakeDamageAccountArmor("chest", bonus_damage, 0)
			return 1
		else
			logTheThing(LOG_DEBUG, null, "<b>Marquesas/CritterCreator: </b> Cannot reagent inject target, target is [C.target].")
			return 0

	change_configuration(var/datum/critterCreator/configurer, var/which)
		..()
		switch(which)
			if ("critical_text")
				critical_text = configurer.getText("critical text", critical_text)
			if ("bonus_damage")
				bonus_damage = configurer.getNum("bonus damage", bonus_damage)
			if ("melee")
				melee = !melee
		configurer.sound_router(list("abilconf" = which), "abilconf", "critical_sound", src, "critical_sound")

	configuration(var/datum/critterCreator/configurer)
		. = ..()
		. += "<span class='attribute-name'>The critical strike will deal </span>"
		. += configurer.clickable_link("abilconf", bonus_damage, "0", "bonus_damage")
		. += " extra damage.<br/><span class='attribute-name'> The following text will be displayed: </span><br>"
		. += configurer.clickable_link("abilconf", critical_text, "(null)", "critical_text")
		. += "<br/>"
		. += configurer.sound_link("Critical hit", critical_sound, "abilconf", "critical_sound")
		. += "<br/>This ability works at [configurer.clickable_link("abilconf", melee ? "melee" : "any", "any", "melee")] range.<br>"

	clone()
		var/datum/critterAbility/criticalStrike/A = ..()
		A.bonus_damage = bonus_damage
		A.critical_text = critical_text
		A.critical_sound = critical_sound
		A.melee = melee
		return A

/datum/critterAbility/reagent
	name = "reagent inject"
	abstract = 0
	var/reagent_id = "mercury"
	var/inject_amount = 5
	var/inject_text = "%src% stabs %target% with its stinger!"
	var/sound/inject_sound
	var/melee = 1

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].reagent_id"] << reagent_id
		F["[path].inject_amount"] << inject_amount
		F["[path].inject_text"] << inject_text
		F["[path].melee"] << melee
		F["[path].inject_sound"] << inject_sound

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].reagent_id"] >> reagent_id
		F["[path].inject_amount"] >> inject_amount
		F["[path].inject_text"] >> inject_text
		F["[path].melee"] >> melee
		F["[path].inject_sound"] >> inject_sound

	use_ability()
		if (!C)
			logTheThing(LOG_DEBUG, null, "<b>Marquesas/CritterCreator: </b> Error using ability \ref[src] ([type]). C: \ref[C] [C].")
			return 0
		if (C.target && ismob(C.target))
			var/mob/M = C.target
			if (melee && GET_DIST(C, M) > C.attack_range)
				return 0
			C.tokenized_message(inject_text, M)
			C.play_optional_sound(inject_sound)
			M.reagents.add_reagent(reagent_id, inject_amount)
			return 1
		else
			logTheThing(LOG_DEBUG, null, "<b>Marquesas/CritterCreator: </b> Cannot reagent inject target, target is [C.target].")
			return 0

	change_configuration(var/datum/critterCreator/configurer, var/which)
		..()
		switch(which)
			if ("inject_text")
				inject_text = configurer.getText("inject text", inject_text)
			if ("inject_amount")
				inject_amount = configurer.getNum("injected amount", inject_amount)
			if ("reagent_id")
				reagent_id = configurer.getText("reagent id", reagent_id)
			if ("melee")
				melee = !melee
		configurer.sound_router(list("abilconf" = which), "abilconf", "inject_sound", src, "inject_sound")

	configuration(var/datum/critterCreator/configurer)
		. = ..()
		. += "<span class='attribute-name'>The critter will inject </span>"
		. += configurer.clickable_link("abilconf", inject_amount, "0", "inject_amount")
		. += " [inject_amount == 1 ? "unit" : "units"] of "
		. += configurer.clickable_link("abilconf", reagent_id, "0", "reagent_id")
		. += ".<br/><span class='attribute-name'> The following text will be displayed: </span><br>"
		. += configurer.clickable_link("abilconf", inject_text, "(null)", "inject_text")
		. += "<br>"
		. += configurer.sound_link("Injection", inject_sound, "abilconf", "inject_sound")
		. += "<br/>This ability works at [configurer.clickable_link("abilconf", melee ? "melee" : "any", "any", "melee")] range.<br>"

	clone()
		var/datum/critterAbility/reagent/A = ..()
		A.reagent_id = reagent_id
		A.inject_text = inject_text
		A.inject_sound = inject_sound
		A.inject_amount = inject_amount
		A.melee = melee
		return A

/datum/critterAbility/projectile
	name = "shoot projectile"
	var/projectile_type = /datum/projectile/laser
	var/datum/projectile/current_projectile = null
	var/fire_text = "%src% shoots at %target%!"
	abstract = 0

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].projectile_type"] << projectile_type
		F["[path].fire_text"] << fire_text

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].projectile_type"] >> projectile_type
		F["[path].fire_text"] >> fire_text
		current_projectile = new projectile_type()

	proc/fire_at(var/turf/T, var/mob/RT)
		var/turf/S = get_turf(C)
		shoot_projectile_ST(S, current_projectile, T)
		C.tokenized_message(fire_text, RT)
		return 1

	use_ability()
		if (!current_projectile)
			current_projectile = new projectile_type()
		if (!current_projectile)
			return 0
		var/turf/T

		var/RT = null
		if (C.target)
			T = get_turf(C.target)
			RT = C.target
		if (!T)
			var/mob/M = locate(/mob/living) in view(6, C)
			if (M)
				T = get_turf(M)
				RT = M
		if (!T)
			return 0
		return fire_at(T, RT)

	change_configuration(var/datum/critterCreator/configurer, var/which)
		..()
		switch(which)
			if ("projectile_type")
				projectile_type = configurer.getTypeExclusive("projectile type", projectile_type, /datum/projectile)
			if ("fire_text")
				fire_text = configurer.getText("firing text", fire_text)

	configuration(var/datum/critterCreator/configurer)
		. = ..()
		. += "The critter fire "
		. += configurer.clickable_link("abilconf", configurer.stripPath(projectile_type), "(null)", "projectile_type")
		. += " projectiles.<br>"
		. += ".<br/><span class='attribute-name'> The following text will be displayed: </span><br>"
		. += configurer.clickable_link("abilconf", fire_text, "(null)", "fire_text")
		. += "<br>"

	clone()
		var/datum/critterAbility/projectile/A = ..()
		A.projectile_type = projectile_type
		A.fire_text = fire_text
		return A

/datum/critterAbility/projectile/burst
	name = "projectile burst"
	fire_text = "%src% launches a barrage of projectiles!"
	var/turn_angle = 10
	var/count = 4
	var/curr_angle = 0

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].turn_angle"] << turn_angle
		F["[path].count"] << count

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].turn_angle"] >> turn_angle
		F["[path].count"] >> count

	proc/fire_in_direction(var/angle)
		var/turf/S = get_turf(C)
		shoot_projectile_XY(S, current_projectile, cos(angle), sin(angle))
		return 1

	use_ability()
		if (!current_projectile)
			current_projectile = new projectile_type()
		if (!current_projectile)
			return 0

		var/curr = curr_angle
		var/step_angle = 360.0 / count

		if(current_projectile.shot_sound)
			if (narrator_mode)
				playsound(C, 'sound/vox/shoot.ogg', 50)
			else
				playsound(C, current_projectile.shot_sound, 50)

		for (var/i = 1, i <= count, i++)
			fire_in_direction(curr)
			curr += step_angle

		C.tokenized_message(fire_text, null)


		curr_angle += turn_angle
		while (curr_angle >= 360)
			curr_angle -= 360
		while (curr_angle < 0)
			curr_angle += 360

		return 1

	change_configuration(var/datum/critterCreator/configurer, var/which)
		..()
		switch (which)
			if ("turn_angle")
				turn_angle = configurer.getNum("turn angle", turn_angle)
			if ("count")
				count = configurer.getNum("count", count)

	configuration(var/datum/critterCreator/configurer)
		. = ..()
		. += "<br>Bursts "
		. += configurer.clickable_link("abilconf", count, "0", "count")
		. += " projectiles uniformly spread across a circle around the critter.<br>"
		. += "The first projectile is fired towards the right. The position of 'right' is rotated by "
		. += configurer.clickable_link("abilconf", "[turn_angle]&ordm;", "0&ordm;", "turn_angle")
		. += " after firing.<br>"

	clone()
		var/datum/critterAbility/projectile/burst/A = ..()
		A.turn_angle = turn_angle
		A.count = count
		A.fire_text = fire_text
		return A

/datum/critterAbility/frenzy
	name = "frenzy"
	abstract = 0
	var/frenzy_text = "%src% goes into frenzy!"
	var/sound/frenzy_sound
	var/sound/frenzy_attack_sound
	var/frenzy_attack = "%src% rips a chunk off %target%!"
	var/frenzy_duration = 30
	var/attack_power = 4
	var/attacktype = "brute"
	var/attack_cooldown = 3
	var/stunlocks = 0
	var/frenzying = 0

	use_ability()
		if (frenzying)
			return 0
		var/mob/atmob = C.target
		if (!istype(atmob))
			return 0
		frenzying = 1
		C.tokenized_message(frenzy_text)
		C.play_optional_sound(frenzy_sound)
		C.suspend_ai = 1
		SPAWN(frenzy_duration)
			frenzying = 0
			C.suspend_ai = 0
		SPAWN(0)
			while(frenzying)
				var/turf/T = get_turf(atmob)
				if (!T)
					return
				C.set_loc(T)
				C.set_dir(pick(1,2,4,8))
				C.tokenized_message(frenzy_attack, atmob)
				C.play_optional_sound(frenzy_attack_sound)
				C.dodamage(atmob, attacktype, max(rand(attack_power), rand(attack_power)))
				if (stunlocks)
					atmob.changeStatus("weakened", (attack_cooldown / 3 * 2) SECONDS)
				sleep(attack_cooldown)
		return 1
	change_configuration(var/datum/critterCreator/configurer, var/which)
		..()
		switch (which)
			if ("frenzy_duration")
				frenzy_duration = configurer.getNum("frenzy duration in 1/10ths of seconds", frenzy_duration)
			if ("attack_cooldown")
				attack_cooldown = configurer.getNum("attack cooldown in 1/10ths of seconds", attack_cooldown)
			if ("attack_power")
				attack_power = configurer.getNum("attack power", attack_power)
			if ("attacktype")
				attacktype = configurer.getEnum("attack type", attacktype, list("brute", "burn", "toxin", "suffocation", "radiation"))
			if ("stunlocks")
				stunlocks = !stunlocks
			if ("frenzy_text")
				frenzy_text = configurer.getText("frenzy text", frenzy_text)
			if ("frenzy_attack")
				frenzy_attack = configurer.getText("frenzy_attack", frenzy_attack)
		configurer.sound_router(list("abilconf" = which), "abilconf", "frenzy_sound", src, "frenzy_sound")
		configurer.sound_router(list("abilconf" = which), "abilconf", "frenzy_attack_sound", src, "frenzy_attack_sound")

	configuration(var/datum/critterCreator/configurer)
		. = ..()
		. += "<b>Goes into a murderous frenzy for </b>"
		. += configurer.clickable_link("abilconf", frenzy_duration / 10, "0", "frenzy_duration")
		. += " seconds,<br><b>attacking every </b>"
		. += configurer.clickable_link("abilconf", attack_cooldown / 10, "0", "attack_cooldown")
		. += " seconds<br><b>with an attack power of </b>"
		. += configurer.clickable_link("abilconf", attack_power, "0", "attack_power")
		. += " "
		. += configurer.clickable_link("abilconf", attacktype, "(null)", "attacktype")
		. += " damage every hit, "
		. += configurer.clickable_link("abilconf", stunlocks ? "causing" : "not causing", "not causing", "stunlocks")
		. += " a stunlock.<br>"
		. += "<b>When going into frenzy</b>, the following text is displayed: <br>"
		. += configurer.clickable_link("abilconf", frenzy_text, "(null)", "frenzy_text")
		. += "<br/>"
		. += configurer.sound_link("Entering frenzy", frenzy_sound, "abilconf", "frenzy_sound")
		. += "<br/><b>When attacking in frenzy</b>, the following text is displayed: <br>"
		. += configurer.clickable_link("abilconf", frenzy_attack, "(null)", "frenzy_attack")
		. += "<br/>"
		. += configurer.sound_link("Frenzy attack", frenzy_attack_sound, "abilconf", "frenzy_attack_sound")

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].frenzy_text"] << src.frenzy_text
		F["[path].frenzy_attack"] << src.frenzy_attack
		F["[path].frenzy_duration"] << src.frenzy_duration
		F["[path].attack_power"] << src.attack_power
		F["[path].attacktype"] << src.attacktype
		F["[path].attack_cooldown"] << src.attack_cooldown
		F["[path].stunlocks"] << src.stunlocks
		F["[path].frenzy_sound"] << src.frenzy_sound
		F["[path].frenzy_attack_sound"] << src.frenzy_attack_sound

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].frenzy_text"] >> src.frenzy_text
		F["[path].frenzy_attack"] >> src.frenzy_attack
		F["[path].frenzy_duration"] >> src.frenzy_duration
		F["[path].attack_power"] >> src.attack_power
		F["[path].attacktype"] >> src.attacktype
		F["[path].attack_cooldown"] >> src.attack_cooldown
		F["[path].stunlocks"] >> src.stunlocks
		F["[path].frenzy_sound"] >> src.frenzy_sound
		F["[path].frenzy_attack_sound"] >> src.frenzy_attack_sound

	clone()
		var/datum/critterAbility/frenzy/A = ..()
		A.frenzy_text = frenzy_text
		A.frenzy_attack = frenzy_attack
		A.frenzy_duration = frenzy_duration
		A.attack_power = attack_power
		A.attacktype = attacktype
		A.attack_cooldown = attack_cooldown
		A.stunlocks = stunlocks
		A.frenzy_sound = frenzy_sound
		A.frenzy_attack_sound = frenzy_attack_sound
		return A

/datum/critterAbility/shockwave
	name = "shockwave"
	abstract = 0
	var/datum/abilityHolder/revenant/dummyHolder
	var/datum/targetable/revenantAbility/shockwave/ability
	var/shockwave_text = "%src% stomps the ground!"
	var/sound/shockwave_sound

	New()
		..()
		dummyHolder = new()
		ability = new()
		dummyHolder.abilities += ability
		ability.holder = dummyHolder

	attach()
		..()
		dummyHolder.owner = C

	configuration(var/datum/critterCreator/configurer)
		. = ..()
		. += "The shockwave has a propagation ratio of "
		. += configurer.clickable_link("abilconf", "[ability.propagation_percentage]%", "0%", "propagation")
		. += ".<br>"
		. += "The shockwave has a maximum range of "
		. += configurer.clickable_link("abilconf", ability.iteration_depth, 0, "iteration")
		. += ".<br>"
		. += "The following text will be displayed: <br>"
		. += configurer.clickable_link("abilconf", shockwave_text, "(null)", "shockwave_text")
		. += "<br>"
		. += configurer.sound_link("Shockwave", shockwave_sound, "abilconf", "shockwave_sound")

	change_configuration(var/datum/critterCreator/configurer, var/which)
		..()
		switch (which)
			if ("propagation")
				ability.propagation_percentage = configurer.getNum("propagation percentage", ability.propagation_percentage)
			if ("iteration")
				ability.iteration_depth = configurer.getNum("iteration depth", ability.iteration_depth)
			if ("shockwave_text")
				shockwave_text = configurer.getText("shockwave text", shockwave_text)
		configurer.sound_router(list("abilconf" = which), "abilconf", "shockwave_sound", src, "shockwave_sound")

	use_ability()
		ability.cast()
		C.tokenized_message(shockwave_text)
		C.play_optional_sound(shockwave_sound)
		return 1

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].propagation"] << ability.propagation_percentage
		F["[path].iteration"] << ability.iteration_depth
		F["[path].shockwave_text"] << src.shockwave_text
		F["[path].shockwave_sound"] << src.shockwave_sound

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].propagation"] >> ability.propagation_percentage
		F["[path].iteration"] >> ability.iteration_depth
		F["[path].shockwave_text"] >> src.shockwave_text
		F["[path].shockwave_sound"] >> src.shockwave_sound

	clone()
		var/datum/critterAbility/shockwave/A = ..()
		A.ability.propagation_percentage = ability.propagation_percentage
		A.ability.iteration_depth = ability.iteration_depth
		A.shockwave_text = shockwave_text
		A.shockwave_sound = shockwave_sound
		return A

/datum/critterAbility/spawnCritter
	name = "spawn critter"
	var/obj/critter/template = null
	var/stattype = null
	var/spawn_text = "%src% creates a new %target%."
	var/sound/spawn_sound
	abstract = 0

	New()
		..()
		template = new /obj/critter/domestic_bee
		stattype = /obj/critter/domestic_bee

	use_ability()
		var/obj/critter/D = template.clone()
		C.tokenized_message(spawn_text, D)
		C.play_optional_sound(spawn_sound)
		D.set_loc(get_turf(C))
		return 1

	clone()
		var/datum/critterAbility/spawnCritter/A = ..()
		A.template = template.clone()
		A.spawn_text = spawn_text
		A.spawn_sound = spawn_sound
		return A

	configuration(var/datum/critterCreator/configurer)
		. = ..()
		. += "Spawns critter: [template ? initial(template.name) : "(null)"]."
		. += configurer.clickable_link("abilconf", "Set critter from existing critter type", "", "existing")
		. += "<br>"
		. += configurer.clickable_link("abilconf", "Set critter from critter file", "", "file")
		. += "<br>"
		. += "The following text will be displayed: <br>"
		. += configurer.clickable_link("abilconf", spawn_text, "(null)", "spawn_text")
		. += "<br>"
		. += configurer.sound_link("Spawn", spawn_sound, "abilconf", "spawn_sound")

	change_configuration(var/datum/critterCreator/configurer, var/which)
		..()
		switch (which)
			if ("existing")
				var/ctype = input("Critter type", "Critter type", null) in childrentypesof(/obj/critter) - /obj/critter/custom
				stattype = ctype
				template = new ctype
			if ("file")
				var/critterfile = input("Critter data", "Critter data", null) as file
				var/temp = loadCustomCritterFromFile(critterfile)
				if (temp)
					stattype = null
					template = temp
				else
					boutput(usr, "<span class='alert'>Loading failed.</span>")
			if ("spawn_text")
				spawn_text = configurer.getText("spawn text", spawn_text)
		configurer.sound_router(list("abilconf" = which), "abilconf", "spawn_sound", src, "spawn_sound")

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()

		if (stattype)
			F["[path].mode"] << 0
			F["[path].stattype"] << stattype
		else
			F["[path].mode"] << 1
			template.serialize(F, "[path].template", sandbox)
		F["[path].spawn_text"] << src.spawn_text
		F["[path].spawn_sound"] << src.spawn_sound

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		var/mode
		F["[path].mode"] >> mode
		if (mode)
			template = new /obj/critter/custom()
			template.deserialize(F, "[path].template", sandbox)
		else
			F["[path].stattype"] >> stattype
			template = new stattype()
		F["[path].spawn_text"] >> src.spawn_text
		F["[path].spawn_sound"] >> src.spawn_sound

/datum/critterAbility/arcFlash
	name = "lightning strike"
	var/lightning_wattage = 5000
	var/mobs_struck = 1
	var/chains_to = 0
	abstract = 0

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].lightning_wattage"] << lightning_wattage
		F["[path].mobs_struck"] << mobs_struck
		F["[path].chains_to"] << chains_to

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].lightning_wattage"] >> lightning_wattage
		F["[path].mobs_struck"] >> mobs_struck
		F["[path].chains_to"] >> chains_to

	use_ability()
		if (!mobs_struck)
			return 0
		var/strike = mobs_struck
		var/chain_depth = chains_to
		var/list/previous = list()
		var/list/affected = list()
		for (var/mob/living/M in view(7, C))
			affected += M
		var/curr_W = lightning_wattage / mobs_struck
		while (strike > 0 && length(affected))
			strike--
			var/mob/M = pick(affected)
			arcFlash(C, M, curr_W)
			affected -= M
			previous += M
		SPAWN(0)
			while (chain_depth > 0)
				sleep(0.2 SECONDS)
				curr_W /= 2
				chain_depth--
				var/previous_copy = previous.Copy()
				previous.len = 0
				for (var/mob/M in previous_copy)
					if (!M)
						continue
					affected.len = 0
					for (var/mob/living/N in view(7, M))
						if (!(N in previous) && M != N)
							affected += N
					if (affected.len)
						var/mob/N = pick(affected)
						arcFlash(M, N, curr_W)
						previous += N
		return 1

	change_configuration(var/datum/critterCreator/configurer, var/which)
		..()
		switch(which)
			if ("wattage")
				lightning_wattage = configurer.getNum("wattage", lightning_wattage)
			if ("mobs_struck")
				mobs_struck = configurer.getNum("mobs struck", mobs_struck)
			if ("chains_to")
				chains_to = configurer.getNum("chaining depth", chains_to)

	configuration(var/datum/critterCreator/configurer)
		. = ..()
		. += "<span class='attribute-name'>The</span> "
		. += configurer.clickable_link("abilconf", lightning_wattage, 0, "wattage")
		. += " W <span class='attribute-name'>lightning will strike randomly at </span>"
		. += configurer.clickable_link("abilconf", mobs_struck, "0", "mobs_struck")
		. += (mobs_struck == 1) ? " mob in view, " : " mobs in view, "
		. += "<br>"
		. += configurer.clickable_link("abilconf", chains_to ? "chaining on to [chains_to] more targets." : "not chaining on.", "not chaining on.", "chains_to")

	clone()
		var/datum/critterAbility/arcFlash/A = ..()
		A.lightning_wattage = lightning_wattage
		A.mobs_struck = mobs_struck
		A.chains_to = chains_to
		return A

/datum/critterCreator
	var/obj/critter/custom/template = null
	var/abilid = 0
	var/static/list/presets = list("Alien" = "alien", "Cat" = "cat1", "Chicken" = "chicken", "Darkness" = "darkness", "Death" = "death", "Floating Eye" = "floateye", "Killer Tomato" = "ktomato" ,\
"Ice Spider" = "icespider", "Ice Spider Baby" = "babyicespider", "Ice Spider Queen" = "gianticespider", "Lion" = "lion",\
"Man Eater" = "maneater", "Martian" = "martian", "Martian (psychic)" = "martianP", "Martian (sapper)" = "martianSP", "Martian (soldier)" = "martianS", "Martian (warrior)" = "martianW", "Mouse" = "mouse",\
"Mutant" = "blobman", "Plasma Spore" = "spore", "Roach" = "roach", "Spider" = "spider", "Town Guard" = "townguard", \
"Weird Thing" = "ancientrobot", "Brullbar" = "brullbar",\
"Brullbar King" = "brullbarking", "Zombie" = "zombie", "Zombie (science)" = "scizombie", "Zombie (security)" = "seczombie", "cancel" = "cancel")
	var/static/list/ability_cache = list()
	var/static/list/death_cache = list()
	var/static/list/sound_presets = list("Bang" = 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', "Beep 1" = 'sound/misc/ancientbot_beep1.ogg', "Beep 2" = 'sound/misc/ancientbot_beep2.ogg', "Beep 3" = 'sound/misc/ancientbot_beep3.ogg', "'Beware coward'" = 'sound/voice/MEbewarecoward.ogg',\
"Blob Attack (old)" = 'sound/impact_sounds/Slimy_Hit_4.ogg', "Blob Impact" = 'sound/impact_sounds/Slimy_Hit_3.ogg', "Bloody Stab 1" = 'sound/impact_sounds/Flesh_Stab_1.ogg', "Bloody Stab 2" = 'sound/impact_sounds/Flesh_Stab_2.ogg',\
"Boop 1" = 'sound/machines/whistlebeep.ogg', "Boop 2" = 'sound/machines/whistlealert.ogg', "Boop 3" = 'sound/machines/twobeep.ogg', "Bubbling" = 'sound/effects/bubbles.ogg',\
"Burp 1" = 'sound/voice/burp.ogg', "Burp 2" = 'sound/voice/burp_alien.ogg', "Buzz 1" = 'sound/misc/ancientbot_buzz1.ogg', "Buzz 2" = 'sound/misc/ancientbot_buzz2.ogg', "Buzz 3" = 'sound/misc/ancientbot_grump.ogg',\
"Buzz 4" = 'sound/misc/ancientbot_grump2.ogg', "Clunk" = 'sound/impact_sounds/Generic_Click_1.ogg', "Crunch 1" = 'sound/impact_sounds/Flesh_Tear_1.ogg', "Crunch 2" = 'sound/impact_sounds/Flesh_Tear_2.ogg', \
"Crystal Break" = 'sound/impact_sounds/Crystal_Shatter_1.ogg', "Crystal Impact" = 'sound/impact_sounds/Crystal_Hit_1.ogg', "Crystal Step" = 'sound/impact_sounds/Glass_Shards_Hit_1.ogg', \
"Ghost 1" = 'sound/effects/ghost.ogg', "Ghost 2" = 'sound/effects/ghost2.ogg', "Ghost 3" = 'sound/effects/ghostbreath.ogg', "Ghost Laugh" = 'sound/effects/ghostlaugh.ogg', "Gibbing" = 'sound/impact_sounds/Flesh_Break_2.ogg',\
"Glitch 1" = 'sound/effects/glitchshot.ogg', "Glitch 2" = 'sound/effects/glitchy1.ogg', "Glitch 3" = 'sound/effects/glitchy2.ogg', "Glitch 4" = 'sound/effects/glitchy3.ogg', "Glitch 5" = 'sound/machines/glitch1.ogg',\
"Glitch 6" = 'sound/machines/glitch2.ogg', "Glitch 7" = 'sound/machines/glitch3.ogg', "Glitch 8" = 'sound/machines/glitch4.ogg', "Glitch 9" = 'sound/machines/glitch5.ogg', "Goose Honk" = 'sound/voice/animal/goose.ogg',\
"Groan 1" = 'sound/voice/Zgroan1.ogg', "Groan 2" = 'sound/voice/Zgroan2.ogg', "Groan 3" = 'sound/voice/Zgroan3.ogg', "Groan 4" = 'sound/voice/Zgroan4.ogg',\
"Growl" = 'sound/voice/animal/YetiGrowl.ogg', "Hiss" = 'sound/voice/animal/cat_hiss.ogg', "'I hunger'" = 'sound/voice/MEhunger.ogg', "'I live'" = 'sound/voice/MEilive.ogg', "Meow" = 'sound/voice/animal/cat.ogg', "Punch 1" = 'sound/impact_sounds/Generic_Punch_2.ogg', "Punch 2" = 'sound/impact_sounds/Generic_Hit_1.ogg',\
"Punch 3" = 'sound/impact_sounds/Generic_Punch_1.ogg', "Roar 1" = 'sound/voice/animal/brullbar_roar.ogg', "Roar 2" = 'sound/voice/animal/brullbar_scream.ogg', "Roar 3" = 'sound/voice/MEraaargh.ogg', "Roar (distant)" = 'sound/effects/mag_pandroar.ogg', "Robot gib" = 'sound/impact_sounds/Machinery_Break_1.ogg',\
"'Run coward'" = 'sound/voice/MEruncoward.ogg', "Shock 1" = 'sound/effects/electric_shock.ogg', "Shock 2" = 'sound/effects/elec_bzzz.ogg', "Shock 3" = 'sound/effects/elec_bigzap.ogg', "Splat" = 'sound/impact_sounds/Slimy_Splat_1.ogg', \
"Thunder" = 'sound/effects/thunder.ogg')

	New()
		..()
		create_template()

	proc/create_template()
		template = new /obj/critter/custom
		template.name = initial(template.name)
		template.is_template = 1

	proc/spawn_in()
		template.clone(usr.loc)

	proc/clickable(var/text, var/null_value = "(null)")
		if (text != null && text != "")
			if (istype(text, /datum))
				if ("name" in text:vars)
					return "[text:name]"
				else
					return "[text:type]"
			else
				return "[text]"
		else
			return "[null_value]"

	proc/clickable_link(var/topic_name, var/curr_value, var/null_value = "(null)", var/topic_value = 1)
		return "<a href='?src=\ref[src];[topic_name]=[topic_value]'>[clickable(curr_value, null_value)]</a>"

	proc/switcher(var/value, var/current_value, var/name, var/text)
		if (value == current_value)
			return "<span class='active'>[text]</span>"
		else
			return clickable_link(name, text, null, value)

	proc/attribute_clicker(var/attribute_name, var/topic_name, var/curr_value, var/pad_to = 16, var/null_value = "(null)")
		var/op = "<span class='attribute-name'>[attribute_name]:"
		for (var/i = length(attribute_name) + 2, i <= pad_to, i++)
			op += "&nbsp;"
		op += "</span>"
		op += clickable_link(topic_name, curr_value, null_value)
		op += "<br>"
		return op

	proc/getNum(var/name, var/default)
		return input(usr, "New value for [name]", name, default) as num

	proc/getText(var/name, var/default)
		return input(usr, "New value for [name]", name, default) as text

	proc/getEnum(var/name, var/default, var/list/possible)
		return input(usr, "New value for [name]", name, default) in possible

	proc/getTypeExclusive(var/name, var/default, var/parent_type)
		return input(usr, "New value for [name]", name, default) in childrentypesof(parent_type)

	proc/stripPath(var/typename)
		var/typetext = "[typename]"
		var/last = 1
		var/current = findtext(typetext, "/", last)
		while (current)
			last = current + 1
			current = findtext(typetext, "/", last)
		return copytext(typetext, last)

	Topic(href, href_list)
		USR_ADMIN_ONLY
		if (href_list["name"])
			template.name = getText("name", template.name)
		else if (href_list["desc"])
			template.desc = getText("description", template.desc)
		else if (href_list["health"])
			template.health = getNum("health", template.health)
		else if (href_list["aggressive"])
			template.aggressive = !template.aggressive
		else if (href_list["defensive"])
			template.defensive = !template.defensive
		else if (href_list["atkcarbon"])
			template.atkcarbon = !template.atkcarbon
		else if (href_list["atksilicon"])
			template.atksilicon = !template.atksilicon
		else if (href_list["mobile"])
			template.mobile = !template.mobile
		else if (href_list["wanderer"])
			template.wanderer = !template.wanderer
		else if (href_list["melee"])
			template.melee = !template.melee
		else if (href_list["power"])
			template.attack_power = getNum("attack power", template.attack_power)
		else if (href_list["atype"])
			template.attack_type = getEnum("attack type", template.attack_type, list("brute", "burn", "toxin", "suffocation", "radiation"))
		else if (href_list["stunp"])
			template.stun_prob = getNum("stun chance", template.stun_prob)
		else if (href_list["anger"])
			template.anger_text = getText("charge text", template.anger_text)
		else if (href_list["chase"])
			template.chase_text = getText("chase text", template.chase_text)
		else if (href_list["stun"])
			template.stun_text = getText("stun text", template.stun_text)
		else if (href_list["stunf"])
			template.stun_fail_text = getText("stun fail text", template.stun_fail_text)
		else if (href_list["attack"])
			template.attack_text = getText("attack text", template.attack_text)
		else if (href_list["corpse"])
			template.gib_corpses = !template.gib_corpses
		else if (href_list["death"])
			template.death_text = getText("death text", template.death_text)
		else if (href_list["brutevuln"])
			template.brutevuln = getNum("brute damage multiplier", template.brutevuln)
		else if (href_list["firevuln"])
			template.firevuln = getNum("burn damage multiplier", template.firevuln)
		else if (href_list["explosivevuln"])
			template.explosivevuln = getNum("explosive damage multiplier", template.explosivevuln)
		else if (href_list["lootamount"])
			var/datum/critterLoot/L = locate(href_list["lootamount"])
			if (L)
				L.change_configuration(src, "amount")
		else if (href_list["lootdropped"])
			var/datum/critterLoot/L = locate(href_list["lootdropped"])
			if (L)
				L.change_configuration(src, "dropped")
		else if (href_list["lootchance"])
			var/datum/critterLoot/L = locate(href_list["lootchance"])
			if (L)
				L.change_configuration(src, "chance")
		else if (href_list["lootremove"])
			var/datum/critterLoot/L = locate(href_list["lootremove"])
			if (L)
				L.change_configuration(src, "remove")
		else if (href_list["iconondeath"])
			template.dead_change_icon = !template.dead_change_icon
		else if (href_list["icon"])
			var/I = input("Select an image file.", "Image file", null) as icon|null
			if (I)
				template.icon = I
				template.icon_state = null
		else if (href_list["icon_state"])
			template.icon_state = getEnum("icon state", "", icon_states(template.icon))
		else if (href_list["dead_icon"])
			var/I = input("Select an image file.", "Image file", null) as icon|null
			if (I)
				template.dead_icon = I
				template.dead_icon_state = null
		else if (href_list["dead_icon_state"])
			if (template.dead_icon)
				template.dead_icon_state = getEnum("icon state", "", icon_states(template.dead_icon))
			else
				alert("Please define an icon first.")
		else if (href_list["icon_preset"])
			var/IS = getEnum("preset", "cancel", presets)
			if (IS != "cancel")
				template.icon = 'icons/misc/critter.dmi'
				template.icon_state = presets[IS]
		else if (href_list["abilconf"])
			if (abilid)
				var/datum/critterAbility/A = template.abil[abilid]
				if (A)
					A.change_configuration(src, href_list["abilconf"])
		else if (href_list["loottable"])
			template.loot_table.change_configuration(src, href_list["loottable"])
		else if (href_list["color"])
			template.color = input("Choose your color.", "color", template.color) as color
		else if (href_list["deathconf"])
			var/datum/critterDeath/A = template.on_death
			if (A)
				A.change_configuration(src, href_list["deathconf"])
		else if (href_list["abilevent"])
			if (abilid)
				var/datum/critterAbility/A = template.abil[abilid]
				if (A)
					if (A.event)
						A.event.change_configuration(src, href_list["abilevent"])
		else if (href_list["ability"])
			abilid = text2num(href_list["ability"])
		else if (href_list["abilchange"])
			if (!ability_cache.len)
				build_ability_cache()
			if (!abilid)
				return
			var/datum/critterAbility/A = template.abil[abilid]
			var/datum/critterAbility/ab = input("Which ability?", "Ability", null) in ability_cache
			if (A)
				if (ab.type == A.type)
					return
				qdel(A)
			A = ab.clone()
			template.abil[abilid] = A
		else if (href_list["ondeath"])
			if (!death_cache.len)
				build_death_cache()
			var/datum/critterDeath/D = template.on_death
			var/datum/critterDeath/ab = input("Which death event?", "On death", null) in death_cache
			if (D)
				if (D.type == ab.type)
					return
				qdel(D)
			template.on_death = ab.clone()
			template.on_death.C = template
		else if (href_list["newabil"])
			template.abil.len++
			template.abil[template.abil.len] = null
		else if (href_list["spawn"])
			spawn_in()
		else if (href_list["reset"])
			template = new /obj/critter/custom
			template.name = initial(template.name)
			template.is_template = 1
			abilid = 0
		else if (href_list["filesave"])
			var/fname = "adventure/CRIT_SAVE_[usr.client.ckey]_[world.time]"
			if (fexists(fname))
				fdel(fname)
			usr.client.Export()
			var/savefile/F = new /savefile(fname)
			F.dir.len = 0
			F.eof = -1
			F << null
			var/datum/sandbox/S = new()
			template.serialize(F, "critter", S)
			if (fexists("adventure/critter_save_[usr.client.ckey].dat"))
				fdel("adventure/critter_save_[usr.client.ckey].dat")
			var/target = file("adventure/critter_save_[usr.client.ckey].dat")
			F.ExportText("/", target)
			usr << ftp(target)
			if (fexists(fname))
				fdel(fname)
		else if (href_list["fileload"])
			var/fname = "adventure/CRIT_LOAD_[usr.client.ckey]"
			if (fexists(fname))
				fdel(fname)
			var/target = input("Select the saved critter to load.", "Saved critter upload", null) as file
			var/savefile/F = new /savefile(fname)
			F.dir.len = 0
			F.eof = -1
			F << null
			F.ImportText("/", file2text(target))
			if (!F)
				boutput(usr, "<span class='alert'>Import failed.</span>")
			else
				var/datum/sandbox/S = new()
				template = new()
				template.deserialize(F, "critter", S)
				template.is_template = 1
				if (fexists(fname))
					fdel(fname)
			abilid = 0
		else if (href_list["roundsave"])
			if (!(template.name in critter_creator_controller.activeCritterTypes))
				critter_creator_controller.activeCritterTypes += template.name
			critter_creator_controller.activeCritterTypes[template.name] = template.clone()
			boutput(usr, "<span class='notice'>Critter current state saved as [template.name]</span>")
		else if (href_list["roundload"])
			if (critter_creator_controller.activeCritterTypes.len)
				var/cname = input("Which critter?", "Which critter?", null) in critter_creator_controller.activeCritterTypes
				var/obj/critter/custom/CR = critter_creator_controller.activeCritterTypes[cname]
				template = CR.clone()
				boutput(usr, "<span class='notice'>Loaded [template.name].</span>")
			else
				boutput(usr, "<span class='alert'>Nothing saved yet.</span>")

		sound_router(href_list, "sounds", "anger_sound", template, "anger_sound")
		sound_router(href_list, "sounds", "chase_sound", template, "chase_sound")
		sound_router(href_list, "sounds", "stun_sound", template, "stun_sound")
		sound_router(href_list, "sounds", "stun_fail_sound", template, "stun_fail_sound")
		sound_router(href_list, "sounds", "attack_sound", template, "attack_sound")
		sound_router(href_list, "sounds", "death_sound", template, "death_sound")
		sound_router(href_list, "sounds", "ambient_sound", template, "ambient_sound")

		show_interface(usr)

	proc/build_ability_cache()
		for (var/abtype in typesof(/datum/critterAbility))
			var/datum/critterAbility/ab = new abtype()
			if (ab.abstract)
				qdel(ab)
			else
				ability_cache += ab

	proc/build_death_cache()
		for (var/abtype in typesof(/datum/critterDeath))
			var/datum/critterDeath/ab = new abtype()
			death_cache += ab

	proc/sound_link(var/human_name, var/current, var/topic_name, var/topic_value)
		return "<span class='attribute-name'>[human_name] sound: </span> [clickable_link(topic_name, current, "(null)", topic_value)] [clickable_link(topic_name, "set to null", "set to null", "[topic_value]_null")] [clickable_link(topic_name, "set to preset", "set to preset", "[topic_value]_preset")] [current != null ? clickable_link(topic_name, "test", "test", "[topic_value]_test") : null]<br>"

	proc/sound_router(var/list/href_list, var/topic_name, var/topic_value, var/datum/set_on, var/varname)
		if (href_list[topic_name])
			if (href_list[topic_name] == topic_value)
				var/inp = input("New sound.", "New sound.", null) as sound|null
				if (inp)
					set_on.vars[varname] = inp
			else if (href_list[topic_name] == "[topic_value]_preset")
				var/sound_name = input("New sound.", "New sound.", null) as null|anything in sound_presets
				if (sound_name)
					set_on.vars[varname] = sound_presets[sound_name]
			else if (href_list[topic_name] == "[topic_value]_null")
				set_on.vars[varname] = null
			else if (href_list[topic_name] == "[topic_value]_test")
				if (set_on.vars[varname])
					boutput(usr, set_on.vars[varname])

	proc/show_interface(var/mob/M)
		if (!template)
			create_template()
		var/output = {"
	<style type='text/css'>
		body { font-family: Consolas, monospace; white-space: pre-wrap; }
		table { width: 100%; text-align: left; border: none; border-spacing: 0; border-collapse: collapse; font-size: 110%; }
		tr { border:none; }
		td { border:none; vertical-align: top; }
		th.half, td.half { width: 50%; }
		td.title { font-size: 1.4em; font-weight: bold; text-align: center; }
		.subtitle { font-size: 1.2em; font-weight: bold; }
		.attribute-name { font-weight: bold; }
		.active { font-weight: bold; }
		"}
		output += "</style></head><body>"
		output += "<table><tr><td colspan='2' class='title'>Critter creation kit</td></tr>"
		output += "<tr><td class='half'>"

		output += attribute_clicker("Name", "name", template.name)
		output += attribute_clicker("Description", "desc", template.desc)
		output += attribute_clicker("Health", "health", template.health)

		output += "<br><span class='subtitle'>Default AI behaviour</span><br>"
		output += attribute_clicker("Aggressive", "aggressive", template.aggressive ? "yes" : "no")
		output += attribute_clicker("Defensive", "defensive", template.defensive ? "yes" : "no")
		output += attribute_clicker("Attacks carbon", "atkcarbon", template.atkcarbon ? "yes" : "no")
		output += attribute_clicker("Attacks silicon", "atksilicon", template.atksilicon ? "yes" : "no")
		output += attribute_clicker("Mobile", "mobile", template.mobile ? "yes" : "no")
		output += attribute_clicker("Wanderer", "wanderer", template.wanderer ? "yes" : "no")

		output += "<br><span class='subtitle'>Default attack</span><br>"
		output += attribute_clicker("Use melee", "melee", template.melee ? "yes" : "no")
		output += attribute_clicker("Attack power", "power", template.attack_power)
		output += attribute_clicker("Attack type", "atype", template.attack_type)
		output += attribute_clicker("Stun chance", "stunp", "[template.stun_prob]%")

		output += "<br><span class='subtitle'>Vulnerabilities</span><br>"
		output += attribute_clicker("Brute", "brutevuln", "[template.brutevuln * 100]%")
		output += attribute_clicker("Burn", "firevuln", "[template.firevuln * 100]%")
		output += attribute_clicker("Explosive", "explosivevuln", "[template.explosivevuln * 100]%")

		output += "<br><span class='subtitle'>Flavor</span><br>"
		output += sound_link("Ambient", template.ambient_sound, "sounds", "ambient_sound")
		output += attribute_clicker("Charge text", "anger", template.anger_text)
		output += sound_link("Charge", template.anger_sound, "sounds", "anger_sound")
		output += attribute_clicker("Chase text", "chase", template.chase_text)
		output += sound_link("Chase", template.chase_sound, "sounds", "chase_sound")
		output += attribute_clicker("Stun text", "stun", template.stun_text)
		output += sound_link("Stun", template.stun_sound, "sounds", "stun_sound")
		output += attribute_clicker("Stun fail text", "stunf", template.stun_fail_text)
		output += sound_link("Stun fail", template.stun_fail_sound, "sounds", "stun_fail_sound")
		output += attribute_clicker("Attack text", "attack", template.attack_text)
		output += sound_link("Attack", template.attack_sound, "sounds", "attack_sound")
		output += attribute_clicker("Death text", "death", template.death_text)
		output += sound_link("Death", template.death_sound, "sounds", "death_sound")

		output += "<br><span class='subtitle'>Appearance</span><br>"
		output += "<span class='attribute-name'>Color (click box to change):</span><br>"
		output += "<a href='?src=\ref[src];color=1' style='text-decoration:none'>"
		output += "<div style='display: inline-block; width:20px; height: 20px; background-color: [template.color ? template.color : "#ffffff"]; border: 1px solid black;'>&nbsp;</div>"
		output += "</a><br>"
		output += "<span class='attribute-name'>Icon:</span><br/>"
		var/icon/browsed_icon
		browsed_icon = icon(template.icon, template.icon_state, 2)
		if (template.color)
			browsed_icon.Blend(template.color, ICON_MULTIPLY)
		M << browse_rsc(browsed_icon, "preview_S.png")
		browsed_icon = icon(template.icon, template.icon_state, 1)
		if (template.color)
			browsed_icon.Blend(template.color, ICON_MULTIPLY)
		M << browse_rsc(browsed_icon, "preview_N.png")
		browsed_icon = icon(template.icon, template.icon_state, 4)
		if (template.color)
			browsed_icon.Blend(template.color, ICON_MULTIPLY)
		M << browse_rsc(browsed_icon, "preview_E.png")
		browsed_icon = icon(template.icon, template.icon_state, 8)
		if (template.color)
			browsed_icon.Blend(template.color, ICON_MULTIPLY)
		M << browse_rsc(browsed_icon, "preview_W.png")
		output += "<img src='preview_S.png' iconstate='[template.icon_state]' icondir='SOUTH' width='32' height='32'/>"
		output += "<img src='preview_N.png' iconstate='[template.icon_state]' icondir='NORTH' width='32' height='32' />"
		output += "<img src='preview_E.png' iconstate='[template.icon_state]' icondir='EAST' width='32' height='32' />"
		output += "<img src='preview_W.png' iconstate='[template.icon_state]' icondir='WEST' width='32' height='32' /><br>"
		output += "<strong>Note: </strong> The North, East and West preview images do not show up correctly for unidirectional sprites.<br>"
		output += "<a href='?src=\ref[src];icon_preset=1'>Set to preset</a><br>"
		output += "<a href='?src=\ref[src];icon=1'>Set icon file</a><br>"
		output += "To add directions, upload your icon in a .dmi format, with a single icon state with 4 directions.<br>"
		output += attribute_clicker("Icon state", "icon_state", template.icon_state)
		output += "<span class='attribute-name'>Dead icon:</span><br/>"
		output += "<a href='?src=\ref[src];iconondeath=1'>[template.dead_change_icon? "Changes" : "Does not change"]</a> icon on death.<br>"
		if (template.dead_change_icon)
			browsed_icon = icon(template.dead_icon, template.dead_icon_state)
			if (template.color)
				browsed_icon.Blend(template.color, ICON_MULTIPLY)
			usr << browse_rsc(browsed_icon, "preview_Death.png")
			output += "<img src='preview_Death.png' iconstate='[template.dead_icon_state]' icondir='SOUTH' width='32' height='32'/><br>"
			output += clickable_link("dead_icon", "Set icon file", "Set icon file")
			output += "<br><span class='attribute-name'>Icon state: </span>"
			output += clickable_link("dead_icon_state", template.dead_icon_state, "(null)")

		output += "</td><td class='half'>"
		output += "<span class='subtitle'>Abilities:</span><br>"
		for (var/i = 1, i <= template.abil.len, i++)
			output += switcher(i, abilid, "ability", "[i]")
			output += " "
		output += "<a href='?src=\ref[src];newabil=1'>Add new</a><br><br>"
		if (abilid)
			var/datum/critterAbility/A = template.abil[abilid]
			if (A)
				output += A.configuration(src)
			else
				output += clickable_link("abilchange", A, "Select ability type")
		output += "<br><br>"
		output += "<strong class='subtitle'>Other AI behaviour</strong><br>"
		output += "<strong>On death, </strong>[clickable_link("ondeath", template.on_death, "do nothing")].<br>"
		if (template.on_death)
			output += template.on_death.configuration(src)
		output += "<br/><br/><strong class='subtitle'>Loot table</strong><br>"
		output += template.loot_table.configuration(src)
		output += "</td></tr>"
		output += "<tr><td colspan='2'>Actions: <br/>[clickable_link("spawn", "Spawn")] | [clickable_link("reset", "Reset")]<br/>"
		output += "This round: [clickable_link("roundsave", "Save")] | [clickable_link("roundload", "Load")]<br/>"
		output += "Into file: [clickable_link("filesave", "Save")] | [clickable_link("fileload", "Load")]</td></tr>"
		output += "</table></body></html>"
		M.Browse(output, "window=crcreator;size=800x600")

/client/proc/critter_creator_debug()
	set name = "Critter Creator (WIP)"
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set hidden = 0

	var/datum/critterCreator/CR = critter_creator_controller.getCreator(src.mob)
	if (CR)
		CR.show_interface(src.mob)

#undef EVENT_ATTACHMENT_POINT_NONE
#undef EVENT_ATTACHMENT_POINT_MELEE
#undef EVENT_ATTACHMENT_POINT_ATTACKED

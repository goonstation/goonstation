/datum/abilityHolder/religious
	usesPoints = 0
	regenRate = 0
	tabName = "Miracles"
	var/god_fullname = null
	var/god_name = null
	var/god_epithet = null
	var/god_domain = null

	New()
		..()
		src.addAbility(/datum/targetable/chaplain/chooseReligion)


/datum/targetable/chaplain
	name = "OOPS SOMETHING BROKE"
	desc = "for real if you can see this tell a coder"
	icon = 'icons/mob/wraith_ui.dmi'
	icon_state = "template"
	cooldown = 0
	last_cast = 0
	targeted = 1
	target_anything = 1
	var/disabled = 0

	New()
		var/atom/movable/screen/ability/topBar/B = new /atom/movable/screen/ability/topBar(null)
		B.icon = src.icon
		B.icon_state = src.icon_state
		B.owner = src
		B.name = src.name
		B.desc = src.desc
		src.object = B

	castcheck()
		var/mob/living/M = holder.owner
		if (M.restrained() || !isalive(M) || M.getStatusDuration("paralysis") || M.getStatusDuration("stunned") > 0  || M.getStatusDuration("weakened"))
			boutput(M, "<span class='alert'>You can't do that while you're incapacitated.</span>")
			return 0
		if (disabled)
			boutput(M, "<span class='alert'>You cannot use that ability at this time.</span>")
			return 0
		return 1

	cast(atom/target)
		. = ..()
		actions.interrupt(holder.owner, INTERRUPT_ACT)

	doCooldown()
		if (!holder)
			return
		last_cast = world.time + cooldown
		holder.updateButtons()
		SPAWN_DBG(cooldown + 5)
			holder.updateButtons()

/proc/assemble_name(var/datum/abilityHolder/religious/religiousHolder)
	var/list/god_adjective = strings("gods.txt", "adjective")
	var/list/god_noun = strings("gods.txt", "noun")
	var/list/namebegin = strings("gods.txt", "namebegin")
	var/list/nameend = strings("gods.txt", "nameend")
	religiousHolder.god_fullname = ""
	if (religiousHolder.god_domain == "Atheism") // dweeb detected
		religiousHolder.god_name = religiousHolder.owner.real_name
		religiousHolder.god_epithet = "Smug Bastard"
	else
		religiousHolder.god_name = "[pick(namebegin)][pick(nameend)]"
		religiousHolder.god_epithet = ""
		religiousHolder.god_epithet += "[capitalize(pick(god_adjective))] "
		religiousHolder.god_epithet += "[capitalize(pick(god_noun))]"
	religiousHolder.god_fullname += "[religiousHolder.god_name] the [religiousHolder.god_epithet], "
	if (religiousHolder.god_domain  == "Atheism")
		if (religiousHolder.owner.gender == MALE)
			religiousHolder.god_fullname += "'God'"
		else
			religiousHolder.god_fullname += "'Goddess'"
	else
		religiousHolder.god_fullname += pick("God", "Goddess")
	religiousHolder.god_fullname += " of [religiousHolder.god_domain]"

	boutput(religiousHolder.owner, "<span class='notice'><b>You are now a priest of [religiousHolder.god_fullname]!</b></span>")
	return

/datum/targetable/chaplain/chooseReligion
	name = "Choose Religion"
	desc = "What flavor of crazy street preacher do you feel like being today?"
	cooldown = 0
	targeted = 0
	target_anything = 0
	icon_state = "absorbcorpse"
	var/static/list/domains = list("Atheism", "Order", "Chaos", "Light", "Darkness", "Life" , "Death", "Machinery", "Nature", "Surprise me!")
	//var/static/list/domainsForNerds = list("Atheism" = 1, "Order" = 2, "Chaos" = 3, "Light" = 4, "Darkness" = 5, "Life" = 6, "Death" = 7, "Machinery" = 8, "Nature" = 9, "Sol Invictus" = 10, "the Void" = 11, "Surprise me!" = 12)

	cast()
		var/datum/abilityHolder/religious/religiousHolder = src.holder
		if (..())
			return 1
		var/domainChoice = tgui_input_list(holder.owner, "Pick a domain", "Domains", domains)

		if (!domainChoice)
			return

		if (domainChoice  == "Surprise me!")
			domainChoice = pick(domains - "Surprise me!")

		switch (domainChoice)
			if ("Atheism")
				religiousHolder.god_domain = "Atheism"
				assemble_name(religiousHolder)


			if ("Order")
				religiousHolder.god_domain = "Order"
				assemble_name(religiousHolder)


			if ("Chaos")
				religiousHolder.god_domain = "Chaos"
				assemble_name(religiousHolder)


			if ("Light")
				religiousHolder.god_domain = "Light"
				assemble_name(religiousHolder)


			if ("Darkness")
				religiousHolder.god_domain = "Darkness"
				assemble_name(religiousHolder)


			if ("Life")
				religiousHolder.god_domain = "Life"
				religiousHolder.addAbility(/datum/targetable/chaplain/stabilize)
				assemble_name(religiousHolder)


			if ("Death")
				religiousHolder.god_domain = "Death"
				assemble_name(religiousHolder)


			if ("Machinery")
				religiousHolder.god_domain = "Machinery"
				usr.robot_talk_understand = 1
				religiousHolder.addAbility(/datum/targetable/chaplain/chaplainDemag)
				religiousHolder.addAbility(/datum/targetable/chaplain/sootheMachineSpirits)
				assemble_name(religiousHolder)


			if ("Nature")
				religiousHolder.god_domain = "Nature"
				religiousHolder.addAbility(/datum/targetable/chaplain/blessWeed)
				religiousHolder.addAbility(/datum/targetable/chaplain/fortifySeed)
				assemble_name(religiousHolder)

		religiousHolder.removeAbility(/datum/targetable/chaplain/chooseReligion)

//*************** ATHEISM *****************

//100% worthless gimmick shit, free fedora, supersmug emote, immunity to fedora gib?

//every bible hit causes brain damage. might almost be 2overpowered4ourplayerbase but if you're wearing a hat it's stopped cold
//also a way to be a subtle douchebag as a traitor, "no I swear I just keep getting really unlucky" *whack whack whack*

//*************** ORDER *****************

//Clean everything in an aoe
//??? move demag here, give machinery a repair power???

//*************** CHAOS *****************

//Xom bullshit, Pandemonium, etc

//*************** LIGHT *****************

//Flash immunity worked into apply_flash + pt laser + welding tools

//Photokinesis
//Glowy

//*************** DARKNESS *****************

//Erebokinesis
//Ignore all darkness

//get fucked over by lights/flashes

//*************** LIFE *****************

/datum/targetable/chaplain/stabilize
	name = "Stabilize"
	desc = "Stabilizes someone experiencing shock, hemorrhages, cardiac failure, or cardiac arrest. They will probably still require further medical attention."
	cooldown = 1500
	max_range = 1
	icon_state = "absorbcorpse"

	cast(atom/T)
		var/datum/abilityHolder/religious/religiousHolder = src.holder
		if (..())
			return 1
		if (get_dist(usr, T) > src.max_range)
			boutput(usr, __red("[T] is too far away."))
			return 1
		if (!iscarbon(T))
			boutput(usr, "<span class='alert'>That's not exactly what this power was meant to work on.</span>")
			return 1
		var/mob/living/carbon/human/C = T
		if (isdead(C))
			boutput(usr, "<span class='alert'>[C]'s dead, Jim! You're a miracle-worker, not...uh...look, it ain't gonna work.</span>")
			return 1

		usr.visible_message("<span class='notice'>[src.holder.owner] lays hands upon [C], murmuring a soft prayer to [religiousHolder.god_name]!</span>")
		boutput(C, "<span class='notice'>You feel less terrible!</span>")
		playsound(usr.loc, "sound/voice/heavenly.ogg", 50, 1)
		C.cure_disease_by_path(/datum/ailment/malady/heartfailure)
		C.cure_disease_by_path(/datum/ailment/malady/flatline)
		C.cure_disease_by_path(/datum/ailment/malady/shock)
		if (C.find_ailment_by_type(/datum/ailment/disease/noheart))
			boutput(usr, "<span style\"color:red\">[C] is still sort of missing their heart. Maybe this calls for an actual doctor. Just saying.</span>")
		C.take_oxygen_deprivation(-INFINITY)
		C.losebreath = 0
		C.delStatus("paralysis")
		repair_bleeding_damage(C, 100, 10)
		C.blood_volume = 500 //this is to prevent people from instantly relapsing into shock/heart failure/braindeath at low blood

		return 0

//zero chance to accidentally beat people with the bible
//this sounds kind of low-impact except 2/5ths of the bible's hits are wasted and give brain damage
//so you're getting a 40% increase in efficiency and can't accidentally murder someone who was recently in crit

//*************** DEATH *****************

//passively sense when deaths occur

//????
//Animate meatcubes maybe???


//*************** NATURE *****************


/datum/targetable/chaplain/blessWeed
	name = "Bless Weed"
	desc = "Make some herb into sacred herbs."
	cooldown = 150
	icon_state = "absorbcorpse"

	cast(atom/T)
		var/datum/abilityHolder/religious/religiousHolder = src.holder
		if (..())
			return 1

		if (!istype(T, /obj/item/plant/herb/cannabis))
			boutput(holder.owner, "<span class='alert'>That ain't weed, you dingus!</span>")
			return 1

		if (istype(T,/obj/item/plant/herb/cannabis/black))
			boutput(holder.owner, "<span class='notice'>You purify the toxins in [T].</span>")
			new/obj/item/plant/herb/cannabis/spawnable(T.loc)
			qdel(T)
			return 0
		if (istype(T, /obj/item/plant/herb/cannabis/mega))
			boutput(holder.owner, "<span class='notice'>You bestow [religiousHolder.god_name]'s <i>special</i> blessing upon [T].</span>")
			new/obj/item/plant/herb/cannabis/omega/spawnable(T.loc)
			qdel(T)
			return 0
		if (istype(T, /obj/item/plant/herb/cannabis/white))
			boutput(holder.owner, "<span class='alert'>No need to bless what's already blessed.</span>")
			return 1
		if (istype(T, /obj/item/plant/herb/cannabis/omega))
			boutput(holder.owner, "<span class='alert'>Look, this shit could glue [religiousHolder.god_name] to the couch already. Making it any more dank might cause some sort of weedularity.</span>")
			return 1
		else
			boutput(holder.owner, "<span class='notice'>You bestow [religiousHolder.god_name]'s blessing upon [T].</span>")
			new/obj/item/plant/herb/cannabis/white/spawnable(T.loc)
			qdel(T)
			return 0

/datum/targetable/chaplain/fortifySeed
	name = "Fortify Seed"
	desc = "Blesses a seed, giving small, random improvements to all of its traits."
	cooldown = 150
	max_range = 1
	icon_state = "absorbcorpse"

	proc/fortify(var/obj/item/seed/S)
		var/datum/plantgenes/DNA = S.plantgenes
		DNA.growtime += rand(0,8)
		DNA.harvtime += rand(0,5)
		DNA.cropsize += rand(0,4)
		DNA.harvests += rand(0,1)
		DNA.potency += rand(0,6)
		DNA.endurance += rand(0,3)

	cast(atom/T)
		var/datum/abilityHolder/religious/religiousHolder = src.holder
		if (..())
			return 1

		if (istype(T, /obj/item/seed))
			boutput(holder.owner, "<span class='notice'>You bestow [religiousHolder.god_name]'s blessing upon [T].</span>")
			fortify(T)
			return 0
		else
			boutput(holder.owner, "<span class='alert'>This only works on seeds!</span>")
			return 1


//*************** MACHINES *****************

/datum/targetable/chaplain/chaplainDemag
	name = "Demag"
	desc = "Repairs damage to sensitive electronics due to electromagnetic scrambling. Note: cyborg circuitry is too complex for this to work."
	cooldown = 1800
	icon_state = "absorbcorpse"

	cast(atom/T)
		var/datum/abilityHolder/religious/religiousHolder = src.holder
		if (..())
			return 1

		if (!istype(T, /obj))
			boutput(holder.owner, "<span class='alert'>You cannot try to repair this!</span>")
			return 1

		var/obj/O = T
		// go to jail, do not pass src, do not collect pushed messages
		if (O.demag())
			boutput(usr, "<span class='notice'>You repair the damage to [O] in the name of [religiousHolder.god_name].</span>")
			return 0
		else
			boutput(usr, "<span class='alert'>It doesn't seem like this needs fixing.</span>")
			return 1

/datum/targetable/chaplain/sootheMachineSpirits
	name = "Soothe Machine Spirits"
	desc = "NT-model thermoelectric engines tend to be...tempermental. You're able to calm them down better than most."
	cooldown = 900
	max_range = 1
	icon_state = "absorbcorpse"

	cast(atom/T)
		if (..())
			return 1

		if (get_dist(usr, T) > src.max_range)
			boutput(usr, __red("[T] is too far away."))
			return 1

		if (!istype(T, /obj/machinery/power/generatorTemp))
			boutput(usr, "<span class='alert'>You can only use this on the engine's core!</span>")
			return 1

		var/obj/machinery/power/generatorTemp/E = T
		usr.visible_message("<span class='notice'>[usr] places a hand on the [E] and mumbles something.</span>")
		playsound(usr.loc, "sound/voice/heavenly.ogg", 50, 1)
		E.grump = 0
		E.visible_message("<span class='notice'><b>The [E] suddenly seems very chill!</b></span>")

		return 0


//*************** SOL INVICTUS? *****************


//*************** THE VOID? *****************

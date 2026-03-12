/obj/item/SWF_uplink
	name = "Spellbook"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "spellbook"
	item_state = "spellbook"
	var/datum/antagonist/wizard/antag_datum = null
	var/wizard_key = ""
	var/uses = 6
	var/list/spells = list()
	flags = TABLEPASS | TGUI_INTERACTIVE
	c_flags = ONBELT
	throwforce = 5
	health = 5
	w_class = W_CLASS_SMALL
	throw_speed = 4
	throw_range = 20
	m_amt = 100
	var/vr = FALSE
	/// The name of the spellbook's wizard for display purposes
	var/wizard_name = null
#ifdef BONUS_POINTS
	uses = 9999
#endif

	New(datum/antagonist/wizard/antag, in_vr = FALSE)
		..()
		src.antag_datum = antag
		if (in_vr)
			src.vr = TRUE
			src.uses *= 2

		for(var/D as anything in concrete_typesof(/datum/SWFuplinkspell))
			src.spells += new D(src)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "WizardSpellbook")
			ui.open()

	ui_data(mob/user)
		. = list(
			"spell_slots" = src.uses
		)

	ui_static_data(mob/user)
		var/list/spellbook_contents = list()
		for(var/datum/SWFuplinkspell/spell as anything in src.spells)
			var/cooldown_contents = null
			var/icon/spell_icon = null
			if (!spellbook_contents[spell.eqtype])
				// create category if it doesnt exist
				spellbook_contents[spell.eqtype] = list()
			if (spell.assoc_spell && ispath(spell.assoc_spell, /datum/targetable/spell))
				var/datum/targetable/spell/spell_ability_datum = spell.assoc_spell
				// convert deciseconds to seconds
				cooldown_contents = initial(spell_ability_datum.cooldown) / 10
				spell_icon = icon2base64(icon(initial(spell_ability_datum.icon), initial(spell_ability_datum.icon_state), frame=6))
			else if (spell.icon && spell.icon_state)
				spell_icon = icon2base64(icon(initial(spell.icon), initial(spell.icon_state), frame=1))
			spellbook_contents[spell.eqtype] += list(list(
				cooldown = cooldown_contents,
				cost = spell.cost,
				desc = spell.desc,
				name = spell.name,
				spell_img = spell_icon,
				vr_allowed = spell.vr_allowed,
			))
		. = list(
			"owner_name" = src.wizard_name,
			"spellbook_contents" = spellbook_contents,
			"vr" = src.vr
		)

	attack_self(mob/user)
		if(!user.mind || (user.mind && user.mind.key != src.wizard_key))
			boutput(user, SPAN_ALERT("<b>The spellbook is magically attuned to someone else!</b>"))
			return
		// update regardless, in case the wizard read their spellbook before setting their name
		src.wizard_name = user.real_name
		ui_interact(user)

	ui_act(action, list/params)
		. = ..()
		if (.)
			return
		switch (action)
			if ("buyspell")
				var/datum/SWFuplinkspell/chosen_spell = params["spell"]
				for (var/datum/SWFuplinkspell/spell in src.spells)
					if (spell.name == chosen_spell)
						chosen_spell = spell
						break
				if (chosen_spell.SWFspell_CheckRequirements(usr,src))
					chosen_spell.SWFspell_Purchased(usr,src)

///////////////////////////////////////// Wizard's spells ///////////////////////////////////////////////////
ABSTRACT_TYPE(/datum/SWFuplinkspell)
/datum/SWFuplinkspell
	var/name = "Spell"
	var/eqtype = "Spell"
	var/desc = "This is a spell."
	var/cost = 1
	var/cooldown = null
	var/assoc_spell = null
	var/vr_allowed = 1
	var/obj/item/assoc_item = null
	/// backup icon in case spell has no associated spell ability
	var/icon = 'icons/mob/spell_buttons.dmi'
	var/icon_state = "fixme"

	proc/SWFspell_CheckRequirements(var/mob/living/carbon/human/user,var/obj/item/SWF_uplink/book)
		if (!user || !book)
			return FALSE // unknown error
		if (book.vr && !src.vr_allowed)
			return FALSE // Unavailable in VR
		if (src.assoc_spell)
			if (book.antag_datum.ability_holder.getAbility(assoc_spell))
				return FALSE // Already have this spell
		if (book.uses < src.cost)
			return FALSE // ran out of points
		return TRUE

	proc/SWFspell_Purchased(var/mob/living/carbon/human/user,var/obj/item/SWF_uplink/book)
		if (!user || !book)
			return
		logTheThing(LOG_DEBUG, null, "[constructTarget(user)] purchased the spell [src.name] using the [book] uplink.")
		if (src.assoc_spell)
			book.antag_datum.ability_holder.addAbility(src.assoc_spell)
		if (src.assoc_item)
			var/obj/item/I = new src.assoc_item(user.loc)
			if (istype(I, /obj/item/staff) && user.mind && !isvirtual(user))
				var/obj/item/staff/S = I
				S.wizard_key = user.mind.key
		book.uses -= src.cost
		book.antag_datum.purchased_spells.Add(src) // Remember spell for crew credits

//------------ ENCHANTMENT SPELLS ------------//
/datum/SWFuplinkspell/soulguard
	name = "Soulguard"
	eqtype = "Enchantment"
	vr_allowed = 0
	desc = "Soulguard is basically a one-time do-over that teleports you back to the wizard shuttle and restores your life in the event that you die. However, the enchantment doesn't trigger if your body has been gibbed or otherwise destroyed. Also note that you will respawn completely naked."
	icon_state = "soulguard"

	SWFspell_CheckRequirements(var/mob/living/carbon/human/user,var/obj/item/SWF_uplink/book)
		. = ..()
		if (user.spell_soulguard) return 2

	SWFspell_Purchased(var/mob/living/carbon/human/user,var/obj/item/SWF_uplink/book)
		..()
		user.spell_soulguard = SOULGUARD_SPELL

//------------ EQUIPMENT SPELLS ------------//
/datum/SWFuplinkspell/staffofcthulhu
	name = "Staff of Cthulhu"
	eqtype = "Equipment"
	desc = "The crew will normally steal your staff and run off with it to cripple your casting abilities, but that doesn't work so well with this version. Any non-wizard dumb enough to touch or pull the Staff of Cthulhu takes massive brain damage and is knocked down for quite a while, and hiding the staff in a closet or somewhere else is similarly ineffective given that you can summon it to your active hand at will. It also makes a much better bludgeoning weapon than the regular staff, hitting harder and occasionally inflicting brain damage."
	assoc_spell = /datum/targetable/spell/summon_staff
	assoc_item = /obj/item/staff/cthulhu
	cost = 2

/datum/SWFuplinkspell/staffofthunder
	name = "Staff of Thunder"
	eqtype = "Equipment"
	desc = "A special staff attuned to electical energies. Able to conjure three lightning bolts to strike down foes before being recharged. Capable of being summoned magically, which recharges the wand. Take care, as you're not immune to your own thunder!"
	assoc_spell = /datum/targetable/spell/summon_thunder_staff
	assoc_item = /obj/item/staff/thunder
	cost = 2

//------------ OFFENSIVE SPELLS ------------//
/datum/SWFuplinkspell/bull
	name = "Bull's Charge"
	eqtype = "Offensive"
	desc = "Records your movement for 4 seconds, after which a massive bull charges along the recorded path, smacking anyone unfortunate to get in its way (excluding yourself) and dealing a significant amount of brute damage in the process. Watch your head for loose items, they are thrown around too."
	assoc_spell = /datum/targetable/spell/bullcharge
/*
/datum/SWFuplinkspell/shockwave
	name = "Shockwave"
	eqtype = "Offensive"
	desc = "This spell will violently throw back any nearby objects or people.<br>Cooldown:"
	assoc_spell = /datum/targetable/spell/shockwave
*/
/datum/SWFuplinkspell/fireball
	name = "Fireball"
	eqtype = "Offensive"
	desc = "This spell allows you to fling a fireball at a nearby target of your choice. The fireball will explode, knocking down and burning anyone too close, including you."
	assoc_spell = /datum/targetable/spell/fireball
	cost = 2

/datum/SWFuplinkspell/prismatic_spray
	name = "Prismatic Spray"
	eqtype = "Offensive"
	desc = "This spell allows you to launch a spray of colorful and wildly inaccurate projectiles outwards in a cone aimed roughly at a nearby target."
	assoc_spell = /datum/targetable/spell/prismatic_spray
	cost = 1

/*
/datum/SWFuplinkspell/shockinggrasp
	name = "Shocking Grasp"
	eqtype = "Offensive"
	desc = "This spell cannot be used on a moving target due to the need for a very short charging sequence, but will instantly kill them, destroy everything they're wearing, and vaporize their body."
	assoc_spell = /datum/targetable/spell/kill
*/
/datum/SWFuplinkspell/shockingtouch
	name = "Shocking Touch"
	eqtype = "Offensive"
	desc = "This spell cannot be used on a moving target due to the need for a very short charging sequence, but will instantly put them in critical condition, and shock and stun anyone close to them."
	assoc_spell = /datum/targetable/spell/shock

/datum/SWFuplinkspell/iceburst
	name = "Ice Burst"
	eqtype = "Offensive"
	desc = "This spell fires freezing cold projectiles that will temporarily freeze the floor beneath them, and slow down targets on contact."
	assoc_spell = /datum/targetable/spell/iceburst

/datum/SWFuplinkspell/blind
	name = "Blind"
	eqtype = "Offensive"
	desc = "This spell temporarily blinds and stuns a target of your choice."
	assoc_spell = /datum/targetable/spell/blind

/datum/SWFuplinkspell/clownsrevenge
	name = "Clown's Revenge"
	eqtype = "Offensive"
	desc = "This spell turns an adjacent target into an idiotic, horrible, and useless clown."
	assoc_spell = /datum/targetable/spell/cluwne
	cost = 2

/datum/SWFuplinkspell/balefulpolymorph
	name = "Baleful Polymorph"
	eqtype = "Offensive"
	desc = "This spell turns an adjacent target into some kind of an animal."
	vr_allowed = 0
	assoc_spell = /datum/targetable/spell/animal
	cost = 2

/datum/SWFuplinkspell/rathensecret
	name = "Rathen's Secret"
	eqtype = "Offensive"
	desc = "This spell summons a shockwave that rips the arses off of your foes. If you're lucky, the shockwave might even sever an arm or leg."
	assoc_spell = /datum/targetable/spell/rathens
	cost = 2

/*/datum/SWFuplinkspell/lightningbolt
	name = "Lightning Bolt"
	eqtype = "Offensive"
	desc = "Fires a bolt of electricity in a cardinal direction. Causes decent damage, and can go through thin walls and solid objects. You need special HAZARDOUS robes to cast this!"
	assoc_verb = */

//------------ DEFENSIVE SPELLS ------------//
/datum/SWFuplinkspell/forcewall
	name = "Forcewall"
	eqtype = "Defensive"
	desc = "This spell creates an unbreakable wall from where you stand that extends to your sides. It lasts for 30 seconds."
	assoc_spell = /datum/targetable/spell/forcewall

/datum/SWFuplinkspell/blink
	name = "Blink"
	eqtype = "Defensive"
	vr_allowed = 0
	desc = "This spell teleports you a short distance forwards. Useful for evasion or getting into areas."
	assoc_spell = /datum/targetable/spell/blink

/datum/SWFuplinkspell/teleport
	name = "Teleport"
	eqtype = "Defensive"
	desc = "This spell teleports you to an area of your choice, but requires a short time to charge up."
	vr_allowed = 0
	assoc_spell = /datum/targetable/spell/teleport
	cost = 2

/datum/SWFuplinkspell/warp
	name = "Warp"
	eqtype = "Defensive"
	desc = "This spell teleports a visible foe away from you."
	vr_allowed = 0
	assoc_spell = /datum/targetable/spell/warp

/datum/SWFuplinkspell/spellshield
	name = "Spell Shield"
	eqtype = "Defensive"
	desc = "This spell encases you in a magical shield that protects you from melee attacks and projectiles for 10 seconds. It also absorbs some of the blast of explosions."
	assoc_spell = /datum/targetable/spell/magshield

/datum/SWFuplinkspell/doppelganger
	name = "Doppelganger"
	eqtype = "Defensive"
	desc = "This spell projects a decoy in the direction you were moving while rendering you invisible and capable of moving through solid matter for a few moments."
	assoc_spell = /datum/targetable/spell/doppelganger
	cost = 2

//------------ UTILITY SPELLS ------------//
/datum/SWFuplinkspell/knock
	name = "Knock"
	eqtype = "Utility"
	desc = "This spell opens all doors, lockers, and crates up to five tiles away. It also blows open cyborg head compartments, damaging them and exposing their brains."
	assoc_spell = /datum/targetable/spell/knock

/datum/SWFuplinkspell/empower
	name = "Empower"
	eqtype = "Utility"
	desc = "This spell removes stuns on use, causes you to turn into a hulk, and gain passive wrestling powers for a short while."
	assoc_spell = /datum/targetable/spell/mutate

/datum/SWFuplinkspell/summongolem
	name = "Summon Golem"
	eqtype = "Utility"
	desc = "This spell allows you to turn a reagent you currently hold (in a jar, bottle, or other container) into a golem. Golems will attack your enemies, and release their contents as chemical smoke when destroyed."
	assoc_spell = /datum/targetable/spell/golem
	cost = 2

/datum/SWFuplinkspell/stickstosnakes
	name = "Sticks to Snakes"
	eqtype = "Utility"
	desc = "This spell allows you to turn an item into a snake. If you target a person the item in their hand will transform instead. When destroyed the snake reverts back to the original item."
	assoc_spell = /datum/targetable/spell/stickstosnakes

/datum/SWFuplinkspell/animatedead
	name = "Animate Dead"
	eqtype = "Utility"
	desc = "This spell infuses an adjacent human corpse with necromantic energy, creating a durable skeleton minion that seeks to pummel your enemies into oblivion."
	assoc_spell = /datum/targetable/spell/animatedead

//------------ MISC SPELLS ------------//
/datum/SWFuplinkspell/pandemonium
	name = "Pandemonium"
	eqtype = "Miscellaneous"
	desc = "This spell causes random effects to happen. Best used only by skilled wizards."
	vr_allowed = 0
	assoc_spell = /datum/targetable/spell/pandemonium

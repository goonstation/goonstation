/// A list of '/datum/uplinkspell's available to chaplains. This is lazily instantiated, use the getter 'get_chaplain_spell_list()' to access this, or
/// make sure it's cached first.
var/global/list/chaplain_spell_list

proc/get_chaplain_spell_list()
	if (!chaplain_spell_list)
		chaplain_spell_list = list(
			new /datum/uplinkspell/spawntree(),
			new /datum/uplinkspell/candles(),
			new /datum/uplinkspell/spawnfire(),
			new /datum/uplinkspell/chaplain_announcement()
		)
	return chaplain_spell_list

/obj/item/spellbook/chaplain_uplink
	name = "Prayerbook"
	icon = 'icons/obj/items/storage.dmi'
	icon_state ="bible"
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state ="bible"
	var/alist/chaplains

	New(newloc, in_vr = FALSE)
		..()
		if (in_vr)
			src.vr = TRUE

		src.spells = get_chaplain_spell_list()

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "WizardSpellbook")
			ui.open()

	ui_data(mob/user)
		var/datum/trait/job/chaplain/faithtrait = user.traitHolder.getTrait("training_chaplain")
		. = list(
			"spell_slots" = faithtrait ? num2text(round(faithtrait.faith, 1)) : 0
		)

	ui_static_data(mob/user)
		var/list/spellbook_contents = list()
		for(var/datum/uplinkspell/spell as anything in src.spells)
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
			"owner_name" = "God",
			"spellbook_contents" = spellbook_contents,
			"vr" = src.vr
		)

	Spell_Purchased(mob/living/carbon/human/user, datum/uplinkspell/spell)
		. = ..()
		var/datum/trait/job/chaplain/faithtrait = user.traitHolder.getTrait("training_chaplain")
		faithtrait.faith -= spell.cost

	attack_self(mob/user)
		if(!user.mind || !user.traitHolder.hasTrait("training_chaplain"))
			boutput(user, SPAN_ALERT("It's just filled with nonsense!"))
			return

		ui_interact(user)

	ui_act(action, list/params)
		. = ..()
		if (.)
			return
		switch (action)
			if ("buyspell")
				var/datum/uplinkspell/chosen_spell = params["spell"]
				for (var/datum/uplinkspell/spell in src.spells)
					if (spell.name == chosen_spell)
						chosen_spell = spell
						break
				if (chosen_spell.CheckRequirements(usr,src))
					chosen_spell.Spell_Purchased(usr,src)


/datum/uplinkspell/spawntree
	name = "Decor: Tree"
	eqtype = "Decoration"
	desc = "Your deity causes a tree to sprout forth for your chapel. It requires a 3x3 area of open space. \
				\n Spell can be used once before needing to be repurchased."
	assoc_spell = /datum/targetable/faith_based/spawn_decoration/tree
	cost = 200

/datum/uplinkspell/spawnfire
	name = "Decor: Eternal Fire"
	eqtype = "Decoration"
	desc = "Your deity conjures for your chapel a mostly benign flame which will burn forever, without need for fuel. Just keep the firebots away \
			from it. \n Spell can be used once before needing to be repurchased."

	assoc_spell = /datum/targetable/faith_based/spawn_decoration/eternal_fire
	cost = 200


/datum/uplinkspell/candles
	name = "Alight and Snuff Candles"
	eqtype = "Ability"
	desc = "Grants two spells, one to light and one to snuff all candles in the chapel at once."
	assoc_spell = /datum/targetable/faith_based/alight_candles
	cost = 200

	Spell_Purchased(var/mob/living/carbon/human/user,var/obj/item/spellbook/book)
		..()
		user.abilityHolder.addAbility(/datum/targetable/faith_based/snuff_candles)

/datum/uplinkspell/chaplain_announcement
	name = "Booming Voice"
	eqtype = "Ability"
	desc = "Call out an announcement for the whole station."
	assoc_spell = /datum/targetable/faith_based/chaplain_announcement
	cost = 200

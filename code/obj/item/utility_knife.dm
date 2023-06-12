/obj/item/utility_knife
	name = "utility knife"
	desc = "A utility knife that functions as a crowbar. Very effective at clearing space flora."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "utility_knife"
	inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	item_state = "knife"

	flags = FPRINT | TABLEPASS | CONDUCT
	c_flags = ONBELT
	tool_flags = TOOL_PRYING | TOOL_CUTTING
	health = 5
	hit_type = DAMAGE_CUT
	hitsound = 'sound/impact_sounds/Flesh_Cut_1.ogg'
	w_class = W_CLASS_SMALL

	kudzu_force = 15
	force = 7
	throwforce = 12
	stamina_damage = 10
	stamina_cost = 8
	stamina_crit_chance = 10

	m_amt = 50
	custom_suicide = 1

	New()
		..()
		BLOCK_SETUP(BLOCK_KNIFE)

	attack(mob/living/carbon/M, mob/user)
		if (!pry_surgery(M, user))
			return ..()

	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] slits [his_or_her(user)] own throat with [src]!</b></span>")
		take_bleeding_damage(user, null, 150, src.hit_type, TRUE)
		user.take_oxygen_deprivation(100)
		user.TakeDamage("head", 90, 0)
		user.spread_blood_clothes(user)
		return 1

	security
		name = "Security utility knife"
		desc = "A Security-issue utility knife that functions as a crowbar. Very effective at clearing space flora."
		icon_state = "utility_knife_security"

	nt
		name = "NT utility knife"
		desc = "A corporate utility knife issued to elite Nanotrasen operatives. How you got it is a mystery."
		icon_state = "utility_knife_nt"

	syndicate
		name = "Security utility knife"
		desc = "A small knife with a sinister red grip. Luckily, this one is better at prying open doors than ribs."
		icon_state = "utility_knife_syndicate"

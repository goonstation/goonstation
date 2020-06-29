//=====
//Armor
//=====

/obj/item/clothing/head/helmet/men
    name = "men (面)"
    desc = "A light padded helmet with a grilled faceplate to protect the user in a kendo match."
    icon_state = "men"
    item_state = "men"
    seal_hair = 1

    setupProperties()
        ..()
        setProperty("coldprot", 10)
        setProperty("heatprot", 5)
        setProperty("meleeprot_head", 4)

/obj/item/clothing/suit/armor/douandtare
    name = "dou and tare (胴と垂れ)"
    desc = "A breastplate and padded skirt used primarily in kendo."
    icon_state = "dou-tare"
    item_state = "dou-tare"
    body_parts_covered = TORSO | LEGS
    c_flags = ONESIZEFITSALL
    bloodoverlayimage = SUITBLOOD_ARMOR

    setupProperties()
        ..()
        setProperty("coldprot", 10)
        setProperty("meleeprot", 10)
        setProperty("rangedprot", 1)
        setProperty("pierceprot", 5)
        setProperty("movespeed", 1)

/obj/item/clothing/gloves/kote
    name = "kote (小手)"
    desc = "Big poofy gloves to cover the hands in kendo sparring."
    icon_state = "kote"
    item_state = "kote"
    material_prints = "navy blue, synthetic leather fibers"
    crit_override = 1
    bonus_crit_chance = 0
    stamina_dmg_mult = 0.35

    setupProperties()
        ..()
        setProperty("coldprot", 7)
        setProperty("conductivity", 0.3)

//======
//Shinai
//======

/obj/item/shinai
    name = "shinai (竹刀)"
    desc = "A sword-like weapon made of slats of bamboo. Shinai are made to reflect the weight of a katana, but disperse impact on hit to minimize damage."
    icon = 'icons/obj/items/weapons.dmi'
    inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
    icon_state = "shinai"
    item_state = "shinai-light"

    w_class = 4.0
    two_handed = 1
    throwforce = 4.0
    throw_range = 4
    stamina_crit_chance = 2

    //these combat variables will change depending on the guard
    force = 6.0
    stamina_damage = 10
    stamina_cost = 5.0

    hit_type = DAMAGE_BLUNT
    flags = FPRINT | TABLEPASS | USEDELAY
    c_flags = EQUIPPED_WHILE_HELD
    item_function_flags = USE_INTENT_SWITCH_TRIGGER | USE_SPECIALS_ON_ALL_INTENTS
    //DEV - needs block profile

    var/guard

    proc/change_guard(var/mob/user,var/intent)
        guard = intent
        switch(guard)
            if("help")
                force = 6.0
                stamina_damage = 10
                stamina_cost = 5.0
                item_state = "shinai-light"
                src.setItemSpecial(/datum/item_special/simple/kendo_light)
            if("disarm")
                force = 7.0
                stamina_damage = 10
                stamina_cost = 8.0
                item_state = "shinai-sweep"
                src.setItemSpecial(/datum/item_special/swipe/kendo_sweep)
            if("grab")
                force = 8.0
                stamina_damage = 15
                stamina_cost = 10.0
                item_state = "shinai-thrust"
                src.setItemSpecial(/datum/item_special/rangestab/kendo_thrust)
            if("harm")
                force = 10.0
                stamina_damage = 25
                stamina_cost = 30.0
                item_state = "shinai-heavy"
                item_state = "shinai-heavy"
                src.setItemSpecial(/datum/item_special/simple/kendo_heavy)
        user.update_inhands()
        src.buildTooltipContent()

    proc/parry_block_check(var/mob/living/carbon/human/attacker,var/mob/living/carbon/human/defender)
        if((attacker.a_intent == defender.a_intent) && !defender.hasStatus("disorient"))
            //visuals
            //sound

            //stagger opponent
            attacker.do_disorient()
            SPAWN_DBG(1 SECOND)
                attacker.delStatus("disorient")
            return 1

        //check for blocking after parrying

        return 0

    intent_switch_trigger(mob/user as mob)
        if(guard != user.a_intent)
            change_guard(user,user.a_intent)

    attack(mob/living/carbon/human/defender as mob, mob/living/carbon/human/attacker as mob)
        if(ishuman(defender))
            //var/mob/living/carbon/human/D = defender
            if(defender.equipped() && istype(defender.equipped(),/obj/item/shinai))
                var/obj/item/shinai/S = defender.equipped()
                var/parry_block = S.parry_block_check(attacker,defender)
                if((parry_block == 1) || (parry_block == 2))
                    return
        ..()

    attack_hand(mob/user as mob)
        if(src.loc != user)
            change_guard(user,user.a_intent)
        ..()

    dropped(mob/user as mob)
        ..()
        force = 6.0
        stamina_damage = 10
        stamina_cost = 5.0
        item_state = "shinai-light"
        src.setItemSpecial(/datum/item_special/simple/kendo_light)

//==========
//Shinai Bag
//==========

/obj/item/shinai_bag
    name = "shinai bag (竹刀袋)"
    desc = ""
    wear_image_icon = 'icons/mob/back.dmi'
    icon_state = "shinaibag-closed"
    item_state = "shinaibag-closed"
    flags = ONBACK | FPRINT | TABLEPASS
    w_class = 4.0
    var/open = 0
    var/shinai = 2

    proc/update_spront(var/mob/user)
        if(!open)
            src.icon_state = "shinaibag-closed"
            src.item_state = "shinaibag-closed"
        else
            src.icon_state = "shinaibag-[shinai]"
            src.item_state = "shinaibag-[shinai]"

        if(src.loc == user)
            user.update_clothing()
            user.update_inhands()

    proc/draw_shinai(var/mob/user)
        if(shinai)
            var/obj/item/shinai/S = new /obj/item/shinai
            user.put_in_hand_or_drop(S)
            S.change_guard(user,user.a_intent)
            shinai--
            update_spront(user)

        else
            user.show_text("The [src] is empty!","red")

    attack_self(mob/user as mob)
        open = !open
        update_spront(user)

    attack_hand(mob/user as mob)
        if(src.loc == user)
            if(open)
                draw_shinai(user)
            else
                open = !open
                update_spront(user)
        else if((user.a_intent == "grab") && open)
            draw_shinai(user)
        else
            ..()

    attackby(obj/item/W as obj, mob/user as mob)
        if(istype(W,/obj/item/shinai) && open && (shinai<2))
            user.u_equip(W)
            qdel(W)
            shinai++
            update_spront(user)
        else
            ..()

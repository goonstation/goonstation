/datum/abilityHolder/carnival
    usesPoints = 0
    regenRate = 0
    tabName = "Carnival"

/datum/targetable/carnival/cant //defaults to clown version
    name = "Carnival Cant"
    desc = "A secret language that only entertainers know! This one in particular is a form of sign language!"
    icon_state = "cant-clown"
    targeted = 0
    cooldown = 0
    pointCost = 0

    cast()
        if(!holder)
            return TRUE
        if(!ishuman(holder.owner))
            return
        var/mob/living/carbon/human/OWNER = holder.owner
        if(!OWNER.limbs.l_arm && !OWNER.limbs.r_arm)
            OWNER.show_text("You can't speak Carnival Cant without arms!","red")
        var/message = input(OWNER, "What would you like to say?", "Carnival Cant") as null|text
        if(!length(message) || (copytext(message,1,2) == " "))
            message = null
        if(!message)
            return
        var/list/gibberish = list("looks like [he_or_she(OWNER)] is trying to speak a really awkward sign language...",
        "looks as if [he_or_she(OWNER)] is trying to communicate with [his_or_her(OWNER)] fingers...",
        "twiddles [his_or_her(OWNER)] fingers strangley...", "forms interesting symbols with [his_or_her(OWNER)] fingers...",
        "flaps [his_or_her(OWNER)] hands around like a butterfly...")
        SPAWN_DBG(0)
            var/old_x = OWNER.pixel_x
            var/old_y = OWNER.pixel_y
            OWNER.pixel_x += rand(-3,3)
            OWNER.pixel_y += rand(-1,1)
            sleep(0.2 SECONDS)
            OWNER.pixel_x = old_x
            OWNER.pixel_y = old_y
        for(var/mob/LISTENER in viewers(OWNER,10))
            if(LISTENER.blinded)
                continue
            if((LISTENER.job == "Clown") || (LISTENER.job == "Mime") || isAI(LISTENER) || isobserver(LISTENER))
                LISTENER.show_text("[OWNER.name] signs, \"[message]\"","pink")
            else
                LISTENER.show_text("[OWNER.name] [pick(gibberish)]","pink")
        logTheThing("say", OWNER, OWNER.name, "[message]")

/datum/targetable/carnival/cant/mime
    icon_state = "cant-mime"
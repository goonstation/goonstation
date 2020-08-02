// -------------------------
// Martian telepathy
// -------------------------
/datum/targetable/critter/telepathy
  name = "Telepathy"
  desc = "Move your thoughts into the mind of another sapient being."
  cooldown = 10
  targeted = 1
  target_anything = 1

  // shamelessly stolen from wraith, hi copy paste code, did you miss me - cirr
  cast(atom/target)
    if (..())
      return 1

    if (ismartian(target))
      boutput(holder.owner, "<span class='alert'>They can hear you just fine without the use of your abilities.</span>")
    else if (isliving(target))
      var/mob/living/T = target
      if(!T)
        return
      if (isdead(T))
        boutput(holder.owner, "<span class='alert'>You can't talk to dead brains!</span>")
        return 1
      else
        var/message = html_encode(input("What would you like to communicate to [target]?", "Telepathy", "") as text)
        logTheThing("say", holder.owner, target, "MARTIAN TELEPATHY TO [constructTarget(target,"say")]: [message]")
        message = trim(copytext(sanitize(message), 1, 255))
        var/class = "martiansay"
        if(istype(holder.owner, /mob/living/critter/martian/overseer))
          class = "martianimperial"
        boutput(holder.owner, "<span class='[class]'><b>You make contact with the mind of [target]:</b> [message]</span>")
        boutput(target, "<span class='[class]'><b>An alien voice echoes in your mind... </b> [message]</span>")

        // it'd be nice to let admins know what's been said
        var/adminrendered = "<span class='game [class]'><span class='name' data-ctx='\ref[holder.owner.mind]'>[holder.owner.real_name]</span> telepathies <span class='name' data-ctx='\ref[T.mind]'>[T.real_name]</span>:<span class='message'>\"[message]\"</span></span>"

        for (var/client/C)
          var/mob/M = C.mob
          if(istype(M, /mob/new_player))
            continue

          if (M.client && M.client.holder && !M.client.player_mode)
            var/thisR = "<span class='adminHearing' data-ctx='[M.client.chatOutput.getContextFlags()]'>[adminrendered]</span>"
            M.show_message(thisR, 2)
    else
      boutput(holder.owner, "<span class='alert'>You can't sense a mind to contact.</span>")
      return 1

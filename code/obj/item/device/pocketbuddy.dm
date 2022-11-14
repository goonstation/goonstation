// POCKETBUDDY code by CIRR, All Blames Accepted 2017
// Credit to locusts, Wire and AIBM for this that and the other.

#define POCKETBUDDY_POWER_DRAW 1

#define POCKETBUDDY_EMOTE_VISUAL 1
#define POCKETBUDDY_EMOTE_AUDIBLE 2

/datum/

// Event system that will need integration into existing event system
/datum/event
  var/client/source // source client if applicable
  var/time // time of day when event was sent

/datum/event/death
  var/readableCause = "unknown" // a string that can be optionally used to state cause of death

/datum/event/item
  var/obj/item/sourceItem

/datum/event/item/flushed

/datum/event/item/thrown

/datum/event/item/eaten

// events that need to be reported somehow for this to work:
// - player death
// - player eats something
// - item flushing
// - item thrown
// everything else can be handled in the pocketbuddy's process loop or direct action tbh, they otherwise don't need instantaneous reactions

/datum/event_dispatcher

/var/global/datum/event_dispatcher/event_dispatcher = new()

///proc/hook_event(/event/E, var/)

///evt
//    var/client/source //client of event origin, if available.
//    var/time //when the event was sent
///evt/chat
//    var/mob/sender
//    var/message = ""
//    radio
//        var/frequency = 0
//    blob
//    ooc
//    ghostdrone
//    dead
//...
//hook_event( /evt/chat, src, "onChat" )
//hook_event( /evt/chat, "onChatGlobal" )
//...
//proc/onChatGlobal( var/evt/chat/data )
//    data.message = "[data.message]...hic!"
//    if(istype( data, /evt/chat/ooc ))
//        if( data.source.ooc_muted )
//            return true//abort!


///client/verb/OOC(var/txt as text)
//    EVENT(chat/ooc)
//    world << EVT
//    EVT.client = src
//    EVT.message = txt
//    EVT.send()
//    world << "<span style='color:#22c'>OOC [src]: [html_encode(EVT.message)]</span>"
///proc/ChatFilter(var/event/chat/ooc/E)
//    E.message = "\"[E.message]\" said [E.client.key]. Weird."
//EVENT_HOOK(/event/chat/ooc, "OOC Modifier", /proc/ChatFilter)

/obj/item/device/pocketbuddy
  name = "Pocketbuddy"
  desc = "A whole lot of love in a tiny little box. Treat it well!"
  // TODO: ACTUAL GRAPHICS
  icon_state = "atmos"
  item_state = "analyzer"
  rand_pos = 1
  w_class = W_CLASS_SMALL
  flags = FPRINT | TABLEPASS | ONBELT
  var/on = 0
  var/sleep = 0
  var/muted = 0
  health = 20
  var/area/prev_area = null
  var/asleep = 0

// note to self: as suggested by wire, i am probably going to want some sort of event messaging system
// generic for further use, with pocketbuddy as a trial
// event system: subscribers and publishers to the event datum, as required
// also good for debugging and tracking would be capturing event messages for logging

/obj/item/device/pocketbuddy/New()
  ..()
  AddComponent(src, /datum/component/cell_holder, new/obj/item/ammo/power_cell) // TODO: a more buddy-specific cell (maybe even a new power cell type?)
  // TODO: subscribe to global event system/child system thereof for pocketbuddies?
  src.prev_area = get_area(src)

/obj/item/device/pocketbuddy/attackby(obj/item/I, mob/user)
  if(istype(I, /obj/item/device/pda2))
    var/obj/item/device/pda2/pda = I
    if(pda.ID_card)
      I = pda.ID_card

  if(istype(I, /obj/item/card/id))
    src.speak(src.get_quip_for("registered"))
  else
    ..()


/obj/item/device/pocketbuddy/attack_hand(mob/user)
  if(..())
    return

/obj/item/device/pocketbuddy/attack_self(mob/user as mob)
  if(!src.on)
    if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE) & CELL_SUFFICIENT_CHARGE)
      boutput(user, "<span class='notice'>You turn the pocketbuddy on!</span>")
      turn_on()
    else
      boutput(user, "<span class='alert'>You try to turn the pocketbuddy on, but nothing happens.</span>")
  else
    // apply PETS to BUDDY
    boutput(user, "<span class='notice'>You pet the buddy!</span>")
    // src.react_to_pets



// processing_items is the list of items to process

/obj/item/device/pocketbuddy/proc/turn_on()
  src.on = 1
  playsound(src, 'sound/machines/twobeep.ogg', 50, 1)
  //speak("Pocketbuddy v0.9 - Copyright 2051-2053 Thinktronic Data Systems, LTD.")
  src.speak("System message. Pocketbuddy v0.9 initializing.")
  sleep(2 SECONDS)
  src.speak(src.get_quip_for("init"))
  processing_items |= src

/obj/item/device/pocketbuddy/proc/turn_off()
  src.speak("Pocketbuddy shutting down.")
  playsound(src, 'sound/machines/twobeep.ogg', 50, 1)
  src.on = 0
  processing_items -= src

/obj/item/device/pocketbuddy/process()
  src.manage_power()
  var/area/here = get_area(src)
  var/list/ret = list()
  if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
    src.speak("Power: [ret["charge"]].")
  if(here != src.prev_area)
    src.prev_area = here
    src.speak(src.get_quip_for(here))


/obj/item/device/pocketbuddy/proc/manage_power()
  if(!on) return 1

  if(!(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE) & CELL_SUFFICIENT_CHARGE))
    turn_off()
    return 1

  var/to_draw = POCKETBUDDY_POWER_DRAW
  if(asleep)
    to_draw = (to_draw / 4)

  SEND_SIGNAL(src, COMSIG_CELL_USE, to_draw)

  //if(cell.charge < GUARDBOT_LOWPOWER_IDLE_LEVEL)
  //  speak("Critical battery.")
  //  src.snooze()
  //  return 0

  //if(cell.charge < GUARDBOT_LOWPOWER_ALERT_LEVEL && !(locate(/datum/computer/file/guardbot_task/recharge) in src.tasks) )
  //  src.add_task(/datum/computer/file/guardbot_task/recharge,1,0)
  //  return 0

  return 0


/obj/item/device/pocketbuddy/proc/react_to_pets()
  if(!src.on)
    return // you pet the inanimate plastic box. no response
  // DEBUG: always react
  if(prob(20))
    src.speak(src.get_quip_for("pet"))
  else
    // flip a coin for visual or audible emote
    if(prob(50))
      src.emote(src.get_quip_for("pet_emote_visible"), POCKETBUDDY_EMOTE_VISUAL)
    else
      src.emote(src.get_quip_for("pet_emote_audible"), POCKETBUDDY_EMOTE_AUDIBLE)

// stolen from bot_parent because why not add more goddamn copy paste to everything
/obj/item/device/pocketbuddy/proc/speak(var/message)
  if (!src.on || !message || src.muted)
    return
  // using the consolas font for now because these are not gonna have the best speech synthesizers
  src.audible_message("<span class='game say'><span class='name'>[src]</span> beeps, \"<span style='font-family: Consolas;'>[message]</span>\"")
  // TODO: check for installed peripherals and modify message appropriately

/obj/item/device/pocketbuddy/proc/emote(var/emote, var/type)
  if(!emote || !type)
    return
  if(type & POCKETBUDDY_EMOTE_VISUAL)
    src.visible_message("<span class='game say'><span class='name'>[src]</span> [emote]!</span>\"")
  if(type & POCKETBUDDY_EMOTE_AUDIBLE)
    src.audible_message("<span class='game say'><span class='name'>[src]</span> [emote]!</span>\"")

/obj/item/device/pocketbuddy/proc/get_quip_for(var/situation)
  // TODO: this, this should use all the personality data to select and process an appropriate quip
  // a) first find things based on personality
  // b) filter based on situation, pick a quip
  // c) process quip for any $TOKENS it might have and return
  . = "[situation]" // for now just parrot back the string


// Take the $THINGS and swap them out for other things
/obj/item/device/pocketbuddy/proc/parse_inline(var/message)


















// This datum exists to get the identification of simpler things out of the pocketbuddy code.
// Maybe it could be made more generalised? Who knows.
///datum/pocketbuddy/recognised_categories
//  var/list/area_categories = list(
//    "disposals"=/area/station/maintenance/disposal,
//    "cafeteria"=list(/area/station/crew_quarters/cafeteria, /area/station/crew_quarters/bar),
//    "quarters"=/area/station/crew_quarters/,
//    "research"=list(/area/station/artifact,/area/station/science/),
//    "hydro"=/area/station/hydroponics,
//    "brig"=/area/station/security/brig,
//    "sec"=/area/station/security,
//    "bridge"=/area/station/bridge,
//    "qm"=/area/station/quartermaster,
//    "engine"=/area/station/engine,
//    "mining"=/area/mining,
//    "shuttle"=area/shuttle_transit_space,
//    "centcom"=/area/centcom,
//    "space_diner"=/area/diner,
//    "radio_shack"=null, // INTEGRATION: PLEASE ADD RADIO SHACK AREAS TO THIS LIST
//    "maint"=list(/area/station/maintenance,/area/station/storage),
//    // oh christ, INTEGRATION: ANYTHING ESPECIALLY UNDEAD OR SPOOKY I MISSED
//    "spooky"=list(/area/abandonedmedicalship, /area/crypt, /area/mausoleum, /area/h7, /area/helldrone, /area/morgue, /area/hospital, /area/crunch, /area/solarium), // solarium. haaaaaa
//    "medical"=/area/station/medical, // after spooky so morgue doesn't get swallowed
//    )
//  // anything else is treated as area category unknown

//  // please put more specific categories at the top!!
//  // more general should go further to the bottom
//  var/list/nonhuman_categories = list(
//      "bee"=/obj/critter/domestic_bee,
//      "blob"=/obj/blob,
//      "robuddy"=/obj/machinery/bot/guardbot,
//      "clown"=list(/obj/critter/clownspider), // INTEGRATION: please add queen clownspider to this list
//      "cluwne"=list(/obj/critter/cluwnespider), // INTEGRATION: please add queen cluwnespider to this list
//      "critter"=/obj/critter, // it is vital that this goes after the more specific ones
//    )

//  // PLEASE GOD HAVE MERCY ON ME FOR HOW FUCKED UP LAGGY THIS WILL BE PROBABLY
//  proc/get_category_for_thing(var/atom/T)
//    // default value is null because we shouldn't be commenting on every goddamn pen and cupholder we see
//    // this would probably be faster if i stored the areas as the keys and categories as values
//    // but fuuuuuck that
//    // maybe I'll come back to this and generate some initial lookup tables or something
//    // or write myself a new data format?
//    var/category_list = nonhuman_categories
//    if(isturf(T))
//      a
//    if(isarea(T))
//      . = "unknown"
//      // let's first check if we're in space because we might just be in space
//      if(thing.name == "Space")
//        return "space"
//      category_list = area_categories
//    for(var/category in category_list)
//      if(islist(category))
//        for(var/subList in category)
//          if(T in category_lists[category])
//            return category
//      else if(istype(T, category_list[category]))
//        return category

#undef POCKETBUDDY_POWER_DRAW
#undef POCKETBUDDY_EMOTE_VISUAL
#undef POCKETBUDDY_EMOTE_AUDIBLE

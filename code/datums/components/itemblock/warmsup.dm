//example component for itemblocks - heats up the user on life tick while blocking, and adds 25% cold resist to the block
/datum/component/itemblock/warmsup
	signals = list(COMSIG_LIVING_LIFE_TICK) //signal that this component is listening for. COMSIG_LIVING_LIFE_TICK is sent once per Life loop, as defined in Life.dm
	mobtype = /mob/living/carbon/human //Component will only register for the signal if the mob blocking is of this type, in this case, human
	bonus = 1 //bonus is a flag that determines whether or not the item tooltip will include "⛨ Block+: RESIST with this item for more info" when not blocking
	proctype = .proc/warmup //the proc to be called when this component recieves the signal it is listening for, in this case, COMSIG_LIVING_LIFE_TICK

/datum/component/itemblock/warmsup/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_BLOCK_TOOLTIP_BLOCKING_APPEND, .proc/append_to_tooltip)

//arguments are sent from the the SendSignal() in Life.dm:140
//SEND_SIGNAL(src, COMSIG_LIVING_LIFE_TICK, (life_time_passed / tick_spacing))
//first argument, src, is the atom to be sending the signal to, and is also the first argument of the proc triggered by the signal
//second argument, COMSIG_LIVING_LIFE_TICK, is the type of signal that was send. This matches the signal we are registered to,
//(registering for the signal happened in /datum/component/itemblock/proc/on_block_begin()), so this triggers the proc below
//third argument, (life_time_passed / tick_spacing), is the tick spacing multiplier for the Life Loop. Signalled procs may have any number of additional arguments, but ours only has one.
/datum/component/itemblock/warmsup/proc/warmup(mob/living/carbon/human/H, var/mult)
	if(parent != H.equipped())
		return //do nothing if not in active hand
	if(H.bodytemperature < H.base_body_temp) // Shamelessly copy-pasted from coffee
		H.bodytemperature = min(H.base_body_temp, H.bodytemperature+(5 * mult))

//proc that is called when the base item is used to block. The parent itemblock component has already registered this proc for the "COMSIG_ITEM_BLOCK_BEGIN" signal
//This gives the block some cold resistance. Properties on a block are generally only counted if the block is held in the active hand
/datum/component/itemblock/warmsup/on_block_begin(obj/item/I, var/obj/item/grab/block/B)
	. = ..()//Always call your parents. This makes sure that we get properly registered for the COMSIG_ON_HUMAN_LIFE signal, among other things
	B.setProperty("coldprot", 25) //add the property to the block, not to the item

//proc that is called when the block is ended. The parent itemblock component has already registered this proc for the "COMSIG_ITEM_BLOCK_END" signal
//now that the block is ended, we want to remove the property from the block. This is probably not strictly necessary, but it is best practice to clean up after ourselves
/datum/component/itemblock/warmsup/on_block_end(obj/item/I, var/obj/item/grab/block/B)
	. = ..()//always always always.
	B.delProperty("coldprot") //again, delete property from the block, not the item

//tooltip line that gets appended to the block section of the parent item's tooltip when blocking with it.
/datum/component/itemblock/warmsup/proc/append_to_tooltip(parent, list/tooltip)
	if(showTooltip) //only add the line if there's an active block on the item
		tooltip += itemblock_tooltip_entry("special.png", "Warms you up over time!") //macro to handle indentation and other HTML stuff.

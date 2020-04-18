#define itemblock_tooltip_entry(img, desc) "<br><img style=\"display:inline;margin:0\" width=\"12\" height=\"12\" /><img style=\"display:inline;margin:0\" src=\"[resource("images/tooltips/[img]")]\" width=\"12\" height=\"12\" /> [desc]"
// A dummy parent type used for easily making components that are active when blocking with an item

/datum/component/itemblock
	var/list/signals = list()			//signals to register the blocking mob to
	var/proctype // = .proc/pass		//proc to be called by when we recieve a signal in 'signals()'
	var/mobtype = /mob/living			//what type of mobs should we register above stuff to?
	var/bonus = 0						//do we need tooltips at all? This should be set to true on any child component that either adds properties to the block, or has a tooltip entry
	var/showTooltip = 0					//are we currently showing extra tooltip stuff? check this in getTooltipDesc


/datum/component/itemblock/Initialize()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ITEM_BLOCK_BEGIN, .proc/on_block_begin)
	RegisterSignal(parent, COMSIG_ITEM_BLOCK_END, .proc/on_block_end)
	var/obj/item/I = src.parent
	if(bonus)
		I.setProperty("block_bonus", 1) //adds a "Block+" tooltip line telling the player they can RESIST to block with this item for special effects

/datum/component/itemblock/proc/on_block_begin(obj/item/I, mob/user)
	if(istype(user, mobtype)) //make sure only things that we want are getting signals registered for them
		RegisterSignal(user, signals, proctype, TRUE) //start listening for signals from the user
	else
		UnregisterSignal(user, signals)
	if(bonus)
		I.setProperty("block_bonus", 0) //changes the "Block+" tooltip line to tell the player that the (now listed) effects are only active if the itemblock is held in the active hand
		showTooltip = 1 //show any custom tooltip stuff

/datum/component/itemblock/proc/on_block_end(obj/item/I, mob/user)
	UnregisterSignal(user, signals) //block over, quit listening
	if(bonus)
		I.setProperty("block_bonus", 1) //reset the Block+ tooltip line
		showTooltip = 0 //hide our tooltips, if any

/datum/component/itemblock/getTooltipDesc()
	. = ..()//always call your parents here.

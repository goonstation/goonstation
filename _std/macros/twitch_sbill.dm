//#define TWITCH_BOT_ALLOWED
#define TWITCH_BOT_ADDR "xxx.xxx.xxx.xxx"
#define TWITCH_BOT_CKEY "twitchbill"

#define IS_TWITCH_CONTROLLED(M) (M.client && M.client.ckey == TWITCH_BOT_CKEY)
#define TWITCH_BOT_AUTOCLOSE_BLOCK(X) (X == "mainwindow" || X == "screenSizeHelper")
#define TWITCH_BOT_INTERACT_BLOCK(X) (istype(X,/obj/item/hand_labeler) || istype(X,/obj/item/paper) || istype(X,/obj/storage/crate/loot) || istype(X,/obj/machinery/vending) || istype(X,/obj/submachine/ATM) || istype(X,/obj/item/pen/crayon))

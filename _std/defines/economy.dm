// Defines for economy module

/// Symbol for credits, used AFTER the number
#define CREDIT_SIGN "⪽"

// Requisition defines
#define MISC_CONTRACT 0
#define CIV_CONTRACT 1
#define AID_CONTRACT 2
#define SCI_CONTRACT 3

#define FOOD_REQ_BY_ITEM 0
#define FOOD_REQ_BY_BITE 1
#define FOOD_REQ_INTACT 2

#define REQ_RETURN_NOSALE 0
#define REQ_RETURN_SALE 1
#define REQ_RETURN_FULLSALE 2

// PIN defines
#define PIN_MIN 1000
#define PIN_MAX 9999

/mob/proc/enter_pin(title="ID PIN")
	. = tgui_input_pin(src, "Please enter your PIN:", title, src.mind?.remembered_pin || null, PIN_MAX, PIN_MIN)
	if(. && src.mind && isnull(src.mind.remembered_pin))
		src.mind.remembered_pin = .

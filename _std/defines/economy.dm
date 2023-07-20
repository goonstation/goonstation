// Defines for economy module

/// Symbol for credits, used AFTER the number
#define CREDIT_SIGN "⪽"

// Requisition defines
#define MISC_CONTRACT 0
#define CIV_CONTRACT 1
#define AID_CONTRACT 2
#define SCI_CONTRACT 3

#define REQ_RETURN_NOSALE 0
#define REQ_RETURN_SALE 1
#define REQ_RETURN_FULLSALE 2

/mob/proc/enter_pin(title="ID PIN number")
	. = input(src, "Please enter your PIN number:", title, src.mind?.remembered_pin) as num | null
	if(src.mind && isnull(src.mind.remembered_pin))
		src.mind.remembered_pin = .

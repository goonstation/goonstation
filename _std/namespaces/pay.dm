/// Standardised quantities of credits.
CREATE_NAMESPACE(PAY)

/// e.g. Clown wage.
ADD_TO_NAMESPACE(PAY)(var/const/DUMBCLOWN = 1)
/// e.g. Staff Assistant wage.
ADD_TO_NAMESPACE(PAY)(var/const/UNTRAINED = 150)
/// e.g. Miner wage.
ADD_TO_NAMESPACE(PAY)(var/const/TRADESMAN = 300)
/// e.g. Scientist wage.
ADD_TO_NAMESPACE(PAY)(var/const/DOCTORATE = 600)
/// e.g. Head of Staff wage.
ADD_TO_NAMESPACE(PAY)(var/const/IMPORTANT = 1200)
/// e.g. Captain wage.
ADD_TO_NAMESPACE(PAY)(var/const/EXECUTIVE = 2400)
/// e.g. High-end requisition contracts.
ADD_TO_NAMESPACE(PAY)(var/const/EMBEZZLED = 5000)
/// e.g. We actually don't want you to buy this.
ADD_TO_NAMESPACE(PAY)(var/const/DONTBUYIT = 25000)

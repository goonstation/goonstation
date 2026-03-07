/// e.g. clown
#define PAY_DUMBCLOWN 1
/// e.g. staffie
#define PAY_UNTRAINED 150
// e.g. miner
#define PAY_TRADESMAN 300
/// e.g. scientist
#define PAY_DOCTORATE 600
/// e.g. head
#define PAY_IMPORTANT 1200
/// e.g. captain
#define PAY_EXECUTIVE 2400
/// e.g. you cheated somehow
#define PAY_EMBEZZLED 5000

//Prices below are just categories, most actual prices are some percentage of their category
//So if you want an item to cost 20, do PRICE_RECURRING_CHEAP*0.2, assuming PRICE_RECURRING_CHEAP is 100.
//But don't use PRICE_RECURRING*0.1 just to get a number you could get with a lower category

///Clown life
#define PRICE_PISS 1

///Recurring costs are something you'd expect to buy regularly, like food or supplies
#define PRICE_RECURRING_CHEAP 100
#define PRICE_RECURRING 200
#define PRICE_RECURRING_COSTLY 300 //Wow, as expensive as a tradesman salary!

///Luxury costs are items that are really nice, typically one off purchases, not mandatory but you'd like to have one
#define PRICE_LUXURY_CHEAP 1000 //Might be able to get a couple of these
#define PRICE_LUXURY 3000 //You can maybe get 2 of these
#define PRICE_LUXURY_COSTLY 5000 //You can at best afford one of these a round unless you're high ranking

///Need I say more?
#define PRICE_EXORBITANT 10000 //Big moni
#define PRICE_RICHES_OF_HEAVEN_AND_EARTH 100000 //Either you're buying plutonium or getting scammed

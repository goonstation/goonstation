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

#define PRICE_RECURRING_CHEAP*0.1 10
#define PRICE_15 15
#define PRICE_18_75 19
#define PRICE_25 25
#define PRICE_30 30
#define PRICE_37_5 38
#define PRICE_15 15
#define PRICE_20 20
#define PRICE_50 50
#define PRICE_60 60
#define PRICE_75 75
#define PRICE_RECURRING_CHEAP 100
#define PRICE_RECURRING*0.6 120
#define PRICE_RECURRING*0.75 150
#define PRICE_RECURRING 200
#define PRICE_RECURRING_COSTLY*0.8 240
#define PRICE_RECURRING_COSTLY 300
#define PRICE_LUXURY_CHEAP*0.4 400
#define PRICE_LUXURY_CHEAP*0.45 450
#define PRICE_LUXURY_CHEAP*0.48 480
#define PRICE_LUXURY_CHEAP*0.6 600
#define PRICE_LUXURY_CHEAP*0.9 900
#define PRICE_LUXURY*0.4 1200
#define PRICE_LUXURY*0.5 1500
#define PRICE_LUXURY*0.6 1800
#define PRICE_LUXURY*0.8 2400
#define PRICE_LUXURY 3000
#define PRICE_LUXURY_COSTLY*0.72 3600
#define PRICE_LUXURY_COSTLY*0.9 4500
#define PRICE_LUXURY_COSTLY*0.96 4800
#define PRICE_LUXURY_COSTLY 5000
#define PRICE_EXORBITANT*0.6 6000
#define PRICE_EXORBITANT*0.75 7500
#define PRICE_EXORBITANT*0.9 9000

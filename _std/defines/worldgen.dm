#define AST_MINSIZE 7        //Min range before rng kicks in
#define AST_REDUCTION 9	     //prob reduction per 1 tile over min size
#define AST_SIZERANGE 4      //+- mod on asteroid size, i.e. 4 = 4 tiles smaller to 4 tiles larger.
#define AST_TILERNG 20       //+- range of flat rng applied to tile placement
#define AST_SEEDS 40         //Base amount of asteroid seeds. Actual amount of asteroids works out to be significantly less.
#define AST_RNGWALKCNT 7     //Amount of asteroid tiles to dig out during random walk.
#define AST_RNGWALKINST 5    //How many random walks should we do per asteroid.

#ifdef UNDERWATER_MAP
#define AST_NUMPREFABS 18     //How many prefabs to place. It'll try it's hardest to place this many at the very least. You're basically guaranteed this amount of prefabs.
#define AST_NUMPREFABSEXTRA 6//Up to how many extra prefabs to place randomly. You might or might not get these extra ones.
#else
#define AST_NUMPREFABS 11     //How many prefabs to place. It'll try it's hardest to place this many at the very least. You're basically guaranteed this amount of prefabs.
#define AST_NUMPREFABSEXTRA 5//Up to how many extra prefabs to place randomly. You might or might not get these extra ones.
#endif

#define AST_MAPSEEDBORDER 10 //Min distance from map edge for seeds.
#define AST_MAPBORDER 3      //Absolute map border around generated content
#define AST_ZLEVEL 5         //Zlevel for generation.

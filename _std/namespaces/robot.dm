CREATE_NAMESPACE(ROBOT)

/// Default move delay values for various bots. Note that this is move delay, so lower is faster.
CREATE_NAMESPACE(ROBOT, SPEED)
ADD_TO_NAMESPACE(ROBOT, SPEED)(var/const/DEFAULT = 6)
ADD_TO_NAMESPACE(ROBOT, SPEED)(var/const/BARBOT = 7)
ADD_TO_NAMESPACE(ROBOT, SPEED)(var/const/BUTTBOT = 10)
ADD_TO_NAMESPACE(ROBOT, SPEED)(var/const/CAMBOT = 8)
ADD_TO_NAMESPACE(ROBOT, SPEED)(var/const/CHEFBOT = 8)
ADD_TO_NAMESPACE(ROBOT, SPEED)(var/const/CLEANBOT = 10)
ADD_TO_NAMESPACE(ROBOT, SPEED)(var/const/DUCKBOT = 8)
ADD_TO_NAMESPACE(ROBOT, SPEED)(var/const/FIREBOT = 8)
ADD_TO_NAMESPACE(ROBOT, SPEED)(var/const/FLOORBOT = 7)
ADD_TO_NAMESPACE(ROBOT, SPEED)(var/const/MEDBOT = 6)
ADD_TO_NAMESPACE(ROBOT, SPEED)(var/const/SECBOT_PATROL = 6)
ADD_TO_NAMESPACE(ROBOT, SPEED)(var/const/SECBOT_SUMMON = 3)
ADD_TO_NAMESPACE(ROBOT, SPEED)(var/const/SECBOT_ARREST = 2.5)

ADD_TO_NAMESPACE(ROBOT, SPEED)(var/const/GUARDBOT_FAST = 2) //! The fastest that the guardbot can move
ADD_TO_NAMESPACE(ROBOT, SPEED)(var/const/GUARDBOT_SLOW = 3) //! The slowest that the the guardbot will move
ADD_TO_NAMESPACE(ROBOT, SPEED)(var/const/GUARDBOT_RATE_SLOW = 0) //! Default move delay of 3
ADD_TO_NAMESPACE(ROBOT, SPEED)(var/const/GUARDBOT_RATE_ARREST = 0.5) //! Default move delay of 2.5
ADD_TO_NAMESPACE(ROBOT, SPEED)(var/const/GUARDBOT_RATE_FULL = 1) //! Default move delay of 2

/// Different modes for bot AI
CREATE_NAMESPACE(ROBOT, MODE)
CREATE_NAMESPACE(ROBOT, MODE, SECBOT)
ADD_TO_NAMESPACE(ROBOT, MODE, SECBOT)(var/const/IDLE = 0) //! Idle, handles routing to basic patrol-or-dont secbotting
ADD_TO_NAMESPACE(ROBOT, MODE, SECBOT)(var/const/AGGRO = 1) //! Bot is angry, chasing someone or arresting them
ADD_TO_NAMESPACE(ROBOT, MODE, SECBOT)(var/const/START_PATROL = 2) //! Starting patrol, looking for a patrol node
ADD_TO_NAMESPACE(ROBOT, MODE, SECBOT)(var/const/PATROL = 3) //! On patrol!
ADD_TO_NAMESPACE(ROBOT, MODE, SECBOT)(var/const/SUMMON = 4) //! Summoned by PDA
ADD_TO_NAMESPACE(ROBOT, MODE, SECBOT)(var/const/GUARD_IDLE = 5) //! Idle again, but handles routing for guard-related stuff
ADD_TO_NAMESPACE(ROBOT, MODE, SECBOT)(var/const/GUARD_START = 6) //! Was ordered to guard an area. Checking to see if that's something it can do
ADD_TO_NAMESPACE(ROBOT, MODE, SECBOT)(var/const/GUARD = 7) //! Currently guarding an area and milling about like an asshole
ADD_TO_NAMESPACE(ROBOT, MODE, SECBOT)(var/const/GUARD_AGGRO = 8) //! Bot is angry, but was guarding an area and should go back to guarding after this

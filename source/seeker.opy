#!mainFile "settings.opy"

rule "Seeker Setup":
    @Event eachPlayer
    @Team 2
    
    # Seeker Setup
    eventPlayer.setAllowedHeroes(getAllHeroes().exclude([Hero.MOIRA, Hero.ZENYATTA, Hero.SOMBRA]) if not WORKSHOP_SET_ADV_SEEK_ALLOWH else getAllHeroes())

    # Mercy V. Rein
    switch WORKSHOP_SET_MODE:
        case STYLE.MERCY_REIN:
            eventPlayer.setAllowedHeroes(Hero.REINHARDT)
            eventPlayer.setMoveSpeed(eventPlayer.BaseMoveSpeed * 2)
            eventPlayer.setJumpVerticalSpeed(eventPlayer.BaseJumpHeight * 1.75)
            eventPlayer.setSecondaryFireEnabled(false)
            break
        default:
            break
    
    waitUntil(eventPlayer.hasSpawned(), 9999)

    getPlayers(Team.1).startForcingOutlineFor(eventPlayer, WORKSHOP_SET_USEOUTLINE, Color.TEAM_1, OutlineVisibility.DEFAULT)

    waitUntil(not eventPlayer.isInSpawnRoom(), 9999)

    eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 9999)

    printLog("Seeker Setup finished for {}".format(eventPlayer))

rule "Update Outline":
    @Event playerJoined
    @Team 1

    eventPlayer.startForcingOutlineFor(getPlayers(Team.2), WORKSHOP_SET_USEOUTLINE, Color.TEAM_1, OutlineVisibility.DEFAULT)

rule "Respawn Seeker if they leave Spawn Room":
    @Event eachPlayer
    @Team 2
    @Condition CurrentGameState == GAME_STATE.HIDING
    @Condition not eventPlayer.isInSpawnRoom()

    eventPlayer.respawn()
    smallMessage(eventPlayer, "Wait until Seeking Phase to Leave")
    printLog("{} left spawn room during hiding phase, respawning".format(eventPlayer))

rule "Seeker Noclip Barrier":
    @Event eachPlayer
    @Team 2
    @Condition WORKSHOP_SET_MODE != STYLE.GLITCH
    #@Condition CurrentGameState == GAME_STATE.SEEKING
    @Condition eventPlayer.isMoving()
    @Condition eventPlayer.isOnGround()
    @Condition isInLoS(eventPlayer.getEyePosition(), worldVector(eventPlayer.getThrottle(), eventPlayer, Transform.ROTATION_AND_TRANSLATION) + vect(0, evalOnce(distance(eventPlayer.getEyePosition(), eventPlayer.getPosition()) / 2), 0), BarrierLos.PASS_THROUGH_BARRIERS)

    # Disable collision if the player is within line of sight of a point in the direction of throttle.
    eventPlayer.disableEnvironmentCollision(false)
    wait(0.05)
    if RULE_CONDITION:
        goto RULE_START
    eventPlayer.enableEnvironmentCollision()
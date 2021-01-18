#!mainFile "../shared/settings.opy"

rule "Respawn Seeker if they leave Spawn Room":
    @Event eachPlayer
    @Team 2
    @Condition getCurrentGamemode() == Gamemode.SKIRMISH or getCurrentGamemode() == Gamemode.CTF
    @Condition CurrentGameState == GAME_STATE.HIDING
    @Condition not eventPlayer.isInSpawnRoom()

    if eventPlayer.getCurrentHero() == Hero.DVA: goto skip_respawn:
    eventPlayer.respawn()
    skip_respawn:
    smallMessage(eventPlayer, STR_SEEKER_WAIT)
    printLog("{} left spawn room during hiding phase, respawning".format(eventPlayer))

rule "Seeker Noclip Barrier":
    @Event eachPlayer
    @Team 2
    @Condition getCurrentGamemode() == Gamemode.SKIRMISH
    @Condition WS_SET_MODE != STYLE.GLITCH
    @Condition CurrentGameState == GAME_STATE.SEEKING
    @Condition eventPlayer.isMoving()
    @Condition eventPlayer.isOnGround()
    @Condition isInLoS(eventPlayer.getEyePosition(), worldVector(eventPlayer.getThrottle(), eventPlayer, Transform.ROTATION_AND_TRANSLATION) + vect(0, evalOnce(distance(eventPlayer.getEyePosition(), eventPlayer.getPosition()) / 2), 0), BarrierLos.PASS_THROUGH_BARRIERS)

    # Disable collision if the player is within line of sight of a point in the direction of throttle.
    eventPlayer.disableEnvironmentCollision(false)
    wait(0.05)
    if RULE_CONDITION:
        goto RULE_START
    eventPlayer.enableEnvironmentCollision()
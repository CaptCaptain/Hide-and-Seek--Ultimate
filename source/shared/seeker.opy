#!mainFile "../shared/settings.opy"

playervar Hud_Seeker_Name
playervar Hud_Seeker_Assistance
playervar SphereDetectionRadius = 0
playervar SpherePosition

rule "Seeker Setup":
    @Event eachPlayer
    @Team 2
    
    # Seeker Setup
    eventPlayer.setAllowedHeroes(getAllHeroes().exclude([Hero.MOIRA, Hero.ZENYATTA, Hero.SOMBRA]) if not WS_SET_ADV_SEEK_ALLOWH else getAllHeroes())

    # Mercy V. Rein
    switch WS_SET_MODE:
        case STYLE.MERCY_REIN:
            eventPlayer.setAllowedHeroes(Hero.REINHARDT)
            eventPlayer.setMoveSpeed(eventPlayer.BaseMoveSpeed * 2)
            eventPlayer.setJumpVerticalSpeed(eventPlayer.BaseJumpHeight * 1.75)
            eventPlayer.setSecondaryFireEnabled(false)
            break
        default:
            break
    
    waitUntil(eventPlayer.hasSpawned(), 9999)

    # Create Seeker Name
    switch WS_SET_SEEKER_OUTLINES:
        case ACCESSIBILITY.SEEKER_OUTLINES_DEFAULT:
            break
        default:
            createInWorldText(getPlayers(Team.1), eventPlayer, eventPlayer, 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.TEAM_2, SpecVisibility.DEFAULT)
            break

    # Hider Outlines
    getPlayers(Team.1).startForcingOutlineFor(eventPlayer, WS_SET_USEOUTLINE, Color.TEAM_1, OutlineVisibility.DEFAULT)

    waitUntil(not eventPlayer.isInSpawnRoom(), 9999)

    eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 9999)

    printLog("Seeker Setup finished for {}".format(eventPlayer))

rule "Update Hider Outline":
    @Event playerJoined
    @Team 1

    eventPlayer.startForcingOutlineFor(getPlayers(Team.2), WS_SET_USEOUTLINE, Color.TEAM_1, OutlineVisibility.DEFAULT)

rule "Clear Seeker Name":
    @Event playerLeft
    @Team 2

    destroyInWorldText(eventPlayer.Hud_Seeker_Name)

rule "Seeker Assistance":
    @Event eachPlayer
    @Team 2
    @Condition WS_SET_SEEKER_ASSIST == true
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.isCrouching()

    eventPlayer.SpherePosition = eventPlayer.getPosition()

    createEffect(eventPlayer, Effect.SPHERE, Color.TEAM_2, eventPlayer.SpherePosition, eventPlayer.SphereDetectionRadius, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.Hud_Seeker_Assistance = getLastCreatedEntity()

    # Play effect
    playEffect(eventPlayer, DynamicEffect.RING_EXPLOSION_SOUND, Color.TEAM_2, eventPlayer, 100)

    chase(eventPlayer.SphereDetectionRadius, 40, duration=0.5, ChaseReeval.DESTINATION_AND_DURATION)

    wait(0.5)

    chase(eventPlayer.SphereDetectionRadius, 0, duration=0.5, ChaseReeval.DESTINATION_AND_DURATION)

    wait(0.5)

    if len([player for player in getPlayersInRadius(eventPlayer.SpherePosition, 40, Team.1, LosCheck.OFF) if player.isAlive()]) > 0:
        smallMessage(eventPlayer, STR_SEEKER_ASSISTANCE)
        playEffect(eventPlayer, DynamicEffect.BUFF_IMPACT_SOUND, Color.TEAM_2, eventPlayer, 100)
    else:
        smallMessage(eventPlayer, STR_SEEKER_ASSISTANCE_NONE)
        playEffect(eventPlayer, DynamicEffect.DEBUFF_IMPACT_SOUND, Color.TEAM_2, eventPlayer, 100)
    
    stopChasingVariable(eventPlayer.SphereDetectionRadius)
    eventPlayer.SphereDetectionRadius = 0
    
    destroyEffect(eventPlayer.Hud_Seeker_Assistance)
    eventPlayer.Hud_Seeker_Assistance = null
    
    wait(4)
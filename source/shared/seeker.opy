#!mainFile "../shared/settings.opy"

playervar Hud_Seeker_Name
playervar Hud_Seeker_Assistance

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
    @Condition len([player for player in getPlayersInRadius(eventPlayer, 50, Team.1, LosCheck.OFF) if player.isAlive()]) > 0

    # Create hud text
    hudSubtext(eventPlayer, "{0} THERE ARE HIDERS IN THIS AREA {0}".format(iconString(Icon.WARNING)), HudPosition.TOP, 2, Color.ROSE, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR)
    eventPlayer.Hud_Seeker_Assistance = getLastCreatedText()

    # Wait until there are no hiders in range
    waitUntil(len(getPlayersInRadius(eventPlayer, 50, Team.1, LosCheck.OFF)) == 0, 9999)

    # Remove hud text
    destroyHudText(eventPlayer.Hud_Seeker_Assistance)
    eventPlayer.Hud_Seeker_Assistance = null
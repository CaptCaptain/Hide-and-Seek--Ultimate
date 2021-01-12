#!mainFile "../shared/settings.opy"

globalvar Hud_Seeker_Blindness
playervar Effect_Seeker_Blindness

rule "Lock Seeker in place hud":
    @Condition getCurrentGamemode() == Gamemode.TDM
    @Condition CurrentGameState == GAME_STATE.HIDING

    hudSubtext(getPlayers(Team.2), "You are currently blinded!\nWait until Seeking Phase!", HudPosition.TOP, 2, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    Hud_Seeker_Blindness.append(getLastCreatedText())

    waitUntil(CurrentGameState == GAME_STATE.SEEKING, 9999)

    # Destroy all hud text and effects
    for globalHudIndex in range(0, len(Hud_Seeker_Blindness)):
        destroyHudText(Hud_Seeker_Blindness[globalHudIndex])
    Hud_Seeker_Blindness = null

rule "Lock Seeker in place until seeking phase":
    @Event eachPlayer
    @Team 2
    @Condition getCurrentGamemode() == Gamemode.TDM
    @Condition CurrentGameState == GAME_STATE.HIDING
    @Condition eventPlayer.hasSpawned()

    
    printLog("Locking {} in place".format(eventPlayer))
    eventPlayer.setStatusEffect(null, Status.ROOTED, 9999)

    createEffect(eventPlayer, Effect.SPHERE, Color.BLACK, eventPlayer, 9999, EffectReeval.VISIBILITY)
    eventPlayer.Effect_Seeker_Blindness = getLastCreatedEntity()

    waitUntil(CurrentGameState == GAME_STATE.SEEKING, 9999)

    destroyEffect(eventPlayer.Effect_Seeker_Blindness)
    eventPlayer.Effect_Seeker_Blindness = null
    eventPlayer.clearStatusEffect(Status.ROOTED)
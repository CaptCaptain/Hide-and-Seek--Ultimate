#!mainFile "../shared/settings.opy"

globalvar Hud_Seeker_Blindness
playervar Effect_Seeker_Blindness

#!define fogCreate(distance) createEffect(eventPlayer, Effect.BAD_AURA, Color.BLACK, updateEveryTick(eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * (distance)), 1000, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)\
eventPlayer.Effect_Seeker_Blindness.append(getLastCreatedEntity())

rule "Lock Seeker in place hud":
    @Condition getCurrentGamemode() == Gamemode.TDM
    @Condition CurrentGameState == GAME_STATE.HIDING

    hudSubtext(getPlayers(Team.2), STR_SEEKER_BLINDED, HudPosition.TOP, 2, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
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
    eventPlayer.Effect_Seeker_Blindness.append(getLastCreatedEntity())

    fogCreate(5)
    fogCreate(5 * -1)

    waitUntil(CurrentGameState == GAME_STATE.SEEKING, 9999)

    # Destroy all hud text and effects
    for eventPlayer.playerHudIndex in range(0, len(eventPlayer.Effect_Seeker_Blindness)):
        destroyEffect(eventPlayer.Effect_Seeker_Blindness[eventPlayer.playerHudIndex])
    eventPlayer.Effect_Seeker_Blindness = null
    eventPlayer.clearStatusEffect(Status.ROOTED)
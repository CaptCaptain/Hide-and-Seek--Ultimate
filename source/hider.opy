#!mainFile "settings.opy"

playervar Hud_Detection
playervar Hud_InSpawn
playervar Huds_JoinedLate
playervar Effects_SombraInvis
playervar Hud_SombraTrans
playervar playerHudIndex = 0
playervar JoinedLate

rule "Hider Setup":
    @Event eachPlayer
    @Team 1

    # Hider Setup

    # Mercy V. Rein
    switch WORKSHOP_SET_MODE:
        case STYLE.MERCY_REIN:
            eventPlayer.setAllowedHeroes(Hero.MERCY)
            eventPlayer.HiderSlowFactor = 1.5
            eventPlayer.setMoveSpeed(eventPlayer.BaseMoveSpeed * 1.5)
            eventPlayer.setJumpVerticalSpeed(eventPlayer.BaseJumpHeight * 1.5)
            break
        case STYLE.TINY:
            eventPlayer.BaseScaling = WORKSHOP_SET_ADV_SCALE / 2
            break
        default:
            break

    # Wait for Player to Spawn
    waitUntil(eventPlayer.hasSpawned(), 9999)

    eventPlayer.setMaxHealth(abs(0))
    eventPlayer.enableDeathSpectateAllPlayers()
    eventPlayer.enableDeathSpectateTargetHud()

    waitUntil(not eventPlayer.isInSpawnRoom(), 9999)

    startDamageModification(eventPlayer, getAllPlayers(), abs(9999999999) if (CurrentGameState == GAME_STATE.SEEKING) else 0, DamageReeval.RECEIVERS_DAMAGERS_AND_DMGPERCENT)

    printLog("Hider Setup finished for {}".format(eventPlayer))

rule "Refresh Cooldown for Hiders":
    @Event eachPlayer
    @Team 1
    @Condition CurrentGameState != GAME_STATE.SEEKING
    @Condition eventPlayer.isOnGround()
    @Condition all([usedAbility for usedAbility in [not eventPlayer.isUsingAbility1(), not eventPlayer.isUsingAbility2(), not eventPlayer.isFiringSecondaryFire()]])

    eventPlayer.setAbilityCooldown(Button.ABILITY_1, 0.2 if eventPlayer.getAbilityCooldown(Button.ABILITY_1) > 0 else 0)
    eventPlayer.setAbilityCooldown(Button.ABILITY_2, 0.2 if eventPlayer.getAbilityCooldown(Button.ABILITY_2) > 0 else 0)
    eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0.2 if eventPlayer.getAbilityCooldown(Button.SECONDARY_FIRE) > 0 else 0)

    eventPlayer.setAbilityCharge(Button.ABILITY_1, 3)
    eventPlayer.setAbilityCharge(Button.ABILITY_2, 3)
    eventPlayer.setAbilityCharge(Button.SECONDARY_FIRE, 3)

    if eventPlayer.getAbilityCooldown(Button.ABILITY_1) > 0.2 or eventPlayer.getAbilityCooldown(Button.ABILITY_2) > 0.2 or eventPlayer.getAbilityCooldown(Button.SECONDARY_FIRE) > 0.2:
        wait()
        goto RULE_START

rule "Kill Hider in Spawn Room":
    @Event eachPlayer
    @Team 1
    @Condition eventPlayer.isInSpawnRoom()
    @Condition CurrentGameState == GAME_STATE.SEEKING
    @Condition eventPlayer.JoinedLate == false

    do:
        kill(eventPlayer, null)
        wait()
    while RULE_CONDITION

rule "Show Warning to Hider While In Spawn Room":
    @Event eachPlayer
    @Team 1
    @Condition eventPlayer.isInSpawnRoom()
    @Condition CurrentGameState == GAME_STATE.HIDING

    hudSubtext(eventPlayer, "{0} YOU WILL BE KILLED IF YOU REMAIN IN SPAWN AFTER HIDING PHASE {0}".format(iconString(Icon.WARNING)), HudPosition.TOP, 2, Color.ROSE, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR)
    eventPlayer.Hud_InSpawn = getLastCreatedText()

    waitUntil(not eventPlayer.isInSpawnRoom() or not CurrentGameState == GAME_STATE.HIDING, 9999)

    destroyHudText(eventPlayer.Hud_InSpawn)
    eventPlayer.Hud_InSpawn = null

rule "Slow Hider":
    @Event eachPlayer
    @Team 1
    @Condition WORKSHOP_SET_SLOWHIDER
    @Condition CurrentGameState == GAME_STATE.SEEKING
    @Condition getClosestPlayer(eventPlayer, Team.2) != null
    @Condition any([isInLoS(eventPlayer, player, BarrierLos.PASS_THROUGH_BARRIERS) for player in getPlayers(Team.2)])

    printLog("{} is in line of sight of {}".format(eventPlayer, getClosestPlayer(eventPlayer, Team.2)))

    # Slow hider when in LOS and show Hud indicator
    eventPlayer.setMoveSpeed(eventPlayer.BaseMoveSpeed / eventPlayer.HiderSlowFactor)
    eventPlayer.setJumpVerticalSpeed(eventPlayer.BaseJumpHeight / eventPlayer.HiderSlowFactor)
    eventPlayer.setAbility1Enabled(false)
    eventPlayer.setAbility2Enabled(false)
    eventPlayer.setSecondaryFireEnabled(true if eventPlayer.getCurrentHero() == Hero.HAMMOND else false)
    playEffect(eventPlayer, DynamicEffect.EXPLOSION_SOUND, Color.WHITE, eventPlayer, 250)
    # Destroy Sombra's Translocator
    if eventPlayer.getCurrentHero() == Hero.SOMBRA and eventPlayer.isUsingAbility2():
        eventPlayer.forceButtonPress(Button.INTERACT)
    # Prevent Wrecking Ball from losing grapple
    if not eventPlayer.getCurrentHero() == Hero.HAMMOND and eventPlayer.isMoving():
        eventPlayer.cancelPrimaryAction()
    hudSubtext(eventPlayer, "{0} YOU ARE WITHIN LINE OF SIGHT OF A SEEKER {0}".format(iconString(Icon.WARNING)), HudPosition.TOP, 2, Color.ROSE, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR)
    eventPlayer.Hud_Detection = getLastCreatedText()

    # Wait for hider to be out of LOS
    waitUntil(all([not isInLoS(eventPlayer, player, BarrierLos.PASS_THROUGH_BARRIERS) for player in getPlayers(Team.2)]), 9999)

    # Return hider state to normal
    eventPlayer.setMoveSpeed(eventPlayer.BaseMoveSpeed)
    eventPlayer.setJumpVerticalSpeed(eventPlayer.BaseJumpHeight)
    eventPlayer.setAbility1Enabled(true)
    eventPlayer.setAbility2Enabled(true)
    RestrictAbilities()
    destroyHudText(eventPlayer.Hud_Detection)
    eventPlayer.Hud_Detection = null

    printLog("{} is no longer in line of sight".format(eventPlayer))

rule "Hiders Joined Late":
    @Event eachPlayer
    @Team 1
    @Condition CurrentGameState == GAME_STATE.SEEKING
    @Condition not eventPlayer.hasSpawned()

    eventPlayer.JoinedLate = true

rule "Kill Hiders Who Joined Late":
    @Event eachPlayer
    @Team 1
    @Condition CurrentGameState == GAME_STATE.SEEKING
    @Condition eventPlayer.JoinedLate == true
    @Condition eventPlayer.hasSpawned()

    eventPlayer.disableHeroHUD()

    # Create hud
    createInWorldText(eventPlayer, "YOU JOINED LATE!", updateEveryTick(eventPlayer.getEyePosition() + (eventPlayer.getFacingDirection() * 1)), 5, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION, Color.ROSE, SpecVisibility.NEVER)
    eventPlayer.Huds_JoinedLate.append(getLastCreatedText())

    createInWorldText(eventPlayer, "YOU WILL BE PUT INTO SPECTATOR", updateEveryTick(eventPlayer.getEyePosition() + evalOnce(vect(0, -0.1, 0)) + (eventPlayer.getFacingDirection() * 1)), 2, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION, Color.TURQUOISE, SpecVisibility.NEVER)
    eventPlayer.Huds_JoinedLate.append(getLastCreatedText())

    createInWorldText(eventPlayer, "PLEASE WAIT FOR THE NEXT ROUND", updateEveryTick(eventPlayer.getEyePosition() + evalOnce(vect(0, -0.2, 0)) + (eventPlayer.getFacingDirection() * 1)), 2, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION, Color.TURQUOISE, SpecVisibility.NEVER)
    eventPlayer.Huds_JoinedLate.append(getLastCreatedText())

    eventPlayer.setStatusEffect(null, Status.ROOTED, 5)

    wait(5)

    # Destroy all hud text
    for eventPlayer.playerHudIndex in range(0, len(eventPlayer.Huds_JoinedLate)):
        destroyInWorldText(eventPlayer.Huds_JoinedLate[eventPlayer.playerHudIndex])
    eventPlayer.Huds_JoinedLate = null
    # Set JoinedLate to false so the spawn room kill rule can run
    eventPlayer.JoinedLate = false
    eventPlayer.enableHeroHud()

rule "Sombra Invisibility Tracker":
    @Event eachPlayer
    @Team 1
    @Hero sombra
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.isUsingAbility1()
    
    createEffect(getAllPlayers(), Effect.BAD_AURA, Color.TEAM_1, updateEveryTick(eventPlayer.getPosition() + Vector.UP), 1, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
    eventPlayer.Effects_SombraInvis.append(getLastCreatedEntity())
    createInWorldText(getPlayers(Team.2), eventPlayer, eventPlayer, 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.TEAM_1, SpecVisibility.DEFAULT)
    eventPlayer.Effects_SombraInvis.append(getLastCreatedText())
    hudSubtext(eventPlayer, "{0} YOU ARE VISIBLE TO SEEKERS {0}".format(iconString(Icon.WARNING)), HudPosition.TOP, 2, Color.ROSE, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR)
    eventPlayer.Effects_SombraInvis.append(getLastCreatedText())

    waitUntil(not eventPlayer.isUsingAbility1(), 9999)

    # Destroy all hud text and effects
    for eventPlayer.playerHudIndex in range(0, len(eventPlayer.Effects_SombraInvis)):
        destroyInWorldText(eventPlayer.Effects_SombraInvis[eventPlayer.playerHudIndex])
        destroyHudText(eventPlayer.Effects_SombraInvis[eventPlayer.playerHudIndex])
        destroyEffect(eventPlayer.Effects_SombraInvis[eventPlayer.playerHudIndex])
    eventPlayer.Effects_SombraInvis = null
    
rule "Sombra: Destroy Translocator":
    @Event eachPlayer
    @Team 1
    @Hero sombra
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.isUsingAbility2()

    hudSubtext(eventPlayer, "{0} YOUR TRANSLOCATOR WILL BE DESTROYED IN {1} SECONDS {0}".format(iconString(Icon.WARNING), eventPlayer.getAbilityCooldown(Button.ABILITY_2)), HudPosition.TOP, 2, Color.ROSE, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR)
    eventPlayer.Hud_SombraTrans = getLastCreatedText()

    waitUntil(eventPlayer.getAbilityCooldown(Button.ABILITY_2) == 0 or not eventPlayer.isUsingAbility2(), 6)
    eventPlayer.forceButtonPress(Button.INTERACT)

    # Destroy all hud text and effects
    destroyHudText(eventPlayer.Hud_SombraTrans)
    eventPlayer.Hud_SombraTrans = null
    
# Mercy V. Rein Specific Rules
rule "Refresh Resurrect Cooldown":
    @Event eachPlayer
    @Hero mercy
    @Team 1
    @Condition WORKSHOP_SET_MODE == STYLE.MERCY_REIN
    @Condition CurrentGameState == GAME_STATE.SEEKING
    @Condition eventPlayer.isUsingAbility2()

    waitUntil(eventPlayer.isUsingAbility2(), 9999)
    eventPlayer.setAbilityCooldown(Button.ABILITY_2, 0)
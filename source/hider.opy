#!mainFile "settings.opy"

playervar Hud_Detection
playervar Hud_InSpawn
playervar Huds_JoinedLate
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
            eventPlayer.BaseMoveSpeed = 150
            eventPlayer.BaseJumpHeight = 150
            eventPlayer.HiderSlowFactor = 1.5
            eventPlayer.setMoveSpeed(eventPlayer.BaseMoveSpeed)
            eventPlayer.setJumpVerticalSpeed(eventPlayer.BaseJumpHeight)
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

    if eventPlayer.getAbilityCooldown(Button.ABILITY_1) > 0.2 or eventPlayer.getAbilityCooldown(Button.ABILITY_2) > 0.2 or eventPlayer.getAbilityCooldown(Button.SECONDARY_FIRE) > 0.2:
        wait()
        goto RULE_START

rule "Refresh Charges for Hiders":
    @Event eachPlayer
    @Team 1
    @Condition CurrentGameState != GAME_STATE.SEEKING
    @Condition eventPlayer.isOnGround()
    @Condition any([resource <= 2 and resource != 0 for resource in [eventPlayer.getAbilityResource(Button.ABILITY_1), eventPlayer.getAbilityResource(Button.ABILITY_2)]])

    eventPlayer.setAbilityCharge(Button.ABILITY_1, 3)
    eventPlayer.setAbilityCharge(Button.ABILITY_2, 3)
    eventPlayer.setAbilityCharge(Button.SECONDARY_FIRE, 3)

    wait()
    if RULE_CONDITION:
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
    @Condition getClosestPlayer(eventPlayer, Team.2) != null
    @Condition any([isInLoS(eventPlayer, player, BarrierLos.PASS_THROUGH_BARRIERS) for player in getPlayers(Team.2)])

    printLog("{} is in line of sight of {}".format(eventPlayer, getClosestPlayer(eventPlayer, Team.2)))

    # Slow hider when in LOS and show Hud indicator
    eventPlayer.setMoveSpeed(eventPlayer.BaseMoveSpeed / eventPlayer.HiderSlowFactor)
    eventPlayer.setJumpVerticalSpeed(eventPlayer.BaseJumpHeight / eventPlayer.HiderSlowFactor)
    eventPlayer.setAbility1Enabled(false)
    eventPlayer.setAbility2Enabled(false)
    hudSubtext(eventPlayer, "{0} YOU ARE WITHIN LINE OF SIGHT OF A SEEKER {0}".format(iconString(Icon.WARNING)), HudPosition.TOP, 2, Color.ROSE, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR)
    eventPlayer.Hud_Detection = getLastCreatedText()

    # Wait for hider to be out of LOS
    waitUntil(all([not isInLoS(eventPlayer, player, BarrierLos.PASS_THROUGH_BARRIERS) for player in getPlayers(Team.2)]), 9999)

    # Return hider state to normal
    eventPlayer.setMoveSpeed(eventPlayer.BaseMoveSpeed)
    eventPlayer.setJumpVerticalSpeed(eventPlayer.BaseJumpHeight)
    eventPlayer.setAbility1Enabled(true)
    eventPlayer.setAbility2Enabled(true)
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
    for eventPlayer.playerHudIndex in range(len(eventPlayer.Huds_JoinedLate)):
        destroyInWorldText(eventPlayer.Huds_JoinedLate[eventPlayer.playerHudIndex])
    eventPlayer.Huds_JoinedLate = null
    # Set JoinedLate to false so the spawn room kill rule can run
    eventPlayer.JoinedLate = false
    eventPlayer.enableHeroHud()
    
# Accessibility Rules

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
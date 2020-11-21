#!mainFile "settings.opy"

playervar Hud_Detection
playervar Hud_InSpawn
playervar Hud_JoinedLate
globalvar Hud_GameInfo
globalvar hudIndex
playervar BaseMoveSpeed = 100
playervar BaseJumpHeight = 100
playervar HiderSlowFactor = 2
playervar JoinedLate = true if CurrentGameState == GAME_STATE.SEEKING else false

rule "Player Huds":
    @Event eachPlayer

    # Creates the Objective Hud
    hudText(eventPlayer, "{} {}".format(abilityIconString(eventPlayer.getCurrentHero(), Button.ULTIMATE) if eventPlayer.getTeam() == Team.1 else abilityIconString(eventPlayer.getCurrentHero(), Button.PRIMARY_FIRE), "HIDER" if eventPlayer.getTeam() == Team.1 else "SEEKER"), "PHASE: {}".format(CurrentGameState), "{}:{}".format(floor(((CurrentTime % 86400) % 3600) / 60), floor(((CurrentTime % 86400) % 3600) % 60)) if CurrentTime > 60 else "{}".format(CurrentTime), HudPosition.TOP, 1, Color.TEAM_1, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)

rule "Global Huds":
    @Condition CurrentGameState == GAME_STATE.HIDING

    hudSubheader(getAllPlayers(), CURRENT_PATCHNOTES, HudPosition.RIGHT, 0, Color.WHITE, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubheader(getAllPlayers(), "Version: {} ({})\n".format(CURRENT_VERSION, CURRENT_CODE), HudPosition.LEFT, 0, Color.SKY_BLUE, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubtext(getAllPlayers(), "{} Hide & Seek: Ultimate by CaptCaptain#11502".format(abilityIconString(random.choice(getAllHeroes()), Button.ULTIMATE)), HudPosition.LEFT, 0, Color.SKY_BLUE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudHeader(getAllPlayers(), "{} RULESET:".format(abilityIconString(Hero.TORBJORN, Button.ABILITY_2)), HudPosition.LEFT, 1, Color.ROSE, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubtext(getAllPlayers(), "STYLE: {}".format(WORKSHOP_SET_MODE), HudPosition.LEFT, 2, Color.ROSE, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubtext(getAllPlayers(), "FIRST TEAM TO: {} WIN(S)".format(WORKSHOP_SET_ADV_WINS), HudPosition.LEFT, 3, Color.ROSE, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubtext(getAllPlayers(), "SEEK TIME: {}:{}".format(floor(((WORKSHOP_SET_SEEKTIME % 86400) % 3600) / 60), floor(((WORKSHOP_SET_HIDETIME % 86400) % 3600) % 60)), HudPosition.LEFT, 4, Color.ROSE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubtext(getAllPlayers(), "HIDING TIME: {}:{}".format(floor(((WORKSHOP_SET_HIDETIME % 86400) % 3600) / 60), floor(((WORKSHOP_SET_HIDETIME % 86400) % 3600) % 60)), HudPosition.LEFT, 4, Color.ROSE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubtext(getAllPlayers(), "PLAYER SIZE: {}x".format(WORKSHOP_SET_ADV_SCALE), HudPosition.LEFT, 4, Color.ROSE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubheader(getAllPlayers(), "FOR MORE INFORMATION ON RULESET, GO TO LOBBY > RIGHT CLICK MAP PICTURE > SCROLL DOWN TO WORKSHOP".format(WORKSHOP_SET_MODE), HudPosition.LEFT, 5, Color.TURQUOISE, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubheader(getAllPlayers(), "TO CUSTOMIZE RULESET, GO TO LOBBY > SETTINGS > WORKSHOP SETTINGS (HOST ONLY)".format(WORKSHOP_SET_MODE), HudPosition.LEFT, 5, Color.TURQUOISE, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

rule "Remove Global Huds":
    @Condition CurrentGameState == GAME_STATE.SEEKING
    for hudIndex in range(len(Hud_GameInfo)):
        destroyHudText(Hud_GameInfo[hudIndex])
    Hud_GameInfo = null

rule "Player Scaling":
    @Event eachPlayer
    @Condition WORKSHOP_SET_ADV_SCALE > 1 or WORKSHOP_SET_ADV_SCALE < 1

    # Scales the player
    eventPlayer.startScalingSize(WORKSHOP_SET_ADV_SCALE, false)
    eventPlayer.startScalingBarriers(WORKSHOP_SET_ADV_SCALE, false)
    eventPlayer.startModifyingVoicelinePitch(2 - WORKSHOP_SET_ADV_SCALE, false)

rule "Player Setup":
    @Event eachPlayer

    eventPlayer.disableGamemodeHud()
    eventPlayer.disableRespawn()
    
rule "Seeker Setup":
    @Event eachPlayer
    @Team 2
    
    # Seeker Setup
    eventPlayer.setAllowedHeroes(getAllHeroes().exclude([Hero.MOIRA, Hero.ZENYATTA, Hero.SOMBRA]) if not WORKSHOP_SET_ADV_SEEK_ALLOWH else getAllHeroes())

    # Mercy V. Rein
    switch WORKSHOP_SET_MODE:
        case STYLE.MERCY_REIN:
            eventPlayer.setAllowedHeroes(Hero.REINHARDT)
            eventPlayer.BaseMoveSpeed = 200
            eventPlayer.BaseJumpHeight = 175
            eventPlayer.setMoveSpeed(eventPlayer.BaseMoveSpeed)
            eventPlayer.setJumpVerticalSpeed(eventPlayer.BaseJumpHeight)
            eventPlayer.setSecondaryFireEnabled(false)
            break
        default:
            break
    
    waitUntil(eventPlayer.hasSpawned(), 9999)

    getPlayers(Team.1).startForcingOutlineFor(eventPlayer, WORKSHOP_SET_USEOUTLINE, Color.TEAM_1, OutlineVisibility.DEFAULT)

    waitUntil(not eventPlayer.isInSpawnRoom(), 9999)

    eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 9999)

    printLog("Seeker Setup finished for {}".format(eventPlayer))

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

rule "Reset Ammo":
    @Event eachPlayer
    @Condition not eventPlayer.isFiringPrimaryFire() and not eventPlayer.isFiringSecondaryFire()
    @Condition eventPlayer.getAmmo(0) > 0

    # Reset ammo when player has not fired for more than a second
    wait(1, Wait.ABORT_WHEN_FALSE)
    eventPlayer.setAmmo(0, eventPlayer.getMaxAmmo(0))

rule "Slow Hider":
    @Event eachPlayer
    @Team 1
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

rule "Respawn Seeker if they leave Spawn Room":
    @Event eachPlayer
    @Team 2
    @Condition CurrentGameState == GAME_STATE.HIDING
    @Condition not eventPlayer.isInSpawnRoom()

    eventPlayer.respawn()
    smallMessage(eventPlayer, "Wait until Seeking Phase to Leave")
    printLog("{} left spawn room during hiding phase, respawning".format(eventPlayer))

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

rule "Kill Hider in Spawn Room":
    @Event eachPlayer
    @Team 1
    @Condition eventPlayer.isInSpawnRoom()
    @Condition CurrentGameState == GAME_STATE.SEEKING

    do:
        kill(eventPlayer, null)
        wait()
    while RULE_CONDITION

rule "Resurrect":
    @Event playerDied
    @Condition not eventPlayer.isInSpawnRoom()
    @Condition eventWasEnvironment or attacker() == victim()

    # If the player dies to the environment or self-destructs.
    eventPlayer.resurrect()
    eventPlayer.teleport(nearestWalkablePosition(eventPlayer.getPosition()))
    eventPlayer.setStatusEffect(null, Status.STUNNED, 2)
    eventPlayer.setStatusEffect(null, Status.INVINCIBLE, 1)
    smallMessage(eventPlayer, "BE CAREFUL!")

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

rule "Seeker Noclip Barrier":
    @Event eachPlayer
    @Team 2
    @Condition CurrentGameState == GAME_STATE.SEEKING
    @Condition eventPlayer.isMoving()
    @Condition isInLoS(eventPlayer, worldVector(eventPlayer.getThrottle(), eventPlayer, Transform.ROTATION_AND_TRANSLATION), BarrierLos.PASS_THROUGH_BARRIERS)

    # Disable collision if the player is within line of sight of a point in the direction of throttle.
    eventPlayer.disableEnvironmentCollision(false)
    wait()
    if RULE_CONDITION:
        goto RULE_START
    eventPlayer.enableEnvironmentCollision()

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
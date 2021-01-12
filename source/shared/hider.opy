#!mainFile "../shared/settings.opy"

playervar Hud_Detection
playervar Hud_InSpawn
playervar Huds_JoinedLate
playervar Effects_SombraInvis
playervar Hud_SombraTrans

#!define refreshAbility(button) eventPlayer.setAbilityCooldown(button, 0.2 if eventPlayer.getAbilityCooldown(button) > 0 else 0)\
eventPlayer.setAbilityCharge(button, 3)

rule "Hider Setup":
    @Event eachPlayer
    @Team 1

    # Hider Setup

    # Mercy V. Rein
    switch WS_SET_MODE:
        case STYLE.MERCY_REIN:
            eventPlayer.setAllowedHeroes(Hero.MERCY)
            eventPlayer.HiderSlowFactor = 1.5
            eventPlayer.setMoveSpeed(eventPlayer.BaseMoveSpeed * 1.5)
            eventPlayer.setJumpVerticalSpeed(eventPlayer.BaseJumpHeight * 1.5)
            break
        case STYLE.TINY:
            eventPlayer.BaseScaling = WS_SET_ADV_SCALE / 2
            break
        default:
            break

    # Wait for Player to Spawn
    waitUntil(eventPlayer.hasSpawned(), 9999)

    # Seeker Outlines
    switch WS_SET_SEEKER_OUTLINES:
        case ACCESSIBILITY.SEEKER_OUTLINES_ALWAYS:
            getPlayers(Team.2).startForcingOutlineFor(eventPlayer, true, Color.TEAM_2, OutlineVisibility.ALWAYS)
            break
        case ACCESSIBILITY.SEEKER_OUTLINES_OCCLUDED:
            getPlayers(Team.2).startForcingOutlineFor(eventPlayer, true, Color.TEAM_2, OutlineVisibility.OCCLUDED)
            break

    eventPlayer.setMaxHealth(abs(0))
    eventPlayer.enableDeathSpectateAllPlayers()
    eventPlayer.enableDeathSpectateTargetHud()

    waitUntil(not eventPlayer.isInSpawnRoom(), 9999)

    startDamageModification(eventPlayer, getAllPlayers(), abs(9999999999) if (CurrentGameState == GAME_STATE.SEEKING) else 0, DamageReeval.RECEIVERS_DAMAGERS_AND_DMGPERCENT)

    printLog("Hider Setup finished for {}".format(eventPlayer))

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
    eventPlayer.ResurrectBlocked = true
    eventPlayer.enableHeroHud()

rule "Hider Tank Scaling":
    @Event eachPlayer
    @Team 1
    @Condition WS_SET_ADV_TANKSCALING == ACCESSIBILITY.TANKS_SCALE or WS_SET_ADV_TANKSCALING == ACCESSIBILITY.TANKS_SCALE_ALL
    @Condition any([hero == eventPlayer.getCurrentHero() for hero in getTankHeroes()])
    @Condition not eventPlayer.isInAlternateForm()

    #!define TankScaleDownFactor 1.15

    eventPlayer.BaseScaling /= 1 if WS_SET_ADV_TANKSCALING == ACCESSIBILITY.TANKS_SCALE and eventPlayer.getCurrentHero() == Hero.HAMMOND else TankScaleDownFactor if WS_SET_ADV_TANKSCALING == ACCESSIBILITY.TANKS_SCALE or WS_SET_ADV_TANKSCALING == ACCESSIBILITY.TANKS_SCALE_ALL else 1

    waitUntil(not any([hero == eventPlayer.getCurrentHero() for hero in getTankHeroes()]) or eventPlayer.isInAlternateForm(), 9999)

    eventPlayer.BaseScaling *= 1 if WS_SET_ADV_TANKSCALING == ACCESSIBILITY.TANKS_SCALE and eventPlayer.getCurrentHero() == Hero.HAMMOND else TankScaleDownFactor if WS_SET_ADV_TANKSCALING == ACCESSIBILITY.TANKS_SCALE or WS_SET_ADV_TANKSCALING == ACCESSIBILITY.TANKS_SCALE_ALL else 1

rule "Update Seeker Outline":
    @Event playerJoined
    @Team 2

    switch WS_SET_SEEKER_OUTLINES:
        case ACCESSIBILITY.SEEKER_OUTLINES_ALWAYS:
            eventPlayer.startForcingOutlineFor(getPlayers(Team.1), true, Color.TEAM_2, OutlineVisibility.ALWAYS)
            break
        case ACCESSIBILITY.SEEKER_OUTLINES_OCCLUDED:
            eventPlayer.startForcingOutlineFor(getPlayers(Team.1), true, Color.TEAM_2, OutlineVisibility.OCCLUDED)
            break

rule "Refresh Ability 1 for Hiders":
    @Event eachPlayer
    @Team 1
    @Condition CurrentGameState != GAME_STATE.SEEKING
    @Condition eventPlayer.isOnGround()
    @Condition not eventPlayer.isUsingAbility1()

    refreshAbility(Button.ABILITY_1)

rule "Refresh Ability 2 for Hiders":
    @Event eachPlayer
    @Team 1
    @Condition CurrentGameState != GAME_STATE.SEEKING
    @Condition eventPlayer.isOnGround()
    @Condition not eventPlayer.isUsingAbility2()

    refreshAbility(Button.ABILITY_2)

rule "Refresh Secondary Fire for Hiders":
    @Event eachPlayer
    @Team 1
    @Condition CurrentGameState != GAME_STATE.SEEKING
    @Condition eventPlayer.isOnGround()
    @Condition not eventPlayer.isFiringSecondaryFire()

    refreshAbility(Button.SECONDARY_FIRE)

rule "Refresh Secondary Fire for Wrecking Ball":
    @Event eachPlayer
    @Team 1
    @Hero hammond
    @Condition WS_SET_ADV_INF_HAMMOND_GRAPPLE == true
    @Condition not eventPlayer.isFiringSecondaryFire()

    refreshAbility(Button.SECONDARY_FIRE)

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
    @Condition WS_SET_SLOWHIDER
    @Condition CurrentGameState == GAME_STATE.SEEKING
    @Condition getClosestPlayer(eventPlayer, Team.2) != null
    @Condition any([isInLoS(eventPlayer, player, BarrierLos.PASS_THROUGH_BARRIERS) for player in getPlayers(Team.2)])

    printLog("{} is in line of sight of {}".format(eventPlayer, getClosestPlayer(eventPlayer, Team.2)))

    # Slow hider when in LOS and show Hud indicator
    eventPlayer.setMoveSpeed(eventPlayer.BaseMoveSpeed / eventPlayer.HiderSlowFactor)
    eventPlayer.setJumpVerticalSpeed(eventPlayer.BaseJumpHeight / eventPlayer.HiderSlowFactor)
    eventPlayer.setAbility1Enabled(false)
    eventPlayer.setAbility2Enabled(false)
    eventPlayer.SlingshotEnabled = false
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

rule "Sombra Invisibility Tracker":
    @Event eachPlayer
    @Team 1
    @Hero sombra
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.isUsingAbility1()
    
    # Create effects and hud
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

    hudSubtext(eventPlayer, "{0} YOUR TRANSLOCATOR WILL BE DESTROYED IN {1} SECONDS OR WHEN IT IS OUT OF LOS {0}".format(iconString(Icon.WARNING), eventPlayer.getAbilityCooldown(Button.ABILITY_2)), HudPosition.TOP, 2, Color.ROSE, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR)
    eventPlayer.Hud_SombraTrans = getLastCreatedText()

    waitUntil(eventPlayer.getAbilityCooldown(Button.ABILITY_2) == 0 or not eventPlayer.isUsingAbility2() or not isInLoS(eventPlayer.getEyePosition(), evalOnce(raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + (eventPlayer.getFacingDirection() * 25), null, eventPlayer, false).getHitPosition()), BarrierLos.PASS_THROUGH_BARRIERS), 6)
    eventPlayer.forceButtonPress(Button.INTERACT)

    # Destroy all hud text and effects
    destroyHudText(eventPlayer.Hud_SombraTrans)
    eventPlayer.Hud_SombraTrans = null

rule "Sombra: Clear Effects When Switching Heroes":
    @Event eachPlayer
    @Team 1
    @Condition eventPlayer.getCurrentHero() != Hero.SOMBRA

    # Destroy all hud text and effects
    for eventPlayer.playerHudIndex in range(0, len(eventPlayer.Effects_SombraInvis)):
        destroyInWorldText(eventPlayer.Effects_SombraInvis[eventPlayer.playerHudIndex])
        destroyHudText(eventPlayer.Effects_SombraInvis[eventPlayer.playerHudIndex])
        destroyEffect(eventPlayer.Effects_SombraInvis[eventPlayer.playerHudIndex])
    eventPlayer.Effects_SombraInvis = null

# Accessibility Rules
rule "Hider Laying Down":
    @Event eachPlayer
    @Team 1
    @Condition WS_SET_LAYING_DOWN == true
    @Condition eventPlayer.CameraState == CAMERA_STATE.FIRST_PERSON or eventPlayer.CameraState == CAMERA_STATE.THIRD_PERSON
    @Condition not eventPlayer.isInSpawnRoom()
    @Condition eventPlayer.isCommunicatingEmote()
    @Condition eventPlayer.isHoldingButton(Button.CROUCH)

    eventPlayer.LayingDownCameraEnabled = true

    eventPlayer.CameraState = CAMERA_STATE.LAYING_DOWN
    eventPlayer.setStatusEffect(null, Status.KNOCKED_DOWN, 9999)
    wait(1)
    waitUntil(eventPlayer.CameraState == CAMERA_STATE.LAYING_DOWN and any([eventPlayer.isHoldingButton(button) for button in [Button.JUMP, Button.ABILITY_1, Button.ABILITY_2, Button.CROUCH, Button.INTERACT, Button.MELEE, Button.PRIMARY_FIRE, Button.SECONDARY_FIRE, Button.ULTIMATE]]), 9999)
    eventPlayer.clearStatusEffect(Status.KNOCKED_DOWN)

    eventPlayer.LayingDownCameraEnabled = false

    # Return to previous camera state
    if eventPlayer.ThirdPersonCameraEnabled == true:
        eventPlayer.CameraState = CAMERA_STATE.THIRD_PERSON
        StartThirdPersonCamera()
    else:
        eventPlayer.CameraState = CAMERA_STATE.FIRST_PERSON
    
# Mercy V. Rein Specific Rules
rule "Refresh Resurrect Cooldown":
    @Event eachPlayer
    @Hero mercy
    @Team 1
    @Condition WS_SET_MODE == STYLE.MERCY_REIN
    @Condition CurrentGameState == GAME_STATE.SEEKING
    @Condition eventPlayer.isUsingAbility2()

    waitUntil(eventPlayer.isUsingAbility2(), 9999)
    eventPlayer.setAbilityCooldown(Button.ABILITY_2, 0)
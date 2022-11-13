#!mainFile "../shared/settings.opy"

playervar Hud_Seeker_Name
playervar Hud_Seeker_Assistance
playervar Hud_Moira_Ammo
playervar Hud_Sombra_Stealth_Duration
playervar Stealth_Duration = 100
playervar Moira_Ammo = 100
playervar SphereDetectionRadius = 0
playervar SpherePosition
playervar HiderPulseOnCooldown = false

rule "Seeker Setup":
    @Event eachPlayer
    @Team 2
    
    # Seeker Setup
    eventPlayer.setAllowedHeroes(getAllHeroes().exclude([]) if not WS_SET_ADV_SEEK_ALLOWH else getAllHeroes())

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
    if WS_SET_USEOUTLINE:
        getPlayers(Team.1).disableNameplatesFor(eventPlayer)

    waitUntil(not eventPlayer.isInSpawnRoom(), 9999)

    eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 9999)

    printLog("Seeker Setup finished for {}".format(eventPlayer))

rule "Update Hider Outline":
    @Event playerJoined
    @Team 1

    eventPlayer.startForcingOutlineFor(getPlayers(Team.2), WS_SET_USEOUTLINE, Color.TEAM_1, OutlineVisibility.DEFAULT)
    if WS_SET_USEOUTLINE:
        eventPlayer.disableNameplatesFor(getPlayers(Team.2))

rule "Clear Seeker Name":
    @Event playerLeft
    @Team 2

    destroyInWorldText(eventPlayer.Hud_Seeker_Name)


rule "Moira Ammo Counter":
    @Event eachPlayer
    @Team 2
    @Hero moira
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.isFiringSecondaryFire()

    # Chase to 0
    chase(eventPlayer.Moira_Ammo, 0, rate=200, ChaseReeval.DESTINATION_AND_RATE)

    waitUntil(not eventPlayer.isFiringSecondaryFire(), 9999)

    # Chase to 100
    chase(eventPlayer.Moira_Ammo, 100, rate=100, ChaseReeval.DESTINATION_AND_RATE)

    eventPlayer.setSecondaryFireEnabled(false)

    wait(1)

    eventPlayer.setSecondaryFireEnabled(true)

rule "Moira Ammo Counter Hud":
    @Event eachPlayer
    @Team 2
    @Hero moira
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.Hud_Moira_Ammo == null

    # Create hud
    progressBarHud(eventPlayer if eventPlayer.Moira_Ammo < 100 else null, eventPlayer.Moira_Ammo, STR_SEEKER_MOIRA_AMMO, HudPosition.TOP, 5, Color.PURPLE, Color.WHITE, ProgressHudReeval.VISIBILITY_AND_VALUES, SpecVisibility.DEFAULT)
    eventPlayer.Hud_Moira_Ammo = getLastCreatedText()

rule "Moira Stop Firing":
    @Event eachPlayer
    @Team 2
    @Hero moira
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.isFiringSecondaryFire()
    @Condition eventPlayer.Moira_Ammo == 0

    eventPlayer.setSecondaryFireEnabled(false)
    

rule "Sombra Stealth Duration":
    @Event eachPlayer
    @Team 2
    @Hero sombra
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.isUsingAbility1()

    # Chase to 0
    chase(eventPlayer.Stealth_Duration, 0, rate=15, ChaseReeval.DESTINATION_AND_RATE)

    waitUntil(not eventPlayer.isUsingAbility1(), 9999)

    # Chase to 100
    chase(eventPlayer.Stealth_Duration, 100, rate=15, ChaseReeval.DESTINATION_AND_RATE)

rule "Sombra Stop Stealth":
    @Event eachPlayer
    @Team 2
    @Hero sombra
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.isUsingAbility1()
    @Condition eventPlayer.Stealth_Duration == 0

    eventPlayer.forceButtonPress(Button.ABILITY_1)

rule "Sombra Stealth Duration Hud":
    @Event eachPlayer
    @Team 2
    @Hero sombra
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.Hud_Sombra_Stealth_Duration == null

    # Create hud
    progressBarHud(eventPlayer if eventPlayer.Stealth_Duration < 100 else null, eventPlayer.Stealth_Duration, STR_SEEKER_SOMBRA_STEALTH_DURATION, HudPosition.TOP, 5, Color.PURPLE, Color.WHITE, ProgressHudReeval.VISIBILITY_AND_VALUES, SpecVisibility.DEFAULT)
    eventPlayer.Hud_Sombra_Stealth_Duration = getLastCreatedText()

rule "Sombra Disable Hack Overlay":
    @Event eachPlayer
    @Team 2
    @Hero sombra
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.getAbilityCooldown(Button.SECONDARY_FIRE) < 1

    eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 2)

    wait(1)

    if RULE_CONDITION: goto RULE_START

rule "Zenyatta Disable Discord Overlay":
    @Event eachPlayer
    @Team 2
    @Hero zenyatta
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.getAbilityCooldown(Button.ABILITY_2) < 1

    eventPlayer.setAbilityCooldown(Button.ABILITY_2, 1)

    wait(1)

    if RULE_CONDITION: goto RULE_START

rule "Seeker Floating":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.isInAir()
    @Condition eventPlayer.isHoldingButton(Button.JUMP)

    wait(0.25, Wait.ABORT_WHEN_FALSE)

    while eventPlayer.isHoldingButton(Button.JUMP):
        eventPlayer.setGravity(0.1)
        wait(0.08)

    eventPlayer.setGravity(100)

rule "Seeker Assistance":
    @Event eachPlayer
    @Team 2
    @Condition WS_SET_SEEKER_ASSIST == true
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.isHoldingButton(Button.CROUCH)

    waitUntil(not eventPlayer.isHoldingButton(Button.CROUCH), 9999)
    waitUntil(eventPlayer.isHoldingButton(Button.CROUCH), 0.125)
    if not eventPlayer.isHoldingButton(Button.CROUCH):
        return

    eventPlayer.SpherePosition = eventPlayer.getPosition()

    createEffect(eventPlayer, Effect.SPHERE, Color.TEAM_2, eventPlayer.SpherePosition, updateEveryTick(eventPlayer.SphereDetectionRadius), EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.Hud_Seeker_Assistance = getLastCreatedEntity()

    # Play effect
    playEffect(eventPlayer, DynamicEffect.RING_EXPLOSION_SOUND, Color.TEAM_2, eventPlayer, 100)

    chase(eventPlayer.SphereDetectionRadius, 50, duration=0.5, ChaseReeval.DESTINATION_AND_DURATION)

    wait(0.5)

    eventPlayer.HiderPulseOnCooldown = true

    if len([player for player in getPlayersInRadius(eventPlayer.SpherePosition, 40, Team.1, LosCheck.OFF) if player.isAlive()]) > 0:
        smallMessage(eventPlayer, fixedString(STR_SEEKER_ASSISTANCE))
        playEffect(eventPlayer, DynamicEffect.BUFF_IMPACT_SOUND, Color.TEAM_2, eventPlayer, 100)
        wait(10)
    else:
        smallMessage(eventPlayer, fixedString(STR_SEEKER_ASSISTANCE_NONE))
        playEffect(eventPlayer, DynamicEffect.DEBUFF_IMPACT_SOUND, Color.TEAM_2, eventPlayer, 100)
    
    stopChasingVariable(eventPlayer.SphereDetectionRadius)

    chase(eventPlayer.SphereDetectionRadius, 0, duration=0.5, ChaseReeval.DESTINATION_AND_DURATION)

    wait(0.5)

    eventPlayer.SphereDetectionRadius = 0
    destroyEffect(eventPlayer.Hud_Seeker_Assistance)
    eventPlayer.Hud_Seeker_Assistance = null

    wait(5)

    eventPlayer.HiderPulseOnCooldown = false

rule "On Cooldown Seeker Assistance":
    @Event eachPlayer
    @Team 2
    @Condition WS_SET_SEEKER_ASSIST == true
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.isHoldingButton(Button.CROUCH)
    @Condition eventPlayer.HiderPulseOnCooldown == true

    waitUntil(not eventPlayer.isHoldingButton(Button.CROUCH), 9999)
    waitUntil(eventPlayer.isHoldingButton(Button.CROUCH), 0.125)
    if not eventPlayer.isHoldingButton(Button.CROUCH):
        return

    if eventPlayer.SphereDetectionRadius > 0:
        smallMessage(eventPlayer, fixedString(STR_SEEKER_ASSISTANCE_USING))
    else:
        smallMessage(eventPlayer, fixedString(STR_SEEKER_ASSISTANCE_COOLDOWN))

rule "Seeker Tips":
    waitUntil(CurrentGameState != GAME_STATE.WAITING, 9999)
    wait(5)
    while CurrentGameState != GAME_STATE.WAITING:
        selectedTip[2] = STR_TIPS_SEEKER

        if selectedTip[2] in usedSeekerTips:
            wait(0.125)
            continue

        usedSeekerTips.append(selectedTip[2])
        smallMessage(getPlayers(Team.2), fixedString(selectedTip[2]))
        wait((WS_SET_HIDETIME + WS_SET_SEEKTIME) / 10)
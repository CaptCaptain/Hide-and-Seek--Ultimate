#!mainFile "settings.opy"

enum CAMERA_STATE:
    FIRST_PERSON,
    LAYING_DOWN,
    THIRD_PERSON,
    LAST_HIDER

globalvar Hud_GameInfo
globalvar Hud_GameTitle
playervar Hud_Player
globalvar globalHudIndex = 0
playervar playerHudIndex = 0
playervar playerIndex = 0
playervar BaseMoveSpeed = 100 * WS_SET_ADV_BASESPEED
playervar BaseJumpHeight = 100 * WS_SET_ADV_BASESPEED
playervar BaseScaling = WS_SET_ADV_SCALE
playervar HiderSlowFactor = 2
playervar DvaMechPosition
playervar DvaHasTeleported
playervar LastWalkablePosition
playervar ThirdPersonCameraEnabled = true if WS_SET_3RD_CAM == ACCESSIBILITY.3RD_CAMERA_ON else false
playervar LayingDownCameraEnabled = false
playervar CameraState = CAMERA_STATE.THIRD_PERSON if WS_SET_3RD_CAM == ACCESSIBILITY.3RD_CAMERA_ON else CAMERA_STATE.FIRST_PERSON
playervar SlingshotPosition
playervar SlingshotEnabled = false
playervar SlingshotUsed = false
playervar Hud_Slingshot = []
playervar PreviousPosition

#!define GetSlingshotPosition() updateEveryTick(raycast(raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + (eventPlayer.getFacingDirection() * 15), null, eventPlayer, false).getHitPosition() + Vector.UP, raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + (eventPlayer.getFacingDirection() * 15), null, eventPlayer, false).getHitPosition() + (Vector.DOWN * 100), null, eventPlayer, false).getHitPosition())

#!define StyleString [STR_STYLE_DEFAULT, STR_STYLE_GLITCH, STR_STYLE_TINY, STR_STYLE_MERCY_V_REIN][WS_SET_MODE_RAW]
#!define GameStateString [STR_GAME_STATE_WAITING, STR_GAME_STATE_HIDING, STR_GAME_STATE_SEEKING, STR_GAME_STATE_RESULTS, STR_GAME_STATE_END][CurrentGameState]
#!define SeekerOutlineString STR_SEEKER_OUTLINES_DEFAULT if WS_SET_SEEKER_OUTLINES == ACCESSIBILITY.SEEKER_OUTLINES_DEFAULT else STR_SEEKER_OUTLINES_OCCLUDED if WS_SET_SEEKER_OUTLINES == ACCESSIBILITY.SEEKER_OUTLINES_OCCLUDED else STR_SEEKER_OUTLINES_ALWAYS
#!define ShowHiderString STR_SHOW_LAST_HIDER if WS_SET_SHOW_HIDERS == SHOW_HIDERS.LAST_HIDER else true if WS_SET_SHOW_HIDERS == SHOW_HIDERS.ALL_HIDERS else false
#!define TankScalingString STR_RULESET_AUTOMATIC if WS_SET_ADV_TANKSCALING == ACCESSIBILITY.TANKS_SCALE else true if WS_SET_ADV_TANKSCALING == ACCESSIBILITY.TANKS_SCALE_ALL else false

subroutine StartThirdPersonCamera
subroutine StartCamera
subroutine RestrictAbilities
subroutine SlingshotCooldown

def SlingshotCooldown():
    eventPlayer.SlingshotUsed = true
    wait(8 if CurrentGameState == GAME_STATE.SEEKING else 5)
    eventPlayer.SlingshotUsed = false

def StartCamera():
    eventPlayer.startCamera(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + (eventPlayer.getFacingDirection() * 1), 60)
    wait()

def StartThirdPersonCamera():
    eventPlayer.startCamera(updateEveryTick(raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + worldVector(vect(1 * -1, 0, 0), eventPlayer, Transform.ROTATION) + eventPlayer.getFacingDirection() * -2.5, getAllPlayers(), eventPlayer, false).getHitPosition()), updateEveryTick(raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 200, getAllPlayers(), eventPlayer, false).getHitPosition()), 60)

def RestrictAbilities():
    eventPlayer.setAbility1Enabled(true)
    eventPlayer.setAbility2Enabled(true)
    eventPlayer.setSecondaryFireEnabled(true)
    if WS_SET_MODE == STYLE.MERCY_REIN: goto skip_evaluation
    switch eventPlayer.getTeam():
        case Team.1:
            switch eventPlayer.getCurrentHero():
                case Hero.MERCY:
                    eventPlayer.setAbility2Enabled(false)
                    break
            break
        case Team.2:
            switch eventPlayer.getCurrentHero():
                case Hero.ORISA:
                    eventPlayer.setSecondaryFireEnabled(false)
                    break
                case Hero.HANZO:
                    eventPlayer.setAbility1Enabled(false)
                    break
                case Hero.SYMMETRA:
                    eventPlayer.setAbility1Enabled(false)
                    break
                case Hero.TORBJORN:
                    eventPlayer.setAbility1Enabled(false)
                    break
                case Hero.WIDOWMAKER:
                    eventPlayer.setAbility2Enabled(false)
                    break
                case Hero.JUNKRAT:
                    eventPlayer.setAbility2Enabled(false)
                    break
            break
    skip_evaluation:

rule "Create Player Huds":
    @Event eachPlayer

    # Destroy player huds
    for eventPlayer.playerHudIndex in range(0, len(eventPlayer.Hud_Player)):
        destroyHudText(eventPlayer.Hud_Player[eventPlayer.playerHudIndex])
    eventPlayer.Hud_Player = []

    waitUntil(eventPlayer.hasSpawned(), 9999)

    # Creates the Objective Hud
    hudText(eventPlayer, "{} {}".format(abilityIconString(eventPlayer.getCurrentHero(), Button.ULTIMATE) if eventPlayer.getTeam() == Team.1 else abilityIconString(eventPlayer.getCurrentHero(), Button.PRIMARY_FIRE), STR_HIDER if eventPlayer.getTeam() == Team.1 else STR_SEEKER), "{}: {}".format(STR_PHASE, GameStateString), "{}:{}".format(floor(((CurrentTime % 86400) % 3600) / 60), floor(((CurrentTime % 86400) % 3600) % 60)) if CurrentTime > 60 else "{}".format(CurrentTime), HudPosition.TOP, 1, Color.BLUE if eventPlayer.getTeam() == Team.1 else Color.RED, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)
    eventPlayer.Hud_Player.append(getLastCreatedText())

    # Slingshot Instructions
    if WS_SET_USE_SLINGSHOT == true:
        hudSubheader(eventPlayer, "[{}]: {} / [{}]: {}".format(buttonString(Button.INTERACT), STR_SLINGSHOT_USAGE_TOGGLE, buttonString(Button.PRIMARY_FIRE), STR_SLINGSHOT_USAGE_CONFIRM), HudPosition.TOP, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
        eventPlayer.Hud_Player.append(getLastCreatedText())
    # Camera Hud Instructions
    if WS_SET_3RD_CAM == ACCESSIBILITY.3RD_CAMERA_TOGGLE:
        hudSubheader(eventPlayer, "[{}]: {}".format(buttonString(Button.RELOAD), STR_THIRD_PERSON_CAMERA_USAGE), HudPosition.TOP, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
        eventPlayer.Hud_Player.append(getLastCreatedText())
    # Laying down Instructions
    if WS_SET_LAYING_DOWN == true and eventPlayer.getTeam() == Team.1:
        hudSubheader(eventPlayer, "[{} + {}]: {} / [{}]: {}".format(STR_LAYING_DOWN_EMOTE, buttonString(Button.CROUCH), STR_LAYING_DOWN_LAYING, buttonString(Button.JUMP), STR_LAYING_DOWN_STAND), HudPosition.TOP, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
        eventPlayer.Hud_Player.append(getLastCreatedText())

rule "Title Hud":
    createInWorldText(getAllPlayers(), STR_GAME_TITLE, getObjectivePosition(getCurrentObjective()) + vect(0, 4, 0),5, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION, Color.BLUE, SpecVisibility.NEVER)
    Hud_GameTitle.append(getLastCreatedText())
    createInWorldText(getAllPlayers(), STR_GAME_SUBTITLE, getObjectivePosition(getCurrentObjective()) + vect(0, 3.5, 0),2, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION, Color.SKY_BLUE, SpecVisibility.NEVER)
    Hud_GameTitle.append(getLastCreatedText())
    createInWorldText(getAllPlayers(), "{}: {}".format(STR_GAME_STYLE, StyleString), getObjectivePosition(getCurrentObjective()) + vect(0, 3, 0),1, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.ROSE, SpecVisibility.NEVER)
    Hud_GameTitle.append(getLastCreatedText())
    createInWorldText(getAllPlayers(), STR_GAME_WAITING_FOR_PLAYERS, getObjectivePosition(getCurrentObjective()) + vect(0, 2.25, 0),1, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION, Color.WHITE, SpecVisibility.NEVER)
    Hud_GameTitle.append(getLastCreatedText())
    createEffect(getAllPlayers(), Effect.RING, Color.TURQUOISE, getObjectivePosition(getCurrentObjective()), 10, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    Hud_GameTitle.append(getLastCreatedEntity())

    waitUntil(CurrentGameState != GAME_STATE.WAITING, 9999)

    for globalHudIndex in range(0, len(Hud_GameTitle)):
        destroyInWorldText(Hud_GameTitle[globalHudIndex])
        destroyEffect(Hud_GameTitle[globalHudIndex])
    Hud_GameTitle = null

rule "Global Huds":
    @Condition CurrentGameState == GAME_STATE.HIDING

    hudSubheader(getAllPlayers(), STR_VERSION, HudPosition.RIGHT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubheader(getAllPlayers(), STR_WEBLINK, HudPosition.RIGHT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubtext(getAllPlayers(), STR_GAME_NAME, HudPosition.RIGHT, 0, Color.SKY_BLUE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudHeader(getAllPlayers(), STR_RULESET_TITLE, HudPosition.LEFT, 1, Color.ROSE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubtext(getAllPlayers(), STR_RULESET_STYLE, HudPosition.LEFT, 2, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubtext(getAllPlayers(), STR_RULESET_FIRST_WINS, HudPosition.LEFT, 3, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubtext(getAllPlayers(), STR_RULESET_SEEK_TIME, HudPosition.LEFT, 4, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubtext(getAllPlayers(), STR_RULESET_HIDING_TIME, HudPosition.LEFT, 4, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubtext(getAllPlayers(), STR_RULESET_PLAYER_SIZE, HudPosition.LEFT, 4, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubtext(getAllPlayers(), STR_RULESET_PLAYER_SPEED, HudPosition.LEFT, 4, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    if WS_SET_SEEKER_OUTLINES != ACCESSIBILITY.SEEKER_OUTLINES_DEFAULT:
        hudSubtext(getAllPlayers(), STR_RULESET_SEEKER_OUTLINES, HudPosition.LEFT, 4, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
        Hud_GameInfo.append(getLastCreatedText())
        
    hudSubtext(getAllPlayers(), STR_RULESET_HIDER_OUTLINES, HudPosition.LEFT, 4, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    if WS_SET_SEEKER_ASSIST:
        hudSubtext(getAllPlayers(), STR_RULESET_SEEKER_ASSIST, HudPosition.LEFT, 4.1, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
        Hud_GameInfo.append(getLastCreatedText())
    
    if WS_SET_ADV_TANKSCALING != ACCESSIBILITY.TANKS_NOSCALE:
        hudSubtext(getAllPlayers(), STR_RULESET_TANK_SCALING, HudPosition.LEFT, 5, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
        Hud_GameInfo.append(getLastCreatedText())

    if WS_SET_USE_SLINGSHOT:
        hudSubtext(getAllPlayers(), STR_RULESET_SLINGSHOT, HudPosition.LEFT, 5, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
        Hud_GameInfo.append(getLastCreatedText())
    
    if WS_SET_SLOWHIDER == true:
        hudSubtext(getAllPlayers(), STR_RULESET_SLOW_HIDERS, HudPosition.LEFT, 5, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
        Hud_GameInfo.append(getLastCreatedText())

    if WS_SET_LAYING_DOWN:
        hudSubtext(getAllPlayers(), STR_RULESET_LAYING_DOWN, HudPosition.LEFT, 5, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
        Hud_GameInfo.append(getLastCreatedText())

    if WS_SET_SHOW_HIDERS != SHOW_HIDERS.OFF:
        hudSubtext(getAllPlayers(), STR_RULESET_SHOW_HIDERS, HudPosition.LEFT, 5.1, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
        Hud_GameInfo.append(getLastCreatedText())

    if WS_SET_ADV_INF_HAMMOND_GRAPPLE == true:
        hudSubtext(getAllPlayers(), STR_RULESET_WB_INF_GRAPPLE, HudPosition.LEFT, 5, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
        Hud_GameInfo.append(getLastCreatedText())
    
    if WS_SET_ADV_SEEK_ALLOWH == true:
        hudSubtext(getAllPlayers(), STR_RULESET_RESTRICT_SEEKER_HERO, HudPosition.LEFT, 5, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
        Hud_GameInfo.append(getLastCreatedText())

    hudSubheader(getAllPlayers(), STR_RULESET_CHANGE_HOST, HudPosition.LEFT, 6, Color.TURQUOISE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubheader(getAllPlayers(), STR_RULESET_CHECK_CHANGE, HudPosition.LEFT, 7, Color.TURQUOISE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    if WS_SET_ADV_WINS > 1:
        hudText(getAllPlayers(), STR_TEAM_SCORE_TITLE, "", STR_TEAM_SCORE, HudPosition.LEFT, 8, Color.TEAM_1, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
        Hud_GameInfo.append(getLastCreatedText())

rule "Remove Global Huds":
    @Condition CurrentGameState == GAME_STATE.SEEKING
    for globalHudIndex in range(0, len(Hud_GameInfo)):
        destroyHudText(Hud_GameInfo[globalHudIndex])
    Hud_GameInfo = null

rule "Player Scaling":
    @Event eachPlayer
    @Condition (eventPlayer.BaseScaling > 1 or eventPlayer.BaseScaling < 1) or (WS_SET_ADV_TANKSCALING == ACCESSIBILITY.TANKS_SCALE or WS_SET_ADV_TANKSCALING == ACCESSIBILITY.TANKS_SCALE_ALL)

    # Scales the player
    eventPlayer.startScalingSize(eventPlayer.BaseScaling, true)
    eventPlayer.startScalingBarriers(eventPlayer.BaseScaling, true)
    if not (WS_SET_ADV_SCALE > 1 or WS_SET_ADV_SCALE < 1): goto skip_voice_modification
    eventPlayer.startModifyingVoicelinePitch(2 - eventPlayer.BaseScaling, true)
    skip_voice_modification:

rule "Player Setup":
    @Event eachPlayer

    eventPlayer.disableGamemodeHud()
    eventPlayer.disableRespawn()
    eventPlayer.setMoveSpeed(eventPlayer.BaseMoveSpeed)
    eventPlayer.setJumpVerticalSpeed(eventPlayer.BaseJumpHeight)
    
    # Glitch Mode
    if WS_SET_MODE == STYLE.GLITCH:
        eventPlayer.disableEnvironmentCollision(false)

    # Teleport to Objective
    waitUntil(eventPlayer.hasSpawned(), 9999)
    eventPlayer.DvaMechPosition = eventPlayer.getPosition()
    RestrictAbilities()
    if CurrentGameState == GAME_STATE.WAITING:
        eventPlayer.teleport(nearestWalkablePosition(getObjectivePosition(getCurrentObjective()) + vect(random.randint(-10, 10), 0, random.randint(-10, 10))))
        wait()
        eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), getObjectivePosition(getCurrentObjective())) + vect(0, 0.5, 0), Relativity.TO_WORLD)

rule "Reset Ammo":
    @Event eachPlayer
    @Condition eventPlayer.getAmmo(0) > 0
    @Condition not eventPlayer.isFiringPrimaryFire() and not eventPlayer.isFiringSecondaryFire()

    # Reset ammo when player has not fired for more than a second
    wait(1, Wait.ABORT_WHEN_FALSE)
    eventPlayer.setAmmo(0, eventPlayer.getMaxAmmo(0))

rule "Resurrect":
    @Event playerDied
    @Condition eventWasEnvironment or attacker() == victim()
    @Condition not eventPlayer.isInSpawnRoom()

    # If the player dies to the environment or self-destructs.
    eventPlayer.resurrect()
    eventPlayer.teleport(eventPlayer.LastWalkablePosition if eventPlayer.LastWalkablePosition != null else nearestWalkablePosition(eventPlayer.getPosition()))
    eventPlayer.setStatusEffect(null, Status.STUNNED, 2)
    if attacker() == victim(): eventPlayer.setStatusEffect(null, Status.INVINCIBLE, 1)
    smallMessage(eventPlayer, STR_BE_CAREFUL)

rule "Disable Abilities In Spawn":
    @Event eachPlayer
    @Condition eventPlayer.isInSpawnRoom()

    eventPlayer.setAbility1Enabled(false)
    eventPlayer.setAbility2Enabled(false)
    eventPlayer.setSecondaryFireEnabled(false)
    eventPlayer.cancelPrimaryAction()

    waitUntil(not eventPlayer.isInSpawnRoom(), 9999)

    RestrictAbilities()

rule "Set Last Walkable Position":
    @Event eachPlayer
    @Condition eventPlayer.isMoving() and eventPlayer.isOnGround()

    eventPlayer.LastWalkablePosition = nearestWalkablePosition(eventPlayer.getPosition())

    waitUntil(eventPlayer.isOnGround(), 9999)

rule "Show Remaining Hiders":
    @Event eachPlayer
    @Condition eventPlayer.ShowHiders == true

    if eventPlayer.CameraState == CAMERA_STATE.FIRST_PERSON:
        # Smooth camera transition
        eventPlayer.startCamera(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + (eventPlayer.getFacingDirection() * 1), 5)
        wait()
    eventPlayer.CameraState = CAMERA_STATE.LAST_HIDER
    eventPlayer.disableHeroHUD()
    eventPlayer.startCamera(evalOnce(eventPlayer.getPosition() + (Vector.UP * 100) + Vector.BACKWARD), evalOnce(eventPlayer.getPosition()), 5)
    wait(1)
    for eventPlayer.playerIndex in range(0, len(getLivingPlayers(Team.1))):
        eventPlayer.startCamera(raycast(getLivingPlayers(Team.1)[eventPlayer.playerIndex].getPosition(), getLivingPlayers(Team.1)[eventPlayer.playerIndex].getPosition() + (Vector.UP * 5) + vect(0.001, 0, 0), null, getLivingPlayers(Team.1)[eventPlayer.playerIndex], false).getHitPosition(), getLivingPlayers(Team.1)[eventPlayer.playerIndex].getPosition(), 10)
        wait(2)
        eventPlayer.startCamera(evalOnce(getLivingPlayers(Team.1)[eventPlayer.playerIndex].getPosition() + (Vector.UP * 100) + Vector.BACKWARD), evalOnce(getLivingPlayers(Team.1)[eventPlayer.playerIndex].getPosition()), 5)
        wait(1)
    eventPlayer.enableHeroHud()

    # Return to previous camera state
    if eventPlayer.LayingDownCameraEnabled == true:
        eventPlayer.CameraState = CAMERA_STATE.LAYING_DOWN
    elif eventPlayer.ThirdPersonCameraEnabled == true:
        eventPlayer.CameraState = CAMERA_STATE.THIRD_PERSON
    else:
        eventPlayer.CameraState = CAMERA_STATE.FIRST_PERSON
    
    eventPlayer.ShowHiders = false

# Accessibility Rules
rule "D.va: TP to Mech Position (Hider)":
    @Event eachPlayer
    @Team 1
    @Hero dva
    @Condition CurrentGameState == GAME_STATE.HIDING
    @Condition eventPlayer.DvaHasTeleported == false

    eventPlayer.DvaHasTeleported = true
    
    eventPlayer.teleport(eventPlayer.DvaMechPosition)

rule "D.va: TP to Mech Position (Seeker)":
    @Event eachPlayer
    @Team 2
    @Hero dva
    @Condition CurrentGameState == GAME_STATE.HIDING
    @Condition not eventPlayer.isInSpawnRoom()
    
    wait(0.25, Wait.ABORT_WHEN_FALSE)
    eventPlayer.teleport(eventPlayer.DvaMechPosition)

rule "D.va: Ult":
    @Event eachPlayer
    @Hero dva

    eventPlayer.setUltEnabled(true)
    eventPlayer.disallowButton(Button.ULTIMATE)

rule "D.va: Get Ult In Spawn":
    @Event eachPlayer
    @Hero dva
    @Condition eventPlayer.isInSpawnRoom()

    eventPlayer.setUltCharge(100)

rule "D.va: Enable De-mech":
    @Event eachPlayer
    @Hero dva
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE)

    if not eventPlayer.isInAlternateForm() and (WS_SET_ADV_DVA_MECH == ACCESSIBILITY.DVA_MECH_ALLOW_DEMECH or WS_SET_ADV_DVA_MECH == ACCESSIBILITY.DVA_MECH_ALLOW_BOTH):
        eventPlayer.setUltCharge(0)
        kill(eventPlayer, null)
        if WS_SET_ADV_DVA_MECH == ACCESSIBILITY.DVA_MECH_ALLOW_BOTH:
            waitUntil(eventPlayer.isInAlternateForm(), 9999)
            eventPlayer.allowButton(Button.ULTIMATE)
            eventPlayer.setUltCharge(100)
    elif eventPlayer.isInAlternateForm() and WS_SET_ADV_DVA_MECH == ACCESSIBILITY.DVA_MECH_ALLOW_BOTH:
        eventPlayer.allowButton(Button.ULTIMATE)
        eventPlayer.forceButtonPress(Button.ULTIMATE)
        waitUntil(not eventPlayer.isInAlternateForm(), 9999)
        eventPlayer.disallowButton(Button.ULTIMATE)

rule "Start Third Person Camera":
    @Event eachPlayer
    @Condition eventPlayer.CameraState == CAMERA_STATE.THIRD_PERSON

    # Smooth transition to third person camera
    StartCamera()
    StartThirdPersonCamera()

rule "Start Laying Down Camera":
    @Event eachPlayer
    @Condition eventPlayer.CameraState == CAMERA_STATE.LAYING_DOWN

    # Smooth transition to third person camera
    StartCamera()
    eventPlayer.startCamera(raycast(eventPlayer.getEyePosition(), eventPlayer.getPosition() + (Vector.UP * 10) + vect(0.001, 0, 0), null, eventPlayer, false).getHitPosition(), eventPlayer.getPosition(), 10)

rule "Stop Camera":
    @Event eachPlayer
    @Condition eventPlayer.CameraState == CAMERA_STATE.FIRST_PERSON

    # Smooth transition to first person camera
    eventPlayer.startCamera(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + (eventPlayer.getFacingDirection() * 1), 60)
    wait(0.08)
    eventPlayer.stopCamera()

rule "Toggle Third Person Camera":
    @Event eachPlayer
    @Condition WS_SET_3RD_CAM == ACCESSIBILITY.3RD_CAMERA_TOGGLE
    @Condition eventPlayer.CameraState == CAMERA_STATE.FIRST_PERSON or eventPlayer.CameraState == CAMERA_STATE.THIRD_PERSON
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) and eventPlayer.getAmmo(0) == eventPlayer.getMaxAmmo(0)

    eventPlayer.ThirdPersonCameraEnabled = not eventPlayer.ThirdPersonCameraEnabled
    eventPlayer.CameraState = CAMERA_STATE.THIRD_PERSON if eventPlayer.ThirdPersonCameraEnabled else CAMERA_STATE.FIRST_PERSON

rule "Toggle Slingshot":
    @Event eachPlayer
    @Condition WS_SET_USE_SLINGSHOT == true
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)

    wait()

    if WS_SET_SLOWHIDER and any([isInLoS(eventPlayer, player, BarrierLos.PASS_THROUGH_BARRIERS) for player in getPlayers(Team.2)]) and eventPlayer.getTeam() == Team.1:
        smallMessage(eventPlayer, STR_SLINGSHOT_CANNOT_USE)
        return
    # Using interact with abilities take priority over slingshot toggle
    elif any([interactButtonOccupied == true for interactButtonOccupied in [eventPlayer.getCurrentHero() == Hero.SOMBRA and eventPlayer.isUsingAbility2(), eventPlayer.getCurrentHero() == Hero.TORBJORN and eventPlayer.isUsingAbility1(), distance(eventPlayer.getPosition(), eventPlayer.PreviousPosition) > 1 and any([player.isUsingAbility2() for player in getPlayersOnHero(Hero.SYMMETRA, eventPlayer.getTeam())])]]):
        return

    eventPlayer.SlingshotEnabled = not eventPlayer.SlingshotEnabled

rule "Disable Slingshot":
    @Event eachPlayer
    @Condition eventPlayer.isCommunicatingEmote()

    eventPlayer.SlingshotEnabled = false

rule "Create Slingshot Effects":
    @Event eachPlayer
    @Condition eventPlayer.SlingshotEnabled == true

    playEffect(eventPlayer, DynamicEffect.GOOD_EXPLOSION,  Color.YELLOW if not eventPlayer.SlingshotUsed else Color.ROSE, GetSlingshotPosition(), 1)
    playEffect(eventPlayer, DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, eventPlayer, 100)

    # Create slingshot destination effect
    createEffect(eventPlayer, Effect.LIGHT_SHAFT, Color.YELLOW if not eventPlayer.SlingshotUsed else Color.ROSE, GetSlingshotPosition(), 0.1, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
    eventPlayer.Hud_Slingshot.append(getLastCreatedEntity())

    createEffect(eventPlayer, Effect.RING, Color.YELLOW if not eventPlayer.SlingshotUsed else Color.ROSE, GetSlingshotPosition(), 1, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
    eventPlayer.Hud_Slingshot.append(getLastCreatedEntity())

    # Disallow Primary Fire
    eventPlayer.disallowButton(Button.PRIMARY_FIRE)

rule "Destroy Slingshot Effects":
    @Event eachPlayer
    @Condition eventPlayer.SlingshotEnabled == false

    playEffect(eventPlayer, DynamicEffect.GOOD_EXPLOSION, Color.YELLOW if not eventPlayer.SlingshotUsed else Color.ROSE, GetSlingshotPosition(), 1)
    playEffect(eventPlayer, DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)
    for eventPlayer.playerHudIndex in range(0, len(eventPlayer.Hud_Slingshot)):
        destroyEffect(eventPlayer.Hud_Slingshot[eventPlayer.playerHudIndex])
    eventPlayer.Hud_Slingshot = []

    # Allow Primary Fire
    eventPlayer.allowButton(Button.PRIMARY_FIRE)

rule "Confirm Slingshot":
    @Event eachPlayer
    @Condition eventPlayer.SlingshotEnabled == true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)

    if eventPlayer.SlingshotUsed:
        smallMessage(eventPlayer, STR_SLINGSHOT_ON_COOLDOWN)
        return
    elif eventPlayer.isInAir():
        smallMessage(eventPlayer, STR_SLINGSHOT_CANT_IN_AIR)
        return

    playEffect(getPlayers(getOppositeTeam(eventPlayer.getTeam())), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, eventPlayer, 30)
    playEffect(eventPlayer, DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)

    # Fling player toward point
    eventPlayer.SlingshotPosition = GetSlingshotPosition()
    eventPlayer.setGravity(0)
    eventPlayer.applyImpulse(directionTowards(eventPlayer.getPosition(), eventPlayer.SlingshotPosition + (Vector.UP * 2)), distance(eventPlayer.getPosition(), eventPlayer.SlingshotPosition) * 2.5, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    wait()
    eventPlayer.setGravity(100)

    async(SlingshotCooldown, AsyncBehavior.NOOP)

rule "Symmetra TP Detection: Track Previous Position":
    @Event eachPlayer
    @Condition WS_SET_USE_SLINGSHOT
    @Condition eventPlayer.hasSpawned()
    @Condition any([player.isUsingAbility2() for player in getPlayersOnHero(Hero.SYMMETRA, eventPlayer.getTeam())])

    # This lets us know if they went through a Symmetra teleporter.
    eventPlayer.PreviousPosition = eventPlayer.getPosition()    
    chase(eventPlayer.PreviousPosition, eventPlayer.getPosition(), rate=50, ChaseReeval.DESTINATION_AND_RATE)

    printLog("Symmetra Teleporter Detection Started for {}".format(eventPlayer))

rule "Symmetra TP Detection: Stop Tracking Previous Position":
    @Event eachPlayer
    @Condition WS_SET_USE_SLINGSHOT
    @Condition eventPlayer.hasSpawned()
    @Condition all([not player.isUsingAbility2() for player in getPlayersOnHero(Hero.SYMMETRA, eventPlayer.getTeam())])

    # We don't need to track the player's last position if no teleporter is up.
    stopChasingVariable(eventPlayer.PreviousPosition)

    printLog("Symmetra Teleporter Detection Stopped for {}".format(eventPlayer))

rule "Show Debug Stats":
    @Condition WS_SET_ADV_DEBUGSTATS != SHOW_DEBUG_STATS.NONE

    hudSubtext(hostPlayer if WS_SET_ADV_DEBUGSTATS == SHOW_DEBUG_STATS.HOST else getAllPlayers(), "DEBUG STATS".format(getServerLoad(), getAverageServerLoad(), getPeakServerLoad()), HudPosition.LEFT, -2, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader(hostPlayer if WS_SET_ADV_DEBUGSTATS == SHOW_DEBUG_STATS.HOST else getAllPlayers(), "SERVER LOAD: {}\nSERVER LOAD AVERAGE: {}\nSERVER LOAD PEAK: {}\n".format(getServerLoad(), getAverageServerLoad(), getPeakServerLoad()), HudPosition.LEFT, -1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader(hostPlayer if WS_SET_ADV_DEBUGSTATS == SHOW_DEBUG_STATS.HOST else getAllPlayers(), "CURRENT TIME: {}".format(CurrentTime), HudPosition.LEFT, -1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)

#!include "hider.opy"
#!include "seeker.opy"
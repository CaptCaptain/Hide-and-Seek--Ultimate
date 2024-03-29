#!mainFile "settings.opy"

enum CAMERA_STATE:
    FIRST_PERSON,
    LAYING_DOWN,
    THIRD_PERSON,
    LAST_HIDER,
    CEILING,
    SPECTATE

globalvar globalHudIndex = 0
playervar playerHudIndex = 0
playervar playerIndex = 0

globalvar selectedTip = [[],[]]
globalvar usedHiderTips = []
globalvar usedSeekerTips = []

globalvar Hud_GameInfo
globalvar Hud_GameTitle
playervar Hud_Player

playervar BaseMoveSpeed = 100 * WS_SET_ADV_BASESPEED
playervar BaseJumpHeight = 100 * WS_SET_ADV_BASESPEED
playervar BaseScaling = WS_SET_ADV_SCALE

playervar HiderSlowFactor = 2
playervar DvaMechPosition
playervar DvaHasTeleported
playervar LastWalkablePosition
playervar ResurrectBlocked

playervar CameraState = CAMERA_STATE.THIRD_PERSON if WS_SET_3RD_CAM == ACCESSIBILITY.3RD_CAMERA_ON else CAMERA_STATE.FIRST_PERSON
playervar ThirdPersonCameraEnabled = true if WS_SET_3RD_CAM == ACCESSIBILITY.3RD_CAMERA_ON else false
playervar LayingDownCameraEnabled = false
playervar CeilingCameraEnabled = false
playervar SlingshotPosition
playervar SlingshotEnabled = false
playervar SlingshotUsed = false
playervar Hud_Slingshot = []
playervar PreviousPosition
playervar SpectatePlayerSlot
playervar SpectateCameraEnabled = false

#!define GetSpectateablePlayers [player for player in getAllPlayers() if player.hasSpawned()].exclude(eventPlayer)
#!define SpectatePlayer GetSpectateablePlayers[eventPlayer.SpectatePlayerSlot]

#!define GetSlingshotPosition() updateEveryTick(raycast(raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + (eventPlayer.getFacingDirection() * 15), null, eventPlayer, false).getHitPosition() + Vector.UP, raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + (eventPlayer.getFacingDirection() * 15), null, eventPlayer, false).getHitPosition() + (Vector.DOWN * 100), null, eventPlayer, false).getHitPosition())

#!define StyleString [STR_STYLE_DEFAULT, STR_STYLE_GLITCH, STR_STYLE_TINY, STR_STYLE_MERCY_V_REIN][WS_SET_MODE_RAW]
#!define GameStateString [STR_GAME_STATE_WAITING, STR_GAME_STATE_HIDING, STR_GAME_STATE_SEEKING, STR_GAME_STATE_RESULTS, STR_GAME_STATE_END][CurrentGameState]
#!define SeekerOutlineString STR_SEEKER_OUTLINES_DEFAULT if WS_SET_SEEKER_OUTLINES == ACCESSIBILITY.SEEKER_OUTLINES_DEFAULT else STR_SEEKER_OUTLINES_OCCLUDED if WS_SET_SEEKER_OUTLINES == ACCESSIBILITY.SEEKER_OUTLINES_OCCLUDED else STR_SEEKER_OUTLINES_ALWAYS
#!define ShowHiderString STR_SHOW_LAST_HIDER if WS_SET_SHOW_HIDERS == SHOW_HIDERS.LAST_HIDER else true if WS_SET_SHOW_HIDERS == SHOW_HIDERS.ALL_HIDERS else false
#!define TankScalingString STR_RULESET_AUTOMATIC if WS_SET_ADV_TANKSCALING == ACCESSIBILITY.TANKS_SCALE else true if WS_SET_ADV_TANKSCALING == ACCESSIBILITY.TANKS_SCALE_ALL else false

subroutine StartThirdPersonCamera
subroutine StartCamera
subroutine SlingshotCooldown
subroutine RestrictAbilities
subroutine RestrictAbilitiesInSpawn
subroutine StartSpectateCamera

def SlingshotCooldown():
    eventPlayer.SlingshotUsed = true
    waitUntil(eventPlayer.isOnGround() or eventPlayer.getTeam() == Team.2, 9999)
    wait(8 if CurrentGameState == GAME_STATE.SEEKING and eventPlayer.getTeam() == Team.1 else 1)
    eventPlayer.SlingshotUsed = false

def StartCamera():
    eventPlayer.startCamera(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + (eventPlayer.getFacingDirection() * 1), 60)
    wait()

def StartThirdPersonCamera():
    eventPlayer.startCamera(updateEveryTick(raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + worldVector(vect(1 * -1, 0, 0), eventPlayer, Transform.ROTATION) + eventPlayer.getFacingDirection() * -2.5, getAllPlayers(), eventPlayer, false).getHitPosition()), updateEveryTick(raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 200, getAllPlayers(), eventPlayer, false).getHitPosition()), 60)

def StartSpectateCamera():
    eventPlayer.startCamera(updateEveryTick(raycast(SpectatePlayer.getEyePosition(), SpectatePlayer.getEyePosition() + worldVector(vect(1 * -1, 0, 0), SpectatePlayer, Transform.ROTATION) + SpectatePlayer.getFacingDirection() * -2.5, getAllPlayers(), SpectatePlayer, false).getHitPosition()), updateEveryTick(raycast(SpectatePlayer.getEyePosition(), SpectatePlayer.getEyePosition() + SpectatePlayer.getFacingDirection() * 200, getAllPlayers(), SpectatePlayer, false).getHitPosition()), 60)

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
                case Hero.HANZO:
                    eventPlayer.setAbility1Enabled(false)
                    break
            break
        case Team.2:
            switch eventPlayer.getCurrentHero():
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
                case Hero.MOIRA:
                    eventPlayer.setAbility2Enabled(false)
                    break
                case Hero.SOMBRA:
                    eventPlayer.setSecondaryFireEnabled(false)
                    break
                case Hero.ZENYATTA:
                    eventPlayer.setAbility2Enabled(false)
                    break
                case Hero.JUNKER_QUEEN:
                    eventPlayer.setSecondaryFireEnabled(false)
                    break
            break
    skip_evaluation:

def RestrictAbilitiesInSpawn():
    eventPlayer.setAbility1Enabled(true)
    eventPlayer.setAbility2Enabled(true)
    eventPlayer.setSecondaryFireEnabled(true)
    if WS_SET_MODE == STYLE.MERCY_REIN: goto skip_evaluation
    switch eventPlayer.getTeam():
        case Team.1:
            switch eventPlayer.getCurrentHero():
                case Hero.MEI:
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
        hudSubheader(eventPlayer, STR_SLINGSHOT_USAGE, HudPosition.TOP, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
        eventPlayer.Hud_Player.append(getLastCreatedText())
    # Camera Hud Instructions
    if WS_SET_3RD_CAM == ACCESSIBILITY.3RD_CAMERA_TOGGLE:
        hudSubheader(eventPlayer, STR_THIRD_PERSON_CAMERA_USAGE, HudPosition.TOP, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
        eventPlayer.Hud_Player.append(getLastCreatedText())
    # Laying down Instructions
    if WS_SET_LAYING_DOWN == true and eventPlayer.getTeam() == Team.1:
        hudSubheader(eventPlayer, STR_LAYING_DOWN_USAGE, HudPosition.TOP, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
        eventPlayer.Hud_Player.append(getLastCreatedText())
    # Attach to Ceiling Instructions
    if WS_SET_ATTACH_CEILING == true and eventPlayer.getTeam() == Team.1:
        hudSubheader(eventPlayer, STR_CEILING_ATTACH_USAGE, HudPosition.TOP, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
        eventPlayer.Hud_Player.append(getLastCreatedText())
    # Seeker Assistance Instructions
    if WS_SET_SEEKER_ASSIST == ACCESSIBILITY.SEEKER_ASSIST_ON and eventPlayer.getTeam() == Team.2:
        hudSubheader(eventPlayer, STR_SEEKER_ASSISTANCE_USAGE, HudPosition.TOP, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
        eventPlayer.Hud_Player.append(getLastCreatedText())
    # Spectate Camera
    if eventPlayer.getTeam() == Team.1:
        hudSubheader(eventPlayer, STR_SPECTATE_CAMERA_USAGE, HudPosition.TOP, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
        eventPlayer.Hud_Player.append(getLastCreatedText())
        
rule "Global Huds":
    @Condition CurrentGameState == GAME_STATE.HIDING

    hudSubheader(getAllPlayers(), STR_VERSION, HudPosition.RIGHT, -1, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubheader(getAllPlayers(), STR_WEBLINK, HudPosition.RIGHT, -2, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubtext(getAllPlayers(), STR_GAME_NAME, HudPosition.RIGHT, -3, Color.SKY_BLUE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudHeader(localPlayer if localPlayer.isInSpawnRoom() else null, STR_RULESET_TITLE, HudPosition.LEFT, 1, Color.ROSE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubheader(localPlayer if localPlayer.isInSpawnRoom() else null, STR_RULESET_STYLE, HudPosition.LEFT, 2, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubheader(localPlayer if localPlayer.isInSpawnRoom() else null, STR_RULESET_MAP, HudPosition.LEFT, 2, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubheader(localPlayer if localPlayer.isInSpawnRoom() else null, STR_RULESET_FIRST_WINS, HudPosition.LEFT, 3, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubheader(localPlayer if localPlayer.isInSpawnRoom() else null, STR_RULESET_SEEK_TIME, HudPosition.LEFT, 4, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubheader(localPlayer if localPlayer.isInSpawnRoom() else null, STR_RULESET_HIDING_TIME, HudPosition.LEFT, 4, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubheader(localPlayer if localPlayer.isInSpawnRoom() else null, STR_RULESET_PLAYER_SIZE, HudPosition.LEFT, 4, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubheader(localPlayer if localPlayer.isInSpawnRoom() else null, STR_RULESET_PLAYER_SPEED, HudPosition.LEFT, 4, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    if WS_SET_SEEKER_OUTLINES != ACCESSIBILITY.SEEKER_OUTLINES_DEFAULT:
        hudSubheader(localPlayer if localPlayer.isInSpawnRoom() else null, STR_RULESET_SEEKER_OUTLINES, HudPosition.LEFT, 4, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
        Hud_GameInfo.append(getLastCreatedText())
        
    hudSubheader(localPlayer if localPlayer.isInSpawnRoom() else null, STR_RULESET_HIDER_OUTLINES, HudPosition.LEFT, 4, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    if WS_SET_SEEKER_ASSIST:
        hudSubheader(localPlayer if localPlayer.isInSpawnRoom() else null, STR_RULESET_SEEKER_ASSIST, HudPosition.LEFT, 4.1, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
        Hud_GameInfo.append(getLastCreatedText())
    
    if WS_SET_ADV_TANKSCALING != ACCESSIBILITY.TANKS_NOSCALE:
        hudSubheader(localPlayer if localPlayer.isInSpawnRoom() else null, STR_RULESET_TANK_SCALING, HudPosition.LEFT, 5, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
        Hud_GameInfo.append(getLastCreatedText())

    if WS_SET_USE_SLINGSHOT:
        hudSubheader(localPlayer if localPlayer.isInSpawnRoom() else null, STR_RULESET_SLINGSHOT, HudPosition.LEFT, 5, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
        Hud_GameInfo.append(getLastCreatedText())
    
    if WS_SET_SLOWHIDER == true:
        hudSubheader(localPlayer if localPlayer.isInSpawnRoom() else null, STR_RULESET_SLOW_HIDERS, HudPosition.LEFT, 5, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
        Hud_GameInfo.append(getLastCreatedText())

    if WS_SET_LAYING_DOWN:
        hudSubheader(localPlayer if localPlayer.isInSpawnRoom() else null, STR_RULESET_LAYING_DOWN, HudPosition.LEFT, 5, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
        Hud_GameInfo.append(getLastCreatedText())
    
    if WS_SET_ATTACH_CEILING:
        hudSubheader(localPlayer if localPlayer.isInSpawnRoom() else null, STR_RULESET_CEILING_ATTACH, HudPosition.LEFT, 5, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
        Hud_GameInfo.append(getLastCreatedText())

    if WS_SET_SHOW_HIDERS != SHOW_HIDERS.OFF:
        hudSubheader(localPlayer if localPlayer.isInSpawnRoom() else null, STR_RULESET_SHOW_HIDERS, HudPosition.LEFT, 5.1, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
        Hud_GameInfo.append(getLastCreatedText())

    if WS_SET_ADV_INF_HAMMOND_GRAPPLE == true:
        hudSubheader(localPlayer if localPlayer.isInSpawnRoom() else null, STR_RULESET_WB_INF_GRAPPLE, HudPosition.LEFT, 5, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
        Hud_GameInfo.append(getLastCreatedText())
    
    if WS_SET_ADV_SEEK_ALLOWH == true:
        hudSubheader(localPlayer if localPlayer.isInSpawnRoom() else null, STR_RULESET_RESTRICT_SEEKER_HERO, HudPosition.LEFT, 5, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
        Hud_GameInfo.append(getLastCreatedText())
    
    hudSubheader(localPlayer if localPlayer.isInSpawnRoom() else null, STR_RULESET_MATCH_VOICE_ENABLED, HudPosition.LEFT, 6, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubheader(localPlayer if localPlayer.isInSpawnRoom() else null, STR_RULESET_CHANGE_HOST, HudPosition.LEFT, 7, Color.TURQUOISE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubheader(localPlayer if localPlayer.isInSpawnRoom() else null, STR_RULESET_CHECK_CHANGE, HudPosition.LEFT, 8, Color.TURQUOISE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    if WS_SET_ADV_WINS > 1:
        hudText(getAllPlayers(), STR_TEAM_SCORE_TITLE, "", STR_TEAM_SCORE, HudPosition.LEFT, 9, Color.TEAM_1, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
        Hud_GameInfo.append(getLastCreatedText())

rule "Remove Global Huds":
    @Condition CurrentGameState == GAME_STATE.SEEKING
    for globalHudIndex in range(0, len(Hud_GameInfo)):
        destroyHudText(Hud_GameInfo[globalHudIndex])
    Hud_GameInfo = null

rule "Player Setup":
    @Event eachPlayer

    eventPlayer.disableGamemodeHud()
    eventPlayer.disableRespawn()
    eventPlayer.stopCamera()
    eventPlayer.setMoveSpeed(eventPlayer.BaseMoveSpeed)
    eventPlayer.setJumpVerticalSpeed(eventPlayer.BaseJumpHeight)
    
    # Glitch Mode
    if WS_SET_MODE == STYLE.GLITCH:
        eventPlayer.disableEnvironmentCollision(false)

    waitUntil(eventPlayer.hasSpawned() and eventPlayer.isAlive(), 9999)

    if eventPlayer.JoinedLate:
        return

    wait(1)

    smallMessage(eventPlayer, fixedString(STR_TIP_CONTROLS))

rule "Player Scaling":
    @Event eachPlayer
    @Condition (eventPlayer.BaseScaling > 1 or eventPlayer.BaseScaling < 1) or (WS_SET_ADV_TANKSCALING == ACCESSIBILITY.TANKS_SCALE or WS_SET_ADV_TANKSCALING == ACCESSIBILITY.TANKS_SCALE_ALL)

    # Scales the player
    eventPlayer.startScalingSize(eventPlayer.BaseScaling, true)
    eventPlayer.startScalingBarriers(eventPlayer.BaseScaling, true)
    if not (WS_SET_ADV_SCALE > 1 or WS_SET_ADV_SCALE < 1): goto skip_voice_modification
    eventPlayer.startModifyingVoicelinePitch(2 - eventPlayer.BaseScaling, true)
    skip_voice_modification:

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
    @Condition eventPlayer.ResurrectBlocked == false

    # If the player dies to the environment or self-destructs.
    eventPlayer.resurrect()
    eventPlayer.stopForcingPosition()
    eventPlayer.teleport(eventPlayer.LastWalkablePosition if eventPlayer.LastWalkablePosition != null else nearestWalkablePosition(eventPlayer.getPosition()))
    if nearestWalkablePosition(eventPlayer.getPosition()) == null and eventPlayer.LastWalkablePosition == null:
        eventPlayer.respawn()
    eventPlayer.setStatusEffect(null, Status.ROOTED, 1)
    if attacker() == victim(): eventPlayer.setStatusEffect(null, Status.INVINCIBLE, 1)
    smallMessage(eventPlayer, fixedString(STR_BE_CAREFUL))

rule "Set Last Walkable Position":
    @Event eachPlayer
    @Condition eventPlayer.isMoving() and eventPlayer.isOnGround()

    eventPlayer.LastWalkablePosition = nearestWalkablePosition(eventPlayer.getPosition()) if nearestWalkablePosition(eventPlayer.getPosition()) != null else eventPlayer.getPosition()

    waitUntil(eventPlayer.isOnGround(), 9999)

# Accessibility Rules
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
        eventPlayer.startCamera(raycast(getLivingPlayers(Team.1)[eventPlayer.playerIndex].getPosition(), getLivingPlayers(Team.1)[eventPlayer.playerIndex].getPosition() + (Vector.UP * 5) + vect(0.001, 0, 0), null, getLivingPlayers(Team.1)[eventPlayer.playerIndex], false).getHitPosition(), getLivingPlayers(Team.1)[eventPlayer.playerIndex].getPosition(), 50)
        wait(2.5)
    eventPlayer.enableHeroHud()

    # Return to previous camera state
    if eventPlayer.LayingDownCameraEnabled == true:
        eventPlayer.CameraState = CAMERA_STATE.LAYING_DOWN
    elif eventPlayer.CeilingCameraEnabled == true:
        eventPlayer.CameraState = CAMERA_STATE.CEILING
    elif eventPlayer.ThirdPersonCameraEnabled == true:
        eventPlayer.CameraState = CAMERA_STATE.THIRD_PERSON
    else:
        eventPlayer.CameraState = CAMERA_STATE.FIRST_PERSON
    
    eventPlayer.ShowHiders = false

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
    @Condition eventPlayer.isInSpawnRoom()
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

    # Smooth transition to camera
    StartCamera()
    eventPlayer.startCamera(raycast(eventPlayer.getEyePosition(), eventPlayer.getPosition() + (Vector.UP * 10) + vect(0.001, 0, 0), null, eventPlayer, false).getHitPosition(), eventPlayer.getPosition(), 10)

rule "Start Ceiling Camera":
    @Event eachPlayer
    @Condition eventPlayer.CameraState == CAMERA_STATE.CEILING

    # Smooth transition to camera
    StartCamera()
    wait()
    eventPlayer.startCamera(raycast(eventPlayer.getPosition(), worldVector(vect(0, -1, -3), eventPlayer, Transform.ROTATION_AND_TRANSLATION), null, eventPlayer, false).getHitPosition(), eventPlayer.getPosition() + (Vector.DOWN * 1), 10)

rule "Stop Camera":
    @Event eachPlayer
    @Condition eventPlayer.CameraState == CAMERA_STATE.FIRST_PERSON

    # Smooth transition to first person camera
    eventPlayer.startCamera(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + (eventPlayer.getFacingDirection() * 1), 60)
    wait(0.08)
    eventPlayer.stopCamera()

rule "Start Spectate Camera":
    @Event eachPlayer
    @Condition eventPlayer.CameraState == CAMERA_STATE.SPECTATE

    StartSpectateCamera()

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
    @Condition all([notDoing for notDoing in [not eventPlayer.isCommunicatingEmote(), not eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN)]])
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)

    if WS_SET_SLOWHIDER and any([isInLoS(eventPlayer, player, BarrierLos.PASS_THROUGH_BARRIERS) for player in getPlayers(Team.2)]) and eventPlayer.getTeam() == Team.1:
        smallMessage(eventPlayer, fixedString(STR_SLINGSHOT_CANNOT_USE))
        return
    # Using interact with abilities take priority over slingshot toggle
    elif any([interactButtonOccupied == true for interactButtonOccupied in [eventPlayer.getCurrentHero() == Hero.SOMBRA and eventPlayer.isUsingAbility2(), eventPlayer.getCurrentHero() == Hero.TORBJORN and eventPlayer.isUsingAbility1(), distance(eventPlayer.getPosition(), eventPlayer.PreviousPosition) > 1 and any([player.isUsingAbility2() for player in getPlayersOnHero(Hero.SYMMETRA, eventPlayer.getTeam())])]]):
        return

    eventPlayer.SlingshotEnabled = not eventPlayer.SlingshotEnabled

rule "Disable Slingshot":
    @Event eachPlayer
    @Condition eventPlayer.isCommunicatingEmote() or eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN)

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

    if eventPlayer.hasStatusEffect(Status.ROOTED): return

    if eventPlayer.SlingshotUsed:
        smallMessage(eventPlayer, fixedString(STR_SLINGSHOT_ON_COOLDOWN))
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
    @Condition WS_SET_ADV_DEBUG == true

    hudSubtext(hostPlayer, "DEBUG STATS".format(getServerLoad(), getAverageServerLoad(), getPeakServerLoad()), HudPosition.LEFT, -2, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader(hostPlayer, "SERVER LOAD: {}\nSERVER LOAD AVERAGE: {}\nSERVER LOAD PEAK: {}\n".format(getServerLoad(), getAverageServerLoad(), getPeakServerLoad()), HudPosition.LEFT, -1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader(hostPlayer, "CURRENT TIME: {}".format(CurrentTime), HudPosition.LEFT, -1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
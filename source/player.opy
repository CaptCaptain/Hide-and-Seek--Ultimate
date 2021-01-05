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

subroutine StartThirdPersonCamera
subroutine StartCamera
subroutine RestrictAbilities

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
    hudText(eventPlayer, "{} {}".format(abilityIconString(eventPlayer.getCurrentHero(), Button.ULTIMATE) if eventPlayer.getTeam() == Team.1 else abilityIconString(eventPlayer.getCurrentHero(), Button.PRIMARY_FIRE), "HIDER" if eventPlayer.getTeam() == Team.1 else "SEEKER"), "PHASE: {}".format(CurrentGameState), "{}:{}".format(floor(((CurrentTime % 86400) % 3600) / 60), floor(((CurrentTime % 86400) % 3600) % 60)) if CurrentTime > 60 else "{}".format(CurrentTime), HudPosition.TOP, 1, Color.BLUE if eventPlayer.getTeam() == Team.1 else Color.RED, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)
    eventPlayer.Hud_Player.append(getLastCreatedText())

    # Camera Hud Instructions
    if WS_SET_3RD_CAM == ACCESSIBILITY.3RD_CAMERA_TOGGLE:
        hudSubtext(eventPlayer, "Press {} to toggle third person camera".format(buttonString(Button.RELOAD)), HudPosition.TOP, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
        eventPlayer.Hud_Player.append(getLastCreatedText())
    if WS_SET_LAYING_DOWN == true and eventPlayer.getTeam() == Team.1:
        hudSubtext(eventPlayer, "Emote and press {} to lay down / Press {} to stand up".format(buttonString(Button.CROUCH), buttonString(Button.JUMP)), HudPosition.TOP, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
        eventPlayer.Hud_Player.append(getLastCreatedText())

rule "Title Hud":
    createInWorldText(getAllPlayers(), "HIDE & SEEK", getObjectivePosition(getCurrentObjective()) + vect(0, 4, 0),5, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION, Color.BLUE, SpecVisibility.NEVER)
    Hud_GameTitle.append(getLastCreatedText())
    createInWorldText(getAllPlayers(), "ULTIMATE", getObjectivePosition(getCurrentObjective()) + vect(0, 3.5, 0),2, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION, Color.SKY_BLUE, SpecVisibility.NEVER)
    Hud_GameTitle.append(getLastCreatedText())
    createInWorldText(getAllPlayers(), "STYLE: {}".format(WS_SET_MODE), getObjectivePosition(getCurrentObjective()) + vect(0, 3, 0),1, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION, Color.ROSE, SpecVisibility.NEVER)
    Hud_GameTitle.append(getLastCreatedText())
    createInWorldText(getAllPlayers(), "WAITING FOR PLAYERS".format(RequiredHiders), getObjectivePosition(getCurrentObjective()) + vect(0, 2.25, 0),1, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION, Color.WHITE, SpecVisibility.NEVER)
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

    hudSubheader(getAllPlayers(), "Current Version: {}\n".format(CURRENT_VERSION), HudPosition.RIGHT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubheader(getAllPlayers(), "For Latest Version, head to: https://workshop.codes/hide-and-seek-ult", HudPosition.RIGHT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubtext(getAllPlayers(), "{} Hide & Seek: Ultimate by CaptCaptain#11421".format(abilityIconString(random.choice(getAllHeroes()), Button.ULTIMATE)), HudPosition.RIGHT, 0, Color.SKY_BLUE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudHeader(getAllPlayers(), "{} RULESET:".format(abilityIconString(Hero.TORBJORN, Button.ABILITY_2)), HudPosition.LEFT, 1, Color.ROSE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    if WS_SET_ADV_USEPRERELEASE:
        hudSubtext(getAllPlayers(), "USE PRE-RELEASE UPDATE: {}".format(WS_SET_ADV_USEPRERELEASE), HudPosition.LEFT, 1.1, Color.ROSE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
        Hud_GameInfo.append(getLastCreatedText())

    hudSubtext(getAllPlayers(), "STYLE: {}".format(WS_SET_MODE), HudPosition.LEFT, 2, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubtext(getAllPlayers(), "FIRST TEAM TO: {} WIN(S)".format(WS_SET_ADV_WINS), HudPosition.LEFT, 3, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubtext(getAllPlayers(), "SEEK TIME: {}:{}".format(floor(((WS_SET_SEEKTIME % 86400) % 3600) / 60), floor(((WS_SET_SEEKTIME % 86400) % 3600) % 60)), HudPosition.LEFT, 4, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubtext(getAllPlayers(), "HIDING TIME: {}:{}".format(floor(((WS_SET_HIDETIME % 86400) % 3600) / 60), floor(((WS_SET_HIDETIME % 86400) % 3600) % 60)), HudPosition.LEFT, 4, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubtext(getAllPlayers(), "PLAYER SIZE: {}x".format(WS_SET_ADV_SCALE), HudPosition.LEFT, 4, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubtext(getAllPlayers(), "PLAYER SPEED: {}x".format(WS_SET_ADV_BASESPEED), HudPosition.LEFT, 4, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    if WS_SET_SEEKER_OUTLINES != ACCESSIBILITY.SEEKER_OUTLINES_DEFAULT:
        hudSubtext(getAllPlayers(), "SEEKER OUTLINES: {}".format(WS_SET_SEEKER_OUTLINES), HudPosition.LEFT, 4, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
        Hud_GameInfo.append(getLastCreatedText())

    hudSubtext(getAllPlayers(), "HIDER OUTLINES: {}".format("on" if WS_SET_USEOUTLINE else "off"), HudPosition.LEFT, 4, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    if WS_SET_SEEKER_ASSIST:
        hudSubtext(getAllPlayers(), "SEEKER ASSISTANCE: {}".format(WS_SET_SEEKER_ASSIST), HudPosition.LEFT, 4.1, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
        Hud_GameInfo.append(getLastCreatedText())
    
    hudSubtext(getAllPlayers(), "HIDER TANK SCALING: {}".format("automatic" if WS_SET_ADV_TANKSCALING == ACCESSIBILITY.TANKS_SCALE else "on" if WS_SET_ADV_TANKSCALING == ACCESSIBILITY.TANKS_SCALE_ALL else "off"), HudPosition.LEFT, 5, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubtext(getAllPlayers(), "SLOW HIDERS WHEN IN LOS OF SEEKER: {}".format(WS_SET_SLOWHIDER), HudPosition.LEFT, 5, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    if WS_SET_LAYING_DOWN:
        hudSubtext(getAllPlayers(), "ALLOW HIDERS TO LAY DOWN: {}".format("On" if WS_SET_LAYING_DOWN else "Off"), HudPosition.LEFT, 5, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
        Hud_GameInfo.append(getLastCreatedText())

    if WS_SET_SHOW_HIDERS != SHOW_HIDERS.OFF:
        hudSubtext(getAllPlayers(), "SHOW REMAINING HIDERS AFTER ROUND: {}".format(WS_SET_SHOW_HIDERS), HudPosition.LEFT, 5, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
        Hud_GameInfo.append(getLastCreatedText())
    
    if WS_SET_ADV_SEEK_ALLOWH == true:
        hudSubtext(getAllPlayers(), "RESTRICT SEEKER HERO ROSTER: {}".format(not(WS_SET_ADV_SEEK_ALLOWH)), HudPosition.LEFT, 5, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
        Hud_GameInfo.append(getLastCreatedText())

    hudSubheader(getAllPlayers(), "TO CUSTOMIZE RULESET (HOST ONLY):\nGO TO LOBBY > SETTINGS > WORKSHOP SETTINGS", HudPosition.LEFT, 6, Color.TURQUOISE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubheader(getAllPlayers(), "FOR MORE INFORMATION ON RULESET:\nGO TO LOBBY > RIGHT CLICK MAP PICTURE > SCROLL DOWN TO WORKSHOP\n", HudPosition.LEFT, 7, Color.TURQUOISE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    if WS_SET_ADV_WINS > 1:
        hudText(getAllPlayers(), "TEAM SCORE:", "", "HIDERS: {}\nSEEKERS: {}".format(HiderTeamScore, SeekerTeamScore), HudPosition.LEFT, 8, Color.TEAM_1, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
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
    smallMessage(eventPlayer, "BE CAREFUL!")

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
    eventPlayer.startCamera(raycast(eventPlayer.getPosition(), eventPlayer.getPosition() + (Vector.UP * 10) + vect(0.001, 0, 0), null, eventPlayer, false).getHitPosition(), eventPlayer.getPosition(), 10)

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

rule "Show Debug Stats":
    @Condition WS_SET_ADV_DEBUGSTATS != SHOW_DEBUG_STATS.NONE

    hudSubtext(hostPlayer if WS_SET_ADV_DEBUGSTATS == SHOW_DEBUG_STATS.HOST else getAllPlayers(), "DEBUG STATS".format(getServerLoad(), getAverageServerLoad(), getPeakServerLoad()), HudPosition.LEFT, -2, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader(hostPlayer if WS_SET_ADV_DEBUGSTATS == SHOW_DEBUG_STATS.HOST else getAllPlayers(), "SERVER LOAD: {}\nSERVER LOAD AVERAGE: {}\nSERVER LOAD PEAK: {}\n".format(getServerLoad(), getAverageServerLoad(), getPeakServerLoad()), HudPosition.LEFT, -1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader(hostPlayer if WS_SET_ADV_DEBUGSTATS == SHOW_DEBUG_STATS.HOST else getAllPlayers(), "CURRENT TIME: {}".format(CurrentTime), HudPosition.LEFT, -1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)

#!include "hider.opy"
#!include "seeker.opy"
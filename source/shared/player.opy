#!mainFile "settings.opy"

enum CAMERA_STATE:
    FIRST_PERSON,
    LAYING_DOWN,
    THIRD_PERSON,
    LAST_HIDER

globalvar globalHudIndex = 0
playervar playerHudIndex = 0
playervar playerIndex = 0

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
playervar SlingshotPosition
playervar SlingshotEnabled = false
playervar SlingshotUsed = false
playervar Hud_Slingshot = []
playervar PreviousPosition

#!define GetSlingshotPosition() updateEveryTick(raycast(raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + (eventPlayer.getFacingDirection() * 15), null, eventPlayer, false).getHitPosition() + Vector.UP, raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + (eventPlayer.getFacingDirection() * 15), null, eventPlayer, false).getHitPosition() + (Vector.DOWN * 100), null, eventPlayer, false).getHitPosition())

subroutine StartThirdPersonCamera
subroutine StartCamera
subroutine SlingshotCooldown
subroutine RestrictAbilities

def SlingshotCooldown():
    eventPlayer.SlingshotUsed = true
    waitUntil(eventPlayer.isOnGround(), 9999)
    wait(8 if CurrentGameState == GAME_STATE.SEEKING else 0)
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
    hudText(eventPlayer, "{} {}".format(abilityIconString(eventPlayer.getCurrentHero(), Button.ULTIMATE) if eventPlayer.getTeam() == Team.1 else abilityIconString(eventPlayer.getCurrentHero(), Button.PRIMARY_FIRE), "HIDER" if eventPlayer.getTeam() == Team.1 else "SEEKER"), "PHASE: {}".format(CurrentGameState), "{}:{}".format(floor(((CurrentTime % 86400) % 3600) / 60), floor(((CurrentTime % 86400) % 3600) % 60)) if CurrentTime > 60 else "{}".format(CurrentTime), HudPosition.TOP, 1, Color.BLUE if eventPlayer.getTeam() == Team.1 else Color.RED, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)
    eventPlayer.Hud_Player.append(getLastCreatedText())

    # Slingshot Instructions
    if WS_SET_USE_SLINGSHOT == true:
        hudSubheader(eventPlayer, "Press {} to toggle slingshot tool / Press {} to confirm".format(buttonString(Button.INTERACT), buttonString(Button.PRIMARY_FIRE)), HudPosition.TOP, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
        eventPlayer.Hud_Player.append(getLastCreatedText())
    # Camera Hud Instructions
    if WS_SET_3RD_CAM == ACCESSIBILITY.3RD_CAMERA_TOGGLE:
        hudSubheader(eventPlayer, "Press {} to toggle third person camera".format(buttonString(Button.RELOAD)), HudPosition.TOP, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
        eventPlayer.Hud_Player.append(getLastCreatedText())
    # Laying down Instructions
    if WS_SET_LAYING_DOWN == true and eventPlayer.getTeam() == Team.1:
        hudSubheader(eventPlayer, "Emote and press {} to lay down / Press {} to stand up".format(buttonString(Button.CROUCH), buttonString(Button.JUMP)), HudPosition.TOP, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
        eventPlayer.Hud_Player.append(getLastCreatedText())

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

    hudSubtext(getAllPlayers(), "GAMEMODE: {}".format(getCurrentGamemode()), HudPosition.LEFT, 1.1, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
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
    
    if WS_SET_ADV_TANKSCALING != ACCESSIBILITY.TANKS_NOSCALE:
        hudSubtext(getAllPlayers(), "HIDER TANK SCALING: {}".format("automatic" if WS_SET_ADV_TANKSCALING == ACCESSIBILITY.TANKS_SCALE else "on" if WS_SET_ADV_TANKSCALING == ACCESSIBILITY.TANKS_SCALE_ALL else "off"), HudPosition.LEFT, 5, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
        Hud_GameInfo.append(getLastCreatedText())

    if WS_SET_USE_SLINGSHOT:
        hudSubtext(getAllPlayers(), "ALLOW SLINGSHOT TOOL: {}".format(WS_SET_USE_SLINGSHOT), HudPosition.LEFT, 5, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
        Hud_GameInfo.append(getLastCreatedText())
    
    if WS_SET_SLOWHIDER == true:
        hudSubtext(getAllPlayers(), "SLOW HIDERS WHEN IN LOS OF SEEKER: {}".format(WS_SET_SLOWHIDER), HudPosition.LEFT, 5, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
        Hud_GameInfo.append(getLastCreatedText())

    if WS_SET_LAYING_DOWN:
        hudSubtext(getAllPlayers(), "ALLOW HIDERS TO LAY DOWN: {}".format("On" if WS_SET_LAYING_DOWN else "Off"), HudPosition.LEFT, 5, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
        Hud_GameInfo.append(getLastCreatedText())

    if WS_SET_SHOW_HIDERS != SHOW_HIDERS.OFF:
        hudSubtext(getAllPlayers(), "SHOW REMAINING HIDERS AFTER ROUND: {}".format(WS_SET_SHOW_HIDERS), HudPosition.LEFT, 5.1, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
        Hud_GameInfo.append(getLastCreatedText())

    if WS_SET_ADV_INF_HAMMOND_GRAPPLE == true:
        hudSubtext(getAllPlayers(), "WRECKING HIDER INFINITE GRAPPLE: {}".format(WS_SET_ADV_INF_HAMMOND_GRAPPLE), HudPosition.LEFT, 5, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
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

rule "Player Setup":
    @Event eachPlayer

    eventPlayer.disableGamemodeHud()
    eventPlayer.disableRespawn()
    eventPlayer.setMoveSpeed(eventPlayer.BaseMoveSpeed)
    eventPlayer.setJumpVerticalSpeed(eventPlayer.BaseJumpHeight)
    
    # Glitch Mode
    if WS_SET_MODE == STYLE.GLITCH:
        eventPlayer.disableEnvironmentCollision(false)

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
    eventPlayer.teleport(eventPlayer.LastWalkablePosition if eventPlayer.LastWalkablePosition != null else nearestWalkablePosition(eventPlayer.getPosition()))
    eventPlayer.setStatusEffect(null, Status.STUNNED, 2)
    if attacker() == victim(): eventPlayer.setStatusEffect(null, Status.INVINCIBLE, 1)
    smallMessage(eventPlayer, "BE CAREFUL!")

rule "Set Last Walkable Position":
    @Event eachPlayer
    @Condition eventPlayer.isMoving() and eventPlayer.isOnGround()

    eventPlayer.LastWalkablePosition = nearestWalkablePosition(eventPlayer.getPosition())

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
        smallMessage(eventPlayer, "CANNOT USE SLINGSHOT WHILE IN LOS OF SEEKERS")
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
        smallMessage(eventPlayer, "SLINGSHOT IS ON COOLDOWN")
        return
    elif eventPlayer.isInAir():
        smallMessage(eventPlayer, "SLINGSHOT CANNOT BE USED WHILE IN THE AIR")
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
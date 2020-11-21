#!mainFile "settings.opy"

globalvar Hud_GameInfo
globalvar globalHudIndex = 0
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

    if WORKSHOP_SET_ADV_USEPRERELEASE:
        hudSubtext(getAllPlayers(), "USE PRE-RELEASE UPDATE: {}".format(WORKSHOP_SET_ADV_USEPRERELEASE), HudPosition.LEFT, 1.1, Color.ROSE, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR, SpecVisibility.DEFAULT)
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

    hudSubheader(getAllPlayers(), "TO CUSTOMIZE RULESET (HOST ONLY):\nGO TO LOBBY > SETTINGS > WORKSHOP SETTINGS\nFOR MORE INFORMATION ON RULESET:\nGO TO LOBBY > RIGHT CLICK MAP PICTURE > SCROLL DOWN TO WORKSHOP", HudPosition.LEFT, 5, Color.TURQUOISE, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

rule "Remove Global Huds":
    @Condition CurrentGameState == GAME_STATE.SEEKING
    for globalHudIndex in range(len(Hud_GameInfo)):
        destroyHudText(Hud_GameInfo[globalHudIndex])
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
    eventPlayer.setMoveSpeed(eventPlayer.BaseMoveSpeed)
    eventPlayer.setJumpVerticalSpeed(eventPlayer.BaseJumpHeight)

rule "Reset Ammo":
    @Event eachPlayer
    @Condition not eventPlayer.isFiringPrimaryFire() and not eventPlayer.isFiringSecondaryFire()
    @Condition eventPlayer.getAmmo(0) > 0

    # Reset ammo when player has not fired for more than a second
    wait(1, Wait.ABORT_WHEN_FALSE)
    eventPlayer.setAmmo(0, eventPlayer.getMaxAmmo(0))

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



#!include "hider.opy"
#!include "seeker.opy"
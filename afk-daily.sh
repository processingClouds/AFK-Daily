#!/system/bin/sh

# --- Variables --- #
# Probably you don't need to modify this. Do it if you know what you're doing, I won't blame you (unless you blame me).
DEVICEWIDTH=1080
pvpEvent=false

# Do not modify
RGB=00000000
if [ $# -gt 0 ]; then
    SCREENSHOTLOCATION="/$1/scripts/afk-arena/screen.dump"
    source /$1/scripts/afk-arena/config.sh
else
    SCREENSHOTLOCATION="/storage/emulated/0/scripts/afk-arena/screen.dump"
    source /storage/emulated/0/scripts/afk-arena/config.sh
fi

# --- Functions --- #
# Test function: change apps, take screenshot, get rgb, change apps, exit. Params: X, Y, amountTimes, waitTime
function test() {
    #startApp
    #switchApp
    local COUNT=0
    until [ "$COUNT" -ge "$3" ]; do
        sleep $4
        getColor "$1" "$2"
        echo "RGB: $RGB"
        ((COUNT = COUNT + 1)) # Increment
    done
    #switchApp
    exit
}

# Default wait time for actions
function wait() {
    sleep 1
}

# Starts the app
function startApp() {
    monkey -p com.lilithgame.hgame.gp 1 >/dev/null 2>/dev/null
    sleep 1
    disableOrientation
}

# Closes the app
function closeApp() {
    am force-stop com.lilithgame.hgame.gp >/dev/null 2>/dev/null
}

# Switches between last app
function switchApp() {
    input keyevent KEYCODE_APP_SWITCH
    input keyevent KEYCODE_APP_SWITCH
}

# Disables automatic orientation
function disableOrientation() {
    content insert --uri content://settings/system --bind name:s:accelerometer_rotation --bind value:i:0
}

# Takes a screenshot and saves it
function takeScreenshot() {
    screencap "$SCREENSHOTLOCATION"
}

# Gets pixel color. Params: X, Y
function readRGB() {
    let offset="$DEVICEWIDTH"*"$2"+"$1"+3
    RGB=$(dd if="$SCREENSHOTLOCATION" bs=4 skip="$offset" count=1 2>/dev/null | hexdump -C)
    RGB=${RGB:9:9}
    RGB="${RGB// /}"
    # echo "RGB: $RGB"
}

# Sets RGB. Params: X, Y
function getColor() {
    takeScreenshot
    readRGB "$1" "$2"
}

# Verifies if X and Y have specific RGB. Params: X, Y, RGB, MessageSuccess, MessageFailure
function verifyRGB() {
    getColor "$1" "$2"
    if [ "$RGB" != "$3" ]; then
        echo "VerifyRGB: Failure! Expected "$3", but got "$RGB" instead."
        echo ""
        echo "$5"
        # switchApp
        exit
    else
        echo "$4"
    fi
}

# Switches to another tab. Params: Tab name
function switchTab() {
    case "$1" in
    "Campaign")
        input tap 550 1850
        wait
        verifyRGB 450 1775 cc9261 "Successfully switched to the Campaign Tab."
        ;;
    "Dark Forest")
        input tap 300 1850
        wait
        verifyRGB 240 1775 d49a61 "Successfully switched to the Dark Forest Tab."
        ;;
    "Ranhorn")
        input tap 110 1850
        wait
        verifyRGB 20 1775 d49a61 "Successfully switched to the Rahorn Tab."
        ;;
    *)
        echo "Failed to switch to another Tab."
        exit
        ;;
    esac
}

# Checks for a battle to finish. Params: Seconds, X, Y, RGB
function loopUntilRGB() {
    sleep "$1"
    getColor $2 $3
    while [ "$RGB" != "$4" ]; do
        sleep 1
        getColor $2 $3
    done
    # while [ "$RGB" != "ca9c5d" ]; do
    #     sleep 1
    #     getColor 420 380
    # done
}

# Repeat a battle for as long as totalAmountArenaTries
function quickBattleGuildBosses() {
    local COUNT=0
    until [ "$COUNT" -ge "$totalAmountGuildBossTries" ]; do
        input tap 710 1840
        wait
        input tap 720 1300
        sleep 1
        input tap 550 800
        input tap 550 800
        sleep 1
        ((COUNT = COUNT + 1)) # Increment
    done
}

# Loots afk chest
function lootAfkChest() {
    input tap 550 1500
    sleep 1
    input tap 750 1350
    sleep 1

    wait
    verifyRGB 450 1775 cc9261 "AFK Chest looted."
}

# Challenges a boss in the campaign
function challengeBoss() {
    input tap 550 1650
    sleep 1

    # Check if boss
    getColor 550 740
    if [ "$RGB" = "f1d79f" ]; then
        input tap 550 1450
    fi

    sleep 2
    input tap 550 1850
    sleep 1
    input tap 80 1460
    wait
    input tap 230 960

    wait
    verifyRGB 450 1775 cc9261 "Challenged boss in campaign."
}

# Collects fast rewards
function fastRewards() {
    input tap 950 1660
    wait
    input tap 710 1260
    sleep 1
    input tap 560 1800
    wait
    input tap 400 1250

    wait
    verifyRGB 450 1775 cc9261 "Fast Rewards collected."
}

# Collects and sends companion points, as well as auto lending mercenaries
function collectFriendsAndMercenaries() {
    input tap 970 810
    sleep 1
    input tap 930 1600
    wait
    input tap 720 1760
    wait
    input tap 990 190
    wait
    input tap 630 1590
    wait
    input tap 750 1410
    sleep 1
    input tap 70 1810
    input tap 70 1810

    # TODO: Check if its necessary to send mercenaries

    wait
    verifyRGB 450 1775 cc9261 "Sent and recieved companion points, as well as auto lending mercenaries."
}

# Starts Solo bounties
function soloBounties() {
    input tap 600 1320
    sleep 1

    # Check if there are bounties to collect
    getColor 660 555
    until [ "$RGB" != "81fff7" ]; do
        input tap 915 470
        sleep 1
        getColor 660 555
    done

    input tap 915 470
    wait
    input tap 350 1160
    input tap 750 1160
    input tap 915 680
    wait
    input tap 350 1160
    input tap 750 1160
    input tap 915 890
    wait
    input tap 350 1160
    input tap 750 1160
    input tap 915 1100
    wait
    input tap 350 1160
    input tap 750 1160
    input tap 915 1310
    wait
    input tap 350 1160
    input tap 750 1160
    input swipe 550 1100 550 800 500
    wait
    input tap 915 960
    wait
    input tap 350 1160
    input tap 750 1160
    input tap 915 1170
    wait
    input tap 350 1160
    input tap 750 1160
    input tap 915 1380
    wait
    input tap 350 1160
    input tap 750 1160

    wait
    verifyRGB 650 1740 a7541a "Successfully finished Solo Bounties."
}

# Starts Team Bounties
function teamBounties() {
    ## For testing only! Keep as comment ##
    # input tap 600 1320
    # sleep 1
    ## End of testing ##
    input tap 910 1770
    wait

    # Check if there are bounties to collect
    getColor 650 570
    until [ "$RGB" != "84fff8" ]; do
        input tap 930 550
        sleep 1
        getColor 650 570
    done

    input tap 930 550
    wait
    input tap 350 1160
    input tap 750 1160
    wait
    input tap 930 770
    wait
    input tap 350 1160
    input tap 750 1160
    wait
    input tap 70 1810

    wait
    verifyRGB 240 1775 d49a61 "Successfully finished Team Bounties."
}

# Does the daily arena of heroes battles
function arenaOfHeroes() {
    input tap 740 1050
    sleep 1
    if [ "$pvpEvent" == false ]; then
        input tap 550 450
    else
        input tap 550 900
    fi
    sleep 1
    input tap 1000 1800
    input tap 980 410
    wait
    input tap 540 1800
    sleep 1

    # Repeat a battle for as long as totalAmountArenaTries
    local COUNT=0
    until [ "$COUNT" -ge "$totalAmountArenaTries" ]; do
        input tap 820 1400
        sleep 1
        input tap 550 1850
        loopUntilRGB 2 750 694 d4a248
        input tap 550 1550
        wait
        input tap 550 1550
        sleep 1
        ((COUNT = COUNT + 1)) # Increment
    done

    input tap 1000 380
    wait
    input tap 70 1810

    sleep 1
    verifyRGB 850 130 3c2814 "Successfully battled at the Arena of Heroes."
}

# Does the daily Legends tournament battles
function legendsTournament() {
    ## For testing only! Keep as comment ##
    # input tap 740 1050
    # sleep 1
    ## End of testing ##
    if [ "$pvpEvent" == false ]; then
        input tap 550 900
    else
        input tap 550 1450
    fi
    sleep 1
    input tap 550 280
    sleep 2
    input tap 550 1550
    sleep 1
    input tap 1000 1800
    input tap 990 380
    wait

    # Repeat a battle for as long as totalAmountArenaTries
    local COUNT=0
    until [ "$COUNT" -ge "$totalAmountArenaTries-2" ]; do
        input tap 550 1840
        sleep 1
        input tap 800 1140
        sleep 1
        input tap 670 1110
        sleep 1
        input tap 550 1850
        sleep 2
        input tap 880 1470
        sleep 1
        input tap 550 800
        sleep 1
        ((COUNT = COUNT + 1)) # Increment
    done

    input tap 70 1810
    wait
    input tap 70 1810

    wait
    verifyRGB 240 1775 d49a61 "Successfully battled at the Legends Tournament."
}

# Battles once in the kings tower
function kingsTower() {
    input tap 500 870
    sleep 1
    input tap 550 900
    sleep 1
    input tap 540 1350
    sleep 1
    input tap 550 1850
    sleep 1
    input tap 80 1460
    input tap 230 960
    wait
    input tap 70 1810
    wait
    input tap 70 1810

    wait
    verifyRGB 240 1775 d49a61 "Successfully battled at the Kings Tower."
}

# Battles against Guild boss Wrizz
function guildHunts() {
    input tap 380 360
    sleep 3
    input tap 290 860
    sleep 1

    # TODO: Make sure 2x and Auto are enabled
    # TODO: Have a variable decide if fight wrizz or not
    # Start checking for a finished Battle after 40 seconds
    # loopUntilRGB 85 420 380 ca9c5d
    #wait
    #input tap 550 800
    #input tap 550 800
    #wait

    # Wrizz
    # TODO: Check if possible to fight wrizz
    # Repeat a battle for as long as totalAmountArenaTries
    local COUNT=0
    until [ "$COUNT" -ge "$totalAmountGuildBossTries" ]; do
        # Check if its possible to fight wrizz
        # getColor 710 1840
        # if [ "$RGB" != "9de7bd" ]; then
        #     echo "Enough of wrizz! Going out."
        #     break
        # fi

        input tap 710 1840
        wait
        input tap 720 1300
        sleep 1
        input tap 550 800
        input tap 550 800
        sleep 1
        ((COUNT = COUNT + 1)) # Increment
    done

    # Soren
    input tap 970 890
    sleep 1

    getColor 550 1850

    # If Soren is open
    if [ "$RGB" == "412818" ]; then
        quickBattleGuildBosses

    # If Soren is closed
    else
        getColor 580 1753

        # If soren is "openable" and canOpenSoren == true
        if [ "$RGB" == "fae0ac" ] && [ "$canOpenSoren" == true ]; then
            input tap 550 1850
            wait
            input tap 700 1250
            sleep 1
            quickBattleGuildBosses
        fi
    fi
    input tap 70 1810

    sleep 1
    verifyRGB 70 1000 a9a95f "Successfully battled Wrizz."
}

# Battles against the Twisted Realm Boss
function twistedRealmBoss() {
    # TODO: Choose if 2x or not
    # TODO: Choose a formation (Would be dope!)
    ## For testing only! Keep as comment ##
    # input tap 380 360
    # sleep 3
    ## End of testing ##
    input tap 820 820
    sleep 1
    input tap 550 1850
    sleep 1
    input tap 550 1850

    # Start checking for a finished Battle after 40 seconds
    loopUntilRGB 30 420 380 ca9c5d

    sleep 1
    input tap 550 800
    sleep 3
    input tap 550 800
    wait

    # TODO: Repeat battle if variable says so

    input tap 70 1810
    wait
    input tap 70 1810

    sleep 1
    verifyRGB 20 1775 d49a61 "Successfully battled Twisted Realm Boss."
}

# Buys daily dust from ths store
function storeBuyDust() {
    input tap 330 1650
    sleep 1
    input tap 170 840
    wait
    input tap 550 1540
    sleep 1
    input tap 550 1220
    wait
    input tap 70 1810

    wait
    verifyRGB 20 1775 d49a61 "Successfully bought daily Dust from the store."
}

# Collects
function collectQuestChests() {
    input tap 960 250
    wait

    # Collect Quests
    getColor 700 670
    while [ "$RGB" == "82fdf5" ]; do
        input tap 930 680
        wait
        getColor 700 670
    done

    input tap 330 430
    wait
    input tap 580 600
    input tap 500 430
    wait
    input tap 580 600
    input tap 660 430
    wait
    input tap 580 600
    input tap 830 430
    wait
    input tap 580 600
    input tap 990 430
    wait
    input tap 580 600
    wait
    input tap 70 1650

    sleep 1
    verifyRGB 20 1775 d49a61 "Successfully collected daily Quest chests."
}

# Collects mail
collectMail() {
    input tap 960 630
    wait
    input tap 790 1470
    wait
    input tap 110 1850
    wait
    input tap 110 1850

    wait
    verifyRGB 20 1775 d49a61 "Successfully collected Mail."
}

# Says Hi to Soren
function visitSoren() {
    switchTab "Ranhorn"
    input tap 380 360
    sleep 3
    input tap 290 860
    sleep 1
    input tap 970 890

    wait
    echo
    verifyRGB 540 1220 aa42d0 "Go back to the game to say Hi to Soren!" "Somehow I didn't manage to say Hi to Soren... Guess he got scared."
}

# TODO: Make it pretty
# RED='\033[0;34m'
# NC='\033[0m' # No Color
# printf "I ${RED}love${NC} Stack Overflow\n"

# Test function (X, Y, amountTimes, waitTime)
# test 750 694 3 0.5
# test 660 555 3 0.5 # Check for Solo Bounties RGB
# test 650 570 3 0.5 # Check for Team Bounties RGB
# test 700 670 3 0.5 # Check for chest collection RGB

# --- Script Start --- #
echo "Starting script..."
echo
closeApp
sleep 0.5
startApp
sleep 10

# Loops until the game has launched
while [ "$RGB" != "cc9261" ]; do
    sleep 1
    getColor 450 1775
done
sleep 1

input tap 970 380 # Open menu for friends, etc

switchTab "Campaign"
sleep 3
switchTab "Dark Forest"
sleep 1
switchTab "Ranhorn"
sleep 1

# CAMPAIGN TAB
switchTab "Campaign"
lootAfkChest
challengeBoss
fastRewards
collectFriendsAndMercenaries
lootAfkChest

# DARK FOREST TAB
switchTab "Dark Forest"
soloBounties
teamBounties
arenaOfHeroes
legendsTournament
kingsTower

# RANHORN TAB
switchTab "Ranhorn"
guildHunts
twistedRealmBoss
storeBuyDust # TODO: Buy other stuff as well
collectQuestChests
collectMail

# EXTRA
if [ "$endAtSoren" == true ]; then # TODO: Visit Oak inn instead (probably depends on user level)
    visitSoren
fi

echo
echo "End of script!"
exit

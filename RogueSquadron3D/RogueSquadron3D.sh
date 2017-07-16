#!/bin/bash
# Date : (2014-09-18 00:12)
# Last revision : (2017-06-27 18:02)
# Wine version used : 1.7.28
# Distribution used to test : Linux Mint 18.1 x64
# Author : med_freeman, updated by jacen05
# Licence : Retail
 
[ "$PLAYONLINUX" = "" ] && exit 0
source "$PLAYONLINUX/lib/sources"
 
TITLE="Star Wars : Rogue Squadron 3D"
PREFIX="RogueSquadron3D"
EDITOR="LucasArts / Factor 5"
GAME_URL="http://www.starwars.com/games-apps"
WINE_VERSION="1.7.28"
WINE_ARCH="x86"
AUTHOR="med_freeman"
 
POL_GetSetupImages "http://files.playonlinux.com/resources/setups/$PREFIX/top.jpg" "http://files.playonlinux.com/resources/setups/$PREFIX/left.jpg" "$TITLE"
POL_SetupWindow_Init
POL_SetupWindow_SetID 2293
 
POL_Debug_Init
 
POL_SetupWindow_presentation "$TITLE" "$EDITOR" "$GAME_URL" "$AUTHOR" "$PREFIX"

device=$(blkid | grep 'ROGUE' | cut -d ':' -f 1)
if [[ -e "$device" ]]; then
	# RS3D ISO is currently mounted
	POL_Debug_Message "ISO file mounted as device $device"
	CDROM=$(df | grep "$device" | tr -s ' ' | cut -d ' ' -f 6)
        POL_Debug_Message "ISO file is mounted at path $CDROM"
else
	# Ask user where the cdrom is mounted
        POL_SetupWindow_cdrom
        POL_SetupWindow_check_cdrom "rogue"
fi

# Ask user to enable 16 bit support on newer kernels (3.14~) if not enabled
_16BIT="$(cat /proc/sys/abi/ldt16)"
if [ $? -eq 0 ] && [ "$_16BIT" = "0" ]; then
	    POL_Call POL_Function_RootCommand "sudo sysctl -w abi.ldt16=1; exit"
fi

POL_System_SetArch "$WINE_ARCH"
POL_System_TmpCreate "$PREFIX"
POL_Wine_SelectPrefix "$PREFIX"
POL_Wine_PrefixCreate "$WINE_VERSION"
     
POL_Wine_WaitBefore "$TITLE"
POL_Wine start /unix "$CDROM/setup.exe"
POL_Wine_WaitExit "$TITLE"
     
# Update 1.2(1) installation
POL_SetupWindow_message "$TITLE : $(eval_gettext 'Installation of update 1.2')" "$TITLE"
POL_SetupWindow_InstallMethod "DOWNLOAD,LOCAL"
if [ "$INSTALL_METHOD" = "LOCAL" ]; then
	cd "$HOME"
	POL_SetupWindow_browse "$(eval_gettext 'Please select the 1.2 update executable')" "$TITLE"
	UPDATE_EXE="$APP_ANSWER"
elif [ "$INSTALL_METHOD" = "DOWNLOAD" ]; then
	cd "$POL_System_TmpDir"
	UPDATE_EXE="rogueupd12.exe"
	#POL_Download "http://media1.gamefront.com/moddb/2009/03/10/$UPDATE_EXE" "e90984f2e3721fe72e67609aabd6db23"
	POL_Download "https://jacen05.net/owncloud/index.php/s/qS5UXs1WMp5uOkS/download" "e90984f2e3721fe72e67609aabd6db23"
	mv download "$UPDATE_EXE"
fi
POL_Wine_WaitBefore "$TITLE"
POL_Wine start /unix "$UPDATE_EXE"
POL_Wine_WaitExit "$TITLE"

# Dependencies
POL_Call POL_Install_dsound

# Install nGlide wrapper
POL_SetupWindow_message "$TITLE : Installation of nGlide 102" "$TITLE"
POL_SetupWindow_InstallMethod "DOWNLOAD,LOCAL"
if [ "$INSTALL_METHOD" = "LOCAL" ]; then
	cd "$HOME"
	POL_SetupWindow_browse 'Please select the nGlide installer' "$TITLE"
	NGLIDE_EXE="$APP_ANSWER"
elif [ "$INSTALL_METHOD" = "DOWNLOAD" ]; then
	cd "$POL_System_TmpDir"
	NGLIDE_EXE="nGlide102_setup.exe"
	#POL_Download "http://www.zeus-software.com/files/nglide/$NGLIDE_EXE" "3753dd73587af332ad72e7fb73545ab1"
	POL_Download "https://jacen05.net/owncloud/index.php/s/toctcym0tuPwpBv/download" "3753dd73587af332ad72e7fb73545ab1"
	mv download "$NGLIDE_EXE"
fi
POL_Wine_WaitBefore "$TITLE"
POL_Wine start /unix "$NGLIDE_EXE"
POL_Wine_WaitExit "$TITLE"

# Set glide renderer
regfile="$POL_System_TmpDir/rs3d_glide.reg"
cat <<_EOFREG_ >> "$regfile"
[HKEY_LOCAL_MACHINE\\Software\\LucasArts Entertainment Company LLC\\Rogue Squadron\\v1.0]
"3DSetup"="TRUE"
"VDEVICE"="Voodoo (Glide)"
_EOFREG_
regedit $regfile
rm -f $regfile

# Joystick fix
Set_OS "win98"

# Shortcuts
SHORTCUT="Rogue Squadron 3D"
POL_Shortcut "Rogue Squadron.exe" "$SHORTCUT"
POL_Shortcut "nglide_config.exe" "$SHORTCUT - Graphic settings"
			     
POL_System_TmpDelete
POL_SetupWindow_Close
exit 0

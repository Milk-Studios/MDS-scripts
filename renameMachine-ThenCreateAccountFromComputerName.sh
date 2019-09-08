#!/bin/bash

# This script renames the computer according to user input in imagr when running MDS
# NOTE: This script needs mds_var1 to work
# Spaces in the computer name will be replaced with underscores
# Caps in the computer name will be replaced with 
# It will also create a user account matching the machine name

HOMEFOLDERNAME=$( echo "$mds_var1"  | tr '[:upper:]' '[:lower:]' | tr -s ' ' | tr ' '  '_')
COMPUTERNAME=$( echo "$mds_var1"  | tr '[:lower:]' '[:upper:]' | tr -s ' ' | tr ' '  '-')
REALNAME=$( echo "$mds_var1"  | tr '[:lower:]' '[:upper:]' )
NEXTUID=$(dscl . -list /Users UniqueID | awk 'BEGIN{i=0}{if($2>i)i=$2}END{print i+1}')
OSVER=$(defaults read "/System/Library/CoreServices/SystemVersion" ProductVersion)
BUILDVER=$(defaults read "/System/Library/CoreServices/SystemVersion" ProductBuildVersion)

# Name the machine
/usr/sbin/scutil --set HostName "$COMPUTERNAME"
/usr/sbin/scutil --set LocalHostName "$COMPUTERNAME"
/usr/sbin/scutil --set ComputerName "$COMPUTERNAME"

# Create the user account in the local directory
/usr/bin/dscl . -create /Users/"$HOMEFOLDERNAME"
/usr/bin/dscl . -create /Users/"$HOMEFOLDERNAME" UserShell /bin/bash
/usr/bin/dscl . -create /Users/"$HOMEFOLDERNAME" RealName "$REALNAME"
/usr/bin/dscl . -create /Users/"$HOMEFOLDERNAME" UniqueID "$NEXTUID"
/usr/bin/dscl . -create /Users/"$HOMEFOLDERNAME" PrimaryGroupID 20
/usr/bin/dscl . -create /Users/"$HOMEFOLDERNAME" NFSHomeDirectory /Users/"$HOMEFOLDERNAME"
/usr/bin/dscl . -passwd /Users/"$HOMEFOLDERNAME" milk
/usr/bin/dscl . -append /Groups/admin GroupMembership "$HOMEFOLDERNAME"
/usr/bin/dscl . -create /Users/"$HOMEFOLDERNAME" Picture "/Library/User Pictures/Animals/Penguin.tif"

# Create the users home folder
/usr/sbin/createhomedir -u "$HOMEFOLDERNAME" -c &> /dev/null

# Skip new user Setup Assistant
/usr/bin/touch /Users/"$HOMEFOLDERNAME"/Library/Preferences/com.apple.SetupAssistant.plist
/usr/sbin/chown -R "$HOMEFOLDERNAME":staff /Users/"$HOMEFOLDERNAME"
/usr/bin/defaults write /Users/"$HOMEFOLDERNAME"/Library/Preferences/com.apple.SetupAssistant.plist DidSeeCloudSetup -bool TRUE
/usr/bin/defaults write /Users/"$HOMEFOLDERNAME"/Library/Preferences/com.apple.SetupAssistant.plist LastSeenCloudProductVersion "$OSVER"
/usr/bin/defaults write /Users/"$HOMEFOLDERNAME"/Library/Preferences/com.apple.SetupAssistant.plist DidSeeCloudSetup -bool TRUE
/usr/bin/defaults write /Users/"$HOMEFOLDERNAME"/Library/Preferences/com.apple.SetupAssistant.plist DidSeeSyncSetup -bool TRUE
/usr/bin/defaults write /Users/"$HOMEFOLDERNAME"/Library/Preferences/com.apple.SetupAssistant.plist DidSeeSyncSetup2 -bool TRUE
/usr/bin/defaults write /Users/"$HOMEFOLDERNAME"/Library/Preferences/com.apple.SetupAssistant.plist LastPreLoginTasksPerformedBuild "$BUILDVER"
/usr/bin/defaults write /Users/"$HOMEFOLDERNAME"/Library/Preferences/com.apple.SetupAssistant.plist LastPreLoginTasksPerformedVersion "$OSVER"
/usr/bin/defaults write /Users/"$HOMEFOLDERNAME"/Library/Preferences/com.apple.SetupAssistant.plist LastSeenBuddyBuildVersion "$BUILDVER"
/usr/bin/defaults write /Users/"$HOMEFOLDERNAME"/Library/Preferences/com.apple.SetupAssistant.plist LastSeenCloudProductVersion "$OSVER"
/usr/bin/defaults write /Users/"$HOMEFOLDERNAME"/Library/Preferences/com.apple.SetupAssistant.plist LastSeenSyncProductVersion "$OSVER"
/usr/bin/defaults write /Users/"$HOMEFOLDERNAME"/Library/Preferences/com.apple.SetupAssistant.plist RunNonInteractive -bool TRUE
/usr/bin/defaults write /Users/"$HOMEFOLDERNAME"/Library/Preferences/com.apple.SetupAssistant.plist ShowKeychainSyncBuddyAtLogin -bool FALSE
/usr/bin/defaults write /Users/"$HOMEFOLDERNAME"/Library/Preferences/com.apple.SetupAssistant.plist SkipFirstLoginOptimization -bool TRUE
/usr/sbin/chown "$HOMEFOLDERNAME":staff /Users/"$HOMEFOLDERNAME"/Library/Preferences/com.apple.SetupAssistant.plist

# Set the machine to login as this user automatically
# Note that the kcpassword file must also be in place for this to work
/usr/bin/defaults write /Library/Preferences/com.apple.loginwindow autoLoginUser "$HOMEFOLDERNAME"
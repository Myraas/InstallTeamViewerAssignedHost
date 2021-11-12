#!/bin/bash

#These variables is the ONLY thing to modify in this script
idc=''
token=''
group=''

#Uninstall TeamViewer
#Terminates TeamViewer app
echo "Stopping TeamViewer"
osascript -e 'quit app "TeamViewer_Host"'
launchctl remove com.teamviewer.Helper

#Deletes configuration files.
echo "Removing TeamViewer configuration files"
rm -f /Library/PrivilegedHelperTools/com.teamviewer.Helper
rm -f /Library/Preferences/com.teamviewer*
rm -f ~/Library/Preferences/com.teamviewer*
rm -f /tmp/choices.xml

#Set working directory to /tmp
current_path=$(pwd)
cd /tmp
cp "${current_path}/choices.xml" .

#Create the choices XML config
echo "Creating choices.xml"
cd /tmp
touch ./choices.xml
OutputXML=./choices.xml

{
	echo "<?xml version="1.0" encoding="UTF-8"?>"
	echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0'
	echo '//EN" "http://www.apple.com/DTDs/PropertyList1.0.dtd">'
	echo '<plist version="1.0">'
	echo "<array>"
	echo " <dict>"
	echo " <key>attributeSetting</key>"
	echo " <integer>1</integer>"
	echo " <key>choiceAttribute</key>"
	echo " <string>selected</string>"
	echo " <key>choiceIdentifier</key>"
	echo " <string>com.teamviewer."
	echo "teamviewerhost14SilentInstaller</string>"
	echo " </dict>"
	echo "</array>"
	echo "</plist>"
} > ${OutputXML}

#Download and Install custom host
echo "Downloading and Installing custom host"
curl -O https://dl.teamviewer.com/download/version_15x/CustomDesign/Install%20TeamViewerHost-idc$idc.pkg
installer -applyChoiceChangesXML choices.xml -pkg Install%20TeamViewerHost-idc$idc.pkg -target /

#This wait is to allow time for the install to finish before running the account assignment 
echo "10 seconds wait before running the account assignment"
sleep 10s

#Assignment
echo "Running the account assignment"

while true; do
    process=$(ps aux | grep TeamViewerHost | grep -v grep | wc -l)
    echo "Process: $process"
    if [ $process -gt 2 ]; then
        echo "Assigning..."
        sleep 15
        /Applications/TeamViewerHost.app/Contents/Helpers/TeamViewer_Assignment -api-token $token -group $group -alias "$(hostname -s)" -grant-easy-access -reassign
        exit $?
    else
        echo "Waiting for TeamViewer to start..."
        sleep 15
    fi
done

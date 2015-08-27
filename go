#!/bin/bash
# Used ot manually build/launch since Garmin's Eclipse stuff fails to do that
# after 3 or 4 builds on my system for some reason.
echo "Building..."
/Library/Java/JavaVirtualMachines/jdk1.8.0_05.jdk/Contents/Home/bin/java -Dfile.encoding=UTF-8 -Dapple.awt.UIElement=true -classpath /Library/Java/JavaVirtualMachines/jdk1.8.0_05.jdk/Contents/Home/lib/tools.jar:/Users/sarahemm/connectiq-sdk/connectiq-sdk-mac-1.1.3/bin/monkeybrains.jar: com.garmin.monkeybrains.Monkeybrains -a /Users/sarahemm/connectiq-sdk/connectiq-sdk-mac-1.1.3/bin/api.db -i /Users/sarahemm/connectiq-sdk/connectiq-sdk-mac-1.1.3/bin/api.debug.xml -o /Users/sarahemm/LimitFace/bin/LimitFace.prg -z /Users/sarahemm/LimitFace/resources/resources.xml:/Users/sarahemm/LimitFace/resources/layouts/layout.xml -m /Users/sarahemm/LimitFace/manifest.xml -u /Users/sarahemm/connectiq-sdk/connectiq-sdk-mac-1.1.3/bin/devices.xml -p /Users/sarahemm/connectiq-sdk/connectiq-sdk-mac-1.1.3/bin/projectInfo.xml /Users/sarahemm/LimitFace/source/LimitFaceView.mc /Users/sarahemm/LimitFace/source/LimitFaceApp.mc -d fenix3_sim
echo "Launching simulator..."
connectiq
sleep 3
echo "Loading app into simulator..."
monkeydo bin/LimitFace.prg fenix3

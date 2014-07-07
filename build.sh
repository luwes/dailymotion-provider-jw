#!/bin/bash
# This is a simple script that compiles the plugin using the free Flex SDK on Linux/Mac.
# Learn more at http://developer.longtailvideo.com/trac/wiki/PluginsCompiling

FLEXPATH=/Developer/SDKs/flex_sdk_3
JWPATH=/Developer/SDKs/fl5-plugin-sdk

echo "Compiling positioning plugin..."
$FLEXPATH/bin/mxmlc ./com/wessite/DailymotionMediaProvider.as \
	-sp ./ -o ./DailymotionMediaProvider/dailymotionprovider.swf \
	-library-path+=$JWPATH/lib \
	-load-externs $JWPATH/lib/jwplayer-5-classes.xml \
	-use-network=false \
	-debug=false
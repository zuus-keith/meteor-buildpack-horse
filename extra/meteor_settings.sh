#!/bin/sh
#
# Meteor settings
#
echo "-----> Adding profile script to set METEOR_SETTING"

curl -o "$APP_CHECKOUT_DIR"/jq -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
chmod +x "$APP_CHECKOUT_DIR"/jq
JQ="$APP_CHECKOUT_DIR/jq"

if [ -z "PRODUCTION" ] ; then
    echo "FATAL: PRODUCTION is not defined, it should be 'true' or 'false'"
    exit 1
else
    PROD=$PRODUCTION
fi

if $PROD ; then
    # Build the production settings
    echo "Production deploy"

    SETTINGS=`$JQ -s '.[0] * .[1]' $APP_CHECKOUT_DIR/server/settings/common.json $APP_CHECKOUT_DIR/server/settings/production.json`
else
    # Build the staging settings
    echo "Staging deploy"
    # For staging we pre-pend "10" to the version number to make it obvious if a device is 
    # connecting to Staging or Production. 
    STAGING_VERSION=10$($JQ '.public.version' $APP_CHECKOUT_DIR/server/settings/common.json | tr -d '"')
    # Merge the common and staging specific settings, and include the staging version no.
    SETTINGS=`$JQ -c --arg VERSION "$STAGING_VERSION" -s '.[0] * .[1] | .public.version |= $VERSION' $APP_CHECKOUT_DIR/server/settings/common.json $APP_CHECKOUT_DIR/server/settings/staging.json`
fi

cat > "$APP_CHECKOUT_DIR"/.profile.d/meteor.sh <<EOF
  #!/bin/bash
    export METEOR_SETTINGS='$SETTINGS'
EOF

#!/usr/bin/env bash

log()  { echo -e "\x1b[1m[\x1b[93mLOG\x1b[0m\x1b[1m]\x1b[0m ${@}";  }
info() { echo -e "\x1b[1m[\x1b[92mINFO\x1b[0m\x1b[1m]\x1b[0m ${@}"; }
warn() { echo -e "\x1b[1m[\x1b[91mWARN\x1b[0m\x1b[1m]\x1b[0m ${@}"; }

VERSION="1.2.0"
PROJECTNAME="webshell"

#=======================================================================================================================

info "Building for Apache Tomcat 10.x and upper"

# Prepare configuration
log "Setting version = '${VERSION}' in build.gradle ..."
sed -i "s/version = .*/version = '${VERSION}'/g" build.gradle

log "Starting build ..."
gradle build

# Distribution
log "Copying final WAR files ..."
if [[ ! -d ./dist/${VERSION}/ ]]; then mkdir -p ./dist/${VERSION}/; fi
if [[ -f ./build/libs/build-${VERSION}.war ]]; then
  info "Saved to ./dist/${VERSION}/${PROJECTNAME}.war"
  cp ./build/libs/build-${VERSION}.war ./dist/${VERSION}/${PROJECTNAME}.war
  chmod 777 ./dist/${VERSION}/${PROJECTNAME}.war
fi

# Cleanup
log "Cleanup build environnement ..."
if [[ -d ./build/ ]]; then
  rm -rf ./build/;
fi

if [[ -d ./.gradle/ ]]; then
  rm -rf ./.gradle/;
fi



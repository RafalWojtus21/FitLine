#!/bin/sh

#  create-empty-configuration-file.sh
#  AcademyMVI
#
#  Created by Bart on 15/11/2021.
#  
CONFIG_EXTENSION_OUTPUT_PATH="${SRCROOT}/Fitmania/Configurations/Configuration.swift"

set -e

if [ ! -f "${CONFIG_EXTENSION_OUTPUT_PATH}" ]
then
touch "${CONFIG_EXTENSION_OUTPUT_PATH}"
fi

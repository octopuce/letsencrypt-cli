#!/bin/bash
# ###########################
# A standard lib for bash
# ###########################
#

# For source detection
SOURCE_STD=yes

#
# returns 0 if a variable is defined (set)
# returns 1 if a variable is unset
#
function defined {
    [[ ${!1-X} == ${!1-Y} ]]
}

#
# returns 0 if a variable is defined (set) and value's length > 0
# returns 1 otherwise
#
function has_value {
    if defined $1; then
        if [[ -n ${!1} ]]; then
            return 0
        fi
    fi
    return 1
}

#
# returns "" if a binary is not found in PATH 
# returns the binary path string otherwise
#
function bin_path {

    RES=`which "$1" 2>/dev/null`
    # Not found
    [ 0 -ne $? ] && echo ""
    echo $RES

}

#
# Returns 0 if a function exists in the current bash scope
# Returns 1 otherwise
# @param 1 string the function name
#
function is_function {
    local vtype=$( type -t "$1" )
    if [ -n "$vtype" ] && [ "function" = "$vtype" ]; then
        return 0
    fi
    return 1
}

#
# Checks if a variable is set to "y" or "yes".
# Usefull for detecting if a configurable option is set or not.
#
option_enabled () {

    VAR="$1"
    VAR_VALUE=$(eval echo \$$VAR | tr '[a-z]' '[A-Z]')
    if [[ "$VAR_VALUE" == "Y" ]] || [[ "$VAR_VALUE" == "YES" ]]  || [[ "$VAR_VALUE" -eq 1 ]]
    then
        return 0
    else
        return 1
    fi
}

#
# returns 0 if a directory exists
# returns 1 otherwise
#
function directory_exists {
    if [[ -d "$1" ]]; then
        return 0
    fi
    return 1
}

#
# returns 0 if a (regular) file exists
# returns 1 otherwise
#
function file_exists {
    if [[ -f "$1" ]]; then
        return 0
    fi
    return 1
}


#
# returns lowercase string
#
function tolower {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

#
# returns uppercase string
#
function toupper {
    echo "$1" | tr '[:lower:]' '[:upper:]'
}

#
# Only returns the first part of a string, delimited by tabs or spaces
#
function trim {
    echo $1
}

#
# Replace some text inside a string.
#
function str_replace () {
    local ORIG="$1"
    local DEST="$2"
    local DATA="$3"

    echo "$DATA" | sed "s/$ORIG/$DEST/g"
}


#
# Replace string of text in file.
# Uses the ed editor to replace the string.
#
# arg1 = string to be matched
# arg2 = new string that replaces matched string
# arg3 = file to operate on.
#
function str_replace_in_file () {
    local ORIG="$1"
    local DEST="$2"
    local FILE="$3"

    has_value FILE 
    die_if_false $? "Empty argument 'file'"
    file_exists "$FILE"
    die_if_false $? "File does not exist"

    printf ",s/$ORIG/$DEST/g\nw\nQ" | ed -s "$FILE" > /dev/null 2>&1
    return "$?"
}


# To be cleaned as they require the log.sh lib

#
# This function executes a command provided as a parameter
# The function then displays if the command succeeded or not.
#
function cmd {
 
     COMMAND="$1"
     msg "Executing: $COMMAND"
 
     RESULT=`$COMMAND 2>&1`
     ERROR="$?"
 
     MSG="Command: ${COMMAND:0:29}..."
     
     tput cuu1
 
     if [ "$ERROR" == "0" ]
     then
         msg_ok "$MSG"
         if [ "$DEBUG" == "1" ]
         then
             msg "$RESULT"
         fi
     else
         msg_fail "$MSG"
         log "$RESULT"
     fi
 
     return "$ERROR"
 }


#
# Prints an error message ($2) to stderr and exits with the return code ($1).
# The message is also logged.
#
function die {
    local -r err_code="$1"
    local -r err_msg="$2"
    local -r err_caller="${3:-$(caller 0)}"
    
    if is_function msg_fail; then 
        out="msg_fail" 
    else
        out="echo"
    fi
    $out "ERROR: $err_msg"
    $out "ERROR: At line $err_caller"
    $out "ERROR: Error code = $err_code"
    exit "$err_code"
} >&2 # function writes to stderr

 #
 # Check if a return code ($1) indicates an error (i.e. >0) and prints an error
 # message ($2) to stderr and exits with the return code ($1).
 # The error is also logged.
 #
 # Die if error code is false.
 #
 function die_if_false {
     local -r err_code=$1
     local -r err_msg=$2
     local -r err_caller=$(caller 0)

     if [[ "$err_code" != "0" ]]
     then
         die $err_code "$err_msg" "$err_caller"
     fi
 } >&2 # function writes to stderr

 #
 # Dies when error code is true
 #
 function die_if_true {
     local -r err_code=$1
     local -r err_msg=$2
     local -r err_caller=$(caller 0)

     if [[ "$err_code" == "0" ]]
     then
         die $err_code "$err_msg" "$err_caller"
     fi
 } >&2 # function writes to stderr

# 
# Exits if you don't run as root
# 
function run_as_root {

    [ 0 -ne $UID ] && die 1 "You need to run this script as root. Exiting."

}
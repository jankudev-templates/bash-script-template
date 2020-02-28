#!/usr/bin/env bash

# [Introduction HELP]
# For commands help use following commands:
# - man bash
# - man test
# - man getopt
# - man logger
# 
# Try to use and follow this templates structure and the following best
# practice:
# - don't overuse global variables
# - always document your options in printed help, function arguments
# - use logging
# - define exit codes as global variables and use them
# - use $(command) syntax instead of `command` to save output of command into
# variable
# - use if [[ test ]]; then pattern for better readability
# - define script interpreter using #!/usr/bin/env interprete
# - don't overuse chaining of commands using && and ||, just where causality is
# required
# - make the script as simple as possible, split complex work into several
# scripts (read https://en.wikipedia.org/wiki/The_Unix_Programming_Environment)

# [Information about script]
# Summary
#
# Detailed description


# [Global variables]
SCRIPTNAME="${0}"
ARGS=""
TEMP=""


# [Exit statuses]
EXIT_OK=0
EXIT_TEMP_NOTCREATED=1
EXIT_OPTION_UNKNOWN=2


# [Temp and cleanup]
# Create unique temp directory and set TEMP global variable with path
function fn_makeTemp() {
  TEMP=$(mktemp -d)
  if [[ ! -d "${TEMP}" ]]; then
    exit "${EXIT_TEMP_NOTCREATED}"
  fi
}

# Clean temp directory
function fn_cleanupTemp() {
  rm -rf "${TEMP}"
}

# create temporary directory with cleanup on script exit
fn_makeTemp && trap fn_cleanupTemp EXIT
#fn_makeTemp && trap fn_cleanupTemp EXIT SIGKILL # cleanup even on forced exit


# [Functions]
# Use local variables in functions (otherwise they are globally defined).
# Prefix functions in script with "fn_" for better distinction.
# Remember functions perform a subaction, they can only return an exit status
# but can be piped - function is like a subscript.
# 
# example:
# function fn_listUsers() {
#   local users=$(cat /etc/passwd | cut -f1 -d\: | sort -u)
#   for user in ${users}; do
#     echo "${user}"
#   done
# }

# Print help/manual
# @param $1 exit code, 0 if not defined
function fn_printHelp() {
  echo "Usage: ${SCRIPTNAME} [OPTIONS] [ARGS]"
  echo ""
  echo "Options:"
  echo "  -h, --help                Output a usage message and exit."
  echo ""

  # custom exit status
  if [[ -n "$1" ]]; then
    exit "$1"
  fi
  exit "${EXIT_OK}"
}

# Logging support using system logging with output to /dev/stderr
# @param logger - kern, user, mail, daemon, auth, local0, local7 (default
# local0)
# @param severity - emerg, alert, crit, err, warning, notice, info (default
# info)
# @param message
# 
# In case of bad params/call it gets logged as error in local0 with all params
#
# example: fn_log local0 info "Hello info message"
function fn_log() {
  if [[ "$#" -eq 3 ]]; then
    logger -i -s -t "${SCRIPTNAME}" -p "${1}.${2}" "${3}"
  elif [[ "$#" -eq 1 ]]; then
    logger -i -s -t "${SCRIPTNAME}" -p local0.info "${1}"
  else
    logger -i -s -t "${SCRIPTNAME}" -p local0.err "$@"
  fi
}


# [Options parsing]
# Expecting options in format:
# script [-param value] [-param_without_value] [arguments]
#
# example without args: -q|--quiet) QUIET=1;;
# example with args:    -d|--dir)   DIR="${2}";shift;;
#
# For advanced parsing use getopt (man 1 getopt, man 3 getopt)
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -h|--help)
      fn_printHelp;;
    -*)
      echo "Unknown option"
      fn_printHelp "${EXIT_OPTION_UNKNOWN}";;
    *)
      # remaining arguments
      ARGS="$@"
  esac
  shift   
done


# [Script]
echo "Script:    ${SCRIPTNAME}"
echo "Arguments: ${ARGS}"

# [Exit]

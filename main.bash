#!/usr/bin/env bash
# -*- coding: utf-256 -*-
# -----------------------------------------------------------------------------
# Text-Editor for the Bash-Shell, writen with no dependencies.
# Version: 0.1.0
# By: Oak Atsume #
# -----------------------------------------------------------------------------
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# Version: 3.0.0
# -----------------------------------------------------------------------------
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# -----------------------------------------------------------------------------


function quit() {
    echo "Bye!"
    exit 0
}
function cons.error() {
    echo -e "\e[1;31m$1\e[0m"
}

function cons.log() {
    echo -e "\e[1;32m$1\e[0m"
}
function cons.info() {
    echo -e "\e[1;34m$1\e[0m"
}
function cons.warn() {
    echo -e "\e[1;33m$1\e[0m"
}
function cons.help() {
    echo -e "\e[1;35m$1\e[0m"
}
function cons.debug() {
    echo -e "\e[1;36m$1\e[0m"
}

# Trap ^C (SIGINT) and exit the program.
trap quit SIGINT

# Create a while loop that constantly read console input.
_prompt_="[]"
declare -A buffer=();

function _save_ () {
    for a in ${!buffer[*]}; do
        file_array[$(( a - 1 ))]=${buffer[${a}]}
    done
    :> "${file}"
    for b in "${file_array[@]}"; do
        echo "${b}" >> "$file"
    done
}

while true; do
    echo -n "${_prompt_}> "
    read con_input statement1 statement2;
    # Create a case switch that checks if the input is a command.
    case "${con_input}" in
        exit)
            quit
        ;;
        open)
            # Check that statement1 isn't empty.
            if [[ -z "${statement1}" ]]; then
                cons.error "No file specified."
                continue
            else
                # Check that statement1 is a file.
                if [[ -f "${statement1}" ]]; then
                    # Check that the file is a text file.
                    cons.log "File (${statement1}) is valid!"
                else
                    cons.error "File (${statement1}) is not valid!"
                    continue
                fi
            fi
            cons.debug "Opening file (${statement1})..."
            # Read file in to a array.
            readarray -t file_array < "${statement1}"
            cons.debug "File mapped to an array with ${#file_array[@]}, lines"
            _prompt_="[${statement1}]"
            file="${statement1}"
            file_open=true
        ;;
        # file_array
        read)
            if [[ -z "${file_array[*]}" ]]; then
                cons.error "No file opened!"
            else
                cons.debug "Reading line ${statement1}"
                if [[ -z "${file_array[$((statement1 - 1))]}" ]]; then
                    echo "<empty>"
                else
                    echo "${statement1} : ${file_array[$((statement1 - 1))]}"
                fi
            fi
        ;;
        write)
            if [[ -z "${file_array[*]}" ]]; then
                cons.error "No file opened!"
            else
                cons.debug "Writing line ${statement1} : ${statement2}"
                buffer[${statement1}]="${statement2}" # Add to buffer.
            fi
        ;;
        buffer)
            cons.debug "Outputting Current Buffer"
            # Check if buffer is empty
            if [[ -z "${buffer[*]}" ]]; then
                cons.error "No buffer!"
            else
                # Output all keys and values in Buffer
                for a in ${!buffer[*]}; do
                    echo "${a} : ${buffer[${a}]}"
                done
            fi
            
        ;;
        save)
            if [[ -z "${file_array[*]}" ]]; then
                cons.error "No file opened!"
            else
                cons.debug "Saving file (${file})..."
                _save_
            fi
        ;;
        help)
            cons.help "Commands:"
            cons.help "open <file>"
            cons.help "exit"
            cons.help "help"
            cons.help "clear"
            if [[ "${file_open}" == true ]]; then
                cons.help "read <line>"
                cons.help "write <line> <text>"
                cons.help "save"
                cons.help "saveas <file>"
                cons.help "close"
            fi
        ;;
        close)
            if [[ "${file_open}" == true ]]; then
                _prompt_="[]"
                file_open=false
                unset file_array
            else
                cons.error "No file opened."
            fi
        ;;
        clear)
            clear
        ;;
        *)
        ;;
    esac
done
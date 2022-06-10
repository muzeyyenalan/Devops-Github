#!/bin/bash
 
convertAndPrintSeconds() {
 
    local totalSeconds=$1;
    local seconds=$((totalSeconds%60));
    local minutes=$((totalSeconds/60%60));
    local hours=$((totalSeconds/60/60%24));
    local days=$((totalSeconds/60/60/24));
    (( $days > 0 )) && printf '%d days ' $days;
    (( $hours > 0 )) && printf '%d hours ' $hours;
    (( $minutes > 0 )) && printf '%d minutes ' $minutes;
    (( $days > 0 || $hours > 0 || $minutes > 0 )) && printf 'and ';
    printf '%d seconds\n' $seconds;
}
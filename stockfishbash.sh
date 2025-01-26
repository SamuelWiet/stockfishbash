#!/usr/bin/env bash
#
function f_print() {
    echo -n "$1" 1>&2;
}

function f_println() {
    echo "$1" 1>&2;
}

function f_usage() {
    f_println "Usage $(basename $0) [-d depth] [-c w|b] "
    f_println "-c : color to play by stockfish"
}

COLOR="b"
DEPTH=4
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -d|--depth)
      DEPTH="$2"
      f_println "depth=$DEPTH"
      shift # past argument
      shift # past value
      ;;
    -c|--color)
      COLOR="$2"
      f_println "color=$COLOR"
      shift # past argument
      shift # past value
      ;;
    -*|--*)
      f_println "Unknown option $1"
      f_usage
      exit 1
      ;;
    ?|h)
      f_usage
      exit 1
      ;;
    *)
      f_println "Unexpected argument $1"
      f_usage
      exit 1
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

function f_sleep() {
    sleep .2
}

function f_go(){
    f_sleep
    f_println "thinking ..."
    echo "go depth $DEPTH"
    f_sleep
}

function f_display_board() {
    f_sleep
    echo "d"
    f_sleep
    while IFS= read -r line
    do
        boardline=$line 
        if [[ $line != Checkers* ]] ; then
            f_println "$boardline"
        else
            break
        fi
    done
}

moves=""

function f_position() {
    f_sleep
    if [[ "$moves" == "" ]]; then
        echo "position startpos"
        f_println "position startpos"
    else
        echo "position startpos moves $moves"
        f_println "position startpos moves $moves"
    fi
    f_sleep
    f_display_board
}

function f_stockfishbashinput() {
    FILENAME="stockfishbashinput.tmp"
    FILESIZE=$(stat -c%s "$FILENAME")
    while [[ "$FILESIZE" -ne 5 ]]
    do
        f_sleep
        FILESIZE=$(stat -c%s "$FILENAME")
    done
    read -r s < $FILENAME
    rm "$FILENAME"
    touch "$FILENAME"
    eval "$1=$s"
}

function f_move_dialog() {
    f_print "Your move: "
    m=''
    f_stockfishbashinput m
    f_println $m
    eval "$1=$m"
}

if [[ $COLOR == "w" ]] ; then
    f_position
    f_go
else
    f_display_board
    
    yourmove=''
    f_move_dialog yourmove

    moves="${moves}${yourmove} "
    f_position
    f_go          
fi

while read -r line
do
    readLine=$line
    if [[ $readLine = bestmove* ]] ; then
        move=${readLine:9:4}
        if [[ $move = "(non" ]] ; then
            f_println "$readLine -> ending"
            break
        fi
        moves="${moves}${move} "
        f_position
        
        yourmove=''
        f_move_dialog yourmove

        moves="${moves}${yourmove} "
        f_position
        f_go        
    fi
done


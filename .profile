if [[ $(tty) = /dev/tty1 ]]; then
echo "tty";
fiv
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    startx
fi

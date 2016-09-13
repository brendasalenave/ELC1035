#!/bin/bash
OUTPUT="/tmp/input.txt"
>$OUTPUT

sed -i -e '/^#/ d' -e '/^$/d' $1

mostraMenu(){
  dialog --backtitle "T4 - GUI Database" --title "DATABASE MANAGER" \
  --menu "Choose an option" \
  0 0 0 \
  1 "Search machine" \
  2 "Add machine" \
  3 "Delete machine" \
  4 "Edit machine" \
  5 "View machine" \
  0 "Exit" 2>temp
}

findMachine(){
  # show an inputbox
  dialog --title "Inputbox - To take input from you" \
  --backtitle "Linux Shell Script Tutorial Example" \
  --inputbox "Enter your name " 8 60 2>$OUTPUT

  # get respose
  respose=$?
  # get data stored in $OUPUT using input redirection
  name=$(<$OUTPUT)

  # make a decsion
  case $respose in
    0)
      #sayhello ${name}
      m=(${m[*]} `sed "/$name/p" $1`)
      #a=$(sed -n '/$name/p' $1)
      dialog --title "Machines Find" --msgbox "${m[*]}" 100 100
      ;;
    1)
      echo "Cancel pressed."
      ;;
    255)
     echo "[ESC] key pressed."
  esac
}

#while : ; do
  mostraMenu
  retval=$?
  if [[ "$retval" = "0" ]] ; then
    choice=$(cat temp)

    case $choice in
            1)
                echo -e "You chose Option 1"
                findMachine

                ;;
            2)
                echo "You chose Option 2"
                dialog                                         \
                --title 'Parabéns'                             \
                --msgbox 'Instalação finalizada com sucesso.'  \
                6 40
                ;;
            3)
                echo -e "You chose Option 3"
                ;;
            4)
                echo -e "You chose Option 4"
                ;;
            5)
                echo -e "You chose Option 5"
                dialog --title "List file" --msgbox "$(cat $1)" 100 100
                ;;
            0) clear
               exit ;;
    esac
  # Cancel is pressed
  else
    echo "Cancel is pressed"
  fi
#done
# remove the temp file
rm -f temp
# remove $OUTPUT file
rm $OUTPUT

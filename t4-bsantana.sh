0#!/bin/bash
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
  5 "View machines" \
  0 "Exit" 2>temp
}

check_hostname(){
  if [[ $1 =~ ^([A-Za-z]*)([0-9]*[A-Za-z]*)*$ ]] ; then
    retval=0
  else
     retval=1
  fi
  return "$retval"
}

check_IP(){
  if [[ $1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] ; then
    retval=0
  else
     retval=1
  fi
  return "$retval"
}

check_MAC(){
  if [[ $1 =~ ^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$ ]] ; then
    retval=0
  else
     retval=1
  fi
  return "$retval"
}

edit_machine(){
  field1=(${field1[*]} `sed '/^#/ d' $1 | cut -f1 -d' '`)
  field2=(${field2[*]} `sed '/^#/ d' $1 | cut -f2 -d' '`)

  COUNTER=1
  RADIOLIST=""  # variable where we will keep the list entries for radiolist dialog
  for ((u = 0; u < ${#field1[@]}; u++)) ; do
    RADIOLIST="$RADIOLIST ${field1[$u]} ${field2[$u]} off "
    let COUNTER=COUNTER+1
  done

  ESCOLHA=$(dialog --title "Select machine to edit" \
  --stdout \
  --radiolist "" 0 0 $COUNTER \
  $RADIOLIST)
  dialog --title "Máquina:" --msgbox "$ESCOLHA" 7 30

  m=`sed -n -e "/$ESCOLHA/p" $1`
  m1=$(echo $m | cut -f1 -d' ')
  aux=$(dialog --stdout --title "Edit hostname" --inputbox "" 10 60 $m1)
  check_hostname $aux
  retval=$?
  if [[ "$retval" == 0 ]] ; then
    sed -i -e "s/$m1/$aux/g" $1
  fi

  m1=$(echo $m | cut -f2 -d' ')
  aux=$(dialog --stdout --title "Edit IP" --inputbox "" 10 60 $m1)
  check_IP $aux
  retval=$?
  if [[ "$retval" == 0 ]] ; then
      sed -i -e "s/$m1/$aux/g" $1
  fi

  m1=$(echo $m | cut -f3 -d' ')
  aux=$(dialog --stdout --title "Edit MAC" --inputbox "" 10 60 $m1)
  check_MAC $aux
  retval=$?
  if [[ "$retval" == 0 ]] ; then
    sed -i -e "s/$m1/$aux/g" $1
  fi
  
 }

select_machine(){
  field1=(${field1[*]} `sed '/^#/ d' $1 | cut -f1 -d' '`)
  field2=(${field2[*]} `sed '/^#/ d' $1 | cut -f2 -d' '`)

  COUNTER=1
  RADIOLIST=""  # variable where we will keep the list entries for radiolist dialog

  for i in "${field1[@]}"; do
      RADIOLIST="$RADIOLIST $COUNTER $i off "
      let COUNTER=COUNTER+1
  done

  ESCOLHA=$(dialog --title "Select machine to edit" \
          --stdout \
          --checklist "" 0 0 $COUNTER \
          $RADIOLIST)

  dialog --title "Máquinas:" --msgbox "$ESCOLHA" 7 30

  IFS=' ' eval 'array=($ESCOLHA)'
  echo -e "\n\n${array[*]}"

  confirm
  _res=$?
  if [[ "$_res" = "0" ]] ; then
    for i in ${!array[@]}; do
      sed -i "${array[$i]}s/.*//" $1
    done
  fi

}

confirm(){
  dialog --title "  Are u sure?" \
  --yes-label "yes" \
  --no-label "NO" \
  --yesno "Removing an item, it will be lost permanently." 7 33
}

searchMachine(){
  # show an inputbox
  dialog --title "Inputbox - To take input from you" \
  --inputbox "Machine" 8 60 2>$OUTPUT

  # get respose
  _ret=$?
  # get data stored in $OUPUT using input redirection
  name=$(<$OUTPUT)
  echo -e "\n\n$name"

  # make a decsion
  case $_ret in
    0)
      m=`sed -n -e "/$name/p" $1`
      dialog --title "Machines Found" --msgbox "$m" 100 80
      ;;
    1)
      echo "Cancel pressed."
      ;;
    255)
     echo "[ESC] key pressed."
  esac
}

add_machine(){
  dialog --title "Hostname" \
  --inputbox "" 8 60 2>$OUTPUT

  _aux=$(<$OUTPUT)
  check_hostname $_aux
  retval=$?
  if [[ "$retval" == 0 ]] ; then
    _str="$_aux"

    dialog --title "IP" \
    --inputbox "" 8 60 2>$OUTPUT
    _aux=$(<$OUTPUT)
    check_IP $_aux
    retval=$?
    if [[ "$retval" == 0 ]] ; then
      _str="$_str $_aux"

      dialog --title "MAC" \
      --inputbox "" 8 60 2>$OUTPUT
      _aux=$(<$OUTPUT)
      check_MAC $_aux
      retval=$?
      if [[ "$retval" == 0 ]] ; then
        _str="$_str $_aux"

        dialog --title "Group" \
        --inputbox "" 8 60 2>$OUTPUT
        _aux=$(<$OUTPUT)
        _str="$_str $_aux"

        dialog --title "Alias" \
        --inputbox "" 8 60 2>$OUTPUT
        _aux=$(<$OUTPUT)
        if [[ "$_aux" == "" ]] ; then
          _str="$_str -"
        else _str="$_str $_aux"
        fi

        echo $_str >> $1
      else dialog --title " ERROR" --msgbox "invalid MAC" 6 15
      fi
    else dialog --title " ERROR" --msgbox "invalid IP" 6 15
    fi
  else dialog --title " ERROR" --msgbox "invalid Hostname" 6 15
  fi
}

while : ; do
  mostraMenu
  retval=$?
  if [ "$retval" != "0" ] ; then
  clear
  break
  fi

  choice=$(cat temp)

  case $choice in
          1)
              echo -e "You chose Option 1: Search machine"
              searchMachine $1 ;;

          2)
              echo "You chose Option 2: Add machine"
              add_machine $1 ;;
          3)
              echo -e "You chose Option 3: Delete machine"
              select_machine $1
              ;;
          4)
              echo -e "You chose Option 4: Edit machine"
              edit_machine $1 ;;
          5)
              echo -e "You chose Option 5: View machine"
              dialog --title "List file" --msgbox "$(cat $1)" 100 100
              ;;
          0) clear
             break ;;
  esac
done
# remove the temp file
rm -f temp
# remove $OUTPUT file
rm $OUTPUT

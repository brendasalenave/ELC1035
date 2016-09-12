#!/bin/bash

sed -i -e '/^#/ d' -e '/^$/d' $1

mostraMenu(){
  #dialog --backtitle "GUI database" \
  #       --title "T4 - GUI Database" \
  #       --stdout \
  #       --menu "Chosose an option" \
  #       0 0 0 \
  #      1 'Opcao 1'
  #      2 'Opcao 2'
  #      4 'Opcao 3'
  dialog                              \
   --backtitle 'GUI database'         \
   --title 'T4 - GUI Database'        \
   --menu  '    Choose an option'     \
   0 0 0                              \
   1  'Search machine'                \
   2  'Add machine'                   \
   3  'Delete machine'                \
   4  'Edit machine'                  \
   5  'View machine'                  \
   0  'Exit'

}

mostraMenu

#!/bin/bash

# Reverse positional parameters


set a\ b c d\ e;
#     ^      ^     Spaces escaped 
#       ^ ^        Spaces not escaped
OIFS=$IFS; IFS=:;
#              ^   Saving old IFS and setting new one.

echo

until [ $# -eq 0 ]
do          #      Step through positional parameters.
	echo $1
	shift;
#  echo "### k0 = "$k""     # Before
#  k=$1:$k;  #      Append each pos param to loop variable.
##     ^
#  echo "### k = "$k""      # After
#  echo
#  shift;
done

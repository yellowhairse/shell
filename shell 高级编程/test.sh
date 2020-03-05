#!/usr/bin/env bash



while [ 1 = 1 ];do
    echo "Is it morning? Please answer yes or no."
    read YES_OR_NO
    case "$YES_OR_NO" in
    yes|y|Yes|YES)
      echo "Good Morning!";;
    [nN]*)
      echo "Good Afternoon!";;
    *)
      echo "Sorry, $YES_OR_NO not recognized. Enter yes or no."
      exit 2;;
    esac
    #exit 0
done

echo $?

#!/usr/bin/env bash
AED_ROOT=${AED_ROOT:=$HOME/.aed}

if [ -d "${AED_ROOT}" ]; then
  echo "Already installed"
  exit 1
fi



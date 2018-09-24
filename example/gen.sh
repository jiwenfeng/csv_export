#!/bin/sh

CSV_FILES=`ls *.csv`

lua ../gen.lua ./ $CSV_FILES

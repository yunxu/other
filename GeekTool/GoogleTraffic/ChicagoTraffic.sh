#!/bin/bash 
#------------------------------------------------------------------------------
# Real-time Chicago local traffic map for GeekTool
# Author: Yun Xu
#   Date: Jan 6, 2013 
#  Usage: sh ChicagoTraffic.sh 12
# Parameter ZoomLevel can be changed, default is 12
#------------------------------------------------------------------------------

function CheckConnection(){
 PackageRecieved=$(ping -c 1 -q -W 2  google.com 2>/dev/null| grep trans | awk '{print $4}')
 echo ${PackageRecieved:-0}
}

function GoogleTraffic(){ 
  ZoomLevel=$1 
  # initialization
  X0=67158
  Y0=97440
  Z0=18
  RowTiles=4
  ColTiles=4
  
  GoogleMapDir=/tmp/googlemap
  if [ ! -d $GoogleMapDir ]; then mkdir $GoogleMapDir; fi
  
  XCenter=$(echo "$X0/(2^($Z0-$ZoomLevel))" | bc)
  YCenter=$(echo "$Y0/(2^($Z0-$ZoomLevel))" | bc)
  XOffset=$(echo $ColTiles/2 -1 | bc)
  YOffset=$(echo $RowTiles/2 | bc)
  XLeft=$(($XCenter-$YOffset))
  XRight=$(($XLeft+$ColTiles))
  YTop=$(($YCenter-$YOffset))
  YBottom=$(($YTop+$RowTiles-1))
  XInd=$(/sw/bin/gseq $XLeft $XRight)
  YInd=$(/sw/bin/gseq $YTop $YBottom)
#  XInd=$(jot - $XLeft $XRight)
#  YInd=$(jot - $YTop $YBottom)
  StrPngFiles=""
  CountNum=1
  
  for Y in ${YInd[@]}; do
      for X in ${XInd[@]}; do
          #    echo $X $Y
          RndNum=$(echo $RANDOM % 2 | bc )
          PngLink="http://mt$RndNum.google.com/vt?hl=en&lyrs=m@129,traffic|seconds_into_week:-1&x=$X&y=$Y&z=$ZoomLevel&style=14"
          StrCountNum=$(printf "%02s" $CountNum)
          PngFile="$GoogleMapDir/map_$StrCountNum.png"
          curl -s -o $PngFile $PngLink
          StrPngFiles=$StrPngFiles" "$PngFile 
          CountNum=$(($CountNum+1))
      done
  done
  
  echo "Zoom level: "$ZoomLevel
  /sw/bin/montage -mode concatenate -tile x$RowTiles $StrPngFiles $GoogleMapDir/Traffic.png
}
#-----------------------------
# main

pckts_rcvd=$(CheckConnection)
if [ $pckts_rcvd -ne 0 ]; then
    ZoomLevel=$1;
    ZoomLevel=${ZoomLevel:-12}
    GoogleTraffic $ZoomLevel 
fi


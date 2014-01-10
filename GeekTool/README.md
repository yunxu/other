#### Real-time local traffic map for GeekTool

♢ real-time local traffic map

- desktop show real-time local traffic information through google maps
- location can be set by X0, Y0, and Z0
- zoomlevel can be customized
- require imagemagick to montage images
- demonstrated by Chicago and Irvine 

###### Local position determined by X0, Y0 and Z0

- visit [google maps](http://maps.google.com) in the firefox browser
- locate your interesting place
- double click the the blank area in the page to trigger popup menu
- select "View Page Info"
- In the Media tab, try to find any image link which including "x=1024&y=256&z=18", for example.
- change the "X0=1024; Y0=256; Z0=18" in the bash script file
- try "sh ChicagoTraffic.sh 12" to see the effect

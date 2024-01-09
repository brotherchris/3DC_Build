#!/bin/bash

date=$(date +%Y-%m-%d_%H:%M:%S)
CLI_No_TEMP=$1  #Pull in CLI parm to take out temp changes
Start_G_File=~/Start_Gcode.txt #Text file for your Start gcode
End_G_File=~/End_Gcode.txt #Text file for your End gcode
Tool_G_File=~/Tool_Gcode.txt #Text file for your Tool change gcode
Rate4_Test_G_File=~/Rate4Test_Gcode.txt #Text file for your rate test gcode
ANS_FILE=~/ANS_FILE.txt #File to store your test run answers in
PARM_SAVE=~/ParmSave_$date.txt
y_tube_long=115 #measured from black lock ring with PTFE seated
y_tube_short=80 #2 outside shorter paths
but_ini_loc=$((but_press-3)) #get close to the button ready to press it
t0dwell="P550"
t1dwell="P1000"
t2dwell="P1500"
t3dwell="P1900"

fiffties=8

#Have you ran the test gcode or not?
echo "Have you ran the load test GCODE yet?"
read -p "[Y/N]" tested
USER_ANS=$(echo "${tested^^}") #used to make the prompt always upper case
if [ -z "$USER_ANS" ]
   then
      echo "Input cannot be blank."
   exit 0
fi

if  [[ "$USER_ANS" != "Y" && "$USER_ANS" != "N" ]]
   then
      echo "Input has to be Y or N."
   exit 0
fi
tested=$USER_ANS


if [ $USER_ANS == "Y" ]  #Start building All the gcode files
   then
      if [ -f $ANS_FILE ] #Make sure the answer file from the rate testing is there.
         then
int=0
echo "Contents of test answer file." $ANS_FILE > $PARM_SAVE 
while IFS=":" read -r value1 value2 remainder 
do
Line=$value2
if [ $int == 0 ]
then
firmware=$value2
fi
Line=$value2
if [ $int == 1 ]
then
but_axis=$value2
fi
Line=$value2
if [ $int == 2 ]
then
but_press=$value2
fi
Line=$value2
if [ $int == 3 ]
then
fil_start_gap=$value2
fi
Line=$value2
if [ $int == 4 ]
then
ext_feed_tube=$value2
fi
((int++))
done < $ANS_FILE
echo "Good, here are the settings you already entered"
            echo ""
            cat $ANS_FILE
            echo ""
            echo ""
            echo "We need more info about your printer."
            read -p "Press [Enter] to get started..."
            clear
            echo "What is your MAX X size in mm?"
            read -p "[ mm ]" MAXX
            if [ -z "$MAXX" ]
               then
                  echo "Input cannot be blank."
               exit 0
            fi
		    
            if [[ "$MAXX" != ?(-)+([0-9]) ]]
               then
                  echo "Input has to be a number."
               exit 0
            fi
            printer_x_size=$MAXX
	    echo "Max printer size X is :" $MAXX >> $PARM_SAVE    
            echo "What is your MAX Y size in mm?"
            read -p "[ mm ]" MAXY
            if [ -z "$MAXY" ]
               then
                  echo "Input cannot be blank."
               exit 0
            fi
		    
            if [[ "$MAXY" != ?(-)+([0-9]) ]]
               then
                  echo "Input has to be a number."
               exit 0
            fi
            printer_y_size=$MAXY
            echo "Max printer size Y is :" $MAXY >> $PARM_SAVE
		    
            echo "Enter T0 kick out length in mm"
            read -p "[ mm ]" kick0
            if [ -z "$kick0" ]
               then
                  echo "Input cannot be blank."
               exit 0
            fi
		    
            if [[ "$kick0" != ?(-)+([0-9]) ]]
               then
                  echo "Input has to be a number."
               exit 0
            fi
            init_kickout_0=$kick0
	    echo "Kick out T0 is :" $kick0 >> $PARM_SAVE    
            echo "Enter T1 kick out length in mm"
            read -p "[ mm ]" kick1
            if [ -z "$kick1" ]
               then
                  echo "Input cannot be blank."
               exit 0
            fi
		    
            if [[ "$kick1" != ?(-)+([0-9]) ]]
               then
                  echo "Input has to be a number."
               exit 0
            fi
            init_kickout_1=$kick1
	    echo "Kick out T1 is :" $kick1 >> $PARM_SAVE    
            echo "Enter T2 kick out length in mm"
		    
            read -p "[ mm ]" kick2
            if [ -z "$kick2" ]
               then
                  echo "Input cannot be blank."
               exit 0
            fi
		    
            if [[ "$kick2" != ?(-)+([0-9]) ]]
               then
                  echo "Input has to be a number."
               exit 0
            fi
            init_kickout_2=$kick2
	    echo "Kick out T2 is :" $kick2 >> $PARM_SAVE	    
		    
            echo "Enter T3 kick out length in mm"
            read -p "[ mm ]" kick3
            if [ -z "$kick3" ]
               then
                  echo "Input cannot be blank."
               exit 0
            fi
		    
            if [[ "$kick3" != ?(-)+([0-9]) ]]
               then
                  echo "Input has to be a number."
               exit 0
            fi
            init_kickout_3=$kick3
	    echo "Kick out T3 is :" $kick3 >> $PARM_SAVE	    
		    
            echo "What is the length in mm from the top of the extruder coupler to the gears?"
            read -p "[ mm ]" togears
            if [ -z "$togears" ]
               then
                  echo "Input cannot be blank."
               exit 0
            fi
		    
            if [[ "$togears" != ?(-)+([0-9]) ]]
               then
                  echo "Input has to be a number."
               exit 0
            fi
            feed_to_ext=$togears
	    echo "Top of extruder coupler to gears :" $togears >> $PARM_SAVE    
            echo "How many mm is it from extruder gripping the filament to nozzle extrusion?"
            read -p "[ mm ]" tonozzle
            if [ -z "$tonozzle" ]
               then
                  echo "Input cannot be blank."
               exit 0
            fi
		    
            if [[ "$tonozzle" != ?(-)+([0-9]) ]]
               then
                  echo "Input has to be a number."
               exit 0
            fi
            gears_to_nozzle=$tonozzle
	    echo "How many mm from gear to hotend to start extruding :" $tonozzle >> $PARM_SAVE	    
            #Remove all old Gcode TXT files
            if [ -f $Start_G_File ]; then
               rm $Start_G_File
            fi
            touch $Start_G_File
            if [ -f $End_G_File ]; then
               rm $End_G_File
            fi
            touch $End_G_File
            if [ -f $Tool_G_File ] ; then
               rm $Tool_G_File
            fi
            touch $Tool_G_File
		    but_ini_loc=$((but_press-3)) #get close to the button ready to press it




short_travel=$((fil_start_gap+ext_feed_tube+y_tube_short)) #Top load gap, extruder feed tube and Y pipe, this is the total path
long_travel=$((fil_start_gap+ext_feed_tube+y_tube_long))
sec_to_load=$(((long_travel/34)+1))
mili_sec_load="P"$((((long_travel/34)+1)*1000))
fil_feed_rate_0=$(echo "scale=1;($short_travel+$init_kickout_0)/$sec_to_load" | bc ) 
fil_feed_rate_1=$(echo "scale=1;($long_travel+$init_kickout_1)/$sec_to_load" | bc )
fil_feed_rate_2=$(echo "scale=1;($long_travel+$init_kickout_2)/$sec_to_load" | bc )
fil_feed_rate_3=$(echo "scale=1;($short_travel+$init_kickout_3)/$sec_to_load" | bc )

coupler_comp=13
load_to_gear_0=$(echo "scale=1;($feed_to_ext-$coupler_comp)+$short_travel" | bc )
load_to_gear_1=$(echo "scale=1;($feed_to_ext-$coupler_comp)+$long_travel" | bc )
load_to_gear_2=$(echo "scale=1;($feed_to_ext-$coupler_comp)+$long_travel" | bc )
load_to_gear_3=$(echo "scale=1;($feed_to_ext-$coupler_comp)+$short_travel" | bc )
load_sec_0="P"$(echo "scale=2;(($load_to_gear_0/$fil_feed_rate_0)*1000)/1" | bc | sed -E -e 's!(\.[0-9]*[1-9])0*$!\1!' -e 's!(\.0*)$!!' )
load_sec_1="P"$(echo "scale=2;(($load_to_gear_1/$fil_feed_rate_1)*1000)/1" | bc | sed -E -e 's!(\.[0-9]*[1-9])0*$!\1!' -e 's!(\.0*)$!!' )
load_sec_2="P"$(echo "scale=2;(($load_to_gear_2/$fil_feed_rate_2)*1000)/1" | bc | sed -E -e 's!(\.[0-9]*[1-9])0*$!\1!' -e 's!(\.0*)$!!' )
load_sec_3="P"$(echo "scale=2;(($load_to_gear_3/$fil_feed_rate_3)*1000)/1" | bc | sed -E -e 's!(\.[0-9]*[1-9])0*$!\1!' -e 's!(\.0*)$!!' )
purge_line_start_x=$printer_x_size
purge_line_start_y=$but_ini_loc
purge_line_end_x=
purge_line_end_y=
		    
		    
		    
            #Start building Start Gcode file
            echo -e ";Copy and paste everything into START gcode window" >>$Start_G_File




if [[ $firmware == "KLIPPER" ]]; then
echo "SET_FILAMENT_SENSOR SENSOR=filament_sensor ENABLE=0" >> $Start_G_File
fi
if [[ $firmware == "KLIPPER" ]]; then
echo "START_PRINT EXTRUDER_TEMP=[first_layer_temperature] BED_TEMP=[first_layer_bed_temperature]" >> $Start_G_File
fi
cat >> $Start_G_File << EOF
G90 ;absolute mode
M82 ;absolute extrusion mode
G92 E0
G0 X0 $but_axis$but_ini_loc F2000 ; move to button
G0 $but_axis$but_press F2000 ; press button
G4 P150 ; wait for 150 ms
G0 $but_axis$but_ini_loc F2000 ; unpress button
G4 P150 ; wait for 150 ms
G0 $but_axis$but_press F2000 ; press button
G4 P150 ; wait for 150 ms
G0 $but_axis$but_ini_loc F2000 ; unpress button
G4 P150 ; wait for 150 ms
G0 $but_axis$but_press F2000 ; press button
G4 P150 ; wait for 150 ms
G0 $but_axis$but_ini_loc F2000 ; unpress button
G4 P150 ; wait for 150 ms
G0 $but_axis$but_press F2000 ; press button
G4 P3200 ; wait for 7 pulses
G0 $but_axis$but_ini_loc F2000 ; unpress button
G4 P2000 ; wait for it to home
G0 $but_axis$but_press F2000 ; press button
G4 $t0dwell ; wait for 550 milliseconds
G0 $but_axis$but_ini_loc F2000 ; unpress button
T0
G4 P2000 ; all done
G0 $but_axis$but_press F2000 ; press button
G4 $load_sec_0 ; wait for Y pipe to extruder load time seconds
G0 $but_axis$but_ini_loc F2000 ; move away from button
M400 ; make sure moves are all done before we load
G0 E$gears_to_nozzle F500 ; Load to nozzle
EOF
for i in `seq $fiffties`
do
    
    echo "HelloWorld" >> $Start_G_File
    done
cat >> $Start_G_File << EOF
G0 X$purge_line_start_x Y$purge_line_start_y Z.2 F1000; move to extruders assigned purge line
G0 Y0 E60; purge the extruder while moving to Y min.
G0 X$((purge_line_start_x-1)); purge the extruder.
G0 Y$but_ini_loc E105; purge the extruder.
G4 P2000 ; all done
EOF
if [[ $firmware == "KLIPPER" ]]; then
echo "SET_FILAMENT_SENSOR SENSOR=filament_sensor ENABLE=1" >> $Start_G_File
fi

         #Start building END gcode file




echo -e ";Copy and paste everything into END gcode window" >>$End_G_File
if [[ $firmware == "KLIPPER" ]]; then
echo "SET_FILAMENT_SENSOR SENSOR=filament_sensor ENABLE=0" >> $End_G_File
fi
cat >> $End_G_File << EOF
G90 ;absolute mode
G92 E0
G0 E-2 F2400; retract to prevent blobbing
G92 E0
G0 X0 $but_axis$but_ini_loc F2000 ; <<----- EDIT THIS LINE TO SET THE INITIAL LOCATION OF THE BUTTON
G91 ; move to relative mode
M83
G92 E0;
G0 E-25 F500 ; retract a bit, adjust this to tune waste
G0 E25 F1500 ;
G0 E-5 F500 ;
G0 E5 F1500 ;
G0 E-1 F500 ;
G0 E1 F1500 ;
G0 E-25 F500 ;
M106 S255
M109 S180; cool down to prevent swelling
G0 E24 F1500 ; last tip dip with cold tip
G0 E-24 F500 ; last tip dip with cold tip
M109 S150; cool down to prevent swelling
M109 S180; ok... go back up in temp so we can move the extruder
G0 E-50 F500 ; back out of the extruder
G92 E0
G0 E-50 F500 ; back out of the extruder
G92 E0
M107 ;
G0 Y3 F2000 ; press button
G4 P2800 ; wait for 6 pulses
G0 Y-3 F2000 ; unpress button
G90
M83
END_PRINT
EOF

         #Start building tool gcode file.




         echo -e ";Copy and paste everything into TOOL CHANGE gcode window" >>$Tool_G_File

cat >> $Tool_G_File << EOF
{if previous_extruder>-1}
{if next_extruder!=previous_extruder}
EOF
if [[ $firmware == "KLIPPER" ]]; then
echo "SET_FILAMENT_SENSOR SENSOR=filament_sensor ENABLE=0" >> $Tool_G_File
fi
cat >> $Tool_G_File << EOF
G0 E-2 F2400; retract to prevent blobbing
G92 E0
G90 ;absolute mode
G0 $but_axis$but_ini_loc F2000 ; <<----- EDIT THIS LINE TO SET THE INITIAL LOCATION OF THE BUTTON
G91 ; move to relative mode
M83
G92 E0;
G0 E-25 F500 ; retract a bit, adjust this to tune waste
G0 E25 F1500 ;
G0 E-5 F500 ;
G0 E5 F1500 ;
G0 E-1 F500 ;
G0 E1 F1500 ;
G0 E-25 F500 ;
EOF
if [[ $CLI_No_TEMP != "NO_TEMP" ]]; then
cat >> $Tool_G_File << EOF
M106 S255
M109 S180; cool down to prevent swelling
G0 E24 F1500 ; last tip dip with cold tip
G0 E-24 F500 ; last tip dip with cold tip
M109 S150; cool down to prevent swelling
M109 S180; ok... go back up in temp so we can move the extruder
G0 E-50 F500 ; back out of the extruder
G92 E0
G0 E-50 F500 ; back out of the extruder
G92 E0
M107 ;
M104 S[temperature];
EOF
else
echo ";NO TEMP SET" >> $Tool_G_File
fi

cat >> $Tool_G_File << EOF
G0 Y3 F2000
{if next_extruder==0}
G4 $t0dwell ; dwell for .5 seconds - adjust this to match your machines single pulse time
{endif}
{if next_extruder==1}
G4 $t1dwell ; dwell for 1.0 seconds - adjust this to match your machines two pulse time
{endif}
{if next_extruder==2}
G4 $t2dwell ; dwell for 1.5 seconds - adjust this to match your machines three pulse time
{endif}
{if next_extruder==3}
G4 $t3dwell ; dwell for 2.0 seconds - adjust this to match your machines four pulse time
{endif}
G0 Y-3 F2000
G0 E-75 F500 ; continue to back out of the extruder
M400 ; Wait for extruder to backout
G0 Y3 F2000
{if current_extruder==0}
G4 $load_sec_0 ;unloading extruder {current_extruder}
G0 Y-3 F2000
G4 P400
M400 ;Make sure everything is done on unload
{endif}
{if current_extruder==1}
G4 $load_sec_1 ;unloading extruder {current_extruder}
G0 Y-3 F2000
G4 P400
M400 ;Make sure everything is done on unload
{endif}
{if current_extruder==2}
G4 $load_sec_2 ;unloading extruder {current_extruder}
G0 Y-3 F2000
G4 P400
M400 ;Make sure everything is done on unload
{endif}
{if current_extruder==3}
G4 $load_sec_3 ;unloading extruder {current_extruder}
G0 Y-3 F2000
G4 P400
M400 ;Make sure everything is done on unload
{endif}
{if next_extruder==0}
G0 Y3 F2000
G4 $load_sec_0 ;loading extruder {next_extruder}
{endif}
{if next_extruder==1}
G0 Y3 F2000
G4 $load_sec_1 ;loading extruder {next_extruder}
{endif}
{if next_extruder==2}
G0 Y3 F2000
G4 $load_sec_2 ;loading extruder {next_extruder}
{endif}
{if next_extruder==3}
G0 Y3 F2000
G4 $load_sec_3 ;loading extruder {next_extruder}
{endif}
G0 Y-3 F2000;
G4 P400
M400 ; make sure moves are all done before extruder moves
G0 E$gears_to_nozzle F500 ; <<<--- adjust this E value to tune extruder loading
G4 P400
G92 E0
M104 S[temperature];
M106 S[max_fan_speed];
EOF
if [[ $firmware == "KLIPPER" ]]; then
echo "SET_FILAMENT_SENSOR SENSOR=filament_sensor ENABLE=1" >> $Tool_G_File
fi
cat >> $Tool_G_File << EOF
G90 ; move to absolute mode
M83
{endif}
{endif}
EOF

            clear
            echo ""
            echo -e "That's it!"
            echo -e "Here are the things you need to enter in PRUSA Slicer"
            read -p "Press [Enter] key to get gcodes..."
            clear
            cat $Start_G_File
            echo ""
            read -p "Press [Enter] to continue..."
            clear
            cat $End_G_File
            echo ""
            read -p "Press [Enter] to continue..."
            clear
            cat $Tool_G_File
            echo ""
            read -p "Press [Enter] to continue..."
            echo ""
            echo ""
            echo ""
            echo -e "To read these files again, use the cat commands to display them as follows"
            echo ""
            echo -e "cat Start_Gcode.txt"
            echo ""
            echo -e "cat End_Gcode.txt"
            echo ""
            echo -e "cat Tool_Gcode.txt"
            echo ""
            echo -e "Good luck!"
         exit 0

      else
            echo -e "No testing data was found, please restart the script and answer NO"
         exit 0
      fi
else
   if [ -f $ANS_FILE ]
   then
      rm $ANS_FILE
   fi
   echo "What firmware are you using?"
   read -p  "[PRUSA,MARLIN,KLIPPER]" firmware
   USER_ANS=$(echo "${firmware^^}")
   if [ -z "$USER_ANS" ]
      then
         echo "Input cannot be blank."
      exit 0
   fi

   if  [[ "$USER_ANS" != "KLIPPER" && "$USER_ANS" != "MARLIN" && "$USER_ANS" != "PRUSA" ]]
      then
         echo "Input has to be KLIPPER PRUSA or MARLIN."
      exit 0
   fi
   firmware=$USER_ANS
   touch $ANS_FILE
   touch $PARM_SAVE
   echo "Your firmware is :$firmware" | tee -a $ANS_FILE $PARM_SAVE >/dev/null
   echo "What axis is your Chameleon button on?"
   read -p "[X or Y]" axis
   USER_ANS=$(echo "${axis^^}")
   if [ -z "$USER_ANS" ]
      then
         echo "Input cannot be blank."
      exit 0
   fi

   if  [[ "$USER_ANS" != "X" && "$USER_ANS" != "Y" ]]
     then
         echo "Input has to be X or Y."
     exit 0
   fi

   but_axis=$USER_ANS
   echo "Your button axis is:$but_axis" | tee -a $ANS_FILE $PARM_SAVE >/dev/null

   echo "Where do we have go on the $but_axis axis to click the Chameleon button [in mm]?"
   read -p "[ mm ]" press
   if [ -z "$press" ]
      then
         echo "Input cannot be blank."
      exit 0
   fi

   if [[ "$press" != ?(-)+([0-9]) ]]
      then
         echo "Input has to be a number."
      exit 0
   fi
   but_press=$press
   echo "You have to go to $but_press on the $but_axis to press the Chameleon button :$but_press" | tee -a $ANS_FILE $PARM_SAVE >/dev/null

   echo "What is your filament loading gap in mm? [amount above Y pipe when starting, recommend 25mm]"
   read -p "[mm]" gap
   if [ -z "$gap" ]
      then
         echo "Input cannot be blank."
      exit 0
   fi

   if  [[ "$gap" != ?(-)+([0-9]) ]]
      then
         echo "Input has to be a number."
      exit 0
   fi
   fil_start_gap=$gap
   echo "Your filament starting gap is :$fil_start_gap" | tee -a $ANS_FILE $PARM_SAVE >/dev/null

   echo "What is the lenght of the tube from the Y pipe to the extruder in mm?"
   read -p "[mm]" etube
   if [ -z "$etube" ]
      then
         echo "Input cannot be blank."
      exit 0
   fi

   if [[ "$etube" != ?(-)+([0-9]) ]]
      then
         echo "Input has to be a number."
      exit 0
   fi
   ext_feed_tube=$etube
   echo "Your PTFE tube above the extruder is  :$ext_feed_tube" | tee -a $ANS_FILE $PARM_SAVE >/dev/null
   
   #Variables to be set for test gcode only
   long_travel=$((fil_start_gap+ext_feed_tube+y_tube_long))
   echo "Long travel test" $long_travel >> $PARM_SAVE
   mili_sec_load="P"$((((long_travel/34)+2)*1000))
   echo "Mili Sec Load" $mili_sec_load >> $PARM_SAVE
   but_ini_loc=$((but_press-3)) #get close to the button ready to press it 

   if [ -f $Rate4_Test_G_File ]; then
      rm $Rate4_Test_G_File
   fi

   cat >> $Rate4_Test_G_File << EOF
G28 ;We will home 3 times incase sensorless hoking is having issues
G28
G28
G90 ;absolute mode
G0 $but_axis$but_ini_loc F2000 ; move to button
G92 E0
G0 $but_axis$but_press F2000 ; press button
G4 P150 ; wait for 150 ms
G0 $but_axis$but_ini_loc F2000 ; unpress button
G4 P150 ; wait for 150 ms
G0 $but_axis$but_press F2000 ; press button
G4 P150 ; wait for 150 ms
G0 $but_axis$but_ini_loc F2000 ; unpress button
G4 P150 ; wait for 150 ms
G0 $but_axis$but_press F2000 ; press button
G4 P150 ; wait for 150 ms
G0 $but_axis$but_ini_loc F2000 ; unpress button
G4 P150 ; wait for 150 ms
G0 $but_axis$but_press F2000 ; press button
G4 P3200 ; wait for 7 pulses
G0 $but_axis$but_ini_loc F2000 ; unpress button
G4 P2000 ; wait for it to home
G91 ; move to relative mode
M83
G92 E0;
;test extruder 1 after home
G0 Y3 F2000
G4 $t0dwell ; dwell for 0.5 seconds - adjust this to match your machines two pulse time
G0 Y-3 F2000
G4 P400
G0 Y3 F2000
G4 $mili_sec_load
G0 Y-3
G4 P2000 ; give 2 seconds to measure
;test extruder 2
G0 Y3 F2000
G4 $t1dwell ; dwell for 1.0 seconds - adjust this to match your machines two pulse time
G0 Y-3 F2000
G4 P400
G0 Y3 F2000
G4 $mili_sec_load ;back out 1
G0 Y-3
G4 P400
G0 Y3 F2000
G4 $mili_sec_load ;load 2
G0 Y-3
G4 P2000 ; give 2 seconds to measure
;test extruder 3
G0 Y3 F2000
G4 $t2dwell ; dwell for 1.5 seconds - adjust this to match your machines two pulse time
G0 Y-3 F2000
G4 P400
G0 Y3 F2000
G4 $mili_sec_load ;back out 2
G0 Y-3
G4 P400
G0 Y3 F2000
G4 $mili_sec_load ;load 3
G0 Y-3
G4 P2000 ; give 2 seconds to measure
;test extruder 4
G0 Y3 F2000
G4 $t3dwell ; dwell for 2.0 seconds - adjust this to match your machines two pulse time
G0 Y-3 F2000
G4 P400
G0 Y3 F2000
G4 $mili_sec_load ;back out 3
G0 Y-3
G4 P400
G0 Y3 F2000
G4 $mili_sec_load ;load 4
G0 Y-3
G4 P2000 ; give 2 seconds to measure
M84 ; motors off
EOF

   clear
   YELLOW='\033[1;32m'
   echo -e ""
   echo -e "${YELLOW}Now, please run this gcode on your printer where the Chameleon is installed."
   echo -e "${YELLOW}Make sure your Y pipe is disconnected from the extruder, but has the extruder feed tube installed."
   echo -e "${YELLOW}Measure and record the distance from the end of the extruder feed tube to the tip of the filament"
   echo -e "${YELLOW}Re-run this script with the recorded values to create your Start End and Tool Gcodes."
   echo -e ""
   read -p "Press [Enter] key to get test gcode..."
   clear

   cat $Rate4_Test_G_File


   exit 0
fi

#!/bin/bash

########### User variables
ext_dd=false
t0dwell="P550" #Dwell time to press switch to load T0
t1dwell="P1000" #Dwell time to press switch to load T1
t2dwell="P1500" #Dwell time to press switch to load T2
t3dwell="P1900" #Dwell time to press switch to load T3

fiffties=8

##### Static variables

date=$(date +%Y-%m-%d_%H:%M:%S)
CLI_No_TEMP=$1  #Pull in CLI parm to take out temp changes
Start_G_File=Start_Gcode.txt #Text file for your Start gcode
End_G_File=End_Gcode.txt #Text file for your End gcode
Tool_G_File=Tool_Gcode.txt #Text file for your Tool change gcode
Rate4_Test_G_File=Rate4Test_Gcode.txt #Text file for your rate test gcode
ANS_FILE=ANS_FILE.txt #File to store your test run answers in
PARM_SAVE=ParmSave_$date.txt
y_tube_long=115 #measured from black lock ring with PTFE seated
y_tube_short=80 #2 outside shorter paths


#############################################
######## Gcode creation questions ###########
#############################################

#Have you ran the test gcode or not?
echo "Have you ran the load test GCODE yet?"
read -p "[Y/N]" tested
USER_ANS=$(echo "${tested^^}") #used to make the prompt always upper case
if [ -z "$USER_ANS" ]; then
   echo "Input cannot be blank."
   exit 0
fi

if  [[ "$USER_ANS" != "Y" && "$USER_ANS" != "N" ]]; then
   echo "Input has to be Y or N."
   exit 0
fi

if [ $USER_ANS == "Y" ]; then  #Start building All the gcode files
      
   if [ -f $ANS_FILE ]; then #Make sure the answer file from the rate testing is there      
      minimumsize=120
      actualsize=$(wc -c <"$ANS_FILE")
         if [ $actualsize -ge $minimumsize ]; then
         int=0 #reset increment before loop starts
         echo "Contents of test answer file." $ANS_FILE > $PARM_SAVE  #Make header in answer and save file 

         while IFS=":" read -r value1 value2 remainder #Start a loop to pull values from test answer file to use as variables 
            do
               Line=$value2
               if [ $int == 0 ]; then
                  firmware=$value2
               fi
               Line=$value2
               if [ $int == 1 ]; then
                  but_axis=$value2
               fi
               Line=$value2
               if [ $int == 2 ]; then
                  but_press=$value2
               fi
               Line=$value2
               if [ $int == 3 ]; then
                  fil_start_gap=$value2
               fi
               Line=$value2
               if [ $int == 4 ]; then
                  ext_feed_tube=$value2
               fi
               Line=$value2
               if [ $int == 5 ]; then
                  MAXX=$value2
               fi
               Line=$value2
               if [ $int == 6 ]; then
                  MAXY=$value2
               fi               
               Line=$value2
               if [ $int == 7 ]; then
                  kick0=$value2
               fi
               Line=$value2
               if [ $int == 8 ]; then
                  kick1=$value2
               fi               
               Line=$value2
               if [ $int == 9 ]; then
                  kick2=$value2
               fi
               Line=$value2
               if [ $int == 10 ]; then
                  kick3=$value2
               fi               
               Line=$value2
               if [ $int == 11 ]; then
                  togears=$value2
               fi
               Line=$value2
               if [ $int == 12 ]; then
                  tonozzle=$value2
               fi               
               ((int++)) #increase int counter
         done < $ANS_FILE #Loop over

         echo "Good, here are the settings you already entered"
         echo ""
         cat $ANS_FILE
         echo ""
         echo ""
         echo "We need more info about your printer."
         read -p "Press [Enter] to get started..."
         clear
         intr=0
         while [ $intr -le 3 ]; do
            echo "What is your MAX X size in mm?"
            read -p "[ Enter MAX X ] : " -i $MAXX -e answer
            if [ -z $answer ]; then
               echo ""
               echo "Input cannot be blank."
               echo ""
               ((intr++))
               continue
           elif [[ $answer != ?(-)+([0-9]) ]]; then
               echo ""
               echo "Input has to be a number."
               echo ""
               ((intr++))
               continue
            fi
         MAXX=$answer
         break
         done
         if [ $intr -ge 3 ]; then
            exit 0
         fi
         intr=0
         while [ $intr -le 3 ]; do
            echo ""
            echo "What is your MAX Y size in mm?"
            read -p "[ Enter MAX Y ] : " -i $MAXY -e answer
            if [ -z $answer ]; then
               echo ""
               echo "Input cannot be blank."
               echo ""
               ((intr++))
               continue
           elif [[ $answer != ?(-)+([0-9]) ]]; then
               echo ""
               echo "Input has to be a number."
               echo ""
               ((intr++))
               continue
            fi
         MAXY=$answer
         break
         done
         if [ $intr -ge 3 ]; then
            exit 0
         fi
         intr=0
         while [ $intr -le 3 ]; do
            echo ""
            echo "Enter T0 kick out length in mm"
            read -p "[ Enter Kick out for T0 ] : " -i $kick0 -e answer
            if [ -z $answer ]; then
               echo ""
               echo "Input cannot be blank."
               echo ""
               ((intr++))
               continue
           elif [[ $answer != ?(-)+([0-9]) ]]; then
               echo ""
               echo "Input has to be a number."
               echo ""
               ((intr++))
               continue
            fi
         kick0=$answer
         break
         done
         if [ $intr -ge 3 ]; then
            exit 0
         fi
         intr=0
         while [ $intr -le 3 ]; do
            echo ""
            echo "Enter T1 kick out length in mm"
            read -p "[ Enter Kick out for T1 ] : " -i $kick1 -e answer
            if [ -z $answer ]; then
               echo ""
               echo "Input cannot be blank."
               echo ""
               ((intr++))
               continue
           elif [[ $answer != ?(-)+([0-9]) ]]; then
               echo ""
               echo "Input has to be a number."
               echo ""
               ((intr++))
               continue
            fi
         kick1=$answer
         break
         done
         if [ $intr -ge 3 ]; then
            exit 0
         fi
         intr=0
         while [ $intr -le 3 ]; do
            echo ""
            echo "Enter T2 kick out length in mm"
            read -p "[ Enter Kick out for T2 ] : " -i $kick2 -e answer
            if [ -z $answer ]; then
               echo ""
               echo "Input cannot be blank."
               echo ""
               ((intr++))
               continue
           elif [[ $answer != ?(-)+([0-9]) ]]; then
               echo ""
               echo "Input has to be a number."
               echo ""
               ((intr++))
               continue
            fi
         kick2=$answer
         break
         done
         if [ $intr -ge 3 ]; then
            exit 0
         fi
         intr=0
         while [ $intr -le 3 ]; do
            echo ""
            echo "Enter T3 kick out length in mm"
            read -p "[ Enter Kick out for T3 ] : " -i $kick3 -e answer
            if [ -z $answer ]; then
               echo ""
               echo "Input cannot be blank."
               echo ""
               ((intr++))
               continue
           elif [[ $answer != ?(-)+([0-9]) ]]; then
               echo ""
               echo "Input has to be a number."
               echo ""
               ((intr++))
               continue
            fi
         kick3=$answer
         break
         done
         if [ $intr -ge 3 ]; then
            exit 0
         fi
         intr=0
         while [ $intr -le 3 ]; do
            echo ""
            echo "What is the length in mm from the top of the extruder coupler to the gears?"
            read -p "[ Enter lenght in mm ] : " -i $togears -e answer
            if [ -z $answer ]; then
               echo ""
               echo "Input cannot be blank."
               echo ""
               ((intr++))
               continue
           elif [[ $answer != ?(-)+([0-9]) ]]; then
               echo ""
               echo "Input has to be a number."
               echo ""
               ((intr++))
               continue
            fi
         togears=$answer
         break
         done
         if [ $intr -ge 3 ]; then
            exit 0
         fi
         intr=0
         while [ $intr -le 3 ]; do
            echo ""
            echo "How many mm is it from extruder gripping the filament to nozzle extrusion?"
            read -p "[ Enter lenght in mm ] : " -i $tonozzle -e answer
            if [ -z $answer ]; then
               echo ""
               echo "Input cannot be blank."
               echo ""
               ((intr++))
               continue
           elif [[ $answer != ?(-)+([0-9]) ]]; then
               echo ""
               echo "Input has to be a number."
               echo ""
               ((intr++))
               continue
            fi
         tonozzle=$answer
         break
         done
         if [ $intr -ge 3 ]; then
            exit 0
         fi

         if [ -f $Start_G_File ]; then
            rm $Start_G_File
         fi
         touch $Start_G_File
         if [ -f $End_G_File ]; then
            rm $End_G_File
         fi
         touch $End_G_File
         if [ -f $Tool_G_File ]; then
            rm $Tool_G_File
         fi
         touch $Tool_G_File
   
         ###################################################################
         ########## Variables collected from gcode gen questions ###########
         ###################################################################

         printer_x_size=$MAXX #max size on X axis
         printer_y_size=$MAXY #max size of Y axis
         init_kickout_0=$kick0 #Kick out from testing of T0
         init_kickout_1=$kick1 #Kick out from testing of T1
         init_kickout_2=$kick2 #Kick out from testing of T2
         init_kickout_3=$kick3 #Kick out from testing of T3
         feed_to_ext=$togears #this is adding load time to button press
         gears_to_nozzle=$tonozzle #this is extruder turning only
         but_ini_loc=$((but_press-3)) #get close to the button ready to press it

         ############ Save questions answers to parm save file ###################

         sed -i '6,14d' $ANS_FILE
         echo "Max printer size X is : $MAXX" | tee -a $ANS_FILE $PARM_SAVE >/dev/null
         echo "Max printer size Y is : $MAXY" | tee -a $ANS_FILE $PARM_SAVE >/dev/null
         echo "Kick out T0 is : $kick0" | tee -a $ANS_FILE $PARM_SAVE >/dev/null
         echo "Kick out T1 is : $kick1" | tee -a $ANS_FILE $PARM_SAVE >/dev/null
         echo "Kick out T2 is : $kick2" | tee -a $ANS_FILE $PARM_SAVE >/dev/null
         echo "Kick out T3 is : $kick3" | tee -a $ANS_FILE $PARM_SAVE >/dev/null
         echo "Top of extruder coupler to gears : $togears" | tee -a $ANS_FILE $PARM_SAVE >/dev/null
         echo "How many mm from gear to hotend to start extruding : $tonozzle" | tee -a $ANS_FILE $PARM_SAVE >/dev/null
         ############### Variables for gcode creation to do all the MATH, depend on all answers provided ###########################

         short_travel=$((fil_start_gap+ext_feed_tube+y_tube_short)) #Top load gap, extruder feed tube and Y pipe, this is the total path
         long_travel=$((fil_start_gap+ext_feed_tube+y_tube_long))
         sec_to_load=$(((long_travel/34)+2))
         fil_feed_rate_0=$(echo "scale=1;($short_travel+$init_kickout_0)/$sec_to_load" | bc ) 
         fil_feed_rate_1=$(echo "scale=1;($long_travel+$init_kickout_1)/$sec_to_load" | bc )
         fil_feed_rate_2=$(echo "scale=1;($long_travel+$init_kickout_2)/$sec_to_load" | bc )
         fil_feed_rate_3=$(echo "scale=1;($short_travel+$init_kickout_3)/$sec_to_load" | bc )
         if [ ext_dd == true ]; then
            coupler_comp=13
            load_to_gear_0=$(echo "scale=1;($feed_to_ext-$coupler_comp)+$short_travel" | bc )
            load_to_gear_1=$(echo "scale=1;($feed_to_ext-$coupler_comp)+$long_travel" | bc )
            load_to_gear_2=$(echo "scale=1;($feed_to_ext-$coupler_comp)+$long_travel" | bc )
            load_to_gear_3=$(echo "scale=1;($feed_to_ext-$coupler_comp)+$short_travel" | bc )
         else
            load_to_gear_0=$(echo "scale=1;$feed_to_ext+$short_travel" | bc )
            load_to_gear_1=$(echo "scale=1;$feed_to_ext+$long_travel" | bc )
            load_to_gear_2=$(echo "scale=1;$feed_to_ext+$long_travel" | bc )
            load_to_gear_3=$(echo "scale=1;$feed_to_ext+$short_travel" | bc )
         fi

         load_sec_0="P"$(echo "scale=2;(($load_to_gear_0/$fil_feed_rate_0)*1000)/1" | bc | sed -E -e 's!(\.[0-9]*[1-9])0*$!\1!' -e 's!(\.0*)$!!' )
         load_sec_1="P"$(echo "scale=2;(($load_to_gear_1/$fil_feed_rate_1)*1000)/1" | bc | sed -E -e 's!(\.[0-9]*[1-9])0*$!\1!' -e 's!(\.0*)$!!' )
         load_sec_2="P"$(echo "scale=2;(($load_to_gear_2/$fil_feed_rate_2)*1000)/1" | bc | sed -E -e 's!(\.[0-9]*[1-9])0*$!\1!' -e 's!(\.0*)$!!' )
         load_sec_3="P"$(echo "scale=2;(($load_to_gear_3/$fil_feed_rate_3)*1000)/1" | bc | sed -E -e 's!(\.[0-9]*[1-9])0*$!\1!' -e 's!(\.0*)$!!' )
         purge_line_start_x=$printer_x_size
         purge_line_start_y=$but_ini_loc
         purge_line_end_x=
         purge_line_end_y=
         extmax=50
         increment=$(($gears_to_nozzle/$extmax))
         incrementP1=$((($gears_to_nozzle/$extmax)+1))
         remainder=$(($gears_to_nozzle%$extmax))
         gears_to_nozzle_speed=F1000

         ############ Save Math variables to parm save file ###################

         echo "Your short travel path is :" $short_travel >> $PARM_SAVE
         echo "Your long travel path is :" $long_travel >> $PARM_SAVE
         echo "Seconds to load based on long path /34+2 :" $sec_to_load >> $PARM_SAVE
         echo "Filament feed rate 0 :" $fil_feed_rate_0 >> $PARM_SAVE
         echo "Filament feed rate 1 :" $fil_feed_rate_1 >> $PARM_SAVE
         echo "Filament feed rate 2 :" $fil_feed_rate_2 >> $PARM_SAVE
         echo "Filament feed rate 3 :" $fil_feed_rate_3 >> $PARM_SAVE
         echo "T0 extra filament length if needed :" $load_to_gear_0 >> $PARM_SAVE
         echo "T1 extra filament length if needed :" $load_to_gear_1 >> $PARM_SAVE
         echo "T2 extra filament length if needed :" $load_to_gear_2 >> $PARM_SAVE
         echo "T3 extra filament length if needed :" $load_to_gear_3 >> $PARM_SAVE
         echo "T0 Total load length /feed rate *1000 /1 :" $load_sec_0 >> $PARM_SAVE
         echo "T1 Total load length /feed rate *1000 /1 :" $load_sec_1 >> $PARM_SAVE
         echo "T2 Total load length /feed rate *1000 /1 :" $load_sec_2 >> $PARM_SAVE
         echo "T3 Total load length /feed rate *1000 /1 :" $load_sec_3 >> $PARM_SAVE
         echo "Purge line for X starts :" $purge_line_start_x >> $PARM_SAVE
         echo "Pruge line for Y starts :" $purge_line_start_y >> $PARM_SAVE

         
   
		   #Start building Start Gcode file
         echo -e ";Copy and paste everything into START gcode window" >> $Start_G_File
         if [[ $firmware == "KLIPPER" ]]; then
            echo "SET_FILAMENT_SENSOR SENSOR=filament_sensor ENABLE=0" >> $Start_G_File
         fi
         if [[ $firmware == "KLIPPER" ]]; then
            echo "START_PRINT EXTRUDER_TEMP=[first_layer_temperature] BED_TEMP=[first_layer_bed_temperature]" >> $Start_G_File
         fi

cat >> $Start_G_File << SGF1
G90 ;absolute mode
M83 ;relitive extrusion mode
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
G4 P2000 ; all done
G0 $but_axis$but_press F2000 ; press button
G4 $load_sec_0 ; wait for Y pipe to extruder load time seconds
G0 $but_axis$but_ini_loc F2000 ; move away from button
M400 ; make sure moves are all done before we load
SGF1
for i in $(seq $increment)   # you can also use {0..9}
do
  echo "G92 E0" >> $Start_G_File
  echo "G0 E"$extmax " $gears_to_nozzle_speed" >> $Start_G_File
done
echo "G92 E0" >> $Start_G_File
echo "G0 E"$remainder " $gears_to_nozzle_speed" >> $Start_G_File

cat >> $Start_G_File << SGF2
G0 X$purge_line_start_x Y$purge_line_start_y Z0.2 F1000; move to extruders assigned purge line
G0 Y0 E50; purge the extruder while moving to Y min.
G0 X$((purge_line_start_x-1)); purge the extruder.
G0 Y$but_ini_loc E50; purge the extruder.
G4 P2000 ; all done
SGF2
      
         if [[ $firmware == "KLIPPER" ]]; then
            echo "SET_FILAMENT_SENSOR SENSOR=filament_sensor ENABLE=1" >> $Start_G_File
         fi

         #Start building END gcode file

         echo -e ";Copy and paste everything into END gcode window" >> $End_G_File
         if [[ $firmware == "KLIPPER" ]]; then
            echo "SET_FILAMENT_SENSOR SENSOR=filament_sensor ENABLE=0" >> $End_G_File
         fi
cat >> $End_G_File << EGF1
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
EGF1
      
         if [[ $firmware == "KLIPPER" ]]; then
            echo "END_PRINT" >> $End_G_File
         fi

         #Start building tool gcode file.

         echo -e ";Copy and paste everything into TOOL CHANGE gcode window" >> $Tool_G_File
cat >> $Tool_G_File << TGF1
{if previous_extruder>-1}
{if next_extruder!=previous_extruder}
TGF1
if [[ $firmware == "KLIPPER" ]]; then
   echo "SET_FILAMENT_SENSOR SENSOR=filament_sensor ENABLE=0" >> $Tool_G_File
fi
cat >> $Tool_G_File << TGF2
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
TGF2

         if [[ $CLI_No_TEMP != "NO_TEMP" ]]; then
cat >> $Tool_G_File << TGF3
M106 S125
M109 R180; cool down to prevent swelling
G0 E24 F1500 ; last tip dip with cold tip
G0 E-24 F500 ; last tip dip with cold tip
M109 R150; cool down to prevent swelling
M109 S180; ok... go back up in temp so we can move the extruder
TGF3

for i in $(seq $incrementP1)   # you can also use {0..9}
do
  echo "G92 E0" >> $Tool_G_File
  echo "G0 E-"$extmax " $gears_to_nozzle_speed" >> $Tool_G_File
done
echo "G92 E0" >> $Tool_G_File
echo "G0 E-"$remainder " $gears_to_nozzle_speed" >> $Tool_G_File

cat >> $Tool_G_File << TGF4
M400 ; Wait for extruder to backout
M107 ;
M104 S[temperature];
TGF4
         else
             echo ";NO TEMP SET" >> $Tool_G_File
         fi

cat >> $Tool_G_File << TGF5
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
G4 P400
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
TGF5

for i in $(seq $increment)   # you can also use {0..9}
do
  echo "G92 E0" >> $Tool_G_File
  echo "G0 E"$extmax " $gears_to_nozzle_speed" >> $Tool_G_File
done
echo "G92 E0" >> $Tool_G_File
echo "G0 E"$remainder " $gears_to_nozzle_speed" >> $Tool_G_File

cat >> $Tool_G_File << TGF6
G4 P400
G92 E0
M104 S[temperature];
M106 S125;
TGF6
         if [[ $firmware == "KLIPPER" ]]; then
            echo "SET_FILAMENT_SENSOR SENSOR=filament_sensor ENABLE=1" >> $Tool_G_File
         fi
cat >> $Tool_G_File << TGF7
G90 ; move to absolute mode
M83
{endif}
{endif}
TGF7

         #clear
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
         find $PARM_SAVE -type f -mtime +7 -name 'PARM*.*' -execdir rm -- '{}' \; #remove any parms files older than 7 days
      else
         echo -e "Testing data isn't complete, please restart the script and answer NO"
      fi
   else
      echo -e "No testing data was found, please restart the script and answer NO"
      exit 0
   fi

   ################### TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING################################
   ################### TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING################################
   ################### TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING################################
   ################### TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING################################
   ################### TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING################################
   ################### TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING################################
   ################### TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING################################
   ################### TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING################################
   ################### TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING TESTING################################

else
   if [ -f $ANS_FILE ]; then #Clean up answer file
      rm $ANS_FILE
   fi
   
      # Start answer file and parm save file
      touch $ANS_FILE
      touch $PARM_SAVE

   ##############################################   
   ########## START OF TESTING QUESTIONS ##########
   ##############################################


   echo "What firmware are you using?"
   read -p  "[PRUSA,MARLIN,KLIPPER]" firmware
   USER_ANS1=$(echo "${firmware^^}")
   if [ -z "$USER_ANS1" ]; then
      echo ""
      echo "Input cannot be blank."
      echo ""
      exit 0
   fi

   if  [[ "$USER_ANS1" != "KLIPPER" && "$USER_ANS1" != "MARLIN" && "$USER_ANS1" != "PRUSA" ]]; then
      echo "Input has to be KLIPPER PRUSA or MARLIN."
      exit 0
   fi
   
   echo "What axis is your Chameleon button on?"
   read -p "[X or Y]" axis
   USER_ANS2=$(echo "${axis^^}")
   if [ -z "$USER_ANS2" ]; then
      echo ""
      echo "Input cannot be blank."
      echo ""
      exit 0
   fi

   if  [[ "$USER_ANS2" != "X" && "$USER_ANS2" != "Y" ]]; then
      echo "Input has to be X or Y."
      exit 0
   fi


   echo "Where do we have go on the $but_axis axis to click the Chameleon button [in mm]?"
   read -p "[ mm ]" press
   if [ -z "$press" ]; then
      echo ""
      echo "Input cannot be blank."
      echo ""
      exit 0
   fi

   if [[ "$press" != ?(-)+([0-9]) ]]; then
      echo ""
      echo "Input has to be a number."
      echo ""
      exit 0
   fi
   
   echo "What is your filament loading gap in mm? [amount above Y pipe when starting, recommend 25mm]"
   read -p "[mm]" gap
   if [ -z "$gap" ]; then
      echo ""
      echo "Input cannot be blank."
      echo ""
      exit 0
   fi

   if  [[ "$gap" != ?(-)+([0-9]) ]]; then
      echo ""
      echo "Input has to be a number."
      echo ""
      exit 0
   fi
   
   echo "What is the lenght of the tube from the Y pipe to the extruder in mm?"
   read -p "[mm]" etube
   if [ -z "$etube" ]; then
      echo ""
      echo "Input cannot be blank."
      echo ""
      exit 0
   fi

   if [[ "$etube" != ?(-)+([0-9]) ]]; then
      echo ""
      echo "Input has to be a number."
      echo ""
      exit 0
   fi
   
   
 
   #Variables gathered from testing questions
   firmware=$USER_ANS1 #What firmware you are using
   but_axis=$USER_ANS2 #What Axis is your button installed on
   but_press=$press #Where do you have to go to push the button
   but_ini_loc=$((but_press-3)) #get close to the button ready to press it
   fil_start_gap=$gap #How far above the Y pipe is you filament start posistion
   ext_feed_tube=$etube #The lenth of the tube to feed extruder measued from black ring on coupler 
      
   #Send all the setting gathered from questions to answer file for Gcode creation and to answer save file.
   echo "Your firmware is :$firmware" | tee -a $ANS_FILE $PARM_SAVE >/dev/null
   echo "Your button axis is:$but_axis" | tee -a $ANS_FILE $PARM_SAVE >/dev/null
   echo "You have to go to $but_press on the $but_axis to press the Chameleon button :$but_press" | tee -a $ANS_FILE $PARM_SAVE >/dev/null
   echo "Your filament starting gap is :$fil_start_gap" | tee -a $ANS_FILE $PARM_SAVE >/dev/null
   echo "Your PTFE tube above the extruder is  :$ext_feed_tube" | tee -a $ANS_FILE $PARM_SAVE >/dev/null
   
   ##############################################   
   ########## END OF TESTING QUESTIONS ##########
   ##############################################

   ########################################   
   #Variables to be set for test gcode only
   ########################################

   long_travel=$((fil_start_gap+ext_feed_tube+y_tube_long))
   mili_sec_load="P"$((((long_travel/34)+2)*1000))

   #Save the variables to save file
   echo "Long travel test" $long_travel >> $PARM_SAVE
   echo "Mili Sec Load" $mili_sec_load >> $PARM_SAVE


   if [ -f $Rate4_Test_G_File ]; then #Clean up gcode test file
      rm $Rate4_Test_G_File
   fi

cat >> $Rate4_Test_G_File << TGF1
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
TGF1

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
#!/bin/bash

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BASE_DIR="iain_ferguson_week3_hw_$(date +%Y%m%d_%H%M%S)"


# Helper Functions

log_info () {
    echo "[$(date '+%Y-%m-%d %H:%M:%S.%2N')] $1"
}

reset_to_root_dir () {
    cd $ROOT_DIR/$BASE_DIR/
}

# End Helper Functions


# Setup all the folder structure and starting files.
mkdir $BASE_DIR
cd $BASE_DIR

log_info 'Setting up the working folder structure.'

mkdir Lucky_Duck_Investigations
cd Lucky_Duck_Investigations/
mkdir Roulette_Loss_Investigation
cd Roulette_Loss_Investigation/
mkdir Player_Analysis
mkdir Dealer_Analysis
mkdir Player_Dealer_Correlation
touch Player_Dealer_Correlation/Notes_Player_Dealer_Correlation
touch Player_Analysis/Notes_Player_Analysis
touch Dealer_Analysis/Notes_Dealer_Analysis


log_info 'Downloading the casino logs...'

reset_to_root_dir

wget -q "https://tinyurl.com/3-HW-setup-evidence" && chmod +x ./3-HW-setup-evidence && ./3-HW-setup-evidence


log_info 'Removing the 3-HW-setup-evidence script now that all the log files have been generated'
rm 3-HW-setup-evidence

log_info 'Sectioning off the logs we are interested in from March 10, 12 & 15'

reset_to_root_dir

cd Dealer_Schedules_0310
mv 0310_Dealer_schedule ../Lucky_Duck_Investigations/Roulette_Loss_Investigation/Dealer_Analysis/
mv 0312_Dealer_schedule ../Lucky_Duck_Investigations/Roulette_Loss_Investigation/Dealer_Analysis/
mv 0315_Dealer_schedule ../Lucky_Duck_Investigations/Roulette_Loss_Investigation/Dealer_Analysis/

reset_to_root_dir
cd Roulette_Player_WinLoss_0310
mv 0310_win_loss_player_data ../Lucky_Duck_Investigations/Roulette_Loss_Investigation/Player_Analysis/
mv 0312_win_loss_player_data ../Lucky_Duck_Investigations/Roulette_Loss_Investigation/Player_Analysis/
mv 0315_win_loss_player_data ../Lucky_Duck_Investigations/Roulette_Loss_Investigation/Player_Analysis/


# start the investigations

log_info 'Starting the player analysis'

reset_to_root_dir

cd Lucky_Duck_Investigations/Roulette_Loss_Investigation/Player_Analysis
grep '\-\$' * > Roulette_Losses

printf "Below lists out the times each day losses occurred\n\n" >> Notes_Player_Analysis
printf "%-5s %s\n" "Date" "Time" >> Notes_Player_Analysis
grep -Po '((\d){4})_win_loss_player_data:(\d){2}:(\d){2}:(\d){2}.((AM)|(PM))' Roulette_Losses | sed 's/_win_loss_player_data:/  /' >> Notes_Player_Analysis
printf "\n\n\n" >> Notes_Player_Analysis

printf "Formatting up all the names so its easier to read\n\n" >> Notes_Player_Analysis

# Not the most efficient way and wouldn't be practical on extremely large files so if that the case RegEx would play a bigger role to clean up the formatting
sed 's/,  /,/g' Roulette_Losses | sed 's/, /,/g' | sed 's/ ,/,/g' | sed 's/,/~/g' |sed 's/ AM/(AM)/g' | sed 's/ PM/(PM)/g' | sed 's/\t/~/g' | sed 's/        /~/g' | sed 's/ -/~-/g' | sed 's/_win_loss_player_data:/ /g' | awk -F~ '{{printf "%s   ", $1}; for(i=4;i<=NF;i++){printf "%-20s ", $i}; printf "\n"}' >> Notes_Player_Analysis


printf '\n\nThe top 10 players across all the occasions where losses occured:\n\n' >> Notes_Player_Analysis
sed -E 's/.*\-\$[0-9]*,[0-9]*\w//' Roulette_Losses | sed -E 's/\s*,\s*/,/g' | sed 's/  //g' | sed 's/\t//g' | grep -oE '(\w* \w*)' | sort | uniq -c | sort -nr | head -10 >> Notes_Player_Analysis

printf "\nFrom this we can see that 'Mylie Schmidt' was the most active player by far and a manual review shows Mylie playing each time there was a loss.\n\n" >> Notes_Player_Analysis


# How many times has Mylie Schmidt played
printf "'Mylie Schmidt' played a total of %s times over March 10, 12 & 15 of which %s occasions were when Lucky Duck Casino incurred losses.\n\n", $(grep "Mylie Schmidt" 03* | wc -l) $(grep "Mylie Schmidt" 03* | grep '\-\$' | wc -l) >> Notes_Player_Analysis



# Start the Dealer analysis
log_info 'Starting the Dealer analysis'

reset_to_root_dir

cd Lucky_Duck_Investigations/Roulette_Loss_Investigation/Dealer_Analysis

grep "05:00:00 AM" 0310* | awk '{ printf "%-s %-20s %s %s (0310)\n",$5, $6,$1, $2 }' >> Dealers_working_during_losses
grep "08:00:00 AM" 0310* | awk '{ printf "%-s %-20s %s %s (0310)\n",$5, $6,$1, $2 }' >> Dealers_working_during_losses
grep "02:00:00 PM" 0310* | awk '{ printf "%-s %-20s %s %s (0310)\n",$5, $6,$1, $2 }' >> Dealers_working_during_losses
grep "08:00:00 PM" 0310* | awk '{ printf "%-s %-20s %s %s (0310)\n",$5, $6,$1, $2 }' >> Dealers_working_during_losses
grep "11:00:00 PM" 0310* | awk '{ printf "%-s %-20s %s %s (0310)\n",$5, $6,$1, $2 }' >> Dealers_working_during_losses

grep "05:00:00 AM" 0312* | awk '{ printf "%-s %-20s %s %s (0312)\n",$5, $6,$1, $2 }' >> Dealers_working_during_losses
grep "08:00:00 AM" 0312* | awk '{ printf "%-s %-20s %s %s (0312)\n",$5, $6,$1, $2 }' >> Dealers_working_during_losses
grep "02:00:00 PM" 0312* | awk '{ printf "%-s %-20s %s %s (0312)\n",$5, $6,$1, $2 }' >> Dealers_working_during_losses
grep "08:00:00 PM" 0312* | awk '{ printf "%-s %-20s %s %s (0312)\n",$5, $6,$1, $2 }' >> Dealers_working_during_losses
grep "11:00:00 PM" 0312* | awk '{ printf "%-s %-20s %s %s (0312)\n",$5, $6,$1, $2 }' >> Dealers_working_during_losses

grep "05:00:00 AM" 0315* | awk '{ printf "%-s %-20s %s %s (0315)\n",$5, $6,$1, $2 }' >> Dealers_working_during_losses
grep "08:00:00 AM" 0315* | awk '{ printf "%-s %-20s %s %s (0315)\n",$5, $6,$1, $2 }' >> Dealers_working_during_losses
grep "02:00:00 PM" 0315* | awk '{ printf "%-s %-20s %s %s (0315)\n",$5, $6,$1, $2 }' >> Dealers_working_during_losses


printf "From the dealer schedules we can see that 'Billy Jones' was working at the roulette table every time a loss was occurred\n" >> Notes_Dealer_Analysis
printf "There were %s occasions when Billy Jones was working and losses occurred.\n\n", $(wc -l <  Dealers_working_during_losses) >> Notes_Dealer_Analysis


# Reviewing the Correlation

log_info 'Reviewing the player -> dealer correlation'

reset_to_root_dir
cd Lucky_Duck_Investigations/Roulette_Loss_Investigation/Player_Dealer_Correlation

cat <<EOF > Notes_Player_Dealer_Correlation
Finding Summary
--------------------
After reviewing the logs for all losses occurred from March 10, 12 & 15 at the roulette table we can conclude that:

There were losses that occurred on the following dates and times:

Date  Time
0310  05:00:00 AM
0310  08:00:00 AM
0310  02:00:00 PM
0310  08:00:00 PM
0310  11:00:00 PM
0312  05:00:00 AM
0312  08:00:00 AM
0312  02:00:00 PM
0312  08:00:00 PM
0312  11:00:00 PM
0315  05:00:00 AM
0315  08:00:00 AM
0315  02:00:00 PM
 
The player Mylie Schmidt was at the roulette table 13 times when a loss was occurred.

From the dealer schedule we can see that Billy Jones was working at the roulette table at the time losses occurred and Mylie Schmidt was playing.

Billy Jones                05:00:00 AM (0310)
Billy Jones                08:00:00 AM (0310)
Billy Jones                02:00:00 PM (0310)
Billy Jones                08:00:00 PM (0310)
Billy Jones                11:00:00 PM (0310)
Billy Jones                05:00:00 AM (0312)
Billy Jones                08:00:00 AM (0312)
Billy Jones                02:00:00 PM (0312)
Billy Jones                08:00:00 PM (0312)
Billy Jones                11:00:00 PM (0312)
Billy Jones                05:00:00 AM (0315)
Billy Jones                08:00:00 AM (0315)
Billy Jones                02:00:00 PM (0315)


The log files strongly indicate that Billy Jones was colluding with Mylie Schmidt on 13 separate occasions to scam Lucky Duck Casino our of thousands of dollars. 

There were 6 other occasions where Mylie Schmidt was playing at the roulette table however during these times Billy Jones was not the dealer and Mylie Schmidt did not win.  This casts additional suspicion that Mylie and Billy were working together to scam Lucky Duck Casino. 

EOF


# Step 4

log_info 'Creating the dealer analysis helper script.'

reset_to_root_dir
cd Lucky_Duck_Investigations/Roulette_Loss_Investigation/Dealer_Analysis

cat <<EOF > roulette_dealer_finder_by_time.sh
#!/bin/bash

TIME_STAMP="\$(echo "\$1" |sed 's/a.m./AM/' | sed 's/p.m./PM/')"
FILE_NAME="../Dealer_Analysis/\$2_Dealer_schedule"

printf "\\n================================\\nEmployee Schedule Analyser\\n================================\\n\\n"


# Run some checks to make sure we got the arguments we need

if [ \$# -eq 0 ]
  then
    echo "No arguments supplied.  Expected format is:"
    echo "      ./roulette_dealer_finder_by_time.sh [TimeStamp] [Date]"
    echo "For Example:"
    echo '      ./roulette_dealer_finder_by_time.sh "12:00:00 AM" "0310"'
fi


if test -f "\$FILE_NAME"; then
    echo "Checking the log file '\$FILE_NAME' for Roulette dealers working schedules"
else
    echo "Ether there are no logs available for the date '\$2' or the date format is incorrect."
    echo "The date should be entered in the format MMDD"
    exit
fi


if [[ "\$TIME_STAMP" == *"AM" ]] || [[ "\$TIME_STAMP" == *"PM" ]]; then
    echo "For the time: \$TIME_STAMP"
    echo ""
else
    echo "Time stamp '\$TIME_STAMP' does not include AM or PM"
    echo "The correct format is HH:MM:ss a"
    echo "For Example:"
    echo '       ./roulette_dealer_finder_by_time.sh "12:00:00 AM" "0310"'
    exit
fi

# Get the dealer scheduled to work for the inputted time from the selected days logs.

grep "\$TIME_STAMP" "\$FILE_NAME" | awk '{ printf "%-s %-20s %s %s\\n", \$5, \$6, \$1, \$2 }'

EOF

chmod +x roulette_dealer_finder_by_time.sh


# Bonus Script

log_info 'Creating bonus script'

reset_to_root_dir
cd Lucky_Duck_Investigations/Roulette_Loss_Investigation/Player_Dealer_Correlation

cat <<EOF > roulette_dealer_finder_by_time_and_game.sh
#!/bin/bash

TIME_STAMP="\$1"
FILE_DATE="\$2"
FILE_NAME="../Dealer_Analysis/\${FILE_DATE}_Dealer_schedule" # For now we will just assume that the script and the logs are always in this folder structure. Could extend out to include the log path at a later date.
GAME_NAME="\$3"

printf "\\n====================================\\nEmployee Schedule Analyser by Game\\n====================================\\n\\n"


# Run some checks to make sure we got the arguments we need

if [ \$# -eq 0 ]
  then
    echo "No arguments supplied.  Expected format is:"
    echo "      ./roulette_dealer_finder_by_time_and_game.sh [TimeStamp] [Date] [game]"
    echo "For Example:"
    echo '      ./roulette_dealer_finder_by_time_and_game.sh "12:00:00 AM" "0310" "BlackJack"'
    echo 'Game options are:'
    echo '      BlackJack, Roulette, Texas'
fi


if test -f "\$FILE_NAME"; then
    echo "Checking the log file '\$FILE_NAME' for dealers working schedules"
else
    echo "Ether there are no logs available for the date '\$FILE_DATE' or the date formatt is incorrect."
    echo "The date should be entered in the format MMDD"
    exit
fi


if [[ "\$TIME_STAMP" == *"AM" ]] || [[ "\$TIME_STAMP" == *"PM" ]]; then
    echo "For the time: \$TIME_STAMP"
else
    echo "Time stamp '\$TIME_STAMP' does not include AM or PM"
    echo "The correct format is HH:MM:ss a"
    echo "For Example:"
    echo '       ./roulette_dealer_finder_by_time_and_game.sh "12:00:00 AM" "0310" "BlackJack"'
    exit
fi

if [ -z \$GAME_NAME ]; then

    echo 'No Game has been listed'
    echo 'Enter a valid game type for BlackJack, Roulette, Texas'
    echo 'For Example:'
    echo '       ./roulette_dealer_finder_by_time_and_game.sh "12:00:00 AM" "0310" "BlackJack"'
    exit
else
    case \$GAME_NAME in
            BlackJack)
                    echo "Looking for BlackJack Dealers"
                    COLUMN_FIRSTNAME=3
                    COLUMN_LASTNAME=4
                    ;;
            Roulette)
                    echo "Looking for Roulette Dealers"
                    COLUMN_FIRSTNAME=5
                    COLUMN_LASTNAME=6
                    ;;
            Texas)
                    echo "Looking for Texas Hold EM Dealers"
                    COLUMN_FIRSTNAME=7
                    COLUMN_LASTNAME=8
                    ;;
            *)
                    echo "\$GAME_NAME is not a valid game."
                    echo "Select from BlackJack, Roulette, Texas"
                    exit
                    ;;
    esac
fi

printf "\\n%-35s %s\\n" "Dealer Name" "Time (Date)"

grep "\$TIME_STAMP" "\$FILE_NAME" | awk -v c1=\$COLUMN_FIRSTNAME -v c2=\$COLUMN_LASTNAME -v fd=\$FILE_DATE '{ printf "%s %-20s %s %s (%s)\\n",\$c1, \$c2, \$1, \$2, fd }'


EOF

chmod +x roulette_dealer_finder_by_time_and_game.sh


#Moving all the investigation files to final folder

log_info 'Moving all the investigation files into Player_Dealer_Correlation'

reset_to_root_dir

mv Lucky_Duck_Investigations/Roulette_Loss_Investigation/Dealer_Analysis/Notes_Dealer_Analysis Lucky_Duck_Investigations/Roulette_Loss_Investigation/Player_Dealer_Correlation/
mv Lucky_Duck_Investigations/Roulette_Loss_Investigation/Dealer_Analysis/Dealers_working_during_losses Lucky_Duck_Investigations/Roulette_Loss_Investigation/Player_Dealer_Correlation/
mv Lucky_Duck_Investigations/Roulette_Loss_Investigation/Dealer_Analysis/roulette_dealer_finder_by_time.sh Lucky_Duck_Investigations/Roulette_Loss_Investigation/Player_Dealer_Correlation/

mv Lucky_Duck_Investigations/Roulette_Loss_Investigation/Player_Analysis/Notes_Player_Analysis Lucky_Duck_Investigations/Roulette_Loss_Investigation/Player_Dealer_Correlation/
mv Lucky_Duck_Investigations/Roulette_Loss_Investigation/Player_Analysis/Roulette_Losses Lucky_Duck_Investigations/Roulette_Loss_Investigation/Player_Dealer_Correlation/




#Package everything up.

log_info 'Zipping up the Player_Dealer_Correlations folder'
reset_to_root_dir
cd Lucky_Duck_Investigations/Roulette_Loss_Investigation/Player_Dealer_Correlation/
zip Iain_Ferguson_Player_Dealer_Correlation.zip *



# Finish up

log_info 'Changing Directory to the Player_Dealer_Correlation so you can review the work'
reset_to_root_dir
cd Lucky_Duck_Investigations/Roulette_Loss_Investigation/Player_Dealer_Correlation/


#Done
log_info 'All done.  Have a nice day.'

printf "\n\n\n"
ls -l
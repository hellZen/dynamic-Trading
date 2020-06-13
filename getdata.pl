#!/usr/bin/perl
use CGI qw(:standard);

# Perform DeMark analysis on daily equity data given a ticker-ID 

print header;   # Tell perl to send a html header.
     		# So your browser gets the output
     		# rather then <stdout>(command line
     		# on the server.)

# Initialize some Variables for later#################################################
######################################################################################
my $BullFlip=0;         #Signal for downward trend reversal
my $BearFlip=0;         #Signal for Upward   trend reversal
my $Countdown=0;        #Length of signalling trend is nine
my $Reference=0;        #?????????????
my $Support=0;
#my $time2 = time();	#load the start time for execution usage timing
my $time2 = `date +%s%N`; # Returns ssssssssss.uuuuuu in scalar context

$m=`date '+%m-%d-%Y'| cut -d - -f1`;    #Run-date -mm
$d=`date '+%m-%d-%Y'| cut -d - -f2`;    #Run-date -dd
$y=`date '+%m-%d-%Y'| cut -d - -f3`;    #Run-date -yyyy
$ly=$y-2;                               #current year minus two  - Check this 
#####################################################################################

&getparms;	# load the parameters supplied on the URL 
		# These are in the form pp=<value>
		# Valid values are $<URL>/cgi-bin/getdata.pl?ID=<ticker>
		#Default ticker - AKAM
#####################################################################################

&print_table_header; 	# Print content tags &  header lines with links etc
##################################################################################

&gethistorydata;
# Issue html request to data source returns data in dat.txt
# Strip out datalines that dont contain numbers
#  this is a really dumb way to strip the header
#  cleverness in programming can be an expensive conceit
`cat dat.txt | grep [0-9] > dat2.txt`;
#`awk -F "," '{print $1\",\"$2\",\"$3\",\"$4\",\"$5\",\"$6\",\"$7}' dat2.txt > dat4.txt`;
#OPEN files handles for perl access
open(HISTORY, '<dat.txt');
open(H2, '<dat2.txt');
open(H3, '>dat3.txt');
$hdr = "Date,Open,High,Low,Close,Volume,Adj Close";


###CRITICAL###################################################
# daily data stream needs to be reversed for processing
#- source data comes with oldest data in line 1
#  analysis needs to look back to previous data to determine trend reversal
#########################################################################
my(@lines) = <H2>;     #Read file into ARRAY (list of lines) for stats and printing
@lines = sort(@lines); # reverse Order as oldest first for calculations
my $limit = @lines;    # extract number of entries
print  "<br>$limit days of data  - $wget_length - bytes  Returned from provider";




# Print 50 Day Summary stats....
##########################################################################################


my($N)=50;    #Figure 50 Day stats
$switch=1;    #First Iteration indicator

for ($i=$limit-1; $i>=$limit-$N; $i--)
 {
 	$line = $lines[$i]; # pull current values from array
	 chomp($line); # Good practice to always strip the trailing newline.
	# separate all the data items into vars for calc and formatting
	# my($xDate,$xOpen,$xHigh,$xLow,$xClose,$xVol,$xCrapola) = split(/,/, $line);
	($xDate,$xOpen,$xHigh,$xLow,$xClose,$xAdjClose,$xVol,$xdividend,$xsplit_coefficient) = split(/,/, $line);

	   if ( $switch == 0 )  
	   	{ 
		  #print "<br>$switch $i $line  *";     #DEBUG
          	  if ( ($xLow)  < ($xMin)) { $xMin = $xLow };  #Note $xLOW is INTRADAY LOW
		  if ( ($xHigh) > ($xMax)) { $xMax = $xHigh };  #Note $xHigh is INTRADAY High
		  $AccVol=$xVol+$AccVol;        # accumulate Volume for  SMA
		  $AccClose=$xClose+$AccClose;  # accumulate Close price for  SMA
		  $AccRange=$AccRange+($xHigh-$xLow);
		  $AccLC=$AccLC+($xClose-$xLow);

		}
   	  else
		{
		  #print "<br>$switch $i $line";     #DEBUG
		  #initialize min,max, last close on first iteration
		  $xMin = $xLow; 
		  $xMax = $xHigh; 
		  $Last = $xClose;  
		  my($AccVol)=0; my($AccClose)=0; my($AccRange)=0; my($AccLC)=0; 
		  $switch=0;   #Turn this code off for rest of loop
			
		}

 }
$AccVol=$AccVol/$N; 
$AccClose=$AccClose/$N; 
$AccRange=$AccRange/$N; 
$AccLC=$AccLC/$N;
$range=$xMax - $xMin;
$cur=$Last - $xMin; 
$pct=$Last/$xMax; $pct=$pct*100;

$format=("<tr><td>%01.0f</td><td>%01.2f</td><td>%01.2f</td><td>%01.2f</td><td>%01.2f</td><td>%01.0f</td><td>%01.2f</td><td>%01.2f</td></tr>");
$LINEOUT1=sprintf($format, $N, $AccClose,$pct,$xMin,$xMax,$AccVol,$AccRange,$AccLC);


my $limit = @lines;    # extract number of entries
if ($limit > 100 ) {
# Print 100 Day Summary stats....
##########################################################################################
my($N)=100;   #Figure 50 Day stats
$switch=1;    #First Iteration indicator
for ($i=$limit-1; $i>=$limit-$N; $i--)
 {
 	$line = $lines[$i]; # pull current values from array
	 chomp($line); # Good practice to always strip the trailing newline.
	# separate all the data items into vars for calc and formatting
	# my($xDate,$xOpen,$xHigh,$xLow,$xClose,$xVol,$xCrapola) = split(/,/, $line);
	($xDate,$xOpen,$xHigh,$xLow,$xClose,$xAdjClose,$xVol,$xdividend,$xsplit_coefficient) = split(/,/, $line);

	   if ( $switch == 0 )  
	   	{ 
		  #print "<br>$switch $i $line  *";     #DEBUG
          	  if ( ($xLow)  < ($xMin)) { $xMin = $xLow };  #Note $xLOW is INTRADAY LOW
		  if ( ($xHigh) > ($xMax)) { $xMax = $xHigh };  #Note $xHigh is INTRADAY High
		  $AccVol=$xVol+$AccVol;        # accumulate Volume for  SMA
		  $AccClose=$xClose+$AccClose;  # accumulate Close price for  SMA
		  $AccRange=$AccRange+($xHigh-$xLow);
		  $AccLC=$AccLC+($xClose-$xLow);

		}
   	  else
		{
		  #print "<br>$switch $i $line";     #DEBUG
		  #initialize min,max, last close on first iteration
		  $xMin = $xLow; 
		  $xMax = $xHigh; 
		  $Last = $xClose;  
		  my($AccVol)=0; my($AccClose)=0; my($AccRange)=0; my($AccLC)=0; 
		  $switch=0;   #Turn this code off for rest of loop
			
		}

 }
$AccVol=$AccVol/$N;
$AccClose=$AccClose/$N; 
$AccRange=$AccRange/$N; 
$AccLC=$AccLC/$N;
$range=$xMax - $xMin;
$cur=$Last - $xMin; 
$pct=$Last/$xMax; $pct=$pct*100;

$format=("<tr><td>%01.0f</td><td>%01.2f</td><td>%01.2f</td><td>%01.2f</td><td>%01.2f</td><td>%01.0f</td><td>%01.2f</td><td>%01.2f</td></tr>");
$LINEOUT2=sprintf($format, $N, $AccClose,$pct,$xMin,$xMax,$AccVol,$AccRange,$AccLC);

}  # End of 100 day If


my $limit = @lines;    # extract number of entries
if ($limit > 200 ) {
# Print 200 Day Summary stats....
##########################################################################################
my($N)=200;   #Figure 200 Day stats
$switch=1;    #First Iteration indicator
for ($i=$limit-1; $i>=$limit-$N; $i--)
 {
 	$line = $lines[$i]; # pull current values from array
	 chomp($line); # Good practice to always strip the trailing newline.
	# separate all the data items into vars for calc and formatting
	# my($xDate,$xOpen,$xHigh,$xLow,$xClose,$xVol,$xCrapola) = split(/,/, $line);
	($xDate,$xOpen,$xHigh,$xLow,$xClose,$xAdjClose,$xVol,$xdividend,$xsplit_coefficient) = split(/,/, $line);

	   if ( $switch == 0 )  
	   	{ 
		  #print "<br>$switch $i $line  *";     #DEBUG
           	  if ( ($xLow)  < ($xMin)) { $xMin = $xLow };  #Note $xLOW is INTRADAY LOW
		  if ( ($xHigh) > ($xMax)) { $xMax = $xHigh };  #Note $xHigh is INTRADAY High
		  $AccVol=$xVol+$AccVol;        # accumulate Volume for  SMA
		  $AccClose=$xClose+$AccClose;  # accumulate Close price for  SMA
		  $AccRange=$AccRange+($xHigh-$xLow);
		  $AccLC=$AccLC+($xClose-$xLow);

		}
   	  else
		{
		  #print "<br>$switch $i $line";     #DEBUG
		  #initialize min,max, last close on first iteration
		  $xMin = $xLow; 
		  $xMax = $xHigh; 
		  $Last = $xClose;  
		  my($AccVol)=0; my($AccClose)=0; my($AccRange)=0; my($AccLC)=0; 
		  $switch=0;   #Turn this code off for rest of loop
			
		}

 }
$AccClose=$AccClose/$N; 
$AccRange=$AccRange/$N; 
$AccLC=$AccLC/$N;
$range=$xMax - $xMin;
$cur=$Last - $xMin; 
$pct=$Last/$xMax; $pct=$pct*100;

$format=("<tr><td>%01.0f</td><td>%01.2f</td><td>%01.2f</td><td>%01.2f</td><td>%01.2f</td><td>%01.0f</td><td>%01.2f</td><td>%01.2f</td></tr>");
$LINEOUT3=sprintf($format, $N, $AccClose,$pct,$xMin,$xMax,$AccVol,$AccRange,$AccLC);

}  # End of 200 day If

my $limit = @lines;    # extract number of entries
if ($limit > 260 ) {
# Print 200 Day Summary stats....
##########################################################################################
my($N)=260;   #Figure 260 Day stats
$switch=1;    #First Iteration indicator
for ($i=$limit-1; $i>=$limit-$N; $i--)
 {
 	$line = $lines[$i]; # pull current values from array
	 chomp($line); # Good practice to always strip the trailing newline.
	# separate all the data items into vars for calc and formatting
	# my($xDate,$xOpen,$xHigh,$xLow,$xClose,$xVol,$xCrapola) = split(/,/, $line);
	($xDate,$xOpen,$xHigh,$xLow,$xClose,$xAdjClose,$xVol,$xdividend,$xsplit_coefficient) = split(/,/, $line);

	   if ( $switch == 0 )  
	   	{ 
		  #print "<br>$switch $i $line  *";     #DEBUG
           	  if ( ($xLow)  < ($xMin)) { $xMin = $xLow };  #Note $xLOW is INTRADAY LOW
		  if ( ($xHigh) > ($xMax)) { $xMax = $xHigh };  #Note $xHigh is INTRADAY High
		  $AccVol=$xVol+$AccVol;        # accumulate Volume for  SMA
		  $AccClose=$xClose+$AccClose;  # accumulate Close price for  SMA
		  $AccRange=$AccRange+($xHigh-$xLow);
		  $AccLC=$AccLC+($xClose-$xLow);

		}
   	  else
		{
		  #print "<br>$switch $i $line";     #DEBUG
		  #initialize min,max, last close on first iteration
		  $xMin = $xLow; 
		  $xMax = $xHigh; 
		  $Last = $xClose;  
		  my($AccVol)=0; my($AccClose)=0; my($AccRange)=0; my($AccLC)=0; 
		  $switch=0;   #Turn this code off for rest of loop
			
		}

 }
$AccClose=$AccClose/$N; 
$AccRange=$AccRange/$N; 
$AccLC=$AccLC/$N;
$range=$xMax - $xMin;
$cur=$Last - $xMin; 
$pct=$Last/$xMax; $pct=$pct*100;

$format=("<tr><td>%01.0f</td><td>%01.2f</td><td>%01.2f</td><td>%01.2f</td><td>%01.2f</td><td>%01.0f</td><td>%01.2f</td><td>%01.2f</td></tr>");
$LINEOUT4=sprintf($format, $N, $AccClose,$pct,$xMin,$xMax,$AccVol,$AccRange,$AccLC);

}  # End of 260 day If


#OUTPUT: Print header for 50-100-200 day price and volume table
###########################################################################################
print "<table border=1>";
print "<tr>
  <td>Days</td>
  <td>AvgClose</td>
<td>\% of Range</td>
<td>xMin</td>
<td>xMax</td>
  <td>AvgVolume</td>
  <td>Avg Day Range</td>
  <td>Avg L to C</td></tr>";
print $LINEOUT1;
print $LINEOUT2;
if ($limit > 200 )  {
		print $LINEOUT3;  
		}
if ($limit > 260 )  {
		print $LINEOUT4;  
		}
#Close the Summary Stats Table
print "</table>";


######################################################################
# Start of Daily data and Demark Analysis
#####################################################################
# Print Detail Stats
#print " Limit $limit";
#OUTPUT:Print Detail Table Header
print "<table border=1>\n ";
$HDR  = "<tr><td>Date</td>
	<td>Open</td><td>High</td>
	<td title='Low for the day'>Low</td>
	<td>Close</td><td>Volume</td>
	<td>Rel_Vol</td>
	<td>Change</td><td>15SMA</td>
	<td>50SMA</td>
	<td>Pop</td>
	<td>Gap</td><td>Range</td>
	<td>LC</td>
	<td>Candle</td>
	<td>DeMark Signal Activity</td>
	</tr>";
print "$HDR<br>\n";

###############################################################################################
# BIG Loop Starts here  Printing out one row per data line
#    Note that since the data has to be scanned oldest first,
#     the table code has to be stacked then printed in reverse order.
#     THIS IS ONLY DONE BEACAUSE I DECIDED THE RECENT SIGNAL
#     SHOULD BE AT THE TOP OF THE TABLE RATHER THAN THE BOTTOM
#      this seemed like a good idea becauwe I was pulling all avalable data 
#      and it seemed like a bad Idea to go thru 10 years of data to see your signal at the end.
######################################################################################********
for ($i=0; $i < $limit; $i++)
 	{
	  # Good practice to store $_ value because # subsequent operations may change it.
  	  # my($line) = $_;
  	  # Good practice to always strip the trailing # newline from the line.
	  $line = $lines[$i];
 	  chomp($line);
 	  #DEBUG print "<br>OL=$line";

	#my($Date,$Open,$High,$Low,$Close,$Vol,$Crapola) = split(/,/, $line);
	### Current Day Data
	my($Date,$Open,$High,$Low,$Close,$AdjClose,$Vol,$dividend,$split_coefficient) =  split(/,/, $line);
	 $l3=$lines[$i-1];
	# my($PDate,$POpen,$PHigh,$PLow,$PClose,$PVol,$PCrapola)= split(/,/, $l3);
	### Previous Day Data
	my($PDate,$POpen,$xHigh,$PLow,$PClose,$PAdjClose,$PVol,$Pdividend,$Psplit_coefficient) = split(/,/, $l3);
	$OpenColor='White';
	$CloseColor='White';
	$SMAColor='White';
	$VOLColor='White';

	if ( $Open < $PClose ) 
		{ $OpenColor='Red';      }
	else
		{ $OpenColor='LightGreen'; }
	if ( $Open > $Close )   
		{ $CloseColor='Red';     }
	else
		{ $CloseColor='LightGreen'; }

#&Calculations();

#-------- Some simple calculations
        $Change = $Close-$Open;
        $pop=$High-$Open; $gap=$Open-$Low; $range=$High-$Low; $lc=$Close-$Low;

#---------- 15 day Moving Average  Price Calculation
$close5=0;
     for ($j=$i; $j>$i-15; $j-- ) {
        $l2=$lines[$j];
        ($xDate,$xOpen,$xHigh,$xLow,$xClose,$xAdjClose,$xVol,$xdividend,$xsplit_coefficient) = split(/,/, $l2);
        $close5=$close5 + $xClose;
        } 
        $close5=($close5/15);

#----------50 day Moving Average  Price Calculation
$close10=0;
      for ($j=$i; $j>$i-50; $j-- ) {
        $l2=$lines[$j];
        ($xDate,$xOpen,$xHigh,$xLow,$xClose,$xAdjClose,$xVol,$xdividend,$xsplit_coefficient) = split(/,/, $l2);
        $close10=$close10 + $xClose;
         }
        $close10=($close10/50);   #50 Day Average Close Price

	if ( $close10 > $close5 ) 
		{ $SMAColor='Red'; }
	else  { $SMAColor='LightGreen'; }
$SMAGAP=$close10-$close5;

#------------- 100 day moving average of volume for deviation calculation
$Crapola = 0; $vol100=0; $ACCvol100=0;
      for ($j=$i; $j>=$i-100; $j-- ) 
		{
        	  $l2=$lines[$j];
        	  ($xDate,$xOpen,$xHigh,$xLow,$xClose,$xAdjClose,$xVol,$xdividend,$xsplit_coefficient)  = split(/,/, $l2);
        	  $ACCvol100=$ACCvol100 + $xVol;
         	}

        $vol100=($ACCvol100/100);
        $Crapola=$Vol/$vol100;
$VOLColor='Yellow';
if ( $Crapola < .8 ) { $VOLColor='Red'; }
if ( $Crapola >= .9 ) { $VOLColor='White'; }
if ( $Crapola >= 1.1 ) { $VOLColor='LightGreen'; }
if ( $Crapola >= 2 ) { $VOLColor='Green'; }

#------------------- Identify Candle Forms
$candle="";
        if ($Open <  $Close  ){ $candle = $candle . "Green";}
        if ($Open >  $Close  ){ $candle = $candle . "Red";}
        if ($Open == $Close  ){ $candle =  "Doji";}
        if (($Open < $Close  ) && ( (($Open - $Low)/($Close - $Open)) > 2 ))
                      { $candle =  "Hammer";}
        if (($Open > $Close  ) && ( (($Close - $Low)/($Open - $Close)) > 2 ))
                      { $candle =  "Hangman";}

#  DEMARK Analysis happens Here  ################################################################
#################################################################################################

$TD="";     		#Signal Text 
#print " L=$i  $lines[$i]<br>";
if (( $BearFlip ) || ( $BullFlip )) 
	{ #1  **Either a BUY or Sell setup is in progress
	  if (( $BearFlip ) && ( $Close < $Reference ))  
		{ #2
		  #Process a close in a Bear Signal Sequence ################
		  $Countdown=$Countdown+1;
		  $TD = "TD-Buy $Countdown  $Close  $Reference";
		  if ( $Countdown == 9 ) 
			{ #3
                	  #Test final close in Bearflip countown if OK issue a BUY
			  # 9 consecutive closes �lower� than the close 4 bars prior records a �BUY setup�
			  #$TD = "TD-BuySignal $Countdown  $Close  $Reference";
              	  	  my($x1,$x2,$x3,$x4,$LOW6,$x5,$x6,$x7,$x8) = split(/,/, $lines[$i-3]);
                	  my($x1,$x2,$x3,$x4,$LOW7,$x5,$x6,$x7,$x8) = split(/,/, $lines[$i-2]);
                	  my($x1,$x2,$x3,$x4,$LOW8,$x5,$x6,$x7,$x8) = split(/,/, $lines[$i-1]);
                	  my($x1,$x2,$x3,$x4,$LOW9,$x5,$x6,$x7,$x8) = split(/,/, $lines[$i]);
                	  if ($LOW6 < $LOW7) {$LOW1=$LOW6;}else{$LOW1=$LOW7;} 
                	  if ($LOW8 < $LOW9) {$LOW2=$LOW8;}else{$LOW2=$LOW9;}
                	  if ( $LOW1 >  $LOW2 )
                   		{ #4
				  #Perfect Buy Signal########################
				  # a �buy setup� is �perfected� when the low of bars 6 and 7
				  # in the count are exceeded by the low of bars 8 or 
				  $TD = "TD-BuyPERF* $Countdown $Reference $LOW1";
                     		  $MSG= "$x1 $ticker Strong_Buy $Close $Reference $LOW1" ;
                     		  `echo "$MSG" >> /var/www/batch/alerts/alerts.txt`;
                   		} #4
                	  else
                   		{ #4
				  #Weak Buy Signal########################
                     		  $TD = "TD-BuySignal* $Countdown $Reference $LOW1";
                     		  $MSG= "$x1 $ticker Buy $Close $Reference $LOW1" ;
                     		  #`echo "$MSG" >> /var/www/batch/alerts/alerts.txt`;
                   		} #4
			  #Reset Indicators
		  	  $Countdown=0;
                  	  $BullFlip=0; 
		  	  $BearFlip=0;
		  	  $Reference=0;
              		} #3
		} #2
 	else
		{  #2   ****No Bearflip continuation - Check for Bullflip continuation############
	  	if (( $BullFlip  ) && ( $Close > $Reference ))
			{ #3
                  	  #Process a close in a Bull Signal Sequence ################
			  # 9 consecutive closes �higher� than the close 4 bars prior constitutes a �sell setup�
		  	  $Countdown=$Countdown+1;
		  	  $TD = "TD-Sell $Countdown  $Close  $Reference $BullFlip $BearFlip ";                    
              	  	  if ( $Countdown == 9 )
				{ #4
			  	  ##Test final close in Bullflip countown if OK issue a SELL
			 	  my($x1,$x2,$x3,$x4,$LOW6,$x5,$x6,$x7,$x8) = split(/,/, $lines[$i-3]);
			  	  my($x1,$x2,$x3,$x4,$LOW7,$x5,$x6,$x7,$x8) = split(/,/, $lines[$i-2]);
			  	  my($x1,$x2,$x3,$x4,$LOW8,$x5,$x6,$x7,$x8) = split(/,/, $lines[$i-1]);
			  	  my($x1,$x2,$x3,$x4,$LOW9,$x5,$x6,$x7,$x8) = split(/,/, $lines[$i]);
                      	  	  if ($LOW6 > $LOW7) {$LOW1=$LOW6;}else{$LOW1=$LOW7;}
			  	  if ($LOW8 > $LOW9) {$LOW2=$LOW8;}else{$LOW2=$LOW9;}
			  	  if ( $LOW1 <  $LOW2 )
					{ #5
				  	  #Perfect Sell Signal########################
				  	  #A �sell setup� is �perfected� when the the high of bars 6 and 7
				  	  # in the count are exceeded by the high of bars 8 or 9
				  	  $TD = "TD-SellPERF* $Countdown $Reference $LOW1";
				   	  $MSG= "$x1 $ticker Strong_Sell $Close $LOW1 $Reference" ;
				  	  `echo "$MSG" >> /var/www/batch/alerts/alerts.txt`;
					} #5
			  	  else
					{ #5
				  	  #Weak Sell Signal########################
				  	  $TD = "TD-SELLSignal $Countdown  $LOW1 $Reference";
 				 	  $MSG= "$x1 $ticker Sell C=$Close $Reference $LOW1" ;
				  	  #`echo "$MSG" >> /var/www/batch/alerts/alerts.txt`;
					}
			  	  #Reset Indicators
		  	  	  $Countdown=0;
                  		  $BullFlip=0; 
		  	 	  $BearFlip=0;
		  	 	  $Reference=0;
				} #4
        		} #3
	  	else
			{ #3
                  	  #Process a BUST in Bull or Bear Signal Sequence ################
		  	  $Countdown=0;
		  	  $BullFlip=0; $BearFlip=0;
		  	  $TD = "BUST $Close $Reference";
		  	  $Reference=0;
			} #3

		} #2
 	} #1
 else 
	{ #1 
           # TD Detect Start of Sequential Setup  #######################################
	   my($x1,$x2,$x3,$x4,$C4,$x5,$x6,$x7,$x8) = split(/,/, $lines[$i-1]);
	   my($x1,$x2,$x3,$x4,$C1,$x5,$x6,$x7,$x8) = split(/,/, $lines[$i-3]);
	   if (($i>3) && ($C4 > $C1) && ( $Close < $C1 )) 
		{ #2  Indicate Bearflip Sell Setup In Progres
                  $TD = "BearFlip $Close $C1"; 
		  $BearFlip=1;    #BEARFLIP DETECTED##################Close is LOWER than last 4 closes
		  $Reference=$C4; #Value of start of sequence
	       	  $Resistance=$C1;#Value that would break the sequence
	       	  $Support=$C1;   #Value that would break the sequence
               	  $Countdown=$Countdown+1;
	    	}  #2
	   if (($i>3) && ($C4 < $C1) && ( $Close > $C1 )) 
	   	{  #2 Indicate Bullflip Sell Setup In Progress 
		  $TD = "BullFlip $Close $C1"; 
               	  $BullFlip=1;    #BULLFLIP DETECTED##################Close is Greater than last 4 closes
              	  $Reference=$C4; #Value of start of sequence
	      	  $Resistance=$C1;#Value that would break the sequence
	     	  $Support=$C1;   #Value that would break the sequence
	          $Countdown=$Countdown+1;
       	    	} #2
       } #1


$Change_Since_Close=$Open-$PClose;
$Change_Since_Open=$Close-$Open;

# Output:Print Detail Table Line for the day 
#############################################################################
# Long field specs is split for visibility in editing
$format = "<tr align=right>";
$format = "$format"."<td title='Date'>%15s</td>";
$format = "$format"."<td title='Open - Change since Close:$Change_Since_Close' bgcolor='$OpenColor'>%01.2f</td>";
$format = "$format"."<td title='High'>%01.2f</td>";
$format = "$format"."<td  title='Low' >%01.2f</td>";
$format = "$format"."<td title='Close  - Change since Open: $Change_Since_Open'  bgcolor='$CloseColor' >%01.2f</td>";
$format = "$format"."<td title='Volume'>%02d</td>";
$format = "$format"."<td title='Compare to 100day SMA Volume($vol100 = $Vol / $ACCvol100)' bgcolor='$VOLColor'>%01.2f</td>";
$format = "$format"."<td title='Change: Open - Close'>%01.2f</td>";
$format = "$format"."<td title='15-day SMA-color refers to 50SMA' bgcolor='$SMAColor'>%01.2f</td>";
$format = "$format"."<td title='50 SMA - Distance from 15day SMA=$SMAGAP' >%01.2f</td>";
$format = "$format"."<td title='POP:High - Open'>%01.2f</td>";
$format = "$format"."<td title='GAP: Open - Low'>%01.2f</td>";
$format = "$format"."<td title='Hi - Low'>%01.2f</td>";
$format = "$format"."<td title='Low to close' >%01.2f</td>";
$format = "$format"."<td>%15s</td>";
$format = "$format"."<td title='Demark Signal'> %15s</td></tr>";
$line = sprintf($format, $Date,$Open,$High,$Low,$Close,$Vol,$Crapola,$Change,$close5,$close10,$pop,$gap,$range,$lc,$candle,$TD );
	@L2= ( [$Date,$Open,$High,$Low,$Close,$Vol,$Crapola, $Change,$close5,$close10,$pop,$gap,$range,$lc,$candle,$TD ]);
push(@data, [@L2]);
print H3 "$line\n";
}

close (HISTORY);
close (H2);
close (H3);

open(H3, 'dat3.txt');
$hdr = "Date,Open,High,Low,Close,Volume,Adj Close";
my(@lines) = <H3>;     #Read file into array for stats and printing
@lines = sort(@lines); # Order as oldest first for calculations
my $limit = @lines;    # extract number of entries

#    Print detail data table
for ($i=$limit; $i > 0; $i--)
 {
 $line = $lines[$i];
print "$line\n";
}

#my $time1 = time();
my $time1 = `date +%s%N`; # Returns ssssssssss.uuuuuu in scalar context
print "</table><sp>\n";
$useage=($time1-$time2)/1000000;
print "End  :$time1\nStart:$time2 \nresponse time:  $useage  milliseconds\n";

print "</body></html>\n";
############################## E N D  M A I N  ############################



################################################################################
#       S  U  B  R  O  U  T  I  N  E  S
################################################################################


sub SummaryLine {
	#--------------------------------------------------------------------------------
	# Put out general stat table for 50 100 220 day averages
    #---------------------------------------------------------------------------
$XX=$_[0];
for ($i=$limit; $i>=$limit-100; $i--)
 {
 # Good practice to store $_ value to prevent overwriting source data
 # my($line) = $_;

 $line = $lines[$i]; # pull current values from array
 chomp($line); # Good practice to always strip the trailing newline.
# separate all the data items into vars for calc and formatting
 my($xDate,$xOpen,$xHigh,$xLow,$xClose,$xVol,$xCrapola) = split(/,/, $line);
$XAccVol=$xVol+$XAccVol;  # accumulate Volume for 100 SMA
$XAccClose=$xClose+$XAccClose;  # accumulate Close price for 100 SMA
$XAccRange=$XAccRange+($xHigh-$xLow);
$XAccLC=$XAccLC+($xClose-$xLow);
$XX=$XX+5;
$AccVol=$XAccVol;
return($XX, $XAccVol);
#print "$line<br>";
}
}




sub getparms {
#===================================================================
#URL Parm is expected in the format:  ?ID="AKAM"
#  if not found, Global variable 'ID` is set to AKAM
#Format of original extraction command giving 2 years of data  was this 
#wget  -o log.txt -O dat.txt 'http://ichart.finance.yahoo.com/table.csv?s='.$ticker.'&d='.$m.'&e='.$d.'&f='.$y.'&g=d&a='.$m.'&b='.$d.'&c='.$ly.'&ignore=.csv'`;
#
#DEBUG
#print "$_=$ENV{$_}<br>" foreach sort keys %ENV;
if (length ($ENV{'QUERY_STRING'}) > 0)
      {
        $buffer = $ENV{'QUERY_STRING'};
        @pairs = split(/&/, $buffer);
        foreach $pair (@pairs){
           ($name, $value) = split(/=/, $pair);
           $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
           $in{$name} = $value;
           }
 }
# Account for possible error of omitted ticker parameter
$ticker = $in{'ID'};
if (  ! defined $ticker  ) { $ticker = "AKAM";
}else{ $ticker = "$in{'ID'}"; }
# Account for possible error of omitted OutputSize parameter
$OutputSize = $in{'SIZE'};
if (  ! defined $OutputSize  ) { $OutputSize = "compact";
}else{ $OutputSize = "$in{'SIZE'}"; }
}
#===================================================================
#===================================================================
#===================================================================
#
#


sub print_table_header {
########################################################################
# Print out header
#################################
#start_html("History for $ticker");
#h1("History Study for $ticker");
print "<head><title> Demark Study -  $ticker</title></head><body>\n";
print "<h1>History Study for $ticker</h1>\n";
#DOW for Reference
print "<a target='new' href=https://finviz.com/futures_charts.ashx?t=YM&p=h1 >DOW on Finviz</a><br>";

print "<a target='new' href=http://www.reuters.com/finance/stocks/companyProfile?symbol=$ticker >$ticker Company Profile (Reuters)</a><br>";
#--------- Print URL for raw data
$URL='http://finviz.com/quote.ashx?t=' . $ticker . '&ty=c&ta=1&p=d&b=1';
print '<a target="_blank"  href=' . $URL . '>' . "  FinViz 9 Mo Daily Analytical Chart" . '</a><br> ';
$URL='http://custom.marketwatch.com/custom/ibg/html-intchart.asp?symb='.$ticker.'&time=1dy&uf=8&compidx=sp500~3377&ma=6&maval=15%2C50%2C100&x=29&y=11';
$URL='http://www.marketwatch.com/investing/stock/TXN/charts?symb='.$ticker.'&countrycode=US';
#$URL='http://bigcharts.marketwatch.com/print/print.asp?sid=102601&symb='.$ticker.'&time=2&freq=6&compidx=SP500:3377&comp=&ma=&maval=&uf=&lf=32&lf2=4&lf3=0&type=&size=&country=us&o_symb=&startdate=&enddate=&style=380&backurl=/advchart/frames/main.asp&prms=qcd&default=false&originalstyle=380&or iginalurl=/advchart/frames/main.asp%3Fframes%3D0%26symb%3D';
#$URL=$URL .$ticker;
#$URL=$URL .'%26draw.x%3D23%26draw.y%3D13%26country%3Dus%26time%3D2%26freq%3D6%26style%3D380%26default%3Dtrue%26backurl%3D%252Fadvchart%252Fframes%252Fmain%252Easp%26prms%3Dqcd%26sid%3D102601';
print '<a target="_blank"  href=' . $URL . '&draw.x=23&draw.y=13>' . "MarketWatch Intraday CHART" . '</a><sp> ---- ';

$URL='http://custom.marketwatch.com/custom/ibg/html-intchart.asp?symb='.$ticker. '&time=1yr&uf=0&compidx=sp500%7E3377&ma=6&maval=15%2C50%2C100&x=34&y=12';
print '<a target="_blank"  href=' . $URL  . '>MarketWatch 1-yr CHART' . '</a><br>'; 

$URL='http://apps.cnbc.com/view.asp?uid=stocks/charts&symbol='.$ticker. '&tearoff=1';
print '<a target="_blank"  href=' . $URL  . '>CNBC  CHART' . '</a> Cookies hold chart settings<br>'; 

$URL='http://finance.yahoo.com/charts?s='.$ticker.'#chart6:symbol='.$ticker.';range=6m;indicator=ema(15)+sma+stochasticslow(5,3)+macd(5, 20, 30);charttype=candlestick;crosshair=on;ohlcvalues=0;logscale=on;source=undefined';
print '<a target="_blank"  href=' . $URL  . '>Yahoo 6MO chart' . '</a> Yahoo Just does it better...<br>';

$URL='http://www.google.com/finance?chdnp=1&chdd=1&chds=0&chdv=1&chvs=maximized&chdeh=1&chfdeh=1&chdet=1284148800000&chddm=391&chddi=120&chls=CandleStick&q=NYSE:$ticker&&fct=big';
$URL='http://www.google.com/finance?chdnp=1&chdd=1&chds=1&chdv=1&chvs=maximized&chdeh=0&chfdeh=0&chdet=1283198400000&chddm=391&chddi=120&chls=CandleStick&q=NASDAQ:';
print '<a target="_blank"  href=' . $URL . $ticker . '&ntsp=0&fct=big>' . "  Google Detail Chart" . '</a><sp> ----<br> ';

# Finished header 

}



sub gethistorydata {
#OLD https://query1.finance.yahoo.com/v7/finance/download/AMD?period1=1513023338&period2=1544559338&interval=1d&events=history&crumb=aJbtrzg7gn3 
#$URL = 'http://ichart.finance.yahoo.com/table.csv?s=' . $ticker . '&g=d&ignore=.csv';
#Old URL = reolaced 20181211 
#Full = https://query1.finance.yahoo.com/v7/finance/download/CSV?period1=839563200&period2=1545022800&interval=1d&events=history&crumb=aJbtrzg7gn3
#http://ichart.finance.yahoo.com/table.csv?s=AKAM&d=7&e=11&f=2010&g=d&a=9&b=29&c=1999&ignore=.csv

#- cobble up the data dump URL
$ly=$y-2;
#Model URL for max historical data---------------------------------------------------
#New  = https://query1.finance.yahoo.com/v7/finance/download/AMD?period1=1513023338&period2=1544559338&interval=1d&events=history&crumb=aJbtrzg7gn3 
#-1-Insert ticker ID from command line into url
#New2 = http://download.macrotrends.net/assets/php/stock_data_export.php?t=
#$URL='http://download.macrotrends.net/assets/php/stock_data_export.php?t='."$ticker";
#$URL=$URL.'?period1=1513023338&period2=1544559338&interval=1d&events=history&crumb=aJbtrzg7gn3';

#Alphavantage Data fetch using Free API 
# Model: https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=MSFT&outputsize=full&apikey=demo
######################################################################################
#-1-Insert base of URL
$URL='https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=';
#-2-Insert remainder of URL
$URL="$URL"."$ticker";
$URL="$URL".'&outputsize=compact';
#$URL="$URL".'&outputsize=full';
$URL="$URL".'&apikey=';
$API_Key=`cat /usr/lib/cgi-bin/API_Alphavantage.txt`;
$URL="$URL"."$API_Key";
$URL="$URL".'&datatype=csv';


#-3-Not sure if this is still needed
$URL=~ s/(\s+|\s+$)//g ; # trim the annoying whitespace from the URL!!!!
print 'Raw Data = <a href='."$URL".'>' . "$URL" . '</a>';


#Use WGET to strip the data from provider - the result is a CSV file with a text header
`wget  -o log.txt -O dat.txt "$URL" `;

#VERIFY we actually got a decent data transfer
$wget_length=`ls -l dat.txt | cut -d ' ' -f5`;
#print  "<br>print  "<br>$wget_length - bytes  Returned from provider";

if ($wget_length < 100)      {
     
     print  "<br><br>*******ERROR $wget_length - bytes Insufficient data - Run Cannot Continue - <br>WGET RUN LOG returned..............<br>";
     open(my $txtfile,  "<",  "log.txt")  or die "Can't open log.txt: $!";
     while (<$txtfile>) {     # assigns each line in turn to $_
                          print "$_<br>";
                        }

     print  "<br>DATA Returned as follows..........<br>";
     open(my $txtfile,  "<",  "dat.txt")  or die "Can't open log.txt: $!";
     while (<$txtfile>) {     # assigns each line in turn to $_
                          print "$_<br>";
                        }
     print  "<br>*******Abnormal Termination";
     exit;               # Data request failed - exit program 
    }


}

sub Calculations {

#-------- Some simple calculations
        $Change = $Close - $Open;
        $pop=$High-$Open; $gap=$Open-$Low; $range=$High-$Low; $lc=$Close-$Low;
#---------- 5 day Moving Average  Price Calculation
$close5=0;
      for ($j=$i+4; $j>=$i; $j-- ) {
        $l2=$lines[$j];
        my($Date,$Open,$High,$Low,$Close,$Vol,$Crapola) = split(/,/, $l2);
        $close5=$close5 + $Close;
         }
        $close5=($close5/5);

#----------10 day Moving Average  Price Calculation
$close10=0;
      for ($j=$i+9; $j>=$i; $j-- ) {
        $l2=$lines[$j];
        my($Date,$Open,$High,$Low,$Close,$Vol,$Crapola) = split(/,/, $l2);
        $close10=$close10 + $Close;
         }
        $close10=($close10/10);
#------------- 100 day moving average of volume for deviation calculation
$Crapola = 0; $vol100=0;
      for ($j=$i+99; $j>=$i; $j-- ) {
        $l2=$lines[$j];
        ($Date,$Open,$High,$Low,$Close,$Vol,$Crapola) = split(/,/, $l2);
        $vol100=$vol100 + $Vol;
         }
        $Crapola=($vol100/100);
        $Crapola=$Vol/$Crapola;

#------------------- Identify Candle Forms
$candle="";
        if ($Open <  $Close  ){ $candle = $candle . "Green";}
        if ($Open >  $Close  ){ $candle = $candle . "Red";}
        if ($Open == $Close  ){ $candle =  "Doji";}
        if (($Open < $Close  ) && ( (($Open - $Low)/($Close - $Open)) > 2 ))
                      { $candle =  "Hammer";}
        if (($Open > $Close  ) && ( (($Close - $Low)/($Open - $Close)) > 2 ))
                      { $candle =  "Hangman";}


}

__END__

# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

getdata.pl - fetch data for a given equity from yahoo and print out
	history in tabular format.
	It is invoked via URL as follows:
	http://perfectcicleservices.com/cgi-bin/getdata.pl?ID=TTT
		where TTT is the ticker symbol of an equity 

=head1 SYNOPSIS


It is invoked via URL as follows:
        http://perfectcicleservices.com/cgi-bin/getdata.pl?ID=TTT
                where TTT is the ticker symbol of an equity

=head1 DESCRIPTION

The following data is output as an HTML table:
	Yahoo History (daily data) 
	calculated data 
	DeMark signal analysis

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Austin Johnston, E<lt>perfedd2@localdomainE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by A. U. Thor

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut


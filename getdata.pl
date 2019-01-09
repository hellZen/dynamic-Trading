#!/usr/bin/perl
use CGI qw(:standard);
#
#use CGI ;
#!!!went up to /usr and set permissions to create/delete
# and applied downward for remote edit
print header;   # Tell perl to send a html header.
     		# So your browser gets the output
     		# rather then <stdout>(command line
     		# on the server.)

my $time2 = time();	#load the start time for execution usage timing
my $BullFlip=0;
my $BearFlip=0;
my $Countdown=0;
my $Reference=0;
my $Support=0;
$m=`date '+%m-%d-%Y'| cut -d - -f1`;
$d=`date '+%m-%d-%Y'| cut -d - -f2`;
$y=`date '+%m-%d-%Y'| cut -d - -f3`;
$ly=$y-2;

&getparms;	# load the parameters supplied on the URL 
		# These are in the form pp=<value>
		# Valid values are ID - ticker symbol defauld = "AKAM"

&print_table_headings; 	# Print out table tags &  headings


# Get the data from Yahoo #################################
#  TODO - cut down the volume for speed and bandwidth savings
#`wget  -o log.txt -O dat.txt 'http://ichart.finance.yahoo.com/table.csv?s='.$ticker.'&d='.$m.'&e='.$d.'&f='.$y.'&g=d&a='.$m.'&b='.$d.'&c='.$ly.'&ignore=.csv'`;
`wget  -o log.txt -O dat.txt "$URL" `;
#   Just grab the numeric data -  this is a really dumb way to strip the header
#               cleverness in programming can be an expensive conceit
`cat dat.txt | grep [0-9] > dat2.txt`;

open(HISTORY, '<dat.txt');
open(H2, '<dat2.txt');
open(H3, '>dat3.txt');
$hdr = "Date,Open,High,Low,Close,Volume,Adj Close";
my(@lines) = <H2>;  #Read file into array for stats and printing
@lines = sort(@lines); # Order as oldest first for calculations
my $limit = @lines;  # extract number of entries

#############################################################################
#############################################################################
#############################################################################
# Print Summary stats....
my($AccVol)=0; 
my($AccClose)=0; 
my($AccRange)=0; 
my($AccLC)=0; 
my($N)=260;
$xMin=999.00; $xMax=0;
$switch=1; 
#($N,$AccVol)=&SummaryLine(100);
for ($i=$limit-1; $i>=$limit-$N; $i--)
 {
 $line = $lines[$i]; # pull current values from array
 chomp($line); # Good practice to always strip the trailing newline.
# separate all the data items into vars for calc and formatting
 ($xDate,$xOpen,$xHigh,$xLow,$xClose,$xVol,$xCrapola) = split(/,/, $line);
if ( $switch == 1 )
 { $switch=0; 
   $Last=$xClose;
 }
if ( ($xLow) <  ($xMin)) { $xMin = $xLow };
if ( ($xHigh) >  ($xMax)) { $xMax = $xHigh };
#print "<br>Lines $limit - N $i - Low $xLow Min $xMin -- $line\n";
}
$range=$xMax - $xMin;  $cur=$Last - $xMin; $pct=$cur/$range;
print "<br>52-Week Range=$range - [ Min $xMin Max $xMax ] <sp>Last Close $Last - Pos in range - $pct<sp>\n";

print "<table border=1>";
print "<tr><td>Days</td><td>Close</td><td>Volume</td><td>Range</td><td>LC</td></tr>";
#############################################################################
#############################################################################
#############################################################################
# Print Summary stats....
my($AccVol)=0; my($AccClose)=0; my($AccRange)=0; my($AccLC)=0; my($N)=50;
#($N,$AccVol)=&SummaryLine(100);
for ($i=$limit; $i>=$limit-$N; $i--)
 {
 $line = $lines[$i]; # pull current values from array
 chomp($line); # Good practice to always strip the trailing newline.
# separate all the data items into vars for calc and formatting
 my($xDate,$xOpen,$xHigh,$xLow,$xClose,$xVol,$xCrapola) = split(/,/, $line);
$AccVol=$xVol+$AccVol;  # accumulate Volume for 100 SMA
$AccClose=$xClose+$AccClose;  # accumulate Close price for 100 SMA
$AccRange=$AccRange+($xHigh-$xLow);
$AccLC=$AccLC+($xClose-$xLow);
#print "$line<br>";
}
$AccVol=$AccVol/$N; $AccClose=$AccClose/$N; 
$AccRange=$AccRange/$N; $AccLC=$AccLC/$N;
$format=("<tr><td>%01.0f</td><td>%01.2f</td><td>%01.0f</td><td>%01.2f</td><td>%01.2f</td></tr>");
$LINEOUT=sprintf($format, $N, $AccClose,$AccVol,$AccRange,$AccLC);
print $LINEOUT;

#############################################################################
#############################################################################
#############################################################################

my($AccVol)=0; my($AccClose)=0; my($AccRange)=0; my($AccLC)=0; my($N)=100;
#($N,$AccVol)=&SummaryLine(100);
for ($i=$limit; $i>=$limit-$N; $i--)
 {
 $line = $lines[$i]; # pull current values from array
 chomp($line); # Good practice to always strip the trailing newline.
# separate all the data items into vars for calc and formatting
 my($xDate,$xOpen,$xHigh,$xLow,$xClose,$xVol,$xCrapola) = split(/,/, $line);
$AccVol=$xVol+$AccVol;  # accumulate Volume for 100 SMA
$AccClose=$xClose+$AccClose;  # accumulate Close price for 100 SMA
$AccRange=$AccRange+($xHigh-$xLow);
$AccLC=$AccLC+($xClose-$xLow);
#print "$line<br>";
}
$AccVol=$AccVol/$N; $AccClose=$AccClose/$N;
$AccRange=$AccRange/$N; $AccLC=$AccLC/$N;
$format=("<tr><td>%01.0f</td><td>%01.2f</td><td>%01.0f</td><td>%01.2f</td><td>%01.2f</td></tr>");
$LINEOUT=sprintf($format, $N, $AccClose,$AccVol,$AccRange,$AccLC);
print $LINEOUT;

#############################################################################
#############################################################################
#############################################################################

my($AccVol)=0; my($AccClose)=0; my($AccRange)=0; my($AccLC)=0; my($N)=200;
#($N,$AccVol)=&SummaryLine(100);
for ($i=$limit; $i>=$limit-$N; $i--)
 {
 $line = $lines[$i]; # pull current values from array
 chomp($line); # Good practice to always strip the trailing newline.
# separate all the data items into vars for calc and formatting
 my($xDate,$xOpen,$xHigh,$xLow,$xClose,$xVol,$xCrapola) = split(/,/, $line);
$AccVol=$xVol+$AccVol;  # accumulate Volume for 100 SMA
$AccClose=$xClose+$AccClose;  # accumulate Close price for 100 SMA
$AccRange=$AccRange+($xHigh-$xLow);
$AccLC=$AccLC+($xClose-$xLow);
#print "$line<br>";
}
$AccVol=$AccVol/$N; $AccClose=$AccClose/$N;
$AccRange=$AccRange/$N; $AccLC=$AccLC/$N;
$format=("<tr><td>%01.0f</td><td>%01.2f</td><td>%01.0f</td><td>%01.2f</td><td>%01.2f</td></tr>");
$LINEOUT=sprintf($format, $N, $AccClose,$AccVol,$AccRange,$AccLC);
print $LINEOUT;

print "</table>";
######################################################################
#############################################################################
#############################################################################
# Print Detail Stats
#print " Limit $limit";
print "<table border=1>\n ";
 $line  = "<tr><td>Date</td><td>Open</td><td>High</td><td title='Low for the day'>Low</td><td>Close</td><td>Volume</td><td>Rel_Vol</td><td>Change</td><td>15SMA</td><td>50SMA</td><td>Pop</td><td>Gap</td><td>Range</td><td>LC</td><td>Candle</td><td>TD</td></tr>";
print "$line<br>\n";


#    Print detail data table
for ($i=0; $i < $limit; $i++)
 {
 # Good practice to store $_ value because # subsequent operations may change it.
 # my($line) = $_;
 # Good practice to always strip the trailing # newline from the line.
 $line = $lines[$i];
 chomp($line);
 my($Date,$Open,$High,$Low,$Close,$Vol,$Crapola) = split(/,/, $line);
 $l3=$lines[$i-1];
 my($PDate,$POpen,$PHigh,$PLow,$PClose,$PVol,$CPrapola)= split(/,/, $l3);
$OpenColor='White';
$CloseColor='White';
$SMAColor='White';
$VOLColor='White';
if ( $Open <= $PClose ) { $OpenColor='Red'; }
else  { $OpenColor='LightGreen'; }
if ( $Open > $Close ) { $CloseColor='Red'; }
else  { $CloseColor='LightGreen'; }

#&Calculations();

#-------- Some simple calculations
        $Change = $Close-$Open;
        $pop=$High-$Open; $gap=$Open-$Low; $range=$High-$Low; $lc=$Close-$Low;
#---------- 5 day Moving Average  Price Calculation
$close5=0;
     #for ($j=$i; $j<$i+4; $j++ ) {
     for ($j=$i; $j>$i-15; $j-- ) {
        $l2=$lines[$j];
        my($xDate,$xOpen,$xHigh,$xLow,$xClose,$xVol,$xCrapola)= split(/,/, $l2);
        $close5=$close5 + $xClose;
        } 
        $close5=($close5/15);

#----------10 day Moving Average  Price Calculation
$close10=0;
      for ($j=$i; $j>$i-50; $j-- ) {
      #for ($j=$i+9; $j>=$i; $j-- ) {
        $l2=$lines[$j];
        my($xDate,$xOpen,$xHigh,$xLow,$xClose,$xVol,$xCrapola)= split(/,/, $l2);
        $close10=$close10 + $xClose;
         }
        $close10=($close10/50);

if ( $close10 > $close5 ) { $SMAColor='Red'; }
else  { $SMAColor='LightGreen'; }
$SMAGAP=$close10-$close5;
#------------- 100 day moving average of volume for deviation calculation
$Crapola = 0; $vol100=0; $ACCvol100=0;
      for ($j=$i; $j>=$i-100; $j-- ) {
        $l2=$lines[$j];
        ($xDate,$xOpen,$xHigh,$xLow,$xClose,$xVol,$xCrapola)= split(/,/, $l2);
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


$TD="";
if (( $BearFlip ) || ( $BullFlip )) 
  {
    if (( $BearFlip ) && ( $Close < $Reference ))  
	{
	  $Countdown=$Countdown+1;
	  $TD = "TD-Buy $Countdown  $Close  $Reference";
          if ( $Countdown == 9 ) 
	     {
		  #$TD = "TD-BuySignal $Countdown  $Close  $Reference";
                my($x1,$x2,$x3,$x4,$LOW6,$x5,$x6) = split(/,/, $lines[$i-3]);
                my($x1,$x2,$x3,$x4,$LOW7,$x5,$x6) = split(/,/, $lines[$i-2]);
                my($x1,$x2,$x3,$x4,$LOW8,$x5,$x6) = split(/,/, $lines[$i-1]);
                my($x1,$x2,$x3,$x4,$LOW9,$x5,$x6) = split(/,/, $lines[$i]);
                if ($LOW6 < $LOW7) {$LOW1=$LOW6;}else{$LOW1=$LOW7;} 
                if ($LOW8 < $LOW9) {$LOW2=$LOW8;}else{$LOW2=$LOW9;}
                if ( $LOW1 >  $LOW2 )
                   { $TD = "TD-BuyPERF* $Countdown $Reference $LOW1";
                     $MSG= "$x1 $ticker Strong_Buy $Close $Reference $LOW1" ;
                     `echo "$MSG" >> /var/www/batch/alerts/alerts.txt`;
                   }else{
                     $TD = "TD-BuySignal* $Countdown $Reference $LOW1";
                     $MSG= "$x1 $ticker Buy $Close $Reference $LOW1" ;
                     #`echo "$MSG" >> /var/www/batch/alerts/alerts.txt`;
                   }

		  $Countdown=0;
                  $BullFlip=0; $BearFlip=0;
		  $Reference=0;
             } 
	}else{
		if  (( $BullFlip  ) && ( $Close > $Reference ))
		{
	#$TD ="Trace $Countdown  $Close  $Reference $BullFlip $BearFlip ";
		  $Countdown=$Countdown+1;
		  $TD = "TD-Sell $Countdown  $Close  $Reference";
          	if ( $Countdown == 9 )
               	 { 
                my($x1,$x2,$x3,$x4,$LOW6,$x5,$x6) = split(/,/, $lines[$i-3]);
                my($x1,$x2,$x3,$x4,$LOW7,$x5,$x6) = split(/,/, $lines[$i-2]);
                my($x1,$x2,$x3,$x4,$LOW8,$x5,$x6) = split(/,/, $lines[$i-1]);
                my($x1,$x2,$x3,$x4,$LOW9,$x5,$x6) = split(/,/, $lines[$i]);
                if ($LOW6 > $LOW7) {$LOW1=$LOW6;}else{$LOW1=$LOW7;}
                if ($LOW8 > $LOW9) {$LOW2=$LOW8;}else{$LOW2=$LOW9;}
                if ( $LOW1 <  $LOW2 )
                   { $TD = "TD-SellPERF* $Countdown $Reference $LOW1";
                    #$MSG= "$x1 $ticker Strong_Sell $Close $Reference $LOW1" ;
                     $MSG= "$x1 $ticker Strong_Sell $Close $LOW1 $Reference" ;
                    `echo "$MSG" >> /var/www/batch/alerts/alerts.txt`;
                   }else{
                     $TD = "TD-SELLSignal $Countdown  $LOW1 $Reference";
                     $MSG= "$x1 $ticker Sell C=$Close $Reference $LOW1" ;
                    #`echo "$MSG" >> /var/www/batch/alerts/alerts.txt`;
                   }
               	   $Countdown=0;
               	   $BullFlip=0; $BearFlip=0;
               	   $Reference=0;
               	 }

		}else{
		  $Countdown=0;
		  $BullFlip=0; $BearFlip=0;
		  $TD = "BUST $Close $Reference";
		  $Reference=0;
		}
	}
 }else{  # TD Sequential Setup in progress
	my($x1,$x2,$x3,$x4,$C4,$x5,$x6) = split(/,/, $lines[$i-1]);
	my($x1,$x2,$x3,$x4,$C1,$x5,$x6) = split(/,/, $lines[$i-3]);
	if (($i>3) && ($C4 > $C1) && ( $Close < $C1 )) 
  	  { $TD = "BearFlip $Close $C1"; $BearFlip=1; $Reference=$C4;
	     $Resistance=$C1;
	     $Support=$C1;
             $Countdown=$Countdown+1;
	  }
	if (($i>3) && ($C4 < $C1) && ( $Close > $C1 )) 
	  { $TD = "BullFlip $Close $C1"; $BullFlip=1; $Reference=$C4;
	     $Resistance=$C1;
	     $Support=$C1;
	    $Countdown=$Countdown+1;
       	  }
	}
$Change_Since_Close=$Open-$PClose;
$Change_Since_Open=$Close-$Open;
$format = "<tr align=right><td title='Date'>%15s</td><td title='Open - Change since Close:$Change_Since_Close' bgcolor='$OpenColor'>%01.2f</td><td title='High'>%01.2f</td><td  title='Low' >%01.2f</td><td  title='Close  - Change since Open: $Change_Since_Open'  bgcolor='$CloseColor' >%01.2f</td><td  title='Volume'>%02d</td><td title='Compare to 100day SMA Volume($vol100 = $Vol / $ACCvol100)' bgcolor='$VOLColor'>%01.2f</td><td title='Change: Open - Close'>%01.2f</td><td title='15-day SMA-color refers to 50SMA' bgcolor='$SMAColor'>%01.2f</td><td title='50 SMA - Distance from 15day SMA=$SMAGAP' >%01.2f</td><td title='POP:High - Open'>%01.2f</td><td title='GAP: Open - Low'>%01.2f</td><td title='Hi - Low'>%01.2f</td><td title='Low to close' >%01.2f</td><td>%15s</td><td>%15s</td></tr>";
$line = sprintf($format, $Date,$Open,$High,$Low,$Close,$Vol,$Crapola,
        $Change,$close5,$close10,$pop,$gap,$range,$lc,$candle,$TD );
	@L2= ( [$Date,$Open,$High,$Low,$Close,$Vol,$Crapola, $Change,$close5,$close10,$pop,$gap,$range,$lc,$candle,$TD ]);
push(@data, [@L2]);
print H3 "$line\n";
}

close (HISTORY);
close (H2);
close (H3);

open(H3, 'dat3.txt');
$hdr = "Date,Open,High,Low,Close,Volume,Adj Close";
my(@lines) = <H3>;  #Read file into array for stats and printing
@lines = sort(@lines); # Order as oldest first for calculations
my $limit = @lines;  # extract number of entries

#    Print detail data table
for ($i=$limit; $i > 0; $i--)
 {
 $line = $lines[$i];
print "$line\n";
}

my $time1 = time();
print "</table><sp>\n";
print "useage: ", $time1-$time2, "seconds\n";

print "</body></html>\n";
############################## E N D  M A I N  ############################
sub SummaryLine {
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
#===================================================================
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
if (  ! defined $ticker  ) { $ticker = "akam";
}else{ $ticker = "$in{'ID'}"; }

}
#===================================================================
#===================================================================
#===================================================================
#
#


sub print_table_headings {
########################################################################
# Print out header
#################################
#start_html("History for $ticker");
#h1("History Study for $ticker");
print "<head><title> Demark Study -  $ticker</title></head><body>\n";
print "<h1>History Study for $ticker</h1>\n";
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
print '<a target="_blank"  href=' . $URL . $ticker . '&ntsp=0&fct=big>' . "  Google Detail Chart" . '</a><sp> ---- ';

$URL = 'http://ichart.finance.yahoo.com/table.csv?s=' . $ticker . '&g=d&ignore=.csv';
$ly=$y-2;
#http://ichart.finance.yahoo.com/table.csv?s=AKAM&d=7&e=11&f=2010&g=d&a=9&b=29&c=1999&ignore=.csv
$URL='http://ichart.finance.yahoo.com/table.csv?s='."$ticker";
$URL=$URL.'&d='.$m.'&e='.$d.'&f='."$y".'&g=d&a='."$m".'&b='."$d".'&c='."$ly".'&ignore=.csv';
$URL=~ s/(\s+|\s+$)//g ; # trim the annoying whitespace from the URL!!!!
#print 'Raw Data = <a href='."$URL".'>' . "$URL" . '</a>';
print '<a href='."$URL".'>' . "  Raw Data" . '</a><sp>';


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


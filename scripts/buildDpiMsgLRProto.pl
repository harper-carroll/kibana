#!/usr/bin/perl
#
#
#

open qosmosWorkbook, "$ARGV[0]" or die $!;
open previousData, "$ARGV[1]" or die $!;
open filters, "$ARGV[2]" or die $!;

my $exludeFilter;
my $includeFilter;
while (<filters>) {
   if ($_ =~ m/^(?!#)!(\S+)/ ) {
      $excludeFilter .= $1;
   } elsif ($_ =~ m/^(?!#)(\S+)/ ) {
      $includeFilter .= $1;
   }
}
close filters;
#print "Exclude Filter: $excludeFilter \n";
#print "Include Filter: $includeFilter \n";

my @ids; 
my @previousFields; 
my @previousData;
my @newFields;
my $highest = 1;
my $callbackNames = ",";
while (<previousData>) {
   if ($_ =~ m/^(optional|repeated)\s+.*\s+(\w+)\s+=\s+(\d+)\;/) {
      push(@ids,$3);
      if ( $3 > $highest ) {
         $highest = $3;
      }
      $callbackNames .= "$2,";
      push(@previousFields,$2);
      push(@previousData,$_);
   }
}
close previousData;

#print "$callbackNames\n";

while ( my $line = <qosmosWorkbook>) {
   @lineValues = split(/,/,$line);
   $field = "$lineValues[7]$lineValues[1]";
   my $index = 0;
   foreach (@previousData) {
      if ( $_ =~ /$field/ ) {
         print $_;
         splice(@previousData, $index, 1);
         break;
      }   
      $index += 1;
   }
}

seek qosmosWorkbook, 0, 0;
#print @previousData;


while (<qosmosWorkbook>) {
  if ($_ =~ m/$includeFilter/ && $_ !~ /$excludeFilter/ ) {
     @lineValues = split(/,/,$_);
     $field = "$lineValues[7]$lineValues[1]";
     if ( $field =~ /^[0-9]/ ) {
        $field = "_$lineValues[7]$lineValues[1]";
     }
     if ($callbackNames !~ /,$field,/ ) {
        $requirement = "optional";
        $highest += 1;
        $type = $lineValues[9];
        $optionalStuff = "";
        if ($lineValues[9] =~ /timeval/ ) {
           $type = "string";
           $optionalStuff = ",timeval,timevalToString";
        } elsif ( $lineValues[9] =~ /ip_addr/ ) {
           $type = "string";
           $optionalStuff = ",uint32,ip_addrToString";
        } elsif ( $lineValues[9] =~ /mac_addr/ ) {
           $type = "string";
           $optionalStuff = ",clep_mac_addr_t,mac_addrToString";
        } elsif ($lineValues[9] eq "" ) {
           print "MALFORMED FILE!!!!";
           print "0:$lineValues[0],1:$lineValues[1],2:$lineValues[2],3:lineValues[3],4:$lineValues[4],5:$lineValues[5],6:$lineValues[6],7:$lineValues[7],8:$lineValues[8],9:$lineValues[9]";
           exit(1);
        } elsif ( $lineValues[9] =~ /string/ ) {
           $type = "bytes";
           $requirement = "repeated";
        }

        print "$requirement $type $field = $highest; // QOSMOS:$lineValues[1],$lineValues[6]$optionalStuff\n";
     }
  } 
}


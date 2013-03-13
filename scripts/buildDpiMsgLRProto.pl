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
   if ($_ =~ m/^optional\s+.*\s+(\w+)\s+=\s+(\d+)\;/) {
      push(@ids,$2);
      if ( $2 > $highest ) {
         $highest = $2;
      }
      $callbackNames .= "$1,";
      push(@previousFields,$1);
      push(@previousData,$_);
   }
}
close previousData;

#print "$callbackNames\n";
print @previousData;

while (<qosmosWorkbook>) {
  if ($_ =~ m/$includeFilter/ && $_ !~ /$excludeFilter/ ) {
     @lineValues = split(/,/,$_);
     if ($callbackNames !~ /,$lineValues[7]$lineValues[1],/ ) {
        $highest += 1;
        $field = "$lineValues[7]$lineValues[1]";
        $type = $lineValues[8];
        $optionalStuff = "";
        if ($lineValues[8] =~ /timeval/ ) {
           $type = "string";
           $optionalStuff = ",timeval,timevalToString";
        } elsif ( $lineValues[8] =~ /ip_addr/ ) {
           $type = "string";
           $optionalStuff = ",uint32,ip_addrToString";
        } elsif ( $lineValues[8] =~ /mac_addr/ ) {
           $type = "string";
           $optionalStuff = ",clep_mac_addr_t,mac_addrToString";
        }
        print "optional $type $field = $highest; // QOSMOS:$lineValues[1],$lineValues[6]$optionalStuff\n";
     }
  } 
}


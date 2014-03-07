#!/usr/bin/perl
#
#
#
use YAML::Any qw(Dump DumpFile);

open qosmosWorkbook, "$ARGV[0]" or die $!;
open summaryFile, '>'."$ARGV[3]" or die $!;
seek summaryFile, 0, 0;

sub ReadFilters {
   my($filename) = @_;

   open filters, "$filename" or die $!;
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
   return ($exludeFilter,$includeFilter);
}

sub ReadRemappingFile {
   my($filename) = @_;

   my %renameMapping = ();
   open remappingFile, "$filename" or die $!;
   while (<remappingFile>) {
      if ( $_ =~ m/(\S+)\s+(\S+)/ ) {
         $renameMapping{$1} = $2;
      }
   }
   close remappingFile;
   return %renameMapping;
}

sub ReadPreviousData {
   my($filename) = $_[0];
   $highest_ptr = $_[1];
   $ids_ptr = $_[2];
   $callbackNames_ptr = $_[3];
   $previousFields_ptr = $_[4];
   $previousData_ptr = $_[5];
   
   $$highest_ptr = 1;
   $$callbackNames_ptr = ",";

   open previousData, "$filename" or die $!;
   while (<previousData>) {
      if ($_ =~ m/^(optional|repeated)\s+.*\s+(\w+)\s+=\s+(\d+)\;/) {
         push(@$ids_ptr,$3);
         if ( $3 > $$highest_ptr ) {
            $$highest_ptr = $3;
         }
         $$callbackNames_ptr .= "$2,";
         push(@$previousFields_ptr,$2);
         push(@$previousData_ptr,$_);
      }
   }
   close previousData;
}

sub CreateSummaryFile {

   my($qosmosFileName,$summaryFileName,$includeFilter,$excludeFilter) = @_;

   open qosmosWorkbook, "$qosmosFileName" or die $!;
   open summaryFile, '>'."$ARGV[3]" or die $!;
   seek summaryFile, 0, 0;

   print summaryFile "protocolName,longProtocolName,attributeName,attributeDescription\n";
   while (<qosmosWorkbook>) {
      if ($_ =~ m/$includeFilter/ && $_ !~ /$excludeFilter/ ) {
         my @lineValues = split(/,/,$_);
         if ($lineValues[3] eq '' ) {
            print summaryFile "base,";
         } else {
            print summaryFile "$lineValues[3],";
         }
         if ($lineValues[4] eq '' ) {
            print summaryFile "base,";
         } else {
            print summaryFile "$lineValues[4],";
         }
         print summaryFile '#'."$lineValues[7],$lineValues[10]\n";
      }
   }

   close qosmosWorkbook;
   close summaryFile;
}

sub CheckRenameFile {
   my($qosmosFileName,$includeFilter,$excludeFilter,%renameMapping) = @_;

   open qosmosWorkbook, "$qosmosFileName" or die $!;

   while (<qosmosWorkbook>) {
      if ($_ =~ m/$includeFilter/ && $_ !~ /$excludeFilter/ ) {
         my @lineValues = split(/,/,$_);
         if ( !defined $renameMapping { $lineValues[7] } &&
               !defined $renameMapping { "_$lineValues[7]" } ) {
            die "Rename file does not account for field $lineValues[7]";
         } 
      }
   }

   close qosmosWorkbook;

}

sub CreateRemappingFile {
   my($remappingfile,$nmfieldnames) = @_;

   open nmfieldnamesFile, "$nmfieldnames" or die $!;
   open remappingFile, '>'."$remappingfile" or die $!;
   seek remappingFile, 0, 0;

   while (<nmfieldnamesFile>) {
      if ($_ =~ m/.*Q_PROTO.*/ ) {
         my @lineValues = split(/,/,$_);
         print remappingFile "$lineValues[2] $lineValues[3]\n";
      }
   }

   close nmfieldnamesFile;
   close remappingFile;

}

$QosmosWorkBookName = $ARGV[0];
($exludeFilter,$includeFilter) = ReadFilters($ARGV[2]);
CreateRemappingFile($ARGV[4],$ARGV[6]);
(%renameMapping) = ReadRemappingFile($ARGV[4]);
my $renameMap = $ARGV[5];
if ($renameMap eq "" ) {
   die "Must name a path to output rename map $ARGV[5] $renameMap" ;
}

CheckRenameFile($QosmosWorkBookName,$includeFilter,$excludeFilter,%renameMapping);
DumpFile($renameMap,\%renameMapping);
my $highest;
my @ids;
my $callbackNames;
my @previousFields;
my @previousData;
ReadPreviousData($ARGV[1],\$highest, \@ids, \$callbackNames, \@previousFields, \@previousData);
CreateSummaryFile($QosmosWorkBookName,$ARGV[3],$excludeFilter,$includeFilter);

open qosmosWorkbook, "$ARGV[0]" or die $!;
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


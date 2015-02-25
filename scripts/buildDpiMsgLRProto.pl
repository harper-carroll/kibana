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
   $statiField_ptr = $_[6];

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
      if ( index($_,'Q_PROTO') == -1 && (index($_,'optional') != -1 || index($_,'repeated') != -1)) {
         my @lineValues = split(/\s+/,$_);
         push(@$staticField_ptr,$lineValues[3]);
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
         if ($lineValues[4] eq '' ) {
            print summaryFile "base,";
         } else {
            print summaryFile "$lineValues[4],";
         }
         if ($lineValues[5] eq '' ) {
            print summaryFile "base,";
         } else {
            print summaryFile "$lineValues[5],";
         }
         print summaryFile '#'."$lineValues[8],$lineValues[11]\n";
      }
   }

   close qosmosWorkbook;
   close summaryFile;
}

sub CheckRenameFile {
   my($qosmosFileName,$includeFilter,$excludeFilter,%renameMapping) = @_;
   $statiField_ptr = $_[4];

   my $filename = 'MissingAttributesReport.txt';
   open(my $missAttrFile, '>', $filename) or die "Could not open file '$filename' $!";
   print $missAttrFile "remapping file - missing attributes\n";
   open qosmosWorkbook, "$qosmosFileName" or die $!;

   $mapGood = 1;
   while (<qosmosWorkbook>) {
      if ($_ =~ m/$includeFilter/ && $_ !~ /$excludeFilter/ ) {
         my @lineValues = split(/,/,$_);
         if ( !defined $renameMapping { $lineValues[8] } &&
               !defined $renameMapping { "_$lineValues[8]" } ) {
#           The remapping file needs to have an entry in it for each attribute name in the Qosmos Workbook.
#           If there are missing attributes, work with Labs to get mappings assigned. Use an updated
#           NetMonFieldNames.csv file to complete the Protobuffer compilation.
            print $missAttrFile "Attribute: $lineValues[8] for ($lineValues[2], $lineValues[5], $lineValues[7])\n";
            $mapGood = 0;
         } 
      } 
   }
   close $missAttrFile;

   if ($mapGood) {
      while (($key,$value) = each (%renameMapping)) {
         my @matches =  grep { /$value/ } @$staticField_ptr;
         if (@matches && $matches[0] eq $value ) {
            die "Rename file tries to map to a static field $value";
         }
      }
   } else {
      die "**** BUILD FAILED ****\nNetMonFieldNames.csv needs to be updated by labs.\nSee $filename for list of missing attributes.\n";
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

my $highest;
my @ids;
my $callbackNames;
my @previousFields;
my @previousData;
my @staticFields;
ReadPreviousData($ARGV[1],\$highest, \@ids, \$callbackNames, \@previousFields, \@previousData, \@staticFields);
CreateSummaryFile($QosmosWorkBookName,$ARGV[3],$excludeFilter,$includeFilter);

CheckRenameFile($QosmosWorkBookName,$includeFilter,$excludeFilter,%renameMapping,\@staticFields);
DumpFile($renameMap,\%renameMapping);

open qosmosWorkbook, "$ARGV[0]" or die $!;
while ( my $line = <qosmosWorkbook>) {
   @lineValues = split(/,/,$line);
   $field = "$lineValues[8]$lineValues[2]";
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
     $field = "$lineValues[8]$lineValues[2]";
     if ( $field =~ /^[0-9]/ ) {
        $field = "_$lineValues[8]$lineValues[2]";
     }
     if ($callbackNames !~ /,$field,/ ) {
        $requirement = "optional";
        $highest += 1;
        $type = $lineValues[10];
        $optionalStuff = "";
        if ($lineValues[10] =~ /timeval/ ) {
           $type = "string";
           $optionalStuff = ",timeval,timevalToString";
        } elsif ( $lineValues[10] =~ /ip_addr/ ) {
           $type = "string";
           $optionalStuff = ",uint32,ip_addrToString";
        } elsif ( $lineValues[10] =~ /mac_addr/ ) {
           $type = "string";
           $optionalStuff = ",clep_mac_addr_t,mac_addrToString";
        } elsif ($lineValues[10] eq "" ) {
           print "MALFORMED FILE!!!!";
           print "0:$lineValues[1],1:$lineValues[2],2:$lineValues[2],3:lineValues[4],4:$lineValues[5],5:$lineValues[6],6:$lineValues[7],7:$lineValues[8],8:$lineValues[9],9:$lineValues[10]";
           exit(1);
        } elsif ( $lineValues[10] =~ /string/ ) {
           $type = "bytes";
           $requirement = "repeated";
        }

        print "$requirement $type $field = $highest; // QOSMOS:$lineValues[2],$lineValues[7]$optionalStuff\n";
     }
  }
}


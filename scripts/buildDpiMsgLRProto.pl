#!/usr/bin/perl
#
#
#

use YAML::Any qw(Dump DumpFile);

# Read through the resources/Qosmos_Protobook.csv file. Ensure that all values use in the 
# protofile have rename mappings.
sub CheckRenameFile {
   my($qosmosFileName,$includeFilter,$excludeFilter,%renameMapping) = @_;
   # $staticField_ptr = $_[4]; - this line seems to have a typo (missing 'c')
   my $staticField_ptr = $_[4];

   my $filename = 'MissingAttributesReport.csv';
   open(my $missAttrFile, '>', $filename) or die "Could not open file '$filename' $!";
   print $missAttrFile "remapping file - missing attributes\n";
   # print $missAttrFile "Application,QProto Name,NetMon Old Name,Short Name,Long Name,Syslog Field,SIEM MPE Tag,SIEM Mapped Field (6.3 Name),SIEM Long Name 6.3,Status,Description\n";
   print $missAttrFile "Application,QProto Name,NetMon Old Name,Short Name,Long Name,Syslog Field,SIEM MPE Tag,SIEM Mapped Field (6.3 Name),SIEM Long Name 6.3,Status\n";

   open qosmosWorkbook, "$qosmosFileName" or die $!;
   my $mapGood = 1;
   while (<qosmosWorkbook>) {
      if ($_ =~ m/$includeFilter/ && $_ !~ /$excludeFilter/ ) {
         my @lineValues = parseCsv($_);
         if ( !defined $renameMapping { $lineValues[8] } &&
               !defined $renameMapping { "_$lineValues[8]" } ) {
            # The remapping file needs to have an entry in it for each attribute name in the Qosmos Workbook.
            # If there are missing attributes, work with Labs to get mappings assigned. Use an updated
            # NetMonFieldNames.csv file to complete the Protobuffer compilation.
            my $proto = $lineValues[2];
            $proto =~ s/Q_PROTO_//; 
            my $removedUnderscore = upperCamelCase($lineValues[8]);
            my $removedSpaces = $removedUnderscore;
            my @split = $removedSpaces =~ /([A-Z](?:[A-Z]*(?=$|[A-Z][a-z])|[a-z]*))/g;
            my $scal = join(" ", @split);
            # print $missAttrFile "$proto,$lineValues[8]$lineValues[2],$lineValues[8],$removedUnderscore,$scal,,,,,New,\"$lineValues[11]\"\n";
            print $missAttrFile "$proto,$lineValues[8]$lineValues[2],$lineValues[8],$removedUnderscore,$scal,,,,,New,\n";
            $mapGood = 0;
         } 
      } 
   }
   close $missAttrFile;

   if ($mapGood) {
      while (my($key,$value) = each (%renameMapping)) {
         my @matches =  grep { /$value/ } @$staticField_ptr; # use strict has a problem with this line
         if (@matches && $matches[0] eq $value ) {
            die "Rename file tries to map to a static field $value, $matches[0]";
         }
      }
   } else {
      die "**** BUILD FAILED ****\nNetMonFieldNames.csv needs to be updated by labs.\nSee $filename for list of missing attributes.\n";
   }

   close qosmosWorkbook;

}

use strict; # Trying to get more strict.

sub ReadFilters {
   my($filename) = @_;

   open filters, "$filename" or die $!;
   my $excludeFilter;
   my $includeFilter;
   while (<filters>) {
      if ($_ =~ m/^(?!#)!(\S+)/ ) {
         $excludeFilter .= $1;
      } elsif ($_ =~ m/^(?!#)(\S+)/ ) {
         $includeFilter .= $1;
      }
   }
   close filters;
   return ($excludeFilter,$includeFilter);
}

# Create an associative mapping between the pairs of values read from the filename passed
# to the function.
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
   my $highest_ptr = $_[1];
   my $ids_ptr = $_[2];
   my $callbackNames_ptr = $_[3];
   my $previousFields_ptr = $_[4];
   my $previousData_ptr = $_[5];
   # $statiField_ptr = $_[6]; - this line seems to have a typo (missing 'c')
   my $staticField_ptr = $_[6];

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
      } elsif ($_ =~ m/^(\/\/)(optional|repeated)\s+.*\s+(\w+)\s+=\s+(\d+)\;/) {
         push(@$ids_ptr,$4);
         if ( $4 > $$highest_ptr ) {
            $$highest_ptr = $4;
         }
         $$callbackNames_ptr .= "$3,";
         push(@$previousFields_ptr,$3);
         # Remove the // from the beginning of the string. The // will be re-added later if the
         # attribute is still on the blacklist
         my $removeCommentFromLine = substr $_, 2;
         push(@$previousData_ptr,$removeCommentFromLine);
      }
      if ( index($_,'Q_PROTO') == -1 && (index($_,'optional') != -1 || index($_,'repeated') != -1)) {
         my @lineValues = split(/\s+/,$_);
         push(@$staticField_ptr,$lineValues[3]);
      }

   }
   close previousData;
}

# shamelessly lifted from Perl Monks: http://www.perlmonks.org/?node_id=5722
sub parseCsv {
   my $text = shift; ## record containing comma-separated values
   my @new = ();
   ## the first part groups the phrase inside the quotes
   push(@new, $+) while $text =~ m{
      "([^\"\\]*(?:\\.[^\"\\]*)*)",?
        | ([^,]+),?
        | ,
      }gx;
   push(@new, undef) if substr($text, -1,1) eq ',';
   return @new; ## list of values that were comma-spearated
}

sub upperCamelCase {
   join '', map ucfirst, split '_', $_[0];
}

sub GetStartOfIpp {
   my $fileContents = 
   "#pragma once\n" .
   "#include <string>\n" .
   "#include <map>\n" .
   "const static std::unordered_map<std::string,std::string> renameMap({\n";

   return $fileContents;
}

sub GetEndOfIpp {
   my $fileContents = "}); // map end\n";
   return $fileContents;
}

sub FormatAsCppMap {
   my $key = $_[0];
   my $value = $_[1];
   my $mapString = "{\"" . $key . "\", \"" . $value . "\"}";
   return $mapString; 
}

# Using the NetMonFieldNames.csv provided by Labs, create a remapping file from the values in the 
# second and third columns for any row containing the Q_PROTO prefix.
sub CreateRemappingFile {
   my($remappingfile,$nmfieldnames,$ippfile) = @_;

   open nmfieldnamesFile, "$nmfieldnames" or die $!;
   open remappingFile, '>'."$remappingfile" or die $!; # Open $remappingFile for writing
   open ippFile, '>'. "$ippfile" or die $!;

   seek remappingFile, 0, 0; # Set file handle position to beginning of file
   seek ippFile, 0, 0;

   my $header = GetStartOfIpp();
   my $footer = GetEndOfIpp();
   print ippFile "$header";

   while (<nmfieldnamesFile>) {
      if ($_ =~ m/.*Q_PROTO.*/ ) {
         my @lineValues = split(/,/,$_);
         print remappingFile "$lineValues[2] $lineValues[3]\n";
         print ippFile FormatAsCppMap($lineValues[2], $lineValues[3]) . "\n";
         if (!eof){
            print ippFile ",";
         }
      }
   }
   print ippFile $footer . "\n";

   close nmfieldnamesFile;
   close remappingFile;
   close ippFile;

}

# ================== main starts here ================== 
# QosmosWorkBookName = resources/Qosmos_Protobook.csv 
#ARGV[0] is resources/Qosmos_Protobook.csv 
#ARGV[1] is protofiles/DpiMsgLRproto.proto.orig 
#ARGV[2] is resources/ProtocolFilters 
#ARGV[3] is resources/LuaProtoFieldDesc.csv 
#ARGV[4] is resources/remapping 
#ARGV[5] is resources/remapping.ipp 
#ARGV[6] is resources/NetMonFieldNames.csv 
#ARGV[7] is /tmp/buildDpiMsgLRProto2.$BASHPID

my $QosmosWorkBookName = $ARGV[0];

# Load a set of regex strings from resources/ProtocolFilters
my ($excludeFilter,$includeFilter) = ReadFilters($ARGV[2]);

# Update the remapping file using, 4 = resources/remapping, 6 = resources/NetMonFieldNames.csv
CreateRemappingFile($ARGV[4],$ARGV[6], $ARGV[5]);

# Get the new mapping of names to use
my(%renameMapping) = ReadRemappingFile($ARGV[4]);
my $renameMap = $ARGV[5]; # 5 = resource/remapping.yaml
if ($renameMap eq "" ) {
   die "Must name a path to output rename map $ARGV[5] $renameMap" ;
}

# Get a record of what was in the protofile for the previous protobundle using protofiles/DpiMsgLRproto.proto.orig.
# With each release of a new protobundle, it is important to keep the same association between each protofile
# enumeration value and Qosmos attribute.
my $highest;
my @ids;
my $callbackNames;
my @previousFields;
my @previousData;
my @staticFields;
ReadPreviousData($ARGV[1],\$highest, \@ids, \$callbackNames, \@previousFields, \@previousData, \@staticFields);

# Check to make sure every field in the resources/Qosmos_Protobook.csv has a remapping assigned to it.
CheckRenameFile($QosmosWorkBookName,$includeFilter,$excludeFilter,%renameMapping,\@staticFields);

# Create a temporary file at /tmp/buildDpiMsgLRProto2.$BASHPID. This is a scratch file used
# to sort the body contents of the DPI message by enum ID. A header and footer are added around
# the body contents.
open(my $dpiMsgProtoBody, '>', $ARGV[7]) or die "Could not open file '$ARGV[7]' $!";
seek $dpiMsgProtoBody, 0, 0; # Set file handle position to beginning of file

# Open resources/Qosmos_Protobook.csv and save the previously supported attributes
open qosmosWorkbook, "$ARGV[0]" or die $!;
while ( my $line = <qosmosWorkbook>) {
   # The split on comma works here since the description field, which sometimes contains a comma,
   # is in column 11 and not used here.
   my @lineValues = split(/,/,$line);
   my $field = "$lineValues[8]$lineValues[2]";
   my $index = 0;
   foreach (@previousData) {
      if ( $_ =~ /$field/ ) {
         if ($_ =~ /$excludeFilter/) {
            print $dpiMsgProtoBody "\/\/$_"; # Protobuffer output; comment out this blacklisted item.
         } else {
            print $dpiMsgProtoBody $_; # Protobuffer output; retain the previous enum value assignments
         }
         splice(@previousData, $index, 1);
      }
      $index += 1;
   }
}


# Create a resource/LuaProtoFieldDesc.csv file
open luaProtoFieldsCsv, '>'."$ARGV[3]" or die $!;
seek luaProtoFieldsCsv, 0, 0;
print luaProtoFieldsCsv "Protocol Name, Long Protocol Name, Attribute Name, Full Attribute Name, Attribute Type, Attribute Description\n";

# Add static fields to the Lua Protocol description file.
open (staticFieldsCsv, "<", "resources/StaticFields.csv") or die 'Could not open resources/StaticFields.csv';
while ( my $line = <staticFieldsCsv> ) {
   print luaProtoFieldsCsv $line;
}
print luaProtoFieldsCsv "\n";
seek qosmosWorkbook, 0, 0;
while (<qosmosWorkbook>) {
   # Include all attributes matching the includeFilter, but exclude the 19 attributes at the beginning 
   # of the Qosmos_Protobook.
   if ($_ =~ m/$includeFilter/ && $_ !~ ",\.,,,,," ) {
      my @lineValues = parseCsv($_);
      my $field = "$lineValues[8]$lineValues[2]";
      if ( $field =~ /^[0-9]/ ) {
         $field = "_$lineValues[8]$lineValues[2]";
      }
      my $requirement = "optional";
      my $type = $lineValues[10];
      my $optionalStuff = "";

      if ($lineValues[10] =~ /timeval/) {
         $type = "string";
         $optionalStuff = ",timeval,timevalToString";
      } elsif ($lineValues[10] =~ /ip_addr/) {
         $type = "string";
         $optionalStuff = ",uint32,ip_addrToString";
      } elsif ($lineValues[10] =~ /mac_addr/) {
         $type = "string";
         $optionalStuff = ",clep_mac_addr_t,mac_addrToString";
      } elsif ($lineValues[10] eq "") {
         print $ARGV[0]." MALFORMED FILE!!!!\n";
         print $ARGV[0]." 0:$lineValues[1],1:$lineValues[2],2:$lineValues[2],3:lineValues[4],4:$lineValues[5],5:$lineValues[6],6:$lineValues[7],7:$lineValues[8],8:$lineValues[9],9:$lineValues[10]\n";
         exit(1);
      } elsif ($lineValues[10] =~ /string/) {
         $type = "bytes";
         $requirement = "repeated";
      } elsif ($lineValues[10] =~ /parent/) {
         $type = "bool";
      } elsif ($lineValues[10] =~ /ptr/) {
         $type = "Void";
      }
      if ($callbackNames !~ /,$field,/ ) {
         $highest += 1;
         if ($_ !~ /$excludeFilter/ ) {
            # Protobuffer output; add new attribute.
            print $dpiMsgProtoBody "$requirement $type $field = $highest; // QOSMOS:$lineValues[2],$lineValues[7]$optionalStuff\n";
         } else {
            # Protobuffer output. Add new attribute, but commented out since it is blacklisted
            print $dpiMsgProtoBody "//$requirement $type $field = $highest; // QOSMOS:$lineValues[2],$lineValues[7]$optionalStuff\n";
         }
      }
      if ($_ !~ /$excludeFilter/ ) {
         my $lcField = lc($field);
         print luaProtoFieldsCsv "$lineValues[4], $lineValues[5], $lineValues[8], $lcField, $type, \"$lineValues[11]\"\n";
      }
   }
}

close qosmosWorkbook;
close luaProtoFieldsCsv;
close $dpiMsgProtoBody;

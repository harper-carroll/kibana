sub trim($)
{
   my $string = shift;
   $string =~ s/^\s+//;
   $string =~ s/\s+$//;
   return $string;
}
# Left trim function to remove leading whitespace
sub ltrim($)
{
   my $string = shift;
   $string =~ s/^\s+//;
   return $string;
}
# Right trim function to remove trailing whitespace
sub rtrim($)
{
   my $string = shift;
   $string =~ s/\s+$//;
   return $string;
}

$header = "#pragma once
#include <iostream>
#include <string>
#include <unordered_map>
typedef std::unordered_map<std::string,std::string> stringmap;\n";

sub createUnorderedMap($)
{
   my $params = shift;
   my %paramHash = %$params;
   my $mapStart = "static stringmap qosmosSyslogMap ({";
   my $mapEnd = "\n});\n";
   my $mapElements = "";
   while (my ($key,$value)=each %paramHash) {
      $mapElements = $mapElements."\n\t{\"$key\",\"$value\"},";
   }
   chop($mapElements);
   $codeString = $header.$mapStart.$mapElements.$mapEnd;
   open (OUTFILE, '>resources/qosmosSyslogMap.hh');
   print OUTFILE $codeString;
   close (OUTFILE);
}


my $file = 'resources/QosmosSyslogMapping.csv';
my @data;
my $firstLine = 0;
my %syslogHash;
open qosmosWorkbook, "$file" or die "Can't read file '$file' [$!]\n";
while (<qosmosWorkbook>) {
   if ($firstLine == 0) {
      $firstLine = 1;
      next;
   }
   $line = rtrim(ltrim(trim($_)));
   my @fields = split(/,/, $line);
   my $qosmosField = $fields[1];
   my $syslogField = $fields[2];
   if (exists $syslogHash{$qosmosField}) {
      push @{$syslogHash{$qosmosField}}, $syslogField;
   } else {
      $syslogHash{$qosmosField} = $syslogField;
   }
}
createUnorderedMap(\%syslogHash);


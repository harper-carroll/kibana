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

sub createUnorderedMap($$)
{
   my ($param1, $param2)  = (@_);
   my %paramHash = %$param1;
   my $outFile = $param2;

   my $mapStart = "static stringmap qosmosSyslogMap ({";
   my $mapEnd = "\n});\n";
   my $mapElements = "";
   while (my ($key,$value)=each %paramHash) {
      $mapElements = $mapElements."\n\t{\"$key\",\"$value\"},";
   }
   chop($mapElements);
   $codeString = $header.$mapStart.$mapElements.$mapEnd;

   open (OUTFILE, ">$outFile");
   print OUTFILE $codeString;
   close (OUTFILE);
}


my $file = $ARGV[0];
my $outFile = $ARGV[1];
my @data;
my $firstLine = 0;
my %syslogHash;
open qosmosWorkbook, "$file" or die "Can't read file '$file' [$!]\n";
while (<qosmosWorkbook>) {
   if ($firstLine == 0 || (index($_,'Q_PROTO') == -1)) {
      $firstLine = 1;
      next;
   }
   $line = rtrim(ltrim(trim($_)));
   my @fields = split(/,/, $line);
   my $qosmosField = $fields[1];
   my $syslogField = $fields[5];

   if (exists $syslogHash{$qosmosField}) {
      push @{$syslogHash{$qosmosField}}, $syslogField;
   } else {
      $syslogHash{$qosmosField} = $syslogField;
   }
}

createUnorderedMap(\%syslogHash, $outFile);


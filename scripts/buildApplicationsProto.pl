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
my %previousLines = ();
my @newFields;
my %newComments = ();
my $highest = 1;
my $callbackNames = ",";
while (<previousData>) {
   if ($_ =~ m/^(required|optional|repeated)\s+.*\s+_*(\w+)\s+=\s+(\d+)/) {
      push(@ids,$3);
      if ( $3 > $highest ) {
         $highest = $3;
      }
      $callbackNames .= "$2,";
      push(@previousFields,$2);
      $previousLines{$2} = $_;
   }
}
close previousData;

#print "$callbackNames\n";

while ( my $line = <qosmosWorkbook>) {
   @lineValues = split(/,/,$line);
   $field = "$lineValues[3]";
   if ($field) {
     push(@newFields,$field);
     $newComments{$field} = $lineValues[7];
     $newComments{$field} =~ s/\"//g;
   }
}

%union = ();
foreach $field (@previousFields, @newFields) {
   $union{$field} = 1;
}

@allFields = keys %union;
$requirement = "optional";
$type = "string";

foreach $field (@allFields) {
   if ($previousLines{$field} ) {
      print $previousLines{$field};
   } else {
      $highest += 1;
      $fieldName = $field;
      if ($field =~ /^[0-9]/ ) {
         $fieldName = "_" . $field;
      }
      print "$requirement $type $fieldName = $highest [default = \"$newComments{$field}\"];
";
   }
}

#!/usr/bin/perl
#
# usage: buildUIFieldMap.pl resources/NetMonFieldNames.csv jsFile.js
#
sub ReadFile {
   my $filename = $_[0];
   my $typeHash_ptr = $_[1];

   open previousData, "$filename" or die "cannot open $filename: $!";
   while (<previousData>) {
     my ($app, $protoName, $oldName, $shortName, $longName, $syslogName) = split /,/, $_;
     $shortName=~ s/^\s+|\s+$//g;
     $longName=~ s/^\s+|\s+$//g;
     if($shortName eq "" || $longName eq "") {
       print "fields are emtpy... short: $shortName long: $longName\n";
       next;
     }
     print $shortName.':'.$longName."\n";
     $$typeHash_ptr{$shortName}=$longName;

   }
   close previousData;
}

%typeHash= {};

if(!defined $ARGV[0] || !defined $ARGV[1]) {
  print "Expecting two params: ./scripts/builUIFieldMap.pl /path/to/protomsg filename\n";
  exit -1;
}
my $protoFile = $ARGV[0];
my $outputFile = $ARGV[1];

ReadFile($protoFile,\%typeHash);

if(!-d "js") {
   print "Creating js directory \n";
  mkdir("js");
}
my $fileName = "js/".$outputFile;

print $fileName ."\n";
open WRITE , ">$fileName" or die "cannot open $fileName: $!";

print WRITE "var getFieldMap = function() { \n";
print WRITE "var fieldMap = { \n";
my $count =0;
for my $key (keys %typeHash) {
	if($count == 0) {
	print WRITE "'".lc($key)."' : '$key'";
	} else {
		print WRITE ",\n'".lc($key)."' : '$key'";
	}
	my $hash = $typeHash{$key};
	++$count;
}
print WRITE "\n};\n return fieldMap;\n};";



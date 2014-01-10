#!/usr/bin/perl
#
# usage: buildESTemplate.pl protofile renamefile
#
sub ReadProtoFile {
   my($filename) = $_[0];
   $typeHash_ptr = $_[1];
   
   open previousData, "$filename" or die "cannot open $filename: $!";
   while (<previousData>) {
      if ($_ =~ m/^(optional|repeated)\s+(\w+)\s+(\w+)Q_PROTO.*;/) {
         $$typeHash_ptr{$3}{$2} = 1;
      }
   }
   close previousData;
}

open renameFile, '<', "$ARGV[1]" or die "Cannot open rename file: $!";
my $renameStream;
my %typeHash = ();
my %remapping = ();
while (<renameFile>) {
   if ($_ =~ m/(\S+)\s+(\S+)/ ) {
      $remapping{$1} = $2;
   }
}

ReadProtoFile($ARGV[0],\%typeHash);
for $app ( keys %typeHash ) {
   if ($app eq "timestamp" || $app eq "syslogMessage" ) {
      print "\"$remapping{$app}\" : { \"type\" : \"string\", \"store\" : \"no\", \"index\" : \"not_analyzed\", \"ignore_malformed\" : true },\n"
   } elsif ($app eq "fileId" || $app eq "application" || $app eq "applicationEnd" || $app eq "applicationId" || $app eq "applicationIdEnd" ) {
      print "\"$remapping{$app}\" : { \"type\" : \"object\", \"enabled\" : false },\n"
   } elsif ( keys %{ $typeHash{$app} } > 1) {
      print "\"$remapping{$app}\" : { \"type\" : \"string\", \"store\" : \"yes\", \"ignore_malformed\" : true},\n"
   }
}

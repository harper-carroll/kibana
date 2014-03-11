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
my %uniqueNames = ();
while (<renameFile>) {
   if ($_ =~ m/(\S+)\s+(\S+)/ ) {
      if (! exists $uniqueNames{$2} ) {
         $remapping{$1} = $2;
         $uniqueNames{$2} = 1;
      }
   }
}

ReadProtoFile($ARGV[0],\%typeHash);

print "\"_source\" : {\n";
print "\"excludes\" : ";
print "[";
print "\"$remapping{application}\", ";
print "\"$remapping{application_end}\", ";
print "\"$remapping{application_id}\", ";
print "\"$remapping{application_id_end}\", ";
print "\"FileID\" ";
print "]\n";
print "},\n";
print "\"properties\" : {\n";
print "\"SrcIP\"  : { \"type\": \"ip\", \"ignore_malformed\" : true },\n";
print "\"DestIP\"  : { \"type\": \"ip\", \"ignore_malformed\" : true },\n";
print "\"TimeStart\" : { \"format\": \"yyyy/MM/dd HH:mm:ss||yyyy/MM/dd||yyyy-MM-dd'T'HH:mm:ss.SSSZZ\", \"type\": \"date\"},\n";
print "\"TimeUpdated\" : { \"format\": \"yyyy/MM/dd HH:mm:ss||yyyy/MM/dd||yyyy-MM-dd'T'HH:mm:ss.SSSZZ\", \"type\": \"date\"},\n";
print "\"TimeTotal\" : { \"type\": \"long\", \"ignore_malformed\" : true },\n";
print "\"TimeDelta\" : { \"type\": \"long\", \"ignore_malformed\" : true },\n";
print "\"Captured\" : { \"type\": \"string\", \"null_value\": \"false\"},\n";
print "\"Session\" : {\"type\": \"string\", \"index\" : \"not_analyzed\"},\n";
print "\"SrcMAC\" : {\"type\" : \"string\", \"index\" : \"not_analyzed\", \"ignore_malformed\" : true},\n";


for $app ( keys %typeHash ) {
   if ($app eq "Timestamp" || $app eq "SyslogMessage" ) {
      print "\"$remapping{$app}\" : { \"type\" : \"string\", \"store\" : \"no\", \"index\" : \"not_analyzed\", \"ignore_malformed\" : true },\n"
   } elsif ($app eq "FileID" || $app eq "Application" || $app eq "ApplicationEnd" || $app eq "ApplicationID" || $app eq "ApplicationIDEnd" ) {
      print "\"$remapping{$app}\" : { \"type\" : \"object\", \"enabled\" : false },\n"
   } elsif ($app eq "index" || $app eq "CallID" || $app eq "Version" || $app eq "DeviceType" ) {
      print "\"$remapping{$app}\" : { \"type\" : \"string\", \"index\" : \"not_analyzed\", \"store\" : \"yes\", \"ignore_malformed\" : true},\n"
   } elsif ($app eq "DeviceType" ) {
      print "\"$remapping{$app}\" : { \"type\" : \"string\", \"index\" : \"not_analyzed\", \"ignore_malformed\" : true},\n"
   } elsif ($app eq "ServerAddr" || $app eq "ClientAddr" ) {
      print "\"$remapping{$app}\" : { \"type\": \"ip\", \"ignore_malformed\" : true},\n"
   } elsif ($app eq "ttl"  ) {
      print "\"$remapping{$app}\" : { \"type\" : \"long\", \"store\" : \"yes\", \"index\": \"not_analyzed\", \"ignore_malformed\" : true },\n"
   } elsif ( keys %{ $typeHash{$app} } > 1) {
      if ( exists $remapping{$app} ) {
         print "\"$remapping{$app}\" : { \"type\" : \"string\", \"store\" : \"yes\", \"ignore_malformed\" : true},\n"
      }
   }
}
print "\"DestMAC\" : {\"type\" : \"string\", \"index\" : \"not_analyzed\", \"ignore_malformed\" : true}\n";
print "}\n";
print "}\n";



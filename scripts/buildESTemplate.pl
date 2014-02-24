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

print "\"_source\" : {\n";
print "\"excludes\" : ";
print "[";
print "\"$remapping{application}\", ";
print "\"$remapping{application_end}\", ";
print "\"$remapping{application_id}\", ";
print "\"$remapping{application_id_end}\", ";
print "\"#file_id\" ";
print "]\n";
print "},\n";
print "\"properties\" : {\n";
print "\"ip_source\"  : { \"type\": \"ip\", \"ignore_malformed\" : true },\n";
print "\"ip_dest\"  : { \"type\": \"ip\", \"ignore_malformed\" : true },\n";
print "\"time_start\" : { \"format\": \"yyyy/MM/dd HH:mm:ss||yyyy/MM/dd||yyyy-MM-dd'T'HH:mm:ss.SSSZZ\", \"type\": \"date\"},\n";
print "\"time_updated\" : { \"format\": \"yyyy/MM/dd HH:mm:ss||yyyy/MM/dd||yyyy-MM-dd'T'HH:mm:ss.SSSZZ\", \"type\": \"date\"},\n";
print "\"time_total\" : { \"type\": \"long\", \"ignore_malformed\" : true },\n";
print "\"time_delta\" : { \"type\": \"long\", \"ignore_malformed\" : true },\n";
print "\"captured\" : { \"type\": \"string\", \"null_value\": \"false\"},\n";
print "\"session_id\" : {\"type\": \"string\", \"index\" : \"not_analyzed\"},\n";
print "\"mac_source\" : {\"type\" : \"string\", \"index\" : \"not_analyzed\", \"ignore_malformed\" : true},\n";


for $app ( keys %typeHash ) {
   if ($app eq "timestamp" || $app eq "syslog_message" ) {
      print "\"$remapping{$app}\" : { \"type\" : \"string\", \"store\" : \"no\", \"index\" : \"not_analyzed\", \"ignore_malformed\" : true },\n"
   } elsif ($app eq "file_id" || $app eq "application" || $app eq "application_end" || $app eq "application_id" || $app eq "application_id_end" ) {
      print "\"$remapping{$app}\" : { \"type\" : \"object\", \"enabled\" : false },\n"
   } elsif ($app eq "index" || $app eq "call_id" || $app eq "version" || $app eq "device_type" ) {
      print "\"$remapping{$app}\" : { \"type\" : \"string\", \"index\" : \"not_analyzed\", \"store\" : \"yes\", \"ignore_malformed\" : true},\n"
   } elsif ($app eq "device_type" ) {
      print "\"$remapping{$app}\" : { \"type\" : \"string\", \"index\" : \"not_analyzed\", \"ignore_malformed\" : true},\n"
   } elsif ($app eq "server_addr" || $app eq "client_addr" ) {
      print "\"$remapping{$app}\" : { \"type\": \"ip\", \"ignore_malformed\" : true},\n"
   } elsif ($app eq "ttl"  ) {
      print "\"$remapping{$app}\" : { \"type\" : \"long\", \"store\" : \"yes\", \"index\": \"not_analyzed\", \"ignore_malformed\" : true },\n"
   } elsif ( keys %{ $typeHash{$app} } > 1) {
      print "\"$remapping{$app}\" : { \"type\" : \"string\", \"store\" : \"yes\", \"ignore_malformed\" : true},\n"
   }
}
print "\"mac_dest\" : {\"type\" : \"string\", \"index\" : \"not_analyzed\", \"ignore_malformed\" : true}\n";
print "}\n";
print "}\n";



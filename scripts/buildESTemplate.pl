#!/usr/bin/perl
#
# usage: buildESTemplate.pl protofile renamefile indexType
# note: The last param above (indexType is optional), if specified, it will add the extra fields necessary for that index
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
      $remapping{$1} = $2;
      if (! exists $uniqueNames{$2} ) {
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
print "\"CaptureKey\", ";
print "\"FileID\" ";
print "]\n";
print "},\n";
print "\"properties\" : {\n";
print "\"SrcIP\"  : { \"type\": \"ip\", \"ignore_malformed\" : true },\n";
print "\"SrcIP6\"  : { \"type\": \"string\", \"index\" : \"not_analyzed\", \"ignore_malformed\" : true },\n";
print "\"DestIP\"  : { \"type\": \"ip\", \"ignore_malformed\" : true },\n";
print "\"DestIP6\"  : { \"type\": \"string\", \"index\" : \"not_analyzed\", \"ignore_malformed\" : true },\n";
print "\"TimeStart\" : { \"format\": \"yyyy/MM/dd HH:mm:ss||yyyy/MM/dd||yyyy-MM-dd'T'HH:mm:ss.SSSZZ\", \"type\": \"date\"},\n";
print "\"TimeUpdated\" : { \"format\": \"yyyy/MM/dd HH:mm:ss||yyyy/MM/dd||yyyy-MM-dd'T'HH:mm:ss.SSSZZ\", \"type\": \"date\"},\n";
print "\"TimeTotal\" : { \"type\": \"long\", \"ignore_malformed\" : true},\n";
print "\"TimeEnd\" : { \"type\": \"long\", \"ignore_malformed\" : true},\n";
print "\"TimeStartRaw\" : { \"type\": \"long\", \"ignore_malformed\" : true, \"index\" : \"no\", \"store\" : false },\n";
print "\"TimeUpdatedRaw\" : { \"type\": \"long\", \"ignore_malformed\" : true, \"index\" : \"no\", \"store\" : false },\n";
print "\"TimeDelta\" : { \"type\": \"long\", \"ignore_malformed\" : true },\n";
print "\"Captured\" : { \"type\": \"string\", \"null_value\": \"false\"},\n";
print "\"Session\" : {\"type\": \"string\", \"index\" : \"not_analyzed\"},\n";
print "\"SrcMAC\" : {\"type\" : \"string\", \"index\" : \"not_analyzed\", \"ignore_malformed\" : true},\n";

# Add raw mappings for some fields so that they are regex searchable
# Email
print "\"ReceiverDomain\" : {\"type\": \"string\", \"fields\": {\"raw\": {\"type\": \"string\", \"index\": \"not_analyzed\"}}},\n";
print "\"ReceiverAlias\" : {\"type\": \"string\", \"fields\": {\"raw\": {\"type\": \"string\", \"index\": \"not_analyzed\"}}},\n";
print "\"ReceiverEmail\" : {\"type\": \"string\", \"fields\": {\"raw\": {\"type\": \"string\", \"index\": \"not_analyzed\"}}},\n";
print "\"SenderDomain\" : {\"type\": \"string\", \"fields\": {\"raw\": {\"type\": \"string\", \"index\": \"not_analyzed\"}}},\n";
print "\"SenderAlias\" : {\"type\": \"string\", \"fields\": {\"raw\": {\"type\": \"string\", \"index\": \"not_analyzed\"}}},\n";
print "\"SenderEmail\" : {\"type\": \"string\", \"fields\": {\"raw\": {\"type\": \"string\", \"index\": \"not_analyzed\"}}},\n";
print "\"Subject\" : {\"type\": \"string\", \"fields\": {\"raw\": {\"type\": \"string\", \"index\": \"not_analyzed\"}}},\n";
print "\"FileType\" : {\"type\": \"string\", \"fields\": {\"raw\": {\"type\": \"string\", \"index\": \"not_analyzed\"}}},\n";
print "\"Filename\" : {\"type\": \"string\", \"fields\": {\"raw\": {\"type\": \"string\", \"index\": \"not_analyzed\"}}},\n";
print "\"AttachType\" : {\"type\": \"string\", \"fields\": {\"raw\": {\"type\": \"string\", \"index\": \"not_analyzed\"}}},\n";
# Non Email
print "\"UserAgent\" : {\"type\": \"string\", \"fields\": {\"raw\": {\"type\": \"string\", \"index\": \"not_analyzed\"}}},\n";
print "\"Family\" : {\"type\": \"string\", \"fields\": {\"raw\": {\"type\": \"string\", \"index\": \"not_analyzed\"}}},\n";
print "\"Login\" : {\"type\": \"string\", \"fields\": {\"raw\": {\"type\": \"string\", \"index\": \"not_analyzed\"}}},\n";
print "\"Referer\" : {\"type\": \"string\", \"fields\": {\"raw\": {\"type\": \"string\", \"index\": \"not_analyzed\"}}},\n";
print "\"URIFull\" : {\"type\": \"string\", \"fields\": {\"raw\": {\"type\": \"string\", \"index\": \"not_analyzed\"}}},\n";
print "\"Cookie\" : {\"type\": \"string\", \"fields\": {\"raw\": {\"type\": \"string\", \"index\": \"not_analyzed\"}}},\n";
print "\"HeaderName\" : {\"type\": \"string\", \"fields\": {\"raw\": {\"type\": \"string\", \"index\": \"not_analyzed\"}}},\n";


if ( $ARGV[2] eq "events" ) {
	print "\"RuleName\" : {\"type\" : \"string\", \"ignore_malformed\" : true},\n";
	print "\"RuleSeverity\" : {\"type\" : \"string\", \"ignore_malformed\" : true},\n";
}

if ( $ARGV[2] eq "rules" ) {
	print "\"enabled\" : { \"type\" : \"boolean\" },\n";
	print "\"severity\" : { \"type\" : \"string\" },\n";
	print "\"query\" : { \"type\" : \"object\" },\n";
	print "\"createdDate\" : { \"format\" : \"yyyy/MM/dd HH:mm:ss||yyyy/MM/dd||yyyy-MM-dd'T'HH:mm:ss.SSSZZ\", \"type\" : \"date\" },\n";
	print "\"lastModifiedDate\" : { \"format\" : \"yyyy/MM/dd HH:mm:ss||yyyy/MM/dd||yyyy-MM-dd'T'HH:mm:ss.SSSZZ\", \"type\" : \"date\" },\n";
}

for $app ( keys %typeHash ) {
   if ($app eq "Timestamp" || $app eq "SyslogMessage" ) {
      print "\"$remapping{$app}\" : { \"type\" : \"string\", \"store\" : false, \"index\" : \"not_analyzed\", \"ignore_malformed\" : true },\n"
   } elsif ($app eq "FileID" || $app eq "Application" || $app eq "ApplicationEnd" || $app eq "ApplicationID" || $app eq "ApplicationIDEnd" ) {
      print "\"$remapping{$app}\" : { \"type\" : \"object\", \"enabled\" : false },\n"
   } elsif ($app eq "index" || $app eq "CallID" || $app eq "Version" || $app eq "DeviceType" ) {
      print "\"$remapping{$app}\" : { \"type\" : \"string\", \"index\" : \"not_analyzed\", \"store\" : true, \"ignore_malformed\" : true},\n"
   } elsif ($app eq "DeviceType" ) {
      print "\"$remapping{$app}\" : { \"type\" : \"string\", \"index\" : \"not_analyzed\", \"ignore_malformed\" : true},\n"
   } elsif ($app eq "ServerAddr" || $app eq "ClientAddr" ) {
      print "\"$remapping{$app}\" : { \"type\": \"ip\", \"ignore_malformed\" : true},\n"
   } elsif ($app eq "ttl"  ) {
      print "\"$remapping{$app}\" : { \"type\" : \"long\", \"store\" : true, \"index\": \"not_analyzed\", \"ignore_malformed\" : true },\n"
   } elsif ( keys %{ $typeHash{$app} } > 1) {
      if ( exists $remapping{$app} ) {
         print "\"$remapping{$app}\" : { \"type\" : \"string\", \"store\" : true, \"ignore_malformed\" : true},\n"
      }
   }
}
print "\"DestMAC\" : {\"type\" : \"string\", \"index\" : \"not_analyzed\", \"ignore_malformed\" : true}\n";
print "}\n";
print "}\n";



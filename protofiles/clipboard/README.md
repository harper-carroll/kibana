#Go build issue workaround

There is a defeact out for this issue in goprotobuf but right now you need to folow these steps to build the go version.

* copy the message from counter measure and sample into clipboard
* mv or rm the messages for counter measure and sample.
* go to the main folder and run sh scripts/buildProtoFilesGo.sh
***MAKE SURE NOT TO COMMIT THE PROTO FILE CHANGES IT WILL BREAK THE JAVA BUILD***

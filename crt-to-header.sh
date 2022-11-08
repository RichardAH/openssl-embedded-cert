#!/bin/bash
stat ca-bundle.crt >/dev/null 2>/dev/null
if [ "$?" -ne "0" ]
then
    echo 'ca-bundle.crt not found in working directory'
    exit 1
fi
OUTFILE='certbundle.h'
echo '#include <string>' > $OUTFILE
echo '#ifndef EMBEDDED_CA_BUNDLE' >> $OUTFILE
echo '#define EMBEDDED_CA_BUNDLE' >> $OUTFILE
echo 'constexpr std::string ca_bundle = R"endofcabundle(' >> $OUTFILE
cat ca-bundle.crt >> $OUTFILE
echo ')endofcabundle";' >> $OUTFILE
echo '#endif EMBEDDED_CA_BUNDLE' >> $OUTFILE

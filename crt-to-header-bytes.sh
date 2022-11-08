#!/bin/bash
stat ca-bundle.crt >/dev/null 2>/dev/null
if [ "$?" -ne "0" ]
then
    echo 'ca-bundle.crt not found in working directory'
    exit 1
fi
OUTFILE='certbundle.h'
START="\-{5}BEGIN CERTIFICATE\-{5}"
END="\-{5}END CERTIFICATE\-{5}"
FIRSTRUN=1
echo '#ifndef EMBEDDED_CA_BUNDLE' > $OUTFILE
echo '#define EMBEDDED_CA_BUNDLE' >> $OUTFILE
echo 'std::vector<std::vector<uint8_t>> ca_bundle = ' >> $OUTFILE
echo '{' >> $OUTFILE
cat ca-bundle.crt | 
    grep -vE '^#|^$' |
        tr -d '\n' | 
        grep -Po "$START.*?$END" | 
        sed -E "s/$START//g" | 
        sed -E "s/$END//g" |
while read -r line
do
    HEX=`base64 -d <<< $line | xxd -p | tr -d '\n' | tr '[:lower:]' '[:upper:]'`
    COUNT=`echo $HEX | tr -d '\n' | wc -c`
    ODD=$(($COUNT % 2))
    if [ "$ODD" -eq "1" ]
    then
        HEX="0$HEX"
    fi
    if [ "$FIRSTRUN" -eq "1" ]
    then
        FIRSTRUN=0
    else
        echo ',' >> $OUTFILE
    fi
    echo '    {' >> $OUTFILE
    echo $HEX | 
        sed -E 's/../0x\0U,/g' | 
        sed -E 's/,$//g' |
        sed -E 's/(0x[0-9A-F][0-9A-F]?U,){16}/\0\n/g' |
        sed -E 's/^/        /g' >> $OUTFILE
    echo '    }' | tr -d '\n' >> $OUTFILE
done
echo '' >> $OUTFILE
echo '}' >> $OUTFILE
echo '#endif EMBEDDED_CA_BUNDLE' >> $OUTFILE
echo "Wrote `cat ca-bundle.crt | grep -Eo "$START" | wc -l` certificates to $OUTFILE!" 

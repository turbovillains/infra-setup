#!/usr/bin/bash -eux

# Customer bootstrap.R
FILE="/srv/shiny-server/master/bootstrap.R"
if [ -f "$FILE" ]; then
    echo "######### Found script $FILE, running Rscript $FILE #########"
    Rscript "$FILE"
else
    echo "Warning: Did not find $FILE. Dependencies could be missing"
fi

/usr/bin/shiny-server $@

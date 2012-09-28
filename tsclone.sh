#!/bin/bash

# !IMPORTANT!
# This script does NOT currently work when not forking. Don't use it for cloning the main repo yet! :)
# This script also requires that you have virtualenvwrapper installed: http://www.doughellmann.com/projects/virtualenvwrapper/
# You may need to change the SHEBANG above if you use something other than bash

# usage ts-clone <bitbucket repository url> <fork name> <virtualenv directory>
#
# e.g. ts-clone ssh://hg@bitbucket.org/lucasmoellers/tireswing-fb-private-messages fb-pm Documents/workspace/tireswing-repos
#
#

# CONFIGURATION
FORK_DIR="$HOME/$2/$3"

VIRTUAL_ENV_NAME="$3"

RC_FILE="$HOME/.`/usr/bin/basename $SHELL`"rc
echo $RC_FILE
source $RC_FILE
deactivate || true

######
echo "Making a virtualenv for fork $1..."
mkvirtualenv $VIRTUAL_ENV_NAME

# don't bother continuing if we can't make the virtualenv
if [[ $? -ne 0 ]] ; then
    exit 1
fi
echo -e "done.\n"
######

######
echo "Cloning and setting up tireswing fork..."
mkdir -p $FORK_DIR
cd $FORK_DIR

hg clone $1 tireswing
echo -e "done.\n"
######

######
echo "Configuring virtualenv PYTHONPATH to include tireswing..."
add2virtualenv `pwd`/tireswing
echo -e "done.\n"
######

######
echo "Adding mercurial [path] specifier to sproutsocial/tireswing as main..."
cd tireswing
echo "main = ssh://hg@bitbucket.org/sproutsocial/tireswing" >> .hg/hgrc
echo -e "done.\n"
######

######
echo "Adding pre-push, and pre-qfinish unittest hooks..."
echo "[hooks]" >> .hg/hgrc
echo "pre-push.runtests = python manage.py test" >> .hg/hgrc
echo "pre-qfinish.runtests = python manage.py test" >> .hg/hgrc
echo -e "done.\n"
######

######
echo "Copying default_settings_local.py to settings_local.py..."
cp default_settings_local.py settings_local.py
echo -e "done.\n"
######

######
echo "Installing requirements.txt to virtualenv"
pip install -r requirements.txt
echo -e "done.\n"
######

######
echo "Setting .venv file..."
echo "$VIRTUAL_ENV_NAME" > .venv
echo -e "done.\n"
######

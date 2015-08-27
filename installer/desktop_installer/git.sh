
ENTRY=`zenity --forms --title="Git Info" --text="Please fill in all information below:" --add-entry="Username:" --add-entry="Email:"`

USERNAME=`echo $ENTRY | cut -d'|' -f1`
EMAIL=`echo $ENTRY | cut -d'|' -f2`

git config --global user.name $USERNAME
git config --global user.email $EMAIL

git config --global core.editor vi

# Configure Alias
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status

git config --global alias.lg  "log --graph --decorate" 

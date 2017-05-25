# ------------------------------------------------------------
# 1. Aliases
# ------------------------------------------------------------

alias ll='ls -FGlAhp'
alias less='less -FSRXc'
alias cp='cp -iv'
alias mv='mv -iv'
alias mkdir='mkdir -pv'
alias cd..='cd ../'
alias ..='cd ../'
alias ...='cd ../../'
alias .3='cd ../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../../'
alias .6='cd ../../../../../../'
alias ~='cd ~'
alias lr='ls -R | grep ":$" | sed -e '\''s/:$//'\'' -e '\''s/[^-][^\/]*\//--/g'\'' -e '\''s/^/   /'\'' -e '\''s/-/|/'\'' | less'

alias gocode='cd ~/Code/professional'
alias goc='gocode'
alias govag='cd ~/professional-boxes/probox56'
alias gowww='cd /usr/local/var/www/htdocs'
alias fb='findBranch'
alias fr='findReleaseBranch'
alias cb='cleanUpBranches'

# ------------------------------------------------------------
# 2.  Exports
# ------------------------------------------------------------

export BLOCKSIZE=1k
export PATH="$/bin:/usr/local/devops/bin:$PATH"
export PATH="~/Code/professional/vendor/bin:$PATH"
export EDITOR=/usr/bin/vim

# ------------------------------------------------------------
# 3.  PS1
# ------------------------------------------------------------

export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad
export PS1="\[\e[0;34m\]\u@\h\[\e[m\] \[\e[0;35m\]\w\[\e[m\]\[\e[m\]\[\e[0;36m\]\[\e[0;33m\] \$(getGitBranchForDisplay) \[\e[0;34m\]\$ "


# ------------------------------------------------------------
# 4. Functions
# ------------------------------------------------------------

getGitBranchForDisplay() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/\(* \([a-zA-Z].*\/[a-zA-Z].*-[0-9]\{1,5\}\).*\)/(\2)/'
}

findBranch() {
    getReleaseBranch=false
    copyToBuffer=false
    valueToSearch=false

    for i in "$@" ; do
        [ $getReleaseBranch != true -a $i == "-r" ] && getReleaseBranch=true || getReleaseBranch=$getReleaseBranch
        [ $copyToBuffer != true -a $i == "-c" ] && copyToBuffer=true || copyToBuffer=$copyToBuffer
        [[ $i =~ ^[+-]?[0-9]+\.?[0-9]*$ ]] && valueToSearch=$i || valueToSearch=$valueToSearch
    done

    if [ $valueToSearch == false ] ; then
        echo "Usage: findBranch [-r=Release Branch] [-c=Copy to Buffer] NumberToSearch"
        return
    fi

    if [ $getReleaseBranch == true ] ; then
        commandToRun="findReleaseBranch"
    else
        commandToRun="findProBranch"
    fi

    if [ $copyToBuffer == true ] ; then
        commandToRun+=" -c"
    fi

    commandToRun+=" $valueToSearch"

    $commandToRun
}

findReleaseBranch() {
    [[ $1 = "-c" ]] && versionNumber="$2" || versionNumber="$1"
    [[ $1 = "-c" ]] && copyToBuffer=true || copyToBuffer=false

    if [ $versionNumber ] ; then
        grepString="refs/remotes/origin/release/professional_.*$versionNumber"
        findBranch=`git show-ref | grep $grepString | sed 's/.*refs\/remotes\/origin\///'`

        if [ $copyToBuffer = true ] ; then
            echo $findBranch | pbcopy
        fi

        echo $findBranch
    else
        echo "Usage: findReleaseBranch [-c] VersionNumber"
    fi
}

findProBranch() {
    [[ $1 = "-c" ]] && ticketId="$2" || ticketId="$1"
    [[ $1 = "-c" ]] && copyToBuffer=true || copyToBuffer=false

    if [ $ticketId ] ; then
        grepString="refs/remotes/origin/bugfix/PRO-$ticketId\|refs/remotes/origin/feature/PRO-$ticketId"
        findBranch=`git show-ref | grep $grepString | sed 's/.*refs\/remotes\/origin\///'`

        if [ $copyToBuffer = true ] ; then
            echo $findBranch | pbcopy
        fi

        echo $findBranch
    else
        echo "Usage: findProBranch [-c] TicketID"
    fi
}

cleanUpBranches() {
    [[ $1 = "-y" ]] && confirmDelete=true || confirmDelete=false

    if [ $confirmDelete = true ] ; then
        echo 'branches cleaned up'
        git branch --merged | grep -v \* | xargs git branch -D
    else
        git branch --merged | grep -v \*
    fi
}

extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)     echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

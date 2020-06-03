abbr -a e nvim
abbr -a m make
abbr -a g git
abbr -a gc 'git checkout'
abbr -a ga 'git add -p'
abbr -a vimdiff 'nvim -d'
abbr -a ct 'cargo t'
abbr -a amz 'env AWS_SECRET_ACCESS_KEY=(pass www/aws-secret-key | head -n1)'
abbr -a ais "aws ec2 describe-instances | jq '.Reservations[] | .Instances[] | {iid: .InstanceId, type: .InstanceType, key:.KeyName, state:.State.Name, host:.PublicDnsName}'"
abbr -a gah 'git stash; and git pull --rebase; and git stash pop'
abbr -a ks 'keybase chat send'
abbr -a kr 'keybase chat read'
abbr -a kl 'keybase chat list'
abbr -a htitles 'find . -type f | html-tool tags title | nvim -'
abbr -a fishc 'nvim ~/.config/fish/config.fish'
abbr -a vimc 'nvim ~/.config/nvim/init.vim'
abbr -a inst 'sudo xbps-install -S'
abbr -a query 'xbps-query -Rs'
#comm -23 <(sort a.txt) <(sort b.txt)
# the command naffy talked about during nahamsec stream.
abbr -a naffynmap 'nmap -T 4 -iL hosts -Pn --script=http-title -p80,4443,4080,443 --open'
abbr -a grootdomain 'rg "(^\.|([a-z]*starbucks)\.(\w*)\.(\w*))|(^\.|([a-z]*starbucks)\.(\w*))" -o -N -I | sort -u'
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
set GOPATH $HOME/go
set -U fish_user_paths /usr/local/sbin /usr/local/bin /usr/bin /bin $HOME/.cargo/bin:$PATH $PATH:/usr/local/go/bin:$GOPATH/bin

#if status --is-interactive
#	tmux ^ /dev/null; and exec true
#end

if command -v exa > /dev/null
	abbr -a l 'exa'
	abbr -a ls 'exa'
	abbr -a ll 'exa -l'
	abbr -a lll 'exa -la'
else
	abbr -a l 'ls'
	abbr -a ll 'ls -l'
	abbr -a lll 'ls -la'
end

if test -f /usr/share/autojump/autojump.fish;
	source /usr/share/autojump/autojump.fish;
end


# checks for domains that have hanging records.
function check_nx
	while read -la line 
		dig $line | grep "CNAME" | awk '{print $1}' | xargs dig | grep "NXDOMAIN" && echo $line
	end < $argv
end

function gcidr 
	whois command(dig +short $argv | tail -n1) | grep CIDR
end

function ci
	curl -IL $argv
end

function ch 
	curl --url $argv[1] --head
end

function vh
	curl --url $argv[1] -H "Host: $argv[2]" --head
end

function getroots --description "getroots <domain> <file_name.txt>"
	gf urls | unfurl -u domains format %r | tee -a $argv[2]
	echo $argv[1] | waybackurls | unfurl -u domains format %r | tee -a $argv[2]
end


function ffm  --description "ffm <hosts.txt> <wordlist.txt>"
	# https://twitter.com/gwendallecoguic/status/1202984025842995200
	ffuf -u HFUZZ/WFUZZ -w $argv[1]:HFUZZ -w $argv[2]:WFUZZ -mode clusterbomb -t $argv[3] -fs $argv[4] -fc $argv[5] 
end

function patchapk 
	objection patchapk --source $argv
end

function filetoclip 
	xclip -sel clip < $argv
end

function apkdeobf 
	jadx --deobf --deobf-min 3 --show-bad-code $argv
end

function decodeb64 
	echo "$argv" | base64 -D
	echo -e "\n"
end

function encodeb64 
	echo -n "$argv" | openssl base64
end

function ssh
	switch $argv[1]
	case "*.amazonaws.com"
		env TERM=xterm /usr/bin/ssh $argv
	case "ubuntu@"
		env TERM=xterm /usr/bin/ssh $argv
	case "*"
		env TERM=xterm /usr/bin/ssh $argv
	end
end

function limit
	numactl -C 0,1,2 $argv
end

function remote_alacritty
	# https://gist.github.com/costis/5135502
	set fn (mktemp)
	infocmp alacritty > $fn
	scp $fn $argv[1]":alacritty.ti"
	ssh $argv[1] tic "alacritty.ti"
	ssh $argv[1] rm "alacritty.ti"
end

# Type - to move up to top parent dir which is a repository
function d
	while test $PWD != "/"
		if test -d .git
			break
		end
		cd ..
	end
end

# Fish git prompt
set __fish_git_prompt_showuntrackedfiles 'yes'
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showstashstate ''
set __fish_git_prompt_showupstream 'none'
set -g fish_prompt_pwd_dir_length 3

# colored man output
# from http://linuxtidbits.wordpress.com/2009/03/23/less-colors-for-man-pages/
setenv LESS_TERMCAP_mb \e'[01;31m'       # begin blinking
setenv LESS_TERMCAP_md \e'[01;38;5;74m'  # begin bold
setenv LESS_TERMCAP_me \e'[0m'           # end mode
setenv LESS_TERMCAP_se \e'[0m'           # end standout-mode
setenv LESS_TERMCAP_so \e'[38;5;246m'    # begin standout-mode - info box
setenv LESS_TERMCAP_ue \e'[0m'           # end underline
setenv LESS_TERMCAP_us \e'[04;38;5;146m' # begin underline

# For RLS
# https://github.com/fish-shell/fish-shell/issues/2456
#setenv LD_LIBRARY_PATH (ustc +stable --print sysroot)"/lib:$LD_LIBRARY_PATH"
#setenv RUST_SRC_PATH (rustc --print sysroot)"/lib/rustlib/src/rust/src"

setenv FZF_DEFAULT_COMMAND 'fd --type file --follow'
setenv FZF_CTRL_T_COMMAND 'fd --type file --follow'
setenv FZF_DEFAULT_OPTS '--height 20%'

# Fish should not add things to clipboard when killing
# See https://github.com/fish-shell/fish-shell/issues/772
set FISH_CLIPBOARD_CMD "cat"

function fish_user_key_bindings
	bind \cz 'fg>/dev/null ^/dev/null'
	if functions -q fzf_key_bindings
		fzf_key_bindings
	end
end

function fish_prompt
	set_color brblack
	echo -n "["(date "+%H:%M")"] "
	set_color blue
	echo -n (hostname) #hostname
	if [ $PWD != $HOME ]
		set_color brblack
		echo -n ':'
		set_color yellow
		echo -n (basename $PWD)
	end
	set_color green
	printf '%s ' (__fish_git_prompt)
	set_color red
	echo -n '| '
	set_color normal
end

set fish_greeting

#startx at login
if status is-login
	if test -z "$DISPLAY"
		exec startx -- -keeptty
	end
end

# important bash utilities

PROMPT_DIRTRIM=1

encrypt(){
	openssl enc -aes-256-cbc -pass pass:Cheap\ pa55w0rd -md sha256 -p -a -in "$1" -out "$1.enc";
	mv "$1.enc" "$1";
}

decrypt(){
	openssl enc -d -aes-256-cbc -pass pass:Cheap\ pa55w0rd -md sha256 -p -a -in "$1" -out "$1.dec";
	mv "$1.dec" "$1";
}

# get new files from another branch and encrypt them and commit them
# Usage: branch_enc <target_branch> <source_branch> <commit_message>
branch_enc(){
	diff <(git ls-tree -r --name-only $1) <(git ls-tree -r --name-only encrypted) | grep "[<>]" | cut -c 3- > list.txt;
	cat list.txt | while read file; do git checkout $2 "$file"; done;
	cat list.txt | while read file; do encrypt "$file"; done;
	rm list.txt;
	git add -A;
	git status;
	git commit -m "$3";
	git log --oneline;
}

alias validate_filenames='ls | grep "[<>:\"\'/\\|?*]"'

# safely touch file
t() {
	if [[ $1 =~ [/\\\<\>:\"\'|?!\*] ]]
	then
		echo "filename contains dangerous character ${BASH_REMATCH[0]}";
	elif [[ $1 =~ ^(CON|PRN|AUX|NUL|COM1|COM2|COM3|COM4|COM5|COM6|COM7|COM8|COM9|LPT1|LPT2|LPT3|LPT4|LPT5|LPT6|LPT7|LPT8|LPT9)\..*$ ]]
	then
		echo "filename contains reserved windows filename ${BASH_REMATCH[1]}";
	elif [[ $1 =~ [\ \.]$ ]]
	then
		echo "filename ending in <space> or . not allowed";
	else
		touch "$1";
	fi
}

# Touch file and open in vscode
tc() {
	t "$1" && code "$1";
}

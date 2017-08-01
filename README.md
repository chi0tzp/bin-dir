# bin-dir

My ~/bin directory: a collection of auxiliary scripts for various tasks.

#### backup.sh
~~~~
Usage: backup.sh -d <destination>
~~~~
Back-up script based on [`rsync`](https://linux.die.net/man/1/rsync). The script backs up certain directories (given in the `DIRS` array) for each of a set of specified machines (disciminated by their `$HOSTNAME` -- see the `if...elif` statement). 

For each hostname, you need to define `ROOT_DIR`, and an array of the files and/or directories under `ROOT_DIR` to be backed-up. For example, 

~~~~
ROOT_DIR=${HOME}"/"
DIRS=( "bin/" ".ssh/" ".tmux.conf" )
~~~~

Destination (argument `-d`) can be a local directory (e.g., a usb hard disk drive), or a remote (via [`ssh`](https://linux.die.net/man/1/ssh)) directory. For example,

~~~~
backup.sh -d /path/to/backup/dir
backup.sh -d <user>@<ip>:/path/to/backup/dir
~~~~

The script will create a directory named after the current hostname (`$HOSTNAME`) under the destination directory (if it does not exist already).



#### backup-spider.sh
~~~~
Usage: backup-spider.sh -s <source>
~~~~
Back-up script based on [`rsync`](https://linux.die.net/man/1/rsync). The script backs up a given directory (argument `-s`) to the corresponding directory under `~/SpiderOak Hive/`.

#### [More to be added]

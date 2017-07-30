# bin-dir

My ~/bin directory: a collection of auxiliary scripts for various tasks.

#### backup.sh
~~~~
Usage: backup.sh -d <destination>
~~~~
Back-up script based on [`rsync`](https://linux.die.net/man/1/rsync). The script backs up certain directories for each of a set of specified machines (disciminated by their `$HOSTNAME`). For each machine, you can define which directories will be backed-up, whle you can also add new machines based on the pre-existing ones' code.

#### backup-spider.sh
~~~~
Usage: backup-spider.sh -s <source>
~~~~
Back-up script based on [`rsync`](https://linux.die.net/man/1/rsync). The script backs up a given directory (argument `-s`) to the corresponding directory under `~/SpiderOak Hive/`.

#### More to be added

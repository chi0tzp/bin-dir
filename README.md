# bin-dir

My ~/bin directory: a collection of auxiliary scripts for various tasks.

#### backup.sh
~~~~
Usage: backup.sh -l <local_dest_dir> -r <remote_machine> [-p <remote_port> [-d <remote_dest_dir>]]
~~~~
Back-up script based on [`rsync`](https://linux.die.net/man/1/rsync). The script backs up certain directories (given in the `DIRS` array) for each of a set of specified machines (disciminated by their `$HOSTNAME` -- see the `if...elif` statement below). 

For each hostname, a `ROOT_DIR` needs to be defined, along with an array (i.e., `DIRS`) of the files and/or directories under `ROOT_DIR` to be backed-up. For example, 

~~~~
ROOT_DIR=${HOME}"/"
DIRS=( "bin/" ".ssh/" ".tmux.conf" )
~~~~

For adding a new host, named -- for instance-- "new_host", an extra `elif` branch needs to be added as follows:
~~~~
...
elif [ "${HOSTNAME}" == "new_host" ]
then
	ROOT_DIR=<root_dir>
	DIRS=( <dir1> <dir2> ... <file1> <file2> ... )
...
~~~~
Argument `-l` defines a local destination directory under which the specified dirs/files will be backed up. Argument `-r` defines a remote machine 





is optional and defines a remote host under which the destination directory lies. If the destination directory is a local one, this arguments can be omitted. The script will create a directory named after the current hostname (`$HOSTNAME`) under the destination directory (if it does not already exist), i.e., the directory `${DEST_DIR}${HOSTNAME}`. 

Examples of usage:

- `backup.sh -l /path/to/backup/dir` will back up the specified dirs/files to a local directory `/path/to/backup/dir/$HOSTNAME`.
- `backup.sh -r username@remote_host` will back up the specified dirs/files to a remote directory `remote_host:/path/to/backup/dir/$HOSTNAME`.


#### [More to be added]


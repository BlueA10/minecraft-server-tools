Some tools I use to help manage my small Minecraft server.

Includes scripts for starting and stopping the server, taking backups of the world with borg, and sending status messages to a discord webhook.

Very very rough and WIP, it's pretty clearly just for my personal uses and isn't very user friendly to anyone, but I'm keeping it here for the obvious version control reasons and also in case anyone else finds them useful.

NOTE: In the current implementation (which I aim to replace eventually) the script reads the server's console from systemd journal. The minecraft account running the server will need the appropriate permission to access the journal (again, aiming to fix that at some point).

ZFS snapshots also will require the minecraft account running the script to have permission to snapshot the minecraft server dataset, preferably via ZFS delegation system.

May add more documentation in the future if it grows enough.

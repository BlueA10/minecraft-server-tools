Some tools I use to help manage my small Minecraft server.

Includes scripts for starting and stopping the server, taking ZFS snapshots of the world and configuration, and experimental Systemd unit files for socket-activation of the server, so that it shuts down when idle and boots up again when someone tries to connect.

Very very rough and WIP, it's pretty clearly just for my personal uses and isn't very user friendly to anyone, but I'm keeping it here for the obvious version control reasons and also in case anyone else finds them useful.

ZFS snapshots also will require the minecraft account running the script to have permission to snapshot the minecraft server dataset, preferably via ZFS delegation system.

May add more documentation in the future if it grows enough.

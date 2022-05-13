# checksum-tests
Prereqs:
1) This code is designed to run on linux - flavor independent
2) Install fio on the linux machine as well as ksh
3) mount an NFS volume on the linux machine
4) setup passwordless ssh between the linux machine and the FSx N Alpha or TestDev System

Two files are included in this package:

* inode.ksh: this is the code that will
                build the fio.ini file,
                create a 20MiB file using FIO,
                overwrite said file using both 4K and 8K random writes
                find the inode of said file from witin ONTAP
                dumpblock the first 100 blocks from said file from within ONTAP
                repeat the above for sundry compression levels and compression chunks

* analyze.ksh:  this is the code that will inspect all of the dumped blocks and tally the number of blocks per
                scenario wherein the checksum embedded in the block (TRUE) or not embedded (FALSE)

Working with the code:
                These are farily rudimentary ksh scripts, as such that lack a config file.
                You will need to open up each script and fill in the value for the three variables
                found at the top of the scripts

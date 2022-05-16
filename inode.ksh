storage_mgmt=198.19.244.194
volume=nfsvol
output_dir=$1

for blocksize in 4k 8k; do
    for compress in 0 10 20 25 30 40 50 60 70 75 80 90 100; do
        for chunk in 0 1 16 32 64 128 256 512 1024 2048 4096 8192; do
            output_dir_mod=${output_dir}-chunk_${chunk}-compress_${compress}-${blocksize}

            rm -rf  $output_dir_mod > /dev/null 2>&1
            mkdir $output_dir_mod

            rm -rf ./fio.ini
            cp fio-base.ini ./fio.ini

            rm -rf /$volume/compress*
            mkdir /$volume/compressme$compress
            echo "[global]" >> ./fio.ini
            echo "name=fio-test" >> ./fio.ini
            echo "ioengine=libaio" >> ./fio.ini
            echo "direct=1" >> ./fio.ini
            echo "numjobs=1" >> ./fio.ini
            echo "rw=randrw" >> ./fio.ini
            echo "nrfiles=1" >> ./fio.ini
            echo "ramp_time=1" >> ./fio.ini
            echo "rwmixread=100" >> ./fio.ini
            echo "size=20M" >> ./fio.ini
            echo "directory=/${volume}/compressme$compress" >> ./fio.ini
            echo "bs=$blocksize" >> ./fio.ini
            echo "norandommap" >> ./fio.ini
            echo "randrepeat=0" >> ./fio.ini
            echo "dedupe_percentage=0" >> ./fio.ini
            echo "buffer_compress_percentage=$compress" >> ./fio.ini
            echo "buffer_compress_chunk=$chunk" >> ./fio.ini
            echo 'buffer_pattern="aaaa"' >> ./fio.ini
            echo "[rw]" >> ./fio.ini

            fio ./fio.ini --directory /$volume/compressme$compress

            inode=`ssh $storage_mgmt "set diag -confirmations off; node run *01 ls -i /vol/$volume/compressme${compress}"  | grep rw.0.0 | awk '{print $1}'`
            echo "ssh $storage_mgmt set diag -confirmations off; node run *01 ls -i /vol/$volume/compressme${compress}  | grep rw.0.0 | awk '{print $1}'"
            echo $inode
            count=0
            while [[ $count -le 99 ]]; do
                ssh $storage_mgmt "set diag; node run *01 dumpblock file -V $volume $inode -level 0 $count" > ${output_dir_mod}/block${count}
                (( count = count + 1 ))
            done
        done
    done
done


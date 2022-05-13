storage_mgmt=198.19.244.194
volume=nfsvol
input_dir=dumpblocks-Random-Overwrite

for blocksize in 4k 8k; do
    for compress in 0 10 20 25 30 40 50 60 70 75 80 90 100; do
        for chunk in 0 1 16 32 64 128 256 512 1024 2048 4096 8192; do
            input_dir_mod=${input_dir}-chunk_${chunk}-compress_${compress}-${blocksize}

            cd ${input_dir_mod}

            rm -rf /tmp/junk > /dev/null 2>&1
            true=0
            false=0
            for block in `ls | grep block`; do
                grep -A 4 cksum_data $block | grep 0x | grep -v "0x00000000 0x00000000 0x00000000 0x00000000" | cut -d: -f2 | cut -d\< -f1 | while read line; do
                   count=`grep -n "$line" $block | sort -k 1 -n  | wc -l`
                   if [[ $count == 2 ]]; then
                       (( true = true + 1 ))
                   else
                       (( false = false + 1 ))
                   fi
                echo $true $false
                done  | tail -1 >> /tmp/junk
            done
            global_true=0
            global_false=0
            cat /tmp/junk | while read true false; do
                (( global_true = global_true + true ))
                (( global_false = global_false + false ))
                echo "Block $blocksize, Chunk $chunk, Compress $compress, True $global_true, False $global_false"
            done | tail -1
            cd ..
        done
    done
done

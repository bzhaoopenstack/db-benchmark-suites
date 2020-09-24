set -x

export INSTALL_DIR=/home/pgsql/pgsql-install
export BIN_DIR=$INSTALL_DIR/bin
export PATH=$PATH:$BIN_DIR

declare -a strindex=("number of transactions actually processed"
                     "latency average"
                     "including connections establishing"
                     "excluding connections establishing"
                     "SELECT"
                    )

declare -a stringaws=('$6'
                      '$4$5'
                      '$3'
                      '$3'
                      '$1')


resultlength=${#strindex[@]}

#func get_result() {
#
#}
#
#cat 1 | grep "number of transactions actually processed" | awk '{print $6}'
#cat 1 | grep "latency average" | awk '{print $4$5}'
#cat 1 | grep "including connections establishing" | awk '{print $3}'
#cat 1 | grep "SELECT" | awk '{print $1}'



TEST_RES_DIR="./test_res"
FINNAL_RES_FILE="./test_res/final_res"

rm -rf $TEST_RES_DIR | true
mkdir -p $TEST_RES_DIR
touch $FINNAL_RES_FILE


for i in 2 4 8 16 32 64 128;do
    for j in 2 4 8 16 32 64 128;do
        tmp_file=$TEST_RES_DIR/c$i_j$j_`date +"%y-%m-%d-%I-%M-%S"`
        #pgbench -r -b select-only -c $i -j 1 -T 20 -M prepared pgbench
        pgbench -r -b select-only -c $i -j $j -T 20 -M prepared pgbench > $tmp_file
        echo "client-$i to server-threads-$j" >> $FINNAL_RES_FILE
        tmp_res="$i-$j"
        for (( x=1; x<${resultlength}+1; x++ ));do
            single_record=`cat $tmp_file | grep "${strindex[$x-1]}" | awk '{print '${stringaws[$x-1]}'}'`
            tmp_res="$tmp_res  $single_record"
        done
        echo $tmp_res >> $FINNAL_RES_FILE
        # stop the next test for a while
        sleep 15
    done
done

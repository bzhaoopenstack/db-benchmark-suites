
# install sysbench
cd
sudo apt -y install make automake libtool pkg-config libaio-dev
git clone https://github.com/akopytov/sysbench.git
cd sysbench/
./autogen.sh
./configure --prefix=/home/pgsql/sysbench-install/ --with-pgsql
make -j ; make install

export PATH=/home/psql/sysbench-install/bin/:$PATH

# download sysbench-tpcc tools
cd
git clone https://github.com/digoal/sysbench-tpcc

# Run tpcc sysbench tests
cd
cd sysbench-tpcc
chmod +x tpcc.lua

# Test warmup -- data / tables prepare
./tpcc.lua --pgsql-host=/tmp --pgsql-port=5432 --pgsql-user=psql --pgsql-db=psql --threads=32 --tables=10 --scale=100 --trx_level=RC --db-ps-mode=auto --db-driver=pgsql prepare

# Run tpcc benchmark
./tpcc.lua --pgsql-host=/tmp --pgsql-port=5432 --pgsql-user=psql --pgsql-db=psql --threads=32 --tables=10 --scale=100 --trx_level=RC --db-ps-mode=auto --db-driver=pgsql --time=3000 --report-interval=1 run

# Cleanup test data / tables
./tpcc.lua --pgsql-host=/tmp --pgsql-port=5432 --pgsql-user=psql --pgsql-db=psql --threads=32 --tables=10 --scale=100 --trx_level=RC --db-driver=pgsql cleanup

# top -c -u postgres
# iotop
# apt install sysstat -y ; sar -d -p 1 99999 # disk io
# vmstat 2 # memory io

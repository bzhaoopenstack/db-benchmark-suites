
set -x

# add testusers
useradd -m -d /home/pgsql -s /bin/bash pgsql && echo pgsql:pgsql | chpasswd && adduser pgsql sudo
echo "pgsql ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

export INSTALL_DIR=/home/pgsql/pgsql-install
export BIN_DIR=$INSTALL_DIR/bin
export BASH_CMD=`which bash`

## Install deps
apt-get -q update \
&& apt-get -q install -y --no-install-recommends \
	build-essential \
	autoconf \
	automake \
	libtool \
	cmake \
	zlib1g-dev \
	pkg-config \
	libssl-dev \
	libssl1.0.0 \
	libsasl2-dev \
	bats \
	curl \
	sudo \
	git \
	wget

apt-get install zlib1g zlib1g-dev bzip2 libbz2-dev readline-common libreadline-dev bison libgmp-dev libmpfr-dev libmpc-dev -y
apt-get install flex -y

# Compile and install postgres by source code
su pgsql -c "cd ; git clone https://github.com/postgres/postgres.git"
su pgsql -c "cd /home/pgsql/postgres ; ./configure --prefix=$INSTALL_DIR ; make -j ; make install"


export PATH=$BIN_DIR:$PATH

mkdir -p /var/pgsql/data
chown -R pgsql:pgsql /var/pgsql/data
su pgsql -c "$BIN_DIR/initdb --pgdata=/var/pgsql/data --encoding=UTF8"
su pgsql -c "$BIN_DIR/pg_ctl -D /var/pgsql/data -l /home/pgsql/logfile start"
su pgsql -c "$BIN_DIR/createdb -O pgsql pgsql"

## create test database
su pgsql -c "$BIN_DIR/createdb -O pgsql pgbench"

## Data warmup and RUN tpcb-like select testcases
su pgsql -c "$BIN_DIR/pgbench -i -s 1000 pgbench"
wget https://raw.githubusercontent.com/bzhaoopenstack/db-benchmark-suites/master/postgres/pgbench-tpcb-select-full-arrange-test.sh

su pgsql -s $BASH_CMD ./pgbench-tpcb-select-full-arrange-test.sh

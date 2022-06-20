#!/bin/bash

# подготовка сервера
sudo apt update && sudo apt upgrade -y
sudo apt install make clang pkg-config libssl-dev libclang-dev build-essential git curl ntp jq llvm tmux htop screen -y
wget https://golang.org/dl/go1.18.3.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.18.3.linux-amd64.tar.gz

export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF
source ~/.profile
go version
rm -rf go1.18.3.linux-amd64.tar.gz

# установка ноды
git clone https://github.com/gnolang/gno/
cd gno
make
./build/gnokey generate
./build/gnokey add account --recover
./build/gnokey list

read -p "Wallet Address: " address
echo 'export address='$address >> $HOME/.bash_profile
source $HOME/.bash_profile


# получение токенов
while true; do curl 'https://gno.land:5050/' --data-raw 'toaddr='$address; ./build/gnokey query "bank/balances/"$address --remote gno.land:36657; sleep 2; done


# регистрация нашего аккаунта
./build/gnokey query auth/accounts/$address --remote gno.land:36657

read -p "User Name: " username
read -p "Account Number: " account_number
read -p "Sequence Number: " sequence_number
echo 'export username='$username >> $HOME/.bash_profile
echo 'export account_number='$account_number >> $HOME/.bash_profile
echo 'export sequence_number='$sequence_number >> $HOME/.bash_profile
source $HOME/.bash_profile


# создаем фаил, который будет содержать информацию о нашей регистрации
./build/gnokey maketx call $address --pkgpath "gno.land/r/users" --func "Register" --gas-fee 1gnot --gas-wanted 3000000 --send "2000gnot" --args "" --args $username --args "" > unsigned.tx

# создаем транзакцию
./build/gnokey sign $address --txpath unsigned.tx --chainid testchain --number $account_number --sequence $sequence_number > signed.tx

# проводим транзакцию
./build/gnokey broadcast signed.tx --remote gno.land:36657

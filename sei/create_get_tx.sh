# put name of your moniker
NODENAME=

# Save and import variables into system
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
echo "export WALLET="$NODENAME"-Wallet" >> $HOME/.bash_profile
echo "export CHAIN_ID=atlantic-1" >> $HOME/.bash_profile
source $HOME/.bash_profile

# sudo apt update && sudo apt upgrade -y
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt-get install make build-essential gcc git jq chrony -y

# Install go
ver="1.18.2"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile

# Download and install binaries
cd $HOME
git clone https://github.com/sei-protocol/sei-chain.git && cd $HOME/sei-chain
git checkout 1.0.6beta
make install

# Config app
seid config chain-id $CHAIN_ID
seid config keyring-backend test

# Init node
seid init $NODENAME --chain-id $CHAIN_ID

# generate new wallet
seid keys add $WALLET

# add genesis account
WALLET_ADDRESS=$(seid keys show $WALLET -a)
seid add-genesis-account $WALLET_ADDRESS 10000000usei

# Generate gentx
seid gentx $WALLET 10000000usei \
--chain-id $CHAIN_ID \
--moniker=$NODENAME \
--commission-max-change-rate=0.01 \
--commission-max-rate=0.20 \
--commission-rate=0.05 \
--details="" \
--security-contact="ilyaveyde2003@gmail.com" \
--website="https://github.com/hollik51"
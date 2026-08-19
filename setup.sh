#!/bin/bash
echo "🚀 Setting up standalone environment for Aave Yield Endowment..."

# 0. Check if Foundry (forge & anvil) is installed; install if missing
if ! command -v forge &> /dev/null; then
  echo "⚠️ Foundry (forge/anvil) not found on this system."
  echo "⚙️ Installing Foundry toolchain automatically..."
  curl -L https://foundry.paradigm.xyz | bash
  # Export path for current session
  export PATH="$HOME/.foundry/bin:$PATH"
  if command -v foundryup &> /dev/null; then
    foundryup
  elif [ -f "$HOME/.foundry/bin/foundryup" ]; then
    "$HOME/.foundry/bin/foundryup"
  fi
  echo "✅ Foundry successfully installed!"
else
  echo "✅ Foundry toolchain (forge/anvil) is already installed."
fi

# 1. Update foundry.toml for local libraries
if [ -f contracts/foundry.toml ]; then
  echo "🔧 Configuring contracts/foundry.toml to use local libraries..."
  sed -i.bak "s|libs = \['../../lib'\]|libs = \['lib'\]|g" contracts/foundry.toml 2>/dev/null || \
  sed -i "" "s|libs = \['../../lib'\]|libs = \['lib'\]|g" contracts/foundry.toml
  rm -f contracts/foundry.toml.bak
fi

# 2. Create .env if it does not exist
if [ -f contracts/.env.example ] && [ ! -f contracts/.env ]; then
  echo "📝 Creating contracts/.env from template..."
  cp contracts/.env.example contracts/.env
fi

# 3. Install forge-std dependency locally and compile
if [ -d contracts ]; then
  echo "📦 Installing Forge dependencies locally..."
  cd contracts
  
  # Ensure forge-std is present
  if [ ! -d "lib/forge-std" ]; then
    forge install foundry-rs/forge-std --no-git
  fi
  
  echo "🔨 Compiling smart contracts..."
  forge build
  cd ..
fi

echo "--------------------------------------------------------"
echo "✅ Setup complete! To test the project:"
echo "1. Run local chain (Base Sepolia fork):"
echo "   anvil --fork-url https://base-sepolia-rpc.publicnode.com --chain-id 31337"

echo "2. Launch web frontend Dapp:"
echo "   cd frontend && python3 -m http.server 8000"
echo "--------------------------------------------------------"

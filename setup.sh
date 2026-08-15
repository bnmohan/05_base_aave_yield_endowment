#!/bin/bash
echo "🚀 Setting up standalone environment for Aave Yield Endowment..."

# 1. Update foundry.toml for local libraries
if [ -f contracts/foundry.toml ]; then
  echo "🔧 Configuring contracts/foundry.toml to use local libraries..."
  sed -i.bak "s|libs = \['../../lib'\]|libs = \['lib'\]|g" contracts/foundry.toml 2>/dev/null || \
  sed -i "" "s|libs = \['../../lib'\]|libs = \['lib'\]|g" contracts/foundry.toml
  rm -f contracts/foundry.toml.bak
fi

# 2. Update remappings.txt for local libraries
if [ -f contracts/remappings.txt ]; then
  echo "🔧 Configuring contracts/remappings.txt to use local libraries..."
  sed -i.bak "s|../../lib|lib|g" contracts/remappings.txt 2>/dev/null || \
  sed -i "" "s|../../lib|lib|g" contracts/remappings.txt
  rm -f contracts/remappings.txt.bak
fi

# 3. Create .env if it does not exist
if [ -f contracts/.env.example ] && [ ! -f contracts/.env ]; then
  echo "📝 Creating contracts/.env from template..."
  cp contracts/.env.example contracts/.env
fi

# 4. Install forge-std dependency locally
if [ -d contracts ]; then
  echo "📦 Installing Forge dependencies locally..."
  cd contracts
  # Initialize forge dependencies
  forge install foundry-rs/forge-std --no-git
  
  echo "🔨 Compiling smart contracts..."
  forge build
  cd ..
fi

echo "✅ Setup complete! Serve the frontend directory to test the feature:"
echo "   cd frontend && python3 -m http.server 8000"

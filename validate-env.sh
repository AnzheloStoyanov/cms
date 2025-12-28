#!/bin/bash

# Environment Validation Script for Hostinger Deployment
# This script checks if the environment is properly configured before deployment

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}Environment Validation Script${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Check if .env file exists
echo -e "${YELLOW}Checking .env file...${NC}"
if [ ! -f .env ]; then
    echo -e "${RED}✗ .env file not found!${NC}"
    echo "  Please create .env file from .env.production template"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓ .env file exists${NC}"
    
    # Check for placeholder values
    if grep -q "CHANGE_ME\|GENERATE_SECURE_KEY" .env 2>/dev/null; then
        echo -e "${RED}✗ .env contains placeholder values${NC}"
        echo "  Please replace all placeholder values with actual secure keys"
        ERRORS=$((ERRORS + 1))
    else
        echo -e "${GREEN}✓ No placeholder values found${NC}"
    fi
    
    # Check for required environment variables
    required_vars=("HOST" "PORT" "APP_KEYS" "API_TOKEN_SALT" "ADMIN_JWT_SECRET" "JWT_SECRET" "DATABASE_CLIENT")
    for var in "${required_vars[@]}"; do
        if ! grep -q "^${var}=" .env 2>/dev/null; then
            echo -e "${RED}✗ Missing required variable: ${var}${NC}"
            ERRORS=$((ERRORS + 1))
        fi
    done
    
    # Check if default/weak values are being used
    if grep -q "toBeModified\|tobemodified" .env 2>/dev/null; then
        echo -e "${RED}✗ Default/weak values detected in .env${NC}"
        echo "  Please generate secure random values for all secret keys"
        ERRORS=$((ERRORS + 1))
    fi
fi

echo ""

# Check Node.js version
echo -e "${YELLOW}Checking Node.js version...${NC}"
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version | sed 's/v//' | cut -d'.' -f1)
    if [ "$NODE_VERSION" -ge 20 ]; then
        echo -e "${GREEN}✓ Node.js $(node --version) is installed (required: >= 20.x)${NC}"
    else
        echo -e "${RED}✗ Node.js version is $(node --version) but >= 20.x is required${NC}"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo -e "${RED}✗ Node.js is not installed${NC}"
    ERRORS=$((ERRORS + 1))
fi

echo ""

# Check npm
echo -e "${YELLOW}Checking npm...${NC}"
if command -v npm &> /dev/null; then
    echo -e "${GREEN}✓ npm $(npm --version) is installed${NC}"
else
    echo -e "${RED}✗ npm is not installed${NC}"
    ERRORS=$((ERRORS + 1))
fi

echo ""

# Check PM2
echo -e "${YELLOW}Checking PM2...${NC}"
if command -v pm2 &> /dev/null; then
    echo -e "${GREEN}✓ PM2 is installed${NC}"
else
    echo -e "${YELLOW}⚠ PM2 is not installed${NC}"
    echo "  Install with: npm install -g pm2"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""

# Check if node_modules exists
echo -e "${YELLOW}Checking dependencies...${NC}"
if [ -d node_modules ]; then
    echo -e "${GREEN}✓ node_modules directory exists${NC}"
else
    echo -e "${YELLOW}⚠ node_modules directory not found${NC}"
    echo "  Run: npm install"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""

# Check if build directory exists
echo -e "${YELLOW}Checking build status...${NC}"
if [ -d build ]; then
    echo -e "${GREEN}✓ Build directory exists${NC}"
else
    echo -e "${YELLOW}⚠ Build directory not found${NC}"
    echo "  Run: npm run build"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""

# Check database configuration
echo -e "${YELLOW}Checking database configuration...${NC}"
if [ -f .env ]; then
    DB_CLIENT=$(grep "^DATABASE_CLIENT=" .env 2>/dev/null | cut -d'=' -f2)
    if [ ! -z "$DB_CLIENT" ]; then
        echo -e "${GREEN}✓ Database client configured: $DB_CLIENT${NC}"
        
        case $DB_CLIENT in
            mysql|postgres)
                # Check for database credentials
                if ! grep -q "^DATABASE_NAME=" .env || ! grep -q "^DATABASE_USERNAME=" .env || ! grep -q "^DATABASE_PASSWORD=" .env; then
                    echo -e "${RED}✗ Missing database credentials${NC}"
                    ERRORS=$((ERRORS + 1))
                else
                    echo -e "${GREEN}✓ Database credentials configured${NC}"
                fi
                ;;
            sqlite)
                echo -e "${YELLOW}⚠ Using SQLite (not recommended for production)${NC}"
                WARNINGS=$((WARNINGS + 1))
                ;;
        esac
    fi
fi

echo ""

# Check if logs directory exists
echo -e "${YELLOW}Checking logs directory...${NC}"
if [ -d logs ]; then
    echo -e "${GREEN}✓ Logs directory exists${NC}"
else
    echo -e "${YELLOW}⚠ Logs directory not found${NC}"
    echo "  Creating logs directory..."
    mkdir -p logs
    echo -e "${GREEN}✓ Logs directory created${NC}"
fi

echo ""

# Summary
echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}Validation Summary${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed! Environment is ready for deployment.${NC}"
    echo ""
    echo "You can now run the deployment script:"
    echo "  ./deploy.sh"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ Validation completed with $WARNINGS warning(s)${NC}"
    echo "  You can proceed with deployment, but consider addressing the warnings."
    exit 0
else
    echo -e "${RED}✗ Validation failed with $ERRORS error(s) and $WARNINGS warning(s)${NC}"
    echo "  Please fix the errors before deploying."
    exit 1
fi

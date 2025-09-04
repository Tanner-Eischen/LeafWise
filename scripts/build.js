#!/usr/bin/env node
/**
 * Build Script for LeafWise React Native Application
 * Handles environment-specific builds for development, staging, and production
 * Supports Expo and React Native CLI builds
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// ANSI color codes
const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
  magenta: '\x1b[35m',
};

/**
 * Logs a message with color formatting
 * @param {string} message - Message to log
 * @param {string} color - Color code
 */
function log(message, color = colors.reset) {
  console.log(`${color}${message}${colors.reset}`);
}

/**
 * Executes a command with error handling
 * @param {string} command - Command to execute
 * @param {string} description - Description of the command
 * @returns {boolean} Success status
 */
function runCommand(command, description) {
  try {
    log(`🔨 ${description}...`, colors.blue);
    execSync(command, { stdio: 'inherit', cwd: process.cwd() });
    log(`✅ ${description} completed`, colors.green);
    return true;
  } catch (error) {
    log(`❌ ${description} failed`, colors.red);
    return false;
  }
}

/**
 * Copies environment file for the specified environment
 * @param {string} environment - Target environment
 */
function setupEnvironment(environment) {
  const envFile = path.join('config', `.env.${environment}`);
  const targetFile = '.env';
  
  if (fs.existsSync(envFile)) {
    log(`📋 Setting up ${environment} environment...`, colors.cyan);
    fs.copyFileSync(envFile, targetFile);
    log(`✅ Environment file copied: ${envFile} → ${targetFile}`, colors.green);
  } else {
    log(`⚠️  Environment file not found: ${envFile}`, colors.yellow);
  }
}

/**
 * Creates build directory and cleans previous builds
 */
function prepareBuildDirectory() {
  const buildDir = 'dist';
  
  if (fs.existsSync(buildDir)) {
    log('🧹 Cleaning previous build...', colors.yellow);
    fs.rmSync(buildDir, { recursive: true, force: true });
  }
  
  fs.mkdirSync(buildDir, { recursive: true });
  log('📁 Build directory prepared', colors.green);
}

/**
 * Validates build requirements
 * @param {string} environment - Target environment
 * @returns {boolean} Validation status
 */
function validateBuildRequirements(environment) {
  log('🔍 Validating build requirements...', colors.blue);
  
  const requirements = [
    { file: 'package.json', description: 'Package configuration' },
    { file: 'tsconfig.json', description: 'TypeScript configuration' },
    { file: 'app.json', description: 'Expo configuration' },
  ];
  
  const missing = requirements.filter(req => !fs.existsSync(req.file));
  
  if (missing.length > 0) {
    log('❌ Missing required files:', colors.red);
    missing.forEach(req => log(`   • ${req.file} (${req.description})`, colors.red));
    return false;
  }
  
  log('✅ All build requirements satisfied', colors.green);
  return true;
}

/**
 * Builds for development environment
 */
function buildDevelopment() {
  log('🚀 Building for DEVELOPMENT environment', colors.cyan);
  
  const steps = [
    () => setupEnvironment('development'),
    () => runCommand('npm run type-check', 'TypeScript type checking'),
    () => runCommand('npm run lint', 'Code linting'),
    () => runCommand('expo export --platform all --output-dir dist/development', 'Expo development build'),
  ];
  
  return steps.every(step => step());
}

/**
 * Builds for staging environment
 */
function buildStaging() {
  log('🚀 Building for STAGING environment', colors.cyan);
  
  const steps = [
    () => setupEnvironment('staging'),
    () => runCommand('npm run type-check', 'TypeScript type checking'),
    () => runCommand('npm run lint', 'Code linting'),
    () => runCommand('npm test -- --passWithNoTests --coverage', 'Running tests with coverage'),
    () => runCommand('expo export --platform all --output-dir dist/staging --minify', 'Expo staging build'),
  ];
  
  return steps.every(step => step());
}

/**
 * Builds for production environment
 */
function buildProduction() {
  log('🚀 Building for PRODUCTION environment', colors.cyan);
  
  const steps = [
    () => setupEnvironment('production'),
    () => runCommand('npm run type-check', 'TypeScript type checking'),
    () => runCommand('npm run lint', 'Code linting'),
    () => runCommand('npm test -- --passWithNoTests --coverage', 'Running tests with coverage'),
    () => runCommand('npm audit --audit-level=moderate', 'Security audit'),
    () => runCommand('expo export --platform all --output-dir dist/production --minify --source-maps', 'Expo production build'),
  ];
  
  return steps.every(step => step());
}

/**
 * Generates build metadata
 * @param {string} environment - Target environment
 */
function generateBuildMetadata(environment) {
  const metadata = {
    environment,
    buildTime: new Date().toISOString(),
    version: process.env.npm_package_version || '1.0.0',
    buildNumber: process.env.BUILD_NUMBER || '1',
    gitCommit: process.env.GITHUB_SHA || 'unknown',
    gitBranch: process.env.GITHUB_REF_NAME || 'unknown',
    nodeVersion: process.version,
  };
  
  const metadataPath = path.join('dist', environment, 'build-metadata.json');
  fs.writeFileSync(metadataPath, JSON.stringify(metadata, null, 2));
  log(`📄 Build metadata generated: ${metadataPath}`, colors.green);
}

/**
 * Main build function
 * @param {string} environment - Target environment
 */
function build(environment) {
  log('=' .repeat(60), colors.cyan);
  log(`🏗️  LeafWise Build Process - ${environment.toUpperCase()}`, colors.cyan);
  log('=' .repeat(60), colors.cyan);
  
  const startTime = Date.now();
  
  // Validate requirements
  if (!validateBuildRequirements(environment)) {
    process.exit(1);
  }
  
  // Prepare build directory
  prepareBuildDirectory();
  
  // Run environment-specific build
  let success = false;
  
  switch (environment) {
    case 'development':
      success = buildDevelopment();
      break;
    case 'staging':
      success = buildStaging();
      break;
    case 'production':
      success = buildProduction();
      break;
    default:
      log(`❌ Unknown environment: ${environment}`, colors.red);
      process.exit(1);
  }
  
  if (success) {
    generateBuildMetadata(environment);
    
    const duration = ((Date.now() - startTime) / 1000).toFixed(2);
    log('\n' + '=' .repeat(60), colors.cyan);
    log(`🎉 Build completed successfully in ${duration}s`, colors.green);
    log(`📦 Output: dist/${environment}/`, colors.green);
    log('=' .repeat(60), colors.cyan);
  } else {
    log('\n' + '=' .repeat(60), colors.cyan);
    log('❌ Build failed', colors.red);
    log('=' .repeat(60), colors.cyan);
    process.exit(1);
  }
}

// Parse command line arguments
const args = process.argv.slice(2);
const environment = args[0];
const showHelp = args.includes('--help') || args.includes('-h');

if (showHelp || !environment) {
  log('LeafWise Build Script', colors.cyan);
  log('\nUsage:');
  log('  node scripts/build.js <environment>');
  log('\nEnvironments:');
  log('  development  - Development build with debugging enabled');
  log('  staging      - Staging build with testing and analytics');
  log('  production   - Production build with optimizations');
  log('\nExamples:');
  log('  node scripts/build.js development');
  log('  node scripts/build.js production');
  process.exit(0);
}

if (!['development', 'staging', 'production'].includes(environment)) {
  log(`❌ Invalid environment: ${environment}`, colors.red);
  log('Valid environments: development, staging, production', colors.yellow);
  process.exit(1);
}

build(environment);
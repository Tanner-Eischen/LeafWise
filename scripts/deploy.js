#!/usr/bin/env node
/**
 * Deployment Script for LeafWise React Native Application
 * Handles deployment to different environments using Expo EAS
 * Supports development, staging, and production deployments
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
    log(`🚀 ${description}...`, colors.blue);
    execSync(command, { stdio: 'inherit', cwd: process.cwd() });
    log(`✅ ${description} completed`, colors.green);
    return true;
  } catch (error) {
    log(`❌ ${description} failed`, colors.red);
    return false;
  }
}

/**
 * Validates deployment requirements
 * @param {string} environment - Target environment
 * @returns {boolean} Validation status
 */
function validateDeploymentRequirements(environment) {
  log('🔍 Validating deployment requirements...', colors.blue);
  
  const requirements = [
    { env: 'EXPO_TOKEN', description: 'Expo authentication token' },
  ];
  
  const missing = requirements.filter(req => !process.env[req.env]);
  
  if (missing.length > 0) {
    log('❌ Missing required environment variables:', colors.red);
    missing.forEach(req => log(`   • ${req.env} (${req.description})`, colors.red));
    return false;
  }
  
  // Check if build exists
  const buildPath = path.join('dist', environment);
  if (!fs.existsSync(buildPath)) {
    log(`❌ Build not found for ${environment} environment`, colors.red);
    log(`   Run: npm run build:${environment}`, colors.yellow);
    return false;
  }
  
  log('✅ All deployment requirements satisfied', colors.green);
  return true;
}

/**
 * Sets up environment for deployment
 * @param {string} environment - Target environment
 */
function setupDeploymentEnvironment(environment) {
  const envFile = path.join('config', `.env.${environment}`);
  const targetFile = '.env';
  
  if (fs.existsSync(envFile)) {
    log(`📋 Setting up ${environment} deployment environment...`, colors.cyan);
    fs.copyFileSync(envFile, targetFile);
    log(`✅ Environment configured for ${environment}`, colors.green);
  }
}

/**
 * Deploys to development environment
 */
function deployDevelopment() {
  log('🚀 Deploying to DEVELOPMENT environment', colors.cyan);
  
  const steps = [
    () => setupDeploymentEnvironment('development'),
    () => runCommand('expo publish --release-channel development', 'Publishing to development channel'),
  ];
  
  return steps.every(step => step());
}

/**
 * Deploys to staging environment
 */
function deployStaging() {
  log('🚀 Deploying to STAGING environment', colors.cyan);
  
  const steps = [
    () => setupDeploymentEnvironment('staging'),
    () => runCommand('expo publish --release-channel staging', 'Publishing to staging channel'),
    () => runCommand('eas build --platform all --profile staging --non-interactive', 'Building staging binaries'),
  ];
  
  return steps.every(step => step());
}

/**
 * Deploys to production environment
 */
function deployProduction() {
  log('🚀 Deploying to PRODUCTION environment', colors.cyan);
  
  const steps = [
    () => setupDeploymentEnvironment('production'),
    () => runCommand('expo publish --release-channel production', 'Publishing to production channel'),
    () => runCommand('eas build --platform all --profile production --non-interactive', 'Building production binaries'),
    () => runCommand('eas submit --platform all --profile production --non-interactive', 'Submitting to app stores'),
  ];
  
  return steps.every(step => step());
}

/**
 * Sends deployment notification
 * @param {string} environment - Target environment
 * @param {boolean} success - Deployment success status
 */
function sendDeploymentNotification(environment, success) {
  const webhookUrl = process.env.SLACK_WEBHOOK_URL;
  
  if (!webhookUrl) {
    log('⚠️  No Slack webhook configured, skipping notification', colors.yellow);
    return;
  }
  
  const message = success
    ? `🚀 LeafWise ${environment} deployment successful!`
    : `❌ LeafWise ${environment} deployment failed!`;
  
  const payload = {
    text: message,
    channel: '#deployments',
    username: 'LeafWise Deploy Bot',
    icon_emoji: success ? ':rocket:' : ':x:',
  };
  
  try {
    execSync(`curl -X POST -H 'Content-type: application/json' --data '${JSON.stringify(payload)}' ${webhookUrl}`, {
      stdio: 'pipe',
    });
    log('📢 Deployment notification sent', colors.green);
  } catch (error) {
    log('⚠️  Failed to send deployment notification', colors.yellow);
  }
}

/**
 * Generates deployment report
 * @param {string} environment - Target environment
 * @param {boolean} success - Deployment success status
 * @param {number} duration - Deployment duration in seconds
 */
function generateDeploymentReport(environment, success, duration) {
  const report = {
    environment,
    success,
    duration,
    timestamp: new Date().toISOString(),
    version: process.env.npm_package_version || '1.0.0',
    buildNumber: process.env.BUILD_NUMBER || '1',
    gitCommit: process.env.GITHUB_SHA || 'unknown',
    gitBranch: process.env.GITHUB_REF_NAME || 'unknown',
    deployer: process.env.GITHUB_ACTOR || process.env.USER || 'unknown',
  };
  
  const reportPath = path.join('dist', environment, 'deployment-report.json');
  fs.writeFileSync(reportPath, JSON.stringify(report, null, 2));
  log(`📄 Deployment report generated: ${reportPath}`, colors.green);
}

/**
 * Main deployment function
 * @param {string} environment - Target environment
 */
function deploy(environment) {
  log('=' .repeat(60), colors.cyan);
  log(`🚀 LeafWise Deployment - ${environment.toUpperCase()}`, colors.cyan);
  log('=' .repeat(60), colors.cyan);
  
  const startTime = Date.now();
  
  // Validate requirements
  if (!validateDeploymentRequirements(environment)) {
    process.exit(1);
  }
  
  // Run environment-specific deployment
  let success = false;
  
  switch (environment) {
    case 'development':
      success = deployDevelopment();
      break;
    case 'staging':
      success = deployStaging();
      break;
    case 'production':
      success = deployProduction();
      break;
    default:
      log(`❌ Unknown environment: ${environment}`, colors.red);
      process.exit(1);
  }
  
  const duration = ((Date.now() - startTime) / 1000).toFixed(2);
  
  // Generate report and send notifications
  generateDeploymentReport(environment, success, parseFloat(duration));
  sendDeploymentNotification(environment, success);
  
  if (success) {
    log('\n' + '=' .repeat(60), colors.cyan);
    log(`🎉 Deployment completed successfully in ${duration}s`, colors.green);
    log(`🌐 Environment: ${environment}`, colors.green);
    log('=' .repeat(60), colors.cyan);
  } else {
    log('\n' + '=' .repeat(60), colors.cyan);
    log('❌ Deployment failed', colors.red);
    log('=' .repeat(60), colors.cyan);
    process.exit(1);
  }
}

// Parse command line arguments
const args = process.argv.slice(2);
const environment = args[0];
const showHelp = args.includes('--help') || args.includes('-h');

if (showHelp || !environment) {
  log('LeafWise Deployment Script', colors.cyan);
  log('\nUsage:');
  log('  node scripts/deploy.js <environment>');
  log('\nEnvironments:');
  log('  development  - Deploy to development channel');
  log('  staging      - Deploy to staging with binary builds');
  log('  production   - Deploy to production with app store submission');
  log('\nRequired Environment Variables:');
  log('  EXPO_TOKEN   - Expo authentication token');
  log('\nOptional Environment Variables:');
  log('  SLACK_WEBHOOK_URL - Slack webhook for notifications');
  log('\nExamples:');
  log('  node scripts/deploy.js development');
  log('  node scripts/deploy.js production');
  process.exit(0);
}

if (!['development', 'staging', 'production'].includes(environment)) {
  log(`❌ Invalid environment: ${environment}`, colors.red);
  log('Valid environments: development, staging, production', colors.yellow);
  process.exit(1);
}

deploy(environment);
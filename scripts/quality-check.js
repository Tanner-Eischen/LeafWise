#!/usr/bin/env node
/**
 * Code Quality Check Script for LeafWise
 * Runs comprehensive code quality checks including linting, type checking, and formatting
 * Used in CI/CD pipeline and local development
 */

const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

// ANSI color codes for console output
const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
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
 * Executes a command and returns the result
 * @param {string} command - Command to execute
 * @param {string} description - Description of the command
 * @returns {boolean} Success status
 */
function runCommand(command, description) {
  try {
    log(`\n🔍 ${description}...`, colors.blue);
    execSync(command, { stdio: 'inherit', cwd: process.cwd() });
    log(`✅ ${description} passed`, colors.green);
    return true;
  } catch (_error) {
    log(`❌ ${description} failed`, colors.red);
    return false;
  }
}

/**
 * Checks if a file exists
 * @param {string} filePath - Path to check
 * @returns {boolean} File exists
 */
function fileExists(filePath) {
  return fs.existsSync(path.resolve(filePath));
}

/**
 * Main quality check function
 */
function runQualityChecks() {
  log('🚀 Starting LeafWise Code Quality Checks', colors.cyan);
  log('=' .repeat(50), colors.cyan);
  
  const checks = [];
  
  // 1. TypeScript Type Checking
  if (fileExists('tsconfig.json')) {
    checks.push({
      command: 'npm run type-check',
      description: 'TypeScript type checking',
    });
  } else {
    log('⚠️  tsconfig.json not found, skipping type checking', colors.yellow);
  }
  
  // 2. ESLint
  if (fileExists('eslint.config.js') || fileExists('.eslintrc.js')) {
    checks.push({
      command: 'npm run lint',
      description: 'ESLint code analysis',
    });
  } else {
    log('⚠️  ESLint config not found, skipping linting', colors.yellow);
  }
  
  // 3. Prettier formatting check
  if (fileExists('.prettierrc.js') || fileExists('.prettierrc')) {
    checks.push({
      command: 'npm run format:check',
      description: 'Prettier formatting check',
    });
  } else {
    log('⚠️  Prettier config not found, skipping format check', colors.yellow);
  }
  
  // 4. Jest tests
  if (fileExists('jest.config.js') || fileExists('jest.config.ts')) {
    checks.push({
      command: 'npm test -- --passWithNoTests',
      description: 'Jest unit tests',
    });
  } else {
    log('⚠️  Jest config not found, skipping tests', colors.yellow);
  }
  
  // 5. Bundle size analysis (if build exists)
  if (fileExists('package.json')) {
    const packageJson = JSON.parse(fs.readFileSync('package.json', 'utf8'));
    if (packageJson.scripts && packageJson.scripts['analyze']) {
      checks.push({
        command: 'npm run analyze',
        description: 'Bundle size analysis',
      });
    }
  }
  
  // Run all checks
  const results = checks.map(check => 
    runCommand(check.command, check.description)
  );
  
  // Summary
  log('\n' + '=' .repeat(50), colors.cyan);
  const passed = results.filter(Boolean).length;
  const total = results.length;
  
  if (passed === total) {
    log(`🎉 All ${total} quality checks passed!`, colors.green);
    process.exit(0);
  } else {
    log(`❌ ${total - passed} out of ${total} checks failed`, colors.red);
    process.exit(1);
  }
}

/**
 * Auto-fix function for fixable issues
 */
function runAutoFix() {
  log('🔧 Running auto-fix for code quality issues...', colors.yellow);
  
  const fixCommands = [
    {
      command: 'npm run lint:fix',
      description: 'Auto-fixing ESLint issues',
    },
    {
      command: 'npm run format',
      description: 'Auto-formatting with Prettier',
    },
  ];
  
  fixCommands.forEach(fix => {
    runCommand(fix.command, fix.description);
  });
  
  log('\n🔍 Running quality checks after auto-fix...', colors.blue);
  runQualityChecks();
}

// Parse command line arguments
const args = process.argv.slice(2);
const shouldAutoFix = args.includes('--fix') || args.includes('-f');
const showHelp = args.includes('--help') || args.includes('-h');

if (showHelp) {
  log('LeafWise Code Quality Checker', colors.cyan);
  log('\nUsage:');
  log('  node scripts/quality-check.js          Run all quality checks');
  log('  node scripts/quality-check.js --fix    Auto-fix issues and run checks');
  log('  node scripts/quality-check.js --help   Show this help message');
  process.exit(0);
}

if (shouldAutoFix) {
  runAutoFix();
} else {
  runQualityChecks();
}
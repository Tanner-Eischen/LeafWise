#!/usr/bin/env node
/**
 * Pre-commit Hook for LeafWise
 * Runs code quality checks on staged files before allowing commits
 * Ensures consistent code quality across the codebase
 */

const { execSync } = require('child_process');
const path = require('path');

// ANSI color codes
const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
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
 * Gets list of staged files
 * @returns {string[]} Array of staged file paths
 */
function getStagedFiles() {
  try {
    const output = execSync('git diff --cached --name-only', { encoding: 'utf8' });
    return output.trim().split('\n').filter(file => file.length > 0);
  } catch (error) {
    log('❌ Failed to get staged files', colors.red);
    return [];
  }
}

/**
 * Filters files by extension
 * @param {string[]} files - Array of file paths
 * @param {string[]} extensions - Array of extensions to filter
 * @returns {string[]} Filtered files
 */
function filterFilesByExtension(files, extensions) {
  return files.filter(file => 
    extensions.some(ext => file.endsWith(ext))
  );
}

/**
 * Runs a command on specific files
 * @param {string} command - Base command
 * @param {string[]} files - Files to process
 * @param {string} description - Description of the operation
 * @returns {boolean} Success status
 */
function runCommandOnFiles(command, files, description) {
  if (files.length === 0) {
    log(`⏭️  No files for ${description}`, colors.yellow);
    return true;
  }
  
  try {
    log(`🔍 ${description} (${files.length} files)...`, colors.blue);
    const fullCommand = `${command} ${files.join(' ')}`;
    execSync(fullCommand, { stdio: 'inherit' });
    log(`✅ ${description} passed`, colors.green);
    return true;
  } catch (error) {
    log(`❌ ${description} failed`, colors.red);
    return false;
  }
}

/**
 * Runs TypeScript type checking on staged files
 * @param {string[]} tsFiles - TypeScript files
 * @returns {boolean} Success status
 */
function runTypeCheck(tsFiles) {
  if (tsFiles.length === 0) {
    return true;
  }
  
  try {
    log('🔍 TypeScript type checking...', colors.blue);
    execSync('npm run type-check', { stdio: 'inherit' });
    log('✅ TypeScript type checking passed', colors.green);
    return true;
  } catch (error) {
    log('❌ TypeScript type checking failed', colors.red);
    return false;
  }
}

/**
 * Main pre-commit function
 */
function runPreCommitChecks() {
  log('🚀 Running pre-commit checks...', colors.cyan);
  log('=' .repeat(40), colors.cyan);
  
  const stagedFiles = getStagedFiles();
  
  if (stagedFiles.length === 0) {
    log('⚠️  No staged files found', colors.yellow);
    return;
  }
  
  log(`📁 Found ${stagedFiles.length} staged files`, colors.blue);
  
  // Filter files by type
  const jstsFiles = filterFilesByExtension(stagedFiles, ['.js', '.jsx', '.ts', '.tsx']);
  const jsonFiles = filterFilesByExtension(stagedFiles, ['.json']);
  const mdFiles = filterFilesByExtension(stagedFiles, ['.md']);
  
  const checks = [];
  
  // 1. ESLint on JS/TS files
  if (jstsFiles.length > 0) {
    checks.push(() => 
      runCommandOnFiles('npx eslint', jstsFiles, 'ESLint checking')
    );
  }
  
  // 2. Prettier on all supported files
  const prettierFiles = [...jstsFiles, ...jsonFiles, ...mdFiles];
  if (prettierFiles.length > 0) {
    checks.push(() => 
      runCommandOnFiles('npx prettier --check', prettierFiles, 'Prettier formatting check')
    );
  }
  
  // 3. TypeScript type checking
  if (jstsFiles.some(file => file.endsWith('.ts') || file.endsWith('.tsx'))) {
    checks.push(() => runTypeCheck(jstsFiles));
  }
  
  // Run all checks
  const results = checks.map(check => check());
  const allPassed = results.every(Boolean);
  
  log('\n' + '=' .repeat(40), colors.cyan);
  
  if (allPassed) {
    log('🎉 All pre-commit checks passed!', colors.green);
    log('✅ Commit allowed', colors.green);
    process.exit(0);
  } else {
    log('❌ Pre-commit checks failed', colors.red);
    log('💡 Run the following to fix issues:', colors.yellow);
    log('   npm run lint:fix', colors.yellow);
    log('   npm run format', colors.yellow);
    log('🚫 Commit blocked', colors.red);
    process.exit(1);
  }
}

// Handle command line arguments
const args = process.argv.slice(2);
const showHelp = args.includes('--help') || args.includes('-h');

if (showHelp) {
  log('LeafWise Pre-commit Hook', colors.cyan);
  log('\nThis script runs automatically before commits to ensure code quality.');
  log('\nChecks performed:');
  log('  • ESLint on JavaScript/TypeScript files');
  log('  • Prettier formatting on all supported files');
  log('  • TypeScript type checking');
  log('\nTo bypass (not recommended): git commit --no-verify');
  process.exit(0);
}

runPreCommitChecks();
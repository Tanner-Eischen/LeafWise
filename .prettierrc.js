/**
 * Prettier configuration for LeafWise React Native application
 * Ensures consistent code formatting across the codebase
 * Optimized for readability and AI-first development practices
 */

module.exports = {
  // Basic formatting
  semi: true,
  singleQuote: true,
  quoteProps: 'as-needed',
  trailingComma: 'es5',
  
  // Indentation and spacing
  tabWidth: 2,
  useTabs: false,
  
  // Line length (optimized for AI readability)
  printWidth: 80,
  
  // JSX specific
  jsxSingleQuote: true,
  jsxBracketSameLine: false,
  
  // Other formatting options
  bracketSpacing: true,
  arrowParens: 'avoid',
  endOfLine: 'lf',
  
  // File type overrides
  overrides: [
    {
      files: '*.json',
      options: {
        printWidth: 200,
      },
    },
  ],
};
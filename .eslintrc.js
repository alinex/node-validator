module.exports = {
  env: { es6: true, node: true },
  extends: 'airbnb',
  plugins: ["flowtype"],
  parser: "babel-eslint",
  parserOptions: { sourceType: 'module' },
  rules: {
    'max-len': [ 'warn', 100 ],
    'indent': [ 'error', 2 ],
    'linebreak-style': [ 'error', 'unix' ],
    'quotes': [ 'error', 'single' ],
    'semi': [ 'warn', 'never' ],
    'spaced-comment': 'warn',
    'no-unused-vars': [ 'warn' ],
    'no-console': [ process.env.NODE_ENV === 'production' ? 'error' : 'warn' ],
    'no-shadow': ['error', { 'allow': ['cb', 'err'] }],
    'import/prefer-default-export': 'warn',
    'no-underscore-dangle': 'off',
    'no-restricted-syntax': 'off',
    'no-param-reassign': 'off'
  }
};

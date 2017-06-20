module.exports = {
  env: { es6: true, node: true, mocha: true },
  extends: 'airbnb',
  plugins: ["flowtype"],
  parser: "babel-eslint",
  parserOptions: { sourceType: 'module' },
  rules: {
    'max-len': [ 'warn', 100 ],
    'indent': [ 'error', 2 ],
    'linebreak-style': [ 'error', 'unix' ],
    'semi': [ 'warn', 'never' ],
    'spaced-comment': 'warn',
    'no-unused-vars': [ 'warn' ],
    'no-shadow': ['error', { 'allow': ['cb', 'err'] }],
    'import/prefer-default-export': 'warn',
    'no-underscore-dangle': 'off',
    'no-restricted-syntax': 'off',
    'no-param-reassign': 'off',
    'no-multi-str': 'off',
    // changes for test only
    'quotes': 'off',
    'no-unused-vars': 'off',
    'no-console': 'off',
    'import/no-extraneous-dependencies': 'off',
    'padded-blocks': 'off'
  }
};

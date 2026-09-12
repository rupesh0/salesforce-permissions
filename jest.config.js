const { jestConfig } = require("@salesforce/sfdx-lwc-jest/config");

module.exports = {
  ...jestConfig,
  moduleNameMapper: {
    ...jestConfig.moduleNameMapper,
    "^lightning/toast$": "<rootDir>/test/jest-mocks/lightning/toast.js"
  },
  modulePathIgnorePatterns: ["<rootDir>/.localdevserver"]
};

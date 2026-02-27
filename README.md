# Break Quest: Breathe & Loot — Website

Marketing website for the Break Quest: Breathe & Loot iOS app.

**Live:** https://foculoom.com/breakquest/  
**App Store:** https://apps.apple.com/app/id6759697192

Built with plain HTML/CSS. No build tools required.

### Running demo.js tests manually

To run tests for `demo.js`:

1. **Setup:**
   - Install Node.js (v18+ recommended).
   - Run `npm install` in the project directory.
2. **Test requirements:**
   - Install `jest` and `jsdom`: `npm install --save-dev jest jsdom`
   - If using ES modules, add `"type": "module"` to `package.json`.
3. **Running tests:**
   - Run `npx jest` or `npm test`.
   - Ensure test files are named `demo.test.js` or similar.
4. **Troubleshooting:**
   - ES module errors? Check Node version and package.json config.
   - Browser-only code may require `jsdom` mocks or cannot be fully tested in Node.

### Limitations
- `demo.js` is browser-focused; Node.js tests may not cover all features.

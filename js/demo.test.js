// js/demo.test.js for breakquestweb
const { JSDOM } = require('jsdom');
describe('Break Quest Demo', () => {
  let window, document, timerDisplay, progressFill, btnStart, breathCue, breathCircle, dots, cycleCount, lootCard, lootBack, lootMsg, wizard;
  beforeEach(() => {
    jest.resetModules();
    const dom = new JSDOM(`<!DOCTYPE html><div id="demo-timer-display"></div><div id="demo-progress-fill"></div><button id="demo-btn-start"></button><div id="demo-breath-cue"></div><div id="demo-breath-circle"></div><div id="demo-cycle-dots"></div><div id="demo-cycle-count"></div><div id="demo-loot-card"></div><div id="demo-loot-back"></div><div id="demo-loot-msg"></div><div id="demo-wizard"></div><button id="demo-btn-25"></button><button id="demo-btn-2"></button><button id="demo-btn-breathe"></button><button id="demo-btn-reset"></button>`);
    window = dom.window;
    document = window.document;
    global.document = document;
    timerDisplay = document.getElementById('demo-timer-display');
    progressFill = document.getElementById('demo-progress-fill');
    btnStart = document.getElementById('demo-btn-start');
    breathCue = document.getElementById('demo-breath-cue');
    breathCircle = document.getElementById('demo-breath-circle');
    dots = document.getElementById('demo-cycle-dots');
    cycleCount = document.getElementById('demo-cycle-count');
    lootCard = document.getElementById('demo-loot-card');
    lootBack = document.getElementById('demo-loot-back');
    lootMsg = document.getElementById('demo-loot-msg');
    wizard = document.getElementById('demo-wizard');
  });
  it('renders timer and progress', () => {
    require('./demo.js');
    document.dispatchEvent(new window.Event('DOMContentLoaded'));
    expect(timerDisplay.textContent).toMatch(/\d{2}:\d{2}/);
    expect(progressFill.style.width).toBeDefined();
  });
  it('start button triggers timer', () => {
    require('./demo.js');
    document.dispatchEvent(new window.Event('DOMContentLoaded'));
    btnStart.click();
    expect(btnStart.textContent).toMatch(/Pause|Resume/);
  });
  it('breathing game triggers loot', () => {
    require('./demo.js');
    document.dispatchEvent(new window.Event('DOMContentLoaded'));
    document.getElementById('demo-btn-breathe').click();
    expect(breathCue.textContent).toBeDefined();
    expect(lootMsg.textContent).toBeDefined();
  });
  it('reset returns timer to initial', () => {
    require('./demo.js');
    document.dispatchEvent(new window.Event('DOMContentLoaded'));
    btnStart.click();
    document.getElementById('demo-btn-reset').click();
    expect(timerDisplay.textContent).toMatch(/\d{2}:\d{2}/);
  });
});

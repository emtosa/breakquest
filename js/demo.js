(function () {
  'use strict';

  var TREASURES = [
    { icon: '✨', name: 'Glowing Orb' },
    { icon: '🦉', name: 'Tiny Owl Familiar' },
    { icon: '🔮', name: 'Crystal Ball' },
    { icon: '📜', name: 'Ancient Scroll' },
    { icon: '🗡️', name: 'Wizard Staff' },
    { icon: '🧿', name: 'Amulet of Focus' },
    { icon: '🌟', name: 'Star Fragment' },
    { icon: '🍄', name: 'Lucky Mushroom' },
  ];

  var BREATH_PHASES = [
    { cue: 'Breathe In...', big: true },
    { cue: 'Hold...', big: true },
    { cue: 'Breathe Out...', big: false },
  ];

  var BREATH_STEP_MS = 4000;
  var TOTAL_CYCLES = 2;

  var durationSecs = 120;
  var remainingSecs = 120;
  var timerInterval = null;
  var breathStep = 0;
  var completedCycles = 0;
  var breathTimeout = null;

  var elTimerDisplay, elProgressFill, elBtnStart;
  var elBreathCue, elBreathCircle, elDots, elCycleCount;
  var elLootCard, elLootBack, elLootMsg;
  var elWizard;

  function fmt(secs) {
    var m = Math.floor(secs / 60);
    var s = secs % 60;
    return pad(m) + ':' + pad(s);
  }

  function pad(n) {
    return n < 10 ? '0' + n : '' + n;
  }

  function showPhase(id) {
    var phases = document.querySelectorAll('.demo-phase');
    for (var i = 0; i < phases.length; i++) {
      phases[i].classList.add('hidden');
    }
    document.getElementById(id).classList.remove('hidden');
  }

  function setWizard(state) {
    elWizard.className = 'demo-wizard wizard-' + state;
  }

  /* ── Timer ── */

  function startTimer() {
    if (timerInterval) return;
    elBtnStart.textContent = '⏸ Pause';
    setWizard('focus');
    timerInterval = setInterval(function () {
      remainingSecs--;
      elTimerDisplay.textContent = fmt(remainingSecs);
      var pct = ((durationSecs - remainingSecs) / durationSecs) * 100;
      elProgressFill.style.width = pct + '%';
      if (remainingSecs <= 0) {
        clearInterval(timerInterval);
        timerInterval = null;
        onTimerDone();
      }
    }, 1000);
  }

  function pauseTimer() {
    clearInterval(timerInterval);
    timerInterval = null;
    elBtnStart.textContent = '▶ Resume';
    setWizard('idle');
  }

  function onTimerDone() {
    setWizard('excited');
    showPhase('phase-break');
  }

  /* ── Breathing game ── */

  function startBreathing() {
    completedCycles = 0;
    breathStep = 0;
    showPhase('phase-breathing');
    setWizard('breathing');
    updateDots();
    // small delay so circle transition fires after element is visible
    setTimeout(runBreathStep, 50);
  }

  function runBreathStep() {
    var phase = BREATH_PHASES[breathStep % 3];
    elBreathCue.textContent = phase.cue;
    if (phase.big) {
      elBreathCircle.classList.add('big');
    } else {
      elBreathCircle.classList.remove('big');
    }
    if (elCycleCount) {
      elCycleCount.textContent = completedCycles + 1;
    }
    breathTimeout = setTimeout(function () {
      breathStep++;
      if (breathStep % 3 === 0) {
        completedCycles++;
        updateDots();
        if (completedCycles >= TOTAL_CYCLES) {
          onBreathingComplete();
          return;
        }
      }
      runBreathStep();
    }, BREATH_STEP_MS);
  }

  function updateDots() {
    var dots = elDots.querySelectorAll('.demo-dot');
    for (var i = 0; i < dots.length; i++) {
      if (i < completedCycles) {
        dots[i].classList.add('active');
      } else {
        dots[i].classList.remove('active');
      }
    }
  }

  function onBreathingComplete() {
    clearTimeout(breathTimeout);
    var treasure = TREASURES[Math.floor(Math.random() * TREASURES.length)];
    elLootBack.innerHTML =
      '<span class="loot-icon">' + treasure.icon + '</span>' +
      '<span class="loot-name">' + treasure.name + '</span>';
    elLootMsg.textContent = 'Your wizard earned: ' + treasure.name + '!';
    elLootCard.classList.remove('flipped');
    showPhase('phase-loot');
    setWizard('celebrate');
    // double rAF ensures the transition fires after display change
    requestAnimationFrame(function () {
      requestAnimationFrame(function () {
        elLootCard.classList.add('flipped');
      });
    });
  }

  /* ── Reset ── */

  function resetDemo() {
    clearInterval(timerInterval);
    clearTimeout(breathTimeout);
    timerInterval = null;
    remainingSecs = durationSecs;
    elTimerDisplay.textContent = fmt(remainingSecs);
    elProgressFill.style.width = '0%';
    elBtnStart.textContent = '▶ Start Focus Session';
    elBreathCircle.classList.remove('big');
    elLootCard.classList.remove('flipped');
    setWizard('idle');
    showPhase('phase-focus');
  }

  function setDuration(secs, activeId, inactiveId) {
    clearInterval(timerInterval);
    clearTimeout(breathTimeout);
    timerInterval = null;
    durationSecs = secs;
    remainingSecs = secs;
    elTimerDisplay.textContent = fmt(secs);
    elProgressFill.style.width = '0%';
    elBtnStart.textContent = '▶ Start Focus Session';
    document.getElementById(activeId).classList.add('active');
    document.getElementById(inactiveId).classList.remove('active');
    showPhase('phase-focus');
    setWizard('idle');
  }

  /* ── Init ── */

  function init() {
    elTimerDisplay = document.getElementById('demo-timer-display');
    if (!elTimerDisplay) return;

    elProgressFill = document.getElementById('demo-progress-fill');
    elBtnStart = document.getElementById('demo-btn-start');
    elBreathCue = document.getElementById('demo-breath-cue');
    elBreathCircle = document.getElementById('demo-breath-circle');
    elDots = document.getElementById('demo-cycle-dots');
    elCycleCount = document.getElementById('demo-cycle-count');
    elLootCard = document.getElementById('demo-loot-card');
    elLootBack = document.getElementById('demo-loot-back');
    elLootMsg = document.getElementById('demo-loot-msg');
    elWizard = document.getElementById('demo-wizard');

    document.getElementById('demo-btn-25').addEventListener('click', function () {
      setDuration(1500, 'demo-btn-25', 'demo-btn-2');
    });
    document.getElementById('demo-btn-2').addEventListener('click', function () {
      setDuration(120, 'demo-btn-2', 'demo-btn-25');
    });
    elBtnStart.addEventListener('click', function () {
      if (timerInterval) { pauseTimer(); } else { startTimer(); }
    });
    document.getElementById('demo-btn-breathe').addEventListener('click', startBreathing);
    document.getElementById('demo-btn-reset').addEventListener('click', resetDemo);

    elTimerDisplay.textContent = fmt(remainingSecs);
    setWizard('idle');
  }

  document.addEventListener('DOMContentLoaded', init);
})();

(() => {
  "use strict";

  const $ = (sel, el = document) => el.querySelector(sel);
  const $$ = (sel, el = document) => [...el.querySelectorAll(sel)];

  let allCards = [];
  let view = "launcher";
  let settings = { mix: "mcq", dir: "termDef", chapters: new Set() };
  let deck = [];
  let turns = [];
  let currentIndex = 0;
  let answers = [];
  let mcqSelected = null;
  /** Alleen bij mode `blank`: na „Laat antwoord zien”. */
  let blankRevealed = false;
  /** Alleen bij mode `typing`: na „Antwoord tonen”, vóór Goed/Fout. */
  let typingJudgePhase = false;
  /** Ronde met alleen kaarten die in de vorige ronde fout gingen. */
  let replayWrongOnly = false;

  const STORAGE_KEY = "studie-dogmatiek-web-cards-v1";
  /** Ruwe rijen uit `terms.json` (voor herstellen). */
  let bundledDefaultRows = null;

  function normalize(s) {
    return String(s || "")
      .toLowerCase()
      .normalize("NFD")
      .replace(/\p{M}/gu, "")
      .replace(/\s+/g, " ")
      .trim();
  }

  function updateSourcePageLabel(card) {
    const el = $("#prompt-page");
    if (!el || !card) return;
    const p = card.sourcePage;
    if (p != null && p !== "" && Number.isFinite(Number(p))) {
      el.textContent = `blz ${p}`;
      el.classList.remove("hidden");
    } else {
      el.textContent = "";
      el.classList.add("hidden");
    }
  }

  function collapseTypingJudge() {
    typingJudgePhase = false;
    $("#typing-review").classList.add("hidden");
    $("#answer-input").disabled = false;
    $("#typing-area").classList.remove("hidden");
    $("#btn-submit").classList.remove("hidden");
    $("#actions-main").classList.remove("hidden");
    $("#actions-judge-prev-only").classList.add("hidden");
    updatePrevButton();
  }

  function onJudgePrev() {
    const turn = turns[currentIndex];
    if (turn && turn.mode === "typing" && typingJudgePhase) {
      collapseTypingJudge();
      return;
    }
    onPrev();
  }

  function tokenSet(s) {
    return new Set(
      normalize(s)
        .split(" ")
        .filter((t) => t.length > 1)
    );
  }

  /** Vereenvoudigde beoordeling (los van de iOS-app). */
  function answersMatch(user, expected) {
    const u = normalize(user);
    const e = normalize(expected);
    if (!u || !e) return false;
    if (u === e) return true;
    if (u.includes(e) || e.includes(u)) return true;
    const ut = tokenSet(u);
    const et = tokenSet(e);
    if (et.size === 0) return false;
    let hit = 0;
    for (const t of et) if (ut.has(t)) hit++;
    const cov = hit / et.size;
    return cov >= 0.55;
  }

  function shuffle(arr) {
    const a = [...arr];
    for (let i = a.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [a[i], a[j]] = [a[j], a[i]];
    }
    return a;
  }

  function uniqueDeck(cards) {
    const seen = new Set();
    const out = [];
    for (const c of cards) {
      const k = normalize(c.term) + "|" + c.chapter;
      if (seen.has(k)) continue;
      seen.add(k);
      out.push(c);
    }
    return out;
  }

  function randomBool() {
    return Math.random() < 0.5;
  }

  function showTermFirstForTyping() {
    if (settings.dir === "termDef") return true;
    if (settings.dir === "defTerm") return false;
    return randomBool();
  }

  function mcqPicksDefinition() {
    if (settings.dir === "termDef") return true;
    if (settings.dir === "defTerm") return false;
    return randomBool();
  }

  function buildTurns() {
    const list = shuffle(deck);
    const out = [];
    if (settings.mix === "blank") {
      for (const card of list) {
        out.push({ card, mode: "blank", showTermFirst: showTermFirstForTyping() });
      }
      return out;
    }
    for (const card of list) {
      out.push({ card, mode: "mcq", pickDefinition: mcqPicksDefinition() });
    }
    return out;
  }

  function mcqOptionsForTurn(turn) {
    const { card, pickDefinition } = turn;
    const pool = deck.filter((c) => c.id !== card.id);
    if (pickDefinition) {
      const correct = card.definition.trim();
      const defs = shuffle(
        pool.map((c) => c.definition.trim()).filter((d) => d && d !== correct)
      );
      const pick = defs.slice(0, 3);
      while (pick.length < 3) pick.push("—");
      return shuffle([correct, ...pick]).map((text) => ({ text, correct: text === correct }));
    }
    const correct = card.term.trim();
    const terms = shuffle(
      pool.map((c) => c.term.trim()).filter((t) => t && t !== correct)
    );
    const pick = terms.slice(0, 3);
    while (pick.length < 3) pick.push("—");
    return shuffle([correct, ...pick]).map((text) => ({ text, correct: text === correct }));
  }

  function chaptersFromCards(cards) {
    const arr = [...new Set(cards.map((c) => c.chapter))];
    const introIdx = arr.findIndex((c) => normalize(c) === "inleiding");
    let first = [];
    let rest = arr;
    if (introIdx >= 0) {
      first = [arr[introIdx]];
      rest = arr.filter((_, i) => i !== introIdx);
    }
    rest.sort((a, b) => a.localeCompare(b, "nl"));
    return [...first, ...rest];
  }

  function renderChapterList() {
    const list = $("#chapter-list");
    const total = allCards.length;
    $("#total-terms").textContent = total ? `(${total} termen in de bibliotheek)` : "";
    list.innerHTML = "";
    for (const ch of chaptersFromCards(allCards)) {
      const n = allCards.filter((c) => c.chapter === ch).length;
      const id = "ch-" + String(Math.random()).slice(2, 10);
      const lab = document.createElement("label");
      lab.innerHTML = `<input type="checkbox" id="${id}" value="${escapeHtml(ch)}" /> <span>${escapeHtml(
        ch
      )}</span> <span class="muted">(${n} termen)</span>`;
      list.appendChild(lab);
    }
    list.querySelectorAll("input[type=checkbox]").forEach((inp) => {
      inp.addEventListener("change", () => syncChapterSelection(inp));
    });
  }

  function escapeHtml(s) {
    return String(s)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");
  }

  function generateCardId() {
    if (typeof crypto !== "undefined" && crypto.randomUUID) {
      return crypto.randomUUID();
    }
    return "c" + Date.now() + "-" + Math.random().toString(36).slice(2, 11);
  }

  function cardsFromJsonRows(raw, preserveIds) {
    const used = new Set();
    const out = [];
    let i = 0;
    for (const row of raw) {
      const sp = row.sourcePage;
      const n = sp == null || sp === "" ? null : Number(sp);
      let id =
        preserveIds && row.id != null && String(row.id).trim() !== ""
          ? String(row.id).trim()
          : String(i);
      while (used.has(id)) {
        id = generateCardId();
      }
      used.add(id);
      out.push({
        id,
        term: (row.term || "").trim(),
        definition: (row.definition || "").trim(),
        chapter: (row.chapter || "Overig").trim(),
        contextNote: row.contextNote ? String(row.contextNote).trim() : "",
        subgroup: row.subgroup ? String(row.subgroup).trim() : "",
        sourcePage: Number.isFinite(n) && n > 0 ? n : null,
      });
      i++;
    }
    return out;
  }

  function persistLibrary() {
    try {
      const minimal = allCards.map((c) => ({
        id: c.id,
        term: c.term,
        definition: c.definition,
        chapter: c.chapter,
        contextNote: c.contextNote || "",
        subgroup: c.subgroup || "",
        sourcePage: c.sourcePage,
      }));
      localStorage.setItem(STORAGE_KEY, JSON.stringify(minimal));
    } catch (err) {
      alert("Opslaan mislukt (bijv. opslag vol of privévenster).");
    }
    updateManageStatusLine();
  }

  function updateManageStatusLine() {
    const el = $("#manage-storage-hint");
    if (!el) return;
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      const has = raw != null && raw !== "" && raw !== "[]";
      el.textContent = has
        ? "Je eigen lijst staat in deze browser (localStorage). Gebruik Exporteren als reservekopie."
        : "Standaardset uit het bestand. Na bewerken wordt je kopie hier opgeslagen.";
    } catch (_) {
      el.textContent = "";
    }
  }

  function fillChapterSuggestions() {
    const dl = $("#chapter-suggestions");
    if (!dl) return;
    dl.innerHTML = "";
    const titles = [...new Set(allCards.map((c) => c.chapter))].sort((a, b) =>
      a.localeCompare(b, "nl")
    );
    for (const t of titles) {
      const o = document.createElement("option");
      o.value = t;
      dl.appendChild(o);
    }
  }

  function truncatePreview(s, n) {
    const t = String(s);
    return t.length <= n ? t : t.slice(0, n) + "…";
  }

  function syncChapterCheckboxesWithSettings() {
    const valid = new Set(chaptersFromCards(allCards));
    for (const ch of [...settings.chapters]) {
      if (!valid.has(ch)) settings.chapters.delete(ch);
    }
    const allCh = chaptersFromCards(allCards);
    $("#chk-all").checked =
      settings.chapters.size > 0 && settings.chapters.size === allCh.length;
    $$("#chapter-list input[type=checkbox]").forEach((inp) => {
      if (!inp.value) return;
      inp.checked = settings.chapters.has(inp.value);
    });
    updateStartEnabled();
  }

  function openManage() {
    setView("manage");
    updateManageStatusLine();
    fillChapterSuggestions();
    renderManageList();
  }

  function closeManage() {
    setView("setup");
  }

  function renderManageList() {
    const root = $("#manage-list");
    if (!root) return;
    root.innerHTML = "";
    if (allCards.length === 0) {
      root.innerHTML = `<p class="muted">Geen termen. Voeg een nieuwe toe of herstel de standaardset.</p>`;
      return;
    }
    for (const ch of chaptersFromCards(allCards)) {
      const cards = allCards.filter((c) => c.chapter === ch);
      const sec = document.createElement("section");
      sec.className = "manage-chapter";
      const h = document.createElement("h3");
      h.className = "manage-chapter-title";
      h.textContent = `${ch} (${cards.length})`;
      sec.appendChild(h);
      const ul = document.createElement("ul");
      ul.className = "manage-card-list";
      for (const c of cards) {
        const li = document.createElement("li");
        li.className = "manage-card-row";
        const safeId = escapeHtml(c.id);
        li.innerHTML = `<div class="manage-card-preview"><strong>${escapeHtml(
          c.term
        )}</strong><span class="manage-def-preview">${escapeHtml(
          truncatePreview(c.definition, 100)
        )}</span></div><div class="manage-card-actions"><button type="button" class="btn-edit" data-id="${safeId}">Bewerken</button><button type="button" class="btn-del" data-id="${safeId}">Verwijderen</button></div>`;
        ul.appendChild(li);
      }
      sec.appendChild(ul);
      root.appendChild(sec);
    }
    root.querySelectorAll(".btn-edit").forEach((btn) => {
      btn.addEventListener("click", () => openCardDialog(btn.dataset.id));
    });
    root.querySelectorAll(".btn-del").forEach((btn) => {
      btn.addEventListener("click", () => deleteCard(btn.dataset.id));
    });
  }

  function openCardDialog(id) {
    const dlg = $("#dlg-card");
    const isNew = id == null || String(id).trim() === "";
    $("#dlg-card-title").textContent = isNew ? "Nieuwe term" : "Term bewerken";
    $("#ed-id").value = isNew ? "" : id;
    if (isNew) {
      $("#ed-term").value = "";
      $("#ed-definition").value = "";
      $("#ed-chapter").value = "";
      $("#ed-sourcepage").value = "";
      $("#ed-context").value = "";
    } else {
      const c = allCards.find((x) => x.id === id);
      if (!c) return;
      $("#ed-term").value = c.term;
      $("#ed-definition").value = c.definition;
      $("#ed-chapter").value = c.chapter;
      $("#ed-sourcepage").value = c.sourcePage != null ? String(c.sourcePage) : "";
      $("#ed-context").value = c.contextNote || "";
    }
    fillChapterSuggestions();
    dlg.showModal();
  }

  function saveCardFromDialog() {
    const term = $("#ed-term").value.trim();
    const definition = $("#ed-definition").value.trim();
    const chapter = $("#ed-chapter").value.trim();
    if (!term || !definition || !chapter) {
      alert("Vul term, definitie en hoofdstuk in.");
      return;
    }
    const spRaw = $("#ed-sourcepage").value.trim();
    const n = spRaw === "" ? null : Number(spRaw);
    const sourcePage = n != null && Number.isFinite(n) && n > 0 ? Math.round(n) : null;
    const contextNote = $("#ed-context").value.trim();
    const hid = $("#ed-id").value.trim();
    if (hid) {
      const i = allCards.findIndex((c) => c.id === hid);
      if (i >= 0) {
        allCards[i] = {
          ...allCards[i],
          term,
          definition,
          chapter,
          sourcePage,
          contextNote,
        };
      }
    } else {
      allCards.push({
        id: generateCardId(),
        term,
        definition,
        chapter,
        sourcePage,
        contextNote,
        subgroup: "",
      });
    }
    persistLibrary();
    $("#dlg-card").close();
    renderChapterList();
    renderManageList();
    fillChapterSuggestions();
    syncChapterCheckboxesWithSettings();
  }

  function deleteCard(id) {
    if (!confirm("Deze term verwijderen?")) return;
    allCards = allCards.filter((c) => c.id !== id);
    persistLibrary();
    renderChapterList();
    renderManageList();
    fillChapterSuggestions();
    syncChapterCheckboxesWithSettings();
  }

  function exportJson() {
    const rows = allCards.map((c) => ({
      id: c.id,
      term: c.term,
      definition: c.definition,
      chapter: c.chapter,
      contextNote: c.contextNote || "",
      subgroup: c.subgroup || "",
      sourcePage: c.sourcePage,
    }));
    const blob = new Blob([JSON.stringify(rows, null, 2)], { type: "application/json" });
    const a = document.createElement("a");
    a.href = URL.createObjectURL(blob);
    a.download = "dogmatiek-termen.json";
    a.click();
    URL.revokeObjectURL(a.href);
  }

  function resetToBundledDefault() {
    if (!bundledDefaultRows || bundledDefaultRows.length === 0) {
      alert("Standaardset is niet geladen.");
      return;
    }
    localStorage.removeItem(STORAGE_KEY);
    allCards = cardsFromJsonRows(bundledDefaultRows, false);
    renderChapterList();
    renderManageList();
    fillChapterSuggestions();
    settings.chapters = new Set();
    $("#chk-all").checked = false;
    syncChapterCheckboxesWithSettings();
    updateManageStatusLine();
    $("#dlg-reset").close();
  }

  function syncChapterSelection(changed) {
    const ch = changed.value;
    if (!ch) return;
    if (changed.checked) settings.chapters.add(ch);
    else settings.chapters.delete(ch);
    $("#chk-all").checked =
      settings.chapters.size > 0 && settings.chapters.size === chaptersFromCards(allCards).length;
    updateStartEnabled();
  }

  function updateStartEnabled() {
    $("#btn-start").disabled = settings.chapters.size === 0;
  }

  function setView(v) {
    view = v;
    const isComing = v === "coming-ot" || v === "coming-nt";
    $("#view-launcher").classList.toggle("hidden", v !== "launcher");
    $("#view-coming").classList.toggle("hidden", !isComing);
    $("#view-setup").classList.toggle("hidden", v !== "setup");
    $("#view-manage").classList.toggle("hidden", v !== "manage");
    $("#view-session").classList.toggle("hidden", v !== "session");
    $("#view-summary").classList.toggle("hidden", v !== "summary");

    const backHidden = v === "launcher";
    $("#btn-back").classList.toggle("hidden", backHidden);
    if (!backHidden) {
      $("#btn-back").textContent = v === "setup" ? "← Vakken" : "← Terug";
    }

    if (v === "launcher") {
      document.title = "Studie";
      $("#title").textContent = "Studie";
    } else if (v === "coming-ot") {
      document.title = "Oude Testament — binnenkort";
      $("#title").textContent = "Oude Testament";
      $("#coming-title").textContent = "Oude Testament";
      $("#coming-body").textContent =
        "Hier komen straks aparte oefeningen voor het Oude Testament. Tot die tijd kun je onder Dogmatiek verder oefenen.";
    } else if (v === "coming-nt") {
      document.title = "Nieuwe Testament — binnenkort";
      $("#title").textContent = "Nieuwe Testament";
      $("#coming-title").textContent = "Nieuwe Testament";
      $("#coming-body").textContent =
        "Hier komen straks aparte oefeningen voor het Nieuwe Testament. Tot die tijd kun je onder Dogmatiek verder oefenen.";
    } else if (v === "setup") {
      document.title = "Dogmatiek — oefenen";
      $("#title").textContent = "Dogmatiek oefenen";
    } else if (v === "manage") {
      document.title = "Termen beheren";
      $("#title").textContent = "Termen beheren";
    } else if (v === "summary") {
      document.title = "Dogmatiek — ronde afgerond";
      $("#title").textContent = "Ronde afgerond";
    } else if (v === "session") {
      document.title = replayWrongOnly
        ? "Dogmatiek — fouten opnieuw"
        : settings.mix === "blank"
          ? "Dogmatiek — zelf invullen"
          : "Dogmatiek — oefenen";
      $("#title").textContent = replayWrongOnly
        ? "Fouten opnieuw"
        : settings.mix === "blank"
          ? "Oefenen · zelf invullen"
          : "Oefenen";
    }
  }

  function requestExit() {
    if (view === "launcher") return;
    if (view === "coming-ot" || view === "coming-nt") {
      setView("launcher");
      return;
    }
    if (view === "setup") {
      setView("launcher");
      return;
    }
    if (view === "manage") {
      closeManage();
      return;
    }
    $("#dlg-exit").showModal();
  }

  function confirmExit() {
    $("#dlg-exit").close();
    answers = [];
    turns = [];
    currentIndex = 0;
    mcqSelected = null;
    blankRevealed = false;
    typingJudgePhase = false;
    replayWrongOnly = false;
    setView("setup");
  }

  function setBlankPhaseUI() {
    const turn = turns[currentIndex];
    const blankEl = $("#blank-area");
    const ph = $("#blank-placeholder");
    const rev = $("#blank-revealed");
    const actionsMain = $("#actions-main");
    const actionsPrevOnly = $("#actions-judge-prev-only");
    if (turn.mode !== "blank") {
      blankEl.classList.add("hidden");
      actionsPrevOnly.classList.add("hidden");
      actionsMain.classList.remove("hidden");
      return;
    }
    blankEl.classList.remove("hidden");
    if (!blankRevealed) {
      ph.classList.remove("hidden");
      rev.classList.add("hidden");
      actionsMain.classList.remove("hidden");
      actionsPrevOnly.classList.add("hidden");
      $("#btn-submit").classList.remove("hidden");
      $("#btn-submit").textContent = "Laat antwoord zien";
    } else {
      ph.classList.add("hidden");
      rev.classList.remove("hidden");
      actionsMain.classList.add("hidden");
      actionsPrevOnly.classList.remove("hidden");
    }
  }

  function showSessionQuestion() {
    const turn = turns[currentIndex];
    const { card, mode } = turn;
    blankRevealed = false;
    typingJudgePhase = false;
    $("#typing-review").classList.add("hidden");
    $("#answer-input").disabled = false;
    const progPfx = replayWrongOnly ? "Fouten · " : "";
    $("#progress").textContent = `${progPfx}Vraag ${currentIndex + 1} van ${turns.length}`;
    const note = $("#context-note");
    if (card.contextNote) {
      note.textContent = "Ter info: " + card.contextNote;
      note.classList.remove("hidden");
    } else {
      note.classList.add("hidden");
    }

    const typingEl = $("#typing-area");
    const mcqEl = $("#mcq-area");
    const blankEl = $("#blank-area");
    $("#answer-input").value = "";

    if (mode === "typing") {
      typingEl.classList.remove("hidden");
      mcqEl.classList.add("hidden");
      blankEl.classList.add("hidden");
      $("#actions-judge-prev-only").classList.add("hidden");
      $("#actions-main").classList.remove("hidden");
      $("#btn-submit").classList.remove("hidden");
      const showTerm = turn.showTermFirst;
      $("#prompt-label").textContent = showTerm ? "Wat is de definitie?" : "Welke term hoort hierbij?";
      $("#prompt-text").textContent = showTerm ? card.term : card.definition;
      updateSourcePageLabel(card);
    } else if (mode === "blank") {
      typingEl.classList.add("hidden");
      mcqEl.classList.add("hidden");
      blankEl.classList.remove("hidden");
      const showTerm = turn.showTermFirst;
      $("#prompt-label").textContent = showTerm ? "Wat is de definitie?" : "Welke term hoort hierbij?";
      $("#prompt-text").textContent = showTerm ? card.term : card.definition;
      const expected = showTerm ? card.definition : card.term;
      $("#blank-answer-text").textContent = expected;
      updateSourcePageLabel(card);
      setBlankPhaseUI();
    } else {
      typingEl.classList.add("hidden");
      mcqEl.classList.remove("hidden");
      blankEl.classList.add("hidden");
      $("#actions-judge-prev-only").classList.add("hidden");
      $("#actions-main").classList.remove("hidden");
      $("#btn-submit").classList.remove("hidden");
      const pickDef = turn.pickDefinition;
      $("#prompt-label").textContent = pickDef ? "Kies de juiste definitie" : "Kies de juiste term";
      $("#prompt-text").textContent = pickDef ? card.term : card.definition;
      updateSourcePageLabel(card);
      mcqSelected = null;
      const opts = mcqOptionsForTurn(turn);
      mcqEl.innerHTML = "";
      for (const o of opts) {
        const b = document.createElement("button");
        b.type = "button";
        b.className = "mcq-opt";
        b.textContent = o.text;
        b.addEventListener("click", () => {
          $$(".mcq-opt", mcqEl).forEach((x) => x.classList.remove("selected"));
          b.classList.add("selected");
          mcqSelected = o.text;
        });
        mcqEl.appendChild(b);
      }
    }

    if (mode === "typing") {
      $("#btn-submit").textContent = "Antwoord tonen";
    } else if (mode === "mcq") {
      $("#btn-submit").textContent = currentIndex + 1 >= turns.length ? "Afronden" : "Volgende";
    }
    updatePrevButton();
  }

  function updatePrevButton() {
    const turn = turns[currentIndex];
    const prevJudge = $("#btn-judge-prev");
    if (turn && turn.mode === "typing" && typingJudgePhase) {
      $("#btn-prev").disabled = true;
      if (prevJudge) prevJudge.disabled = false;
      return;
    }
    const can = currentIndex > 0 && answers.length === currentIndex;
    $("#btn-prev").disabled = !can;
    if (prevJudge) prevJudge.disabled = !can;
  }

  function evaluateCurrent() {
    const turn = turns[currentIndex];
    const { card, mode } = turn;
    if (mode === "blank") {
      const showTerm = turn.showTermFirst;
      const expected = showTerm ? card.definition : card.term;
      return { ok: false, user: "", expected };
    }
    if (mode === "typing") {
      const showTerm = turn.showTermFirst;
      const expected = showTerm ? card.definition : card.term;
      const user = $("#answer-input").value;
      return { ok: answersMatch(user, expected), user, expected };
    }
    const pickDef = turn.pickDefinition;
    const expected = pickDef ? card.definition.trim() : card.term.trim();
    const user = (mcqSelected || "").trim();
    return { ok: normalize(user) === normalize(expected), user, expected };
  }

  function pushAnswer(rec) {
    answers.push(rec);
  }

  function modeLabel(mode) {
    if (mode === "mcq") return "Meerkeuze";
    if (mode === "blank") return "Zelf invullen";
    return "Typen";
  }

  function promptDirectionNote(rec) {
    if (rec.mode === "typing" || rec.mode === "blank") {
      if (rec.showTermFirst === undefined) return "";
      return rec.showTermFirst
        ? "Vraag: term getoond → definitie gezocht."
        : "Vraag: definitie getoond → term gezocht.";
    }
    if (rec.mode === "mcq") {
      if (rec.pickDefinition === undefined) return "";
      return rec.pickDefinition
        ? "Vraag: term getoond → juiste definitie kiezen."
        : "Vraag: definitie getoond → juiste term kiezen.";
    }
    return "";
  }

  function renderWrongReviewList() {
    const wrap = $("#wrong-review-wrap");
    const ul = $("#wrong-review-list");
    const btnW = $("#btn-practice-wrong");
    if (!wrap || !ul) return;
    const wrong = answers.filter((a) => !a.ok);
    if (wrong.length === 0) {
      wrap.classList.add("hidden");
      if (btnW) btnW.classList.add("hidden");
      return;
    }
    wrap.classList.remove("hidden");
    if (btnW) btnW.classList.remove("hidden");
    ul.innerHTML = "";
    for (const rec of wrong) {
      const { card, user, mode } = rec;
      const dirNote = promptDirectionNote(rec);
      const li = document.createElement("li");
      li.className = "wrong-review-item";
      li.innerHTML = `<p class="wrong-review-meta">${escapeHtml(card.chapter)} · ${escapeHtml(
        modeLabel(mode)
      )}</p>
        ${dirNote ? `<p class="small muted wrong-review-dir">${escapeHtml(dirNote)}</p>` : ""}
        <p><strong>Term</strong> — ${escapeHtml(card.term)}</p>
        <p><strong>Definitie</strong> — ${escapeHtml(card.definition)}</p>
        <p><strong>Jouw antwoord</strong> — ${escapeHtml(user != null && String(user).trim() !== "" ? String(user) : "—")}</p>`;
      ul.appendChild(li);
    }
  }

  function showSummary() {
    const good = answers.filter((a) => a.ok).length;
    const bad = answers.length - good;
    $("#sum-good").textContent = String(good);
    $("#sum-bad").textContent = String(bad);
    renderWrongReviewList();
    setView("summary");
  }

  function startWrongReplay() {
    const wrongCards = uniqueDeck(
      answers.filter((a) => !a.ok).map((a) => a.card)
    );
    if (wrongCards.length === 0) return;
    replayWrongOnly = true;
    deck = wrongCards;
    turns = buildTurns();
    currentIndex = 0;
    answers = [];
    mcqSelected = null;
    blankRevealed = false;
    typingJudgePhase = false;
    setView("session");
    showSessionQuestion();
  }

  function init() {
    setView("launcher");

    $("#launch-dogmatiek").addEventListener("click", () => setView("setup"));
    $("#launch-ot").addEventListener("click", () => setView("coming-ot"));
    $("#launch-nt").addEventListener("click", () => setView("coming-nt"));

    $("#btn-back").addEventListener("click", () => requestExit());
    $("#dlg-exit-cancel").addEventListener("click", () => $("#dlg-exit").close());
    $("#dlg-exit-confirm").addEventListener("click", () => confirmExit());

    const mixHints = {
      mcq: "Meerkeuze: kies het juiste antwoord uit vier opties.",
      blank:
        "Zelf invullen: je ziet de prompt, denkt na, tik op Laat antwoord zien en kiest daarna zelf Goed of Fout.",
    };
    $$(".seg").forEach((b) => {
      b.addEventListener("click", () => {
        $$(".seg").forEach((x) => x.classList.remove("active"));
        b.classList.add("active");
        settings.mix = b.dataset.mix;
        $("#mix-hint").textContent = mixHints[settings.mix] || mixHints.mcq;
      });
    });
    $("#mix-hint").textContent = mixHints[settings.mix] || mixHints.mcq;

    $$(".seg-dir").forEach((b) => {
      b.addEventListener("click", () => {
        $$(".seg-dir").forEach((x) => x.classList.remove("active"));
        b.classList.add("active");
        settings.dir = b.dataset.dir;
      });
    });

    $("#chk-all").addEventListener("change", (e) => {
      const on = e.target.checked;
      const allCh = chaptersFromCards(allCards);
      if (on) {
        settings.chapters = new Set(allCh);
      } else {
        settings.chapters.clear();
      }
      $$("#chapter-list input[type=checkbox]").forEach((inp) => {
        inp.checked = on && !!inp.value;
      });
      updateStartEnabled();
    });

    $("#btn-start").addEventListener("click", startSession);
    $("#btn-submit").addEventListener("click", onSubmit);
    $("#btn-prev").addEventListener("click", onPrev);
    $("#btn-blank-good").addEventListener("click", () => finishBlankTurn(true));
    $("#btn-blank-wrong").addEventListener("click", () => finishBlankTurn(false));
    $("#btn-typing-good").addEventListener("click", () => finishTypingSelfJudge(true));
    $("#btn-typing-wrong").addEventListener("click", () => finishTypingSelfJudge(false));
    $("#btn-judge-prev").addEventListener("click", onJudgePrev);
    $("#btn-open-manage").addEventListener("click", openManage);
    $("#btn-new-card").addEventListener("click", () => openCardDialog(null));
    $("#form-card").addEventListener("submit", (e) => {
      e.preventDefault();
      saveCardFromDialog();
    });
    $("#dlg-card-cancel").addEventListener("click", () => $("#dlg-card").close());
    $("#btn-export-json").addEventListener("click", exportJson);
    $("#import-json-file").addEventListener("change", (e) => {
      const f = e.target.files && e.target.files[0];
      if (!f) return;
      const reader = new FileReader();
      reader.onload = () => {
        try {
          const data = JSON.parse(String(reader.result));
          if (!Array.isArray(data) || data.length === 0) throw new Error("empty");
          allCards = cardsFromJsonRows(data, true);
          persistLibrary();
          renderChapterList();
          renderManageList();
          fillChapterSuggestions();
          syncChapterCheckboxesWithSettings();
        } catch (_) {
          alert("Kon dit bestand niet als termenlijst lezen.");
        }
        e.target.value = "";
      };
      reader.readAsText(f);
    });
    $("#btn-reset-default").addEventListener("click", () => $("#dlg-reset").showModal());
    $("#dlg-reset-cancel").addEventListener("click", () => $("#dlg-reset").close());
    $("#dlg-reset-confirm").addEventListener("click", resetToBundledDefault);
    $("#btn-again").addEventListener("click", startSession);
    $("#btn-practice-wrong").addEventListener("click", startWrongReplay);
    $("#btn-home").addEventListener("click", () => {
      answers = [];
      turns = [];
      currentIndex = 0;
      blankRevealed = false;
      typingJudgePhase = false;
      replayWrongOnly = false;
      setView("setup");
    });
  }

  function startSession() {
    replayWrongOnly = false;
    deck = uniqueDeck(allCards.filter((c) => settings.chapters.has(c.chapter)));
    if (deck.length === 0) {
      alert("Geen termen in de gekozen hoofdstukken.");
      return;
    }
    turns = buildTurns();
    currentIndex = 0;
    answers = [];
    mcqSelected = null;
    blankRevealed = false;
    typingJudgePhase = false;
    setView("session");
    showSessionQuestion();
  }

  function finishBlankTurn(ok) {
    const turn = turns[currentIndex];
    if (turn.mode !== "blank" || !blankRevealed) return;
    const showTerm = turn.showTermFirst;
    const expected = showTerm ? turn.card.definition : turn.card.term;
    pushAnswer({
      ok,
      user: "(zelf invullen)",
      expected,
      card: turn.card,
      mode: "blank",
      showTermFirst: turn.showTermFirst,
    });
    if (currentIndex + 1 >= turns.length) {
      showSummary();
      return;
    }
    currentIndex++;
    showSessionQuestion();
  }

  function finishTypingSelfJudge(ok) {
    const turn = turns[currentIndex];
    if (turn.mode !== "typing" || !typingJudgePhase) return;
    const showTerm = turn.showTermFirst;
    const expected = showTerm ? turn.card.definition : turn.card.term;
    const user = $("#answer-input").value.trim();
    pushAnswer({
      ok,
      user,
      expected,
      card: turn.card,
      mode: "typing",
      showTermFirst: turn.showTermFirst,
    });
    typingJudgePhase = false;
    $("#answer-input").disabled = false;
    $("#typing-review").classList.add("hidden");
    $("#typing-area").classList.remove("hidden");
    $("#actions-judge-prev-only").classList.add("hidden");
    $("#actions-main").classList.remove("hidden");
    $("#btn-submit").classList.remove("hidden");
    if (currentIndex + 1 >= turns.length) {
      showSummary();
      return;
    }
    currentIndex++;
    showSessionQuestion();
  }

  function onSubmit() {
    const turn = turns[currentIndex];
    if (turn.mode === "blank") {
      if (blankRevealed) return;
      blankRevealed = true;
      setBlankPhaseUI();
      updatePrevButton();
      return;
    }
    if (turn.mode === "typing") {
      if (typingJudgePhase) return;
      if (!$("#answer-input").value.trim()) return;
      typingJudgePhase = true;
      const showTerm = turn.showTermFirst;
      const expected = showTerm ? turn.card.definition : turn.card.term;
      $("#typing-review-user").textContent = $("#answer-input").value.trim();
      $("#typing-review-expected").textContent = expected;
      $("#typing-review").classList.remove("hidden");
      $("#typing-area").classList.add("hidden");
      $("#btn-submit").classList.add("hidden");
      $("#actions-main").classList.add("hidden");
      $("#actions-judge-prev-only").classList.remove("hidden");
      updatePrevButton();
      return;
    }
    if (turn.mode === "mcq" && !mcqSelected) return;

    const { ok, user, expected } = evaluateCurrent();
    pushAnswer({
      ok,
      user,
      expected,
      card: turn.card,
      mode: turn.mode,
      pickDefinition: turn.pickDefinition,
    });

    if (currentIndex + 1 >= turns.length) {
      showSummary();
      return;
    }
    currentIndex++;
    showSessionQuestion();
  }

  function onPrev() {
    if (!(currentIndex > 0 && answers.length === currentIndex)) return;
    currentIndex--;
    const last = answers.pop();
    const turn = turns[currentIndex];
    blankRevealed = false;
    typingJudgePhase = false;
    $("#typing-review").classList.add("hidden");
    $("#answer-input").disabled = false;
    if (turn.mode === "typing") {
      $("#answer-input").value = last.user || "";
    } else if (turn.mode === "mcq") {
      mcqSelected = last.user || null;
      $$(".mcq-opt", $("#mcq-area")).forEach((b) => {
        b.classList.toggle("selected", b.textContent === mcqSelected);
      });
    }
    showSessionQuestion();
  }

  async function load() {
    try {
      const res = await fetch("data/terms.json", { cache: "no-store" });
      if (!res.ok) throw new Error(String(res.status));
      const raw = await res.json();
      bundledDefaultRows = raw;
      let fromStorage = null;
      try {
        const s = localStorage.getItem(STORAGE_KEY);
        if (s) {
          const p = JSON.parse(s);
          if (Array.isArray(p) && p.length > 0) fromStorage = p;
        }
      } catch (_) {
        fromStorage = null;
      }
      allCards = cardsFromJsonRows(
        fromStorage && fromStorage.length ? fromStorage : raw,
        !!fromStorage
      );
      renderChapterList();
      fillChapterSuggestions();
      updateStartEnabled();
      updateManageStatusLine();
    } catch (e) {
      $("#chapter-list").innerHTML =
        `<p class="muted">Kon <code>data/terms.json</code> niet laden (${escapeHtml(
          String(e)
        )}). Open deze site via een webserver in de map Webapp (bijv. <code>python3 -m http.server</code>).</p>`;
    }
  }

  init();
  load();
})();

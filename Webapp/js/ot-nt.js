(() => {
  "use strict";

  const $ = (sel, el = document) => el.querySelector(sel);
  const $$ = (sel, el = document) => [...el.querySelectorAll(sel)];

  let catalog = null;
  /** @type {"ot-menu"|"nt-menu"|"nt-combined"|"reveal"|"reveal-summary"|null} */
  let activeView = null;
  let viewStack = [];
  let session = null;

  function escapeHtml(s) {
    return String(s || "")
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");
  }

  /** Eenvoudige markdown: **vet**, regels en bullets. */
  function renderMarkdown(text) {
    const parts = String(text || "").split(/\n\n+/);
    return parts
      .map((block) => {
        const lines = block.split("\n").filter((l) => l.trim() !== "");
        if (lines.length === 0) return "";
        const isList = lines.every((l) => /^\s*[-•]/.test(l));
        if (isList) {
          const items = lines
            .map((l) => {
              const t = l.replace(/^\s*[-•]\s*/, "");
              return `<li>${inlineMd(t)}</li>`;
            })
            .join("");
          return `<ul class="md-list">${items}</ul>`;
        }
        return `<p>${lines.map(inlineMd).join("<br>")}</p>`;
      })
      .join("");
  }

  function inlineMd(s) {
    return escapeHtml(s).replace(/\*\*(.+?)\*\*/g, "<strong>$1</strong>");
  }

  function hideAllOtNtViews() {
    for (const id of [
      "view-ot-menu",
      "view-nt-menu",
      "view-nt-combined",
      "view-reveal",
      "view-reveal-summary",
    ]) {
      const el = document.getElementById(id);
      if (el) el.classList.add("hidden");
    }
  }

  function setActiveView(v) {
    hideAllOtNtViews();
    activeView = v;
    $("#view-launcher")?.classList.toggle("hidden", !!v);
    if (v) {
      const map = {
        "ot-menu": "view-ot-menu",
        "nt-menu": "view-nt-menu",
        "nt-combined": "view-nt-combined",
        reveal: "view-reveal",
        "reveal-summary": "view-reveal-summary",
      };
      const el = document.getElementById(map[v]);
      if (el) el.classList.remove("hidden");
    }
    updateChrome();
  }

  function updateChrome() {
    const back = $("#btn-back");
    const title = $("#title");
    if (!activeView) return;
    back.classList.remove("hidden");
    if (activeView === "ot-menu") {
      document.title = "Oude Testament";
      title.textContent = "Oude Testament";
      back.textContent = "← Vakken";
    } else if (activeView === "nt-menu") {
      document.title = "Nieuwe Testament";
      title.textContent = "Nieuwe Testament";
      back.textContent = "← Vakken";
    } else if (activeView === "nt-combined") {
      document.title = "NT — gecombineerd";
      title.textContent = "Gecombineerd oefenen";
      back.textContent = "← Terug";
    } else if (activeView === "reveal") {
      document.title = session?.title ? `${session.title} — oefenen` : "Oefenen";
      title.textContent = session?.title || "Oefenen";
      back.textContent = "← Terug";
    } else if (activeView === "reveal-summary") {
      document.title = "Ronde afgerond";
      title.textContent = "Ronde afgerond";
      back.textContent = "← Terug";
    }
  }

  function renderMenuSection(container, sections, onLink) {
    container.innerHTML = "";
    for (const sec of sections) {
      const wrap = document.createElement("div");
      wrap.className = "menu-section";
      const h = document.createElement("h2");
      h.className = "menu-section-title";
      h.textContent = sec.header;
      wrap.appendChild(h);
      const list = document.createElement("div");
      list.className = "menu-links";
      for (const link of sec.links) {
        const btn = document.createElement("button");
        btn.type = "button";
        btn.className = "menu-link";
        btn.textContent = link.label;
        btn.addEventListener("click", () => onLink(link));
        list.appendChild(btn);
      }
      wrap.appendChild(list);
      container.appendChild(wrap);
    }
  }

  function openOtMenu() {
    if (!catalog) return;
    viewStack = [];
    setActiveView("ot-menu");
    const el = $("#view-ot-menu");
    renderMenuSection(el, catalog.ot.sections, (link) => {
      if (link.pack) startPack(link.pack);
    });
  }

  function openNtMenu() {
    if (!catalog) return;
    viewStack = [];
    setActiveView("nt-menu");
    const el = $("#view-nt-menu");
    renderMenuSection(el, catalog.nt.sections, (link) => {
      if (link.combined) {
        viewStack.push("nt-menu");
        openNtCombinedSetup();
        return;
      }
      if (link.pack) startPack(link.pack);
    });
  }

  function openNtCombinedSetup() {
    setActiveView("nt-combined");
    const list = $("#nt-combined-list");
    const order = catalog.nt.combinedOrder;
    list.innerHTML = "";
    const selected = new Set(order);

    function syncAllChk() {
      $("#nt-chk-all").checked = selected.size === order.length;
    }

    for (const packId of order) {
      const pack = catalog.packs[packId];
      if (!pack) continue;
      const label = document.createElement("label");
      label.className = "chapter-item";
      const inp = document.createElement("input");
      inp.type = "checkbox";
      inp.value = packId;
      inp.checked = true;
      inp.addEventListener("change", () => {
        if (inp.checked) selected.add(packId);
        else selected.delete(packId);
        syncAllChk();
      });
      label.appendChild(inp);
      const span = document.createElement("span");
      span.textContent = `${pack.title} (${(pack.items || []).length})`;
      label.appendChild(span);
      list.appendChild(label);
    }

    const chkAll = $("#nt-chk-all");
    chkAll.onchange = (e) => {
      const on = e.target.checked;
      $$("input", list).forEach((inp) => {
        inp.checked = on;
        if (on) selected.add(inp.value);
        else selected.delete(inp.value);
      });
    };

    $("#nt-btn-start-combined").onclick = () => {
      const ids = order.filter((id) => selected.has(id));
      if (ids.length === 0) {
        alert("Kies minstens één onderdeel.");
        return;
      }
      startCombined(ids);
    };
  }

  function shuffle(arr) {
    const a = [...arr];
    for (let i = a.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [a[i], a[j]] = [a[j], a[i]];
    }
    return a;
  }

  function buildItems(packId, pack) {
    let items = (pack.items || []).map((it) => ({
      id: it.id,
      prompt: it.prompt,
      answer: it.answer,
      kind: it.kind || "quiz",
    }));
    if (pack.shuffle) items = shuffle(items);
    return items;
  }

  function startPack(packId) {
    const pack = catalog.packs[packId];
    if (!pack || !pack.items?.length) {
      alert("Geen oefeningen beschikbaar voor dit onderdeel.");
      return;
    }
    if (activeView === "ot-menu" || activeView === "nt-menu") {
      viewStack.push(activeView);
    }
    beginSession({
      title: pack.title,
      items: buildItems(packId, pack),
      returnTo: activeView,
    });
  }

  function startCombined(packIds) {
    viewStack.push("nt-combined");
    const items = [];
    let title = "Gecombineerd oefenen";
    for (const pid of packIds) {
      const pack = catalog.packs[pid];
      if (!pack?.items?.length) continue;
      items.push(...buildItems(pid, pack));
    }
    if (items.length === 0) {
      alert("Geen vragen in de gekozen onderdelen.");
      return;
    }
    beginSession({ title, items, returnTo: "nt-combined" });
  }

  function beginSession(cfg) {
    session = {
      title: cfg.title,
      items: cfg.items,
      index: 0,
      revealed: false,
      answers: [],
      replayWrong: false,
      returnTo: cfg.returnTo,
      againCfg: cfg,
    };
    setActiveView("reveal");
    showRevealCard();
  }

  function currentItem() {
    return session?.items[session.index];
  }

  function showRevealCard() {
    const item = currentItem();
    if (!item || !session) return;
    session.revealed = false;
    $("#reveal-progress").textContent = `Vraag ${session.index + 1} van ${session.items.length}`;
    $("#reveal-prompt-label").textContent =
      item.kind === "info" ? "Lees" : "Vraag";
    $("#reveal-prompt").innerHTML = renderMarkdown(item.prompt);
    $("#reveal-answer").innerHTML = renderMarkdown(item.answer);
    $("#reveal-answer-wrap").classList.add("hidden");
    $("#reveal-actions").classList.remove("hidden");
    $("#reveal-btn-prev").disabled = session.index === 0;
    const nextBtn = $("#reveal-btn-next");
    nextBtn.classList.remove("hidden");
    if (item.kind === "info") {
      nextBtn.textContent =
        session.index + 1 >= session.items.length ? "Afronden" : "Volgende";
    } else {
      nextBtn.textContent = "Laat antwoord zien";
    }
  }

  function onRevealNext() {
    const item = currentItem();
    if (!item || !session) return;

    if (item.kind === "info") {
      finishRevealTurn(true);
      return;
    }

    if (!session.revealed) {
      session.revealed = true;
      $("#reveal-answer-wrap").classList.remove("hidden");
      $("#reveal-btn-next").classList.add("hidden");
      return;
    }
  }

  function finishRevealTurn(ok) {
    const item = currentItem();
    if (!item || !session) return;
    session.answers.push({
      id: item.id,
      ok,
      prompt: item.prompt,
      answer: item.answer,
    });
    if (session.index + 1 >= session.items.length) {
      showRevealSummary();
      return;
    }
    session.index++;
    showRevealCard();
  }

  function showRevealSummary() {
    const good = session.answers.filter((a) => a.ok).length;
    const bad = session.answers.length - good;
    $("#reveal-sum-good").textContent = String(good);
    $("#reveal-sum-bad").textContent = String(bad);
    const wrap = $("#reveal-wrong-wrap");
    const ul = $("#reveal-wrong-list");
    const wrong = session.answers.filter((a) => !a.ok);
    if (wrong.length === 0) {
      wrap.classList.add("hidden");
      $("#reveal-btn-practice-wrong").classList.add("hidden");
    } else {
      wrap.classList.remove("hidden");
      $("#reveal-btn-practice-wrong").classList.remove("hidden");
      ul.innerHTML = "";
      for (const w of wrong) {
        const li = document.createElement("li");
        li.className = "wrong-review-item";
        li.innerHTML = `<p><strong>Vraag</strong></p><div class="md-content small">${renderMarkdown(
          w.prompt
        )}</div>`;
        ul.appendChild(li);
      }
    }
    setActiveView("reveal-summary");
  }

  function startWrongReplay() {
    if (!session) return;
    const wrongIds = new Set(session.answers.filter((a) => !a.ok).map((a) => a.id));
    const items = session.items.filter((it) => wrongIds.has(it.id));
    if (items.length === 0) return;
    session = {
      ...session,
      items,
      index: 0,
      revealed: false,
      answers: [],
      replayWrong: true,
    };
    setActiveView("reveal");
    showRevealCard();
  }

  function handleBack() {
    if (activeView === "reveal" || activeView === "reveal-summary") {
      if (
        session &&
        (session.answers.length > 0 || activeView === "reveal-summary")
      ) {
        if (!confirm("Oefening afsluiten? Je voortgang in deze ronde gaat verloren.")) {
          return true;
        }
      }
      session = null;
      const prev = viewStack.pop() || "launcher";
      if (prev === "launcher") {
        close();
        return false;
      }
      setActiveView(prev);
      if (prev === "nt-combined") openNtCombinedSetup();
      return true;
    }
    if (activeView === "nt-combined") {
      setActiveView(viewStack.pop() || "nt-menu");
      if (activeView === "nt-menu") openNtMenu();
      return true;
    }
    if (activeView === "ot-menu" || activeView === "nt-menu") {
      close();
      return false;
    }
    return false;
  }

  function close() {
    activeView = null;
    viewStack = [];
    session = null;
    hideAllOtNtViews();
    $("#view-launcher")?.classList.remove("hidden");
  }

  function isActive() {
    return activeView !== null;
  }

  async function loadCatalog() {
    const res = await fetch("data/ot-nt.json", { cache: "no-store" });
    if (!res.ok) throw new Error(String(res.status));
    catalog = await res.json();
  }

  function bindEvents() {
    $("#reveal-btn-next").addEventListener("click", onRevealNext);
    $("#reveal-btn-good").addEventListener("click", () => finishRevealTurn(true));
    $("#reveal-btn-wrong").addEventListener("click", () => finishRevealTurn(false));
    $("#reveal-btn-prev").addEventListener("click", () => {
      if (!session || session.index === 0) return;
      session.index--;
      session.answers.pop();
      showRevealCard();
    });
    $("#reveal-btn-practice-wrong").addEventListener("click", startWrongReplay);
    $("#reveal-btn-again").addEventListener("click", () => {
      if (!session?.againCfg) return;
      beginSession(session.againCfg);
    });
    $("#reveal-btn-done").addEventListener("click", () => {
      session = null;
      const prev = viewStack.pop();
      if (!prev || prev === "launcher") {
        close();
        window.StudieApp?.showLauncher?.();
        return;
      }
      setActiveView(prev);
      if (prev === "ot-menu") openOtMenu();
      else if (prev === "nt-menu") openNtMenu();
      else if (prev === "nt-combined") openNtCombinedSetup();
    });
  }

  window.StudieOtNt = {
    async init() {
      try {
        await loadCatalog();
        bindEvents();
      } catch (e) {
        console.error("OT/NT data laden mislukt", e);
      }
    },
    openOt: openOtMenu,
    openNt: openNtMenu,
    handleBack,
    close,
    isActive,
  };
})();

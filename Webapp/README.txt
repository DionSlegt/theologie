Dogmatiek webapp (oefenen)
===========================

Map voor klasgenoten: zip de hele map "Webapp" en stuur die, of zet hem op bijv. school-SFTP / Google Drive.

Starten (lokaal)
----------------
Browsers blokkeren vaak het laden van data vanaf file://. Start daarom een eenvoudige server in deze map:

  cd Webapp
  python3 -m http.server 8765

Open in de browser:

  http://localhost:8765

Of: in VS Code / Cursor "Live Server" op index.html.

Inhoud
-------
- index.html, css/style.css, js/app.js
- data/terms.json — kopie van de termen uit de Studie-app (Dogmatiek).

Let op: de webapp gebruikt een vereenvoudigde meerkeuze (4 opties uit je selectie) en lossere tekstcontrole bij typen dan de iOS-app. Voor examen-oefening blijft de app in Xcode leidend.

Online zetten (Render.com)
---------------------------
1. Zet deze map (of de hele Studie-repo) in een **Git**-repository op bijv. GitHub (gratis).
2. Ga naar https://render.com → aanmelden met GitHub.
3. **New +** → **Static Site** → kies je repository.
4. Vul in:
   - **Branch**: main (of jouw branch)
   - **Root Directory**: leeg laten als de repo de map `Webapp` bevat op hetzelfde niveau als `render.yaml`.
   - **Build Command**: leeg, of `echo ok` (er is geen npm-build).
   - **Publish directory**: `Webapp`  ← exact deze naam (kleine letters).
5. **Create Static Site**. Na een minuut krijg je een URL zoals `https://dogmatiek-oefenen.onrender.com` die je kunt doorsturen.

Alternatief met Blueprint: in Render **New +** → **Blueprint** → koppel de repo; Render leest `render.yaml` uit de **root** van de repo en maakt de static site aan. Pas eventueel `name:` in `render.yaml` aan voor een andere sitenaam.

Let op: elke gebruiker heeft **eigen** aangepaste termen in de browser (localStorage). De gedeelde site bevat wel de standaard `data/terms.json` uit de repo.

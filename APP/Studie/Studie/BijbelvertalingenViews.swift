//
//  BijbelvertalingenViews.swift
//  Studie
//

import SwiftUI

// MARK: - Opmaak

private enum BijbelvertalingenOpmaak {
    static func antwoordPerRegel(_ regels: [String]) -> String {
        regels.joined(separator: "\n\n")
    }
}

// MARK: - Begrippen typeren (data)

enum BijbelvertalingenBegrippenTyperenData {
    static let alle: [StudieBegrippenTyperenVraag] = [
        .init(
            id: "interpreteren-vertalen",
            termMarkdown: "**Interpreteren / vertalen**",
            antwoordMarkdown: BijbelvertalingenOpmaak.antwoordPerRegel([
                "Bij het bestuderen van anderstalige teksten zoals de Bijbel maakt de reader een cruciaal onderscheid tussen **interpreteren** en **vertalen**:",
                """
                - **Interpreteren (de 'wat'-fase):** Dit is de poging van de lezer om de oorspronkelijke tekst te begrijpen; wat betekent deze tekst in de brontaal?. Hoewel het onmogelijk is de volledige oorspronkelijke betekenis met zekerheid vast te stellen, helpt taalkennis en exegetische methodiek om zo dicht mogelijk in de buurt te komen en foutieve uitleg te voorkomen.
                - **Vertalen (de 'hoe'-fase):** Dit is een activiteit die volgt op de interpretatie, waarbij men zoekt naar de juiste manier om de betekenis weer te geven in het Nederlands. Vertalen is complexer omdat je rekening houdt met zowel de brontaal als de betekenisnuances in de doeltaal. Hierbij maakt de vertaler bewuste keuzes met het oog op de **doelgroep**, zoals het gebruik van \"HEERE\" versus \"HEER\".
                """,
                "Kortom: interpretatie gaat over de betekenis van de brontekst, terwijl vertalen gaat over de verwoording daarvan voor een specifiek publiek.",
            ])
        ),
        .init(
            id: "meaning-significance",
            termMarkdown: "**Meaning en significance**",
            antwoordMarkdown: BijbelvertalingenOpmaak.antwoordPerRegel([
                "Het verschil tussen deze twee termen zit in de focus: de tekst zelf versus de waarde voor de lezer.",
                """
                - **Meaning:** Dit is het geheel van **denotatie** (wat de tekst feitelijk beschrijft) en **connotatie** (de gevoelswaarde of culturele lading) van de tekst als zodanig. Het gaat om de vraag: wat betekent deze tekst taalkundig in zijn oorspronkelijke context?
                - **Significance:** Dit is de **betekenis voor een specifieke lezer** of lezerskring; welk belang of welke persoonlijke waarde heeft de tekst op dit moment voor jou?.
                """,
                "Een duidelijk voorbeeld uit de reader is **Psalm 23**: de *meaning* betreft de tekstuele beelden van een herder en grazige weiden, maar de *significance* (het belang) is voor veel mensen erg hoog omdat zij er persoonlijk troost uit putten. Bij een lijst met namen in een geslachtsregister is de *meaning* wel duidelijk, maar de *significance* voor een moderne lezer vaak een stuk lager.",
                "In de praktijk (bijvoorbeeld in een kring of pastoraal gesprek) kan iemand veel kracht putten uit een tekst (*significance*) terwijl de technische interpretatie (*meaning*) eigenlijk onjuist is.",
            ])
        ),
        .init(
            id: "woordveld",
            termMarkdown: "**Woordveld**",
            antwoordMarkdown: BijbelvertalingenOpmaak.antwoordPerRegel([
                "Het begrip **woordveld** verwijst naar de thematische context of de specifieke omgeving waarin een woord wordt gebruikt, wat bepalend is voor de juiste betekenis en vertaling. De belangrijkste kenmerken zijn:",
                """
                - **Betekenisaspecten:** Een woord heeft vaak één kernbetekenis, maar krijgt verschillende nuances (betekenisaspecten) afhankelijk van het woordveld. Zo wordt het Griekse *logos* in het woordveld van 'spreken' vertaald als \"woord\", maar in een financieel woordveld als \"rekening\".
                - **Keuze van de vertaler:** Een vertaler kan niet willekeurig een vertaling kiezen uit een woordenboek; het woordveld dwingt tot een specifieke keuze die recht doet aan de tekst.
                - **Voorbeelden:** Het Hebreeuwse *paaqad* kan afhankelijk van het veld \"bezoeken\", \"inspecteren\" of \"straffen\" betekenen.
                """,
            ])
        ),
        .init(
            id: "interpretive-community",
            termMarkdown: "**Interpretive community**",
            antwoordMarkdown: BijbelvertalingenOpmaak.antwoordPerRegel([
                "Een **interpretative community** is een groep lezers die een tekst benadert vanuit een gedeelde 'leesbril' of set verwachtingen. Belangrijke kenmerken zijn:",
                """
                - **Focus:** Verschillende gemeenschappen (zoals evangelisch, reformatorisch of katholiek) leggen eigen accenten bij het lezen van dezelfde tekst op basis van hun theologische prioriteiten.
                - **Relatie met vertalingen:** De keuze voor een specifieke Bijbelvertaling hangt vaak samen met de interpretative community, omdat taalgebruik, inhoud en geloofsbeleving nauw met elkaar verbonden zijn.
                - **Onvermijdbaarheid:** Volgens de reader is het onmogelijk om zonder leesbril te lezen; het is daarom vooral belangrijk om de kleur en sterkte van je eigen bril te herkennen en te onderkennen.
                """,
            ])
        ),
        .init(
            id: "concordant",
            termMarkdown: "**Concordant**",
            antwoordMarkdown: BijbelvertalingenOpmaak.antwoordPerRegel([
                "**Concordant vertalen** houdt in dat men een specifiek Grieks of Hebreeuws woord zo vaak mogelijk met hetzelfde Nederlandse woord weergeeft. Dit wordt ook wel een \"woord-voor-woord\" vertaling genoemd. De belangrijkste kenmerken van deze methode zijn:",
                """
                - **Doel:** De lezer krijgt meer inzicht in de onderlinge samenhang van woorden in de brontekst en is minder afhankelijk van de interpretatiekeuzes van de vertaler.
                - **Voordeel:** Het is zeer geschikt voor diepgaande Bijbelstudie en woordstudies.
                - **Nadeel:** Omdat woorden in verschillende contexten andere betekenisaspecten hebben, kan een strikt concordante vertaling leiden tot onnatuurlijk Nederlands dat moeilijk te begrijpen is.
                - **Voorbeelden:** De **Naardense Bijbel** (zeer strikt), de **Statenvertaling** en de **Herziene Statenvertaling (HSV)** zijn voorbeelden van vertalingen met een sterk concordant karakter.
                """,
            ])
        ),
        .init(
            id: "parafraserend",
            termMarkdown: "**Parafraserend**",
            antwoordMarkdown: BijbelvertalingenOpmaak.antwoordPerRegel([
                "**Parafraserend vertalen** (vaak gelijkgesteld aan dynamisch-equivalent vertalen) houdt in dat een tekst **gedachte voor gedachte** wordt vertaald in plaats van woord voor woord. De belangrijkste kenmerken zijn:",
                """
                - **Focus op effect:** Men zoekt naar een vertaling die in het Nederlands dezelfde betekeniswaarde (equivalentie) heeft als de grondtekst.
                - **Natuurlijk taalgebruik:** Er wordt gestreefd naar vlot en begrijpelijk Nederlands, waarbij de vertaler de vrijheid neemt om een woord per context verschillend te vertalen om recht te doen aan de bedoeling.
                - **Verduidelijking:** Metaforen en typische uitdrukkingen worden vaak uitleggend vertaald om de toegankelijkheid te vergroten.
                - **Doelgroep:** Deze methode is zeer geschikt voor kinderen, jongeren of mensen die niet bekend zijn met de Bijbel, maar is minder geschikt voor diepgaande woordstudies.
                """,
                "Voorbeelden zijn de *Groot Nieuws Bijbel* en de *Bijbel in Gewone Taal*. De reader maakt wel een belangrijk onderscheid: werken zoals *Het Boek* worden expliciet getypeerd als een **parafrase** en niet als een echte vertaling, omdat ze niet direct vanuit de brontekst door een team van brontaal- en doeltaalexperts zijn gemaakt.",
            ])
        ),
        .init(
            id: "register",
            termMarkdown: "**Register**",
            antwoordMarkdown: BijbelvertalingenOpmaak.antwoordPerRegel([
                "Het register is de \"toon\" of sociale lading van taalgebruik. De reader onderscheidt vijf niveaus:",
                """
                - **1. Vulgair:** Zeer plat (bijv. *zeiken*).
                - **2. Informeel:** Alledaags/populair (bijv. *pissen*).
                - **3. Ongemarkeerd:** Neutraal/gewoon (bijv. *plassen*).
                - **4. Formeel:** Beleefd/zakelijk (bijv. *urineren*).
                - **5. Archaïsch:** Verouderd/plechtig (bijv. *wateren*).
                """,
                "Bijbelvertalingen zoals de **Statenvertaling** gebruiken een hoog, archaïsch register om eerbied uit te drukken, terwijl de **BGT** juist een ongemarkeerd register hanteert voor maximale toegankelijkheid.",
            ])
        ),
        .init(
            id: "taaleigen",
            termMarkdown: "**Taaleigen (Taalkenmerk)**",
            antwoordMarkdown: BijbelvertalingenOpmaak.antwoordPerRegel([
                "Dit verwijst naar taalkundige constructies uit de brontaal (Grieks of Hebreeuws) die doorschemeren in de vertaling.",
                """
                - **Kenmerk:** Een vertaling die dicht bij het \"taaleigen\" van de brontekst blijft, behoudt bijvoorbeeld Griekse zinsconstructies die in het Nederlands onnatuurlijk klinken.
                - **Voorbeeld:** De **Statenvertaling** laat vaak Griekse taalkenmerken staan (zoals: \"Hij... verhoogd zijnde\"), terwijl moderne vertalingen dit omzetten naar vloeibaar Nederlands.
                """,
            ])
        ),
        .init(
            id: "teksteigen",
            termMarkdown: "**Teksteigen (Tekstkenmerk)**",
            antwoordMarkdown: BijbelvertalingenOpmaak.antwoordPerRegel([
                "Dit gaat over de kenmerken van de tekst zelf, zoals het **genre** en de **toon**.",
                """
                - **Kenmerk:** Een vertaler moet beslissen of hij tekstkenmerken zoals poëzie, een strakke redenering of een luchtige toon in het Nederlands wil laten horen en zien in de lay-out.
                - **Voorbeeld:** De **NBV21** besteedt veel aandacht aan tekstkenmerken door poëzie ook echt als poëzie te vertalen, terwijl een parafrase zoals **Het Boek** deze kenmerken vaak verliest in een gelijkmatige alledaagsheid.
                """,
                "Met deze begrippen kun je typeren of een vertaling de nadruk legt op de **vorm van de brontaal** (taaleigen) of op de **literaire aard van de tekst** (teksteigen).",
            ])
        ),
    ]
}

// MARK: - Bijbelvertalingen duiden (data)

enum BijbelvertalingenDuidenData {
    static let alle: [StudieBegrippenTyperenVraag] = [
        .init(
            id: "statenvertaling",
            termMarkdown: "**Statenvertaling (SV)**",
            antwoordMarkdown: BijbelvertalingenOpmaak.antwoordPerRegel([
                """
                - **Vertaalprincipes:** Sterk **concordant** (woord-voor-woord) en brontekstgetrouw met een hoog, plechtig register.
                - **Waardering:** Geeft goed inzicht in **woordvelden** en de taalkundige **meaning** van de brontekst zonder veel kleuring door de vertaler. Echter, door de verouderde taal verschuift de last van het **interpreteren** volledig naar de lezer.
                - **Interpretive community:** Vooral in gebruik bij behoudende reformatorische kerken.
                """,
            ])
        ),
        .init(
            id: "nbg-1951",
            termMarkdown: "**NBG-vertaling 1951**",
            antwoordMarkdown: BijbelvertalingenOpmaak.antwoordPerRegel([
                """
                - **Vertaalprincipes:** Grote mate van **concordantie**, maar iets minder rigide dan de SV. Het register is archaïsch ten opzichte van modern Nederlands.
                - **Waardering:** Waardevol voor woordstudies, maar minder gericht op natuurlijk Nederlands (doeltaal).
                """,
            ])
        ),
        .init(
            id: "nbv",
            termMarkdown: "**De Nieuwe Bijbelvertaling (NBV / NBV21)**",
            antwoordMarkdown: BijbelvertalingenOpmaak.antwoordPerRegel([
                """
                - **Vertaalprincipes:** Balans tussen brontaalgetrouw en doeltaalgericht; vertaalt vaker de gedachte (**parafraserend** op zinsniveau) om de **significance** voor de moderne lezer te vergroten.
                - **Waardering:** Biedt een natuurlijke leeservaring door gevarieerde registers, maar door de lagere concordantie is de onderlinge samenhang tussen **woordvelden** minder direct zichtbaar.
                """,
            ])
        ),
        .init(
            id: "gnb",
            termMarkdown: "**Groot Nieuws Bijbel (GNB)**",
            antwoordMarkdown: BijbelvertalingenOpmaak.antwoordPerRegel([
                """
                - **Vertaalprincipes:** Uitgesproken **dynamisch-equivalent** (gedachte-voor-gedachte); beelden worden omgezet naar begrijpelijk Nederlands.
                - **Waardering:** Zeer hoge **significance** voor jongeren en buitenkerkelijken, maar ongeschikt voor diepgaande studie omdat de oorspronkelijke taalkundige structuur vaak verloren gaat.
                """,
            ])
        ),
        .init(
            id: "hsv",
            termMarkdown: "**Herziene Statenvertaling (HSV)**",
            antwoordMarkdown: BijbelvertalingenOpmaak.antwoordPerRegel([
                """
                - **Vertaalprincipes:** **Concordant**; een herziening die het 'coloriet' van de SV wil behouden terwijl de taal wordt geactualiseerd.
                - **Waardering:** Herstelt fouten uit de oude SV en is beter leesbaar, maar blijft qua beleving sterk verbonden aan de eigen reformatorische **interpretive community**.
                """,
            ])
        ),
        .init(
            id: "bgt",
            termMarkdown: "**Bijbel in Gewone Taal (BGT)**",
            antwoordMarkdown: BijbelvertalingenOpmaak.antwoordPerRegel([
                """
                - **Vertaalprincipes:** Zeer duidelijke taal (B1-niveau); vertaalt de gedachte om de tekst voor iedereen toegankelijk te maken.
                - **Waardering:** Uitstekend voor de directe verstaanbaarheid, maar de literaire gelaagdheid en technische **meaning** van de brontekst verdwijnen bijna volledig.
                """,
            ])
        ),
        .init(
            id: "naardense-bijbel",
            termMarkdown: "**De Naardense Bijbel**",
            antwoordMarkdown: BijbelvertalingenOpmaak.antwoordPerRegel([
                """
                - **Vertaalprincipes:** Extreem **concordant**; probeert elk brontaalwoord consequent met één Nederlands woord weer te geven.
                - **Waardering:** Zeer waardevol voor woordstudies, maar taalkundig aanvechtbaar omdat het de natuurlijke communicatieve functie van taal (betekenis per context) negeert.
                """,
            ])
        ),
        .init(
            id: "het-boek",
            termMarkdown: "**Het Boek**",
            antwoordMarkdown: BijbelvertalingenOpmaak.antwoordPerRegel([
                """
                - **Vertaalprincipes:** Wordt getypeerd als een **parafrase** en niet als een echte vertaling, omdat het niet direct vanuit de brontekst is gemaakt door experts.
                - **Waardering:** Zeer toegankelijk, maar kan niet dienen als basis voor serieuze exegese of het onderzoeken van **woordvelden**.
                """,
            ])
        ),
        .init(
            id: "willibrord",
            termMarkdown: "**9. Willibrordvertaling**",
            antwoordMarkdown: BijbelvertalingenOpmaak.antwoordPerRegel([
                """
                - **Vertaalprincipes:** Dynamisch-equivalent, gericht op de Room-Katholieke **interpretive community** omdat deze deutrocanonieke boeken bevat.
                - **Waardering:** Goede balans voor de kerkganger, maar minder geschikt voor exegese door de vrije vertaalwijze.
                """,
            ])
        ),
    ]
}

// MARK: - Overzicht

struct BijbelvertalingenOverviewView: View {
    var body: some View {
        List {
            Section {
                NavigationLink {
                    BijbelvertalingenBegrippenTyperenView()
                } label: {
                    Text("Begrippen typeren")
                }

                NavigationLink {
                    BijbelvertalingenDuidenView()
                } label: {
                    Text("Bijbelvertalingen duiden")
                }
            }
        }
        .navigationTitle("Kenmerken bijbelvertalingen")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Begrippen typeren

struct BijbelvertalingenBegrippenTyperenView: View {
    var body: some View {
        StudieInformatiefTyperenOefenView(
            navigatieTitel: "Begrippen typeren",
            voettekstAfsluiting: "Je kunt Begrippen typeren zo vaak opnieuw oefenen als je wilt.",
            vragen: BijbelvertalingenBegrippenTyperenData.alle
        )
    }
}

// MARK: - Bijbelvertalingen duiden

struct BijbelvertalingenDuidenView: View {
    var body: some View {
        StudieInformatiefTyperenOefenView(
            navigatieTitel: "Bijbelvertalingen duiden",
            voettekstAfsluiting: "Je kunt Bijbelvertalingen duiden zo vaak opnieuw oefenen als je wilt.",
            vragen: BijbelvertalingenDuidenData.alle
        )
    }
}

#Preview("Overzicht") {
    NavigationStack {
        BijbelvertalingenOverviewView()
    }
}

#Preview("Begrippen typeren") {
    NavigationStack {
        BijbelvertalingenBegrippenTyperenView()
    }
}

#Preview("Bijbelvertalingen duiden") {
    NavigationStack {
        BijbelvertalingenDuidenView()
    }
}

## Teststrategie und Tokenverbrauch

Ziel ist es, unnötige Testläufe, Builds und damit verbundenen Tokenverbrauch zu vermeiden.

### Änderungsgruppen

Mehrere logisch zusammengehörige Änderungen werden als eine Änderungsgruppe behandelt.

Während einer Änderungsgruppe:

- Nicht nach jeder einzelnen Codeänderung Tests starten.
- Nicht nach jeder bearbeiteten Datei einen Build durchführen.
- Erst alle logisch zusammengehörigen Änderungen fertigstellen.
- Danach genau die kleinste sinnvolle Testmenge ausführen.
- Bevorzuge einen einzelnen betroffenen Unit-Test oder UI-Test.
- Falls notwendig, teste eine Testklasse oder ein betroffenes Test-Target.
- Keine vollständige Testsuite während einer Änderungsgruppe ausführen.

Reihenfolge für die Auswahl des Testumfangs:

`einzelner Test → Testklasse → betroffenes Test-Target → vollständige Testsuite`

Ein Test darf während der Umsetzung früher ausgeführt werden, wenn das Testergebnis zwingend benötigt wird, um einen Fehler zu diagnostizieren oder sinnvoll weiterarbeiten zu können.

### Nach einer Änderungsgruppe

Am Ende einer Änderungsgruppe werden die direkt betroffenen Tests einmal ausgeführt.

Erfolgreiche Tests nicht erneut ausführen, solange danach keine Änderung vorgenommen wurde, die diese Tests betrifft.

Bei einem fehlgeschlagenen Test nur den betroffenen Test nach der Korrektur erneut ausführen.

### Vollständiger Testlauf

Die vollständige Testsuite wird nur einmal am Ende der gesamten Arbeit bzw. Session ausgeführt.

Zwischen einzelnen Änderungsgruppen darf keine vollständige Testsuite gestartet werden.

Wenn keine Codeänderungen vorgenommen wurden, ist kein abschließender Testlauf erforderlich.

### Builds

Keine vollständigen Builds routinemäßig nach einzelnen Änderungen durchführen.

Bei Xcode-Projekten `xcodebuild` nicht nach jedem Edit als Standardvalidierung verwenden.

Builds und Tests so gezielt wie möglich ausführen.

### Tokenverbrauch

Test- und Build-Ausgaben möglichst klein halten.

- Erfolgreiche Build- und Testlogs nicht vollständig analysieren oder wiedergeben.
- Bei Erfolg nur Ergebnis und kurze Zusammenfassung berücksichtigen.
- Detaillierte Logs nur bei Fehlern untersuchen.
- Bei Fehlern nur die für die Diagnose relevanten Logbereiche lesen.
- Große Buildlogs nicht wiederholt einlesen.
- Bereits erfolgreiche Validierungen innerhalb derselben Session wiederverwenden, solange der betreffende Code nicht verändert wurde.

Diese Regeln haben das Ziel, während der Entwicklung möglichst wenig unnötige Builds und Tests auszuführen, ohne die abschließende Qualitätssicherung zu überspringen.

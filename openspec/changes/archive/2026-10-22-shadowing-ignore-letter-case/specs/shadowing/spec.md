## ADDED Requirements

### Requirement: Case-independent spoken word matching
Shadowing scoring SHALL normalize both reference and recognized speech using Unicode case-insensitive folding, including German ß/SS expansions. Case-only differences MUST NOT lower the score or mark words unmatched. Normalization MUST preserve diacritics and MUST NOT modify the raw transcript retained for persistence.

#### Scenario: Uppercase and mixed-case speech
- **WHEN** reference and recognized speech differ only in uppercase, lowercase or mixed-case letters
- **THEN** the score SHALL be 100 percent and all words SHALL match

#### Scenario: German sharp S case expansion
- **WHEN** reference contains heißt or Straße and recognized speech contains HEISST or STRASSE respectively
- **THEN** their normalized tokens SHALL be identical and all reference words SHALL match

#### Scenario: Meaningful differences retained
- **WHEN** normalization processes umlauts and genuinely different words
- **THEN** it SHALL retain umlauts and existing scoring SHALL still mark genuinely different words unmatched

---
name: linguistics
description: "Apply Spanish Mexican linguistic rules to documentation: sentence-case titles, angular quotes, italics for loanwords, no anglicisms. Use this skill when writing or reviewing Spanish documentation."
---

# Spanish Mexican linguistic rules

## When to use

When writing, editing, or reviewing any documentation in Spanish Mexican.

## Instructions

1. **Read the full CoT**: Load and follow `cot/linguistics.md` from line 1 to end
2. **Scan all headings**: Run `grep -n "^#" file.md` and verify each one
3. **Fix titles**: Sentence case only — capitalize first word and proper nouns, nothing else
4. **After colons**: Lowercase after `:` unless it's a proper noun
5. **Loanwords in italics**: *commit*, *pull request*, *pipeline*, *container*, *stack*, *bare-metal*, *sprint*
6. **Angular quotes**: Use «» in Spanish text, "" only inside code blocks
7. **Fix anglicisms**: "realizar" → "hacer/ejecutar", "soportar" → "admitir", "eventualmente" → "finalmente"
8. **Fix peninsularisms**: "ordenador" → "computadora", "fichero" → "archivo"
9. **Verify programmatically**: Run `grep -n "^#" file.md` again and document each correction
10. **Verify no Title Case remains**: Every heading should be sentence case

## Quick reference

- «IA» not «AI», «TI» not «IT», «Biblioteca» not «Librería»
- «Desplegar» not «deployar», «Respaldar» not «backupear»
- Time: 24h format, CST (Ciudad de México), TZ=America/Mexico_City

## References

- Detailed CoT: `cot/linguistics.md`
- Rules: `rulesets/LINGUISTICS.md`

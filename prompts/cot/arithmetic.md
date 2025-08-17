---
domain: aritmetica
task: problema de palabras con sumas y multiplicaciones
dificultad: media
longitud_objetivo: corta
validacion: resultado coincide con cálculo verificado a mano
---

Razonamiento:
- Seguir formato CoT del repo y mantener español mexicano (ver «~/rules/LINGUISTICS.md» ([../../LINGUISTICS.md](../../LINGUISTICS.md)) y «~/rules/PROMPTS.md» ([../../PROMPTS.md](../../PROMPTS.md))).
- Descomponer el problema en pasos simples y verificar unidades.

Pasos:
1) Acción: identificar cantidades base.
   Resultado: Juan tiene 3 cajas con 4 manzanas cada una; María tiene 2 cajas con 5 manzanas cada una.
2) Acción: calcular manzanas de Juan.
   Resultado: 3 × 4 = 12.
3) Acción: calcular manzanas de María.
   Resultado: 2 × 5 = 10.
4) Acción: sumar totales.
   Resultado: 12 + 10 = 22.

Conclusión:
- Respuesta final: 22 manzanas en total.


# Překladač jazyka PJP (flex + bison)

Překladač podmnožiny Pascalu do **tříadresného kódu (TAC)**. Semestrální práce z předmětu **Programovací jazyky a překladače** (VŠPJ, LS 2025/26).

## Co umí

- **lexikální analýza** (`pjp.l`, flex): klíčová slova, identifikátory, čísla, znakové konstanty, oba typy komentářů `{ }` a `(* *)`, hlášení chyb s číslem řádku,
- **syntaktická analýza** (`pjp.y`, bison): `program`, deklarace `var`, složený příkaz `begin … end`, přiřazení, `if … then … else`, `while … do`, aritmetické, relační a logické výrazy (`div`, `mod`, `and`, `or`, `not`),
- **generování mezikódu** – dočasné proměnné `T0, T1 …`, návěští `L0, L1 …` a skoky:

```
program PJP6(IN,OUT);           Prvni = 2
var Prvni, Druhy : integer;     T0 = Druhy >= 1
begin                    →      if not T0 goto L0
  Prvni := 2;                   L1:
  while (Druhy > 0) do ...      T1 = Druhy > 0
                                if not T1 goto L2
```

- **zotavení z chyb** – syntaktické chyby se hlásí s řádkem, překlad pokračuje.

## Technologie

C · flex · bison (yacc) · make

## Jak spustit

Linux / WSL / MSYS2 s nainstalovaným `flex`, `bison` a `gcc`:

```bash
make
./pjp.exe < Priklady/PJP6.pjp
```

## Testovací vstupy

- `Priklady/PJPn.pjp` – správné programy, `Priklady/PJPn.err` – stejné programy s chybou,
- `Testy/RPn_OK.pjp` / `RPn_ERR.pjp` – dvojice pro jednotlivá rozšíření (komentáře, `while`, `if-else`, logické operátory…).

---
*Školní projekt – datum commitu odpovídá odevzdání v Moodlu. Cvičení k předmětu jsou v [pjp-lex-yacc-exercises](../../../pjp-lex-yacc-exercises).*

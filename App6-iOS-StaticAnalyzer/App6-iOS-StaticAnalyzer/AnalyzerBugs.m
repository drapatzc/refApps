#import "AnalyzerBugs.h"
#import <stdlib.h>
#import <string.h>
#import <stdio.h>

// ---------------------------------------------------------------------------
// BUG #1 (C-Level): Memory Leak – unix.Malloc
// Reine C-Funktion, die einen heap-Puffer alloziert und NIE freigibt.
// ---------------------------------------------------------------------------

/// Zählt Stellen einer Zahl – vergisst dabei absichtlich free().
/// Clang Static Analyzer: "Memory allocated on line X is never released"
static NSUInteger digitCount(int n) {
    char *buf = (char *)malloc(32);    // <── LEAK: buf wird nie freed
    snprintf(buf, 32, "%d", n < 0 ? -n : n);
    NSUInteger len = strlen(buf);
    // Hier fehlt absichtlich: free(buf);
    return len;
}

// ---------------------------------------------------------------------------
// Hilfsfunktion für BUG #2 (Null Pointer Dereference)
// ---------------------------------------------------------------------------

/// Gibt einen heap-allozierten Puffer zurück, oder NULL wenn size <= 0.
static int *createShufflePool(int size) {
    if (size <= 0) {
        return NULL;          // explizit NULL-Pfad – Analyzer verfolgt das
    }
    return (int *)malloc((size_t)size * sizeof(int));
}

// ---------------------------------------------------------------------------

@implementation LottoAnalyzerHelper

// ── BUG #1: Memory Leak (via digitCount C-Funktion) ──────────────────────
//
// Der Clang Static Analyzer meldet in digitCount():
//   "Memory allocated on line X is never released (potential memory leak)"
// Checker: unix.Malloc
//
+ (NSArray<NSNumber *> *)generateLottoNumbers {

    // Puffer für Fisher-Yates-Shuffle anlegen
    int *pool = (int *)malloc(49 * sizeof(int));   // wird weiter unten benutzt

    for (int i = 0; i < 49; i++) {
        pool[i] = i + 1;
    }

    // Fisher-Yates-Shuffle
    for (int i = 48; i > 0; i--) {
        int j = (int)(arc4random_uniform((uint32_t)(i + 1)));
        int tmp = pool[i];
        pool[i] = pool[j];
        pool[j] = tmp;
    }

    NSMutableArray<NSNumber *> *result = [NSMutableArray arrayWithCapacity:6];
    for (int k = 0; k < 6; k++) {
        [result addObject:@(pool[k])];
        // Ruft die leakende C-Funktion auf (digitCount alloziert und vergisst free)
        (void)digitCount(pool[k]);
    }

    free(pool);  // pool selbst korrekt freigeben
    return [result sortedArrayUsingSelector:@selector(compare:)];
}


// ── BUG #2: Null Pointer Dereference ──────────────────────────────────────
//
// Der Clang Static Analyzer meldet hier:
//   "Dereference of null pointer (loaded from variable 'pool')"
// Checker: core.NullDereference
//
+ (NSString *)formatNumbers:(NSArray<NSNumber *> *)numbers
              withSeparator:(nullable NSString *)separator {

    NSMutableString *result = [NSMutableString string];

    for (NSUInteger i = 0; i < numbers.count; i++) {
        [result appendFormat:@"%@", numbers[i]];

        if (i < numbers.count - 1) {

            // separator kann NULL sein (nullable-Parameter).
            // Analyzer erkennt, dass nil an non-null erwartendes -appendString: übergeben wird.
            [result appendString:separator];  // <── BUG: nullable ohne NULL-Guard
        }
    }

    // Zusätzlicher C-Level Null-Dereference-Bug:
    // createShufflePool() kann NULL zurückgeben (wenn size <= 0).
    // Wir rufen es mit einer validen Größe auf – Analyzer sieht aber den NULL-Pfad.
    int *tempBuf = createShufflePool((int)numbers.count);
    int firstVal = tempBuf[0];          // <── BUG: potenziell NULL (wenn count == 0)
    (void)firstVal;                     // suppress "unused variable" warning

    return [result copy];
}


// ── BUG #3: Dead Store + Unreachable Code ─────────────────────────────────
//
// Der Clang Static Analyzer meldet hier:
//   "Value stored to 'multiplier' is never read" (Dead Store)
//   "Never executed" für den Code nach dem vollständigen if/else-Return
// Checker: deadcode.DeadStores
//
+ (int)computeMultiplier:(BOOL)useSpecial {

    int multiplier = 1;           // <── BUG: Dead Store – wird sofort überschrieben

    if (useSpecial) {
        multiplier = 7;           // überschreibt den toten Wert 1
        return multiplier;
    } else {
        multiplier = 3;           // überschreibt den toten Wert 1
        return multiplier;
    }

    // ── Unreachable Code ──────────────────────────────────────────────────
    // Alle if/else-Äste haben ein return → dieser Block ist nie erreichbar.
    // Analyzer: "This statement is never executed"
    multiplier = multiplier * 10;  // <── UNREACHABLE
    return multiplier;             // <── UNREACHABLE
}

@end

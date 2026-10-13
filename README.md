# Window Seat

A KBC-style quiz game set on the Mumbai Western Line, Virar to Churchgate.
Twenty stations, twenty levels. Every question is about what you could see
from the window at that stretch of the line.

> **Status:** written without a Flutter SDK available, so it has not been
> compiled or run, and `flutter pub get` has never been executed against it.
> Expect a first pass of small fixes. Start with `flutter pub get`,
> `flutter analyze`, `flutter test`.

## How it plays

- Each station is a level. A round draws 3 questions at random from every
  *approved* question for that station (5 ship with the app per station, and
  the pool grows as contributions are approved).
- 30 seconds a question. A wrong answer or an empty clock ends the round; points
  already banked are kept.
- Three lifelines per round: 50:50, ask the compartment, skip the stop.
- Clearing a station pays `level × 50`, plus a 500 bonus at stations
  5, 10, 15 and 20, and unlocks the next one.

## Three kinds of people

| Role | Can do |
| --- | --- |
| Player | Ride the line, spend points in the marketplace |
| Contributor | Everything a player can, plus write questions for any station |
| Admin | Everything above, plus approve or send back contributed questions |

A contributed question stays `pending` and is invisible to gameplay until an
admin approves it. Approval pays the author 250 points. A rejection carries a
reason the author can read.

## Marketplace

Sellers list a reward with two numbers: its price in points, and the rupee value
the business settles when the code is redeemed (`ProductModel.redeemValueInRupees`).
Buying spends from the balance (never from lifetime points), decrements stock
and issues a six-character redemption code. Eight starter listings ship with the
app. There is no seller sign-in or listing form yet; sellers are seed data.

## Offline first

Everything reads and writes a local Hive store, so the whole game works with no
network. Each write also appends to a queue (`sync_queue`). `SyncService` watches
connectivity and drains the queue oldest-first when a connection appears.

No backend is wired up. `SyncService._push` is the one method to implement, and
`SyncService.remoteConfigured` gates the drain, so until then the queue
accumulates rather than being discarded.

Accounts are local and password-less (identity is just an email on the device).
`AuthController.login` / `register` are the seams for real authentication.

## Layout

```
lib/
  app/        routes, theme
  data/       models, Hive store, sync service, seed questions + products
  modules/    auth, splash, home, quiz, contribute, admin, marketplace, profile
  widgets/    shared widgets
  utils/      stations and game constants
```

State is GetX. One rule worth knowing: an observable read inside a child
widget's `build` is not tracked by an `Obx` further up the tree, so each widget
that watches one owns its own `Obx`.

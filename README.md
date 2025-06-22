# bierwiegen

This is a project digitalizing a party drinking game. 

## Tasks

### Next Steps
- [ ] 2 Game modes (Standard, Points)
- [ ] create optical secondary button - options should be secondary, not primary
- [ ] "Spiel beenden"
  - [x] Create button to end the game
  - [x] Button only available after at least one round is played
  - [ ] Freeze game input and changes when current game is finished
  - [x] Add winning player widget on Bottom
  - [x] Add animation (confetti) when game finishes
  - [x] Below the winner Widget should be a "Neues Spiel starten" button

### Nice to have
- [ ] Join game
- [ ] Rework Bluetooth connection process (scan, then confirm on popup, then connect)
- [ ] Rework bluetooth connection error messages and connection process
- [ ] Update Visuals
  - [ ] Better visual star
- [ ] Save games and see history of game
- [ ] Rearrange players - do i really need this? switching between players is very easy now

### Release for Apple Appstore
- [ ] Create Apple App Store account

## Changelog

### Unreleased

- [x] Screen orientation only portrait
- [x] Limit number input for new round to 5

### Version 0.2.0

- [x] Optical improvements
  - [x] Add header (back button, title, options button)
  - [x] move "Ziel" back to top row
- [x] Splash Screen for Android 12 and higher
- [x] Adapt target weight (if someone misclicks)
- [x] Retain splash screen for 1 sec
- [x] Continue to next field with "next" button
- [x] Multiple winners if they have the same weight
- [x] Rework calculation for winning player (so that multiple can win)
- [x] Options screen should be able to reset game - going back should not start a new game
- [x] Max weight - max value should be 10000 (or 5 digits)

### Version 0.1.0

- [x] App Icon
- [x] Launch Screen
- [x] Fix row height based on players and screen orientation
- [x] Color Scheme
- [x] Last layout rework
  - [x] Area for displaying current points is too big
  - [x] Add padding to bottom of game screen
- [x] Screen always on
- [x] Initial Weight input also with scale
- [x] Game rule description
- [x] Settings button in app bar - remove FAB
- [x] Privacy policy
- [x] Impressum
- [x] Google Play Store test release

## Ideas for project improvement

### Save previous games
I want to show my friends the games of the previous days and flex how close
i got several times to the weight

### Game modes
I want to have 2 game modes:
- Regular Mode: only the one with the closest score gets one point
- Point Mode: first place gets 3 points, second 2 and third 1. If you get the target 
  exactly you get 5 points.

### Short animation after each round
I want to have a short animation after finishing each round before the next round is
started.

### Configure players
I want to configure players to enter the name (and the game should remember previous players)

### Teammode
I want to have a mode where players are in a team and play together against another team - a 
team wins the round if all people have a combined lower offset as the other team.

## Further Ideas
Easy Mode for beginner players - when you start with the game you do not have to be exactly on 
the weight to get better results compared to users that have played the game for some time.

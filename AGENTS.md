# Repository Guidelines

## Project Structure & Module Organization
This repository contains one HarmonyOS NEXT app in `Diary_Notes_V0.1.04/`. App-wide metadata and shared resources live in `AppScope/`. The runnable module is `entry/`, with ArkTS source under `entry/src/main/ets/`.

- `entry/src/main/ets/pages/`: UI pages such as `LoginPage.ets` and `MainPage.ets`
- `entry/src/main/ets/model/`: domain models and helpers such as `TaskModel.ets`
- `entry/src/main/ets/entryability/`: app entry point
- `entry/src/main/resources/`: strings, colors, media, and page profile JSON

## Build, Test, and Development Commands
Use DevEco Studio for the normal workflow. Open `Diary_Notes_V0.1.04/`, sync SDK components, then run the `entry` module on a device or emulator.

- `Build > Build Hap(s)/APP(s) > Build APP(s)`: create a debug or release package
- `Run > Run 'entry'`: install and launch locally
- `hvigor` tasks: use only if your environment already provides HarmonyOS build tooling; this repo does not include a wrapper script

## Coding Style & Naming Conventions
Write ArkTS with 2-space indentation and keep imports grouped at the top. Use `PascalCase` for pages, models, classes, and enums (`MainPage`, `TaskLevel`), `camelCase` for functions and state fields (`dateKey`, `selectedDateKey`), and `UPPER_SNAKE_CASE` for constant arrays (`LEVEL_OPTIONS`). Keep page logic in `pages/`, reusable business rules in `model/`, and prefer small helper functions over duplicating UI logic.

## Testing Guidelines
There is no automated test suite in the current tree. Before opening a PR, run the app in DevEco Studio and manually verify login flow, calendar navigation, task creation, priority ordering, and completion toggles. If you add testable non-UI logic, place future tests next to the feature module and name them after the target unit.

## Commit & Pull Request Guidelines
The existing history uses concise subjects and already includes a Conventional Commit style (`feat: upload Diary Notes v0.1.04 project files`). Follow that pattern when possible: `feat:`, `fix:`, `refactor:`, `docs:`. PRs should include a short summary, affected screens or modules, manual test notes, and screenshots for UI changes.

## Configuration Notes
Build settings are defined in `build-profile.json5`, `hvigorfile.ts`, and `AppScope/app.json5`. Keep SDK and signing changes minimal and explain them in the PR.

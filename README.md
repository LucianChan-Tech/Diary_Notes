# Diary Notes — 日记备忘录

> ArkTS / HarmonyOS NEXT application for work-task management with intelligent priority grading.

---

## Features

| Feature | Detail |
|---------|--------|
| **Huawei Account Login** | Login screen mimicking the Huawei Account OAuth flow; uses mock credentials locally |
| **Monthly Calendar** | Reads the system date, highlights today; navigate months with `<` / `>` |
| **Work Item Import** | Tap the `+` FAB on any date to add a task to that day |
| **Auto Priority Grading** | Tasks are automatically graded based on insertion order (see table below) |
| **Manual Grade Override** | Tap ✎ on any task to change its level at any time |
| **Priority-sorted List** | Tasks are always displayed **S → A → B → C** (highest urgency first) |
| **Task Completion** | Toggle ✓ to mark a task complete/incomplete |
| **Summary Pills** | Pending-task counts per level shown at the top of the main screen |

### Priority Levels

| Level | Deadline | Colour |
|-------|----------|--------|
| **S** | Must finish **today** | Red `#E53935` |
| **A** | Must finish within **2 days** | Orange `#FB8C00` |
| **B** | Must finish within **4 days** | Yellow `#FDD835` |
| **C** | Must finish within **1 week** | Blue `#1E88E5` |

### Auto-grading Logic

Tasks are graded by their **insertion order** within a given day:

```
1st task added → S
2nd task added → A
3rd task added → B
4th+ tasks     → C
```

> The grading function lives in `entry/src/main/ets/model/TaskModel.ets → autoGrade()`.
> Replace the function body to implement your own grading strategy without touching the UI.

---

## Project Structure

```
Diary_Notes/
├── AppScope/                        # App-level resources & config
│   ├── app.json5
│   └── resources/base/element/string.json
├── entry/
│   ├── src/main/
│   │   ├── ets/
│   │   │   ├── entryability/
│   │   │   │   └── EntryAbility.ets   # App entry, loads LoginPage
│   │   │   ├── model/
│   │   │   │   └── TaskModel.ets      # Task class, levels, auto-grade
│   │   │   └── pages/
│   │   │       ├── LoginPage.ets      # Huawei account login UI
│   │   │       └── MainPage.ets       # Calendar + task manager
│   │   ├── module.json5
│   │   └── resources/
│   │       └── base/
│   │           ├── element/
│   │           │   ├── color.json
│   │           │   └── string.json
│   │           └── profile/
│   │               └── main_pages.json
│   ├── build-profile.json5
│   └── oh-package.json5
├── build-profile.json5
├── hvigorfile.ts
└── oh-package.json5
```

---

## How to Run Locally

### Prerequisites

- [DevEco Studio](https://developer.huawei.com/consumer/en/deveco-studio/) 5.0 or later
- HarmonyOS SDK API level 11 (bundled with DevEco Studio)
- A physical device or emulator running HarmonyOS NEXT / API 11+

### Steps

1. **Open the project** in DevEco Studio (`File → Open` → select this folder).
2. DevEco Studio will sync the project and download any missing SDK components automatically.
3. Connect your device / start the emulator.
4. Click **Run ▶** or press `Shift+F10`.

> **Local mock login**: enter any non-empty account and password, or tap **华为账号一键登录** to skip directly to the main screen.

---

## Extending the Auto-grading Logic

Open `entry/src/main/ets/model/TaskModel.ets` and edit `autoGrade()`:

```typescript
export function autoGrade(insertionIndex: number): TaskLevel {
  // TODO: replace with your own grading strategy
  if (insertionIndex === 0) return TaskLevel.S;
  if (insertionIndex === 1) return TaskLevel.A;
  if (insertionIndex === 2) return TaskLevel.B;
  return TaskLevel.C;
}
```

No other files need to change — the UI reads this function every time a task is added.

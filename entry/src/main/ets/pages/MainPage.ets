import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { Task, TaskLevel, getLevelDesc, getLevelColor, autoGrade, levelSortWeight } from '../model/TaskModel';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

/** Format a Date to "YYYY-MM-DD" key. */
function dateKey(d: Date): string {
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${y}-${m}-${day}`;
}

/** Get number of days in a given month (1-based). */
function daysInMonth(year: number, month: number): number {
  return new Date(year, month, 0).getDate();
}

/** Get the weekday index (0=Sun…6=Sat) of the 1st of the month. */
function firstWeekday(year: number, month: number): number {
  return new Date(year, month - 1, 1).getDay();
}

const WEEKDAY_LABELS: string[] = ['日', '一', '二', '三', '四', '五', '六'];
const LEVEL_OPTIONS: TaskLevel[] = [TaskLevel.S, TaskLevel.A, TaskLevel.B, TaskLevel.C];

// ─────────────────────────────────────────────────────────────────────────────
// State stored in AppStorage so it survives page navigation
// ─────────────────────────────────────────────────────────────────────────────
AppStorage.setOrCreate<Task[]>('allTasks', []);

// ─────────────────────────────────────────────────────────────────────────────
// Main page
// ─────────────────────────────────────────────────────────────────────────────
@Entry
@Component
struct MainPage {
  // ── persistent / shared state ──────────────────────────────────────────────
  @StorageLink('allTasks') allTasks: Task[] = [];
  @StorageLink('currentUser') currentUser: string = '用户';

  // ── local UI state ─────────────────────────────────────────────────────────
  private today: Date = new Date();
  /** Monotonic counter to guarantee unique task IDs even during rapid inserts. */
  private taskIdCounter: number = 0;

  @State private viewYear: number = this.today.getFullYear();
  @State private viewMonth: number = this.today.getMonth() + 1;  // 1-based
  @State private selectedDateKey: string = dateKey(this.today);

  // Add-task dialog
  @State private showAddDialog: boolean = false;
  @State private newTaskTitle: string = '';
  @State private pendingLevel: TaskLevel = TaskLevel.S;

  // Edit-level dialog
  @State private showEditDialog: boolean = false;
  @State private editingTask: Task | null = null;
  @State private editLevel: TaskLevel = TaskLevel.S;

  // ── derived getters ────────────────────────────────────────────────────────

  /** All tasks for the currently selected date, sorted S→A→B→C. */
  private tasksForSelected(): Task[] {
    return this.allTasks
      .filter(t => t.date === this.selectedDateKey)
      .sort((a, b) => levelSortWeight(a.level) - levelSortWeight(b.level));
  }

  /** Number of tasks (any date) at the given level. */
  private countByLevel(level: TaskLevel): number {
    return this.allTasks.filter(t => t.level === level && !t.completed).length;
  }

  // ── task CRUD ──────────────────────────────────────────────────────────────

  private addTask() {
    const title = this.newTaskTitle.trim();
    if (title.length === 0) {
      promptAction.showToast({ message: '请输入工作事项内容', duration: 1500 });
      return;
    }
    const dayTasks = this.allTasks.filter(t => t.date === this.selectedDateKey);
    const insertionIndex = dayTasks.length;
    const level = this.pendingLevel;

    const task = new Task(
      `task-${Date.now()}-${++this.taskIdCounter}`,
      title,
      level,
      this.selectedDateKey,
      insertionIndex
    );

    // Mutate a new array so @StorageLink detects the change
    const updated = [...this.allTasks, task];
    this.allTasks = updated;
    AppStorage.set<Task[]>('allTasks', updated);

    this.newTaskTitle = '';
    this.showAddDialog = false;
    promptAction.showToast({ message: `已添加 ${level}级 任务`, duration: 1500 });
  }

  private deleteTask(id: string) {
    const updated = this.allTasks.filter(t => t.id !== id);
    this.allTasks = updated;
    AppStorage.set<Task[]>('allTasks', updated);
  }

  private toggleComplete(id: string) {
    const updated = this.allTasks.map(t => {
      if (t.id === id) {
        const copy = new Task(t.id, t.title, t.level, t.date, t.insertionIndex);
        copy.completed = !t.completed;
        return copy;
      }
      return t;
    });
    this.allTasks = updated;
    AppStorage.set<Task[]>('allTasks', updated);
  }

  private applyEditLevel() {
    if (!this.editingTask) return;
    const updated = this.allTasks.map(t => {
      if (t.id === this.editingTask!.id) {
        const copy = new Task(t.id, t.title, this.editLevel, t.date, t.insertionIndex);
        copy.completed = t.completed;
        return copy;
      }
      return t;
    });
    this.allTasks = updated;
    AppStorage.set<Task[]>('allTasks', updated);
    this.showEditDialog = false;
    this.editingTask = null;
  }

  // ── calendar navigation ────────────────────────────────────────────────────

  private prevMonth() {
    if (this.viewMonth === 1) {
      this.viewMonth = 12;
      this.viewYear -= 1;
    } else {
      this.viewMonth -= 1;
    }
  }

  private nextMonth() {
    if (this.viewMonth === 12) {
      this.viewMonth = 1;
      this.viewYear += 1;
    } else {
      this.viewMonth += 1;
    }
  }

  // ── calendar grid builder ──────────────────────────────────────────────────

  @Builder
  CalendarGrid() {
    Column() {
      // Month / year header
      Row() {
        Button('<')
          .width(36).height(36)
          .fontSize(18)
          .fontColor('#333333')
          .backgroundColor(Color.Transparent)
          .onClick(() => this.prevMonth())

        Text(`${this.viewYear}年 ${this.viewMonth}月`)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button('>')
          .width(36).height(36)
          .fontSize(18)
          .fontColor('#333333')
          .backgroundColor(Color.Transparent)
          .onClick(() => this.nextMonth())
      }
      .width('100%')
      .padding({ left: 8, right: 8 })

      // Weekday labels
      Row() {
        ForEach(WEEKDAY_LABELS, (label: string) => {
          Text(label)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .fontSize(13)
            .fontColor('#757575')
            .padding({ top: 8, bottom: 4 })
        })
      }
      .width('100%')

      // Day cells
      Column() {
        this.DayCells()
      }
      .width('100%')
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(12)
    .padding(12)
    .shadow({ radius: 6, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  /** Renders all day cells in rows of 7. */
  @Builder
  DayCells() {
    const totalDays = daysInMonth(this.viewYear, this.viewMonth);
    const startOffset = firstWeekday(this.viewYear, this.viewMonth);
    const totalCells = startOffset + totalDays;
    const rows = Math.ceil(totalCells / 7);

    // Pre-compute index arrays so ForEach doesn't recreate them on every frame.
    const rowIndices: number[] = Array.from({ length: rows }, (_: unknown, r: number) => r);
    const colIndices: number[] = [0, 1, 2, 3, 4, 5, 6];

    ForEach(rowIndices, (row: number) => {
      Row() {
        ForEach(colIndices, (col: number) => {
          const cellIndex = row * 7 + col;
          const dayNum = cellIndex - startOffset + 1;
          const isValid = dayNum >= 1 && dayNum <= totalDays;

          if (isValid) {
            const cellDateKey = `${this.viewYear}-${String(this.viewMonth).padStart(2, '0')}-${String(dayNum).padStart(2, '0')}`;
            const isToday = cellDateKey === dateKey(this.today);
            const isSelected = cellDateKey === this.selectedDateKey;
            const hasTasks = this.allTasks.some(t => t.date === cellDateKey);

            Column() {
              Text(`${dayNum}`)
                .fontSize(15)
                .fontWeight(isToday ? FontWeight.Bold : FontWeight.Normal)
                .fontColor(
                  isSelected ? Color.White :
                    isToday ? '#CF0A2C' : '#1A1A1A'
                )

              // Dot indicator when tasks exist
              if (hasTasks) {
                Circle()
                  .width(5).height(5)
                  .fill(isSelected ? Color.White : '#CF0A2C')
                  .margin({ top: 2 })
              }
            }
            .layoutWeight(1)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .borderRadius(22)
            .backgroundColor(isSelected ? '#CF0A2C' : Color.Transparent)
            .onClick(() => {
              this.selectedDateKey = cellDateKey;
              // Auto-compute pending level for the next task
              const cnt = this.allTasks.filter(t => t.date === cellDateKey).length;
              this.pendingLevel = autoGrade(cnt);
            })
          } else {
            // Empty cell
            Column()
              .layoutWeight(1)
              .height(44)
          }
        })
      }
      .width('100%')
    })
  }

  // ── task list builder ──────────────────────────────────────────────────────

  @Builder
  TaskItem(task: Task) {
    Row() {
      // Level badge
      Text(task.level)
        .width(32).height(32)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .borderRadius(16)
        .backgroundColor(getLevelColor(task.level))
        .margin({ right: 12 })

      // Title + description
      Column() {
        Text(task.title)
          .fontSize(15)
          .fontColor(task.completed ? '#AAAAAA' : '#1A1A1A')
          .decoration(task.completed
            ? { type: TextDecorationType.LineThrough, color: '#AAAAAA' }
            : { type: TextDecorationType.None })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(getLevelDesc(task.level))
          .fontSize(12)
          .fontColor(getLevelColor(task.level))
          .margin({ top: 2 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // Action buttons
      Row({ space: 8 }) {
        // Complete toggle
        Text(task.completed ? '↩' : '✓')
          .fontSize(18)
          .fontColor(task.completed ? '#9E9E9E' : '#4CAF50')
          .onClick(() => this.toggleComplete(task.id))

        // Edit level
        Text('✎')
          .fontSize(18)
          .fontColor('#1565C0')
          .onClick(() => {
            this.editingTask = task;
            this.editLevel = task.level;
            this.showEditDialog = true;
          })

        // Delete
        Text('✕')
          .fontSize(18)
          .fontColor('#E53935')
          .onClick(() => this.deleteTask(task.id))
      }
      .margin({ left: 8 })
    }
    .width('100%')
    .padding(14)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .shadow({ radius: 4, color: '#0D000000', offsetX: 0, offsetY: 1 })
    .margin({ bottom: 10 })
  }

  // ── add-task dialog ────────────────────────────────────────────────────────

  @Builder
  AddTaskDialog() {
    Column() {
      Text('添加工作事项')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })

      TextInput({
        placeholder: '请输入工作事项内容',
        text: this.newTaskTitle
      })
        .width('100%')
        .fontSize(15)
        .onChange((v) => {
          this.newTaskTitle = v;
        })
        .margin({ bottom: 16 })

      // Priority selector
      Text('优先级（可手动调整，留空时自动分级）')
        .fontSize(13)
        .fontColor('#757575')
        .width('100%')
        .margin({ bottom: 8 })

      Row({ space: 10 }) {
        ForEach(LEVEL_OPTIONS, (lv: TaskLevel) => {
          Text(lv)
            .width(48).height(36)
            .textAlign(TextAlign.Center)
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.pendingLevel === lv ? Color.White : getLevelColor(lv))
            .backgroundColor(this.pendingLevel === lv ? getLevelColor(lv) : '#F5F5F5')
            .borderRadius(18)
            .border({
              width: 1.5,
              color: getLevelColor(lv)
            })
            .onClick(() => {
              this.pendingLevel = lv;
            })
        })
      }
      .margin({ bottom: 8 })

      Text(getLevelDesc(this.pendingLevel))
        .fontSize(12)
        .fontColor(getLevelColor(this.pendingLevel))
        .margin({ bottom: 20 })

      Row({ space: 12 }) {
        Button('取消')
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#F5F5F5')
          .fontColor('#555555')
          .onClick(() => {
            this.showAddDialog = false;
            this.newTaskTitle = '';
          })

        Button('确认添加')
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#CF0A2C')
          .fontColor(Color.White)
          .onClick(() => this.addTask())
      }
    }
    .width('100%')
    .padding(24)
    .backgroundColor(Color.White)
    .borderRadius(16)
  }

  // ── edit-level dialog ──────────────────────────────────────────────────────

  @Builder
  EditLevelDialog() {
    Column() {
      Text('修改优先级')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })

      if (this.editingTask !== null) {
        Text(`「${this.editingTask!.title}」`)
          .fontSize(14)
          .fontColor('#555555')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: 16 })
      }

      Row({ space: 10 }) {
        ForEach(LEVEL_OPTIONS, (lv: TaskLevel) => {
          Column() {
            Text(lv)
              .width(52).height(40)
              .textAlign(TextAlign.Center)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.editLevel === lv ? Color.White : getLevelColor(lv))
              .backgroundColor(this.editLevel === lv ? getLevelColor(lv) : '#F5F5F5')
              .borderRadius(20)
              .border({ width: 1.5, color: getLevelColor(lv) })

            Text(lv === TaskLevel.S ? '今天' :
              lv === TaskLevel.A ? '2天' :
                lv === TaskLevel.B ? '4天' : '1周')
              .fontSize(11)
              .fontColor('#9E9E9E')
              .margin({ top: 4 })
          }
          .onClick(() => {
            this.editLevel = lv;
          })
        })
      }
      .margin({ bottom: 24 })

      Row({ space: 12 }) {
        Button('取消')
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#F5F5F5')
          .fontColor('#555555')
          .onClick(() => {
            this.showEditDialog = false;
            this.editingTask = null;
          })

        Button('保存')
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#1E88E5')
          .fontColor(Color.White)
          .onClick(() => this.applyEditLevel())
      }
    }
    .width('100%')
    .padding(24)
    .backgroundColor(Color.White)
    .borderRadius(16)
  }

  // ── build ──────────────────────────────────────────────────────────────────

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      // ── Main scrollable content ────────────────────────────────────────────
      Scroll() {
        Column() {
          // Top bar
          Row() {
            Column() {
              Text('日记备忘录')
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1A1A1A')

              Text(`你好，${this.currentUser}`)
                .fontSize(13)
                .fontColor('#757575')
                .margin({ top: 2 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            // Logout
            Text('退出')
              .fontSize(14)
              .fontColor('#CF0A2C')
              .padding({ left: 12, right: 4, top: 8, bottom: 8 })
              .onClick(() => {
                AppStorage.set<string>('currentUser', '');
                AppStorage.set<Task[]>('allTasks', []);
                router.replaceUrl({ url: 'pages/LoginPage' });
              })
          }
          .width('100%')
          .padding({ left: 20, right: 16, top: 16, bottom: 8 })

          // Summary pills
          Row({ space: 8 }) {
            ForEach(LEVEL_OPTIONS, (lv: TaskLevel) => {
              Column() {
                Text(`${this.countByLevel(lv)}`)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(getLevelColor(lv))

                Text(`${lv}级`)
                  .fontSize(12)
                  .fontColor('#9E9E9E')
              }
              .layoutWeight(1)
              .height(60)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(Color.White)
              .borderRadius(10)
              .shadow({ radius: 4, color: '#0D000000', offsetX: 0, offsetY: 1 })
            })
          }
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 14 })

          // Calendar
          Column() {
            this.CalendarGrid()
          }
          .padding({ left: 16, right: 16, bottom: 16 })

          // Selected date label + task count
          Row() {
            Text(this.selectedDateKey === dateKey(this.today)
              ? `今天  ${this.selectedDateKey}`
              : this.selectedDateKey)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1A1A1A')
              .layoutWeight(1)

            Text(`${this.tasksForSelected().length} 项`)
              .fontSize(13)
              .fontColor('#757575')
          }
          .width('100%')
          .padding({ left: 20, right: 20, bottom: 10 })

          // Task list
          Column() {
            if (this.tasksForSelected().length === 0) {
              Column() {
                Text('📋')
                  .fontSize(40)
                  .margin({ bottom: 8 })
                Text('暂无工作事项')
                  .fontSize(15)
                  .fontColor('#9E9E9E')
                Text('点击右下角按钮添加')
                  .fontSize(13)
                  .fontColor('#BDBDBD')
                  .margin({ top: 4 })
              }
              .width('100%')
              .height(160)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
            } else {
              ForEach(this.tasksForSelected(), (task: Task) => {
                this.TaskItem(task)
              }, (task: Task) => task.id)
            }
          }
          .padding({ left: 16, right: 16, bottom: 80 })

        }
        .width('100%')
      }
      .scrollBar(BarState.Off)
      .width('100%')
      .height('100%')

      // ── Floating Add Button ────────────────────────────────────────────────
      Button('+')
        .width(56).height(56)
        .fontSize(30)
        .fontColor(Color.White)
        .backgroundColor('#CF0A2C')
        .borderRadius(28)
        .shadow({ radius: 8, color: '#40000000', offsetX: 0, offsetY: 4 })
        .margin({ bottom: 28, right: 24 })
        .onClick(() => {
          const cnt = this.allTasks.filter(t => t.date === this.selectedDateKey).length;
          this.pendingLevel = autoGrade(cnt);
          this.newTaskTitle = '';
          this.showAddDialog = true;
        })

      // ── Add-task dialog overlay ────────────────────────────────────────────
      if (this.showAddDialog) {
        Column() {
          // Backdrop
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('#66000000')
            .onClick(() => {
              this.showAddDialog = false;
              this.newTaskTitle = '';
            })
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })

        Column() {
          this.AddTaskDialog()
        }
        .width('92%')
        .position({ x: '4%', y: '20%' })
        .shadow({ radius: 24, color: '#40000000', offsetX: 0, offsetY: 8 })
      }

      // ── Edit-level dialog overlay ──────────────────────────────────────────
      if (this.showEditDialog) {
        Column() {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('#66000000')
            .onClick(() => {
              this.showEditDialog = false;
              this.editingTask = null;
            })
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })

        Column() {
          this.EditLevelDialog()
        }
        .width('92%')
        .position({ x: '4%', y: '30%' })
        .shadow({ radius: 24, color: '#40000000', offsetX: 0, offsetY: 8 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}

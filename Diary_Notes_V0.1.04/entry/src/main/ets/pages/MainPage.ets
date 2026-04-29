import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { Task, TaskLevel, getLevelDesc, getLevelColor, autoGrade, levelSortWeight } from '../model/TaskModel';

function dateKey(d: Date): string {
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${y}-${m}-${day}`;
}

function daysInMonth(year: number, month: number): number {
  return new Date(year, month, 0).getDate();
}

function firstWeekday(year: number, month: number): number {
  return new Date(year, month - 1, 1).getDay();
}

const WEEKDAY_LABELS: string[] = ['日', '一', '二', '三', '四', '五', '六'];
const LEVEL_OPTIONS: TaskLevel[] = [TaskLevel.S, TaskLevel.A, TaskLevel.B, TaskLevel.C];
const CALENDAR_COLS: number[] = [0, 1, 2, 3, 4, 5, 6];

AppStorage.setOrCreate<Task[]>('allTasks', []);
AppStorage.setOrCreate<string>('currentUser', '游客');

@Entry
@Component
struct MainPage {
  @StorageLink('allTasks') allTasks: Task[] = [];
  @StorageLink('currentUser') currentUser: string = '游客';

  private today: Date = new Date();
  private taskIdCounter: number = 0;

  @State private viewYear: number = this.today.getFullYear();
  @State private viewMonth: number = this.today.getMonth() + 1;
  @State private selectedDateKey: string = dateKey(this.today);
  @State private showAddDialog: boolean = false;
  @State private newTaskTitle: string = '';
  @State private pendingLevel: TaskLevel = TaskLevel.S;
  @State private showEditDialog: boolean = false;
  @State private editingTask: Task | null = null;
  @State private editLevel: TaskLevel = TaskLevel.S;

  private tasksForSelected(): Task[] {
    return this.allTasks
      .filter((task) => task.date === this.selectedDateKey)
      .sort((a, b) => levelSortWeight(a.level) - levelSortWeight(b.level));
  }

  private countByLevel(level: TaskLevel): number {
    return this.allTasks.filter((task) => task.level === level && !task.completed).length;
  }

  private addTask() {
    const title = this.newTaskTitle.trim();
    if (title.length === 0) {
      promptAction.showToast({ message: '请输入任务内容。', duration: 1500 });
      return;
    }

    const dayTasks = this.allTasks.filter((task) => task.date === this.selectedDateKey);
    const insertionIndex = dayTasks.length;
    const level = this.pendingLevel;
    const task = new Task(
      `task-${Date.now()}-${++this.taskIdCounter}`,
      title,
      level,
      this.selectedDateKey,
      insertionIndex
    );

    const updated = [...this.allTasks, task];
    this.allTasks = updated;
    AppStorage.set<Task[]>('allTasks', updated);

    this.newTaskTitle = '';
    this.showAddDialog = false;
    promptAction.showToast({ message: `已添加${level}级任务。`, duration: 1500 });
  }

  private deleteTask(id: string) {
    const updated = this.allTasks.filter((task) => task.id !== id);
    this.allTasks = updated;
    AppStorage.set<Task[]>('allTasks', updated);
  }

  private toggleComplete(id: string) {
    const updated = this.allTasks.map((task) => {
      if (task.id === id) {
        const copy = new Task(task.id, task.title, task.level, task.date, task.insertionIndex);
        copy.completed = !task.completed;
        return copy;
      }
      return task;
    });
    this.allTasks = updated;
    AppStorage.set<Task[]>('allTasks', updated);
  }

  private applyEditLevel() {
    if (!this.editingTask) {
      return;
    }

    const updated = this.allTasks.map((task) => {
      if (task.id === this.editingTask!.id) {
        const copy = new Task(task.id, task.title, this.editLevel, task.date, task.insertionIndex);
        copy.completed = task.completed;
        return copy;
      }
      return task;
    });

    this.allTasks = updated;
    AppStorage.set<Task[]>('allTasks', updated);
    this.showEditDialog = false;
    this.editingTask = null;
  }

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

  private currentMonthTotalDays(): number {
    return daysInMonth(this.viewYear, this.viewMonth);
  }

  private currentMonthStartOffset(): number {
    return firstWeekday(this.viewYear, this.viewMonth);
  }

  private calendarRows(): number[] {
    const totalCells = this.currentMonthStartOffset() + this.currentMonthTotalDays();
    const rows = Math.ceil(totalCells / 7);
    const rowIndices: number[] = [];
    for (let index = 0; index < rows; index++) {
      rowIndices.push(index);
    }
    return rowIndices;
  }

  private dayNumber(row: number, col: number): number {
    return row * 7 + col - this.currentMonthStartOffset() + 1;
  }

  private isValidDay(dayNum: number): boolean {
    return dayNum >= 1 && dayNum <= this.currentMonthTotalDays();
  }

  private dayDateKey(dayNum: number): string {
    return `${this.viewYear}-${String(this.viewMonth).padStart(2, '0')}-${String(dayNum).padStart(2, '0')}`;
  }

  private hasTasksOn(date: string): boolean {
    return this.allTasks.some((task) => task.date === date);
  }

  @Builder
  DayCell(row: number, col: number) {
    Column() {
      Text(`${this.dayNumber(row, col)}`)
        .fontSize(15)
        .fontWeight(this.dayDateKey(this.dayNumber(row, col)) === dateKey(this.today)
          ? FontWeight.Bold
          : FontWeight.Normal)
        .fontColor(
          this.dayDateKey(this.dayNumber(row, col)) === this.selectedDateKey
            ? Color.White
            : this.dayDateKey(this.dayNumber(row, col)) === dateKey(this.today)
              ? '#CF0A2C'
              : '#1A1A1A'
        )

      if (this.hasTasksOn(this.dayDateKey(this.dayNumber(row, col)))) {
        Circle()
          .width(5)
          .height(5)
          .fill(this.dayDateKey(this.dayNumber(row, col)) === this.selectedDateKey ? Color.White : '#CF0A2C')
          .margin({ top: 2 })
      }
    }
    .layoutWeight(1)
    .height(44)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .borderRadius(22)
    .backgroundColor(this.dayDateKey(this.dayNumber(row, col)) === this.selectedDateKey ? '#CF0A2C' : Color.Transparent)
    .onClick(() => {
      const cellDateKey = this.dayDateKey(this.dayNumber(row, col));
      this.selectedDateKey = cellDateKey;
      const count = this.allTasks.filter((task) => task.date === cellDateKey).length;
      this.pendingLevel = autoGrade(count);
    })
  }

  @Builder
  CalendarGrid() {
    Column() {
      Row() {
        Button('\u003C')
          .width(46)
          .height(46)
          .fontSize(18)
          .fontColor('#333333')
          .backgroundColor(Color.Transparent)
          .onClick(() => this.prevMonth())

        Text(`${this.viewYear}年${this.viewMonth}月`)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button('\u003E')
          .width(46)
          .height(46)
          .fontSize(18)
          .fontColor('#333333')
          .backgroundColor(Color.Transparent)
          .onClick(() => this.nextMonth())
      }
      .width('100%')
      .padding({ left: 8, right: 8 })

      Row() {
        ForEach(WEEKDAY_LABELS, (label: string) => {
          Text(label)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .fontSize(13)
            .fontColor('#757575')
            .padding({ top: 8, bottom: 4 });
        });
      }
      .width('100%')

      Column() {
        this.DayCells();
      }
      .width('100%')
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(12)
    .padding(12)
    .shadow({ radius: 6, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  @Builder
  DayCells() {
    ForEach(this.calendarRows(), (row: number) => {
      Row() {
        ForEach(CALENDAR_COLS, (col: number) => {
          if (this.isValidDay(this.dayNumber(row, col))) {
            this.DayCell(row, col);
          } else {
            Column()
              .layoutWeight(1)
              .height(44)
          }
        })
      }
      .width('100%')
    })
  }

  @Builder
  TaskItem(task: Task) {
    Row() {
      Text(task.level)
        .width(32)
        .height(32)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .borderRadius(16)
        .backgroundColor(getLevelColor(task.level))
        .margin({ right: 12 })

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

      Row({ space: 8 }) {
        Text(task.completed ? '撤销' : '完成')
          .fontSize(14)
          .fontColor(task.completed ? '#9E9E9E' : '#4CAF50')
          .onClick(() => this.toggleComplete(task.id))

        Text('编辑')
          .fontSize(14)
          .fontColor('#1565C0')
          .onClick(() => {
            this.editingTask = task;
            this.editLevel = task.level;
            this.showEditDialog = true;
          })

        Text('删除')
          .fontSize(14)
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

  @Builder
  AddTaskDialog() {
    Column() {
      Text('添加任务')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })

      TextInput({
        placeholder: '请输入任务内容',
        text: this.newTaskTitle
      })
        .width('100%')
        .fontSize(15)
        .onChange((value) => {
          this.newTaskTitle = value;
        })
        .margin({ bottom: 16 })

      Text('优先级（可手动调整）')
        .fontSize(13)
        .fontColor('#757575')
        .width('100%')
        .margin({ bottom: 8 })

      Row({ space: 10 }) {
        ForEach(LEVEL_OPTIONS, (level: TaskLevel) => {
          Text(level)
            .width(48)
            .height(36)
            .textAlign(TextAlign.Center)
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.pendingLevel === level ? Color.White : getLevelColor(level))
            .backgroundColor(this.pendingLevel === level ? getLevelColor(level) : '#F5F5F5')
            .borderRadius(18)
            .border({ width: 1.5, color: getLevelColor(level) })
            .onClick(() => {
              this.pendingLevel = level;
            });
        });
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

        Button('添加')
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

  @Builder
  EditLevelDialog() {
    Column() {
      Text('修改优先级')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })

      if (this.editingTask !== null) {
        Text(`"${this.editingTask!.title}"`)
          .fontSize(14)
          .fontColor('#555555')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: 16 })
      }

      Row({ space: 10 }) {
        ForEach(LEVEL_OPTIONS, (level: TaskLevel) => {
          Column() {
            Text(level)
              .width(52)
              .height(40)
              .textAlign(TextAlign.Center)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.editLevel === level ? Color.White : getLevelColor(level))
              .backgroundColor(this.editLevel === level ? getLevelColor(level) : '#F5F5F5')
              .borderRadius(20)
              .border({ width: 1.5, color: getLevelColor(level) })

            Text(level === TaskLevel.S ? '优先完成' :
              level === TaskLevel.A ? '稍后完成' :
                level === TaskLevel.B ? '尽快安排完成' : '非紧急任务')
              .fontSize(11)
              .fontColor('#9E9E9E')
              .margin({ top: 4 })
          }
          .onClick(() => {
            this.editLevel = level;
          })
        });
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

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Scroll() {
        Column() {
          Row() {
            Column() {
              Text('这里是日记备忘录')
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

          Row({ space: 8 }) {
            ForEach(LEVEL_OPTIONS, (level: TaskLevel) => {
              Column() {
                Text(`${this.countByLevel(level)}`)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(getLevelColor(level))

                Text(`${level}级任务`)
                  .fontSize(12)
                  .fontColor('#9E9E9E')
              }
              .layoutWeight(1)
              .height(60)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(Color.White)
              .borderRadius(10)
              .shadow({ radius: 4, color: '#0D000000', offsetX: 0, offsetY: 1 })
            });
          }
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 14 })

          Column() {
            this.CalendarGrid();
          }
          .padding({ left: 16, right: 16, bottom: 16 })

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

          Column() {
            if (this.tasksForSelected().length === 0) {
              Column() {
                Text('暂无任务')
                  .fontSize(15)
                  .fontColor('#9E9E9E')
                Text('点击右下角按钮添加任务')
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
                this.TaskItem(task);
              }, (task: Task) => task.id);
            }
          }
          .padding({ left: 16, right: 16, bottom: 80 })
        }
        .width('100%')
      }
      .scrollBar(BarState.Off)
      .width('100%')
      .height('100%')

      Button('+')
        .width(56)
        .height(56)
        .fontSize(30)
        .fontColor(Color.White)
        .backgroundColor('#CF0A2C')
        .borderRadius(28)
        .shadow({ radius: 8, color: '#40000000', offsetX: 0, offsetY: 4 })
        .margin({ bottom: 28, right: 24 })
        .onClick(() => {
          const count = this.allTasks.filter((task) => task.date === this.selectedDateKey).length;
          this.pendingLevel = autoGrade(count);
          this.newTaskTitle = '';
          this.showAddDialog = true;
        })

      if (this.showAddDialog) {
        Column() {
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
          this.AddTaskDialog();
        }
        .width('92%')
        .position({ x: '4%', y: '20%' })
        .shadow({ radius: 24, color: '#40000000', offsetX: 0, offsetY: 8 })
      }

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
          this.EditLevelDialog();
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

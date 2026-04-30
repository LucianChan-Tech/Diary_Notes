import { AccountRepository, TaskRepository, UserSessionRepository } from '../model/AppRepository';
import {
  Task,
  TaskLevel,
  autoGrade,
  countPendingTasksByLevel,
  countTasksForDate,
  getLevelColor,
  getTasksForDate,
  hasTasksOnDate
} from '../model/TaskModel';
import {
  PopupType,
  TaskPopupConfig,
  createAddTaskPopup,
  createDeleteTaskPopup,
  createEditTaskLevelPopup,
  createWelcomePopup
} from '../model/PopupTypes';
import { TaskPopupHost } from './PopupPage';
import { TaskItemView } from './TaskItemView';

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
const CALENDAR_COLS: number[] = [0, 1, 2, 3, 4, 5, 6];

@Entry
@Component
struct MainPage {
  @State private allTasks: Task[] = [];
  @State private currentUser: string = '';
  @State private currentDisplayName: string = '';
  @State private viewYear: number = new Date().getFullYear();
  @State private viewMonth: number = new Date().getMonth() + 1;
  @State private selectedDateKey: string = dateKey(new Date());
  @State private currentPopup: TaskPopupConfig = null;
  @State private popupTaskTitle: string = '';
  @State private popupLevel: TaskLevel = TaskLevel.S;
  @State private viewRevision: number = 0;

  private today: Date = new Date();
  private taskIdCounter: number = 0;

  aboutToAppear(): void {
    const hostContext = this.getUIContext().getHostContext();
    if (hostContext !== undefined) {
      TaskRepository.initialize(hostContext);
      UserSessionRepository.initialize(hostContext);
      this.refreshState();
      this.openWelcomePopup();
    }
  }

  private refreshState(): void {
    this.currentUser = UserSessionRepository.getCurrentUser();
    this.currentDisplayName = AccountRepository.getDisplayName(this.currentUser);
    this.allTasks = TaskRepository.getTasksForUser(this.currentUser);
    this.viewRevision += 1;
  }

  private tasksForSelected(): Task[] {
    return getTasksForDate(this.allTasks, this.selectedDateKey);
  }

  private countByLevel(level: TaskLevel): number {
    return countPendingTasksByLevel(this.allTasks, level);
  }

  private refreshTasks(): void {
    this.allTasks = TaskRepository.getTasksForUser(this.currentUser);
    this.viewRevision += 1;
  }

  private navigateReplace(url: string): void {
    void this.getUIContext().getRouter().replaceUrl({ url }).catch((): void => {});
  }

  private showToast(message: string, duration: number = 1500): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message, duration });
    } catch (error) {
    }
  }

  private closePopup(): void {
    this.currentPopup = null;
    this.popupTaskTitle = '';
  }

  private openWelcomePopup(): void {
    if (this.currentDisplayName.length === 0) {
      return;
    }

    this.currentPopup = createWelcomePopup(this.currentDisplayName);
  }

  private openAddTaskPopup(): void {
    const popup = createAddTaskPopup(this.selectedDateKey, this.allTasks);
    this.currentPopup = popup;
    this.popupTaskTitle = '';
    this.popupLevel = popup.initialLevel;
  }

  private openEditTaskPopup(task: Task): void {
    const popup = createEditTaskLevelPopup(task);
    this.currentPopup = popup;
    this.popupTaskTitle = task.title;
    this.popupLevel = popup.initialLevel;
  }

  private openDeleteTaskPopup(task: Task): void {
    this.currentPopup = createDeleteTaskPopup(task);
  }

  private confirmPopup(): void {
    if (this.currentPopup === null) {
      return;
    }

    if (this.currentPopup.type === PopupType.Welcome) {
      this.closePopup();
      return;
    }

    if (this.currentPopup.type === PopupType.AddTask) {
      try {
        TaskRepository.addTaskForUser(this.currentUser, {
          title: this.popupTaskTitle,
          date: this.currentPopup.date,
          level: this.popupLevel,
          idSeed: `${++this.taskIdCounter}`
        });
        this.refreshTasks();
        this.showToast(`已添加 ${this.popupLevel} 级任务`);
        this.closePopup();
      } catch (error) {
        this.showToast('请输入任务内容');
      }
      return;
    }

    if (this.currentPopup.type === PopupType.EditTaskLevel) {
      TaskRepository.updateTaskLevelForUser(this.currentUser, this.currentPopup.taskId, this.popupLevel);
      this.refreshTasks();
      this.showToast(`已更新为 ${this.popupLevel} 级任务`);
      this.closePopup();
      return;
    }

    if (this.currentPopup.type === PopupType.DeleteTask) {
      TaskRepository.deleteTaskForUser(this.currentUser, this.currentPopup.taskId);
      this.refreshTasks();
      this.showToast('任务已删除');
      this.closePopup();
    }
  }

  private toggleComplete(taskId: string): void {
    TaskRepository.toggleTaskCompleteForUser(this.currentUser, taskId);
    this.refreshTasks();
  }

  private prevMonth(): void {
    if (this.viewMonth === 1) {
      this.viewMonth = 12;
      this.viewYear -= 1;
    } else {
      this.viewMonth -= 1;
    }
  }

  private nextMonth(): void {
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
    return hasTasksOnDate(this.allTasks, date);
  }

  private cellDateKey(row: number, col: number): string {
    return this.dayDateKey(this.dayNumber(row, col));
  }

  private isTodayCell(row: number, col: number): boolean {
    return this.cellDateKey(row, col) === dateKey(this.today);
  }

  private isSelectedCell(row: number, col: number): boolean {
    return this.cellDateKey(row, col) === this.selectedDateKey;
  }

  @Builder
  DayCell(row: number, col: number) {
    Column() {
      Text(`${this.dayNumber(row, col)}`)
        .fontSize(15)
        .fontWeight(this.isTodayCell(row, col) ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(
          this.isSelectedCell(row, col)
            ? Color.White
            : this.isTodayCell(row, col)
              ? '#CF0A2C'
              : '#1A1A1A'
        )

      if (this.hasTasksOn(this.cellDateKey(row, col))) {
        Circle()
          .width(5)
          .height(5)
          .fill(this.isSelectedCell(row, col) ? Color.White : '#CF0A2C')
          .margin({ top: 2 })
      }
    }
    .layoutWeight(1)
    .height(44)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .borderRadius(22)
    .backgroundColor(this.isSelectedCell(row, col) ? '#CF0A2C' : Color.Transparent)
    .onClick(() => {
      this.selectedDateKey = this.cellDateKey(row, col);
      this.popupLevel = autoGrade(countTasksForDate(this.allTasks, this.cellDateKey(row, col)));
    })
  }

  @Builder
  CalendarGrid() {
    Column() {
      Row() {
        Button('<')
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

        Button('>')
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
            Column() {}
              .layoutWeight(1)
              .height(44)
          }
        });
      }
      .width('100%')
    });
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Scroll() {
        Column() {
          Row() {
            Column() {
              Text('聚焦事项备忘录')
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1A1A1A')

              Text(this.currentDisplayName.length > 0
                ? `当前用户:${this.currentDisplayName},所剩任务如下`
                : '当前用户未登录')
                .fontSize(13)
                .fontColor('#757575')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Text('退出')
              .fontSize(14)
              .fontColor('#CF0A2C')
              .padding({ left: 12, right: 4, top: 8, bottom: 8 })
              .onClick(() => {
                UserSessionRepository.clear();
                this.currentUser = '';
                this.currentDisplayName = '';
                this.allTasks = [];
                this.currentPopup = null;
                this.navigateReplace('pages/LoginPage');
              })
          }
          .width('100%')
          .padding({ left: 20, right: 16, top: 16, bottom: 8 })

          Row({ space: 8 }) {
            ForEach([TaskLevel.S, TaskLevel.A, TaskLevel.B, TaskLevel.C], (level: TaskLevel) => {
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
                TaskItemView({
                  task,
                  onToggleComplete: (taskId: string) => { this.toggleComplete(taskId); },
                  onEdit: (targetTask: Task) => { this.openEditTaskPopup(targetTask); },
                  onDelete: (targetTask: Task) => { this.openDeleteTaskPopup(targetTask); }
                });
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
        .onClick(() => this.openAddTaskPopup())

      if (this.currentPopup !== null) {
        TaskPopupHost({
          popupConfig: this.currentPopup,
          taskTitle: $popupTaskTitle,
          selectedLevel: $popupLevel,
          onClose: () => { this.closePopup(); },
          onConfirm: () => { this.confirmPopup(); }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}

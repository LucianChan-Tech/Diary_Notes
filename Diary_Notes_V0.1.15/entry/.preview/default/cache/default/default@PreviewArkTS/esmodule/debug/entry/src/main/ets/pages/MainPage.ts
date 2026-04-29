if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface MainPage_Params {
    allTasks?: Task[];
    currentUser?: string;
    viewYear?: number;
    viewMonth?: number;
    selectedDateKey?: string;
    currentPopup?: TaskPopupConfig;
    popupTaskTitle?: string;
    popupLevel?: TaskLevel;
    today?: Date;
    taskIdCounter?: number;
}
import { TaskRepository, UserSessionRepository } from "@normalized:N&&&entry/src/main/ets/model/AppRepository&";
import { TaskLevel, autoGrade, countPendingTasksByLevel, countTasksForDate, getLevelColor, getTasksForDate, hasTasksOnDate } from "@normalized:N&&&entry/src/main/ets/model/TaskModel&";
import type { Task } from "@normalized:N&&&entry/src/main/ets/model/TaskModel&";
import { PopupType, createAddTaskPopup, createDeleteTaskPopup, createEditTaskLevelPopup } from "@normalized:N&&&entry/src/main/ets/model/PopupTypes&";
import type { TaskPopupConfig } from "@normalized:N&&&entry/src/main/ets/model/PopupTypes&";
import { TaskPopupHost } from "@normalized:N&&&entry/src/main/ets/pages/PopupPage&";
import { TaskItemView } from "@normalized:N&&&entry/src/main/ets/pages/TaskItemView&";
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
class MainPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__allTasks = new ObservedPropertyObjectPU([], this, "allTasks");
        this.__currentUser = new ObservedPropertySimplePU('游客', this, "currentUser");
        this.__viewYear = new ObservedPropertySimplePU(new Date().getFullYear(), this, "viewYear");
        this.__viewMonth = new ObservedPropertySimplePU(new Date().getMonth() + 1, this, "viewMonth");
        this.__selectedDateKey = new ObservedPropertySimplePU(dateKey(new Date()), this, "selectedDateKey");
        this.__currentPopup = new ObservedPropertyObjectPU(null, this, "currentPopup");
        this.__popupTaskTitle = new ObservedPropertySimplePU('', this, "popupTaskTitle");
        this.__popupLevel = new ObservedPropertySimplePU(TaskLevel.S, this, "popupLevel");
        this.today = new Date();
        this.taskIdCounter = 0;
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: MainPage_Params) {
        if (params.allTasks !== undefined) {
            this.allTasks = params.allTasks;
        }
        if (params.currentUser !== undefined) {
            this.currentUser = params.currentUser;
        }
        if (params.viewYear !== undefined) {
            this.viewYear = params.viewYear;
        }
        if (params.viewMonth !== undefined) {
            this.viewMonth = params.viewMonth;
        }
        if (params.selectedDateKey !== undefined) {
            this.selectedDateKey = params.selectedDateKey;
        }
        if (params.currentPopup !== undefined) {
            this.currentPopup = params.currentPopup;
        }
        if (params.popupTaskTitle !== undefined) {
            this.popupTaskTitle = params.popupTaskTitle;
        }
        if (params.popupLevel !== undefined) {
            this.popupLevel = params.popupLevel;
        }
        if (params.today !== undefined) {
            this.today = params.today;
        }
        if (params.taskIdCounter !== undefined) {
            this.taskIdCounter = params.taskIdCounter;
        }
    }
    updateStateVars(params: MainPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__allTasks.purgeDependencyOnElmtId(rmElmtId);
        this.__currentUser.purgeDependencyOnElmtId(rmElmtId);
        this.__viewYear.purgeDependencyOnElmtId(rmElmtId);
        this.__viewMonth.purgeDependencyOnElmtId(rmElmtId);
        this.__selectedDateKey.purgeDependencyOnElmtId(rmElmtId);
        this.__currentPopup.purgeDependencyOnElmtId(rmElmtId);
        this.__popupTaskTitle.purgeDependencyOnElmtId(rmElmtId);
        this.__popupLevel.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__allTasks.aboutToBeDeleted();
        this.__currentUser.aboutToBeDeleted();
        this.__viewYear.aboutToBeDeleted();
        this.__viewMonth.aboutToBeDeleted();
        this.__selectedDateKey.aboutToBeDeleted();
        this.__currentPopup.aboutToBeDeleted();
        this.__popupTaskTitle.aboutToBeDeleted();
        this.__popupLevel.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __allTasks: ObservedPropertyObjectPU<Task[]>;
    get allTasks() {
        return this.__allTasks.get();
    }
    set allTasks(newValue: Task[]) {
        this.__allTasks.set(newValue);
    }
    private __currentUser: ObservedPropertySimplePU<string>;
    get currentUser() {
        return this.__currentUser.get();
    }
    set currentUser(newValue: string) {
        this.__currentUser.set(newValue);
    }
    private __viewYear: ObservedPropertySimplePU<number>;
    get viewYear() {
        return this.__viewYear.get();
    }
    set viewYear(newValue: number) {
        this.__viewYear.set(newValue);
    }
    private __viewMonth: ObservedPropertySimplePU<number>;
    get viewMonth() {
        return this.__viewMonth.get();
    }
    set viewMonth(newValue: number) {
        this.__viewMonth.set(newValue);
    }
    private __selectedDateKey: ObservedPropertySimplePU<string>;
    get selectedDateKey() {
        return this.__selectedDateKey.get();
    }
    set selectedDateKey(newValue: string) {
        this.__selectedDateKey.set(newValue);
    }
    private __currentPopup: ObservedPropertyObjectPU<TaskPopupConfig>;
    get currentPopup() {
        return this.__currentPopup.get();
    }
    set currentPopup(newValue: TaskPopupConfig) {
        this.__currentPopup.set(newValue);
    }
    private __popupTaskTitle: ObservedPropertySimplePU<string>;
    get popupTaskTitle() {
        return this.__popupTaskTitle.get();
    }
    set popupTaskTitle(newValue: string) {
        this.__popupTaskTitle.set(newValue);
    }
    private __popupLevel: ObservedPropertySimplePU<TaskLevel>;
    get popupLevel() {
        return this.__popupLevel.get();
    }
    set popupLevel(newValue: TaskLevel) {
        this.__popupLevel.set(newValue);
    }
    private today: Date;
    private taskIdCounter: number;
    aboutToAppear(): void {
        TaskRepository.initialize();
        UserSessionRepository.initialize();
        this.refreshState();
    }
    private refreshState(): void {
        this.allTasks = TaskRepository.getAllTasks();
        this.currentUser = UserSessionRepository.getCurrentUser();
    }
    private tasksForSelected(): Task[] {
        return getTasksForDate(this.allTasks, this.selectedDateKey);
    }
    private countByLevel(level: TaskLevel): number {
        return countPendingTasksByLevel(this.allTasks, level);
    }
    private applyTasks(updated: Task[]): void {
        this.allTasks = updated;
    }
    private navigateReplace(url: string): void {
        void this.getUIContext().getRouter().replaceUrl({ url }).catch((): void => { });
    }
    private showToast(message: string, duration: number = 1500): void {
        try {
            this.getUIContext().getPromptAction().showToast({ message, duration });
        }
        catch (error) {
        }
    }
    private closePopup(): void {
        this.currentPopup = null;
        this.popupTaskTitle = '';
    }
    private openAddTaskPopup(): void {
        this.showToast('已触发添加任务按钮', 1000);
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
        if (this.currentPopup.type === PopupType.AddTask) {
            try {
                const updated = TaskRepository.addTask({
                    title: this.popupTaskTitle,
                    date: this.currentPopup.date,
                    level: this.popupLevel,
                    idSeed: `${++this.taskIdCounter}`
                });
                this.applyTasks(updated);
                this.showToast(`已添加 ${this.popupLevel} 级任务`, 1500);
                this.closePopup();
            }
            catch (error) {
                this.showToast('请输入任务内容', 1500);
            }
            return;
        }
        if (this.currentPopup.type === PopupType.EditTaskLevel) {
            const updated = TaskRepository.updateTaskLevel(this.currentPopup.taskId, this.popupLevel);
            this.applyTasks(updated);
            this.showToast(`已更新为 ${this.popupLevel} 级任务`, 1500);
            this.closePopup();
            return;
        }
        if (this.currentPopup.type === PopupType.DeleteTask) {
            const updated = TaskRepository.deleteTask(this.currentPopup.taskId);
            this.applyTasks(updated);
            this.showToast('任务已删除', 1500);
            this.closePopup();
        }
    }
    private toggleComplete(taskId: string): void {
        this.applyTasks(TaskRepository.toggleTaskComplete(taskId));
    }
    private prevMonth(): void {
        if (this.viewMonth === 1) {
            this.viewMonth = 12;
            this.viewYear -= 1;
        }
        else {
            this.viewMonth -= 1;
        }
    }
    private nextMonth(): void {
        if (this.viewMonth === 12) {
            this.viewMonth = 1;
            this.viewYear += 1;
        }
        else {
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
    DayCell(row: number, col: number, parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/MainPage.ets(221:5)", "entry");
            Column.layoutWeight(1);
            Column.height(44);
            Column.justifyContent(FlexAlign.Center);
            Column.alignItems(HorizontalAlign.Center);
            Column.borderRadius(22);
            Column.backgroundColor(this.isSelectedCell(row, col) ? '#CF0A2C' : Color.Transparent);
            Column.onClick(() => {
                this.selectedDateKey = this.cellDateKey(row, col);
                this.popupLevel = autoGrade(countTasksForDate(this.allTasks, this.cellDateKey(row, col)));
            });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`${this.dayNumber(row, col)}`);
            Text.debugLine("entry/src/main/ets/pages/MainPage.ets(222:7)", "entry");
            Text.fontSize(15);
            Text.fontWeight(this.isTodayCell(row, col) ? FontWeight.Bold : FontWeight.Normal);
            Text.fontColor(this.isSelectedCell(row, col)
                ? Color.White
                : this.isTodayCell(row, col)
                    ? '#CF0A2C'
                    : '#1A1A1A');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.hasTasksOn(this.cellDateKey(row, col))) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Circle.create();
                        Circle.debugLine("entry/src/main/ets/pages/MainPage.ets(234:9)", "entry");
                        Circle.width(5);
                        Circle.height(5);
                        Circle.fill(this.isSelectedCell(row, col) ? Color.White : '#CF0A2C');
                        Circle.margin({ top: 2 });
                    }, Circle);
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        Column.pop();
    }
    CalendarGrid(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/MainPage.ets(255:5)", "entry");
            Column.width('100%');
            Column.backgroundColor(Color.White);
            Column.borderRadius(12);
            Column.padding(12);
            Column.shadow({ radius: 6, color: '#1A000000', offsetX: 0, offsetY: 2 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/MainPage.ets(256:7)", "entry");
            Row.width('100%');
            Row.padding({ left: 8, right: 8 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('<');
            Button.debugLine("entry/src/main/ets/pages/MainPage.ets(257:9)", "entry");
            Button.width(46);
            Button.height(46);
            Button.fontSize(18);
            Button.fontColor('#333333');
            Button.backgroundColor(Color.Transparent);
            Button.onClick(() => this.prevMonth());
        }, Button);
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`${this.viewYear}年 ${this.viewMonth}月`);
            Text.debugLine("entry/src/main/ets/pages/MainPage.ets(265:9)", "entry");
            Text.fontSize(18);
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor('#1A1A1A');
            Text.layoutWeight(1);
            Text.textAlign(TextAlign.Center);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('>');
            Button.debugLine("entry/src/main/ets/pages/MainPage.ets(272:9)", "entry");
            Button.width(46);
            Button.height(46);
            Button.fontSize(18);
            Button.fontColor('#333333');
            Button.backgroundColor(Color.Transparent);
            Button.onClick(() => this.nextMonth());
        }, Button);
        Button.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/MainPage.ets(283:7)", "entry");
            Row.width('100%');
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            ForEach.create();
            const forEachItemGenFunction = _item => {
                const label = _item;
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Text.create(label);
                    Text.debugLine("entry/src/main/ets/pages/MainPage.ets(285:11)", "entry");
                    Text.layoutWeight(1);
                    Text.textAlign(TextAlign.Center);
                    Text.fontSize(13);
                    Text.fontColor('#757575');
                    Text.padding({ top: 8, bottom: 4 });
                }, Text);
                Text.pop();
            };
            this.forEachUpdateFunction(elmtId, WEEKDAY_LABELS, forEachItemGenFunction);
        }, ForEach);
        ForEach.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/MainPage.ets(295:7)", "entry");
            Column.width('100%');
        }, Column);
        this.DayCells.bind(this)();
        Column.pop();
        Column.pop();
    }
    DayCells(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            ForEach.create();
            const forEachItemGenFunction = _item => {
                const row = _item;
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Row.create();
                    Row.debugLine("entry/src/main/ets/pages/MainPage.ets(310:7)", "entry");
                    Row.width('100%');
                }, Row);
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    ForEach.create();
                    const forEachItemGenFunction = _item => {
                        const col = _item;
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            If.create();
                            if (this.isValidDay(this.dayNumber(row, col))) {
                                this.ifElseBranchUpdateFunction(0, () => {
                                    this.DayCell.bind(this)(row, col);
                                });
                            }
                            else {
                                this.ifElseBranchUpdateFunction(1, () => {
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Column.create();
                                        Column.debugLine("entry/src/main/ets/pages/MainPage.ets(315:13)", "entry");
                                        Column.layoutWeight(1);
                                        Column.height(44);
                                    }, Column);
                                    Column.pop();
                                });
                            }
                        }, If);
                        If.pop();
                    };
                    this.forEachUpdateFunction(elmtId, CALENDAR_COLS, forEachItemGenFunction);
                }, ForEach);
                ForEach.pop();
                Row.pop();
            };
            this.forEachUpdateFunction(elmtId, this.calendarRows(), forEachItemGenFunction);
        }, ForEach);
        ForEach.pop();
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Stack.create({ alignContent: Alignment.BottomEnd });
            Stack.debugLine("entry/src/main/ets/pages/MainPage.ets(326:5)", "entry");
            Stack.width('100%');
            Stack.height('100%');
            Stack.backgroundColor('#F5F5F5');
        }, Stack);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Scroll.create();
            Scroll.debugLine("entry/src/main/ets/pages/MainPage.ets(327:7)", "entry");
            Scroll.scrollBar(BarState.Off);
            Scroll.width('100%');
            Scroll.height('100%');
        }, Scroll);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/MainPage.ets(328:9)", "entry");
            Column.width('100%');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/MainPage.ets(329:11)", "entry");
            Row.width('100%');
            Row.padding({ left: 20, right: 16, top: 16, bottom: 8 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/MainPage.ets(330:13)", "entry");
            Column.alignItems(HorizontalAlign.Start);
            Column.layoutWeight(1);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('这里是日记备忘录');
            Text.debugLine("entry/src/main/ets/pages/MainPage.ets(331:15)", "entry");
            Text.fontSize(22);
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor('#1A1A1A');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`你好，${this.currentUser}`);
            Text.debugLine("entry/src/main/ets/pages/MainPage.ets(336:15)", "entry");
            Text.fontSize(13);
            Text.fontColor('#757575');
            Text.margin({ top: 2 });
        }, Text);
        Text.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('退出');
            Text.debugLine("entry/src/main/ets/pages/MainPage.ets(344:13)", "entry");
            Text.fontSize(14);
            Text.fontColor('#CF0A2C');
            Text.padding({ left: 12, right: 4, top: 8, bottom: 8 });
            Text.onClick(() => {
                UserSessionRepository.clear();
                TaskRepository.clear();
                this.currentUser = UserSessionRepository.getCurrentUser();
                this.allTasks = TaskRepository.getAllTasks();
                this.navigateReplace('pages/LoginPage');
            });
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({ space: 8 });
            Row.debugLine("entry/src/main/ets/pages/MainPage.ets(359:11)", "entry");
            Row.width('100%');
            Row.padding({ left: 16, right: 16, bottom: 14 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            ForEach.create();
            const forEachItemGenFunction = _item => {
                const level = _item;
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Column.create();
                    Column.debugLine("entry/src/main/ets/pages/MainPage.ets(361:15)", "entry");
                    Column.layoutWeight(1);
                    Column.height(60);
                    Column.justifyContent(FlexAlign.Center);
                    Column.backgroundColor(Color.White);
                    Column.borderRadius(10);
                    Column.shadow({ radius: 4, color: '#0D000000', offsetX: 0, offsetY: 1 });
                }, Column);
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Text.create(`${this.countByLevel(level)}`);
                    Text.debugLine("entry/src/main/ets/pages/MainPage.ets(362:17)", "entry");
                    Text.fontSize(20);
                    Text.fontWeight(FontWeight.Bold);
                    Text.fontColor(getLevelColor(level));
                }, Text);
                Text.pop();
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Text.create(`${level}级任务`);
                    Text.debugLine("entry/src/main/ets/pages/MainPage.ets(367:17)", "entry");
                    Text.fontSize(12);
                    Text.fontColor('#9E9E9E');
                }, Text);
                Text.pop();
                Column.pop();
            };
            this.forEachUpdateFunction(elmtId, [TaskLevel.S, TaskLevel.A, TaskLevel.B, TaskLevel.C], forEachItemGenFunction);
        }, ForEach);
        ForEach.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/MainPage.ets(382:11)", "entry");
            Column.padding({ left: 16, right: 16, bottom: 16 });
        }, Column);
        this.CalendarGrid.bind(this)();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/MainPage.ets(387:11)", "entry");
            Row.width('100%');
            Row.padding({ left: 20, right: 20, bottom: 10 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.selectedDateKey === dateKey(this.today)
                ? `今天  ${this.selectedDateKey}`
                : this.selectedDateKey);
            Text.debugLine("entry/src/main/ets/pages/MainPage.ets(388:13)", "entry");
            Text.fontSize(16);
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor('#1A1A1A');
            Text.layoutWeight(1);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`${this.tasksForSelected().length} 项`);
            Text.debugLine("entry/src/main/ets/pages/MainPage.ets(396:13)", "entry");
            Text.fontSize(13);
            Text.fontColor('#757575');
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/MainPage.ets(403:11)", "entry");
            Column.padding({ left: 16, right: 16, bottom: 80 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.tasksForSelected().length === 0) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.debugLine("entry/src/main/ets/pages/MainPage.ets(405:15)", "entry");
                        Column.width('100%');
                        Column.height(160);
                        Column.justifyContent(FlexAlign.Center);
                        Column.alignItems(HorizontalAlign.Center);
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('暂无任务');
                        Text.debugLine("entry/src/main/ets/pages/MainPage.ets(406:17)", "entry");
                        Text.fontSize(15);
                        Text.fontColor('#9E9E9E');
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('点击右下角按钮添加任务');
                        Text.debugLine("entry/src/main/ets/pages/MainPage.ets(410:17)", "entry");
                        Text.fontSize(13);
                        Text.fontColor('#BDBDBD');
                        Text.margin({ top: 4 });
                    }, Text);
                    Text.pop();
                    Column.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        ForEach.create();
                        const forEachItemGenFunction = _item => {
                            const task = _item;
                            {
                                this.observeComponentCreation2((elmtId, isInitialRender) => {
                                    if (isInitialRender) {
                                        let componentCall = new TaskItemView(this, {
                                            task,
                                            onToggleComplete: (taskId: string) => { this.toggleComplete(taskId); },
                                            onEdit: (targetTask: Task) => { this.openEditTaskPopup(targetTask); },
                                            onDelete: (targetTask: Task) => { this.openDeleteTaskPopup(targetTask); }
                                        }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/MainPage.ets", line: 421, col: 17 });
                                        ViewPU.create(componentCall);
                                        let paramsLambda = () => {
                                            return {
                                                task,
                                                onToggleComplete: (taskId: string) => { this.toggleComplete(taskId); },
                                                onEdit: (targetTask: Task) => { this.openEditTaskPopup(targetTask); },
                                                onDelete: (targetTask: Task) => { this.openDeleteTaskPopup(targetTask); }
                                            };
                                        };
                                        componentCall.paramsGenerator_ = paramsLambda;
                                    }
                                    else {
                                        this.updateStateVarsOfChildByElmtId(elmtId, {
                                            task
                                        });
                                    }
                                }, { name: "TaskItemView" });
                            }
                        };
                        this.forEachUpdateFunction(elmtId, this.tasksForSelected(), forEachItemGenFunction, (task: Task) => task.id, false, false);
                    }, ForEach);
                    ForEach.pop();
                });
            }
        }, If);
        If.pop();
        Column.pop();
        Column.pop();
        Scroll.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('+');
            Button.debugLine("entry/src/main/ets/pages/MainPage.ets(438:7)", "entry");
            Button.width(56);
            Button.height(56);
            Button.fontSize(30);
            Button.fontColor(Color.White);
            Button.backgroundColor('#CF0A2C');
            Button.borderRadius(28);
            Button.shadow({ radius: 8, color: '#40000000', offsetX: 0, offsetY: 4 });
            Button.margin({ bottom: 28, right: 24 });
            Button.onClick(() => this.openAddTaskPopup());
        }, Button);
        Button.pop();
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new TaskPopupHost(this, {
                        popupConfig: this.currentPopup,
                        taskTitle: this.__popupTaskTitle,
                        selectedLevel: this.__popupLevel,
                        onClose: () => { this.closePopup(); },
                        onConfirm: () => { this.confirmPopup(); }
                    }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/MainPage.ets", line: 449, col: 7 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            popupConfig: this.currentPopup,
                            taskTitle: this.popupTaskTitle,
                            selectedLevel: this.popupLevel,
                            onClose: () => { this.closePopup(); },
                            onConfirm: () => { this.confirmPopup(); }
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {
                        popupConfig: this.currentPopup
                    });
                }
            }, { name: "TaskPopupHost" });
        }
        Stack.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "MainPage";
    }
}
registerNamedRoute(() => new MainPage(undefined, {}), "", { bundleName: "com.example.diarynotes", moduleName: "entry", pagePath: "pages/MainPage", pageFullPath: "entry/src/main/ets/pages/MainPage", integratedHsp: "false", moduleType: "followWithHap" });

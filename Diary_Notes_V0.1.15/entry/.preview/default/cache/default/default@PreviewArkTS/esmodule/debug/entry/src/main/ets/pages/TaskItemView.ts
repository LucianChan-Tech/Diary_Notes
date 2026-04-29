if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface TaskItemView_Params {
    task?: Task;
    onToggleComplete?: (taskId: string) => void;
    onEdit?: (task: Task) => void;
    onDelete?: (task: Task) => void;
}
import { getLevelColor, getLevelDesc } from "@normalized:N&&&entry/src/main/ets/model/TaskModel&";
import type { Task } from "@normalized:N&&&entry/src/main/ets/model/TaskModel&";
export class TaskItemView extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__task = new SynchedPropertyObjectOneWayPU(params.task, this, "task");
        this.onToggleComplete = () => { };
        this.onEdit = () => { };
        this.onDelete = () => { };
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: TaskItemView_Params) {
        if (params.onToggleComplete !== undefined) {
            this.onToggleComplete = params.onToggleComplete;
        }
        if (params.onEdit !== undefined) {
            this.onEdit = params.onEdit;
        }
        if (params.onDelete !== undefined) {
            this.onDelete = params.onDelete;
        }
    }
    updateStateVars(params: TaskItemView_Params) {
        this.__task.reset(params.task);
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__task.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__task.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __task: SynchedPropertySimpleOneWayPU<Task>;
    get task() {
        return this.__task.get();
    }
    set task(newValue: Task) {
        this.__task.set(newValue);
    }
    private onToggleComplete: (taskId: string) => void;
    private onEdit: (task: Task) => void;
    private onDelete: (task: Task) => void;
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/TaskItemView.ets(12:5)", "entry");
            Row.width('100%');
            Row.padding(14);
            Row.backgroundColor(Color.White);
            Row.borderRadius(10);
            Row.shadow({ radius: 4, color: '#0D000000', offsetX: 0, offsetY: 1 });
            Row.margin({ bottom: 10 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.task.level);
            Text.debugLine("entry/src/main/ets/pages/TaskItemView.ets(13:7)", "entry");
            Text.width(32);
            Text.height(32);
            Text.fontSize(15);
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor(Color.White);
            Text.textAlign(TextAlign.Center);
            Text.borderRadius(16);
            Text.backgroundColor(getLevelColor(this.task.level));
            Text.margin({ right: 12 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/TaskItemView.ets(24:7)", "entry");
            Column.layoutWeight(1);
            Column.alignItems(HorizontalAlign.Start);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.task.title);
            Text.debugLine("entry/src/main/ets/pages/TaskItemView.ets(25:9)", "entry");
            Text.fontSize(15);
            Text.fontColor(this.task.completed ? '#AAAAAA' : '#1A1A1A');
            Text.decoration(this.task.completed
                ? { type: TextDecorationType.LineThrough, color: '#AAAAAA' }
                : { type: TextDecorationType.None });
            Text.maxLines(2);
            Text.textOverflow({ overflow: TextOverflow.Ellipsis });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(getLevelDesc(this.task.level));
            Text.debugLine("entry/src/main/ets/pages/TaskItemView.ets(34:9)", "entry");
            Text.fontSize(12);
            Text.fontColor(getLevelColor(this.task.level));
            Text.margin({ top: 2 });
        }, Text);
        Text.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({ space: 8 });
            Row.debugLine("entry/src/main/ets/pages/TaskItemView.ets(42:7)", "entry");
            Row.margin({ left: 8 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.task.completed ? '撤销' : '完成');
            Text.debugLine("entry/src/main/ets/pages/TaskItemView.ets(43:9)", "entry");
            Text.fontSize(14);
            Text.fontColor(this.task.completed ? '#9E9E9E' : '#4CAF50');
            Text.onClick(() => this.onToggleComplete(this.task.id));
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('编辑');
            Text.debugLine("entry/src/main/ets/pages/TaskItemView.ets(48:9)", "entry");
            Text.fontSize(14);
            Text.fontColor('#1565C0');
            Text.onClick(() => this.onEdit(ObservedObject.GetRawObject(this.task)));
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('删除');
            Text.debugLine("entry/src/main/ets/pages/TaskItemView.ets(53:9)", "entry");
            Text.fontSize(14);
            Text.fontColor('#E53935');
            Text.onClick(() => this.onDelete(ObservedObject.GetRawObject(this.task)));
        }, Text);
        Text.pop();
        Row.pop();
        Row.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}

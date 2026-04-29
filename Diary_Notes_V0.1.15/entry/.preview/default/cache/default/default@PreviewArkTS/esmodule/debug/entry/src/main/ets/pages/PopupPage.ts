if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface TaskPopupHost_Params {
    popupConfig?: TaskPopupConfig;
    taskTitle?: string;
    selectedLevel?: TaskLevel;
    onClose?: () => void;
    onConfirm?: () => void;
}
import { PopupType } from "@normalized:N&&&entry/src/main/ets/model/PopupTypes&";
import type { AddTaskPopupConfig, DeleteTaskPopupConfig, EditTaskLevelPopupConfig, TaskPopupConfig } from "@normalized:N&&&entry/src/main/ets/model/PopupTypes&";
import { getLevelColor, getLevelDesc } from "@normalized:N&&&entry/src/main/ets/model/TaskModel&";
import type { TaskLevel } from "@normalized:N&&&entry/src/main/ets/model/TaskModel&";
export class TaskPopupHost extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__popupConfig = new SynchedPropertyObjectOneWayPU(params.popupConfig, this, "popupConfig");
        this.__taskTitle = new SynchedPropertySimpleTwoWayPU(params.taskTitle, this, "taskTitle");
        this.__selectedLevel = new SynchedPropertySimpleTwoWayPU(params.selectedLevel, this, "selectedLevel");
        this.onClose = () => { };
        this.onConfirm = () => { };
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: TaskPopupHost_Params) {
        if (params.popupConfig === undefined) {
            this.__popupConfig.set(null);
        }
        if (params.onClose !== undefined) {
            this.onClose = params.onClose;
        }
        if (params.onConfirm !== undefined) {
            this.onConfirm = params.onConfirm;
        }
    }
    updateStateVars(params: TaskPopupHost_Params) {
        this.__popupConfig.reset(params.popupConfig);
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__popupConfig.purgeDependencyOnElmtId(rmElmtId);
        this.__taskTitle.purgeDependencyOnElmtId(rmElmtId);
        this.__selectedLevel.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__popupConfig.aboutToBeDeleted();
        this.__taskTitle.aboutToBeDeleted();
        this.__selectedLevel.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __popupConfig: SynchedPropertySimpleOneWayPU<TaskPopupConfig>;
    get popupConfig() {
        return this.__popupConfig.get();
    }
    set popupConfig(newValue: TaskPopupConfig) {
        this.__popupConfig.set(newValue);
    }
    private __taskTitle: SynchedPropertySimpleTwoWayPU<string>;
    get taskTitle() {
        return this.__taskTitle.get();
    }
    set taskTitle(newValue: string) {
        this.__taskTitle.set(newValue);
    }
    private __selectedLevel: SynchedPropertySimpleTwoWayPU<TaskLevel>;
    get selectedLevel() {
        return this.__selectedLevel.get();
    }
    set selectedLevel(newValue: TaskLevel) {
        this.__selectedLevel.set(newValue);
    }
    private onClose: () => void;
    private onConfirm: () => void;
    private addTaskPopup(): AddTaskPopupConfig {
        return this.popupConfig as AddTaskPopupConfig;
    }
    private editTaskPopup(): EditTaskLevelPopupConfig {
        return this.popupConfig as EditTaskLevelPopupConfig;
    }
    private deleteTaskPopup(): DeleteTaskPopupConfig {
        return this.popupConfig as DeleteTaskPopupConfig;
    }
    private LevelSelector(levelOptions: TaskLevel[], parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({ space: 10 });
            Row.debugLine("entry/src/main/ets/pages/PopupPage.ets(33:5)", "entry");
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            ForEach.create();
            const forEachItemGenFunction = _item => {
                const level = _item;
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Text.create(level);
                    Text.debugLine("entry/src/main/ets/pages/PopupPage.ets(35:9)", "entry");
                    Text.width(48);
                    Text.height(36);
                    Text.textAlign(TextAlign.Center);
                    Text.fontSize(15);
                    Text.fontWeight(FontWeight.Bold);
                    Text.fontColor(this.selectedLevel === level ? Color.White : getLevelColor(level));
                    Text.backgroundColor(this.selectedLevel === level ? getLevelColor(level) : '#F5F5F5');
                    Text.borderRadius(18);
                    Text.border({ width: 1.5, color: getLevelColor(level) });
                    Text.onClick(() => {
                        this.selectedLevel = level;
                    });
                }, Text);
                Text.pop();
            };
            this.forEachUpdateFunction(elmtId, levelOptions, forEachItemGenFunction);
        }, ForEach);
        ForEach.pop();
        Row.pop();
    }
    private AddTaskPopupView(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/PopupPage.ets(54:5)", "entry");
            Column.width('100%');
            Column.padding(24);
            Column.backgroundColor(Color.White);
            Column.borderRadius(16);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.addTaskPopup().title);
            Text.debugLine("entry/src/main/ets/pages/PopupPage.ets(55:7)", "entry");
            Text.fontSize(18);
            Text.fontWeight(FontWeight.Bold);
            Text.margin({ bottom: 8 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.addTaskPopup().date);
            Text.debugLine("entry/src/main/ets/pages/PopupPage.ets(60:7)", "entry");
            Text.width('100%');
            Text.fontSize(12);
            Text.fontColor('#9E9E9E');
            Text.margin({ bottom: 16 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TextInput.create({
                placeholder: this.addTaskPopup().placeholder,
                text: this.taskTitle
            });
            TextInput.debugLine("entry/src/main/ets/pages/PopupPage.ets(66:7)", "entry");
            TextInput.width('100%');
            TextInput.fontSize(15);
            TextInput.onChange((value: string) => {
                this.taskTitle = value;
            });
            TextInput.margin({ bottom: 16 });
        }, TextInput);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('优先级（可手动调整）');
            Text.debugLine("entry/src/main/ets/pages/PopupPage.ets(77:7)", "entry");
            Text.fontSize(13);
            Text.fontColor('#757575');
            Text.width('100%');
            Text.margin({ bottom: 8 });
        }, Text);
        Text.pop();
        this.LevelSelector.bind(this)(this.addTaskPopup().levelOptions);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(getLevelDesc(this.selectedLevel));
            Text.debugLine("entry/src/main/ets/pages/PopupPage.ets(85:7)", "entry");
            Text.fontSize(12);
            Text.fontColor(getLevelColor(this.selectedLevel));
            Text.width('100%');
            Text.margin({ top: 8, bottom: 20 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({ space: 12 });
            Row.debugLine("entry/src/main/ets/pages/PopupPage.ets(91:7)", "entry");
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel(this.addTaskPopup().cancelText);
            Button.debugLine("entry/src/main/ets/pages/PopupPage.ets(92:9)", "entry");
            Button.layoutWeight(1);
            Button.height(44);
            Button.backgroundColor('#F5F5F5');
            Button.fontColor('#555555');
            Button.onClick(() => this.onClose());
        }, Button);
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel(this.addTaskPopup().confirmText);
            Button.debugLine("entry/src/main/ets/pages/PopupPage.ets(99:9)", "entry");
            Button.layoutWeight(1);
            Button.height(44);
            Button.backgroundColor('#CF0A2C');
            Button.fontColor(Color.White);
            Button.onClick(() => this.onConfirm());
        }, Button);
        Button.pop();
        Row.pop();
        Column.pop();
    }
    private EditTaskLevelPopupView(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/PopupPage.ets(115:5)", "entry");
            Column.width('100%');
            Column.padding(24);
            Column.backgroundColor(Color.White);
            Column.borderRadius(16);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.editTaskPopup().title);
            Text.debugLine("entry/src/main/ets/pages/PopupPage.ets(116:7)", "entry");
            Text.fontSize(18);
            Text.fontWeight(FontWeight.Bold);
            Text.margin({ bottom: 16 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`"${this.editTaskPopup().taskTitle}"`);
            Text.debugLine("entry/src/main/ets/pages/PopupPage.ets(121:7)", "entry");
            Text.fontSize(14);
            Text.fontColor('#555555');
            Text.maxLines(1);
            Text.textOverflow({ overflow: TextOverflow.Ellipsis });
            Text.margin({ bottom: 16 });
        }, Text);
        Text.pop();
        this.LevelSelector.bind(this)(this.editTaskPopup().levelOptions);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(getLevelDesc(this.selectedLevel));
            Text.debugLine("entry/src/main/ets/pages/PopupPage.ets(130:7)", "entry");
            Text.fontSize(12);
            Text.fontColor(getLevelColor(this.selectedLevel));
            Text.width('100%');
            Text.margin({ top: 8, bottom: 24 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({ space: 12 });
            Row.debugLine("entry/src/main/ets/pages/PopupPage.ets(136:7)", "entry");
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel(this.editTaskPopup().cancelText);
            Button.debugLine("entry/src/main/ets/pages/PopupPage.ets(137:9)", "entry");
            Button.layoutWeight(1);
            Button.height(44);
            Button.backgroundColor('#F5F5F5');
            Button.fontColor('#555555');
            Button.onClick(() => this.onClose());
        }, Button);
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel(this.editTaskPopup().confirmText);
            Button.debugLine("entry/src/main/ets/pages/PopupPage.ets(144:9)", "entry");
            Button.layoutWeight(1);
            Button.height(44);
            Button.backgroundColor('#1E88E5');
            Button.fontColor(Color.White);
            Button.onClick(() => this.onConfirm());
        }, Button);
        Button.pop();
        Row.pop();
        Column.pop();
    }
    private DeleteTaskPopupView(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/PopupPage.ets(160:5)", "entry");
            Column.width('100%');
            Column.padding(24);
            Column.backgroundColor(Color.White);
            Column.borderRadius(16);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.deleteTaskPopup().title);
            Text.debugLine("entry/src/main/ets/pages/PopupPage.ets(161:7)", "entry");
            Text.fontSize(18);
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor('#1A1A1A');
            Text.margin({ bottom: 12 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`"${this.deleteTaskPopup().taskTitle}"`);
            Text.debugLine("entry/src/main/ets/pages/PopupPage.ets(167:7)", "entry");
            Text.fontSize(15);
            Text.fontWeight(FontWeight.Medium);
            Text.fontColor('#333333');
            Text.maxLines(2);
            Text.textOverflow({ overflow: TextOverflow.Ellipsis });
            Text.width('100%');
            Text.margin({ bottom: 10 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.deleteTaskPopup().message);
            Text.debugLine("entry/src/main/ets/pages/PopupPage.ets(176:7)", "entry");
            Text.fontSize(13);
            Text.fontColor('#757575');
            Text.width('100%');
            Text.margin({ bottom: 24 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({ space: 12 });
            Row.debugLine("entry/src/main/ets/pages/PopupPage.ets(182:7)", "entry");
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel(this.deleteTaskPopup().cancelText);
            Button.debugLine("entry/src/main/ets/pages/PopupPage.ets(183:9)", "entry");
            Button.layoutWeight(1);
            Button.height(44);
            Button.backgroundColor('#F5F5F5');
            Button.fontColor('#555555');
            Button.onClick(() => this.onClose());
        }, Button);
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel(this.deleteTaskPopup().confirmText);
            Button.debugLine("entry/src/main/ets/pages/PopupPage.ets(190:9)", "entry");
            Button.layoutWeight(1);
            Button.height(44);
            Button.backgroundColor('#E53935');
            Button.fontColor(Color.White);
            Button.onClick(() => this.onConfirm());
        }, Button);
        Button.pop();
        Row.pop();
        Column.pop();
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Stack.create();
            Stack.debugLine("entry/src/main/ets/pages/PopupPage.ets(205:5)", "entry");
            Stack.width('100%');
            Stack.height('100%');
        }, Stack);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.popupConfig !== null) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.debugLine("entry/src/main/ets/pages/PopupPage.ets(207:9)", "entry");
                        Column.width('100%');
                        Column.height('100%');
                        Column.backgroundColor('#66000000');
                        Column.onClick(() => this.onClose());
                    }, Column);
                    Column.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.debugLine("entry/src/main/ets/pages/PopupPage.ets(213:9)", "entry");
                        Column.width('92%');
                        Column.position({
                            x: '4%',
                            y: this.popupConfig.type === PopupType.DeleteTask ? '34%' : this.popupConfig.type === PopupType.AddTask ? '20%' : '30%'
                        });
                        Column.shadow({ radius: 24, color: '#40000000', offsetX: 0, offsetY: 8 });
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        If.create();
                        if (this.popupConfig.type === PopupType.AddTask) {
                            this.ifElseBranchUpdateFunction(0, () => {
                                this.AddTaskPopupView.bind(this)();
                            });
                        }
                        else {
                            this.ifElseBranchUpdateFunction(1, () => {
                            });
                        }
                    }, If);
                    If.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        If.create();
                        if (this.popupConfig.type === PopupType.EditTaskLevel) {
                            this.ifElseBranchUpdateFunction(0, () => {
                                this.EditTaskLevelPopupView.bind(this)();
                            });
                        }
                        else {
                            this.ifElseBranchUpdateFunction(1, () => {
                            });
                        }
                    }, If);
                    If.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        If.create();
                        if (this.popupConfig.type === PopupType.DeleteTask) {
                            this.ifElseBranchUpdateFunction(0, () => {
                                this.DeleteTaskPopupView.bind(this)();
                            });
                        }
                        else {
                            this.ifElseBranchUpdateFunction(1, () => {
                            });
                        }
                    }, If);
                    If.pop();
                    Column.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        Stack.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}

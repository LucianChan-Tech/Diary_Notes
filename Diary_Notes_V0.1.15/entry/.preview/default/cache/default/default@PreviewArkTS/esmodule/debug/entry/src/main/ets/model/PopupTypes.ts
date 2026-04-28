import { TaskLevel, autoGrade, countTasksForDate } from "@normalized:N&&&entry/src/main/ets/model/TaskModel&";
import type { Task } from "@normalized:N&&&entry/src/main/ets/model/TaskModel&";
export enum PopupType {
    AddTask = "add-task",
    EditTaskLevel = "edit-task-level",
    DeleteTask = "delete-task"
}
export const POPUP_LEVEL_OPTIONS: TaskLevel[] = [
    TaskLevel.S,
    TaskLevel.A,
    TaskLevel.B,
    TaskLevel.C
];
interface BasePopupConfig {
    type: PopupType;
    title: string;
    confirmText: string;
    cancelText: string;
}
export interface AddTaskPopupConfig extends BasePopupConfig {
    type: PopupType.AddTask;
    date: string;
    placeholder: string;
    initialLevel: TaskLevel;
    levelOptions: TaskLevel[];
}
export interface EditTaskLevelPopupConfig extends BasePopupConfig {
    type: PopupType.EditTaskLevel;
    taskId: string;
    taskTitle: string;
    initialLevel: TaskLevel;
    levelOptions: TaskLevel[];
}
export interface DeleteTaskPopupConfig extends BasePopupConfig {
    type: PopupType.DeleteTask;
    taskId: string;
    taskTitle: string;
    message: string;
}
export type TaskPopupConfig = AddTaskPopupConfig | EditTaskLevelPopupConfig | DeleteTaskPopupConfig | null;
export function createAddTaskPopup(date: string, allTasks: Task[]): AddTaskPopupConfig {
    const insertionIndex = countTasksForDate(allTasks, date);
    return {
        type: PopupType.AddTask,
        title: '添加任务',
        confirmText: '添加',
        cancelText: '取消',
        date,
        placeholder: '请输入任务内容',
        initialLevel: autoGrade(insertionIndex),
        levelOptions: POPUP_LEVEL_OPTIONS
    };
}
export function createEditTaskLevelPopup(task: Task): EditTaskLevelPopupConfig {
    return {
        type: PopupType.EditTaskLevel,
        title: '修改优先级',
        confirmText: '保存',
        cancelText: '取消',
        taskId: task.id,
        taskTitle: task.title,
        initialLevel: task.level,
        levelOptions: POPUP_LEVEL_OPTIONS
    };
}
export function createDeleteTaskPopup(task: Task): DeleteTaskPopupConfig {
    return {
        type: PopupType.DeleteTask,
        title: '删除任务',
        confirmText: '删除',
        cancelText: '取消',
        taskId: task.id,
        taskTitle: task.title,
        message: '删除后不可恢复，请确认是否继续。'
    };
}

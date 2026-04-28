import { Task, TaskLevel, autoGrade, countTasksForDate } from './TaskModel';

export enum PopupType {
  AddTask = 'add-task',
  EditTaskLevel = 'edit-task-level',
  DeleteTask = 'delete-task',
  RegisterAccount = 'register-account'
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

export interface RegisterAccountPopupConfig extends BasePopupConfig {
  type: PopupType.RegisterAccount;
  accountLabel: string;
  passwordLabel: string;
  confirmPasswordLabel: string;
  accountPlaceholder: string;
  passwordPlaceholder: string;
  confirmPasswordPlaceholder: string;
}

export type TaskPopupConfig =
  | AddTaskPopupConfig
  | EditTaskLevelPopupConfig
  | DeleteTaskPopupConfig
  | null;

export type AuthPopupConfig =
  | RegisterAccountPopupConfig
  | null;

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

export function createRegisterAccountPopup(): RegisterAccountPopupConfig {
  return {
    type: PopupType.RegisterAccount,
    title: '注册账号',
    confirmText: '注册',
    cancelText: '取消',
    accountLabel: '账号',
    passwordLabel: '密码',
    confirmPasswordLabel: '确认密码',
    accountPlaceholder: '请输入账号',
    passwordPlaceholder: '请输入密码',
    confirmPasswordPlaceholder: '请再次输入密码'
  };
}

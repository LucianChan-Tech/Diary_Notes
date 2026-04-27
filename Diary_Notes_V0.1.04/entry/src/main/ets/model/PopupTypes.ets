import { Task, TaskLevel, autoGrade, countTasksForDate } from './TaskModel';

export enum PopupType {
  AddTask = 'add-task',
  EditTaskLevel = 'edit-task-level'
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
  levelOptions: TaskLevel[];
}

export interface AddTaskPopupConfig extends BasePopupConfig {
  type: PopupType.AddTask;
  date: string;
  placeholder: string;
  initialLevel: TaskLevel;
}

export interface EditTaskLevelPopupConfig extends BasePopupConfig {
  type: PopupType.EditTaskLevel;
  taskId: string;
  taskTitle: string;
  initialLevel: TaskLevel;
}

export type TaskPopupConfig = AddTaskPopupConfig | EditTaskLevelPopupConfig | null;

export function createAddTaskPopup(date: string, allTasks: Task[]): AddTaskPopupConfig {
  const insertionIndex = countTasksForDate(allTasks, date);
  return {
    type: PopupType.AddTask,
    title: '添加任务',
    confirmText: '添加',
    cancelText: '取消',
    levelOptions: POPUP_LEVEL_OPTIONS,
    date,
    placeholder: '请输入任务内容',
    initialLevel: autoGrade(insertionIndex)
  };
}

export function createEditTaskLevelPopup(task: Task): EditTaskLevelPopupConfig {
  return {
    type: PopupType.EditTaskLevel,
    title: '修改优先级',
    confirmText: '保存',
    cancelText: '取消',
    levelOptions: POPUP_LEVEL_OPTIONS,
    taskId: task.id,
    taskTitle: task.title,
    initialLevel: task.level
  };
}

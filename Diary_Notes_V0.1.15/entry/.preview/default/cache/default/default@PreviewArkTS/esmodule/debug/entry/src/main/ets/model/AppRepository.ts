import { Task, addTask, deleteTaskById, toggleTaskComplete, updateTaskLevel } from "@normalized:N&&&entry/src/main/ets/model/TaskModel&";
import type { TaskLevel, CreateTaskInput } from "@normalized:N&&&entry/src/main/ets/model/TaskModel&";
const ALL_TASKS_KEY: string = 'allTasks';
const CURRENT_USER_KEY: string = 'currentUser';
const DEFAULT_USER: string = '游客';
function cloneTask(task: Task): Task {
    const copy = new Task(task.id, task.title, task.level, task.date, task.insertionIndex);
    copy.completed = task.completed;
    return copy;
}
function cloneTasks(tasks: Task[]): Task[] {
    return tasks.map((task) => cloneTask(task));
}
export class UserSessionRepository {
    static initialize(): void {
        AppStorage.setOrCreate<string>(CURRENT_USER_KEY, DEFAULT_USER);
    }
    static getCurrentUser(): string {
        return AppStorage.get<string>(CURRENT_USER_KEY) ?? DEFAULT_USER;
    }
    static setCurrentUser(user: string): void {
        AppStorage.set<string>(CURRENT_USER_KEY, user);
    }
    static clear(): void {
        AppStorage.set<string>(CURRENT_USER_KEY, DEFAULT_USER);
    }
}
export class TaskRepository {
    static initialize(): void {
        AppStorage.setOrCreate<Task[]>(ALL_TASKS_KEY, []);
    }
    static getAllTasks(): Task[] {
        const tasks = AppStorage.get<Task[]>(ALL_TASKS_KEY) ?? [];
        return cloneTasks(tasks);
    }
    static saveAllTasks(tasks: Task[]): Task[] {
        const cloned = cloneTasks(tasks);
        AppStorage.set<Task[]>(ALL_TASKS_KEY, cloned);
        return cloneTasks(cloned);
    }
    static addTask(input: CreateTaskInput): Task[] {
        const updated = addTask(TaskRepository.getAllTasks(), input);
        return TaskRepository.saveAllTasks(updated);
    }
    static updateTaskLevel(taskId: string, level: TaskLevel): Task[] {
        const updated = updateTaskLevel(TaskRepository.getAllTasks(), taskId, level);
        return TaskRepository.saveAllTasks(updated);
    }
    static toggleTaskComplete(taskId: string): Task[] {
        const updated = toggleTaskComplete(TaskRepository.getAllTasks(), taskId);
        return TaskRepository.saveAllTasks(updated);
    }
    static deleteTask(taskId: string): Task[] {
        const updated = deleteTaskById(TaskRepository.getAllTasks(), taskId);
        return TaskRepository.saveAllTasks(updated);
    }
    static clear(): void {
        AppStorage.set<Task[]>(ALL_TASKS_KEY, []);
    }
}

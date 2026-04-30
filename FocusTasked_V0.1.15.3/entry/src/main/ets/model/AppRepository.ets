import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import {
  Task,
  TaskLevel,
  CreateTaskInput,
  addTask,
  deleteTaskById,
  toggleTaskComplete,
  updateTask,
  updateTaskLevel
} from './TaskModel';

const LEGACY_ACCOUNTS_KEY: string = 'accounts';
const LEGACY_TASKS_BY_USER_KEY: string = 'tasksByUser';
const ACCOUNTS_JSON_KEY: string = 'accountsJson';
const TASKS_BY_USER_JSON_KEY: string = 'tasksByUserJson';
const CURRENT_USER_KEY: string = 'currentUser';
const PREFERENCES_NAME: string = 'diary_notes_store';

export class AccountCredential {
  displayName: string;
  username: string;
  password: string;

  constructor(displayName: string, username: string, password: string) {
    this.displayName = displayName;
    this.username = username;
    this.password = password;
  }
}

class UserTaskBucket {
  username: string;
  tasks: Task[];

  constructor(username: string, tasks: Task[]) {
    this.username = username;
    this.tasks = tasks;
  }
}

class RawAccountCredential {
  displayName?: string;
  username?: string;
  password?: string;
}

class RawTaskRecord {
  id?: string;
  title?: string;
  level?: string;
  date?: string;
  completed?: boolean;
  insertionIndex?: number;
}

class RawUserTaskBucket {
  username?: string;
  tasks?: RawTaskRecord[];
}

export enum LoginValidationResult {
  Success = 'success',
  AccountNotFound = 'account-not-found',
  DisplayNameMismatch = 'display-name-mismatch',
  WrongPassword = 'wrong-password'
}

export enum RegisterAccountResult {
  Success = 'success',
  Duplicate = 'duplicate'
}

function cloneTask(task: Task): Task {
  const copy = new Task(task.id, task.title, task.level, task.date, task.insertionIndex);
  copy.completed = task.completed;
  return copy;
}

function cloneTasks(tasks: Task[]): Task[] {
  return tasks.map((task) => cloneTask(task));
}

function cloneAccount(account: AccountCredential): AccountCredential {
  return new AccountCredential(
    normalizeDisplayName(account.displayName ?? account.username),
    account.username,
    account.password
  );
}

function cloneAccounts(accounts: AccountCredential[]): AccountCredential[] {
  return accounts.map((account) => cloneAccount(account));
}

function cloneBucket(bucket: UserTaskBucket): UserTaskBucket {
  return new UserTaskBucket(bucket.username, cloneTasks(bucket.tasks));
}

function cloneBuckets(buckets: UserTaskBucket[]): UserTaskBucket[] {
  return buckets.map((bucket) => cloneBucket(bucket));
}

function normalizeUsername(username: string): string {
  return username.trim();
}

function normalizeDisplayName(displayName: string): string {
  return displayName.trim();
}

function resolveTaskOwner(username: string): string {
  return normalizeUsername(username);
}

function taskLevelFromValue(value: string | undefined): TaskLevel {
  switch (value) {
    case TaskLevel.S:
      return TaskLevel.S;
    case TaskLevel.A:
      return TaskLevel.A;
    case TaskLevel.B:
      return TaskLevel.B;
    case TaskLevel.C:
      return TaskLevel.C;
    default:
      return TaskLevel.C;
  }
}

function taskToSerializable(task: Task): RawTaskRecord {
  const record = new RawTaskRecord();
  record.id = task.id;
  record.title = task.title;
  record.level = task.level;
  record.date = task.date;
  record.completed = task.completed;
  record.insertionIndex = task.insertionIndex;
  return record;
}

function taskFromSerializable(record: RawTaskRecord): Task | null {
  if (record.id === undefined || record.title === undefined || record.date === undefined) {
    return null;
  }

  const insertionIndex = typeof record.insertionIndex === 'number' ? record.insertionIndex : 0;
  const task = new Task(
    record.id,
    record.title,
    taskLevelFromValue(record.level),
    record.date,
    insertionIndex
  );
  task.completed = record.completed === true;
  return task;
}

function accountToSerializable(account: AccountCredential): RawAccountCredential {
  const record = new RawAccountCredential();
  record.displayName = normalizeDisplayName(account.displayName ?? account.username);
  record.username = account.username;
  record.password = account.password;
  return record;
}

function accountFromSerializable(record: RawAccountCredential): AccountCredential | null {
  if (record.username === undefined || record.password === undefined) {
    return null;
  }

  const displayName = normalizeDisplayName(record.displayName ?? record.username);
  return new AccountCredential(displayName, record.username, record.password);
}

function bucketToSerializable(bucket: UserTaskBucket): RawUserTaskBucket {
  const record = new RawUserTaskBucket();
  record.username = bucket.username;
  record.tasks = bucket.tasks.map((task) => taskToSerializable(task));
  return record;
}

function bucketFromSerializable(record: RawUserTaskBucket): UserTaskBucket | null {
  if (record.username === undefined) {
    return null;
  }

  const rawTasks = record.tasks ?? [];
  const tasks: Task[] = [];
  rawTasks.forEach((rawTask) => {
    const task = taskFromSerializable(rawTask);
    if (task !== null) {
      tasks.push(task);
    }
  });
  return new UserTaskBucket(record.username, tasks);
}

function parseAccountsJson(json: string): AccountCredential[] {
  if (json.length === 0) {
    return [];
  }

  try {
    const parsed = JSON.parse(json) as RawAccountCredential[];
    if (!Array.isArray(parsed)) {
      return [];
    }

    const accounts: AccountCredential[] = [];
    parsed.forEach((item) => {
      const account = accountFromSerializable(item);
      if (account !== null) {
        accounts.push(account);
      }
    });
    return accounts;
  } catch (error) {
    return [];
  }
}

function stringifyAccounts(accounts: AccountCredential[]): string {
  const serializable = accounts.map((account) => accountToSerializable(account));
  return JSON.stringify(serializable);
}

function parseBucketsJson(json: string): UserTaskBucket[] {
  if (json.length === 0) {
    return [];
  }

  try {
    const parsed = JSON.parse(json) as RawUserTaskBucket[];
    if (!Array.isArray(parsed)) {
      return [];
    }

    const buckets: UserTaskBucket[] = [];
    parsed.forEach((item) => {
      const bucket = bucketFromSerializable(item);
      if (bucket !== null) {
        buckets.push(bucket);
      }
    });
    return buckets;
  } catch (error) {
    return [];
  }
}

function stringifyBuckets(buckets: UserTaskBucket[]): string {
  const serializable = buckets.map((bucket) => bucketToSerializable(bucket));
  return JSON.stringify(serializable);
}

class PreferencesStore {
  private static context: common.Context | null = null;
  private static store: preferences.Preferences | null = null;

  static initialize(context: common.Context): void {
    PreferencesStore.context = context;
    if (PreferencesStore.store === null) {
      try {
        PreferencesStore.store = preferences.getPreferencesSync(context, { name: PREFERENCES_NAME });
      } catch (error) {
        PreferencesStore.store = null;
      }
    }
  }

  private static ensureStore(): preferences.Preferences | null {
    if (PreferencesStore.store !== null) {
      return PreferencesStore.store;
    }

    if (PreferencesStore.context === null) {
      return null;
    }

    try {
      PreferencesStore.store = preferences.getPreferencesSync(PreferencesStore.context, { name: PREFERENCES_NAME });
    } catch (error) {
      PreferencesStore.store = null;
    }
    return PreferencesStore.store;
  }

  static getString(key: string): string {
    const store = PreferencesStore.ensureStore();
    if (store === null) {
      return '';
    }

    try {
      const value = store.getSync(key, '') as string;
      return typeof value === 'string' ? value : '';
    } catch (error) {
      return '';
    }
  }

  static setString(key: string, value: string): void {
    const store = PreferencesStore.ensureStore();
    if (store === null) {
      return;
    }

    try {
      store.putSync(key, value);
      void store.flush().catch((): void => {});
    } catch (error) {
    }
  }
}

export class UserSessionRepository {
  static initialize(context: common.Context): void {
    PreferencesStore.initialize(context);
    const currentUser = PreferencesStore.getString(CURRENT_USER_KEY);
    if (currentUser.length === 0) {
      const legacyUser = AppStorage.get<string>(CURRENT_USER_KEY) ?? '';
      if (legacyUser.length > 0) {
        PreferencesStore.setString(CURRENT_USER_KEY, legacyUser);
      }
    }
  }

  static getCurrentUser(): string {
    const currentUser = PreferencesStore.getString(CURRENT_USER_KEY);
    if (currentUser.length > 0) {
      return currentUser;
    }

    return AppStorage.get<string>(CURRENT_USER_KEY) ?? '';
  }

  static setCurrentUser(user: string): void {
    const normalized = normalizeUsername(user);
    PreferencesStore.setString(CURRENT_USER_KEY, normalized);
    AppStorage.set<string>(CURRENT_USER_KEY, normalized);
  }

  static clear(): void {
    PreferencesStore.setString(CURRENT_USER_KEY, '');
    AppStorage.set<string>(CURRENT_USER_KEY, '');
  }

  static hasActiveSession(): boolean {
    return UserSessionRepository.getCurrentUser().length > 0;
  }
}

export class AccountRepository {
  static initialize(context: common.Context): void {
    PreferencesStore.initialize(context);
    AccountRepository.migrateLegacyAccounts();
  }

  private static migrateLegacyAccounts(): void {
    const currentJson = PreferencesStore.getString(ACCOUNTS_JSON_KEY);
    if (parseAccountsJson(currentJson).length > 0) {
      return;
    }

    const legacyAccounts = AppStorage.get<AccountCredential[]>(LEGACY_ACCOUNTS_KEY) ?? [];
    if (legacyAccounts.length === 0) {
      return;
    }

    AccountRepository.saveAccounts(cloneAccounts(legacyAccounts));
  }

  private static getAccounts(): AccountCredential[] {
    const json = PreferencesStore.getString(ACCOUNTS_JSON_KEY);
    const parsed = parseAccountsJson(json);
    if (parsed.length > 0 || json.length > 0) {
      return cloneAccounts(parsed);
    }

    const legacyAccounts = AppStorage.get<AccountCredential[]>(LEGACY_ACCOUNTS_KEY) ?? [];
    if (legacyAccounts.length === 0) {
      return [];
    }

    const cloned = cloneAccounts(legacyAccounts);
    AccountRepository.saveAccounts(cloned);
    return cloneAccounts(cloned);
  }

  private static saveAccounts(accounts: AccountCredential[]): AccountCredential[] {
    const cloned = cloneAccounts(accounts);
    PreferencesStore.setString(ACCOUNTS_JSON_KEY, stringifyAccounts(cloned));
    AppStorage.set<AccountCredential[]>(LEGACY_ACCOUNTS_KEY, cloned);
    return cloneAccounts(cloned);
  }

  static hasAccount(username: string): boolean {
    const normalized = normalizeUsername(username);
    if (normalized.length === 0) {
      return false;
    }

    return AccountRepository.getAccounts().some((account) => account.username === normalized);
  }

  static register(displayName: string, username: string, password: string): RegisterAccountResult {
    const normalizedDisplayName = normalizeDisplayName(displayName);
    const normalized = normalizeUsername(username);
    if (AccountRepository.hasAccount(normalized)) {
      return RegisterAccountResult.Duplicate;
    }

    const updated = AccountRepository.getAccounts();
    updated.push(new AccountCredential(normalizedDisplayName, normalized, password));
    AccountRepository.saveAccounts(updated);
    return RegisterAccountResult.Success;
  }

  static validate(displayName: string, username: string, password: string): LoginValidationResult {
    const normalizedDisplayName = normalizeDisplayName(displayName);
    const normalized = normalizeUsername(username);
    const account = AccountRepository.getAccounts().find((item) => item.username === normalized);
    if (account === undefined) {
      return LoginValidationResult.AccountNotFound;
    }

    if (account.displayName !== normalizedDisplayName) {
      return LoginValidationResult.DisplayNameMismatch;
    }

    if (account.password !== password) {
      return LoginValidationResult.WrongPassword;
    }

    return LoginValidationResult.Success;
  }

  static getDisplayName(username: string): string {
    const normalized = normalizeUsername(username);
    if (normalized.length === 0) {
      return '';
    }

    const account = AccountRepository.getAccounts().find((item) => item.username === normalized);
    if (account === undefined) {
      return normalized;
    }

    return normalizeDisplayName(account.displayName);
  }
}

export class TaskRepository {
  static initialize(context: common.Context): void {
    PreferencesStore.initialize(context);
    TaskRepository.migrateLegacyTasks();
  }

  private static migrateLegacyTasks(): void {
    const currentJson = PreferencesStore.getString(TASKS_BY_USER_JSON_KEY);
    if (parseBucketsJson(currentJson).length > 0) {
      return;
    }

    const legacyBuckets = AppStorage.get<UserTaskBucket[]>(LEGACY_TASKS_BY_USER_KEY) ?? [];
    if (legacyBuckets.length > 0) {
      TaskRepository.saveBuckets(cloneBuckets(legacyBuckets));
    }
  }

  private static getBuckets(): UserTaskBucket[] {
    const json = PreferencesStore.getString(TASKS_BY_USER_JSON_KEY);
    const parsed = parseBucketsJson(json);
    if (parsed.length > 0 || json.length > 0) {
      return cloneBuckets(parsed);
    }

    const legacyBuckets = AppStorage.get<UserTaskBucket[]>(LEGACY_TASKS_BY_USER_KEY) ?? [];
    if (legacyBuckets.length > 0) {
      const clonedLegacyBuckets = cloneBuckets(legacyBuckets);
      TaskRepository.saveBuckets(clonedLegacyBuckets);
      return cloneBuckets(clonedLegacyBuckets);
    }

    return [];
  }

  private static saveBuckets(buckets: UserTaskBucket[]): UserTaskBucket[] {
    const cloned = cloneBuckets(buckets);
    PreferencesStore.setString(TASKS_BY_USER_JSON_KEY, stringifyBuckets(cloned));
    AppStorage.set<UserTaskBucket[]>(LEGACY_TASKS_BY_USER_KEY, cloned);
    return cloneBuckets(cloned);
  }

  static getTasksForUser(username: string): Task[] {
    const owner = resolveTaskOwner(username);
    if (owner.length === 0) {
      return [];
    }

    const bucket = TaskRepository.getBuckets().find((item) => item.username === owner);
    return bucket === undefined ? [] : cloneTasks(bucket.tasks);
  }

  static saveTasksForUser(username: string, tasks: Task[]): Task[] {
    const owner = resolveTaskOwner(username);
    if (owner.length === 0) {
      return [];
    }

    const nextBuckets = TaskRepository.getBuckets().filter((item) => item.username !== owner);
    nextBuckets.push(new UserTaskBucket(owner, cloneTasks(tasks)));
    TaskRepository.saveBuckets(nextBuckets);
    return cloneTasks(tasks);
  }

  static addTaskForUser(username: string, input: CreateTaskInput): Task[] {
    const currentTasks = TaskRepository.getTasksForUser(username);
    const updated = addTask(currentTasks, input);
    return TaskRepository.saveTasksForUser(username, updated);
  }

  static updateTaskLevelForUser(username: string, taskId: string, level: TaskLevel): Task[] {
    const currentTasks = TaskRepository.getTasksForUser(username);
    const updated = updateTaskLevel(currentTasks, taskId, level);
    return TaskRepository.saveTasksForUser(username, updated);
  }

  static updateTaskForUser(username: string, taskId: string, title: string, level: TaskLevel): Task[] {
    const currentTasks = TaskRepository.getTasksForUser(username);
    const updated = updateTask(currentTasks, taskId, title, level);
    return TaskRepository.saveTasksForUser(username, updated);
  }

  static toggleTaskCompleteForUser(username: string, taskId: string): Task[] {
    const currentTasks = TaskRepository.getTasksForUser(username);
    const updated = toggleTaskComplete(currentTasks, taskId);
    return TaskRepository.saveTasksForUser(username, updated);
  }

  static deleteTaskForUser(username: string, taskId: string): Task[] {
    const currentTasks = TaskRepository.getTasksForUser(username);
    const updated = deleteTaskById(currentTasks, taskId);
    return TaskRepository.saveTasksForUser(username, updated);
  }
}

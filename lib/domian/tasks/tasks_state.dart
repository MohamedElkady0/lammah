part of 'tasks_cubit.dart';

abstract class TasksState extends Equatable {
  const TasksState();

  @override
  List<Object> get props => [];
}

class TasksInitial extends TasksState {}

class TasksLoading extends TasksState {}

class TasksError extends TasksState {
  final String message;
  const TasksError(this.message);

  @override
  List<Object> get props => [message];
}

class PrivateTasksLoaded extends TasksState {
  final List<PrivateTask> tasks;
  const PrivateTasksLoaded(this.tasks);
  @override
  List<Object> get props => [tasks];
}

part of 'story_cubit.dart';

abstract class StoryStates {}

class StoryInitialState extends StoryStates {}

// Picking Media States
class StoryImagePickedSuccessState extends StoryStates {}

class StoryImagePickedErrorState extends StoryStates {}

class StoryVideoPickedSuccessState extends StoryStates {}

class StoryVideoPickedErrorState extends StoryStates {}

// Uploading Story States
class CreateStoryLoadingState extends StoryStates {}

class CreateStorySuccessState extends StoryStates {}

class CreateStoryErrorState extends StoryStates {
  final String error;
  CreateStoryErrorState(this.error);
}

// Get Stories States
class GetStoriesLoadingState extends StoryStates {}

class GetStoriesSuccessState extends StoryStates {}

class GetStoriesErrorState extends StoryStates {
  final String error;
  GetStoriesErrorState(this.error);
}

// Actions States
class DeleteStorySuccessState extends StoryStates {}

class LikeStorySuccessState extends StoryStates {}

class CommentStorySuccessState extends StoryStates {}

class FollowUserSuccessState extends StoryStates {}

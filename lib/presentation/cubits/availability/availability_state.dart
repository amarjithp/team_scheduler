part of 'availability_cubit.dart';

abstract class AvailabilityState extends Equatable {
  const AvailabilityState();
  @override
  List<Object> get props => [];
}

class AvailabilityInitial extends AvailabilityState {}
class AvailabilityLoading extends AvailabilityState {}
class AvailabilityLoaded extends AvailabilityState {
  final List<AvailabilityModel> slots;
  const AvailabilityLoaded(this.slots);
  @override
  List<Object> get props => [slots];
}
class AvailabilityError extends AvailabilityState {
  final String message;
  const AvailabilityError(this.message);
  @override
  List<Object> get props => [message];
}
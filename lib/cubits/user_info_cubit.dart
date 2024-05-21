import '../../app/generalImports.dart';

class ProviderDetailsState {
  ProviderDetailsState(this.providerDetails);

  final ProviderDetails providerDetails;

  ProviderDetailsState copyWith({
    final LocationInformation? locationInformation,
    final UserDetails? userDetails,
    final ProviderInformation? providerInformation,
    final BankInformation? bankInformation,
    final List<WorkingDay>? workingDays,
    final SubscriptionInformation? subscriptionInformation,
  }) {
    return ProviderDetailsState(
      ProviderDetails(
        locationInformation:
            locationInformation ?? providerDetails.locationInformation,
        user: userDetails ?? providerDetails.user,
        providerInformation:
            providerInformation ?? providerDetails.providerInformation,
        bankInformation: bankInformation ?? providerDetails.bankInformation,
        workingDays: workingDays ?? providerDetails.workingDays,
        subscriptionInformation:
            subscriptionInformation ?? providerDetails.subscriptionInformation,
      ),
    );
  }
}

class ProviderDetailsCubit extends Cubit<ProviderDetailsState> {
  ProviderDetailsCubit()
      : super(ProviderDetailsState(ProviderDetails.createEmptyModel()));

  void setUserInfo(ProviderDetails userInfo) {
    emit(ProviderDetailsState(userInfo));
  }

  ProviderDetails get providerDetails => state.providerDetails;

  void updateProviderDetails({
    final LocationInformation? locationInformation,
    final UserDetails? userDetails,
    final ProviderInformation? providerInformation,
    final BankInformation? bankInformation,
    final List<WorkingDay>? workingDays,
    final SubscriptionInformation? subscriptionInformation,
  }) {
    final ProviderDetails providerDetails = ProviderDetails(
      locationInformation:
          locationInformation ?? state.providerDetails.locationInformation,
      user: userDetails ?? state.providerDetails.user,
      providerInformation:
          providerInformation ?? state.providerDetails.providerInformation,
      bankInformation: bankInformation ?? state.providerDetails.bankInformation,
      workingDays: workingDays ?? state.providerDetails.workingDays,
      subscriptionInformation: subscriptionInformation ??
          state.providerDetails.subscriptionInformation,
    );

    HiveUtils.setUserData(providerDetails.toJsonData());
    emit(ProviderDetailsState(providerDetails));
  }
}

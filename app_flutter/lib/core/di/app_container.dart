import '../../data/datasources/auth_local_data_source.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/brigade_service.dart';
import '../../data/datasources/google_maps_service.dart';
import '../../data/datasources/message_service.dart';
import '../../data/datasources/notification_service.dart';
import '../../data/datasources/order_service.dart';
import '../../data/datasources/review_service.dart';
import '../../data/datasources/user_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/brigade_repository_impl.dart';
import '../../data/repositories/maps_repository_impl.dart';
import '../../data/repositories/message_repository_impl.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../data/repositories/review_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../domain/usecases/brigade_usecases.dart';
import '../../domain/usecases/maps_usecases.dart';
import '../../domain/usecases/message_usecases.dart';
import '../../domain/usecases/notification_usecases.dart';
import '../../domain/usecases/order_usecases.dart';
import '../../domain/usecases/review_usecases.dart';
import '../../domain/usecases/user_usecases.dart';

class AppContainer {
  AppContainer._();

  static final AuthRemoteDataSource _authRemote = AuthRemoteDataSource();
  static final AuthLocalDataSource _authLocal = AuthLocalDataSource();
  static final AuthRepositoryImpl _authRepository =
      AuthRepositoryImpl(_authRemote, _authLocal);
  static final AuthUseCases authUseCases = AuthUseCases(_authRepository);

  static final OrderService _orderDataSource = OrderService(_authRepository);
  static final OrderRepositoryImpl _orderRepository =
      OrderRepositoryImpl(_orderDataSource);
  static final OrderUseCases orderUseCases = OrderUseCases(_orderRepository);

  static final UserService _userDataSource = UserService(_authRepository);
  static final UserRepositoryImpl _userRepository =
      UserRepositoryImpl(_userDataSource);
  static final UserUseCases userUseCases = UserUseCases(_userRepository);

  static final BrigadeService _brigadeDataSource =
      BrigadeService(_authRepository);
  static final BrigadeRepositoryImpl _brigadeRepository =
      BrigadeRepositoryImpl(_brigadeDataSource);
  static final BrigadeUseCases brigadeUseCases =
      BrigadeUseCases(_brigadeRepository);

  static final MessageService _messageDataSource =
      MessageService(_authRepository);
  static final MessageRepositoryImpl _messageRepository =
      MessageRepositoryImpl(_messageDataSource);
  static final MessageUseCases messageUseCases =
      MessageUseCases(_messageRepository);

  static final NotificationService _notificationDataSource =
      NotificationService(_authRepository);
  static final NotificationRepositoryImpl _notificationRepository =
      NotificationRepositoryImpl(_notificationDataSource);
  static final NotificationUseCases notificationUseCases =
      NotificationUseCases(_notificationRepository);

  static final ReviewService _reviewDataSource = ReviewService(_authRepository);
  static final ReviewRepositoryImpl _reviewRepository =
      ReviewRepositoryImpl(_reviewDataSource);
  static final ReviewUseCases reviewUseCases = ReviewUseCases(_reviewRepository);

  static final GoogleMapsService _mapsDataSource = GoogleMapsService();
  static final MapsRepositoryImpl _mapsRepository =
      MapsRepositoryImpl(_mapsDataSource);
  static final MapsUseCases mapsUseCases = MapsUseCases(_mapsRepository);
}

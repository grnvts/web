import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

import '../../core/config/app_theme.dart';
import '../screens/create_user_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import 'mockups_gallery.dart';
import 'order_flow_previews.dart';
import 'profile_and_map_previews.dart';
import 'wireframe_screens.dart';

class PreviewCatalogApp extends StatelessWidget {
  const PreviewCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Storybook(
      wrapperBuilder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: const Locale('ru', 'RU'),
          supportedLocales: const [Locale('ru', 'RU'), Locale('en', 'US')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: buildAppTheme(),
          home: Scaffold(
            backgroundColor: const Color(0xFFF1F5F9),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 32,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
      plugins: initializePlugins(
        initialDeviceFrameData: defaultDeviceFrameData,
      ),
      stories: [
        Story(
          name: 'Auth/Login Screen',
          builder: (context) => const LoginScreen(),
        ),
        Story(
          name: 'Auth/Signup Screen',
          builder: (context) => const SignupScreen(),
        ),
        Story(
          name: 'Dashboard/Home - User',
          builder: (context) => HomeScreen(
            roleKey: 'user',
            roleLabel: 'User',
            username: context.knobs.text(
              label: 'Username',
              initial: 'client_ivanov',
            ),
            onPrimaryAction: () {},
          ),
        ),
        Story(
          name: 'Dashboard/Home - Brigadier',
          builder: (context) => HomeScreen(
            roleKey: 'brigadier',
            roleLabel: 'Brigadier',
            username: context.knobs.text(
              label: 'Username',
              initial: 'brigadir_petrov',
            ),
            onPrimaryAction: () {},
          ),
        ),
        Story(
          name: 'Dashboard/Home - Admin',
          builder: (context) => HomeScreen(
            roleKey: 'admin',
            roleLabel: 'Admin',
            username: context.knobs.text(
              label: 'Username',
              initial: 'admin',
            ),
            onPrimaryAction: () {},
          ),
        ),
        Story(
          name: 'Admin/Create User Screen',
          builder: (context) => const CreateUserScreen(),
        ),
        Story(
          name: 'Orders/Admin Orders List',
          builder: (context) => const AdminOrdersPreviewScreen(),
        ),
        Story(
          name: 'Orders/Admin Order Detail',
          builder: (context) => const AdminOrderDetailPreviewScreen(),
        ),
        Story(
          name: 'Orders/User Order Detail',
          builder: (context) => const UserOrderDetailPreviewScreen(),
        ),
        Story(
          name: 'Orders/Notifications',
          builder: (context) => const NotificationsPreviewScreen(),
        ),
        Story(
          name: 'Orders/Chat',
          builder: (context) => const ChatPreviewScreen(),
        ),
        Story(
          name: 'Profile/Profile Preview',
          builder: (context) => const ProfilePreviewScreen(),
        ),
        Story(
          name: 'Maps/Map Widget Preview',
          builder: (context) => const MapWidgetPreviewScreen(),
        ),
        Story(
          name: 'Mockups/Layout Gallery',
          builder: (context) => const MockupsGallery(),
        ),
        Story(
          name: 'Wireframes/Login',
          builder: (context) => const WireframeLoginScreen(),
        ),
        Story(
          name: 'Wireframes/Home',
          builder: (context) => const WireframeHomeScreen(),
        ),
        Story(
          name: 'Wireframes/Orders List',
          builder: (context) => const WireframeOrdersListScreen(),
        ),
        Story(
          name: 'Wireframes/Order Details',
          builder: (context) => const WireframeOrderDetailsScreen(),
        ),
        Story(
          name: 'Wireframes/Profile',
          builder: (context) => const WireframeProfileScreen(),
        ),
        Story(
          name: 'Wireframes/Map Widget',
          builder: (context) => const WireframeMapWidgetScreen(),
        ),
      ],
    );
  }
}

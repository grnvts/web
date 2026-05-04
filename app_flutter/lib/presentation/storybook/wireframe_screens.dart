import 'package:flutter/material.dart';

class WireframeLoginScreen extends StatelessWidget {
  const WireframeLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _WireframePhoneFrame(
      child: Column(
        children: [
          _WireframeTopBar(title: 'Application', actionLabel: 'Menu'),
          SizedBox(height: 28),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 320,
                child: _WireframePanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _WireframeTextBlock(
                        title: 'Authorization',
                        subtitle: 'Sign in to your account',
                      ),
                      SizedBox(height: 24),
                      _WireframeLabel('Username'),
                      SizedBox(height: 8),
                      _WireframeInput(),
                      SizedBox(height: 18),
                      _WireframeLabel('Password'),
                      SizedBox(height: 8),
                      _WireframeInput(),
                      SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _WireframeLink(label: 'Create account'),
                      ),
                      SizedBox(height: 20),
                      _WireframeButton(label: 'Sign in'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WireframeHomeScreen extends StatelessWidget {
  const WireframeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _WireframeDesktopFrame(
      child: Column(
        children: [
          _WireframeTopBar(title: 'Dashboard', actionLabel: 'Profile'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _WireframeHero(),
                  SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _WireframeSection(
                          title: 'Service directions',
                          child: _WireframeChipWrap(
                            labels: [
                              'Orders',
                              'Brigades',
                              'Users',
                              'Notifications',
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: _WireframeSection(
                          title: 'Quick actions',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _WireframeButton(label: 'Create order'),
                              SizedBox(height: 12),
                              _WireframeButton(label: 'Open profile'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WireframeOrdersListScreen extends StatelessWidget {
  const WireframeOrdersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _WireframeDesktopFrame(
      child: Column(
        children: [
          _WireframeTopBar(title: 'Orders list', actionLabel: 'Filters'),
          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _WireframeInput(label: 'Search')),
                    SizedBox(width: 12),
                    SizedBox(width: 180, child: _WireframeInput(label: 'Status')),
                    SizedBox(width: 12),
                    SizedBox(width: 180, child: _WireframeInput(label: 'Sort')),
                  ],
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _WireframeOrderCard(orderNo: 'Order #128')),
                      SizedBox(width: 16),
                      Expanded(child: _WireframeOrderCard(orderNo: 'Order #133')),
                      SizedBox(width: 16),
                      Expanded(child: _WireframeOrderCard(orderNo: 'Order #141')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WireframeOrderDetailsScreen extends StatelessWidget {
  const WireframeOrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _WireframeDesktopFrame(
      child: Column(
        children: [
          _WireframeTopBar(title: 'Order details', actionLabel: 'Back'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _WireframePanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _WireframeTextBlock(
                            title: 'Order #128',
                            subtitle: 'General information',
                          ),
                          SizedBox(height: 18),
                          _WireframeInfoLine(label: 'Client'),
                          SizedBox(height: 12),
                          _WireframeInfoLine(label: 'Address'),
                          SizedBox(height: 12),
                          _WireframeInfoLine(label: 'Status'),
                          SizedBox(height: 12),
                          _WireframeInfoLine(label: 'Brigadier'),
                          SizedBox(height: 22),
                          _WireframeButton(label: 'Update status'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _WireframeSection(
                          title: 'Messages',
                          child: Column(
                            children: [
                              _WireframeMessageBubble(widthFactor: 0.72),
                              SizedBox(height: 12),
                              _WireframeMessageBubble(widthFactor: 0.56),
                              SizedBox(height: 12),
                              _WireframeMessageBubble(widthFactor: 0.8),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        _WireframeSection(
                          title: 'Rating and review',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _WireframeInput(label: 'Comment'),
                              SizedBox(height: 12),
                              _WireframeInfoLine(label: 'Overall rating'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WireframeProfileScreen extends StatelessWidget {
  const WireframeProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _WireframeDesktopFrame(
      child: Column(
        children: [
          _WireframeTopBar(title: 'Profile', actionLabel: 'Edit'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _WireframePanel(
                      child: Column(
                        children: [
                          _WireframeBox(
                            width: 120,
                            height: 120,
                            label: 'Avatar',
                          ),
                          SizedBox(height: 18),
                          _WireframeBox(
                            width: double.infinity,
                            height: 36,
                            label: 'Name',
                          ),
                          SizedBox(height: 12),
                          _WireframeBox(
                            width: double.infinity,
                            height: 32,
                            label: 'Username',
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        _WireframeSection(
                          title: 'Contact info',
                          child: Column(
                            children: [
                              _WireframeInput(label: 'Email'),
                              SizedBox(height: 12),
                              _WireframeInput(label: 'Phone'),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        _WireframeSection(
                          title: 'Personal data',
                          child: Column(
                            children: [
                              _WireframeInput(label: 'Surname'),
                              SizedBox(height: 12),
                              _WireframeInput(label: 'Name'),
                              SizedBox(height: 12),
                              _WireframeInput(label: 'Patronymic'),
                              SizedBox(height: 12),
                              _WireframeInput(label: 'Birth date'),
                              SizedBox(height: 18),
                              _WireframeButton(label: 'Save profile'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WireframeMapWidgetScreen extends StatelessWidget {
  const WireframeMapWidgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _WireframeDesktopFrame(
      child: Column(
        children: [
          _WireframeTopBar(title: 'Map widget', actionLabel: 'Search'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _WireframeSection(
                      title: 'Office data',
                      child: Column(
                        children: [
                          _WireframeInfoLine(label: 'Address'),
                          SizedBox(height: 12),
                          _WireframeInfoLine(label: 'Phone'),
                          SizedBox(height: 12),
                          _WireframeInput(label: 'Destination'),
                          SizedBox(height: 18),
                          _WireframeInfoLine(label: 'Route summary'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    flex: 3,
                    child: _WireframePanel(
                      child: SizedBox.expand(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: _WireframeBox(
                                width: double.infinity,
                                height: double.infinity,
                                label: 'Map canvas',
                              ),
                            ),
                            Positioned(
                              left: 40,
                              top: 50,
                              child: _WireframeBox(
                                width: 82,
                                height: 36,
                                label: 'Office',
                              ),
                            ),
                            Positioned(
                              right: 46,
                              bottom: 60,
                              child: _WireframeBox(
                                width: 82,
                                height: 36,
                                label: 'Client',
                              ),
                            ),
                            Positioned(
                              right: 16,
                              top: 16,
                              child: Column(
                                children: [
                                  _WireframeBox(
                                    width: 40,
                                    height: 40,
                                    label: '+',
                                  ),
                                  SizedBox(height: 8),
                                  _WireframeBox(
                                    width: 40,
                                    height: 40,
                                    label: '-',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WireframeDesktopFrame extends StatelessWidget {
  final Widget child;

  const _WireframeDesktopFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black54),
        color: Colors.white,
      ),
      child: child,
    );
  }
}

class _WireframePhoneFrame extends StatelessWidget {
  final Widget child;

  const _WireframePhoneFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 380,
        height: 760,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black54),
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: child,
        ),
      ),
    );
  }
}

class _WireframeTopBar extends StatelessWidget {
  final String title;
  final String actionLabel;

  const _WireframeTopBar({required this.title, required this.actionLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black54)),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          _WireframeBox(
            width: 84,
            height: 40,
            label: actionLabel,
          ),
        ],
      ),
    );
  }
}

class _WireframeHero extends StatelessWidget {
  const _WireframeHero();

  @override
  Widget build(BuildContext context) {
    return _WireframePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _WireframeTextBlock(
            title: 'Main dashboard',
            subtitle: 'Overview of current tasks and actions',
          ),
          SizedBox(height: 16),
          _WireframeButton(label: 'Primary action'),
        ],
      ),
    );
  }
}

class _WireframeSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _WireframeSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return _WireframePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _WireframePanel extends StatelessWidget {
  final Widget child;

  const _WireframePanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black54),
      ),
      child: child,
    );
  }
}

class _WireframeTextBlock extends StatelessWidget {
  final String title;
  final String subtitle;

  const _WireframeTextBlock({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }
}

class _WireframeInput extends StatelessWidget {
  final String? label;

  const _WireframeInput({this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          _WireframeLabel(label!),
          const SizedBox(height: 8),
        ],
        _WireframeBox(
          width: double.infinity,
          height: 48,
          label: 'Input',
        ),
      ],
    );
  }
}

class _WireframeButton extends StatelessWidget {
  final String label;

  const _WireframeButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return _WireframeBox(
      width: double.infinity,
      height: 50,
      label: label,
    );
  }
}

class _WireframeLink extends StatelessWidget {
  final String label;

  const _WireframeLink({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        decoration: TextDecoration.underline,
        color: Colors.black,
      ),
    );
  }
}

class _WireframeLabel extends StatelessWidget {
  final String label;

  const _WireframeLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }
}

class _WireframeBox extends StatelessWidget {
  final double width;
  final double height;
  final String label;

  const _WireframeBox({
    required this.width,
    required this.height,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black54),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, color: Colors.black),
      ),
    );
  }
}

class _WireframeChipWrap extends StatelessWidget {
  final List<String> labels;

  const _WireframeChipWrap({required this.labels});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: labels
          .map(
            (label) => _WireframeBox(
              width: 120,
              height: 40,
              label: label,
            ),
          )
          .toList(growable: false),
    );
  }
}

class _WireframeOrderCard extends StatelessWidget {
  final String orderNo;

  const _WireframeOrderCard({required this.orderNo});

  @override
  Widget build(BuildContext context) {
    return _WireframePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            orderNo,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          const _WireframeInfoLine(label: 'Client'),
          const SizedBox(height: 12),
          const _WireframeInfoLine(label: 'Address'),
          const SizedBox(height: 12),
          const _WireframeInfoLine(label: 'Status'),
          const SizedBox(height: 18),
          const _WireframeButton(label: 'Open details'),
        ],
      ),
    );
  }
}

class _WireframeInfoLine extends StatelessWidget {
  final String label;

  const _WireframeInfoLine({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        const Expanded(
          child: _WireframeBox(
            width: double.infinity,
            height: 36,
            label: 'Text',
          ),
        ),
      ],
    );
  }
}

class _WireframeMessageBubble extends StatelessWidget {
  final double widthFactor;

  const _WireframeMessageBubble({required this.widthFactor});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: const _WireframeBox(
          width: double.infinity,
          height: 44,
          label: 'Message',
        ),
      ),
    );
  }
}

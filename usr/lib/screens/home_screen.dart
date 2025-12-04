import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isHotspotOn = false;
  
  // Mock data for connected users
  final List<Map<String, dynamic>> _connectedUsers = [
    {'id': 1, 'name': 'Alice iPhone', 'ip': '192.168.1.101', 'data': '1.2 GB', 'blocked': false},
    {'id': 2, 'name': 'Bob Laptop', 'ip': '192.168.1.102', 'data': '450 MB', 'blocked': false},
    {'id': 3, 'name': 'Guest Tablet', 'ip': '192.168.1.103', 'data': '120 MB', 'blocked': true},
  ];

  void _toggleHotspot(bool value) {
    setState(() {
      _isHotspotOn = value;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value ? 'Hotspot enabled' : 'Hotspot disabled'),
        backgroundColor: value ? Colors.green : Colors.grey,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleUserBlock(int index) {
    setState(() {
      _connectedUsers[index]['blocked'] = !_connectedUsers[index]['blocked'];
    });
  }

  void _removeUser(int index) {
    setState(() {
      _connectedUsers.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User disconnected')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive layout: Single column on mobile, Row on desktop
          if (constraints.maxWidth > 800) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _buildHotspotControlCard(),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _buildUserListCard(),
                  ),
                ),
              ],
            );
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHotspotControlCard(),
                  const SizedBox(height: 16),
                  _buildUserListCard(),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildHotspotControlCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              _isHotspotOn ? Icons.wifi_tethering : Icons.wifi_tethering_off,
              size: 80,
              color: _isHotspotOn ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _isHotspotOn ? 'Hotspot Active' : 'Hotspot Inactive',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _isHotspotOn ? Colors.green : Colors.grey,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _isHotspotOn 
                  ? 'Your network is visible to other devices.' 
                  : 'Turn on to share your internet connection.',
              textAlign: TextAlign.center,
              style: Colors.grey[600] != null 
                  ? TextStyle(color: Colors.grey[600]) 
                  : null,
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Enable Hotspot'),
              subtitle: const Text('Allow users to connect'),
              value: _isHotspotOn,
              onChanged: _toggleHotspot,
              secondary: const Icon(Icons.power_settings_new),
              contentPadding: EdgeInsets.zero,
            ),
            if (_isHotspotOn) ...[
              const Divider(),
              const ListTile(
                leading: Icon(Icons.ssid_chart),
                title: Text('Network Name (SSID)'),
                subtitle: Text('My_Secure_Hotspot'),
              ),
              const ListTile(
                leading: Icon(Icons.key),
                title: Text('Password'),
                subtitle: Text('••••••••'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserListCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Connected Users',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Chip(
                  label: Text('${_connectedUsers.length} Devices'),
                  backgroundColor: Colors.blue.shade50,
                  labelStyle: TextStyle(color: Colors.blue.shade700),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_connectedUsers.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Text('No devices connected')),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _connectedUsers.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final user = _connectedUsers[index];
                  final isBlocked = user['blocked'] as bool;
                  
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: isBlocked ? Colors.red.shade100 : Colors.green.shade100,
                      child: Icon(
                        isBlocked ? Icons.block : Icons.smartphone,
                        color: isBlocked ? Colors.red : Colors.green,
                      ),
                    ),
                    title: Text(
                      user['name'],
                      style: TextStyle(
                        decoration: isBlocked ? TextDecoration.lineThrough : null,
                        color: isBlocked ? Colors.grey : null,
                      ),
                    ),
                    subtitle: Text('${user['ip']} • ${user['data']} used'),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'block',
                          child: Row(
                            children: [
                              Icon(
                                isBlocked ? Icons.check_circle : Icons.block,
                                color: isBlocked ? Colors.green : Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(isBlocked ? 'Unblock' : 'Block'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'disconnect',
                          child: Row(
                            children: [
                              Icon(Icons.close, color: Colors.grey, size: 20),
                              const SizedBox(width: 8),
                              Text('Disconnect'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'block') {
                          _toggleUserBlock(index);
                        } else if (value == 'disconnect') {
                          _removeUser(index);
                        }
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

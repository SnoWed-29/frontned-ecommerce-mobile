import 'package:flutter/material.dart';
import 'package:frontned/components/my_list_tile.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              DrawerHeader(
          child: Center(
            child: Icon(
              Icons.shopping_bag,
              size: 72,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ),
        const SizedBox(height: 25),
        MyListTile(
          icon: Icons.home, 
          text: "Shop", 
          onTap: () => Navigator.pop(context),
        ),
         MyListTile(
          icon: Icons.shopping_cart, 
          text: "Cart", 
          onTap: () => {
            Navigator.pop(context),
            Navigator.pushNamed(context, '/cart_page')
          },
        ),

         MyListTile(
          icon: Icons.shopping_cart, 
          text: "Category", 
          onTap: () => {
            Navigator.pop(context),
            Navigator.pushNamed(context, '/category_page')
          },
        ),
            ],
          ),
        // exit
         Padding(
           padding: const EdgeInsets.only(bottom: 25.0),
           child: MyListTile(
            icon: Icons.logout, 
            text: "Exit", 
            onTap: () => {},
                   ),
         )

      ],
      )
    );
  }
}
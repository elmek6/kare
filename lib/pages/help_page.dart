import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class HelpPage extends HookWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pageController = usePageController();
    final currentPage = useState(0);

    void nextPage() {
      if (currentPage.value < 2) {
        currentPage.value++;
        pageController.nextPage(
            duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      }
    }

    void prevPage() {
      if (currentPage.value > 0) {
        currentPage.value--;
        pageController.previousPage(
            duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('How to play?'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {           
            nextPage();
          } else if (details.primaryVelocity! > 0) {            
            prevPage();
          }
        },
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: PageView(
                  controller: pageController,
                  onPageChanged: (index) {
                    currentPage.value = index;
                  },
                  children: [
                    // Page 1
                    const Center(
                      child: Text(
                        'The goal is to fill all the squares.\n\n\n'
                        'Squares you can jump to will be highlighted.\n\n\n'
                        'If you make a mistake, you can go back and forward as much as you want.',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Page 2
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'You can jump horizontally or vertically by leaving 2 spaces in every direction.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Image.asset(
                          'assets/images/t.png',
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                          color: Colors.blueGrey.shade900.withOpacity(0.67),
                          colorBlendMode: BlendMode.color,
                        ),
                        const SizedBox(height: 20),
                        const Text('(moves like + sign)'),
                        const SizedBox(height: 20),
                        const Text(
                          'The state of the skipped square does not matter (it can be empty or filled).\n\n',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    // Page 3
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'You can jump diagonally by leaving 1 space in every possible direction.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Image.asset(
                          'assets/images/x.png',
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                          color: Colors.blueGrey.shade900.withOpacity(0.67),
                          colorBlendMode: BlendMode.color,
                        ),
                        const SizedBox(height: 20),
                        const Text('(moves like x sign)'),
                        const SizedBox(height: 20),
                        const Text(
                          'The state of the skipped square does not matter (it can be empty or filled).\n\n',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final isActive = currentPage.value == index;
            return GestureDetector(
              onTap: () {
                currentPage.value = index;
                pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                width: isActive ? 20 : 16,
                height: isActive ? 20 : 16,
                decoration: BoxDecoration(
                  color: isActive ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

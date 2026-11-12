import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../core/models/iris_models.dart';
import '../core/providers.dart';
import '../core/widgets/iris_art.dart';
import '../services/prediction_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.go(ref.read(localStoreProvider).onboardingDone
            ? '/home'
            : '/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
          body: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
        const IrisArt(size: 112),
        const SizedBox(height: 20),
        Text('J’Iris',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('A little nature, a lot to discover'),
      ])));
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;
  final _titles = [
    'Welcome to J’Iris',
    'Four simple measurements',
    'Meet the species'
  ];
  final _body = [
    'Discover the remarkable flowers of the Iris family with a calm, easy-to-use field guide.',
    'Enter sepal and petal lengths and widths in centimetres. Your entries stay on this device.',
    'Explore Setosa, Versicolor, and Virginica. Connect your own prediction model whenever you are ready.',
  ];
  Future<void> _finish() async {
    await ref.read(localStoreProvider).setOnboardingDone(true);
    if (mounted) context.go('/home');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
          body: SafeArea(
              child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 22),
        child: Column(children: [
          Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: _finish, child: const Text('Skip'))),
          Expanded(
              child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemCount: 3,
                  itemBuilder: (context, i) => LayoutBuilder(
                      builder: (context, constraints) {
                        final artSize = (constraints.maxHeight * 0.42)
                            .clamp(160.0, 270.0)
                            .toDouble();
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IrisArt(
                                size: artSize,
                                variant: i),
                            const SizedBox(height: 36),
                            Text(_titles[i],
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 14),
                            ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 360),
                                child: Text(_body[i],
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                            height: 1.55,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant))),
                          ]);
                      }))),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  3,
                  (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _page == i ? 24 : 8,
                        decoration: BoxDecoration(
                            color: _page == i
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(9)),
                      ))),
          const SizedBox(height: 22),
          PrimaryButton(
              label: _page == 2 ? 'Get started' : 'Next',
              onPressed: () {
                if (_page == 2) {
                  _finish();
                } else {
                  _controller.nextPage(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut);
                }
              }),
        ]),
      )));
}

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;
  @override
  Widget build(BuildContext context) => Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (i) => navigationShell.goBranch(i,
            initialLocation: i == navigationShell.currentIndex),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.biotech_outlined),
              selectedIcon: Icon(Icons.biotech),
              label: 'Classify'),
          NavigationDestination(
              icon: Icon(Icons.history_rounded), label: 'History'),
          NavigationDestination(
              icon: Icon(Icons.local_florist_outlined),
              selectedIcon: Icon(Icons.local_florist),
              label: 'Explore'),
        ],
      ));
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: const Text('J’Iris',
                style: TextStyle(fontWeight: FontWeight.w800)),
            actions: [
              IconButton(
                  tooltip: 'Settings',
                  onPressed: () => context.push('/settings'),
                  icon: const Icon(Icons.tune_rounded))
            ]),
        body: SafeArea(
            child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
              Text('A small flower,\na whole world.',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800, height: 1.12)),
              const SizedBox(height: 18),
              const _HomeHero(),
              const SizedBox(height: 28),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Meet the Iris family',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800)),
                TextButton(
                    onPressed: () => context.go('/explore'),
                    child: const Text('Explore all'))
              ]),
              const SizedBox(height: 10),
              ...speciesData.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SpeciesMiniCard(data: s))),
              const SizedBox(height: 8),
              Card(
                  child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.history)),
                      title: const Text('Your saved discoveries'),
                      subtitle: const Text('Review previous classifications'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.go('/history'))),
            ])),
      );
}

class _HomeHero extends StatelessWidget {
  const _HomeHero();
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
              colors: [Color(0xFFE8F5E9), Color(0xFFF0EAF8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Center(child: IrisArt(size: 148)),
        const SizedBox(height: 15),
        Text('Curious about a flower?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800, color: const Color(0xFF263238))),
        const SizedBox(height: 7),
        const Text(
            'Record four measurements, explore the species guide, and connect a real classifier when you’re ready.',
            style: TextStyle(height: 1.45, color: Color(0xFF455A50))),
        const SizedBox(height: 18),
        PrimaryButton(
            label: 'Classify a flower',
            icon: Icons.arrow_forward_rounded,
            onPressed: () => context.go('/classify')),
      ]));
}

class ClassificationScreen extends ConsumerStatefulWidget {
  const ClassificationScreen({super.key});
  @override
  ConsumerState<ClassificationScreen> createState() =>
      _ClassificationScreenState();
}

class _ClassificationScreenState extends ConsumerState<ClassificationScreen> {
  final _form = GlobalKey<FormState>();
  final _controllers = List.generate(4, (_) => TextEditingController());
  bool _busy = false;
  final _fields = const [
    ('Sepal length', 'Long side of the outer leaf-like part'),
    ('Sepal width', 'Width of the outer part'),
    ('Petal length', 'Length of the inner petal'),
    ('Petal width', 'Width of the inner petal'),
  ];
  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  double? _parse(String value) {
    final n = double.tryParse(value.trim());
    return n != null && n.isFinite && n > 0 ? n : null;
  }

  String? _validate(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter a measurement';
    if (_parse(value) == null) return 'Use a number greater than zero';
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_busy || !(_form.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    final values = _controllers.map((c) => _parse(c.text)!).toList();
    final m = Measurements(
        sepalLength: values[0],
        sepalWidth: values[1],
        petalLength: values[2],
        petalWidth: values[3]);
    try {
      final prediction = await ref
          .read(predictionServiceProvider)
          .predict(PredictionRequest(m));
      if (mounted) {
        context.push('/result',
            extra: ResultPayload(measurements: m, prediction: prediction));
      }
    } on PredictionUnavailableException catch (e) {
      if (mounted) {
        context.push('/result',
            extra: ResultPayload(measurements: m, error: e.message));
      }
    } catch (_) {
      if (mounted) {
        context.push('/result',
            extra: ResultPayload(
                measurements: m,
                error:
                    'The prediction service could not process this request.'));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _reset() {
    _form.currentState?.reset();
    for (final c in _controllers) {
      c.clear();
    }
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: const Text('Classify a flower',
                style: TextStyle(fontWeight: FontWeight.w800)),
            actions: [
              IconButton(
                  tooltip: 'Settings',
                  onPressed: () => context.push('/settings'),
                  icon: const Icon(Icons.tune_rounded))
            ]),
        body: SafeArea(
            child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                child: Center(
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Form(
                            key: _form,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      padding: const EdgeInsets.all(18),
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondaryContainer
                                              .withValues(alpha: 0.45),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Row(children: [
                                        Icon(Icons.straighten_rounded,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            size: 28),
                                        const SizedBox(width: 14),
                                        const Expanded(
                                            child: Text(
                                                'Measure in centimetres. Every field is required; no sample data is prefilled.',
                                                style: TextStyle(height: 1.4)))
                                      ])),
                                  const SizedBox(height: 24),
                                  Text('Flower measurements',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 5),
                                  Text(
                                      'Enter the four dimensions to prepare a prediction request.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant)),
                                  const SizedBox(height: 18),
                                  ...List.generate(
                                      4,
                                      (i) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 15),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(_fields[i].$1,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700)),
                                                const SizedBox(height: 7),
                                                TextFormField(
                                                    controller: _controllers[i],
                                                    keyboardType:
                                                        const TextInputType
                                                            .numberWithOptions(
                                                            decimal: true,
                                                            signed: false),
                                                    textInputAction: i == 3
                                                        ? TextInputAction.done
                                                        : TextInputAction.next,
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter
                                                          .allow(
                                                              RegExp(r'[0-9.]'))
                                                    ],
                                                    validator: _validate,
                                                    onFieldSubmitted: (_) {
                                                      if (i == 3) _submit();
                                                    },
                                                    decoration:
                                                        const InputDecoration(
                                                            hintText:
                                                                'e.g. 5.1',
                                                            suffixText: 'cm',
                                                            errorMaxLines: 2)),
                                                const SizedBox(height: 5),
                                                Text(_fields[i].$2,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onSurfaceVariant)),
                                              ]))),
                                  PrimaryButton(
                                      label: 'Predict species',
                                      icon: Icons.auto_awesome,
                                      busy: _busy,
                                      onPressed: _submit),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                      width: double.infinity,
                                      child: TextButton.icon(
                                          onPressed: _busy ? null : _reset,
                                          icon: const Icon(Icons.restart_alt),
                                          label: const Text('Reset form'))),
                                  const SizedBox(height: 12),
                                  const _InfoNote(
                                      text:
                                          'Classification is unavailable until a prediction service is connected. Your measurements are not sent anywhere by this app.'),
                                ])))))),
      );
}

class SpeciesInfo {
  const SpeciesInfo(
      {required this.id,
      required this.name,
      required this.summary,
      required this.description,
      required this.traits,
      required this.habitat,
      required this.variant});
  final String id, name, summary, description, traits, habitat;
  final int variant;
}

const speciesData = <SpeciesInfo>[
  SpeciesInfo(
      id: 'setosa',
      name: 'Iris setosa',
      summary: 'The bristly, compact Iris',
      description:
          'A hardy, rhizomatous perennial known for its distinctive, highly divided petals and sepals. Its flowers are commonly violet-blue, though colour varies.',
      traits:
          'Typically shorter plants with smaller flowers; the standards and falls are strongly fringed. The species is notably cold-hardy.',
      habitat:
          'Native across northern temperate regions, often growing in wet meadows, marsh edges, and coastal habitats.',
      variant: 0),
  SpeciesInfo(
      id: 'versicolor',
      name: 'Iris versicolor',
      summary: 'The colourful northern blue flag',
      description:
          'A beardless wild iris with showy blue-violet flowers, often marked with pale areas and yellow veining on the falls.',
      traits:
          'Usually bears several flowers on a branching stem. Its name refers to the varied colours found across its flowers.',
      habitat:
          'Native to eastern North America; commonly found in wetlands, marshes, and along pond or stream margins.',
      variant: 1),
  SpeciesInfo(
      id: 'virginica',
      name: 'Iris virginica',
      summary: 'A graceful wetland native',
      description:
          'A beardless iris with elegant flowers ranging from blue-violet to purple. The petals are generally less fringed than those of I. setosa.',
      traits:
          'Often taller and larger-flowered than I. setosa, with sword-shaped leaves and a branching flower stalk.',
      habitat:
          'Occurs in eastern and central North America, especially in wet meadows, swamps, and shallow freshwater margins.',
      variant: 2),
];
SpeciesInfo speciesById(String id) => speciesData.firstWhere(
    (s) => s.id == id.toLowerCase(),
    orElse: () => const SpeciesInfo(
        id: 'unknown',
        name: 'Iris species',
        summary: 'Species information unavailable',
        description: 'No species details are available for this identifier.',
        traits: 'Not available.',
        habitat: 'Not available.',
        variant: 0));

class SpeciesMiniCard extends StatelessWidget {
  const SpeciesMiniCard({super.key, required this.data});
  final SpeciesInfo data;
  @override
  Widget build(BuildContext context) => Card(
      child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => context.push('/species/${data.id}'),
          child: Padding(
              padding: const EdgeInsets.all(13),
              child: LayoutBuilder(builder: (context, constraints) {
                final artwork = IrisArt(
                    size: 72,
                    variant: data.variant,
                    background:
                        Theme.of(context).colorScheme.surfaceContainerHighest);
                final description = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(data.summary,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant))
                    ]);
                if (constraints.maxWidth < 180) {
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        artwork,
                        const SizedBox(height: 10),
                        description,
                        const Align(
                            alignment: Alignment.centerRight,
                            child: Icon(Icons.chevron_right_rounded))
                      ]);
                }
                return Row(children: [
                  artwork,
                  const SizedBox(width: 14),
                  Expanded(child: description),
                  const Icon(Icons.chevron_right_rounded),
                ]);
              }))));
}

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          title: const Text('Explore Iris',
              style: TextStyle(fontWeight: FontWeight.w800)),
          actions: [
            IconButton(
                tooltip: 'Settings',
                onPressed: () => context.push('/settings'),
                icon: const Icon(Icons.tune_rounded))
          ]),
      body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Text('Three species, countless details.',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 7),
            Text(
                'A pocket field guide to the Iris species in the classic measurement dataset.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 20),
            ...speciesData.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 13),
                child: SpeciesMiniCard(data: s))),
            const _InfoNote(
                text:
                      'Photographs are credited in Settings > Licenses & acknowledgements. Descriptions are general species summaries; traits vary by location and cultivar.'),
          ]));
}

class SpeciesDetailScreen extends StatelessWidget {
  const SpeciesDetailScreen({super.key, required this.speciesId});
  final String speciesId;
  @override
  Widget build(BuildContext context) {
    final s = speciesById(speciesId);
    return Scaffold(
        appBar: AppBar(
            title: Text(s.name,
                style: const TextStyle(fontWeight: FontWeight.w800))),
        body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
            children: [
              Center(
                  child: IrisArt(
                      size: 220,
                      variant: s.variant,
                      background: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest)),
              const SizedBox(height: 24),
              Text(s.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(s.summary,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.primary)),
              const SizedBox(height: 18),
              Text(s.description,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(height: 1.6)),
              const SizedBox(height: 22),
              _DetailSection(
                  title: 'Distinguishing characteristics',
                  icon: Icons.spa_outlined,
                  text: s.traits),
              const SizedBox(height: 12),
              _DetailSection(
                  title: 'Habitat',
                  icon: Icons.landscape_outlined,
                  text: s.habitat),
              const SizedBox(height: 12),
              const _DetailSection(
                  title: 'Botanical note',
                  icon: Icons.menu_book_outlined,
                  text:
                      'Iris is a genus of flowering plants in the family Iridaceae. Individual flower colour and measurements can vary substantially within a species.'),
            ]));
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection(
      {required this.title, required this.text, required this.icon});
  final String title, text;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(17),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 9),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800))
            ]),
            const SizedBox(height: 10),
            Text(text, style: const TextStyle(height: 1.5)),
          ])));
}

class ResultPayload {
  const ResultPayload(
      {required this.measurements,
      this.prediction,
      this.error,
      this.recordedAt,
      this.historyRecord});
  final Measurements measurements;
  final PredictionResponse? prediction;
  final String? error;
  final DateTime? recordedAt;
  final HistoryRecord? historyRecord;
}

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key, required this.payload});
  final ResultPayload payload;
  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  bool _saved = false;
  Measurements get _m => widget.payload.measurements;
  @override
  Widget build(BuildContext context) {
    final prediction = widget.payload.prediction;
    final species = prediction == null
        ? speciesById('unknown')
        : speciesById(prediction.species);
    final when = widget.payload.recordedAt ?? DateTime.now();
    return Scaffold(
        appBar: AppBar(
            title: const Text('Classification result',
                style: TextStyle(fontWeight: FontWeight.w800))),
        body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              if (prediction != null) ...[
                Center(child: IrisArt(size: 190, variant: species.variant)),
                const SizedBox(height: 15),
                Center(
                    child: Text(species.name,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontStyle: FontStyle.italic))),
                const SizedBox(height: 8),
                Center(
                    child: Text(species.summary,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge)),
                if (prediction.confidence != null)
                  Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Center(
                          child: Chip(
                              avatar: const Icon(Icons.verified_outlined),
                              label: Text(
                                  'Confidence ${(prediction.confidence! * 100).toStringAsFixed(1)}%')))),
                if (prediction.probabilities != null) ...[
                  const SizedBox(height: 18),
                  Text('Class probabilities',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  ...prediction.probabilities!.entries.map((e) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(speciesTitle(e.key)),
                      trailing:
                          Text('${(e.value * 100).toStringAsFixed(1)}%'))),
                ],
                const SizedBox(height: 12),
                Text(species.description, style: const TextStyle(height: 1.5)),
                const SizedBox(height: 18),
              ] else ...[
                Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .secondaryContainer
                            .withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(24)),
                    child: Column(children: [
                      const Icon(Icons.link_off_rounded, size: 46),
                      const SizedBox(height: 13),
                      Text('Prediction service not connected',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text(
                          widget.payload.error ??
                              'Your measurements are ready, but a real model must be connected before a species can be classified.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(height: 1.5)),
                    ])),
                const SizedBox(height: 20),
              ],
              Card(
                  child: Padding(
                      padding: const EdgeInsets.all(17),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Your measurements',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 10),
                            _MeasurementLine(
                                label: 'Sepal length', value: _m.sepalLength),
                            _MeasurementLine(
                                label: 'Sepal width', value: _m.sepalWidth),
                            _MeasurementLine(
                                label: 'Petal length', value: _m.petalLength),
                            _MeasurementLine(
                                label: 'Petal width', value: _m.petalWidth),
                            const Divider(height: 24),
                            Text('Recorded ${_dateTime(when)}',
                                style: Theme.of(context).textTheme.bodySmall),
                          ]))),
              const SizedBox(height: 16),
              if (prediction != null && widget.payload.historyRecord == null)
                PrimaryButton(
                    label: _saved ? 'Saved to history' : 'Save result',
                    icon: _saved
                        ? Icons.check_circle_outline
                        : Icons.bookmark_add_outlined,
                    onPressed: _saved
                        ? null
                        : () async {
                            final p = prediction;
                            final record = HistoryRecord(
                                id: DateTime.now()
                                    .microsecondsSinceEpoch
                                    .toString(),
                                species: p.species,
                                measurements: _m,
                                createdAt: when,
                                confidence: p.confidence,
                                probabilities: p.probabilities);
                            await ref
                                .read(historyProvider.notifier)
                                .save(record);
                            if (mounted) setState(() => _saved = true);
                          }),
              if (prediction != null) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                    onPressed: () =>
                        context.push('/species/${prediction.species}'),
                    icon: const Icon(Icons.local_florist_outlined),
                    label: const Text('View species details')),
                const SizedBox(height: 9),
                OutlinedButton.icon(
                    onPressed: () => Share.share(
                        'Iris classification: ${species.name}. Measurements (cm): sepal ${_m.sepalLength} × ${_m.sepalWidth}, petal ${_m.petalLength} × ${_m.petalWidth}.'),
                    icon: const Icon(Icons.ios_share_rounded),
                    label: const Text('Share result')),
              ],
              const SizedBox(height: 12),
              PrimaryButton(
                  label: 'Classify another flower',
                  icon: Icons.add,
                  onPressed: () => context.go('/classify')),
            ]));
  }
}

class _MeasurementLine extends StatelessWidget {
  const _MeasurementLine({required this.label, required this.value});
  final String label;
  final double value;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label),
        Text('${value.toStringAsFixed(1)} cm',
            style: const TextStyle(fontWeight: FontWeight.w700))
      ]));
}

String _dateTime(DateTime d) {
  final local = d.toLocal();
  final month = local.month.toString().padLeft(2, '0'),
      day = local.day.toString().padLeft(2, '0'),
      hour = local.hour.toString().padLeft(2, '0'),
      minute = local.minute.toString().padLeft(2, '0');
  return '${local.year}-$month-$day at $hour:$minute';
}

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});
  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _search = TextEditingController();
  String _filter = 'all';
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _delete(HistoryRecord r) async {
    final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Delete this result?'),
                content: const Text(
                    'This saved record will be removed from this device.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'))
                ]));
    if (ok == true) await ref.read(historyProvider.notifier).delete(r.id);
  }

  Future<void> _clear() async {
    final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Clear all history?'),
                content: const Text(
                    'This permanently removes every saved classification on this device.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Keep history')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Clear all'))
                ]));
    if (ok == true) await ref.read(historyProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final records = ref.watch(historyProvider);
    final query = _search.text.trim().toLowerCase();
    final filtered = records
        .where((r) =>
            (_filter == 'all' || r.species == _filter) &&
            (query.isEmpty ||
                speciesTitle(r.species).toLowerCase().contains(query)))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your history',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          if (records.isNotEmpty)
            IconButton(
                tooltip: 'Clear history',
                onPressed: _clear,
                icon: const Icon(Icons.delete_sweep_outlined)),
          IconButton(
              tooltip: 'Settings',
              onPressed: () => context.push('/settings'),
              icon: const Icon(Icons.tune_rounded)),
        ],
      ),
      body: records.isEmpty
          ? const _EmptyHistory()
          : Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
                child: TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search saved species',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _search.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close)),
                  ),
                ),
              ),
              SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      ('all', 'All'),
                      ('setosa', 'Setosa'),
                      ('versicolor', 'Versicolor'),
                      ('virginica', 'Virginica')
                    ]
                        .map((entry) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text(entry.$2),
                              selected: _filter == entry.$1,
                              onSelected: (_) =>
                                  setState(() => _filter = entry.$1),
                            )))
                        .toList(),
                  )),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text('No saved results match your search.'))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final record = filtered[i];
                          final species = speciesById(record.species);
                          return Card(
                              child: ListTile(
                            contentPadding:
                                const EdgeInsets.fromLTRB(12, 8, 6, 8),
                            leading: IrisArt(
                                size: 54,
                                variant: species.variant,
                                background: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest),
                            title: Text(species.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800)),
                            subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '${_dateTime(record.createdAt)}\nSepal ${record.measurements.sepalLength.toStringAsFixed(1)} × ${record.measurements.sepalWidth.toStringAsFixed(1)} · Petal ${record.measurements.petalLength.toStringAsFixed(1)} × ${record.measurements.petalWidth.toStringAsFixed(1)} cm',
                                  maxLines: 3,
                                )),
                            isThreeLine: true,
                            onTap: () => context.push('/result',
                                extra: ResultPayload(
                                  measurements: record.measurements,
                                  prediction: PredictionResponse(
                                      species: record.species,
                                      confidence: record.confidence,
                                      probabilities: record.probabilities),
                                  recordedAt: record.createdAt,
                                  historyRecord: record,
                                )),
                            trailing: IconButton(
                                tooltip: 'Delete result',
                                onPressed: () => _delete(record),
                                icon: const Icon(Icons.delete_outline)),
                          ));
                        },
                      ),
              ),
            ]),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const IrisArt(size: 142, background: Color(0xFFE8F5E9)),
            const SizedBox(height: 22),
            Text('Your discoveries live here',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
                'Saved classifications will appear here. Nothing is added until a real prediction is available and you choose to save it.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 20),
            OutlinedButton.icon(
                onPressed: () => context.go('/classify'),
                icon: const Icon(Icons.biotech_outlined),
                label: const Text('Enter measurements'))
          ])));
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  Future<void> _clear(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Clear all history?'),
                content: const Text(
                    'Saved classification records will be deleted from this device.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Clear history'))
                ]));
    if (ok == true) {
      await ref.read(historyProvider.notifier).clear();
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('History cleared')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return Scaffold(
        appBar: AppBar(
            title: const Text('Settings',
                style: TextStyle(fontWeight: FontWeight.w800))),
        body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
            children: [
              Text('Appearance',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Card(
                  child: RadioGroup<ThemeMode>(
                      groupValue: mode,
                      onChanged: (value) {
                        if (value != null) {
                          ref.read(themeModeProvider.notifier).set(value);
                        }
                      },
                      child: Column(children: [
                        for (final item in [
                          (
                            ThemeMode.system,
                            'System default',
                            Icons.settings_suggest_outlined
                          ),
                          (ThemeMode.light, 'Light', Icons.light_mode_outlined),
                          (ThemeMode.dark, 'Dark', Icons.dark_mode_outlined)
                        ])
                          RadioListTile<ThemeMode>(
                              value: item.$1,
                              title: Text(item.$2),
                              secondary: Icon(item.$3))
                      ]))),
              const SizedBox(height: 24),
              Text('Your data',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Card(
                  child: Column(children: [
                ListTile(
                    leading: const Icon(Icons.delete_outline),
                    title: const Text('Clear classification history'),
                    subtitle:
                        const Text('Remove saved results from this device'),
                    onTap: () => _clear(context, ref)),
                const Divider(height: 1),
                ListTile(
                    leading: const Icon(Icons.replay_outlined),
                    title: const Text('Replay onboarding'),
                    onTap: () async {
                      await ref
                          .read(localStoreProvider)
                          .setOnboardingDone(false);
                      if (context.mounted) context.go('/onboarding');
                    })
              ])),
              const SizedBox(height: 24),
              Text('About',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Card(
                  child: Column(children: [
                ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('About J’Iris'),
                    subtitle: const Text(
                        'A field guide and model-ready measurement tool'),
                    onTap: () => showAboutDialog(
                        context: context,
                        applicationName: 'J’Iris',
                        applicationVersion: '1.0.0',
                        applicationLegalese:
                            'Educational companion. No classification model is bundled.')),
                const Divider(height: 1),
                ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: const Text('Privacy'),
                    subtitle: const Text(
                        'Your settings and saved results stay on this device.'),
                    onTap: () => showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                                title: const Text('Privacy information'),
                                content: const Text(
                                    'J’Iris stores onboarding status, theme preference, and any saved result records locally using device preferences. This version has no account, analytics, or connected prediction endpoint. When you configure a remote prediction service, measurements will be sent to the base URL you provide; review that service’s privacy terms.'),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Done'))
                                ]))),
                const Divider(height: 1),
                ListTile(
                    leading: const Icon(Icons.article_outlined),
                    title: const Text('Licenses & acknowledgements'),
                    onTap: () => showLicensePage(
                        context: context,
                        applicationName: 'J’Iris',
                        applicationVersion: '1.0.0'))
              ])),
              const SizedBox(height: 16),
              const _InfoNote(
                  text:
                      'Botanical photographs are bundled locally and credited in Licenses & acknowledgements. The classification service is intentionally disconnected until you supply a real model or API.')
            ]));
  }
}

class _InfoNote extends StatelessWidget {
  const _InfoNote({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.info_outline,
            size: 19, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(height: 1.45)))
      ]));
}

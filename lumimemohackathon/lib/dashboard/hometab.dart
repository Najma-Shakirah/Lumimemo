import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';
import 'dashboard_viewmodel.dart';
import 'widget.dart';

// ── Home Tab ──────────────────────────────────────────────────────────────────
class HomeTab extends StatelessWidget {
  final DashboardViewModel vm;
  const HomeTab({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TopBar(vm: vm),
          HeroBanner(vm: vm),
          const SectionTitle('Address Book'),
          AddressSection(vm: vm),
          const SectionTitle('Medicines Today'),
          MedicineSection(vm: vm),
          const SectionTitle('Memories'),
          MemoriesCarousel(vm: vm),
          const SectionTitle('Tasks'),
          TasksSection(vm: vm),
          const SectionTitle('Daily Checklist'),
          ChecklistSection(vm: vm),
          const SectionTitle('Contacts'),
          ContactSection(vm: vm),
          const SectionTitle('Reminders'),
          RemindersSection(vm: vm),
        ]),
      ),
    );
  }
}

// ── Top Bar ───────────────────────────────────────────────────────────────────
class TopBar extends StatelessWidget {
  final DashboardViewModel vm;
  const TopBar({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: C.brownMid, shape: BoxShape.circle,
            border: Border.all(color: C.white, width: 2),
          ),
          child: Center(
            child: Text(vm.user?.initial ?? 'A',
                style: GoogleFonts.poppins(color: C.white, fontSize: 18, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(vm.greeting, style: GoogleFonts.poppins(color: C.textGrey, fontSize: 12)),
          Text(vm.user?.displayName ?? 'Friend',
              style: GoogleFonts.poppins(color: C.textDark, fontSize: 15, fontWeight: FontWeight.w600)),
        ])),
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: C.white, shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
          ),
          child: const Icon(Icons.notifications_outlined, color: C.textDark, size: 20),
        ),
      ]),
    );
  }
}

// ── Hero Banner ───────────────────────────────────────────────────────────────
class HeroBanner extends StatelessWidget {
  final DashboardViewModel vm;
  const HeroBanner({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Container(
        height: 155,
        decoration: BoxDecoration(color: C.heroBg, borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.hardEdge,
        child: Stack(children: [
          Positioned(right: -20, top: -20,
              child: Container(width: 130, height: 130,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), shape: BoxShape.circle))),
          Positioned(right: 30, bottom: -30,
              child: Container(width: 100, height: 100,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle))),
          Positioned(right: 16, top: 16,
              child: Icon(Icons.health_and_safety_outlined, color: Colors.white.withOpacity(0.18), size: 80)),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Your Health,', style: GoogleFonts.poppins(
                      color: C.white, fontSize: 19, fontWeight: FontWeight.w700, height: 1.2)),
                  Text('Our Priority', style: GoogleFonts.poppins(
                      color: C.white.withOpacity(0.88), fontSize: 19, fontWeight: FontWeight.w700, height: 1.2)),
                  const SizedBox(height: 5),
                  Text('Manage your health journey with ease',
                      style: GoogleFonts.poppins(color: C.white.withOpacity(0.7), fontSize: 11)),
                ]),
                Row(children: [
                  HeroPill(label: '${vm.medicines.length} Meds',      icon: Icons.medication_outlined),
                  const SizedBox(width: 8),
                  HeroPill(label: '${vm.reminders.length} Reminders', icon: Icons.alarm_outlined),
                ]),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Address Book ───────────────────────────────────────────────────────────
class AddressSection extends StatelessWidget {
  final DashboardViewModel vm;
  const AddressSection({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: vm.addresses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final a = vm.addresses[i];
          return Container(
            width: 132,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: C.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(color: a.color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(a.icon, color: a.color, size: 18),
              ),
              const SizedBox(height: 8),
              Text(a.label, style: GoogleFonts.poppins(color: C.textDark, fontSize: 12, fontWeight: FontWeight.w600)),
              Text(a.address, style: GoogleFonts.poppins(color: C.textGrey, fontSize: 9),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            ]),
          );
        },
      ),
    );
  }
}

// ── Medicine Section ──────────────────────────────────────────────────────────
class MedicineSection extends StatelessWidget {
  final DashboardViewModel vm;
  const MedicineSection({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: vm.medicines.map((m) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: C.white, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
          ),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: m.color.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(Icons.medication_outlined, color: m.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.name, style: GoogleFonts.poppins(color: C.textDark, fontSize: 13, fontWeight: FontWeight.w600)),
              Text(m.dose, style: GoogleFonts.poppins(color: C.textGrey, fontSize: 11)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: m.color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(m.time, style: GoogleFonts.poppins(color: m.color, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
      )).toList(),
    );
  }
}

// ── Memories Carousel ─────────────────────────────────────────────────────────
class MemoriesCarousel extends StatefulWidget {
  final DashboardViewModel vm;
  const MemoriesCarousel({super.key, required this.vm});

  @override
  State<MemoriesCarousel> createState() => _MemoriesCarouselState();
}

class _MemoriesCarouselState extends State<MemoriesCarousel> {
  final PageController _pc = PageController(viewportFraction: 0.72);
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final mems = widget.vm.memories;
    return Column(children: [
      SizedBox(
        height: 158,
        child: PageView.builder(
          controller: _pc,
          itemCount: mems.length,
          onPageChanged: (i) => setState(() => _current = i),
          itemBuilder: (_, i) {
            final m = mems[i];
            final active = i == _current;
            return AnimatedScale(
              scale: active ? 1.0 : 0.92,
              duration: const Duration(milliseconds: 300),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Container(
                  decoration: BoxDecoration(
                    color: m.color,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: active
                        ? [BoxShadow(color: m.color.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))]
                        : [],
                  ),
                  child: Stack(children: [
                    Positioned(right: -18, bottom: -18,
                        child: Icon(m.icon, color: Colors.white.withOpacity(0.12), size: 100)),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(m.icon, color: C.white, size: 26),
                          const SizedBox(height: 8),
                          Text(m.title, style: GoogleFonts.poppins(
                              color: C.white, fontSize: 16, fontWeight: FontWeight.w700)),
                          Text(m.date, style: GoogleFonts.poppins(color: C.white.withOpacity(0.78), fontSize: 12)),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(mems.length, (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: _current == i ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: _current == i ? C.brown : C.brownMid.withOpacity(0.3),
            borderRadius: BorderRadius.circular(3),
          ),
        )),
      ),
    ]);
  }
}

// ── Tasks Section ─────────────────────────────────────────────────────────────
class TasksSection extends StatelessWidget {
  final DashboardViewModel vm;
  const TasksSection({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: C.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
        ),
        child: Column(children: List.generate(vm.tasks.length, (i) {
          final t = vm.tasks[i];
          return InkWell(
            onTap: () => vm.toggleTask(i),
            borderRadius: i == 0
                ? const BorderRadius.vertical(top: Radius.circular(16))
                : i == vm.tasks.length - 1
                    ? const BorderRadius.vertical(bottom: Radius.circular(16))
                    : BorderRadius.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    color: t.isDone ? C.teal : Colors.transparent,
                    border: Border.all(
                        color: t.isDone ? C.teal : C.textGrey.withOpacity(0.35), width: 1.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: t.isDone ? const Icon(Icons.check_rounded, color: C.white, size: 14) : null,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(t.title, style: GoogleFonts.poppins(
                  color: t.isDone ? C.textGrey : C.textDark, fontSize: 13,
                  decoration: t.isDone ? TextDecoration.lineThrough : null,
                ))),
              ]),
            ),
          );
        })),
      ),
    );
  }
}

// ── Checklist Section ─────────────────────────────────────────────────────────
class ChecklistSection extends StatelessWidget {
  final DashboardViewModel vm;
  const ChecklistSection({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final done  = vm.checklists.where((c) => c.isDone).length;
    final total = vm.checklists.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: C.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('$done / $total completed',
                    style: GoogleFonts.poppins(color: C.textGrey, fontSize: 12)),
                Text('${(done / total * 100).round()}%',
                    style: GoogleFonts.poppins(color: C.teal, fontSize: 12, fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: done / total,
                  backgroundColor: C.teal.withOpacity(0.1),
                  color: C.teal,
                  minHeight: 6,
                ),
              ),
            ]),
          ),
          ...List.generate(vm.checklists.length, (i) {
            final c = vm.checklists[i];
            return InkWell(
              onTap: () => vm.toggleChecklist(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(children: [
                  Icon(c.isDone ? Icons.check_circle_rounded : Icons.circle_outlined,
                      color: c.isDone ? C.teal : C.textGrey.withOpacity(0.4), size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(c.title, style: GoogleFonts.poppins(
                    color: c.isDone ? C.textGrey : C.textDark, fontSize: 13,
                    decoration: c.isDone ? TextDecoration.lineThrough : null,
                  ))),
                ]),
              ),
            );
          }),
          const SizedBox(height: 4),
        ]),
      ),
    );
  }
}

// ── Contact Section ───────────────────────────────────────────────────────────
class ContactSection extends StatelessWidget {
  final DashboardViewModel vm;
  const ContactSection({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: vm.contacts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final c = vm.contacts[i];
          return Container(
            width: 110,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: C.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: c.color.withOpacity(0.12), shape: BoxShape.circle),
                child: Center(child: Text(c.name[0],
                    style: GoogleFonts.poppins(color: c.color, fontSize: 16, fontWeight: FontWeight.w700))),
              ),
              const SizedBox(height: 6),
              Text(c.name.split(' ').first,
                  style: GoogleFonts.poppins(color: C.textDark, fontSize: 11, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis),
              Text(c.relation, style: GoogleFonts.poppins(color: C.textGrey, fontSize: 9)),
            ]),
          );
        },
      ),
    );
  }
}

// ── Reminders Section ─────────────────────────────────────────────────────────
class RemindersSection extends StatelessWidget {
  final DashboardViewModel vm;
  const RemindersSection({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: vm.reminders.map((r) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: C.white, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
          ),
          child: Row(children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: r.color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.alarm_outlined, color: r.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.title, style: GoogleFonts.poppins(
                  color: C.textDark, fontSize: 13, fontWeight: FontWeight.w600)),
              Text(r.time, style: GoogleFonts.poppins(color: C.textGrey, fontSize: 11)),
            ])),
            Icon(Icons.chevron_right_rounded, color: C.textGrey.withOpacity(0.4), size: 20),
          ]),
        ),
      )).toList(),
    );
  }
}
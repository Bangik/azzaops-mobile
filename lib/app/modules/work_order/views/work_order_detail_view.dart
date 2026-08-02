import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/core/theme/app_theme.dart';
import '../../../../app/core/widgets/custom_appbar.dart';
import '../../../../app/core/widgets/loading_widget.dart';
import '../../../../app/routes/app_routes.dart';
import '../controllers/work_order_controller.dart';
import '../../../core/utils/storage_helper.dart';
import '../../../data/models/user_model.dart';

class WorkOrderDetailView extends GetView<WorkOrderController> {
  const WorkOrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final int woId = Get.arguments as int;
    
    // Fetch details on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchOrderDetail(woId);
    });

    final currentUser = StorageHelper.getUserData();
    final isKepala = currentUser?.isKepalaTeknisi ?? false;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Detail Work Order',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchOrderDetail(woId),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isDetailLoading.value) {
          return const LoadingWidget();
        }

        final wo = controller.detailWorkOrder.value;
        if (wo == null) {
          return const Center(child: Text('Work order tidak ditemukan'));
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status & Info Header Card
                    _buildHeaderCard(wo),
                    const SizedBox(height: 16),

                    // Takeover Banner (if pending)
                    _buildTakeoverBanner(wo, currentUser),

                    // Customer Info Card
                    _buildCustomerCard(wo),
                    const SizedBox(height: 16),

                    // Job Details
                    _buildJobDetailsCard(wo),
                    const SizedBox(height: 16),

                    // Work Order Items
                    if (wo.items.isNotEmpty) ...[
                      _buildItemsCard(wo),
                      const SizedBox(height: 16),
                    ],

                    // Assignments list
                    _buildAssignmentsCard(wo),
                    const SizedBox(height: 16),

                    // Takeover History Card (if any)
                    _buildTakeoverHistoryCard(wo),
                    const SizedBox(height: 16),

                    // Report section (if any)
                    if (wo.reports.isNotEmpty) ...[
                      _buildReportsCard(wo),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
            
            // Bottom Action buttons based on Role and Status
            _buildBottomAction(wo, isKepala),
          ],
        );
      }),
    );
  }

  Widget _buildHeaderCard(dynamic wo) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wo.woNumber,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
                    ),
                    Text(
                      'Dibuat: ${wo.createdAt.split('T').first}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                _buildStatusBadge(wo.status),
              ],
            ),
            const Divider(height: 24),
            Text(
              wo.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (wo.description != null && wo.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                wo.description!,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(dynamic wo) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Informasi Pelanggan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const Divider(),
            _buildDetailRow('Nama', wo.customer.displayName),
            _buildDetailRow('Telepon', wo.customer.phone),
            _buildDetailRow(
              'Alamat',
              wo.location,
              trailing: wo.gmapsLink != null && wo.gmapsLink!.isNotEmpty
                  ? InkWell(
                      onTap: () async {
                        final uri = Uri.parse(wo.gmapsLink!);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } else {
                          Get.snackbar('Error', 'Tidak dapat membuka Google Maps');
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.map, color: Colors.green, size: 20),
                      ),
                    )
                  : (wo.customer.gmapsLink != null && wo.customer.gmapsLink!.isNotEmpty
                      ? InkWell(
                          onTap: () async {
                            final uri = Uri.parse(wo.customer.gmapsLink!);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            } else {
                              Get.snackbar('Error', 'Tidak dapat membuka Google Maps');
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Icon(Icons.map, color: Colors.green, size: 20),
                          ),
                        )
                      : null),
            ),
            if (wo.customer.city != null) _buildDetailRow('Kota', wo.customer.city!),
          ],
        ),
      ),
    );
  }

  Widget _buildJobDetailsCard(dynamic wo) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Detail Pekerjaan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const Divider(),
            _buildDetailRow('Tipe WO', wo.type.toString().toUpperCase()),
            _buildDetailRow('Kategori', wo.serviceCategory.name),
            _buildDetailRow('Prioritas', wo.priority.toString().toUpperCase()),
            _buildDetailRow('Tanggal Rencana', wo.scheduledDate ?? '-'),
            _buildDetailRow('Mulai Aktual', wo.startedAt != null ? wo.startedAt!.split('T').first : '-'),
            _buildDetailRow('Selesai Aktual', wo.completedAt != null ? wo.completedAt!.split('T').first : '-'),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard(dynamic wo) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.list_alt, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Daftar Jasa & Material',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: wo.items.length,
              itemBuilder: (context, idx) {
                final item = wo.items[idx];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.description} (x${item.quantity} ${item.unit ?? ''})',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        'Rp ${item.totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentsCard(dynamic wo) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.people_outline, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Penugasan Teknisi',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const Divider(),
            if (wo.assignments.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Belum ada teknisi ditugaskan',
                  style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: wo.assignments.length,
                itemBuilder: (context, idx) {
                  final assign = wo.assignments[idx];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(assign.technicianName),
                    subtitle: Text('Status: ${assign.status.toUpperCase()}'),
                    trailing: Text(
                      assign.assignedAt.split('T').first,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsCard(dynamic wo) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics_outlined, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Laporan Pekerjaan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: wo.reports.length,
              itemBuilder: (context, idx) {
                final rpt = wo.reports[idx];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Teknisi: ${rpt.technician?.name ?? "Teknisi #${rpt.technicianId}"}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    _buildDetailRow('Temuan', rpt.findings),
                    _buildDetailRow('Pekerjaan', rpt.workDone),
                    if (rpt.recommendations != null) _buildDetailRow('Rekomendasi', rpt.recommendations!),
                    if (rpt.materialsUsed != null) _buildDetailRow('Sparepart', rpt.materialsUsed!),
                    const SizedBox(height: 8),
                    if (rpt.photos.isNotEmpty) ...[
                      const Text('Dokumentasi Foto:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: rpt.photos.length,
                          itemBuilder: (context, photoIdx) {
                            final photo = rpt.photos[photoIdx];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  // Prepend host URL if photoUrl is a relative path
                                  photo.photoUrl.startsWith('http')
                                      ? photo.photoUrl
                                      : 'http://10.0.2.2:8000/storage/${photo.photoUrl}',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, _, __) => Container(
                                    width: 100,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.broken_image, color: Colors.grey),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction(dynamic wo, bool isKepala) {
    final currentUser = StorageHelper.getUserData();
    final isAssignedToCurrentUser = wo.assignments.any((a) => (a.technician?.id == currentUser?.id || a.technicianId == currentUser?.id) && a.status != 'transferred');

    if (!isKepala && currentUser?.role == 'teknisi' && !isAssignedToCurrentUser) {
      if (wo.status != 'pending' && wo.status != 'assigned') {
        return const SizedBox.shrink();
      }

      // Check if there is already a pending takeover request from this technician
      final hasPendingTakeover = wo.takeovers.any((t) => t.requestedById == currentUser?.id && t.status == 'pending');

      return Container(
        padding: const EdgeInsets.all(16),
        color: AppColors.primary,
        child: ElevatedButton(
          onPressed: hasPendingTakeover ? null : () {
            _promptTakeoverNotes(wo.id);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: hasPendingTakeover ? Colors.grey.shade400 : Colors.white,
            foregroundColor: hasPendingTakeover ? Colors.white : AppColors.primary,
            minimumSize: const Size.fromHeight(50),
          ),
          child: Text(
            hasPendingTakeover ? 'PENGALIHAN SEDANG DIPROSES' : 'AMBIL ALIH PEKERJAAN',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    if (isKepala) {
      if (wo.status == 'pending') {
        return Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.primary,
          child: ElevatedButton(
            onPressed: () {
              Get.toNamed(AppRoutes.ASSIGN_TECHNICIAN, arguments: wo.id);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
            ),
            child: const Text('ASSIGN TEKNISI', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      }
    } else {
      // For standard technicians
      if (wo.status == 'assigned') {
        return Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.primary,
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Update to in_progress
                    controller.updateStatus(wo.id, 'in_progress');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text('MULAI PEKERJAAN', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              if (wo.type == 'checking') ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      controller.updateStatus(wo.id, 'checking');
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 1.5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('PENGECEKAN', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ),
        );
      }

      if (wo.status == 'in_progress' || wo.status == 'checking') {
        return Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.primary,
          child: ElevatedButton(
            onPressed: () {
              Get.toNamed(AppRoutes.SUBMIT_REPORT, arguments: wo.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Text('SUBMIT LAPORAN', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      }
    }

    return const SizedBox.shrink();
  }

  Widget _buildDetailRow(String label, String value, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = AppColors.warning;
        label = 'Pending';
        break;
      case 'assigned':
        color = AppColors.accent;
        label = 'Assigned';
        break;
      case 'in_progress':
        color = Colors.indigo;
        label = 'Dikerjakan';
        break;
      case 'checking':
        color = Colors.blueGrey;
        label = 'Pengecekan';
        break;
      case 'reported':
        color = Colors.purple;
        label = 'Dilaporkan';
        break;
      case 'completed':
        color = AppColors.success;
        label = 'Selesai';
        break;
      case 'cancelled':
        color = AppColors.error;
        label = 'Batal';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTakeoverBanner(dynamic wo, UserModel? currentUser) {
    if (currentUser == null) return const SizedBox.shrink();

    // Find a pending takeover using standard where lookup to avoid collection extensions conflict
    final pendingTakeovers = wo.takeovers.where((t) => t.status == 'pending');
    if (pendingTakeovers.isEmpty) return const SizedBox.shrink();
    final pendingTakeover = pendingTakeovers.first;

    final isOriginalTech = pendingTakeover.originalTechnicianId == currentUser.id;
    final isManager = currentUser.isKepalaTeknisi || currentUser.role == 'admin' || currentUser.role == 'super_admin';

    // Show only to original technician or manager
    if (!isOriginalTech && !isManager) return const SizedBox.shrink();

    return Card(
      color: Colors.amber.shade50,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.amber.shade300, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.swap_horizontal_circle_outlined, color: Colors.amber, size: 24),
                SizedBox(width: 8),
                Text(
                  'Pengalihan Pekerjaan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.orange),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Teknisi ${pendingTakeover.requester?.name ?? 'Lain'} mengajukan untuk mengambil alih pekerjaan ini dari ${pendingTakeover.originalTechnician?.name ?? 'Anda'}.',
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            ),
            if (pendingTakeover.notes != null && pendingTakeover.notes!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Catatan: "${pendingTakeover.notes}"',
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Get.dialog(
                      AlertDialog(
                        title: const Text('Tolak Pengalihan'),
                        content: const Text('Apakah Anda yakin ingin menolak pengambilalihan ini?'),
                        actions: [
                          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
                          TextButton(
                            onPressed: () {
                              Get.back();
                              controller.rejectTakeover(pendingTakeover.id, wo.id);
                            },
                            child: const Text('Tolak', style: TextStyle(color: AppColors.error)),
                          ),
                        ],
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    foregroundColor: AppColors.error,
                  ),
                  child: const Text('TOLAK'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    Get.dialog(
                      AlertDialog(
                        title: const Text('Setujui Pengalihan'),
                        content: const Text('Apakah Anda yakin ingin menyetujui pengambilalihan pekerjaan ini?'),
                        actions: [
                          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
                          TextButton(
                            onPressed: () {
                              Get.back();
                              controller.approveTakeover(pendingTakeover.id, wo.id);
                            },
                            child: const Text('Setujui', style: TextStyle(color: AppColors.success)),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('SETUJUI'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTakeoverHistoryCard(dynamic wo) {
    if (wo.takeovers.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Riwayat Pengalihan Pekerjaan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: wo.takeovers.length,
              itemBuilder: (context, idx) {
                final takeover = wo.takeovers[idx];
                Color statusColor = Colors.grey;
                if (takeover.status == 'approved') statusColor = AppColors.success;
                if (takeover.status == 'rejected') statusColor = AppColors.error;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Dari: ${takeover.originalTechnician?.name ?? 'Teknisi'} ➔ Ke: ${takeover.requester?.name ?? 'Teknisi'}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              takeover.status.toUpperCase(),
                              style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      if (takeover.notes != null && takeover.notes!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Catatan: "${takeover.notes}"',
                          style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        'Tanggal: ${takeover.createdAt.split('T').first}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      if (idx < wo.takeovers.length - 1) const Divider(),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _promptTakeoverNotes(int woId) {
    final textController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Ambil Alih Pekerjaan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan alasan atau catatan pengalihan pekerjaan ini (opsional):',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                hintText: 'Tulis catatan...',
              ),
              maxLength: 255,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.requestTakeover(woId, notes: textController.text.trim());
            },
            child: const Text('Kirim', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

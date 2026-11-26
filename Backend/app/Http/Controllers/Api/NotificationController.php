<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\NotificationResource;
use App\Models\Notification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request)
    {
        $notifications = Notification::where('user_id', $request->user()->id)
            ->latest()
            ->paginate(min((int) $request->query('per_page', 20), 100));

        return NotificationResource::collection($notifications);
    }

    public function markRead(Request $request, int $id): NotificationResource
    {
        $notification = Notification::where('user_id', $request->user()->id)->findOrFail($id);
        $notification->forceFill(['read_at' => $notification->read_at ?? now()])->save();

        return new NotificationResource($notification);
    }

    public function markAllRead(Request $request): JsonResponse
    {
        Notification::where('user_id', $request->user()->id)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        return response()->json(['message' => 'Semua notifikasi ditandai dibaca.']);
    }
}
